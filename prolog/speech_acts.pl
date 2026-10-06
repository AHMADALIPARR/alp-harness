% SPDX-License-Identifier: AGPL-3.0-only
% Copyright (C) 2026 Ahmad Ali Parr
% GNU Affero General Public License version 3 only.
%
% Speech act theory for the dialogue logic program.
% Pure Prolog. Load after dialog_kb.pl.
%
% Searle's felicity conditions, one clause group per act:
%   propositional content, preparatory, sincerity, essential.
% An act may be performed only if felicitous/1 succeeds.
% reply_sa/4 is the dialogue rule restricted by those conditions.
%
%   ?- [dialog_kb, speech_acts].
%   ?- felicitous(tell(guide, visitor, located(gold, vault))).
%   ?- reply_sa(guide, visitor, ask(visitor, guide, where, gold), Act).
%   ?- sample_script(S), dialogue_sa(S, Trace).

% ------------------------------------------------------------
% Illocutionary force (Searle 1975 classes)
% ------------------------------------------------------------

force(tell(_, _, _), assertive).
force(confirm(_, _, _), assertive).
force(deny(_, _, _), assertive).
force(ask(_, _, _, _), directive).
force(clarify(_, _, _), directive).
force(offer(_, _, _), commissive).
force(accept(_, _, _), commissive).
force(reject(_, _, _), commissive).
force(greet(_, _), expressive).
force(ack(_, _), expressive).
force(close(_, _), expressive).

assertive(Act) :- force(Act, assertive).
directive(Act) :- force(Act, directive).
commissive(Act) :- force(Act, commissive).
expressive(Act) :- force(Act, expressive).

% ------------------------------------------------------------
% Propositional content condition
% ------------------------------------------------------------

content(tell(_, _, F)) :- proposition(F).
content(confirm(_, _, F)) :- proposition(F).
content(deny(_, _, F)) :- proposition(F).
content(ask(_, _, Q, T)) :- question(Q), topic(T).
content(clarify(_, _, T)) :- topic(T).
content(offer(_, _, O)) :- object(O).
content(accept(_, _, O)) :- object(O).
content(reject(_, _, O)) :- object(O).
content(greet(S, H)) :- agent(S), agent(H), S \== H.
content(ack(S, H)) :- agent(S), agent(H), S \== H.
content(close(S, H)) :- agent(S), agent(H), S \== H.

proposition(located(_, _)).
proposition(isa(_, _)).
proposition(property(_, _)).
proposition(adjacent(_, _)).
proposition(topic(_)).
proposition(competent(_, _)).
proposition(home(_, _)).
proposition(unknown(_, _)).
proposition(neg(F)) :- proposition(F).

% ------------------------------------------------------------
% Preparatory conditions
% ------------------------------------------------------------

preparatory(tell(S, _, F)) :-
    topic_of(F, T),
    competent(S, T).
preparatory(confirm(S, _, F)) :-
    believes(S, F).
preparatory(deny(S, _, F)) :-
    ( believes(S, neg(F)) ; \+ believes(S, F) ).
preparatory(ask(S, H, _, T)) :-
    agent(S), agent(H), S \== H, topic(T).
preparatory(clarify(S, H, T)) :-
    agent(S), agent(H), topic(T),
    \+ competent(S, T).
preparatory(offer(S, _, O)) :-
    object(O),
    \+ believes(S, prohibited(O)).
preparatory(accept(S, _, O)) :-
    object(O),
    \+ believes(S, prohibited(O)).
preparatory(reject(_, _, O)) :-
    object(O).
preparatory(greet(S, H)) :- agent(S), agent(H), S \== H.
preparatory(ack(S, H)) :- agent(S), agent(H), S \== H.
preparatory(close(S, H)) :- agent(S), agent(H), S \== H.

