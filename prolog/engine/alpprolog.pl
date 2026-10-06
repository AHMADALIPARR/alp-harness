% SPDX-License-Identifier: AGPL-3.0-only
% Copyright (C) 2026 Ahmad Ali Parr
% GNU Affero General Public License version 3 only.
%
% Agent strategy: ordinary definite clauses, plus
%   ?(Phi)     query the current state (does not change time)
%   do(Action) execute Action if its precondition holds, then progress
%
% Online control: the programmer must cut after every do/1 so that
% Prolog does not backtrack over an executed action.
%
% Action theory facts (defined by the domain file):
%   initial_state(PIList).
%   action(Action, Precond, EffectAxioms).
%   aux(Pred/Arity).                  % optional
%   sensors([SenseFunctor, ...]).     % optional
%   sensor_axiom(SenseTerm, Vals).    % optional
%   sensing_result(SenseTerm, Result).% optional; else the engine asks
%
% PI-list: a list of clauses. A clause is a fluent literal, or a list
% of at least two fluent literals. A fluent literal is F or neg(F).
% Effect axioms: a list of Cond-Eff pairs. Cond is a PI-list.
% Eff is a list of fluent literals (the update).
% Sensor values: a list of Val-Index-Meaning triples.
%   Val    = Arg-Result
%   Index  = PI-list of unit clauses (context that selects the axiom)
%   Meaning= PI-list entailed by the observation in that context

% Plain Prolog (no module). Domain files and this engine share one namespace,
% matching the original ALPprolog style.

:- dynamic current_state/1.
:- dynamic observed_sensing/2.

% ---------------------------------------------------------------------------
% Public control
% ---------------------------------------------------------------------------

alp_reset :-
    retractall(current_state(_)),
    retractall(observed_sensing(_, _)),
    (   initial_state(PI0)
    ->  normalize_pi(PI0, PI),
        asserta(current_state(PI))
    ;   asserta(current_state([]))
    ).

alp_state(PI) :-
    (   current_state(PI)
    ->  true
    ;   alp_reset,
        current_state(PI)
    ).

% Run a strategy from the initial state. Fails if the strategy fails.
alp_run(Goal) :-
    alp_reset,
    call(Goal).

% ?(Phi) — entailment, or sensing when Phi is a declared sense fluent.
?(Phi) :-
    (   query_is_sense(Phi, Sense)
    ->  sense(Sense)
    ;   alp_state(State),
        query_form(Phi, Form),
        entails(State, Form)
    ).

% do(Action) — precondition, then progression. Call cut after do/1 online.
do(Action) :-
    alp_state(State),
    action(Action, Precond, Cases),
    entails(State, Precond),
    applicable_case(Cases, State, Eff),
    progress(State, Eff, Next),
    replace_state(Next).

holds(Phi) :- ?(Phi).

% ---------------------------------------------------------------------------
% Query forms
% ---------------------------------------------------------------------------

query_form(Phi, Form) :-
    (   Phi = [_|_]
    ->  maplist(as_clause, Phi, Form)
    ;   as_clause(Phi, C),
        Form = [C]
    ).

as_clause([L|Ls], Clause) :-
    !,
    maplist(as_literal, [L|Ls], Lits),
    sort(Lits, Clause).
as_clause(Lit, Clause) :-
    as_literal(Lit, L),
    Clause = [L].

as_literal(neg(F), neg(F)) :- !.
as_literal(F, F).

% ---------------------------------------------------------------------------
% Entailment
% ---------------------------------------------------------------------------

entails(State, PI0) :-
    normalize_query(PI0, PI),
    entails_clauses(PI, State).

normalize_query([], []).
normalize_query([C|Cs], [Clause|Rest]) :-
    as_clause(C, Clause),
    normalize_query(Cs, Rest).

entails_clauses([], _).
entails_clauses([C|Cs], State) :-
    entails_clause(C, State),
    entails_clauses(Cs, State).

entails_clause(Clause, State) :-
    split_clause(Clause, Fluents, AuxAtoms),
    (   Fluents = []
    ->  true
    ;   member(PI, State),
        subsumes_clause(PI, Fluents)
    ),
    entails_aux(AuxAtoms).

subsumes_clause(PI, Query) :-
    subset_unify(PI, Query).

subset_unify([], _).
subset_unify([L|Ls], Query) :-
    select_unify(L, Query, Rest),
    subset_unify(Ls, Rest).

select_unify(L, [Q|Qs], Qs) :-
    L = Q.
select_unify(L, [Q|Qs], [Q|Rest]) :-
    select_unify(L, Qs, Rest).

split_clause([], [], []).
split_clause([Lit|Lits], Fluents, Aux) :-
    literal_atom(Lit, Atom),
    (   aux_atom(Atom)
    ->  Fluents = Fs,
        Aux = [Atom|As]
    ;   Fluents = [Lit|Fs],
        Aux = As
    ),
    split_clause(Lits, Fs, As).

literal_atom(neg(F), F) :- !.
literal_atom(F, F).

