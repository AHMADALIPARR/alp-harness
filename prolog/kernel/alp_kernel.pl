% SPDX-License-Identifier: AGPL-3.0-only
% Copyright (C) 2026 Ahmad Ali Parr
% GNU Affero General Public License version 3 only.
%
% Recursive ALPprolog-style kernel
% Pure Prolog. Program terms, not Python.
%
% Offline:  exec(Program, State0, State, History)
% Online:   exec_online(Program, RealState0, BeliefState0, FinalRealState, History)
%
% State: a list of fluent-value pairs, [at=home, battery=high].
% A boolean fluent may be written F=true or simply F.
%
% Belief state: a non-empty list of possible states.
%
% User supplies:
%   primitive_action(A).
%   impossible(A, S).          % optional; absence means possible
%   effects(A, S, Effects).    % Effects is a list of F=V
%   senses(A, Fluents).        % Fluents is a list of fluent names; [] if none
%   agent_proc(Name, Body).
%
% Program terms:
%   nil
%   prim(A)  sense(A)  call(Name)
%   seq(P, Q)  choice(P, Q)  if(Cond, Then, Else)
%   while(Cond, Body)  star(P)

get_fluent(F, V, S) :-
    member(F=V, S).

remove_fluent(_, [], []).
remove_fluent(F, [F0=_|T], T2) :-
    F0 == F, !,
    remove_fluent(F, T, T2).
remove_fluent(F, [H|T], [H|T2]) :-
    remove_fluent(F, T, T2).

set_fluent(F, V, S, S2) :-
    remove_fluent(F, S, S1),
    S2 = [F=V|S1].

holds(true, _).
holds(false, _) :- fail.

holds(F=V, S) :-
    get_fluent(F, V, S).

holds(F, S) :-
    atom(F),
    get_fluent(F, true, S).

holds(and(A, B), S) :-
    holds(A, S),
    holds(B, S).

holds(or(A, B), S) :-
    holds(A, S)
    ; holds(B, S).

holds(neg(A), S) :-
    \+ holds(A, S).

k_holds(C, BS) :-
    BS \= [],
    \+ ( member(S, BS), \+ holds(C, S) ).

k_poss(A, BS) :-
    BS \= [],
    \+ ( member(S, BS), \+ poss(A, S) ).

poss(A, S) :-
    primitive_action(A),
    \+ impossible(A, S).

apply_effects([], S, S).
apply_effects([F=V|Es], S, S2) :-
    set_fluent(F, V, S, S1),
    apply_effects(Es, S1, S2).

result(A, S, S2) :-
    effects(A, S, Effects),
    apply_effects(Effects, S, S2).

update_belief(A, BS, BS1) :-
    update_belief_list(BS, A, BS1).

update_belief_list([], _, []).
update_belief_list([S|Ss], A, [S2|BS2]) :-
    result(A, S, S2),
    update_belief_list(Ss, A, BS2).

filter_belief(_, _, [], []).
filter_belief(F, V, [S|Ss], BS2) :-
    (   holds(F=V, S)
    ->  BS2 = [S|Rest]
    ;   BS2 = Rest
    ),
    filter_belief(F, V, Ss, Rest).

sense_update(A, RealS, BS, BS2) :-
    senses(A, Fs),
    filter_sensed(Fs, RealS, BS, BS2).

filter_sensed([], _, BS, BS).
filter_sensed([F|Fs], RealS, BS, BS2) :-
    holds(F=V, RealS),
    filter_belief(F, V, BS, BS1),
    filter_sensed(Fs, RealS, BS1, BS2).

exec(nil, S, S, []).

exec(seq(P, Q), S, S2, H) :-
    exec(P, S, S1, H1),
    exec(Q, S1, S2, H2),
    append(H1, H2, H).

exec(choice(P, _), S, S2, H) :-
    exec(P, S, S2, H).
exec(choice(_, Q), S, S2, H) :-
    exec(Q, S, S2, H).

exec(if(Cond, Then, Else), S, S2, H) :-
    (   holds(Cond, S)
    ->  exec(Then, S, S2, H)
    ;   exec(Else, S, S2, H)
    ).

exec(prim(A), S, S2, [A]) :-
    poss(A, S),
    result(A, S, S2).

exec(sense(A), S, S2, [A]) :-
    poss(A, S),
    result(A, S, S2).