topic_of(located(O, _), O) :- topic(O), !.
topic_of(located(_, _), supply).
topic_of(property(O, _), O) :- topic(O), !.
topic_of(isa(O, _), O) :- topic(O), !.
topic_of(adjacent(_, _), route).
topic_of(competent(_, T), T).
topic_of(home(_, _), route).
topic_of(topic(T), T).
topic_of(unknown(_, T), T).
topic_of(neg(F), T) :- topic_of(F, T).

% ------------------------------------------------------------
% Sincerity and essential conditions
% ------------------------------------------------------------

sincerity(tell(S, _, F)) :- believes(S, F).
sincerity(confirm(S, _, F)) :- believes(S, F).
sincerity(deny(S, _, F)) :- \+ believes(S, F).
sincerity(ask(S, H, _, _)) :- agent(S), agent(H), S \== H.
sincerity(clarify(S, H, _)) :- agent(S), agent(H).
sincerity(offer(S, H, _)) :- agent(S), agent(H), S \== H.
sincerity(accept(S, H, _)) :- agent(S), agent(H).
sincerity(reject(S, H, _)) :- agent(S), agent(H).
sincerity(greet(S, H)) :- agent(S), agent(H).
sincerity(ack(S, H)) :- agent(S), agent(H).
sincerity(close(S, H)) :- agent(S), agent(H).

% Essential: the act counts as an attempt to make the hearer
% recognise the illocutionary point.
essential(tell(S, H, F)) :- counts_as(S, H, undertake(truth(F))).
essential(confirm(S, H, F)) :- counts_as(S, H, undertake(truth(F))).
essential(deny(S, H, F)) :- counts_as(S, H, undertake(falsity(F))).
essential(ask(S, H, Q, T)) :- counts_as(S, H, attempt(answer(Q, T))).
essential(clarify(S, H, T)) :- counts_as(S, H, attempt(repair(T))).
essential(offer(S, H, O)) :- counts_as(S, H, commit(transfer(O))).
essential(accept(S, H, O)) :- counts_as(S, H, commit(receive(O))).
essential(reject(S, H, O)) :- counts_as(S, H, refuse(transfer(O))).
essential(greet(S, H)) :- counts_as(S, H, recognise(contact)).
essential(ack(S, H)) :- counts_as(S, H, recognise(uptake)).
essential(close(S, H)) :- counts_as(S, H, recognise(end)).

counts_as(S, H, _) :- agent(S), agent(H), S \== H.

felicitous(Act) :-
    content(Act),
    preparatory(Act),
    sincerity(Act),
    essential(Act).

% ------------------------------------------------------------
% Logic programming dialogue under felicity
% A reply is admitted only when the produced act is felicitous.
% ------------------------------------------------------------

reply_sa(Hearer, Speaker, In, Act) :-
    reply(Hearer, Speaker, In, Act),
    felicitous(Act).

dialogue_sa([], []).
dialogue_sa([Act|Acts], [Act, Reply|Trace]) :-
    felicitous(Act),
    participants(Act, Speaker, Hearer),
    reply_sa(Hearer, Speaker, Act, Reply),
    dialogue_sa(Acts, Trace).

% Uptake: assertive success adds the content to the hearer's beliefs
% only as common ground, not as private belief, unless confirmed.
uptake(tell(S, H, F), cg(F)) :- felicitous(tell(S, H, F)).
uptake(confirm(S, H, F), cg(F)) :- felicitous(confirm(S, H, F)).
uptake(deny(S, H, F), cg(neg(F))) :- felicitous(deny(S, H, F)).
uptake(accept(S, H, O), cg(committed(S, receive(O)))) :- felicitous(accept(S, H, O)).

% Perlocutionary aim is recorded, not executed.
perlocution(tell(_, H, F), H, believe(F)).
perlocution(ask(_, H, Q, T), H, answer(Q, T)).
perlocution(offer(_, H, O), H, consider(O)).
perlocution(greet(_, H), H, notice).