aux_atom(Atom) :-
    current_predicate(aux/1),
    aux(Preds),
    functor(Atom, F, A),
    member(F/A, Preds),
    !.

entails_aux([]).
entails_aux([A|As]) :-
    call(A),
    entails_aux(As).

% ---------------------------------------------------------------------------
% Update / progression
% ---------------------------------------------------------------------------

applicable_case([], _, []) :- !.
applicable_case([Cond-Eff|_], State, Eff) :-
    entails(State, Cond),
    !.
applicable_case([_|Cases], State, Eff) :-
    applicable_case(Cases, State, Eff).

progress(State, Eff, Next) :-
    maplist(as_literal, Eff, Lits),
    delete_affected(State, Lits, Kept),
    maplist(unit_clause, Lits, Units),
    append(Kept, Units, Raw),
    normalize_pi(Raw, Next).

unit_clause(L, [L]).

delete_affected([], _, []).
delete_affected([C|Cs], Eff, Out) :-
    (   clause_affected(C, Eff)
    ->  delete_affected(Cs, Eff, Out)
    ;   Out = [C|Rest],
        delete_affected(Cs, Eff, Rest)
    ).

clause_affected(C, Eff) :-
    member(L, C),
    member(E, Eff),
    complement(L, E),
    !.
clause_affected(C, Eff) :-
    member(L, C),
    member(E, Eff),
    L == E,
    !.

complement(neg(F), F) :- !.
complement(F, neg(F)) :- atom_or_compound(F).

atom_or_compound(T) :- atom(T), !.
atom_or_compound(T) :- compound(T).

% ---------------------------------------------------------------------------
% Sensing
% ---------------------------------------------------------------------------

:- multifile sensing_result/2.

query_is_sense(Phi, Sense) :-
    current_predicate(sensors/1),
    (   Phi = [Sense]
    ->  true
    ;   Sense = Phi
    ),
    Sense =.. [F|_],
    sensors(Ss),
    memberchk(F, Ss),
    !.

q(Phi) :- ?(Phi).

sense(Sense) :-
    alp_state(State),
    sensor_axiom(Pattern, Vals),
    copy_term(Pattern-Vals, Sense-Vals2),
    observe(Sense, Result),
    select_meaning(Vals2, Sense, Result, State, Meaning),
    append(State, Meaning, Raw),
    prime_implicates(Raw, Next),
    replace_state(Next),
    assertz(observed_sensing(Sense, Result)).

observe(Sense, Result) :-
    observed_sensing(Sense, Result),
    !.
observe(Sense, Result) :-
    sensing_result(Sense, Result),
    !.
observe(Sense, Result) :-
    write('sensing '), write(Sense), write(' = '),
    read(Result).

select_meaning([Val-Index-Meaning|_], Sense, Result, State, Meaning) :-
    val_matches(Val, Sense, Result),
    entails(State, Index),
    !.
select_meaning([_|Rest], Sense, Result, State, Meaning) :-
    select_meaning(Rest, Sense, Result, State, Meaning).

val_matches(Arg-Result, Sense, Result) :-
    Sense =.. [_|Args],
    Args = [Arg|_].

% ---------------------------------------------------------------------------
% Prime implicates
% ---------------------------------------------------------------------------

prime_implicates(Clauses0, PI) :-
    maplist(as_clause, Clauses0, Cs0),
    include(non_tautology, Cs0, Cs1),
    sort(Cs1, Cs2),
    resolve_close(Cs2, PI).

normalize_pi(Clauses0, PI) :-
    maplist(as_clause, Clauses0, Cs0),
    include(non_tautology, Cs0, Cs1),
    sort(Cs1, Cs2),
    drop_subsumed(Cs2, PI).

non_tautology(C) :-
    \+ tautology(C).

tautology(C) :-
    member(L, C),
    complement(L, N),
    member(N, C).

resolve_close(Cs, PI) :-
    resolve_once(Cs, New),
    (   New = []
    ->  drop_subsumed(Cs, PI)
    ;   append(Cs, New, All),
        sort(All, Sorted),
        drop_subsumed(Sorted, Reduced),
        resolve_close(Reduced, PI)
    ).

resolve_once(Cs, New) :-
    findall(R, (member(C1, Cs), member(C2, Cs), C1 @< C2, resolvent(C1, C2, R)), Rs),
    include(fresh_clause(Cs), Rs, New).

fresh_clause(Cs, R) :-
    \+ member(R, Cs),
    \+ (member(C, Cs), subset(C, R)).

resolvent(C1, C2, R) :-
    member(L, C1),
    complement(L, N),
    member(N, C2),
    select(L, C1, R1),
    select(N, C2, R2),
    append(R1, R2, Raw),
    sort(Raw, R),
    \+ tautology(R).

drop_subsumed(Cs, Out) :-
    include(not_subsumed(Cs), Cs, Out).

not_subsumed(Cs, C) :-
    \+ (member(D, Cs), D \== C, subset(D, C)).

replace_state(PI) :-
    retractall(current_state(_)),
    asserta(current_state(PI)).