exec(call(Name), S, S2, H) :-
    agent_proc(Name, Body),
    exec(Body, S, S2, H).

step_limit(64).

exec(while(Cond, Body), S, S2, H) :-
    step_limit(Lim),
    exec_while(Cond, Body, S, S2, H, 0, Lim).
exec(while(Cond, Body), S, S2, H) :-
    \+ holds(Cond, S),
    S2 = S,
    H = [].

exec_while(_, _, _, _, _, N, Lim) :-
    N >= Lim,
    !,
    throw(execution_limit_exceeded(Lim)).
exec_while(Cond, Body, S, S2, H, N, Lim) :-
    holds(Cond, S),
    !,
    N1 is N + 1,
    exec(Body, S, S1, H1),
    exec_while(Cond, Body, S1, S2, H2, N1, Lim),
    append(H1, H2, H).
exec_while(_, _, S, S, [], _, _).

exec(star(P), S, S2, H) :-
    step_limit(Lim),
    exec_star(P, S, S2, H, 0, Lim).
exec(star(_), S, S, []).

exec_star(_, _, _, _, N, Lim) :-
    N >= Lim,
    !,
    throw(execution_limit_exceeded(Lim)).
exec_star(P, S, S2, H, N, Lim) :-
    N1 is N + 1,
    exec(P, S, S1, H1),
    H1 \== [],
    exec_star(P, S1, S2, H2, N1, Lim),
    append(H1, H2, H).
exec_star(_, S, S, [], _, _).

trans_b(prim(A), BS, A, nil) :-
    k_poss(A, BS).

trans_b(sense(A), BS, A, nil) :-
    k_poss(A, BS).

trans_b(seq(P, Q), BS, A, R) :-
    trans_b(P, BS, A, P1),
    (   P1 == nil
    ->  R = Q
    ;   R = seq(P1, Q)
    ).

trans_b(choice(P, _), BS, A, P1) :-
    trans_b(P, BS, A, P1).
trans_b(choice(_, Q), BS, A, P1) :-
    trans_b(Q, BS, A, P1).

trans_b(if(Cond, Then, _), BS, A, P1) :-
    k_holds(Cond, BS),
    trans_b(Then, BS, A, P1).
trans_b(if(Cond, _, Else), BS, A, P1) :-
    k_holds(neg(Cond), BS),
    trans_b(Else, BS, A, P1).

trans_b(while(Cond, Body), BS, A, seq(P1, while(Cond, Body))) :-
    k_holds(Cond, BS),
    trans_b(Body, BS, A, P1).

trans_b(call(Name), BS, A, P1) :-
    agent_proc(Name, Body),
    trans_b(Body, BS, A, P1).

trans_b(star(P), BS, A, seq(P1, star(P))) :-
    trans_b(P, BS, A, P1).

reduce_once(seq(nil, Q), _, Q).
reduce_once(seq(P, Q), BS, seq(P1, Q)) :-
    reduce_once(P, BS, P1).

reduce_once(if(Cond, Then, _), BS, Then) :-
    k_holds(Cond, BS), !.
reduce_once(if(Cond, _, Else), BS, Else) :-
    k_holds(neg(Cond), BS), !.

reduce_once(while(Cond, _), BS, nil) :-
    k_holds(neg(Cond), BS), !.

reduce_once(call(Name), _, Body) :-
    agent_proc(Name, Body).

simplify(P, BS, P1) :-
    reduce_once(P, BS, P2), !,
    simplify(P2, BS, P1).
simplify(P, _, P).

exec_online(P, RealS, BS, FinalS, H) :-
    step_limit(Lim),
    exec_online(P, RealS, BS, FinalS, H, 0, Lim).

exec_online(_, _, _, _, _, N, Lim) :-
    N >= Lim,
    !,
    throw(execution_limit_exceeded(Lim)).
exec_online(P, RealS, BS, FinalS, H, N, Lim) :-
    simplify(P, BS, P1),
    (   P1 == nil
    ->  FinalS = RealS,
        H = []
    ;   N1 is N + 1,
        trans_b(P1, BS, A, P2),
        result(A, RealS, RealS1),
        update_belief(A, BS, BS1),
        sense_update(A, RealS1, BS1, BS2),
        exec_online(P2, RealS1, BS2, FinalS, H1, N1, Lim),
        H = [A|H1]
    ).
