% SPDX-License-Identifier: AGPL-3.0-only
% Copyright (C) 2026 Ahmad Ali Parr
% GNU Affero General Public License version 3 only.

% Agent dialogue knowledge base
% Pure Prolog. Load alone, or after alp_kernel.pl.
%
% Query:
%   ?- [dialog_kb].
%   ?- reply(guide, visitor, ask(where, gold), Act).
%   ?- dialogue([greet(visitor, guide), ask(visitor, guide, where, gold)], Trace).
%
% Speech acts: greet, ask, tell, confirm, deny, clarify, offer, accept, reject, ack, close.
% Belief: believes(Agent, Fluent).  Common ground: cg(Fluent).
% Commitment: committed(Agent, Hearer, Act).

% ------------------------------------------------------------
% Taxonomy and meta
% ------------------------------------------------------------
kind(agent). kind(place). kind(object). kind(topic). kind(act). kind(property).
isa(X, X).
isa(X, Z) :- parent(X, Y), isa(Y, Z).
kind_of(X, K) :- isa(X, Y), kind(Y), K = Y.

parent(person, agent). parent(guide, person). parent(visitor, person).
parent(scholar, person). parent(merchant, person). parent(guard, person).
parent(region, place). parent(city, place). parent(room, place). parent(wild, place).
parent(artifact, object). parent(tool, artifact). parent(good, artifact).
parent(substance, object). parent(creature, object).
parent(query, act). parent(assert, act). parent(directive, act). parent(social, act).

agent(guide).
role(guide, guide).
home(guide, hall).
isa(guide, guide).
agent(visitor).
role(visitor, visitor).
home(visitor, gate).
isa(visitor, visitor).
agent(scholar).
role(scholar, scholar).
home(scholar, library).
isa(scholar, scholar).
agent(merchant).
role(merchant, merchant).
home(merchant, market).
isa(merchant, merchant).
agent(guard).
role(guard, guard).
home(guard, gate).
isa(guard, guard).
agent(archivist).
role(archivist, scholar).
home(archivist, archive).
isa(archivist, scholar).
agent(pilot).
role(pilot, guide).
home(pilot, dock).
isa(pilot, guide).
agent(medic).
role(medic, scholar).
home(medic, clinic).
isa(medic, scholar).
agent(ranger).
role(ranger, guard).
home(ranger, wild).
isa(ranger, guard).
agent(broker).
role(broker, merchant).
home(broker, exchange).
isa(broker, merchant).

place(gate).
isa(gate, place).
place(hall).
isa(hall, place).
place(library).
isa(library, place).
place(archive).
isa(archive, place).
place(market).
isa(market, place).
place(exchange).
isa(exchange, place).
place(dock).
isa(dock, place).
place(clinic).
isa(clinic, place).
place(wild).
isa(wild, place).
place(maze).
isa(maze, place).
place(cellar).
isa(cellar, place).
place(tower).
isa(tower, place).
place(garden).
isa(garden, place).
place(forge).
isa(forge, place).
place(shrine).
isa(shrine, place).
place(vault).
isa(vault, place).
place(north_road).
isa(north_road, place).
place(south_road).
isa(south_road, place).
place(east_yard).
isa(east_yard, place).
place(west_yard).
isa(west_yard, place).
place(river).
isa(river, place).
place(bridge).
isa(bridge, place).
place(quarry).
isa(quarry, place).
place(orchard).
isa(orchard, place).
place(barracks).
isa(barracks, place).
place(observatory).
isa(observatory, place).

adjacent(gate, hall).
adjacent(hall, gate).
adjacent(hall, library).
adjacent(library, hall).
adjacent(library, archive).
adjacent(archive, library).
adjacent(hall, market).
adjacent(market, hall).
adjacent(market, exchange).
adjacent(exchange, market).
adjacent(hall, dock).
adjacent(dock, hall).
adjacent(dock, river).
adjacent(river, dock).
adjacent(hall, clinic).
adjacent(clinic, hall).
adjacent(gate, north_road).
adjacent(north_road, gate).
adjacent(north_road, wild).
adjacent(wild, north_road).
adjacent(wild, maze).
adjacent(maze, wild).
adjacent(hall, tower).
adjacent(tower, hall).
adjacent(tower, observatory).
adjacent(observatory, tower).
adjacent(market, forge).
adjacent(forge, market).
adjacent(hall, garden).
adjacent(garden, hall).
adjacent(garden, shrine).
adjacent(shrine, garden).
adjacent(hall, cellar).
adjacent(cellar, hall).
adjacent(cellar, vault).
adjacent(vault, cellar).
adjacent(gate, barracks).
adjacent(barracks, gate).
adjacent(market, orchard).
adjacent(orchard, market).
adjacent(orchard, south_road).
adjacent(south_road, orchard).
adjacent(dock, bridge).
adjacent(bridge, dock).
adjacent(bridge, east_yard).
adjacent(east_yard, bridge).
adjacent(forge, quarry).
adjacent(quarry, forge).
adjacent(barracks, west_yard).
adjacent(west_yard, barracks).
reachable(A, B) :- adjacent(A, B).
reachable(A, C) :- adjacent(A, B), reachable(B, C), A \== C.

object(gold).
isa(gold, good).
located(gold, vault).
object(map).
isa(map, tool).
located(map, library).
object(key).
isa(key, tool).
located(key, guard).
object(lamp).
isa(lamp, tool).
located(lamp, hall).
object(rope).
isa(rope, tool).
located(rope, dock).
object(book).
isa(book, good).
located(book, library).
object(ore).
isa(ore, substance).
located(ore, quarry).
object(herb).
isa(herb, substance).
located(herb, orchard).
object(coin).
isa(coin, good).
located(coin, exchange).
object(seal).
isa(seal, artifact).
located(seal, archive).
object(compass).
isa(compass, tool).
located(compass, observatory).
object(shield).
isa(shield, tool).
located(shield, barracks).
object(potion).
isa(potion, substance).
located(potion, clinic).
object(grain).
isa(grain, good).
located(grain, market).
object(stone).
isa(stone, substance).
located(stone, quarry).
object(bell).
isa(bell, artifact).
located(bell, shrine).
object(chart).
isa(chart, tool).
located(chart, dock).
object(ink).
isa(ink, substance).
located(ink, archive).
object(blade).
isa(blade, tool).
located(blade, forge).
object(cloak).
isa(cloak, good).
located(cloak, market).

property(gold, valuable).
property(gold, heavy).
property(gold, inert).
property(map, readable).
property(map, fragile).
property(key, small).
property(key, metal).
property(lamp, portable).
property(lamp, lit).
property(rope, long).
property(rope, flexible).
property(book, readable).
property(book, fragile).
property(ore, heavy).
property(ore, raw).
property(herb, perishable).
property(herb, medicinal).
property(coin, valuable).
property(coin, small).
property(seal, official).
property(seal, unique).
property(compass, precise).
property(compass, portable).
property(shield, heavy).
property(shield, defensive).
property(potion, medicinal).
property(potion, liquid).
property(grain, bulk).
property(grain, edible).
property(stone, heavy).
property(stone, raw).
property(bell, loud).
property(bell, metal).
property(chart, readable).
property(chart, fragile).
property(ink, liquid).
property(ink, consumable).
property(blade, sharp).
property(blade, metal).
property(cloak, wearable).
property(cloak, flexible).

topic(gold).
topic(map).
topic(route).
topic(threat).
topic(trade).
topic(health).
topic(archive).
topic(weather).
topic(law).
topic(ritual).
topic(navigation).
topic(supply).
topic(maze).
topic(battery).
topic(stench).
topic(wumpus).

competent(guide, route).
believes(guide, topic(route)).
competent(guide, map).
believes(guide, topic(map)).
competent(guide, maze).
believes(guide, topic(maze)).
competent(guide, navigation).
believes(guide, topic(navigation)).
competent(guide, gold).
believes(guide, topic(gold)).
competent(visitor, gold).
believes(visitor, topic(gold)).
competent(visitor, trade).
believes(visitor, topic(trade)).
competent(scholar, archive).
believes(scholar, topic(archive)).
competent(scholar, law).
believes(scholar, topic(law)).
competent(scholar, map).
believes(scholar, topic(map)).
competent(scholar, ritual).
believes(scholar, topic(ritual)).
competent(merchant, trade).
believes(merchant, topic(trade)).
competent(merchant, supply).
believes(merchant, topic(supply)).
competent(merchant, gold).
believes(merchant, topic(gold)).
competent(merchant, coin).
believes(merchant, topic(coin)).
competent(guard, threat).
believes(guard, topic(threat)).
competent(guard, law).
believes(guard, topic(law)).
competent(guard, maze).
believes(guard, topic(maze)).
competent(guard, wumpus).
believes(guard, topic(wumpus)).
competent(archivist, archive).
believes(archivist, topic(archive)).
competent(archivist, seal).
believes(archivist, topic(seal)).
competent(archivist, book).
believes(archivist, topic(book)).
competent(pilot, navigation).
believes(pilot, topic(navigation)).
competent(pilot, route).
believes(pilot, topic(route)).
competent(pilot, weather).
believes(pilot, topic(weather)).
competent(pilot, dock).
believes(pilot, topic(dock)).
competent(medic, health).
believes(medic, topic(health)).
competent(medic, herb).
believes(medic, topic(herb)).
competent(medic, potion).
believes(medic, topic(potion)).
competent(ranger, threat).
believes(ranger, topic(threat)).
competent(ranger, wild).
believes(ranger, topic(wild)).
competent(ranger, stench).
believes(ranger, topic(stench)).
competent(ranger, wumpus).
believes(ranger, topic(wumpus)).
competent(ranger, maze).
believes(ranger, topic(maze)).
competent(broker, trade).
believes(broker, topic(trade)).
competent(broker, coin).
believes(broker, topic(coin)).
competent(broker, supply).
believes(broker, topic(supply)).
competent(broker, gold).
believes(broker, topic(gold)).

% World fluents the knowledgeable agents accept
world(located(gold, vault)).
world(isa(gold, good)).
world(located(map, library)).
world(isa(map, tool)).
world(located(key, guard)).
world(isa(key, tool)).
world(located(lamp, hall)).
world(isa(lamp, tool)).
world(located(rope, dock)).
world(isa(rope, tool)).
world(located(book, library)).
world(isa(book, good)).
world(located(ore, quarry)).
world(isa(ore, substance)).
world(located(herb, orchard)).
world(isa(herb, substance)).
world(located(coin, exchange)).
world(isa(coin, good)).
world(located(seal, archive)).
world(isa(seal, artifact)).
world(located(compass, observatory)).
world(isa(compass, tool)).
world(located(shield, barracks)).
world(isa(shield, tool)).
world(located(potion, clinic)).
world(isa(potion, substance)).
world(located(grain, market)).
world(isa(grain, good)).
world(located(stone, quarry)).
world(isa(stone, substance)).
world(located(bell, shrine)).
world(isa(bell, artifact)).
world(located(chart, dock)).
world(isa(chart, tool)).
world(located(ink, archive)).
world(isa(ink, substance)).
world(located(blade, forge)).
world(isa(blade, tool)).
world(located(cloak, market)).
world(isa(cloak, good)).
world(adjacent(gate, hall)).
world(adjacent(hall, library)).
world(adjacent(library, archive)).
world(adjacent(hall, market)).
world(adjacent(market, exchange)).
world(adjacent(hall, dock)).
world(adjacent(dock, river)).
world(adjacent(hall, clinic)).
world(adjacent(gate, north_road)).
world(adjacent(north_road, wild)).
world(adjacent(wild, maze)).
world(adjacent(hall, tower)).
world(adjacent(tower, observatory)).
world(adjacent(market, forge)).
world(adjacent(hall, garden)).
world(adjacent(garden, shrine)).
world(adjacent(hall, cellar)).
world(adjacent(cellar, vault)).
world(adjacent(gate, barracks)).
world(adjacent(market, orchard)).
world(adjacent(orchard, south_road)).
world(adjacent(dock, bridge)).
world(adjacent(bridge, east_yard)).
world(adjacent(forge, quarry)).
world(adjacent(barracks, west_yard)).

believes(A, F) :- competent(A, T), about(F, T), world(F).
about(located(O, _), T) :- topic(T), (O = T ; property(O, _), T = supply).
about(located(O, P), route) :- located(O, P).
about(adjacent(_, _), route).
about(adjacent(_, _), navigation).
about(isa(O, _), T) :- topic(T), O = T.
about(property(O, _), T) :- topic(T), O = T.

cg(agent(guide)). cg(agent(visitor)). cg(place(hall)). cg(topic(gold)).
cg(role(guide, guide)). cg(role(visitor, visitor)).

% ------------------------------------------------------------
% Speech acts
% ------------------------------------------------------------
speech_act(greet(S, H)) :- agent(S), agent(H), S \== H.
speech_act(ask(S, H, Q, Topic)) :- agent(S), agent(H), S \== H, question(Q), topic(Topic).
speech_act(tell(S, H, Fluent)) :- agent(S), agent(H), S \== H.
speech_act(confirm(S, H, Fluent)) :- agent(S), agent(H).
speech_act(deny(S, H, Fluent)) :- agent(S), agent(H).
speech_act(clarify(S, H, Topic)) :- agent(S), agent(H), topic(Topic).
speech_act(offer(S, H, Object)) :- agent(S), agent(H), object(Object).
speech_act(accept(S, H, Object)) :- agent(S), agent(H), object(Object).
speech_act(reject(S, H, Object)) :- agent(S), agent(H), object(Object).
speech_act(ack(S, H)) :- agent(S), agent(H).
speech_act(close(S, H)) :- agent(S), agent(H).

question(where). question(what). question(who). question(how). question(whether). question(why).

% A hearer can answer only on a topic they are competent in.
can_answer(H, Topic) :- competent(H, Topic).
can_answer(H, Topic) :- isa(Topic, object), located(Topic, _), competent(H, supply).

% Next legal reply. Deterministic preference: answer, else clarify, else deny competence.
reply(Hearer, Speaker, ask(_, _, Q, Topic), Act) :-
    can_answer(Hearer, Topic),
    answer_form(Q, Topic, Fluent),
    believes(Hearer, Fluent),
    Act = tell(Hearer, Speaker, Fluent), !.
reply(Hearer, Speaker, ask(_, _, _, Topic), clarify(Hearer, Speaker, Topic)) :-
    \+ can_answer(Hearer, Topic), !.
reply(Hearer, Speaker, ask(_, _, Q, Topic), deny(Hearer, Speaker, unknown(Q, Topic))).
reply(Hearer, Speaker, greet(_, _), greet(Hearer, Speaker)).
reply(Hearer, Speaker, tell(_, _, F), confirm(Hearer, Speaker, F)) :- believes(Hearer, F), !.
reply(Hearer, Speaker, tell(_, _, F), deny(Hearer, Speaker, F)) :- believes(Hearer, neg(F)), !.
reply(Hearer, Speaker, tell(_, _, F), ack(Hearer, Speaker)).
reply(Hearer, Speaker, offer(_, _, O), accept(Hearer, Speaker, O)) :-
    \+ believes(Hearer, prohibited(O)), !.
reply(Hearer, Speaker, offer(_, _, O), reject(Hearer, Speaker, O)).
reply(Hearer, Speaker, close(_, _), close(Hearer, Speaker)).
reply(Hearer, Speaker, _, ack(Hearer, Speaker)).

answer_form(where, Topic, located(Topic, _)) :- object(Topic), !.
answer_form(where, Topic, home(_, Topic)) :- place(Topic), !.
answer_form(where, route, adjacent(hall, _)).
answer_form(what, Topic, property(Topic, _)) :- object(Topic), !.
answer_form(what, Topic, isa(Topic, _)) :- topic(Topic), !.
answer_form(who, Topic, competent(_, Topic)).
answer_form(how, route, adjacent(_, _)).
answer_form(how, navigation, adjacent(_, _)).
answer_form(whether, Topic, located(Topic, _)) :- object(Topic), !.
answer_form(whether, Topic, topic(Topic)).
answer_form(why, gold, property(gold, valuable)).
answer_form(why, threat, topic(threat)).
answer_form(_, Topic, topic(Topic)).

% Concrete answer clauses used by tell/4 rendering
mention(located(O, P), ['the', O, 'is', 'at', P]) :- located(O, P).
mention(property(O, P), ['the', O, 'is', P]) :- property(O, P).
mention(adjacent(A, B), ['from', A, 'one', 'can', 'reach', B]) :- adjacent(A, B).
mention(competent(A, T), [A, 'can', 'speak', 'of', T]) :- competent(A, T).
mention(topic(T), [T, 'is', 'a', 'known', 'topic']).
mention(unknown(Q, T), ['no', 'answer', 'on', Q, T]).
mention(neg(F), ['not' | Rest]) :- mention(F, Rest).
mention(F, [F]).

% dialogue(InboundActs, Trace)  -- each inbound act gets one reply
dialogue([], []).
dialogue([Act|Acts], [Act, Reply|Trace]) :-
    participants(Act, Speaker, Hearer),
    reply(Hearer, Speaker, Act, Reply),
    dialogue(Acts, Trace).

participants(greet(S, H), S, H).
participants(ask(S, H, _, _), S, H).
participants(tell(S, H, _), S, H).
participants(confirm(S, H, _), S, H).
participants(deny(S, H, _), S, H).
participants(clarify(S, H, _), S, H).
participants(offer(S, H, _), S, H).
participants(accept(S, H, _), S, H).
participants(reject(S, H, _), S, H).
participants(ack(S, H), S, H).
participants(close(S, H), S, H).

adds_commitment(tell(S, H, F), committed(S, H, F)).
adds_commitment(offer(S, H, O), committed(S, H, transfer(O))).
adds_commitment(accept(S, H, O), committed(S, H, receive(O))).
adds_cg(tell(_, _, F), F).
adds_cg(confirm(_, _, F), F).
adds_cg(ack(_, _), heard).

ground_all([], CG, CG).
ground_all([Act|Acts], CG0, CG) :-
    ( adds_cg(Act, F) -> CG1 = [F|CG0] ; CG1 = CG0 ),
    ground_all(Acts, CG1, CG).

% Optional bridge to alp_kernel.pl program terms
agent_proc(open_dialog,
    seq(prim(greet_visitor), sense(hear_question))).
agent_proc(answer_gold,
    seq(prim(tell_gold_place), prim(close_dialog))).

primitive_action(greet_visitor).
primitive_action(hear_question).
primitive_action(tell_gold_place).
primitive_action(close_dialog).
impossible(close_dialog, S) :- \+ member(topic=gold, S).
effects(greet_visitor, _, [phase=greeted]).
effects(hear_question, _, [topic=gold, phase=asked]).
effects(tell_gold_place, _, [phase=answered, gold_at=vault]).
effects(close_dialog, _, [phase=closed]).
senses(greet_visitor, []).
senses(hear_question, [topic]).
senses(tell_gold_place, []).
senses(close_dialog, []).

% ------------------------------------------------------------
% Licensed tell-fluents and question catalogue
% ------------------------------------------------------------
catalog(ask(visitor, guide, where, route)).
catalog(ask(visitor, guide, what, route)).
catalog(ask(visitor, guide, who, route)).
catalog(ask(visitor, guide, how, route)).
catalog(ask(visitor, guide, whether, route)).
catalog(ask(visitor, guide, why, route)).
catalog(clarify(guide, visitor, route)).
catalog(ask(visitor, guide, where, map)).
catalog(ask(visitor, guide, what, map)).
catalog(ask(visitor, guide, who, map)).
catalog(ask(visitor, guide, how, map)).
catalog(ask(visitor, guide, whether, map)).
catalog(ask(visitor, guide, why, map)).
catalog(clarify(guide, visitor, map)).
catalog(ask(visitor, guide, where, maze)).
catalog(ask(visitor, guide, what, maze)).
catalog(ask(visitor, guide, who, maze)).
catalog(ask(visitor, guide, how, maze)).
catalog(ask(visitor, guide, whether, maze)).
catalog(ask(visitor, guide, why, maze)).
catalog(clarify(guide, visitor, maze)).
catalog(ask(visitor, guide, where, navigation)).
catalog(ask(visitor, guide, what, navigation)).
catalog(ask(visitor, guide, who, navigation)).
catalog(ask(visitor, guide, how, navigation)).
catalog(ask(visitor, guide, whether, navigation)).
catalog(ask(visitor, guide, why, navigation)).
catalog(clarify(guide, visitor, navigation)).
catalog(ask(visitor, guide, where, gold)).
catalog(ask(visitor, guide, what, gold)).
catalog(ask(visitor, guide, who, gold)).
catalog(ask(visitor, guide, how, gold)).
catalog(ask(visitor, guide, whether, gold)).
catalog(ask(visitor, guide, why, gold)).
catalog(clarify(guide, visitor, gold)).
catalog(ask(visitor, visitor, where, gold)).
catalog(ask(visitor, visitor, what, gold)).
catalog(ask(visitor, visitor, who, gold)).
catalog(ask(visitor, visitor, how, gold)).
catalog(ask(visitor, visitor, whether, gold)).
catalog(ask(visitor, visitor, why, gold)).
catalog(clarify(visitor, visitor, gold)).
catalog(ask(visitor, visitor, where, trade)).
catalog(ask(visitor, visitor, what, trade)).
catalog(ask(visitor, visitor, who, trade)).
catalog(ask(visitor, visitor, how, trade)).
catalog(ask(visitor, visitor, whether, trade)).
catalog(ask(visitor, visitor, why, trade)).
catalog(clarify(visitor, visitor, trade)).
catalog(ask(visitor, scholar, where, archive)).
catalog(ask(visitor, scholar, what, archive)).
catalog(ask(visitor, scholar, who, archive)).
catalog(ask(visitor, scholar, how, archive)).
catalog(ask(visitor, scholar, whether, archive)).
catalog(ask(visitor, scholar, why, archive)).
catalog(clarify(scholar, visitor, archive)).
catalog(ask(visitor, scholar, where, law)).
catalog(ask(visitor, scholar, what, law)).
catalog(ask(visitor, scholar, who, law)).
catalog(ask(visitor, scholar, how, law)).
catalog(ask(visitor, scholar, whether, law)).
catalog(ask(visitor, scholar, why, law)).
catalog(clarify(scholar, visitor, law)).
catalog(ask(visitor, scholar, where, map)).
catalog(ask(visitor, scholar, what, map)).
catalog(ask(visitor, scholar, who, map)).
catalog(ask(visitor, scholar, how, map)).
catalog(ask(visitor, scholar, whether, map)).
catalog(ask(visitor, scholar, why, map)).
catalog(clarify(scholar, visitor, map)).
catalog(ask(visitor, scholar, where, ritual)).
catalog(ask(visitor, scholar, what, ritual)).
catalog(ask(visitor, scholar, who, ritual)).
catalog(ask(visitor, scholar, how, ritual)).
catalog(ask(visitor, scholar, whether, ritual)).
catalog(ask(visitor, scholar, why, ritual)).
catalog(clarify(scholar, visitor, ritual)).
catalog(ask(visitor, merchant, where, trade)).
catalog(ask(visitor, merchant, what, trade)).
catalog(ask(visitor, merchant, who, trade)).
catalog(ask(visitor, merchant, how, trade)).
catalog(ask(visitor, merchant, whether, trade)).
catalog(ask(visitor, merchant, why, trade)).
catalog(clarify(merchant, visitor, trade)).
catalog(ask(visitor, merchant, where, supply)).
catalog(ask(visitor, merchant, what, supply)).
catalog(ask(visitor, merchant, who, supply)).
catalog(ask(visitor, merchant, how, supply)).
catalog(ask(visitor, merchant, whether, supply)).
catalog(ask(visitor, merchant, why, supply)).
catalog(clarify(merchant, visitor, supply)).
catalog(ask(visitor, merchant, where, gold)).
catalog(ask(visitor, merchant, what, gold)).
catalog(ask(visitor, merchant, who, gold)).
catalog(ask(visitor, merchant, how, gold)).
catalog(ask(visitor, merchant, whether, gold)).
catalog(ask(visitor, merchant, why, gold)).
catalog(clarify(merchant, visitor, gold)).
catalog(ask(visitor, merchant, where, coin)).
catalog(ask(visitor, merchant, what, coin)).
catalog(ask(visitor, merchant, who, coin)).
catalog(ask(visitor, merchant, how, coin)).
catalog(ask(visitor, merchant, whether, coin)).
catalog(ask(visitor, merchant, why, coin)).
catalog(clarify(merchant, visitor, coin)).
catalog(ask(visitor, guard, where, threat)).
catalog(ask(visitor, guard, what, threat)).
catalog(ask(visitor, guard, who, threat)).
catalog(ask(visitor, guard, how, threat)).
catalog(ask(visitor, guard, whether, threat)).
catalog(ask(visitor, guard, why, threat)).
catalog(clarify(guard, visitor, threat)).
catalog(ask(visitor, guard, where, law)).
catalog(ask(visitor, guard, what, law)).
catalog(ask(visitor, guard, who, law)).
catalog(ask(visitor, guard, how, law)).
catalog(ask(visitor, guard, whether, law)).
catalog(ask(visitor, guard, why, law)).
catalog(clarify(guard, visitor, law)).
catalog(ask(visitor, guard, where, maze)).
catalog(ask(visitor, guard, what, maze)).
catalog(ask(visitor, guard, who, maze)).
catalog(ask(visitor, guard, how, maze)).
catalog(ask(visitor, guard, whether, maze)).
catalog(ask(visitor, guard, why, maze)).
catalog(clarify(guard, visitor, maze)).
catalog(ask(visitor, guard, where, wumpus)).
catalog(ask(visitor, guard, what, wumpus)).
catalog(ask(visitor, guard, who, wumpus)).
catalog(ask(visitor, guard, how, wumpus)).
catalog(ask(visitor, guard, whether, wumpus)).
catalog(ask(visitor, guard, why, wumpus)).
catalog(clarify(guard, visitor, wumpus)).
catalog(ask(visitor, archivist, where, archive)).
catalog(ask(visitor, archivist, what, archive)).
catalog(ask(visitor, archivist, who, archive)).
catalog(ask(visitor, archivist, how, archive)).
catalog(ask(visitor, archivist, whether, archive)).
catalog(ask(visitor, archivist, why, archive)).
catalog(clarify(archivist, visitor, archive)).
catalog(ask(visitor, archivist, where, seal)).
catalog(ask(visitor, archivist, what, seal)).
catalog(ask(visitor, archivist, who, seal)).
catalog(ask(visitor, archivist, how, seal)).
catalog(ask(visitor, archivist, whether, seal)).
catalog(ask(visitor, archivist, why, seal)).
catalog(clarify(archivist, visitor, seal)).
catalog(ask(visitor, archivist, where, book)).
catalog(ask(visitor, archivist, what, book)).
catalog(ask(visitor, archivist, who, book)).
catalog(ask(visitor, archivist, how, book)).
catalog(ask(visitor, archivist, whether, book)).
catalog(ask(visitor, archivist, why, book)).
catalog(clarify(archivist, visitor, book)).
catalog(ask(visitor, pilot, where, navigation)).
catalog(ask(visitor, pilot, what, navigation)).
catalog(ask(visitor, pilot, who, navigation)).
catalog(ask(visitor, pilot, how, navigation)).
catalog(ask(visitor, pilot, whether, navigation)).
catalog(ask(visitor, pilot, why, navigation)).
catalog(clarify(pilot, visitor, navigation)).
catalog(ask(visitor, pilot, where, route)).
catalog(ask(visitor, pilot, what, route)).
catalog(ask(visitor, pilot, who, route)).
catalog(ask(visitor, pilot, how, route)).
catalog(ask(visitor, pilot, whether, route)).
catalog(ask(visitor, pilot, why, route)).
catalog(clarify(pilot, visitor, route)).
catalog(ask(visitor, pilot, where, weather)).
catalog(ask(visitor, pilot, what, weather)).
catalog(ask(visitor, pilot, who, weather)).
catalog(ask(visitor, pilot, how, weather)).
catalog(ask(visitor, pilot, whether, weather)).
catalog(ask(visitor, pilot, why, weather)).
catalog(clarify(pilot, visitor, weather)).
catalog(ask(visitor, pilot, where, dock)).
catalog(ask(visitor, pilot, what, dock)).
catalog(ask(visitor, pilot, who, dock)).
catalog(ask(visitor, pilot, how, dock)).
catalog(ask(visitor, pilot, whether, dock)).
catalog(ask(visitor, pilot, why, dock)).
catalog(clarify(pilot, visitor, dock)).
catalog(ask(visitor, medic, where, health)).
catalog(ask(visitor, medic, what, health)).
catalog(ask(visitor, medic, who, health)).
catalog(ask(visitor, medic, how, health)).
catalog(ask(visitor, medic, whether, health)).
catalog(ask(visitor, medic, why, health)).
catalog(clarify(medic, visitor, health)).
catalog(ask(visitor, medic, where, herb)).
catalog(ask(visitor, medic, what, herb)).
catalog(ask(visitor, medic, who, herb)).
catalog(ask(visitor, medic, how, herb)).
catalog(ask(visitor, medic, whether, herb)).
catalog(ask(visitor, medic, why, herb)).
catalog(clarify(medic, visitor, herb)).
catalog(ask(visitor, medic, where, potion)).
catalog(ask(visitor, medic, what, potion)).
catalog(ask(visitor, medic, who, potion)).
catalog(ask(visitor, medic, how, potion)).
catalog(ask(visitor, medic, whether, potion)).
catalog(ask(visitor, medic, why, potion)).
catalog(clarify(medic, visitor, potion)).
catalog(ask(visitor, ranger, where, threat)).
catalog(ask(visitor, ranger, what, threat)).
catalog(ask(visitor, ranger, who, threat)).
catalog(ask(visitor, ranger, how, threat)).
catalog(ask(visitor, ranger, whether, threat)).
catalog(ask(visitor, ranger, why, threat)).
catalog(clarify(ranger, visitor, threat)).
catalog(ask(visitor, ranger, where, wild)).
catalog(ask(visitor, ranger, what, wild)).
catalog(ask(visitor, ranger, who, wild)).
catalog(ask(visitor, ranger, how, wild)).
catalog(ask(visitor, ranger, whether, wild)).
catalog(ask(visitor, ranger, why, wild)).
catalog(clarify(ranger, visitor, wild)).
catalog(ask(visitor, ranger, where, stench)).
catalog(ask(visitor, ranger, what, stench)).
catalog(ask(visitor, ranger, who, stench)).
catalog(ask(visitor, ranger, how, stench)).
catalog(ask(visitor, ranger, whether, stench)).
catalog(ask(visitor, ranger, why, stench)).
catalog(clarify(ranger, visitor, stench)).
catalog(ask(visitor, ranger, where, wumpus)).
catalog(ask(visitor, ranger, what, wumpus)).
catalog(ask(visitor, ranger, who, wumpus)).
catalog(ask(visitor, ranger, how, wumpus)).
catalog(ask(visitor, ranger, whether, wumpus)).
catalog(ask(visitor, ranger, why, wumpus)).
catalog(clarify(ranger, visitor, wumpus)).
catalog(ask(visitor, ranger, where, maze)).
catalog(ask(visitor, ranger, what, maze)).
catalog(ask(visitor, ranger, who, maze)).
catalog(ask(visitor, ranger, how, maze)).
catalog(ask(visitor, ranger, whether, maze)).
catalog(ask(visitor, ranger, why, maze)).
catalog(clarify(ranger, visitor, maze)).
catalog(ask(visitor, broker, where, trade)).
catalog(ask(visitor, broker, what, trade)).
catalog(ask(visitor, broker, who, trade)).
catalog(ask(visitor, broker, how, trade)).
catalog(ask(visitor, broker, whether, trade)).
catalog(ask(visitor, broker, why, trade)).
catalog(clarify(broker, visitor, trade)).
catalog(ask(visitor, broker, where, coin)).
catalog(ask(visitor, broker, what, coin)).
catalog(ask(visitor, broker, who, coin)).
catalog(ask(visitor, broker, how, coin)).
catalog(ask(visitor, broker, whether, coin)).
catalog(ask(visitor, broker, why, coin)).
catalog(clarify(broker, visitor, coin)).
catalog(ask(visitor, broker, where, supply)).
catalog(ask(visitor, broker, what, supply)).
catalog(ask(visitor, broker, who, supply)).
catalog(ask(visitor, broker, how, supply)).
catalog(ask(visitor, broker, whether, supply)).
catalog(ask(visitor, broker, why, supply)).
catalog(clarify(broker, visitor, supply)).
catalog(ask(visitor, broker, where, gold)).
catalog(ask(visitor, broker, what, gold)).
catalog(ask(visitor, broker, who, gold)).
catalog(ask(visitor, broker, how, gold)).
catalog(ask(visitor, broker, whether, gold)).
catalog(ask(visitor, broker, why, gold)).
catalog(clarify(broker, visitor, gold)).
catalog(tell(guide, visitor, located(gold, vault))).
catalog(offer(merchant, visitor, gold)).
catalog(ask(visitor, merchant, whether, gold)).
catalog(tell(guide, visitor, located(map, library))).
catalog(offer(merchant, visitor, map)).
catalog(ask(visitor, merchant, whether, map)).
catalog(tell(guide, visitor, located(key, guard))).
catalog(offer(merchant, visitor, key)).
catalog(ask(visitor, merchant, whether, key)).
catalog(tell(guide, visitor, located(lamp, hall))).
catalog(offer(merchant, visitor, lamp)).
catalog(ask(visitor, merchant, whether, lamp)).
catalog(tell(guide, visitor, located(rope, dock))).
catalog(offer(merchant, visitor, rope)).
catalog(ask(visitor, merchant, whether, rope)).
catalog(tell(guide, visitor, located(book, library))).
catalog(offer(merchant, visitor, book)).
catalog(ask(visitor, merchant, whether, book)).
catalog(tell(guide, visitor, located(ore, quarry))).
catalog(offer(merchant, visitor, ore)).
catalog(ask(visitor, merchant, whether, ore)).
catalog(tell(guide, visitor, located(herb, orchard))).
catalog(offer(merchant, visitor, herb)).
catalog(ask(visitor, merchant, whether, herb)).
catalog(tell(guide, visitor, located(coin, exchange))).
catalog(offer(merchant, visitor, coin)).
catalog(ask(visitor, merchant, whether, coin)).
catalog(tell(guide, visitor, located(seal, archive))).
catalog(offer(merchant, visitor, seal)).
catalog(ask(visitor, merchant, whether, seal)).
catalog(tell(guide, visitor, located(compass, observatory))).
catalog(offer(merchant, visitor, compass)).
catalog(ask(visitor, merchant, whether, compass)).
catalog(tell(guide, visitor, located(shield, barracks))).
catalog(offer(merchant, visitor, shield)).
catalog(ask(visitor, merchant, whether, shield)).
catalog(tell(guide, visitor, located(potion, clinic))).
catalog(offer(merchant, visitor, potion)).
catalog(ask(visitor, merchant, whether, potion)).
catalog(tell(guide, visitor, located(grain, market))).
catalog(offer(merchant, visitor, grain)).
catalog(ask(visitor, merchant, whether, grain)).
catalog(tell(guide, visitor, located(stone, quarry))).
catalog(offer(merchant, visitor, stone)).
catalog(ask(visitor, merchant, whether, stone)).
catalog(tell(guide, visitor, located(bell, shrine))).
catalog(offer(merchant, visitor, bell)).
catalog(ask(visitor, merchant, whether, bell)).
catalog(tell(guide, visitor, located(chart, dock))).
catalog(offer(merchant, visitor, chart)).
catalog(ask(visitor, merchant, whether, chart)).
catalog(tell(guide, visitor, located(ink, archive))).
catalog(offer(merchant, visitor, ink)).
catalog(ask(visitor, merchant, whether, ink)).
catalog(tell(guide, visitor, located(blade, forge))).
catalog(offer(merchant, visitor, blade)).
catalog(ask(visitor, merchant, whether, blade)).
catalog(tell(guide, visitor, located(cloak, market))).
catalog(offer(merchant, visitor, cloak)).
catalog(ask(visitor, merchant, whether, cloak)).
catalog(tell(guide, visitor, adjacent(gate, hall))).
catalog(tell(guide, visitor, adjacent(hall, library))).
catalog(tell(guide, visitor, adjacent(library, archive))).
catalog(tell(guide, visitor, adjacent(hall, market))).
catalog(tell(guide, visitor, adjacent(market, exchange))).
catalog(tell(guide, visitor, adjacent(hall, dock))).
catalog(tell(guide, visitor, adjacent(dock, river))).
catalog(tell(guide, visitor, adjacent(hall, clinic))).
catalog(tell(guide, visitor, adjacent(gate, north_road))).
catalog(tell(guide, visitor, adjacent(north_road, wild))).
catalog(tell(guide, visitor, adjacent(wild, maze))).
catalog(tell(guide, visitor, adjacent(hall, tower))).
catalog(tell(guide, visitor, adjacent(tower, observatory))).
catalog(tell(guide, visitor, adjacent(market, forge))).
catalog(tell(guide, visitor, adjacent(hall, garden))).
catalog(tell(guide, visitor, adjacent(garden, shrine))).
catalog(tell(guide, visitor, adjacent(hall, cellar))).
catalog(tell(guide, visitor, adjacent(cellar, vault))).
catalog(tell(guide, visitor, adjacent(gate, barracks))).
catalog(tell(guide, visitor, adjacent(market, orchard))).
catalog(tell(guide, visitor, adjacent(orchard, south_road))).
catalog(tell(guide, visitor, adjacent(dock, bridge))).
catalog(tell(guide, visitor, adjacent(bridge, east_yard))).
catalog(tell(guide, visitor, adjacent(forge, quarry))).
catalog(tell(guide, visitor, adjacent(barracks, west_yard))).
catalog(tell(guide, visitor, home(guide, hall))).
catalog(greet(visitor, guide)).
catalog(tell(guide, visitor, home(visitor, gate))).
catalog(greet(visitor, visitor)).
catalog(tell(guide, visitor, home(scholar, library))).
catalog(greet(visitor, scholar)).
catalog(tell(guide, visitor, home(merchant, market))).
catalog(greet(visitor, merchant)).
catalog(tell(guide, visitor, home(guard, gate))).
catalog(greet(visitor, guard)).
catalog(tell(guide, visitor, home(archivist, archive))).
catalog(greet(visitor, archivist)).
catalog(tell(guide, visitor, home(pilot, dock))).
catalog(greet(visitor, pilot)).
catalog(tell(guide, visitor, home(medic, clinic))).
catalog(greet(visitor, medic)).
catalog(tell(guide, visitor, home(ranger, wild))).
catalog(greet(visitor, ranger)).
catalog(tell(guide, visitor, home(broker, exchange))).
catalog(greet(visitor, broker)).

% Sample script the agents can run
sample_script([
    greet(visitor, guide),
    ask(visitor, guide, where, gold),
    ask(visitor, guide, how, route),
    ask(visitor, guard, whether, threat),
    offer(merchant, visitor, cloak),
    close(visitor, guide)
]).

% catalogue size marker
catalogue_entries(371).

% ------------------------------------------------------------
% Expanded dialogue world: agents, lexicon, scripts, commitments
% ------------------------------------------------------------

named_agent(ada_north).
role(ada_north, guide).
home(ada_north, hall_north).
manner(ada_north, formal).
isa(ada_north, guide).
named_agent(ada_south).
role(ada_south, guide).
home(ada_south, hall_south).
manner(ada_south, formal).
isa(ada_south, guide).
named_agent(ada_east).
role(ada_east, guide).
home(ada_east, hall_east).
manner(ada_east, formal).
isa(ada_east, guide).
named_agent(bas_north).
role(bas_north, visitor).
home(bas_north, gate_north).
manner(bas_north, plain).
isa(bas_north, visitor).
named_agent(bas_south).
role(bas_south, visitor).
home(bas_south, gate_south).
manner(bas_south, plain).
isa(bas_south, visitor).
named_agent(bas_east).
role(bas_east, visitor).
home(bas_east, gate_east).
manner(bas_east, plain).
isa(bas_east, visitor).
named_agent(cor_north).
role(cor_north, scholar).
home(cor_north, market_north).
manner(cor_north, brief).
isa(cor_north, scholar).
named_agent(cor_south).
role(cor_south, scholar).
home(cor_south, market_south).
manner(cor_south, brief).
isa(cor_south, scholar).
named_agent(cor_east).
role(cor_east, scholar).
home(cor_east, market_east).
manner(cor_east, brief).
isa(cor_east, scholar).
named_agent(dax_north).
role(dax_north, merchant).
home(dax_north, dock_north).
manner(dax_north, cautious).
isa(dax_north, merchant).
named_agent(dax_south).
role(dax_south, merchant).
home(dax_south, dock_south).
manner(dax_south, cautious).
isa(dax_south, merchant).
named_agent(dax_east).
role(dax_east, merchant).
home(dax_east, dock_east).
manner(dax_east, cautious).
isa(dax_east, merchant).
named_agent(eli_north).
role(eli_north, guard).
home(eli_north, archive_north).
manner(eli_north, urgent).
isa(eli_north, guard).
named_agent(eli_south).
role(eli_south, guard).
home(eli_south, archive_south).
manner(eli_south, urgent).
isa(eli_south, guard).
named_agent(eli_east).
role(eli_east, guard).
home(eli_east, archive_east).
manner(eli_east, urgent).
isa(eli_east, guard).
named_agent(fay_north).
role(fay_north, pilot).
home(fay_north, clinic_north).
manner(fay_north, formal).
isa(fay_north, pilot).
named_agent(fay_south).
role(fay_south, pilot).
home(fay_south, clinic_south).
manner(fay_south, formal).
isa(fay_south, pilot).
named_agent(fay_east).
role(fay_east, pilot).
home(fay_east, clinic_east).
manner(fay_east, formal).
isa(fay_east, pilot).
named_agent(gio_north).
role(gio_north, medic).
home(gio_north, tower_north).
manner(gio_north, plain).
isa(gio_north, medic).
named_agent(gio_south).
role(gio_south, medic).
home(gio_south, tower_south).
manner(gio_south, plain).
isa(gio_south, medic).
named_agent(gio_east).
role(gio_east, medic).
home(gio_east, tower_east).
manner(gio_east, plain).
isa(gio_east, medic).
named_agent(hal_north).
role(hal_north, ranger).
home(hal_north, yard_north).
manner(hal_north, brief).
isa(hal_north, ranger).
named_agent(hal_south).
role(hal_south, ranger).
home(hal_south, yard_south).
manner(hal_south, brief).
isa(hal_south, ranger).
named_agent(hal_east).
role(hal_east, ranger).
home(hal_east, yard_east).
manner(hal_east, brief).
isa(hal_east, ranger).
named_agent(ira_north).
role(ira_north, broker).
home(ira_north, road_north).
manner(ira_north, cautious).
isa(ira_north, broker).
named_agent(ira_south).
role(ira_south, broker).
home(ira_south, road_south).
manner(ira_south, cautious).
isa(ira_south, broker).
named_agent(ira_east).
role(ira_east, broker).
home(ira_east, road_east).
manner(ira_east, cautious).
isa(ira_east, broker).
named_agent(joss_north).
role(joss_north, archivist).
home(joss_north, bridge_north).
manner(joss_north, urgent).
isa(joss_north, archivist).
named_agent(joss_south).
role(joss_south, archivist).
home(joss_south, bridge_south).
manner(joss_south, urgent).
isa(joss_south, archivist).
named_agent(joss_east).
role(joss_east, archivist).
home(joss_east, bridge_east).
manner(joss_east, urgent).
isa(joss_east, archivist).
named_agent(kai_north).
role(kai_north, guide).
home(kai_north, vault_north).
manner(kai_north, formal).
isa(kai_north, guide).
named_agent(kai_south).
role(kai_south, guide).
home(kai_south, vault_south).
manner(kai_south, formal).
isa(kai_south, guide).
named_agent(kai_east).
role(kai_east, guide).
home(kai_east, vault_east).
manner(kai_east, formal).
isa(kai_east, guide).
named_agent(lea_north).
role(lea_north, visitor).
home(lea_north, maze_north).
manner(lea_north, plain).
isa(lea_north, visitor).
named_agent(lea_south).
role(lea_south, visitor).
home(lea_south, maze_south).
manner(lea_south, plain).
isa(lea_south, visitor).
named_agent(lea_east).
role(lea_east, visitor).
home(lea_east, maze_east).
manner(lea_east, plain).
isa(lea_east, visitor).
named_agent(mio_north).
role(mio_north, scholar).
home(mio_north, hall_north).
manner(mio_north, brief).
isa(mio_north, scholar).
named_agent(mio_south).
role(mio_south, scholar).
home(mio_south, hall_south).
manner(mio_south, brief).
isa(mio_south, scholar).
named_agent(mio_east).
role(mio_east, scholar).
home(mio_east, hall_east).
manner(mio_east, brief).
isa(mio_east, scholar).
named_agent(ned_north).
role(ned_north, merchant).
home(ned_north, gate_north).
manner(ned_north, cautious).
isa(ned_north, merchant).
named_agent(ned_south).
role(ned_south, merchant).
home(ned_south, gate_south).
manner(ned_south, cautious).
isa(ned_south, merchant).
named_agent(ned_east).
role(ned_east, merchant).
home(ned_east, gate_east).
manner(ned_east, cautious).
isa(ned_east, merchant).
named_agent(ora_north).
role(ora_north, guard).
home(ora_north, market_north).
manner(ora_north, urgent).
isa(ora_north, guard).
named_agent(ora_south).
role(ora_south, guard).
home(ora_south, market_south).
manner(ora_south, urgent).
isa(ora_south, guard).
named_agent(ora_east).
role(ora_east, guard).
home(ora_east, market_east).
manner(ora_east, urgent).
isa(ora_east, guard).
named_agent(pim_north).
role(pim_north, pilot).
home(pim_north, dock_north).
manner(pim_north, formal).
isa(pim_north, pilot).
named_agent(pim_south).
role(pim_south, pilot).
home(pim_south, dock_south).
manner(pim_south, formal).
isa(pim_south, pilot).
named_agent(pim_east).
role(pim_east, pilot).
home(pim_east, dock_east).
manner(pim_east, formal).
isa(pim_east, pilot).
named_agent(quin_north).
role(quin_north, medic).
home(quin_north, archive_north).
manner(quin_north, plain).
isa(quin_north, medic).
named_agent(quin_south).
role(quin_south, medic).
home(quin_south, archive_south).
manner(quin_south, plain).
isa(quin_south, medic).
named_agent(quin_east).
role(quin_east, medic).
home(quin_east, archive_east).
manner(quin_east, plain).
isa(quin_east, medic).
named_agent(rae_north).
role(rae_north, ranger).
home(rae_north, clinic_north).
manner(rae_north, brief).
isa(rae_north, ranger).
named_agent(rae_south).
role(rae_south, ranger).
home(rae_south, clinic_south).
manner(rae_south, brief).
isa(rae_south, ranger).
named_agent(rae_east).
role(rae_east, ranger).
home(rae_east, clinic_east).
manner(rae_east, brief).
isa(rae_east, ranger).
named_agent(sol_north).
role(sol_north, broker).
home(sol_north, tower_north).
manner(sol_north, cautious).
isa(sol_north, broker).
named_agent(sol_south).
role(sol_south, broker).
home(sol_south, tower_south).
manner(sol_south, cautious).
isa(sol_south, broker).
named_agent(sol_east).
role(sol_east, broker).
home(sol_east, tower_east).
manner(sol_east, cautious).
isa(sol_east, broker).
named_agent(tia_north).
role(tia_north, archivist).
home(tia_north, yard_north).
manner(tia_north, urgent).
isa(tia_north, archivist).
named_agent(tia_south).
role(tia_south, archivist).
home(tia_south, yard_south).
manner(tia_south, urgent).
isa(tia_south, archivist).
named_agent(tia_east).
role(tia_east, archivist).
home(tia_east, yard_east).
manner(tia_east, urgent).
isa(tia_east, archivist).
named_agent(uma_north).
role(uma_north, guide).
home(uma_north, road_north).
manner(uma_north, formal).
isa(uma_north, guide).
named_agent(uma_south).
role(uma_south, guide).
home(uma_south, road_south).
manner(uma_south, formal).
isa(uma_south, guide).
named_agent(uma_east).
role(uma_east, guide).
home(uma_east, road_east).
manner(uma_east, formal).
isa(uma_east, guide).
named_agent(vic_north).
role(vic_north, visitor).
home(vic_north, bridge_north).
manner(vic_north, plain).
isa(vic_north, visitor).
named_agent(vic_south).
role(vic_south, visitor).
home(vic_south, bridge_south).
manner(vic_south, plain).
isa(vic_south, visitor).
named_agent(vic_east).
role(vic_east, visitor).
home(vic_east, bridge_east).
manner(vic_east, plain).
isa(vic_east, visitor).
named_agent(wren_north).
role(wren_north, scholar).
home(wren_north, vault_north).
manner(wren_north, brief).
isa(wren_north, scholar).
named_agent(wren_south).
role(wren_south, scholar).
home(wren_south, vault_south).
manner(wren_south, brief).
isa(wren_south, scholar).
named_agent(wren_east).
role(wren_east, scholar).
home(wren_east, vault_east).
manner(wren_east, brief).
isa(wren_east, scholar).
named_agent(xan_north).
role(xan_north, merchant).
home(xan_north, maze_north).
manner(xan_north, cautious).
isa(xan_north, merchant).
named_agent(xan_south).
role(xan_south, merchant).
home(xan_south, maze_south).
manner(xan_south, cautious).
isa(xan_south, merchant).
named_agent(xan_east).
role(xan_east, merchant).
home(xan_east, maze_east).
manner(xan_east, cautious).
isa(xan_east, merchant).
named_agent(yve_north).
role(yve_north, guard).
home(yve_north, hall_north).
manner(yve_north, urgent).
isa(yve_north, guard).
named_agent(yve_south).
role(yve_south, guard).
home(yve_south, hall_south).
manner(yve_south, urgent).
isa(yve_south, guard).
named_agent(yve_east).
role(yve_east, guard).
home(yve_east, hall_east).
manner(yve_east, urgent).
isa(yve_east, guard).
named_agent(zek_north).
role(zek_north, pilot).
home(zek_north, gate_north).
manner(zek_north, formal).
isa(zek_north, pilot).
named_agent(zek_south).
role(zek_south, pilot).
home(zek_south, gate_south).
manner(zek_south, formal).
isa(zek_south, pilot).
named_agent(zek_east).
role(zek_east, pilot).
home(zek_east, gate_east).
manner(zek_east, formal).
isa(zek_east, pilot).

place(archive_east).
place(archive_north).
place(archive_south).
place(bridge_east).
place(bridge_north).
place(bridge_south).
place(clinic_east).
place(clinic_north).
place(clinic_south).
place(dock_east).
place(dock_north).
place(dock_south).
place(gate_east).
place(gate_north).
place(gate_south).
place(hall_east).
place(hall_north).
place(hall_south).
place(market_east).
place(market_north).
place(market_south).
place(maze_east).
place(maze_north).
place(maze_south).
place(road_east).
place(road_north).
place(road_south).
place(tower_east).
place(tower_north).
place(tower_south).
place(vault_east).
place(vault_north).
place(vault_south).
place(yard_east).
place(yard_north).
place(yard_south).
adjacent(hall_north, gate_north).
adjacent(gate_north, hall_north).
adjacent(gate_north, market_north).
adjacent(market_north, gate_north).
adjacent(market_north, dock_north).
adjacent(dock_north, market_north).
adjacent(dock_north, archive_north).
adjacent(archive_north, dock_north).
adjacent(archive_north, clinic_north).
adjacent(clinic_north, archive_north).
adjacent(clinic_north, tower_north).
adjacent(tower_north, clinic_north).
adjacent(tower_north, yard_north).
adjacent(yard_north, tower_north).
adjacent(yard_north, road_north).
adjacent(road_north, yard_north).
adjacent(road_north, bridge_north).
adjacent(bridge_north, road_north).
adjacent(bridge_north, vault_north).
adjacent(vault_north, bridge_north).
adjacent(vault_north, maze_north).
adjacent(maze_north, vault_north).
adjacent(hall_south, gate_south).
adjacent(gate_south, hall_south).
adjacent(gate_south, market_south).
adjacent(market_south, gate_south).
adjacent(market_south, dock_south).
adjacent(dock_south, market_south).
adjacent(dock_south, archive_south).
adjacent(archive_south, dock_south).
adjacent(archive_south, clinic_south).
adjacent(clinic_south, archive_south).
adjacent(clinic_south, tower_south).
adjacent(tower_south, clinic_south).
adjacent(tower_south, yard_south).
adjacent(yard_south, tower_south).
adjacent(yard_south, road_south).
adjacent(road_south, yard_south).
adjacent(road_south, bridge_south).
adjacent(bridge_south, road_south).
adjacent(bridge_south, vault_south).
adjacent(vault_south, bridge_south).
adjacent(vault_south, maze_south).
adjacent(maze_south, vault_south).
adjacent(hall_east, gate_east).
adjacent(gate_east, hall_east).
adjacent(gate_east, market_east).
adjacent(market_east, gate_east).
adjacent(market_east, dock_east).
adjacent(dock_east, market_east).
adjacent(dock_east, archive_east).
adjacent(archive_east, dock_east).
adjacent(archive_east, clinic_east).
adjacent(clinic_east, archive_east).
adjacent(clinic_east, tower_east).
adjacent(tower_east, clinic_east).
adjacent(tower_east, yard_east).
adjacent(yard_east, tower_east).
adjacent(yard_east, road_east).
adjacent(road_east, yard_east).
adjacent(road_east, bridge_east).
adjacent(bridge_east, road_east).
adjacent(bridge_east, vault_east).
adjacent(vault_east, bridge_east).
adjacent(vault_east, maze_east).
adjacent(maze_east, vault_east).
adjacent(hall_west, gate_west).
adjacent(gate_west, hall_west).
adjacent(gate_west, market_west).
adjacent(market_west, gate_west).
adjacent(market_west, dock_west).
adjacent(dock_west, market_west).
adjacent(dock_west, archive_west).
adjacent(archive_west, dock_west).
adjacent(archive_west, clinic_west).
adjacent(clinic_west, archive_west).
adjacent(clinic_west, tower_west).
adjacent(tower_west, clinic_west).
adjacent(tower_west, yard_west).
adjacent(yard_west, tower_west).
adjacent(yard_west, road_west).
adjacent(road_west, yard_west).
adjacent(road_west, bridge_west).
adjacent(bridge_west, road_west).
adjacent(bridge_west, vault_west).
adjacent(vault_west, bridge_west).
adjacent(vault_west, maze_west).
adjacent(maze_west, vault_west).
adjacent(hall_inner, gate_inner).
adjacent(gate_inner, hall_inner).
adjacent(gate_inner, market_inner).
adjacent(market_inner, gate_inner).
adjacent(market_inner, dock_inner).
adjacent(dock_inner, market_inner).
adjacent(dock_inner, archive_inner).
adjacent(archive_inner, dock_inner).
adjacent(archive_inner, clinic_inner).
adjacent(clinic_inner, archive_inner).
adjacent(clinic_inner, tower_inner).
adjacent(tower_inner, clinic_inner).
adjacent(tower_inner, yard_inner).
adjacent(yard_inner, tower_inner).
adjacent(yard_inner, road_inner).
adjacent(road_inner, yard_inner).
adjacent(road_inner, bridge_inner).
adjacent(bridge_inner, road_inner).
adjacent(bridge_inner, vault_inner).
adjacent(vault_inner, bridge_inner).
adjacent(vault_inner, maze_inner).
adjacent(maze_inner, vault_inner).
adjacent(hall_outer, gate_outer).
adjacent(gate_outer, hall_outer).
adjacent(gate_outer, market_outer).
adjacent(market_outer, gate_outer).
adjacent(market_outer, dock_outer).
adjacent(dock_outer, market_outer).
adjacent(dock_outer, archive_outer).
adjacent(archive_outer, dock_outer).
adjacent(archive_outer, clinic_outer).
adjacent(clinic_outer, archive_outer).
adjacent(clinic_outer, tower_outer).
adjacent(tower_outer, clinic_outer).
adjacent(tower_outer, yard_outer).
adjacent(yard_outer, tower_outer).
adjacent(yard_outer, road_outer).
adjacent(road_outer, yard_outer).
adjacent(road_outer, bridge_outer).
adjacent(bridge_outer, road_outer).
adjacent(bridge_outer, vault_outer).
adjacent(vault_outer, bridge_outer).
adjacent(vault_outer, maze_outer).
adjacent(maze_outer, vault_outer).
adjacent(hall_upper, gate_upper).
adjacent(gate_upper, hall_upper).
adjacent(gate_upper, market_upper).
adjacent(market_upper, gate_upper).
adjacent(market_upper, dock_upper).
adjacent(dock_upper, market_upper).
adjacent(dock_upper, archive_upper).
adjacent(archive_upper, dock_upper).
adjacent(archive_upper, clinic_upper).
adjacent(clinic_upper, archive_upper).
adjacent(clinic_upper, tower_upper).
adjacent(tower_upper, clinic_upper).
adjacent(tower_upper, yard_upper).
adjacent(yard_upper, tower_upper).
adjacent(yard_upper, road_upper).
adjacent(road_upper, yard_upper).
adjacent(road_upper, bridge_upper).
adjacent(bridge_upper, road_upper).
adjacent(bridge_upper, vault_upper).
adjacent(vault_upper, bridge_upper).
adjacent(vault_upper, maze_upper).
adjacent(maze_upper, vault_upper).
adjacent(hall_lower, gate_lower).
adjacent(gate_lower, hall_lower).
adjacent(gate_lower, market_lower).
adjacent(market_lower, gate_lower).
adjacent(market_lower, dock_lower).
adjacent(dock_lower, market_lower).
adjacent(dock_lower, archive_lower).
adjacent(archive_lower, dock_lower).
adjacent(archive_lower, clinic_lower).
adjacent(clinic_lower, archive_lower).
adjacent(clinic_lower, tower_lower).
adjacent(tower_lower, clinic_lower).
adjacent(tower_lower, yard_lower).
adjacent(yard_lower, tower_lower).
adjacent(yard_lower, road_lower).
adjacent(road_lower, yard_lower).
adjacent(road_lower, bridge_lower).
adjacent(bridge_lower, road_lower).
adjacent(bridge_lower, vault_lower).
adjacent(vault_lower, bridge_lower).
adjacent(vault_lower, maze_lower).
adjacent(maze_lower, vault_lower).
adjacent(hall_north, hall_south).
adjacent(hall_south, hall_north).
adjacent(hall_south, hall_east).
adjacent(hall_east, hall_south).
adjacent(hall_east, hall_west).
adjacent(hall_west, hall_east).
adjacent(hall_west, hall_inner).
adjacent(hall_inner, hall_west).
adjacent(hall_inner, hall_outer).
adjacent(hall_outer, hall_inner).
adjacent(hall_outer, hall_upper).
adjacent(hall_upper, hall_outer).
adjacent(hall_upper, hall_lower).
adjacent(hall_lower, hall_upper).

competent(ada_north, threat).
willing(ada_north, threat, formal).
may_ask(ada_north, where, threat).
may_ask(ada_north, what, threat).
may_ask(ada_north, who, threat).
may_ask(ada_north, how, threat).
may_ask(ada_north, whether, threat).
may_ask(ada_north, why, threat).
may_ask(ada_north, when, threat).
may_ask(ada_north, which, threat).
competent(ada_north, trade).
willing(ada_north, trade, formal).
may_ask(ada_north, where, trade).
may_ask(ada_north, what, trade).
may_ask(ada_north, who, trade).
may_ask(ada_north, how, trade).
may_ask(ada_north, whether, trade).
may_ask(ada_north, why, trade).
may_ask(ada_north, when, trade).
may_ask(ada_north, which, trade).
competent(ada_north, health).
willing(ada_north, health, formal).
may_ask(ada_north, where, health).
may_ask(ada_north, what, health).
may_ask(ada_north, who, health).
may_ask(ada_north, how, health).
may_ask(ada_north, whether, health).
may_ask(ada_north, why, health).
may_ask(ada_north, when, health).
may_ask(ada_north, which, health).
competent(ada_north, archive).
willing(ada_north, archive, formal).
may_ask(ada_north, where, archive).
may_ask(ada_north, what, archive).
may_ask(ada_north, who, archive).
may_ask(ada_north, how, archive).
may_ask(ada_north, whether, archive).
may_ask(ada_north, why, archive).
may_ask(ada_north, when, archive).
may_ask(ada_north, which, archive).
stock(ada_north, greet, [hello, from, hall_north]).
stock(ada_north, close, [farewell, from, ada_north]).
competent(ada_south, gold).
willing(ada_south, gold, formal).
may_ask(ada_south, where, gold).
may_ask(ada_south, what, gold).
may_ask(ada_south, who, gold).
may_ask(ada_south, how, gold).
may_ask(ada_south, whether, gold).
may_ask(ada_south, why, gold).
may_ask(ada_south, when, gold).
may_ask(ada_south, which, gold).
competent(ada_south, map).
willing(ada_south, map, formal).
may_ask(ada_south, where, map).
may_ask(ada_south, what, map).
may_ask(ada_south, who, map).
may_ask(ada_south, how, map).
may_ask(ada_south, whether, map).
may_ask(ada_south, why, map).
may_ask(ada_south, when, map).
may_ask(ada_south, which, map).
competent(ada_south, route).
willing(ada_south, route, formal).
may_ask(ada_south, where, route).
may_ask(ada_south, what, route).
may_ask(ada_south, who, route).
may_ask(ada_south, how, route).
may_ask(ada_south, whether, route).
may_ask(ada_south, why, route).
may_ask(ada_south, when, route).
may_ask(ada_south, which, route).
competent(ada_south, threat).
willing(ada_south, threat, formal).
may_ask(ada_south, where, threat).
may_ask(ada_south, what, threat).
may_ask(ada_south, who, threat).
may_ask(ada_south, how, threat).
may_ask(ada_south, whether, threat).
may_ask(ada_south, why, threat).
may_ask(ada_south, when, threat).
may_ask(ada_south, which, threat).
stock(ada_south, greet, [hello, from, hall_south]).
stock(ada_south, close, [farewell, from, ada_south]).
competent(ada_east, trade).
willing(ada_east, trade, formal).
may_ask(ada_east, where, trade).
may_ask(ada_east, what, trade).
may_ask(ada_east, who, trade).
may_ask(ada_east, how, trade).
may_ask(ada_east, whether, trade).
may_ask(ada_east, why, trade).
may_ask(ada_east, when, trade).
may_ask(ada_east, which, trade).
competent(ada_east, health).
willing(ada_east, health, formal).
may_ask(ada_east, where, health).
may_ask(ada_east, what, health).
may_ask(ada_east, who, health).
may_ask(ada_east, how, health).
may_ask(ada_east, whether, health).
may_ask(ada_east, why, health).
may_ask(ada_east, when, health).
may_ask(ada_east, which, health).
competent(ada_east, archive).
willing(ada_east, archive, formal).
may_ask(ada_east, where, archive).
may_ask(ada_east, what, archive).
may_ask(ada_east, who, archive).
may_ask(ada_east, how, archive).
may_ask(ada_east, whether, archive).
may_ask(ada_east, why, archive).
may_ask(ada_east, when, archive).
may_ask(ada_east, which, archive).
competent(ada_east, weather).
willing(ada_east, weather, formal).
may_ask(ada_east, where, weather).
may_ask(ada_east, what, weather).
may_ask(ada_east, who, weather).
may_ask(ada_east, how, weather).
may_ask(ada_east, whether, weather).
may_ask(ada_east, why, weather).
may_ask(ada_east, when, weather).
may_ask(ada_east, which, weather).
stock(ada_east, greet, [hello, from, hall_east]).
stock(ada_east, close, [farewell, from, ada_east]).
competent(bas_north, threat).
willing(bas_north, threat, plain).
may_ask(bas_north, where, threat).
may_ask(bas_north, what, threat).
may_ask(bas_north, who, threat).
may_ask(bas_north, how, threat).
may_ask(bas_north, whether, threat).
may_ask(bas_north, why, threat).
may_ask(bas_north, when, threat).
may_ask(bas_north, which, threat).
competent(bas_north, trade).
willing(bas_north, trade, plain).
may_ask(bas_north, where, trade).
may_ask(bas_north, what, trade).
may_ask(bas_north, who, trade).
may_ask(bas_north, how, trade).
may_ask(bas_north, whether, trade).
may_ask(bas_north, why, trade).
may_ask(bas_north, when, trade).
may_ask(bas_north, which, trade).
competent(bas_north, health).
willing(bas_north, health, plain).
may_ask(bas_north, where, health).
may_ask(bas_north, what, health).
may_ask(bas_north, who, health).
may_ask(bas_north, how, health).
may_ask(bas_north, whether, health).
may_ask(bas_north, why, health).
may_ask(bas_north, when, health).
may_ask(bas_north, which, health).
competent(bas_north, archive).
willing(bas_north, archive, plain).
may_ask(bas_north, where, archive).
may_ask(bas_north, what, archive).
may_ask(bas_north, who, archive).
may_ask(bas_north, how, archive).
may_ask(bas_north, whether, archive).
may_ask(bas_north, why, archive).
may_ask(bas_north, when, archive).
may_ask(bas_north, which, archive).
stock(bas_north, greet, [hello, from, gate_north]).
stock(bas_north, close, [farewell, from, bas_north]).
competent(bas_south, threat).
willing(bas_south, threat, plain).
may_ask(bas_south, where, threat).
may_ask(bas_south, what, threat).
may_ask(bas_south, who, threat).
may_ask(bas_south, how, threat).
may_ask(bas_south, whether, threat).
may_ask(bas_south, why, threat).
may_ask(bas_south, when, threat).
may_ask(bas_south, which, threat).
competent(bas_south, trade).
willing(bas_south, trade, plain).
may_ask(bas_south, where, trade).
may_ask(bas_south, what, trade).
may_ask(bas_south, who, trade).
may_ask(bas_south, how, trade).
may_ask(bas_south, whether, trade).
may_ask(bas_south, why, trade).
may_ask(bas_south, when, trade).
may_ask(bas_south, which, trade).
competent(bas_south, health).
willing(bas_south, health, plain).
may_ask(bas_south, where, health).
may_ask(bas_south, what, health).
may_ask(bas_south, who, health).
may_ask(bas_south, how, health).
may_ask(bas_south, whether, health).
may_ask(bas_south, why, health).
may_ask(bas_south, when, health).
may_ask(bas_south, which, health).
competent(bas_south, archive).
willing(bas_south, archive, plain).
may_ask(bas_south, where, archive).
may_ask(bas_south, what, archive).
may_ask(bas_south, who, archive).
may_ask(bas_south, how, archive).
may_ask(bas_south, whether, archive).
may_ask(bas_south, why, archive).
may_ask(bas_south, when, archive).
may_ask(bas_south, which, archive).
stock(bas_south, greet, [hello, from, gate_south]).
stock(bas_south, close, [farewell, from, bas_south]).
competent(bas_east, gold).
willing(bas_east, gold, plain).
may_ask(bas_east, where, gold).
may_ask(bas_east, what, gold).
may_ask(bas_east, who, gold).
may_ask(bas_east, how, gold).
may_ask(bas_east, whether, gold).
may_ask(bas_east, why, gold).
may_ask(bas_east, when, gold).
may_ask(bas_east, which, gold).
competent(bas_east, map).
willing(bas_east, map, plain).
may_ask(bas_east, where, map).
may_ask(bas_east, what, map).
may_ask(bas_east, who, map).
may_ask(bas_east, how, map).
may_ask(bas_east, whether, map).
may_ask(bas_east, why, map).
may_ask(bas_east, when, map).
may_ask(bas_east, which, map).
competent(bas_east, route).
willing(bas_east, route, plain).
may_ask(bas_east, where, route).
may_ask(bas_east, what, route).
may_ask(bas_east, who, route).
may_ask(bas_east, how, route).
may_ask(bas_east, whether, route).
may_ask(bas_east, why, route).
may_ask(bas_east, when, route).
may_ask(bas_east, which, route).
competent(bas_east, threat).
willing(bas_east, threat, plain).
may_ask(bas_east, where, threat).
may_ask(bas_east, what, threat).
may_ask(bas_east, who, threat).
may_ask(bas_east, how, threat).
may_ask(bas_east, whether, threat).
may_ask(bas_east, why, threat).
may_ask(bas_east, when, threat).
may_ask(bas_east, which, threat).
stock(bas_east, greet, [hello, from, gate_east]).
stock(bas_east, close, [farewell, from, bas_east]).
competent(cor_north, map).
willing(cor_north, map, brief).
may_ask(cor_north, where, map).
may_ask(cor_north, what, map).
may_ask(cor_north, who, map).
may_ask(cor_north, how, map).
may_ask(cor_north, whether, map).
may_ask(cor_north, why, map).
may_ask(cor_north, when, map).
may_ask(cor_north, which, map).
competent(cor_north, route).
willing(cor_north, route, brief).
may_ask(cor_north, where, route).
may_ask(cor_north, what, route).
may_ask(cor_north, who, route).
may_ask(cor_north, how, route).
may_ask(cor_north, whether, route).
may_ask(cor_north, why, route).
may_ask(cor_north, when, route).
may_ask(cor_north, which, route).
competent(cor_north, threat).
willing(cor_north, threat, brief).
may_ask(cor_north, where, threat).
may_ask(cor_north, what, threat).
may_ask(cor_north, who, threat).
may_ask(cor_north, how, threat).
may_ask(cor_north, whether, threat).
may_ask(cor_north, why, threat).
may_ask(cor_north, when, threat).
may_ask(cor_north, which, threat).
competent(cor_north, trade).
willing(cor_north, trade, brief).
may_ask(cor_north, where, trade).
may_ask(cor_north, what, trade).
may_ask(cor_north, who, trade).
may_ask(cor_north, how, trade).
may_ask(cor_north, whether, trade).
may_ask(cor_north, why, trade).
may_ask(cor_north, when, trade).
may_ask(cor_north, which, trade).
stock(cor_north, greet, [hello, from, market_north]).
stock(cor_north, close, [farewell, from, cor_north]).
competent(cor_south, threat).
willing(cor_south, threat, brief).
may_ask(cor_south, where, threat).
may_ask(cor_south, what, threat).
may_ask(cor_south, who, threat).
may_ask(cor_south, how, threat).
may_ask(cor_south, whether, threat).
may_ask(cor_south, why, threat).
may_ask(cor_south, when, threat).
may_ask(cor_south, which, threat).
competent(cor_south, trade).
willing(cor_south, trade, brief).
may_ask(cor_south, where, trade).
may_ask(cor_south, what, trade).
may_ask(cor_south, who, trade).
may_ask(cor_south, how, trade).
may_ask(cor_south, whether, trade).
may_ask(cor_south, why, trade).
may_ask(cor_south, when, trade).
may_ask(cor_south, which, trade).
competent(cor_south, health).
willing(cor_south, health, brief).
may_ask(cor_south, where, health).
may_ask(cor_south, what, health).
may_ask(cor_south, who, health).
may_ask(cor_south, how, health).
may_ask(cor_south, whether, health).
may_ask(cor_south, why, health).
may_ask(cor_south, when, health).
may_ask(cor_south, which, health).
competent(cor_south, archive).
willing(cor_south, archive, brief).
may_ask(cor_south, where, archive).
may_ask(cor_south, what, archive).
may_ask(cor_south, who, archive).
may_ask(cor_south, how, archive).
may_ask(cor_south, whether, archive).
may_ask(cor_south, why, archive).
may_ask(cor_south, when, archive).
may_ask(cor_south, which, archive).
stock(cor_south, greet, [hello, from, market_south]).
stock(cor_south, close, [farewell, from, cor_south]).
competent(cor_east, map).
willing(cor_east, map, brief).
may_ask(cor_east, where, map).
may_ask(cor_east, what, map).
may_ask(cor_east, who, map).
may_ask(cor_east, how, map).
may_ask(cor_east, whether, map).
may_ask(cor_east, why, map).
may_ask(cor_east, when, map).
may_ask(cor_east, which, map).
competent(cor_east, route).
willing(cor_east, route, brief).
may_ask(cor_east, where, route).
may_ask(cor_east, what, route).
may_ask(cor_east, who, route).
may_ask(cor_east, how, route).
may_ask(cor_east, whether, route).
may_ask(cor_east, why, route).
may_ask(cor_east, when, route).
may_ask(cor_east, which, route).
competent(cor_east, threat).
willing(cor_east, threat, brief).
may_ask(cor_east, where, threat).
may_ask(cor_east, what, threat).
may_ask(cor_east, who, threat).
may_ask(cor_east, how, threat).
may_ask(cor_east, whether, threat).
may_ask(cor_east, why, threat).
may_ask(cor_east, when, threat).
may_ask(cor_east, which, threat).
competent(cor_east, trade).
willing(cor_east, trade, brief).
may_ask(cor_east, where, trade).
may_ask(cor_east, what, trade).
may_ask(cor_east, who, trade).
may_ask(cor_east, how, trade).
may_ask(cor_east, whether, trade).
may_ask(cor_east, why, trade).
may_ask(cor_east, when, trade).
may_ask(cor_east, which, trade).
stock(cor_east, greet, [hello, from, market_east]).
stock(cor_east, close, [farewell, from, cor_east]).
competent(dax_north, gold).
willing(dax_north, gold, cautious).
may_ask(dax_north, where, gold).
may_ask(dax_north, what, gold).
may_ask(dax_north, who, gold).
may_ask(dax_north, how, gold).
may_ask(dax_north, whether, gold).
may_ask(dax_north, why, gold).
may_ask(dax_north, when, gold).
may_ask(dax_north, which, gold).
competent(dax_north, map).
willing(dax_north, map, cautious).
may_ask(dax_north, where, map).
may_ask(dax_north, what, map).
may_ask(dax_north, who, map).
may_ask(dax_north, how, map).
may_ask(dax_north, whether, map).
may_ask(dax_north, why, map).
may_ask(dax_north, when, map).
may_ask(dax_north, which, map).
competent(dax_north, route).
willing(dax_north, route, cautious).
may_ask(dax_north, where, route).
may_ask(dax_north, what, route).
may_ask(dax_north, who, route).
may_ask(dax_north, how, route).
may_ask(dax_north, whether, route).
may_ask(dax_north, why, route).
may_ask(dax_north, when, route).
may_ask(dax_north, which, route).
competent(dax_north, threat).
willing(dax_north, threat, cautious).
may_ask(dax_north, where, threat).
may_ask(dax_north, what, threat).
may_ask(dax_north, who, threat).
may_ask(dax_north, how, threat).
may_ask(dax_north, whether, threat).
may_ask(dax_north, why, threat).
may_ask(dax_north, when, threat).
may_ask(dax_north, which, threat).
stock(dax_north, greet, [hello, from, dock_north]).
stock(dax_north, close, [farewell, from, dax_north]).
competent(dax_south, map).
willing(dax_south, map, cautious).
may_ask(dax_south, where, map).
may_ask(dax_south, what, map).
may_ask(dax_south, who, map).
may_ask(dax_south, how, map).
may_ask(dax_south, whether, map).
may_ask(dax_south, why, map).
may_ask(dax_south, when, map).
may_ask(dax_south, which, map).
competent(dax_south, route).
willing(dax_south, route, cautious).
may_ask(dax_south, where, route).
may_ask(dax_south, what, route).
may_ask(dax_south, who, route).
may_ask(dax_south, how, route).
may_ask(dax_south, whether, route).
may_ask(dax_south, why, route).
may_ask(dax_south, when, route).
may_ask(dax_south, which, route).
competent(dax_south, threat).
willing(dax_south, threat, cautious).
may_ask(dax_south, where, threat).
may_ask(dax_south, what, threat).
may_ask(dax_south, who, threat).
may_ask(dax_south, how, threat).
may_ask(dax_south, whether, threat).
may_ask(dax_south, why, threat).
may_ask(dax_south, when, threat).
may_ask(dax_south, which, threat).
competent(dax_south, trade).
willing(dax_south, trade, cautious).
may_ask(dax_south, where, trade).
may_ask(dax_south, what, trade).
may_ask(dax_south, who, trade).
may_ask(dax_south, how, trade).
may_ask(dax_south, whether, trade).
may_ask(dax_south, why, trade).
may_ask(dax_south, when, trade).
may_ask(dax_south, which, trade).
stock(dax_south, greet, [hello, from, dock_south]).
stock(dax_south, close, [farewell, from, dax_south]).
competent(dax_east, trade).
willing(dax_east, trade, cautious).
may_ask(dax_east, where, trade).
may_ask(dax_east, what, trade).
may_ask(dax_east, who, trade).
may_ask(dax_east, how, trade).
may_ask(dax_east, whether, trade).
may_ask(dax_east, why, trade).
may_ask(dax_east, when, trade).
may_ask(dax_east, which, trade).
competent(dax_east, health).
willing(dax_east, health, cautious).
may_ask(dax_east, where, health).
may_ask(dax_east, what, health).
may_ask(dax_east, who, health).
may_ask(dax_east, how, health).
may_ask(dax_east, whether, health).
may_ask(dax_east, why, health).
may_ask(dax_east, when, health).
may_ask(dax_east, which, health).
competent(dax_east, archive).
willing(dax_east, archive, cautious).
may_ask(dax_east, where, archive).
may_ask(dax_east, what, archive).
may_ask(dax_east, who, archive).
may_ask(dax_east, how, archive).
may_ask(dax_east, whether, archive).
may_ask(dax_east, why, archive).
may_ask(dax_east, when, archive).
may_ask(dax_east, which, archive).
competent(dax_east, weather).
willing(dax_east, weather, cautious).
may_ask(dax_east, where, weather).
may_ask(dax_east, what, weather).
may_ask(dax_east, who, weather).
may_ask(dax_east, how, weather).
may_ask(dax_east, whether, weather).
may_ask(dax_east, why, weather).
may_ask(dax_east, when, weather).
may_ask(dax_east, which, weather).
stock(dax_east, greet, [hello, from, dock_east]).
stock(dax_east, close, [farewell, from, dax_east]).
competent(eli_north, threat).
willing(eli_north, threat, urgent).
may_ask(eli_north, where, threat).
may_ask(eli_north, what, threat).
may_ask(eli_north, who, threat).
may_ask(eli_north, how, threat).
may_ask(eli_north, whether, threat).
may_ask(eli_north, why, threat).
may_ask(eli_north, when, threat).
may_ask(eli_north, which, threat).
competent(eli_north, trade).
willing(eli_north, trade, urgent).
may_ask(eli_north, where, trade).
may_ask(eli_north, what, trade).
may_ask(eli_north, who, trade).
may_ask(eli_north, how, trade).
may_ask(eli_north, whether, trade).
may_ask(eli_north, why, trade).
may_ask(eli_north, when, trade).
may_ask(eli_north, which, trade).
competent(eli_north, health).
willing(eli_north, health, urgent).
may_ask(eli_north, where, health).
may_ask(eli_north, what, health).
may_ask(eli_north, who, health).
may_ask(eli_north, how, health).
may_ask(eli_north, whether, health).
may_ask(eli_north, why, health).
may_ask(eli_north, when, health).
may_ask(eli_north, which, health).
competent(eli_north, archive).
willing(eli_north, archive, urgent).
may_ask(eli_north, where, archive).
may_ask(eli_north, what, archive).
may_ask(eli_north, who, archive).
may_ask(eli_north, how, archive).
may_ask(eli_north, whether, archive).
may_ask(eli_north, why, archive).
may_ask(eli_north, when, archive).
may_ask(eli_north, which, archive).
stock(eli_north, greet, [hello, from, archive_north]).
stock(eli_north, close, [farewell, from, eli_north]).
competent(eli_south, threat).
willing(eli_south, threat, urgent).
may_ask(eli_south, where, threat).
may_ask(eli_south, what, threat).
may_ask(eli_south, who, threat).
may_ask(eli_south, how, threat).
may_ask(eli_south, whether, threat).
may_ask(eli_south, why, threat).
may_ask(eli_south, when, threat).
may_ask(eli_south, which, threat).
competent(eli_south, trade).
willing(eli_south, trade, urgent).
may_ask(eli_south, where, trade).
may_ask(eli_south, what, trade).
may_ask(eli_south, who, trade).
may_ask(eli_south, how, trade).
may_ask(eli_south, whether, trade).
may_ask(eli_south, why, trade).
may_ask(eli_south, when, trade).
may_ask(eli_south, which, trade).
competent(eli_south, health).
willing(eli_south, health, urgent).
may_ask(eli_south, where, health).
may_ask(eli_south, what, health).
may_ask(eli_south, who, health).
may_ask(eli_south, how, health).
may_ask(eli_south, whether, health).
may_ask(eli_south, why, health).
may_ask(eli_south, when, health).
may_ask(eli_south, which, health).
competent(eli_south, archive).
willing(eli_south, archive, urgent).
may_ask(eli_south, where, archive).
may_ask(eli_south, what, archive).
may_ask(eli_south, who, archive).
may_ask(eli_south, how, archive).
may_ask(eli_south, whether, archive).
may_ask(eli_south, why, archive).
may_ask(eli_south, when, archive).
may_ask(eli_south, which, archive).
stock(eli_south, greet, [hello, from, archive_south]).
stock(eli_south, close, [farewell, from, eli_south]).
competent(eli_east, map).
willing(eli_east, map, urgent).
may_ask(eli_east, where, map).
may_ask(eli_east, what, map).
may_ask(eli_east, who, map).
may_ask(eli_east, how, map).
may_ask(eli_east, whether, map).
may_ask(eli_east, why, map).
may_ask(eli_east, when, map).
may_ask(eli_east, which, map).
competent(eli_east, route).
willing(eli_east, route, urgent).
may_ask(eli_east, where, route).
may_ask(eli_east, what, route).
may_ask(eli_east, who, route).
may_ask(eli_east, how, route).
may_ask(eli_east, whether, route).
may_ask(eli_east, why, route).
may_ask(eli_east, when, route).
may_ask(eli_east, which, route).
competent(eli_east, threat).
willing(eli_east, threat, urgent).
may_ask(eli_east, where, threat).
may_ask(eli_east, what, threat).
may_ask(eli_east, who, threat).
may_ask(eli_east, how, threat).
may_ask(eli_east, whether, threat).
may_ask(eli_east, why, threat).
may_ask(eli_east, when, threat).
may_ask(eli_east, which, threat).
competent(eli_east, trade).
willing(eli_east, trade, urgent).
may_ask(eli_east, where, trade).
may_ask(eli_east, what, trade).
may_ask(eli_east, who, trade).
may_ask(eli_east, how, trade).
may_ask(eli_east, whether, trade).
may_ask(eli_east, why, trade).
may_ask(eli_east, when, trade).
may_ask(eli_east, which, trade).
stock(eli_east, greet, [hello, from, archive_east]).
stock(eli_east, close, [farewell, from, eli_east]).
competent(fay_north, route).
willing(fay_north, route, formal).
may_ask(fay_north, where, route).
may_ask(fay_north, what, route).
may_ask(fay_north, who, route).
may_ask(fay_north, how, route).
may_ask(fay_north, whether, route).
may_ask(fay_north, why, route).
may_ask(fay_north, when, route).
may_ask(fay_north, which, route).
competent(fay_north, threat).
willing(fay_north, threat, formal).
may_ask(fay_north, where, threat).
may_ask(fay_north, what, threat).
may_ask(fay_north, who, threat).
may_ask(fay_north, how, threat).
may_ask(fay_north, whether, threat).
may_ask(fay_north, why, threat).
may_ask(fay_north, when, threat).
may_ask(fay_north, which, threat).
competent(fay_north, trade).
willing(fay_north, trade, formal).
may_ask(fay_north, where, trade).
may_ask(fay_north, what, trade).
may_ask(fay_north, who, trade).
may_ask(fay_north, how, trade).
may_ask(fay_north, whether, trade).
may_ask(fay_north, why, trade).
may_ask(fay_north, when, trade).
may_ask(fay_north, which, trade).
competent(fay_north, health).
willing(fay_north, health, formal).
may_ask(fay_north, where, health).
may_ask(fay_north, what, health).
may_ask(fay_north, who, health).
may_ask(fay_north, how, health).
may_ask(fay_north, whether, health).
may_ask(fay_north, why, health).
may_ask(fay_north, when, health).
may_ask(fay_north, which, health).
stock(fay_north, greet, [hello, from, clinic_north]).
stock(fay_north, close, [farewell, from, fay_north]).
competent(fay_south, threat).
willing(fay_south, threat, formal).
may_ask(fay_south, where, threat).
may_ask(fay_south, what, threat).
may_ask(fay_south, who, threat).
may_ask(fay_south, how, threat).
may_ask(fay_south, whether, threat).
may_ask(fay_south, why, threat).
may_ask(fay_south, when, threat).
may_ask(fay_south, which, threat).
competent(fay_south, trade).
willing(fay_south, trade, formal).
may_ask(fay_south, where, trade).
may_ask(fay_south, what, trade).
may_ask(fay_south, who, trade).
may_ask(fay_south, how, trade).
may_ask(fay_south, whether, trade).
may_ask(fay_south, why, trade).
may_ask(fay_south, when, trade).
may_ask(fay_south, which, trade).
competent(fay_south, health).
willing(fay_south, health, formal).
may_ask(fay_south, where, health).
may_ask(fay_south, what, health).
may_ask(fay_south, who, health).
may_ask(fay_south, how, health).
may_ask(fay_south, whether, health).
may_ask(fay_south, why, health).
may_ask(fay_south, when, health).
may_ask(fay_south, which, health).
competent(fay_south, archive).
willing(fay_south, archive, formal).
may_ask(fay_south, where, archive).
may_ask(fay_south, what, archive).
may_ask(fay_south, who, archive).
may_ask(fay_south, how, archive).
may_ask(fay_south, whether, archive).
may_ask(fay_south, why, archive).
may_ask(fay_south, when, archive).
may_ask(fay_south, which, archive).
stock(fay_south, greet, [hello, from, clinic_south]).
stock(fay_south, close, [farewell, from, fay_south]).
competent(fay_east, threat).
willing(fay_east, threat, formal).
may_ask(fay_east, where, threat).
may_ask(fay_east, what, threat).
may_ask(fay_east, who, threat).
may_ask(fay_east, how, threat).
may_ask(fay_east, whether, threat).
may_ask(fay_east, why, threat).
may_ask(fay_east, when, threat).
may_ask(fay_east, which, threat).
competent(fay_east, trade).
willing(fay_east, trade, formal).
may_ask(fay_east, where, trade).
may_ask(fay_east, what, trade).
may_ask(fay_east, who, trade).
may_ask(fay_east, how, trade).
may_ask(fay_east, whether, trade).
may_ask(fay_east, why, trade).
may_ask(fay_east, when, trade).
may_ask(fay_east, which, trade).
competent(fay_east, health).
willing(fay_east, health, formal).
may_ask(fay_east, where, health).
may_ask(fay_east, what, health).
may_ask(fay_east, who, health).
may_ask(fay_east, how, health).
may_ask(fay_east, whether, health).
may_ask(fay_east, why, health).
may_ask(fay_east, when, health).
may_ask(fay_east, which, health).
competent(fay_east, archive).
willing(fay_east, archive, formal).
may_ask(fay_east, where, archive).
may_ask(fay_east, what, archive).
may_ask(fay_east, who, archive).
may_ask(fay_east, how, archive).
may_ask(fay_east, whether, archive).
may_ask(fay_east, why, archive).
may_ask(fay_east, when, archive).
may_ask(fay_east, which, archive).
stock(fay_east, greet, [hello, from, clinic_east]).
stock(fay_east, close, [farewell, from, fay_east]).
competent(gio_north, route).
willing(gio_north, route, plain).
may_ask(gio_north, where, route).
may_ask(gio_north, what, route).
may_ask(gio_north, who, route).
may_ask(gio_north, how, route).
may_ask(gio_north, whether, route).
may_ask(gio_north, why, route).
may_ask(gio_north, when, route).
may_ask(gio_north, which, route).
competent(gio_north, threat).
willing(gio_north, threat, plain).
may_ask(gio_north, where, threat).
may_ask(gio_north, what, threat).
may_ask(gio_north, who, threat).
may_ask(gio_north, how, threat).
may_ask(gio_north, whether, threat).
may_ask(gio_north, why, threat).
may_ask(gio_north, when, threat).
may_ask(gio_north, which, threat).
competent(gio_north, trade).
willing(gio_north, trade, plain).
may_ask(gio_north, where, trade).
may_ask(gio_north, what, trade).
may_ask(gio_north, who, trade).
may_ask(gio_north, how, trade).
may_ask(gio_north, whether, trade).
may_ask(gio_north, why, trade).
may_ask(gio_north, when, trade).
may_ask(gio_north, which, trade).
competent(gio_north, health).
willing(gio_north, health, plain).
may_ask(gio_north, where, health).
may_ask(gio_north, what, health).
may_ask(gio_north, who, health).
may_ask(gio_north, how, health).
may_ask(gio_north, whether, health).
may_ask(gio_north, why, health).
may_ask(gio_north, when, health).
may_ask(gio_north, which, health).
stock(gio_north, greet, [hello, from, tower_north]).
stock(gio_north, close, [farewell, from, gio_north]).
competent(gio_south, route).
willing(gio_south, route, plain).
may_ask(gio_south, where, route).
may_ask(gio_south, what, route).
may_ask(gio_south, who, route).
may_ask(gio_south, how, route).
may_ask(gio_south, whether, route).
may_ask(gio_south, why, route).
may_ask(gio_south, when, route).
may_ask(gio_south, which, route).
competent(gio_south, threat).
willing(gio_south, threat, plain).
may_ask(gio_south, where, threat).
may_ask(gio_south, what, threat).
may_ask(gio_south, who, threat).
may_ask(gio_south, how, threat).
may_ask(gio_south, whether, threat).
may_ask(gio_south, why, threat).
may_ask(gio_south, when, threat).
may_ask(gio_south, which, threat).
competent(gio_south, trade).
willing(gio_south, trade, plain).
may_ask(gio_south, where, trade).
may_ask(gio_south, what, trade).
may_ask(gio_south, who, trade).
may_ask(gio_south, how, trade).
may_ask(gio_south, whether, trade).
may_ask(gio_south, why, trade).
may_ask(gio_south, when, trade).
may_ask(gio_south, which, trade).
competent(gio_south, health).
willing(gio_south, health, plain).
may_ask(gio_south, where, health).
may_ask(gio_south, what, health).
may_ask(gio_south, who, health).
may_ask(gio_south, how, health).
may_ask(gio_south, whether, health).
may_ask(gio_south, why, health).
may_ask(gio_south, when, health).
may_ask(gio_south, which, health).
stock(gio_south, greet, [hello, from, tower_south]).
stock(gio_south, close, [farewell, from, gio_south]).
competent(gio_east, threat).
willing(gio_east, threat, plain).
may_ask(gio_east, where, threat).
may_ask(gio_east, what, threat).
may_ask(gio_east, who, threat).
may_ask(gio_east, how, threat).
may_ask(gio_east, whether, threat).
may_ask(gio_east, why, threat).
may_ask(gio_east, when, threat).
may_ask(gio_east, which, threat).
competent(gio_east, trade).
willing(gio_east, trade, plain).
may_ask(gio_east, where, trade).
may_ask(gio_east, what, trade).
may_ask(gio_east, who, trade).
may_ask(gio_east, how, trade).
may_ask(gio_east, whether, trade).
may_ask(gio_east, why, trade).
may_ask(gio_east, when, trade).
may_ask(gio_east, which, trade).
competent(gio_east, health).
willing(gio_east, health, plain).
may_ask(gio_east, where, health).
may_ask(gio_east, what, health).
may_ask(gio_east, who, health).
may_ask(gio_east, how, health).
may_ask(gio_east, whether, health).
may_ask(gio_east, why, health).
may_ask(gio_east, when, health).
may_ask(gio_east, which, health).
competent(gio_east, archive).
willing(gio_east, archive, plain).
may_ask(gio_east, where, archive).
may_ask(gio_east, what, archive).
may_ask(gio_east, who, archive).
may_ask(gio_east, how, archive).
may_ask(gio_east, whether, archive).
may_ask(gio_east, why, archive).
may_ask(gio_east, when, archive).
may_ask(gio_east, which, archive).
stock(gio_east, greet, [hello, from, tower_east]).
stock(gio_east, close, [farewell, from, gio_east]).
competent(hal_north, map).
willing(hal_north, map, brief).
may_ask(hal_north, where, map).
may_ask(hal_north, what, map).
may_ask(hal_north, who, map).
may_ask(hal_north, how, map).
may_ask(hal_north, whether, map).
may_ask(hal_north, why, map).
may_ask(hal_north, when, map).
may_ask(hal_north, which, map).
competent(hal_north, route).
willing(hal_north, route, brief).
may_ask(hal_north, where, route).
may_ask(hal_north, what, route).
may_ask(hal_north, who, route).
may_ask(hal_north, how, route).
may_ask(hal_north, whether, route).
may_ask(hal_north, why, route).
may_ask(hal_north, when, route).
may_ask(hal_north, which, route).
competent(hal_north, threat).
willing(hal_north, threat, brief).
may_ask(hal_north, where, threat).
may_ask(hal_north, what, threat).
may_ask(hal_north, who, threat).
may_ask(hal_north, how, threat).
may_ask(hal_north, whether, threat).
may_ask(hal_north, why, threat).
may_ask(hal_north, when, threat).
may_ask(hal_north, which, threat).
competent(hal_north, trade).
willing(hal_north, trade, brief).
may_ask(hal_north, where, trade).
may_ask(hal_north, what, trade).
may_ask(hal_north, who, trade).
may_ask(hal_north, how, trade).
may_ask(hal_north, whether, trade).
may_ask(hal_north, why, trade).
may_ask(hal_north, when, trade).
may_ask(hal_north, which, trade).
stock(hal_north, greet, [hello, from, yard_north]).
stock(hal_north, close, [farewell, from, hal_north]).
competent(hal_south, map).
willing(hal_south, map, brief).
may_ask(hal_south, where, map).
may_ask(hal_south, what, map).
may_ask(hal_south, who, map).
may_ask(hal_south, how, map).
may_ask(hal_south, whether, map).
may_ask(hal_south, why, map).
may_ask(hal_south, when, map).
may_ask(hal_south, which, map).
competent(hal_south, route).
willing(hal_south, route, brief).
may_ask(hal_south, where, route).
may_ask(hal_south, what, route).
may_ask(hal_south, who, route).
may_ask(hal_south, how, route).
may_ask(hal_south, whether, route).
may_ask(hal_south, why, route).
may_ask(hal_south, when, route).
may_ask(hal_south, which, route).
competent(hal_south, threat).
willing(hal_south, threat, brief).
may_ask(hal_south, where, threat).
may_ask(hal_south, what, threat).
may_ask(hal_south, who, threat).
may_ask(hal_south, how, threat).
may_ask(hal_south, whether, threat).
may_ask(hal_south, why, threat).
may_ask(hal_south, when, threat).
may_ask(hal_south, which, threat).
competent(hal_south, trade).
willing(hal_south, trade, brief).
may_ask(hal_south, where, trade).
may_ask(hal_south, what, trade).
may_ask(hal_south, who, trade).
may_ask(hal_south, how, trade).
may_ask(hal_south, whether, trade).
may_ask(hal_south, why, trade).
may_ask(hal_south, when, trade).
may_ask(hal_south, which, trade).
stock(hal_south, greet, [hello, from, yard_south]).
stock(hal_south, close, [farewell, from, hal_south]).
competent(hal_east, trade).
willing(hal_east, trade, brief).
may_ask(hal_east, where, trade).
may_ask(hal_east, what, trade).
may_ask(hal_east, who, trade).
may_ask(hal_east, how, trade).
may_ask(hal_east, whether, trade).
may_ask(hal_east, why, trade).
may_ask(hal_east, when, trade).
may_ask(hal_east, which, trade).
competent(hal_east, health).
willing(hal_east, health, brief).
may_ask(hal_east, where, health).
may_ask(hal_east, what, health).
may_ask(hal_east, who, health).
may_ask(hal_east, how, health).
may_ask(hal_east, whether, health).
may_ask(hal_east, why, health).
may_ask(hal_east, when, health).
may_ask(hal_east, which, health).
competent(hal_east, archive).
willing(hal_east, archive, brief).
may_ask(hal_east, where, archive).
may_ask(hal_east, what, archive).
may_ask(hal_east, who, archive).
may_ask(hal_east, how, archive).
may_ask(hal_east, whether, archive).
may_ask(hal_east, why, archive).
may_ask(hal_east, when, archive).
may_ask(hal_east, which, archive).
competent(hal_east, weather).
willing(hal_east, weather, brief).
may_ask(hal_east, where, weather).
may_ask(hal_east, what, weather).
may_ask(hal_east, who, weather).
may_ask(hal_east, how, weather).
may_ask(hal_east, whether, weather).
may_ask(hal_east, why, weather).
may_ask(hal_east, when, weather).
may_ask(hal_east, which, weather).
stock(hal_east, greet, [hello, from, yard_east]).
stock(hal_east, close, [farewell, from, hal_east]).
competent(ira_north, map).
willing(ira_north, map, cautious).
may_ask(ira_north, where, map).
may_ask(ira_north, what, map).
may_ask(ira_north, who, map).
may_ask(ira_north, how, map).
may_ask(ira_north, whether, map).
may_ask(ira_north, why, map).
may_ask(ira_north, when, map).
may_ask(ira_north, which, map).
competent(ira_north, route).
willing(ira_north, route, cautious).
may_ask(ira_north, where, route).
may_ask(ira_north, what, route).
may_ask(ira_north, who, route).
may_ask(ira_north, how, route).
may_ask(ira_north, whether, route).
may_ask(ira_north, why, route).
may_ask(ira_north, when, route).
may_ask(ira_north, which, route).
competent(ira_north, threat).
willing(ira_north, threat, cautious).
may_ask(ira_north, where, threat).
may_ask(ira_north, what, threat).
may_ask(ira_north, who, threat).
may_ask(ira_north, how, threat).
may_ask(ira_north, whether, threat).
may_ask(ira_north, why, threat).
may_ask(ira_north, when, threat).
may_ask(ira_north, which, threat).
competent(ira_north, trade).
willing(ira_north, trade, cautious).
may_ask(ira_north, where, trade).
may_ask(ira_north, what, trade).
may_ask(ira_north, who, trade).
may_ask(ira_north, how, trade).
may_ask(ira_north, whether, trade).
may_ask(ira_north, why, trade).
may_ask(ira_north, when, trade).
may_ask(ira_north, which, trade).
stock(ira_north, greet, [hello, from, road_north]).
stock(ira_north, close, [farewell, from, ira_north]).
competent(ira_south, gold).
willing(ira_south, gold, cautious).
may_ask(ira_south, where, gold).
may_ask(ira_south, what, gold).
may_ask(ira_south, who, gold).
may_ask(ira_south, how, gold).
may_ask(ira_south, whether, gold).
may_ask(ira_south, why, gold).
may_ask(ira_south, when, gold).
may_ask(ira_south, which, gold).
competent(ira_south, map).
willing(ira_south, map, cautious).
may_ask(ira_south, where, map).
may_ask(ira_south, what, map).
may_ask(ira_south, who, map).
may_ask(ira_south, how, map).
may_ask(ira_south, whether, map).
may_ask(ira_south, why, map).
may_ask(ira_south, when, map).
may_ask(ira_south, which, map).
competent(ira_south, route).
willing(ira_south, route, cautious).
may_ask(ira_south, where, route).
may_ask(ira_south, what, route).
may_ask(ira_south, who, route).
may_ask(ira_south, how, route).
may_ask(ira_south, whether, route).
may_ask(ira_south, why, route).
may_ask(ira_south, when, route).
may_ask(ira_south, which, route).
competent(ira_south, threat).
willing(ira_south, threat, cautious).
may_ask(ira_south, where, threat).
may_ask(ira_south, what, threat).
may_ask(ira_south, who, threat).
may_ask(ira_south, how, threat).
may_ask(ira_south, whether, threat).
may_ask(ira_south, why, threat).
may_ask(ira_south, when, threat).
may_ask(ira_south, which, threat).
stock(ira_south, greet, [hello, from, road_south]).
stock(ira_south, close, [farewell, from, ira_south]).
competent(ira_east, threat).
willing(ira_east, threat, cautious).
may_ask(ira_east, where, threat).
may_ask(ira_east, what, threat).
may_ask(ira_east, who, threat).
may_ask(ira_east, how, threat).
may_ask(ira_east, whether, threat).
may_ask(ira_east, why, threat).
may_ask(ira_east, when, threat).
may_ask(ira_east, which, threat).
competent(ira_east, trade).
willing(ira_east, trade, cautious).
may_ask(ira_east, where, trade).
may_ask(ira_east, what, trade).
may_ask(ira_east, who, trade).
may_ask(ira_east, how, trade).
may_ask(ira_east, whether, trade).
may_ask(ira_east, why, trade).
may_ask(ira_east, when, trade).
may_ask(ira_east, which, trade).
competent(ira_east, health).
willing(ira_east, health, cautious).
may_ask(ira_east, where, health).
may_ask(ira_east, what, health).
may_ask(ira_east, who, health).
may_ask(ira_east, how, health).
may_ask(ira_east, whether, health).
may_ask(ira_east, why, health).
may_ask(ira_east, when, health).
may_ask(ira_east, which, health).
competent(ira_east, archive).
willing(ira_east, archive, cautious).
may_ask(ira_east, where, archive).
may_ask(ira_east, what, archive).
may_ask(ira_east, who, archive).
may_ask(ira_east, how, archive).
may_ask(ira_east, whether, archive).
may_ask(ira_east, why, archive).
may_ask(ira_east, when, archive).
may_ask(ira_east, which, archive).
stock(ira_east, greet, [hello, from, road_east]).
stock(ira_east, close, [farewell, from, ira_east]).
competent(joss_north, threat).
willing(joss_north, threat, urgent).
may_ask(joss_north, where, threat).
may_ask(joss_north, what, threat).
may_ask(joss_north, who, threat).
may_ask(joss_north, how, threat).
may_ask(joss_north, whether, threat).
may_ask(joss_north, why, threat).
may_ask(joss_north, when, threat).
may_ask(joss_north, which, threat).
competent(joss_north, trade).
willing(joss_north, trade, urgent).
may_ask(joss_north, where, trade).
may_ask(joss_north, what, trade).
may_ask(joss_north, who, trade).
may_ask(joss_north, how, trade).
may_ask(joss_north, whether, trade).
may_ask(joss_north, why, trade).
may_ask(joss_north, when, trade).
may_ask(joss_north, which, trade).
competent(joss_north, health).
willing(joss_north, health, urgent).
may_ask(joss_north, where, health).
may_ask(joss_north, what, health).
may_ask(joss_north, who, health).
may_ask(joss_north, how, health).
may_ask(joss_north, whether, health).
may_ask(joss_north, why, health).
may_ask(joss_north, when, health).
may_ask(joss_north, which, health).
competent(joss_north, archive).
willing(joss_north, archive, urgent).
may_ask(joss_north, where, archive).
may_ask(joss_north, what, archive).
may_ask(joss_north, who, archive).
may_ask(joss_north, how, archive).
may_ask(joss_north, whether, archive).
may_ask(joss_north, why, archive).
may_ask(joss_north, when, archive).
may_ask(joss_north, which, archive).
stock(joss_north, greet, [hello, from, bridge_north]).
stock(joss_north, close, [farewell, from, joss_north]).
competent(joss_south, trade).
willing(joss_south, trade, urgent).
may_ask(joss_south, where, trade).
may_ask(joss_south, what, trade).
may_ask(joss_south, who, trade).
may_ask(joss_south, how, trade).
may_ask(joss_south, whether, trade).
may_ask(joss_south, why, trade).
may_ask(joss_south, when, trade).
may_ask(joss_south, which, trade).
competent(joss_south, health).
willing(joss_south, health, urgent).
may_ask(joss_south, where, health).
may_ask(joss_south, what, health).
may_ask(joss_south, who, health).
may_ask(joss_south, how, health).
may_ask(joss_south, whether, health).
may_ask(joss_south, why, health).
may_ask(joss_south, when, health).
may_ask(joss_south, which, health).
competent(joss_south, archive).
willing(joss_south, archive, urgent).
may_ask(joss_south, where, archive).
may_ask(joss_south, what, archive).
may_ask(joss_south, who, archive).
may_ask(joss_south, how, archive).
may_ask(joss_south, whether, archive).
may_ask(joss_south, why, archive).
may_ask(joss_south, when, archive).
may_ask(joss_south, which, archive).
competent(joss_south, weather).
willing(joss_south, weather, urgent).
may_ask(joss_south, where, weather).
may_ask(joss_south, what, weather).
may_ask(joss_south, who, weather).
may_ask(joss_south, how, weather).
may_ask(joss_south, whether, weather).
may_ask(joss_south, why, weather).
may_ask(joss_south, when, weather).
may_ask(joss_south, which, weather).
stock(joss_south, greet, [hello, from, bridge_south]).
stock(joss_south, close, [farewell, from, joss_south]).
competent(joss_east, route).
willing(joss_east, route, urgent).
may_ask(joss_east, where, route).
may_ask(joss_east, what, route).
may_ask(joss_east, who, route).
may_ask(joss_east, how, route).
may_ask(joss_east, whether, route).
may_ask(joss_east, why, route).
may_ask(joss_east, when, route).
may_ask(joss_east, which, route).
competent(joss_east, threat).
willing(joss_east, threat, urgent).
may_ask(joss_east, where, threat).
may_ask(joss_east, what, threat).
may_ask(joss_east, who, threat).
may_ask(joss_east, how, threat).
may_ask(joss_east, whether, threat).
may_ask(joss_east, why, threat).
may_ask(joss_east, when, threat).
may_ask(joss_east, which, threat).
competent(joss_east, trade).
willing(joss_east, trade, urgent).
may_ask(joss_east, where, trade).
may_ask(joss_east, what, trade).
may_ask(joss_east, who, trade).
may_ask(joss_east, how, trade).
may_ask(joss_east, whether, trade).
may_ask(joss_east, why, trade).
may_ask(joss_east, when, trade).
may_ask(joss_east, which, trade).
competent(joss_east, health).
willing(joss_east, health, urgent).
may_ask(joss_east, where, health).
may_ask(joss_east, what, health).
may_ask(joss_east, who, health).
may_ask(joss_east, how, health).
may_ask(joss_east, whether, health).
may_ask(joss_east, why, health).
may_ask(joss_east, when, health).
may_ask(joss_east, which, health).
stock(joss_east, greet, [hello, from, bridge_east]).
stock(joss_east, close, [farewell, from, joss_east]).
competent(kai_north, route).
willing(kai_north, route, formal).
may_ask(kai_north, where, route).
may_ask(kai_north, what, route).
may_ask(kai_north, who, route).
may_ask(kai_north, how, route).
may_ask(kai_north, whether, route).
may_ask(kai_north, why, route).
may_ask(kai_north, when, route).
may_ask(kai_north, which, route).
competent(kai_north, threat).
willing(kai_north, threat, formal).
may_ask(kai_north, where, threat).
may_ask(kai_north, what, threat).
may_ask(kai_north, who, threat).
may_ask(kai_north, how, threat).
may_ask(kai_north, whether, threat).
may_ask(kai_north, why, threat).
may_ask(kai_north, when, threat).
may_ask(kai_north, which, threat).
competent(kai_north, trade).
willing(kai_north, trade, formal).
may_ask(kai_north, where, trade).
may_ask(kai_north, what, trade).
may_ask(kai_north, who, trade).
may_ask(kai_north, how, trade).
may_ask(kai_north, whether, trade).
may_ask(kai_north, why, trade).
may_ask(kai_north, when, trade).
may_ask(kai_north, which, trade).
competent(kai_north, health).
willing(kai_north, health, formal).
may_ask(kai_north, where, health).
may_ask(kai_north, what, health).
may_ask(kai_north, who, health).
may_ask(kai_north, how, health).
may_ask(kai_north, whether, health).
may_ask(kai_north, why, health).
may_ask(kai_north, when, health).
may_ask(kai_north, which, health).
stock(kai_north, greet, [hello, from, vault_north]).
stock(kai_north, close, [farewell, from, kai_north]).
competent(kai_south, map).
willing(kai_south, map, formal).
may_ask(kai_south, where, map).
may_ask(kai_south, what, map).
may_ask(kai_south, who, map).
may_ask(kai_south, how, map).
may_ask(kai_south, whether, map).
may_ask(kai_south, why, map).
may_ask(kai_south, when, map).
may_ask(kai_south, which, map).
competent(kai_south, route).
willing(kai_south, route, formal).
may_ask(kai_south, where, route).
may_ask(kai_south, what, route).
may_ask(kai_south, who, route).
may_ask(kai_south, how, route).
may_ask(kai_south, whether, route).
may_ask(kai_south, why, route).
may_ask(kai_south, when, route).
may_ask(kai_south, which, route).
competent(kai_south, threat).
willing(kai_south, threat, formal).
may_ask(kai_south, where, threat).
may_ask(kai_south, what, threat).
may_ask(kai_south, who, threat).
may_ask(kai_south, how, threat).
may_ask(kai_south, whether, threat).
may_ask(kai_south, why, threat).
may_ask(kai_south, when, threat).
may_ask(kai_south, which, threat).
competent(kai_south, trade).
willing(kai_south, trade, formal).
may_ask(kai_south, where, trade).
may_ask(kai_south, what, trade).
may_ask(kai_south, who, trade).
may_ask(kai_south, how, trade).
may_ask(kai_south, whether, trade).
may_ask(kai_south, why, trade).
may_ask(kai_south, when, trade).
may_ask(kai_south, which, trade).
stock(kai_south, greet, [hello, from, vault_south]).
stock(kai_south, close, [farewell, from, kai_south]).
competent(kai_east, threat).
willing(kai_east, threat, formal).
may_ask(kai_east, where, threat).
may_ask(kai_east, what, threat).
may_ask(kai_east, who, threat).
may_ask(kai_east, how, threat).
may_ask(kai_east, whether, threat).
may_ask(kai_east, why, threat).
may_ask(kai_east, when, threat).
may_ask(kai_east, which, threat).
competent(kai_east, trade).
willing(kai_east, trade, formal).
may_ask(kai_east, where, trade).
may_ask(kai_east, what, trade).
may_ask(kai_east, who, trade).
may_ask(kai_east, how, trade).
may_ask(kai_east, whether, trade).
may_ask(kai_east, why, trade).
may_ask(kai_east, when, trade).
may_ask(kai_east, which, trade).
competent(kai_east, health).
willing(kai_east, health, formal).
may_ask(kai_east, where, health).
may_ask(kai_east, what, health).
may_ask(kai_east, who, health).
may_ask(kai_east, how, health).
may_ask(kai_east, whether, health).
may_ask(kai_east, why, health).
may_ask(kai_east, when, health).
may_ask(kai_east, which, health).
competent(kai_east, archive).
willing(kai_east, archive, formal).
may_ask(kai_east, where, archive).
may_ask(kai_east, what, archive).
may_ask(kai_east, who, archive).
may_ask(kai_east, how, archive).
may_ask(kai_east, whether, archive).
may_ask(kai_east, why, archive).
may_ask(kai_east, when, archive).
may_ask(kai_east, which, archive).
stock(kai_east, greet, [hello, from, vault_east]).
stock(kai_east, close, [farewell, from, kai_east]).
competent(lea_north, trade).
willing(lea_north, trade, plain).
may_ask(lea_north, where, trade).
may_ask(lea_north, what, trade).
may_ask(lea_north, who, trade).
may_ask(lea_north, how, trade).
may_ask(lea_north, whether, trade).
may_ask(lea_north, why, trade).
may_ask(lea_north, when, trade).
may_ask(lea_north, which, trade).
competent(lea_north, health).
willing(lea_north, health, plain).
may_ask(lea_north, where, health).
may_ask(lea_north, what, health).
may_ask(lea_north, who, health).
may_ask(lea_north, how, health).
may_ask(lea_north, whether, health).
may_ask(lea_north, why, health).
may_ask(lea_north, when, health).
may_ask(lea_north, which, health).
competent(lea_north, archive).
willing(lea_north, archive, plain).
may_ask(lea_north, where, archive).
may_ask(lea_north, what, archive).
may_ask(lea_north, who, archive).
may_ask(lea_north, how, archive).
may_ask(lea_north, whether, archive).
may_ask(lea_north, why, archive).
may_ask(lea_north, when, archive).
may_ask(lea_north, which, archive).
competent(lea_north, weather).
willing(lea_north, weather, plain).
may_ask(lea_north, where, weather).
may_ask(lea_north, what, weather).
may_ask(lea_north, who, weather).
may_ask(lea_north, how, weather).
may_ask(lea_north, whether, weather).
may_ask(lea_north, why, weather).
may_ask(lea_north, when, weather).
may_ask(lea_north, which, weather).
stock(lea_north, greet, [hello, from, maze_north]).
stock(lea_north, close, [farewell, from, lea_north]).
competent(lea_south, gold).
willing(lea_south, gold, plain).
may_ask(lea_south, where, gold).
may_ask(lea_south, what, gold).
may_ask(lea_south, who, gold).
may_ask(lea_south, how, gold).
may_ask(lea_south, whether, gold).
may_ask(lea_south, why, gold).
may_ask(lea_south, when, gold).
may_ask(lea_south, which, gold).
competent(lea_south, map).
willing(lea_south, map, plain).
may_ask(lea_south, where, map).
may_ask(lea_south, what, map).
may_ask(lea_south, who, map).
may_ask(lea_south, how, map).
may_ask(lea_south, whether, map).
may_ask(lea_south, why, map).
may_ask(lea_south, when, map).
may_ask(lea_south, which, map).
competent(lea_south, route).
willing(lea_south, route, plain).
may_ask(lea_south, where, route).
may_ask(lea_south, what, route).
may_ask(lea_south, who, route).
may_ask(lea_south, how, route).
may_ask(lea_south, whether, route).
may_ask(lea_south, why, route).
may_ask(lea_south, when, route).
may_ask(lea_south, which, route).
competent(lea_south, threat).
willing(lea_south, threat, plain).
may_ask(lea_south, where, threat).
may_ask(lea_south, what, threat).
may_ask(lea_south, who, threat).
may_ask(lea_south, how, threat).
may_ask(lea_south, whether, threat).
may_ask(lea_south, why, threat).
may_ask(lea_south, when, threat).
may_ask(lea_south, which, threat).
stock(lea_south, greet, [hello, from, maze_south]).
stock(lea_south, close, [farewell, from, lea_south]).
competent(lea_east, map).
willing(lea_east, map, plain).
may_ask(lea_east, where, map).
may_ask(lea_east, what, map).
may_ask(lea_east, who, map).
may_ask(lea_east, how, map).
may_ask(lea_east, whether, map).
may_ask(lea_east, why, map).
may_ask(lea_east, when, map).
may_ask(lea_east, which, map).
competent(lea_east, route).
willing(lea_east, route, plain).
may_ask(lea_east, where, route).
may_ask(lea_east, what, route).
may_ask(lea_east, who, route).
may_ask(lea_east, how, route).
may_ask(lea_east, whether, route).
may_ask(lea_east, why, route).
may_ask(lea_east, when, route).
may_ask(lea_east, which, route).
competent(lea_east, threat).
willing(lea_east, threat, plain).
may_ask(lea_east, where, threat).
may_ask(lea_east, what, threat).
may_ask(lea_east, who, threat).
may_ask(lea_east, how, threat).
may_ask(lea_east, whether, threat).
may_ask(lea_east, why, threat).
may_ask(lea_east, when, threat).
may_ask(lea_east, which, threat).
competent(lea_east, trade).
willing(lea_east, trade, plain).
may_ask(lea_east, where, trade).
may_ask(lea_east, what, trade).
may_ask(lea_east, who, trade).
may_ask(lea_east, how, trade).
may_ask(lea_east, whether, trade).
may_ask(lea_east, why, trade).
may_ask(lea_east, when, trade).
may_ask(lea_east, which, trade).
stock(lea_east, greet, [hello, from, maze_east]).
stock(lea_east, close, [farewell, from, lea_east]).
competent(mio_north, route).
willing(mio_north, route, brief).
may_ask(mio_north, where, route).
may_ask(mio_north, what, route).
may_ask(mio_north, who, route).
may_ask(mio_north, how, route).
may_ask(mio_north, whether, route).
may_ask(mio_north, why, route).
may_ask(mio_north, when, route).
may_ask(mio_north, which, route).
competent(mio_north, threat).
willing(mio_north, threat, brief).
may_ask(mio_north, where, threat).
may_ask(mio_north, what, threat).
may_ask(mio_north, who, threat).
may_ask(mio_north, how, threat).
may_ask(mio_north, whether, threat).
may_ask(mio_north, why, threat).
may_ask(mio_north, when, threat).
may_ask(mio_north, which, threat).
competent(mio_north, trade).
willing(mio_north, trade, brief).
may_ask(mio_north, where, trade).
may_ask(mio_north, what, trade).
may_ask(mio_north, who, trade).
may_ask(mio_north, how, trade).
may_ask(mio_north, whether, trade).
may_ask(mio_north, why, trade).
may_ask(mio_north, when, trade).
may_ask(mio_north, which, trade).
competent(mio_north, health).
willing(mio_north, health, brief).
may_ask(mio_north, where, health).
may_ask(mio_north, what, health).
may_ask(mio_north, who, health).
may_ask(mio_north, how, health).
may_ask(mio_north, whether, health).
may_ask(mio_north, why, health).
may_ask(mio_north, when, health).
may_ask(mio_north, which, health).
stock(mio_north, greet, [hello, from, hall_north]).
stock(mio_north, close, [farewell, from, mio_north]).
competent(mio_south, threat).
willing(mio_south, threat, brief).
may_ask(mio_south, where, threat).
may_ask(mio_south, what, threat).
may_ask(mio_south, who, threat).
may_ask(mio_south, how, threat).
may_ask(mio_south, whether, threat).
may_ask(mio_south, why, threat).
may_ask(mio_south, when, threat).
may_ask(mio_south, which, threat).
competent(mio_south, trade).
willing(mio_south, trade, brief).
may_ask(mio_south, where, trade).
may_ask(mio_south, what, trade).
may_ask(mio_south, who, trade).
may_ask(mio_south, how, trade).
may_ask(mio_south, whether, trade).
may_ask(mio_south, why, trade).
may_ask(mio_south, when, trade).
may_ask(mio_south, which, trade).
competent(mio_south, health).
willing(mio_south, health, brief).
may_ask(mio_south, where, health).
may_ask(mio_south, what, health).
may_ask(mio_south, who, health).
may_ask(mio_south, how, health).
may_ask(mio_south, whether, health).
may_ask(mio_south, why, health).
may_ask(mio_south, when, health).
may_ask(mio_south, which, health).
competent(mio_south, archive).
willing(mio_south, archive, brief).
may_ask(mio_south, where, archive).
may_ask(mio_south, what, archive).
may_ask(mio_south, who, archive).
may_ask(mio_south, how, archive).
may_ask(mio_south, whether, archive).
may_ask(mio_south, why, archive).
may_ask(mio_south, when, archive).
may_ask(mio_south, which, archive).
stock(mio_south, greet, [hello, from, hall_south]).
stock(mio_south, close, [farewell, from, mio_south]).
competent(mio_east, gold).
willing(mio_east, gold, brief).
may_ask(mio_east, where, gold).
may_ask(mio_east, what, gold).
may_ask(mio_east, who, gold).
may_ask(mio_east, how, gold).
may_ask(mio_east, whether, gold).
may_ask(mio_east, why, gold).
may_ask(mio_east, when, gold).
may_ask(mio_east, which, gold).
competent(mio_east, map).
willing(mio_east, map, brief).
may_ask(mio_east, where, map).
may_ask(mio_east, what, map).
may_ask(mio_east, who, map).
may_ask(mio_east, how, map).
may_ask(mio_east, whether, map).
may_ask(mio_east, why, map).
may_ask(mio_east, when, map).
may_ask(mio_east, which, map).
competent(mio_east, route).
willing(mio_east, route, brief).
may_ask(mio_east, where, route).
may_ask(mio_east, what, route).
may_ask(mio_east, who, route).
may_ask(mio_east, how, route).
may_ask(mio_east, whether, route).
may_ask(mio_east, why, route).
may_ask(mio_east, when, route).
may_ask(mio_east, which, route).
competent(mio_east, threat).
willing(mio_east, threat, brief).
may_ask(mio_east, where, threat).
may_ask(mio_east, what, threat).
may_ask(mio_east, who, threat).
may_ask(mio_east, how, threat).
may_ask(mio_east, whether, threat).
may_ask(mio_east, why, threat).
may_ask(mio_east, when, threat).
may_ask(mio_east, which, threat).
stock(mio_east, greet, [hello, from, hall_east]).
stock(mio_east, close, [farewell, from, mio_east]).
competent(ned_north, gold).
willing(ned_north, gold, cautious).
may_ask(ned_north, where, gold).
may_ask(ned_north, what, gold).
may_ask(ned_north, who, gold).
may_ask(ned_north, how, gold).
may_ask(ned_north, whether, gold).
may_ask(ned_north, why, gold).
may_ask(ned_north, when, gold).
may_ask(ned_north, which, gold).
competent(ned_north, map).
willing(ned_north, map, cautious).
may_ask(ned_north, where, map).
may_ask(ned_north, what, map).
may_ask(ned_north, who, map).
may_ask(ned_north, how, map).
may_ask(ned_north, whether, map).
may_ask(ned_north, why, map).
may_ask(ned_north, when, map).
may_ask(ned_north, which, map).
competent(ned_north, route).
willing(ned_north, route, cautious).
may_ask(ned_north, where, route).
may_ask(ned_north, what, route).
may_ask(ned_north, who, route).
may_ask(ned_north, how, route).
may_ask(ned_north, whether, route).
may_ask(ned_north, why, route).
may_ask(ned_north, when, route).
may_ask(ned_north, which, route).
competent(ned_north, threat).
willing(ned_north, threat, cautious).
may_ask(ned_north, where, threat).
may_ask(ned_north, what, threat).
may_ask(ned_north, who, threat).
may_ask(ned_north, how, threat).
may_ask(ned_north, whether, threat).
may_ask(ned_north, why, threat).
may_ask(ned_north, when, threat).
may_ask(ned_north, which, threat).
stock(ned_north, greet, [hello, from, gate_north]).
stock(ned_north, close, [farewell, from, ned_north]).
competent(ned_south, trade).
willing(ned_south, trade, cautious).
may_ask(ned_south, where, trade).
may_ask(ned_south, what, trade).
may_ask(ned_south, who, trade).
may_ask(ned_south, how, trade).
may_ask(ned_south, whether, trade).
may_ask(ned_south, why, trade).
may_ask(ned_south, when, trade).
may_ask(ned_south, which, trade).
competent(ned_south, health).
willing(ned_south, health, cautious).
may_ask(ned_south, where, health).
may_ask(ned_south, what, health).
may_ask(ned_south, who, health).
may_ask(ned_south, how, health).
may_ask(ned_south, whether, health).
may_ask(ned_south, why, health).
may_ask(ned_south, when, health).
may_ask(ned_south, which, health).
competent(ned_south, archive).
willing(ned_south, archive, cautious).
may_ask(ned_south, where, archive).
may_ask(ned_south, what, archive).
may_ask(ned_south, who, archive).
may_ask(ned_south, how, archive).
may_ask(ned_south, whether, archive).
may_ask(ned_south, why, archive).
may_ask(ned_south, when, archive).
may_ask(ned_south, which, archive).
competent(ned_south, weather).
willing(ned_south, weather, cautious).
may_ask(ned_south, where, weather).
may_ask(ned_south, what, weather).
may_ask(ned_south, who, weather).
may_ask(ned_south, how, weather).
may_ask(ned_south, whether, weather).
may_ask(ned_south, why, weather).
may_ask(ned_south, when, weather).
may_ask(ned_south, which, weather).
stock(ned_south, greet, [hello, from, gate_south]).
stock(ned_south, close, [farewell, from, ned_south]).
competent(ned_east, threat).
willing(ned_east, threat, cautious).
may_ask(ned_east, where, threat).
may_ask(ned_east, what, threat).
may_ask(ned_east, who, threat).
may_ask(ned_east, how, threat).
may_ask(ned_east, whether, threat).
may_ask(ned_east, why, threat).
may_ask(ned_east, when, threat).
may_ask(ned_east, which, threat).
competent(ned_east, trade).
willing(ned_east, trade, cautious).
may_ask(ned_east, where, trade).
may_ask(ned_east, what, trade).
may_ask(ned_east, who, trade).
may_ask(ned_east, how, trade).
may_ask(ned_east, whether, trade).
may_ask(ned_east, why, trade).
may_ask(ned_east, when, trade).
may_ask(ned_east, which, trade).
competent(ned_east, health).
willing(ned_east, health, cautious).
may_ask(ned_east, where, health).
may_ask(ned_east, what, health).
may_ask(ned_east, who, health).
may_ask(ned_east, how, health).
may_ask(ned_east, whether, health).
may_ask(ned_east, why, health).
may_ask(ned_east, when, health).
may_ask(ned_east, which, health).
competent(ned_east, archive).
willing(ned_east, archive, cautious).
may_ask(ned_east, where, archive).
may_ask(ned_east, what, archive).
may_ask(ned_east, who, archive).
may_ask(ned_east, how, archive).
may_ask(ned_east, whether, archive).
may_ask(ned_east, why, archive).
may_ask(ned_east, when, archive).
may_ask(ned_east, which, archive).
stock(ned_east, greet, [hello, from, gate_east]).
stock(ned_east, close, [farewell, from, ned_east]).
competent(ora_north, threat).
willing(ora_north, threat, urgent).
may_ask(ora_north, where, threat).
may_ask(ora_north, what, threat).
may_ask(ora_north, who, threat).
may_ask(ora_north, how, threat).
may_ask(ora_north, whether, threat).
may_ask(ora_north, why, threat).
may_ask(ora_north, when, threat).
may_ask(ora_north, which, threat).
competent(ora_north, trade).
willing(ora_north, trade, urgent).
may_ask(ora_north, where, trade).
may_ask(ora_north, what, trade).
may_ask(ora_north, who, trade).
may_ask(ora_north, how, trade).
may_ask(ora_north, whether, trade).
may_ask(ora_north, why, trade).
may_ask(ora_north, when, trade).
may_ask(ora_north, which, trade).
competent(ora_north, health).
willing(ora_north, health, urgent).
may_ask(ora_north, where, health).
may_ask(ora_north, what, health).
may_ask(ora_north, who, health).
may_ask(ora_north, how, health).
may_ask(ora_north, whether, health).
may_ask(ora_north, why, health).
may_ask(ora_north, when, health).
may_ask(ora_north, which, health).
competent(ora_north, archive).
willing(ora_north, archive, urgent).
may_ask(ora_north, where, archive).
may_ask(ora_north, what, archive).
may_ask(ora_north, who, archive).
may_ask(ora_north, how, archive).
may_ask(ora_north, whether, archive).
may_ask(ora_north, why, archive).
may_ask(ora_north, when, archive).
may_ask(ora_north, which, archive).
stock(ora_north, greet, [hello, from, market_north]).
stock(ora_north, close, [farewell, from, ora_north]).
competent(ora_south, trade).
willing(ora_south, trade, urgent).
may_ask(ora_south, where, trade).
may_ask(ora_south, what, trade).
may_ask(ora_south, who, trade).
may_ask(ora_south, how, trade).
may_ask(ora_south, whether, trade).
may_ask(ora_south, why, trade).
may_ask(ora_south, when, trade).
may_ask(ora_south, which, trade).
competent(ora_south, health).
willing(ora_south, health, urgent).
may_ask(ora_south, where, health).
may_ask(ora_south, what, health).
may_ask(ora_south, who, health).
may_ask(ora_south, how, health).
may_ask(ora_south, whether, health).
may_ask(ora_south, why, health).
may_ask(ora_south, when, health).
may_ask(ora_south, which, health).
competent(ora_south, archive).
willing(ora_south, archive, urgent).
may_ask(ora_south, where, archive).
may_ask(ora_south, what, archive).
may_ask(ora_south, who, archive).
may_ask(ora_south, how, archive).
may_ask(ora_south, whether, archive).
may_ask(ora_south, why, archive).
may_ask(ora_south, when, archive).
may_ask(ora_south, which, archive).
competent(ora_south, weather).
willing(ora_south, weather, urgent).
may_ask(ora_south, where, weather).
may_ask(ora_south, what, weather).
may_ask(ora_south, who, weather).
may_ask(ora_south, how, weather).
may_ask(ora_south, whether, weather).
may_ask(ora_south, why, weather).
may_ask(ora_south, when, weather).
may_ask(ora_south, which, weather).
stock(ora_south, greet, [hello, from, market_south]).
stock(ora_south, close, [farewell, from, ora_south]).
competent(ora_east, route).
willing(ora_east, route, urgent).
may_ask(ora_east, where, route).
may_ask(ora_east, what, route).
may_ask(ora_east, who, route).
may_ask(ora_east, how, route).
may_ask(ora_east, whether, route).
may_ask(ora_east, why, route).
may_ask(ora_east, when, route).
may_ask(ora_east, which, route).
competent(ora_east, threat).
willing(ora_east, threat, urgent).
may_ask(ora_east, where, threat).
may_ask(ora_east, what, threat).
may_ask(ora_east, who, threat).
may_ask(ora_east, how, threat).
may_ask(ora_east, whether, threat).
may_ask(ora_east, why, threat).
may_ask(ora_east, when, threat).
may_ask(ora_east, which, threat).
competent(ora_east, trade).
willing(ora_east, trade, urgent).
may_ask(ora_east, where, trade).
may_ask(ora_east, what, trade).
may_ask(ora_east, who, trade).
may_ask(ora_east, how, trade).
may_ask(ora_east, whether, trade).
may_ask(ora_east, why, trade).
may_ask(ora_east, when, trade).
may_ask(ora_east, which, trade).
competent(ora_east, health).
willing(ora_east, health, urgent).
may_ask(ora_east, where, health).
may_ask(ora_east, what, health).
may_ask(ora_east, who, health).
may_ask(ora_east, how, health).
may_ask(ora_east, whether, health).
may_ask(ora_east, why, health).
may_ask(ora_east, when, health).
may_ask(ora_east, which, health).
stock(ora_east, greet, [hello, from, market_east]).
stock(ora_east, close, [farewell, from, ora_east]).
competent(pim_north, trade).
willing(pim_north, trade, formal).
may_ask(pim_north, where, trade).
may_ask(pim_north, what, trade).
may_ask(pim_north, who, trade).
may_ask(pim_north, how, trade).
may_ask(pim_north, whether, trade).
may_ask(pim_north, why, trade).
may_ask(pim_north, when, trade).
may_ask(pim_north, which, trade).
competent(pim_north, health).
willing(pim_north, health, formal).
may_ask(pim_north, where, health).
may_ask(pim_north, what, health).
may_ask(pim_north, who, health).
may_ask(pim_north, how, health).
may_ask(pim_north, whether, health).
may_ask(pim_north, why, health).
may_ask(pim_north, when, health).
may_ask(pim_north, which, health).
competent(pim_north, archive).
willing(pim_north, archive, formal).
may_ask(pim_north, where, archive).
may_ask(pim_north, what, archive).
may_ask(pim_north, who, archive).
may_ask(pim_north, how, archive).
may_ask(pim_north, whether, archive).
may_ask(pim_north, why, archive).
may_ask(pim_north, when, archive).
may_ask(pim_north, which, archive).
competent(pim_north, weather).
willing(pim_north, weather, formal).
may_ask(pim_north, where, weather).
may_ask(pim_north, what, weather).
may_ask(pim_north, who, weather).
may_ask(pim_north, how, weather).
may_ask(pim_north, whether, weather).
may_ask(pim_north, why, weather).
may_ask(pim_north, when, weather).
may_ask(pim_north, which, weather).
stock(pim_north, greet, [hello, from, dock_north]).
stock(pim_north, close, [farewell, from, pim_north]).
competent(pim_south, map).
willing(pim_south, map, formal).
may_ask(pim_south, where, map).
may_ask(pim_south, what, map).
may_ask(pim_south, who, map).
may_ask(pim_south, how, map).
may_ask(pim_south, whether, map).
may_ask(pim_south, why, map).
may_ask(pim_south, when, map).
may_ask(pim_south, which, map).
competent(pim_south, route).
willing(pim_south, route, formal).
may_ask(pim_south, where, route).
may_ask(pim_south, what, route).
may_ask(pim_south, who, route).
may_ask(pim_south, how, route).
may_ask(pim_south, whether, route).
may_ask(pim_south, why, route).
may_ask(pim_south, when, route).
may_ask(pim_south, which, route).
competent(pim_south, threat).
willing(pim_south, threat, formal).
may_ask(pim_south, where, threat).
may_ask(pim_south, what, threat).
may_ask(pim_south, who, threat).
may_ask(pim_south, how, threat).
may_ask(pim_south, whether, threat).
may_ask(pim_south, why, threat).
may_ask(pim_south, when, threat).
may_ask(pim_south, which, threat).
competent(pim_south, trade).
willing(pim_south, trade, formal).
may_ask(pim_south, where, trade).
may_ask(pim_south, what, trade).
may_ask(pim_south, who, trade).
may_ask(pim_south, how, trade).
may_ask(pim_south, whether, trade).
may_ask(pim_south, why, trade).
may_ask(pim_south, when, trade).
may_ask(pim_south, which, trade).
stock(pim_south, greet, [hello, from, dock_south]).
stock(pim_south, close, [farewell, from, pim_south]).
competent(pim_east, gold).
willing(pim_east, gold, formal).
may_ask(pim_east, where, gold).
may_ask(pim_east, what, gold).
may_ask(pim_east, who, gold).
may_ask(pim_east, how, gold).
may_ask(pim_east, whether, gold).
may_ask(pim_east, why, gold).
may_ask(pim_east, when, gold).
may_ask(pim_east, which, gold).
competent(pim_east, map).
willing(pim_east, map, formal).
may_ask(pim_east, where, map).
may_ask(pim_east, what, map).
may_ask(pim_east, who, map).
may_ask(pim_east, how, map).
may_ask(pim_east, whether, map).
may_ask(pim_east, why, map).
may_ask(pim_east, when, map).
may_ask(pim_east, which, map).
competent(pim_east, route).
willing(pim_east, route, formal).
may_ask(pim_east, where, route).
may_ask(pim_east, what, route).
may_ask(pim_east, who, route).
may_ask(pim_east, how, route).
may_ask(pim_east, whether, route).
may_ask(pim_east, why, route).
may_ask(pim_east, when, route).
may_ask(pim_east, which, route).
competent(pim_east, threat).
willing(pim_east, threat, formal).
may_ask(pim_east, where, threat).
may_ask(pim_east, what, threat).
may_ask(pim_east, who, threat).
may_ask(pim_east, how, threat).
may_ask(pim_east, whether, threat).
may_ask(pim_east, why, threat).
may_ask(pim_east, when, threat).
may_ask(pim_east, which, threat).
stock(pim_east, greet, [hello, from, dock_east]).
stock(pim_east, close, [farewell, from, pim_east]).
competent(quin_north, route).
willing(quin_north, route, plain).
may_ask(quin_north, where, route).
may_ask(quin_north, what, route).
may_ask(quin_north, who, route).
may_ask(quin_north, how, route).
may_ask(quin_north, whether, route).
may_ask(quin_north, why, route).
may_ask(quin_north, when, route).
may_ask(quin_north, which, route).
competent(quin_north, threat).
willing(quin_north, threat, plain).
may_ask(quin_north, where, threat).
may_ask(quin_north, what, threat).
may_ask(quin_north, who, threat).
may_ask(quin_north, how, threat).
may_ask(quin_north, whether, threat).
may_ask(quin_north, why, threat).
may_ask(quin_north, when, threat).
may_ask(quin_north, which, threat).
competent(quin_north, trade).
willing(quin_north, trade, plain).
may_ask(quin_north, where, trade).
may_ask(quin_north, what, trade).
may_ask(quin_north, who, trade).
may_ask(quin_north, how, trade).
may_ask(quin_north, whether, trade).
may_ask(quin_north, why, trade).
may_ask(quin_north, when, trade).
may_ask(quin_north, which, trade).
competent(quin_north, health).
willing(quin_north, health, plain).
may_ask(quin_north, where, health).
may_ask(quin_north, what, health).
may_ask(quin_north, who, health).
may_ask(quin_north, how, health).
may_ask(quin_north, whether, health).
may_ask(quin_north, why, health).
may_ask(quin_north, when, health).
may_ask(quin_north, which, health).
stock(quin_north, greet, [hello, from, archive_north]).
stock(quin_north, close, [farewell, from, quin_north]).
competent(quin_south, threat).
willing(quin_south, threat, plain).
may_ask(quin_south, where, threat).
may_ask(quin_south, what, threat).
may_ask(quin_south, who, threat).
may_ask(quin_south, how, threat).
may_ask(quin_south, whether, threat).
may_ask(quin_south, why, threat).
may_ask(quin_south, when, threat).
may_ask(quin_south, which, threat).
competent(quin_south, trade).
willing(quin_south, trade, plain).
may_ask(quin_south, where, trade).
may_ask(quin_south, what, trade).
may_ask(quin_south, who, trade).
may_ask(quin_south, how, trade).
may_ask(quin_south, whether, trade).
may_ask(quin_south, why, trade).
may_ask(quin_south, when, trade).
may_ask(quin_south, which, trade).
competent(quin_south, health).
willing(quin_south, health, plain).
may_ask(quin_south, where, health).
may_ask(quin_south, what, health).
may_ask(quin_south, who, health).
may_ask(quin_south, how, health).
may_ask(quin_south, whether, health).
may_ask(quin_south, why, health).
may_ask(quin_south, when, health).
may_ask(quin_south, which, health).
competent(quin_south, archive).
willing(quin_south, archive, plain).
may_ask(quin_south, where, archive).
may_ask(quin_south, what, archive).
may_ask(quin_south, who, archive).
may_ask(quin_south, how, archive).
may_ask(quin_south, whether, archive).
may_ask(quin_south, why, archive).
may_ask(quin_south, when, archive).
may_ask(quin_south, which, archive).
stock(quin_south, greet, [hello, from, archive_south]).
stock(quin_south, close, [farewell, from, quin_south]).
competent(quin_east, gold).
willing(quin_east, gold, plain).
may_ask(quin_east, where, gold).
may_ask(quin_east, what, gold).
may_ask(quin_east, who, gold).
may_ask(quin_east, how, gold).
may_ask(quin_east, whether, gold).
may_ask(quin_east, why, gold).
may_ask(quin_east, when, gold).
may_ask(quin_east, which, gold).
competent(quin_east, map).
willing(quin_east, map, plain).
may_ask(quin_east, where, map).
may_ask(quin_east, what, map).
may_ask(quin_east, who, map).
may_ask(quin_east, how, map).
may_ask(quin_east, whether, map).
may_ask(quin_east, why, map).
may_ask(quin_east, when, map).
may_ask(quin_east, which, map).
competent(quin_east, route).
willing(quin_east, route, plain).
may_ask(quin_east, where, route).
may_ask(quin_east, what, route).
may_ask(quin_east, who, route).
may_ask(quin_east, how, route).
may_ask(quin_east, whether, route).
may_ask(quin_east, why, route).
may_ask(quin_east, when, route).
may_ask(quin_east, which, route).
competent(quin_east, threat).
willing(quin_east, threat, plain).
may_ask(quin_east, where, threat).
may_ask(quin_east, what, threat).
may_ask(quin_east, who, threat).
may_ask(quin_east, how, threat).
may_ask(quin_east, whether, threat).
may_ask(quin_east, why, threat).
may_ask(quin_east, when, threat).
may_ask(quin_east, which, threat).
stock(quin_east, greet, [hello, from, archive_east]).
stock(quin_east, close, [farewell, from, quin_east]).
competent(rae_north, threat).
willing(rae_north, threat, brief).
may_ask(rae_north, where, threat).
may_ask(rae_north, what, threat).
may_ask(rae_north, who, threat).
may_ask(rae_north, how, threat).
may_ask(rae_north, whether, threat).
may_ask(rae_north, why, threat).
may_ask(rae_north, when, threat).
may_ask(rae_north, which, threat).
competent(rae_north, trade).
willing(rae_north, trade, brief).
may_ask(rae_north, where, trade).
may_ask(rae_north, what, trade).
may_ask(rae_north, who, trade).
may_ask(rae_north, how, trade).
may_ask(rae_north, whether, trade).
may_ask(rae_north, why, trade).
may_ask(rae_north, when, trade).
may_ask(rae_north, which, trade).
competent(rae_north, health).
willing(rae_north, health, brief).
may_ask(rae_north, where, health).
may_ask(rae_north, what, health).
may_ask(rae_north, who, health).
may_ask(rae_north, how, health).
may_ask(rae_north, whether, health).
may_ask(rae_north, why, health).
may_ask(rae_north, when, health).
may_ask(rae_north, which, health).
competent(rae_north, archive).
willing(rae_north, archive, brief).
may_ask(rae_north, where, archive).
may_ask(rae_north, what, archive).
may_ask(rae_north, who, archive).
may_ask(rae_north, how, archive).
may_ask(rae_north, whether, archive).
may_ask(rae_north, why, archive).
may_ask(rae_north, when, archive).
may_ask(rae_north, which, archive).
stock(rae_north, greet, [hello, from, clinic_north]).
stock(rae_north, close, [farewell, from, rae_north]).
competent(rae_south, map).
willing(rae_south, map, brief).
may_ask(rae_south, where, map).
may_ask(rae_south, what, map).
may_ask(rae_south, who, map).
may_ask(rae_south, how, map).
may_ask(rae_south, whether, map).
may_ask(rae_south, why, map).
may_ask(rae_south, when, map).
may_ask(rae_south, which, map).
competent(rae_south, route).
willing(rae_south, route, brief).
may_ask(rae_south, where, route).
may_ask(rae_south, what, route).
may_ask(rae_south, who, route).
may_ask(rae_south, how, route).
may_ask(rae_south, whether, route).
may_ask(rae_south, why, route).
may_ask(rae_south, when, route).
may_ask(rae_south, which, route).
competent(rae_south, threat).
willing(rae_south, threat, brief).
may_ask(rae_south, where, threat).
may_ask(rae_south, what, threat).
may_ask(rae_south, who, threat).
may_ask(rae_south, how, threat).
may_ask(rae_south, whether, threat).
may_ask(rae_south, why, threat).
may_ask(rae_south, when, threat).
may_ask(rae_south, which, threat).
competent(rae_south, trade).
willing(rae_south, trade, brief).
may_ask(rae_south, where, trade).
may_ask(rae_south, what, trade).
may_ask(rae_south, who, trade).
may_ask(rae_south, how, trade).
may_ask(rae_south, whether, trade).
may_ask(rae_south, why, trade).
may_ask(rae_south, when, trade).
may_ask(rae_south, which, trade).
stock(rae_south, greet, [hello, from, clinic_south]).
stock(rae_south, close, [farewell, from, rae_south]).
competent(rae_east, threat).
willing(rae_east, threat, brief).
may_ask(rae_east, where, threat).
may_ask(rae_east, what, threat).
may_ask(rae_east, who, threat).
may_ask(rae_east, how, threat).
may_ask(rae_east, whether, threat).
may_ask(rae_east, why, threat).
may_ask(rae_east, when, threat).
may_ask(rae_east, which, threat).
competent(rae_east, trade).
willing(rae_east, trade, brief).
may_ask(rae_east, where, trade).
may_ask(rae_east, what, trade).
may_ask(rae_east, who, trade).
may_ask(rae_east, how, trade).
may_ask(rae_east, whether, trade).
may_ask(rae_east, why, trade).
may_ask(rae_east, when, trade).
may_ask(rae_east, which, trade).
competent(rae_east, health).
willing(rae_east, health, brief).
may_ask(rae_east, where, health).
may_ask(rae_east, what, health).
may_ask(rae_east, who, health).
may_ask(rae_east, how, health).
may_ask(rae_east, whether, health).
may_ask(rae_east, why, health).
may_ask(rae_east, when, health).
may_ask(rae_east, which, health).
competent(rae_east, archive).
willing(rae_east, archive, brief).
may_ask(rae_east, where, archive).
may_ask(rae_east, what, archive).
may_ask(rae_east, who, archive).
may_ask(rae_east, how, archive).
may_ask(rae_east, whether, archive).
may_ask(rae_east, why, archive).
may_ask(rae_east, when, archive).
may_ask(rae_east, which, archive).
stock(rae_east, greet, [hello, from, clinic_east]).
stock(rae_east, close, [farewell, from, rae_east]).
competent(sol_north, route).
willing(sol_north, route, cautious).
may_ask(sol_north, where, route).
may_ask(sol_north, what, route).
may_ask(sol_north, who, route).
may_ask(sol_north, how, route).
may_ask(sol_north, whether, route).
may_ask(sol_north, why, route).
may_ask(sol_north, when, route).
may_ask(sol_north, which, route).
competent(sol_north, threat).
willing(sol_north, threat, cautious).
may_ask(sol_north, where, threat).
may_ask(sol_north, what, threat).
may_ask(sol_north, who, threat).
may_ask(sol_north, how, threat).
may_ask(sol_north, whether, threat).
may_ask(sol_north, why, threat).
may_ask(sol_north, when, threat).
may_ask(sol_north, which, threat).
competent(sol_north, trade).
willing(sol_north, trade, cautious).
may_ask(sol_north, where, trade).
may_ask(sol_north, what, trade).
may_ask(sol_north, who, trade).
may_ask(sol_north, how, trade).
may_ask(sol_north, whether, trade).
may_ask(sol_north, why, trade).
may_ask(sol_north, when, trade).
may_ask(sol_north, which, trade).
competent(sol_north, health).
willing(sol_north, health, cautious).
may_ask(sol_north, where, health).
may_ask(sol_north, what, health).
may_ask(sol_north, who, health).
may_ask(sol_north, how, health).
may_ask(sol_north, whether, health).
may_ask(sol_north, why, health).
may_ask(sol_north, when, health).
may_ask(sol_north, which, health).
stock(sol_north, greet, [hello, from, tower_north]).
stock(sol_north, close, [farewell, from, sol_north]).
competent(sol_south, route).
willing(sol_south, route, cautious).
may_ask(sol_south, where, route).
may_ask(sol_south, what, route).
may_ask(sol_south, who, route).
may_ask(sol_south, how, route).
may_ask(sol_south, whether, route).
may_ask(sol_south, why, route).
may_ask(sol_south, when, route).
may_ask(sol_south, which, route).
competent(sol_south, threat).
willing(sol_south, threat, cautious).
may_ask(sol_south, where, threat).
may_ask(sol_south, what, threat).
may_ask(sol_south, who, threat).
may_ask(sol_south, how, threat).
may_ask(sol_south, whether, threat).
may_ask(sol_south, why, threat).
may_ask(sol_south, when, threat).
may_ask(sol_south, which, threat).
competent(sol_south, trade).
willing(sol_south, trade, cautious).
may_ask(sol_south, where, trade).
may_ask(sol_south, what, trade).
may_ask(sol_south, who, trade).
may_ask(sol_south, how, trade).
may_ask(sol_south, whether, trade).
may_ask(sol_south, why, trade).
may_ask(sol_south, when, trade).
may_ask(sol_south, which, trade).
competent(sol_south, health).
willing(sol_south, health, cautious).
may_ask(sol_south, where, health).
may_ask(sol_south, what, health).
may_ask(sol_south, who, health).
may_ask(sol_south, how, health).
may_ask(sol_south, whether, health).
may_ask(sol_south, why, health).
may_ask(sol_south, when, health).
may_ask(sol_south, which, health).
stock(sol_south, greet, [hello, from, tower_south]).
stock(sol_south, close, [farewell, from, sol_south]).
competent(sol_east, threat).
willing(sol_east, threat, cautious).
may_ask(sol_east, where, threat).
may_ask(sol_east, what, threat).
may_ask(sol_east, who, threat).
may_ask(sol_east, how, threat).
may_ask(sol_east, whether, threat).
may_ask(sol_east, why, threat).
may_ask(sol_east, when, threat).
may_ask(sol_east, which, threat).
competent(sol_east, trade).
willing(sol_east, trade, cautious).
may_ask(sol_east, where, trade).
may_ask(sol_east, what, trade).
may_ask(sol_east, who, trade).
may_ask(sol_east, how, trade).
may_ask(sol_east, whether, trade).
may_ask(sol_east, why, trade).
may_ask(sol_east, when, trade).
may_ask(sol_east, which, trade).
competent(sol_east, health).
willing(sol_east, health, cautious).
may_ask(sol_east, where, health).
may_ask(sol_east, what, health).
may_ask(sol_east, who, health).
may_ask(sol_east, how, health).
may_ask(sol_east, whether, health).
may_ask(sol_east, why, health).
may_ask(sol_east, when, health).
may_ask(sol_east, which, health).
competent(sol_east, archive).
willing(sol_east, archive, cautious).
may_ask(sol_east, where, archive).
may_ask(sol_east, what, archive).
may_ask(sol_east, who, archive).
may_ask(sol_east, how, archive).
may_ask(sol_east, whether, archive).
may_ask(sol_east, why, archive).
may_ask(sol_east, when, archive).
may_ask(sol_east, which, archive).
stock(sol_east, greet, [hello, from, tower_east]).
stock(sol_east, close, [farewell, from, sol_east]).
competent(tia_north, map).
willing(tia_north, map, urgent).
may_ask(tia_north, where, map).
may_ask(tia_north, what, map).
may_ask(tia_north, who, map).
may_ask(tia_north, how, map).
may_ask(tia_north, whether, map).
may_ask(tia_north, why, map).
may_ask(tia_north, when, map).
may_ask(tia_north, which, map).
competent(tia_north, route).
willing(tia_north, route, urgent).
may_ask(tia_north, where, route).
may_ask(tia_north, what, route).
may_ask(tia_north, who, route).
may_ask(tia_north, how, route).
may_ask(tia_north, whether, route).
may_ask(tia_north, why, route).
may_ask(tia_north, when, route).
may_ask(tia_north, which, route).
competent(tia_north, threat).
willing(tia_north, threat, urgent).
may_ask(tia_north, where, threat).
may_ask(tia_north, what, threat).
may_ask(tia_north, who, threat).
may_ask(tia_north, how, threat).
may_ask(tia_north, whether, threat).
may_ask(tia_north, why, threat).
may_ask(tia_north, when, threat).
may_ask(tia_north, which, threat).
competent(tia_north, trade).
willing(tia_north, trade, urgent).
may_ask(tia_north, where, trade).
may_ask(tia_north, what, trade).
may_ask(tia_north, who, trade).
may_ask(tia_north, how, trade).
may_ask(tia_north, whether, trade).
may_ask(tia_north, why, trade).
may_ask(tia_north, when, trade).
may_ask(tia_north, which, trade).
stock(tia_north, greet, [hello, from, yard_north]).
stock(tia_north, close, [farewell, from, tia_north]).
competent(tia_south, gold).
willing(tia_south, gold, urgent).
may_ask(tia_south, where, gold).
may_ask(tia_south, what, gold).
may_ask(tia_south, who, gold).
may_ask(tia_south, how, gold).
may_ask(tia_south, whether, gold).
may_ask(tia_south, why, gold).
may_ask(tia_south, when, gold).
may_ask(tia_south, which, gold).
competent(tia_south, map).
willing(tia_south, map, urgent).
may_ask(tia_south, where, map).
may_ask(tia_south, what, map).
may_ask(tia_south, who, map).
may_ask(tia_south, how, map).
may_ask(tia_south, whether, map).
may_ask(tia_south, why, map).
may_ask(tia_south, when, map).
may_ask(tia_south, which, map).
competent(tia_south, route).
willing(tia_south, route, urgent).
may_ask(tia_south, where, route).
may_ask(tia_south, what, route).
may_ask(tia_south, who, route).
may_ask(tia_south, how, route).
may_ask(tia_south, whether, route).
may_ask(tia_south, why, route).
may_ask(tia_south, when, route).
may_ask(tia_south, which, route).
competent(tia_south, threat).
willing(tia_south, threat, urgent).
may_ask(tia_south, where, threat).
may_ask(tia_south, what, threat).
may_ask(tia_south, who, threat).
may_ask(tia_south, how, threat).
may_ask(tia_south, whether, threat).
may_ask(tia_south, why, threat).
may_ask(tia_south, when, threat).
may_ask(tia_south, which, threat).
stock(tia_south, greet, [hello, from, yard_south]).
stock(tia_south, close, [farewell, from, tia_south]).
competent(tia_east, threat).
willing(tia_east, threat, urgent).
may_ask(tia_east, where, threat).
may_ask(tia_east, what, threat).
may_ask(tia_east, who, threat).
may_ask(tia_east, how, threat).
may_ask(tia_east, whether, threat).
may_ask(tia_east, why, threat).
may_ask(tia_east, when, threat).
may_ask(tia_east, which, threat).
competent(tia_east, trade).
willing(tia_east, trade, urgent).
may_ask(tia_east, where, trade).
may_ask(tia_east, what, trade).
may_ask(tia_east, who, trade).
may_ask(tia_east, how, trade).
may_ask(tia_east, whether, trade).
may_ask(tia_east, why, trade).
may_ask(tia_east, when, trade).
may_ask(tia_east, which, trade).
competent(tia_east, health).
willing(tia_east, health, urgent).
may_ask(tia_east, where, health).
may_ask(tia_east, what, health).
may_ask(tia_east, who, health).
may_ask(tia_east, how, health).
may_ask(tia_east, whether, health).
may_ask(tia_east, why, health).
may_ask(tia_east, when, health).
may_ask(tia_east, which, health).
competent(tia_east, archive).
willing(tia_east, archive, urgent).
may_ask(tia_east, where, archive).
may_ask(tia_east, what, archive).
may_ask(tia_east, who, archive).
may_ask(tia_east, how, archive).
may_ask(tia_east, whether, archive).
may_ask(tia_east, why, archive).
may_ask(tia_east, when, archive).
may_ask(tia_east, which, archive).
stock(tia_east, greet, [hello, from, yard_east]).
stock(tia_east, close, [farewell, from, tia_east]).
competent(uma_north, gold).
willing(uma_north, gold, formal).
may_ask(uma_north, where, gold).
may_ask(uma_north, what, gold).
may_ask(uma_north, who, gold).
may_ask(uma_north, how, gold).
may_ask(uma_north, whether, gold).
may_ask(uma_north, why, gold).
may_ask(uma_north, when, gold).
may_ask(uma_north, which, gold).
competent(uma_north, map).
willing(uma_north, map, formal).
may_ask(uma_north, where, map).
may_ask(uma_north, what, map).
may_ask(uma_north, who, map).
may_ask(uma_north, how, map).
may_ask(uma_north, whether, map).
may_ask(uma_north, why, map).
may_ask(uma_north, when, map).
may_ask(uma_north, which, map).
competent(uma_north, route).
willing(uma_north, route, formal).
may_ask(uma_north, where, route).
may_ask(uma_north, what, route).
may_ask(uma_north, who, route).
may_ask(uma_north, how, route).
may_ask(uma_north, whether, route).
may_ask(uma_north, why, route).
may_ask(uma_north, when, route).
may_ask(uma_north, which, route).
competent(uma_north, threat).
willing(uma_north, threat, formal).
may_ask(uma_north, where, threat).
may_ask(uma_north, what, threat).
may_ask(uma_north, who, threat).
may_ask(uma_north, how, threat).
may_ask(uma_north, whether, threat).
may_ask(uma_north, why, threat).
may_ask(uma_north, when, threat).
may_ask(uma_north, which, threat).
stock(uma_north, greet, [hello, from, road_north]).
stock(uma_north, close, [farewell, from, uma_north]).
competent(uma_south, gold).
willing(uma_south, gold, formal).
may_ask(uma_south, where, gold).
may_ask(uma_south, what, gold).
may_ask(uma_south, who, gold).
may_ask(uma_south, how, gold).
may_ask(uma_south, whether, gold).
may_ask(uma_south, why, gold).
may_ask(uma_south, when, gold).
may_ask(uma_south, which, gold).
competent(uma_south, map).
willing(uma_south, map, formal).
may_ask(uma_south, where, map).
may_ask(uma_south, what, map).
may_ask(uma_south, who, map).
may_ask(uma_south, how, map).
may_ask(uma_south, whether, map).
may_ask(uma_south, why, map).
may_ask(uma_south, when, map).
may_ask(uma_south, which, map).
competent(uma_south, route).
willing(uma_south, route, formal).
may_ask(uma_south, where, route).
may_ask(uma_south, what, route).
may_ask(uma_south, who, route).
may_ask(uma_south, how, route).
may_ask(uma_south, whether, route).
may_ask(uma_south, why, route).
may_ask(uma_south, when, route).
may_ask(uma_south, which, route).
competent(uma_south, threat).
willing(uma_south, threat, formal).
may_ask(uma_south, where, threat).
may_ask(uma_south, what, threat).
may_ask(uma_south, who, threat).
may_ask(uma_south, how, threat).
may_ask(uma_south, whether, threat).
may_ask(uma_south, why, threat).
may_ask(uma_south, when, threat).
may_ask(uma_south, which, threat).
stock(uma_south, greet, [hello, from, road_south]).
stock(uma_south, close, [farewell, from, uma_south]).
competent(uma_east, route).
willing(uma_east, route, formal).
may_ask(uma_east, where, route).
may_ask(uma_east, what, route).
may_ask(uma_east, who, route).
may_ask(uma_east, how, route).
may_ask(uma_east, whether, route).
may_ask(uma_east, why, route).
may_ask(uma_east, when, route).
may_ask(uma_east, which, route).
competent(uma_east, threat).
willing(uma_east, threat, formal).
may_ask(uma_east, where, threat).
may_ask(uma_east, what, threat).
may_ask(uma_east, who, threat).
may_ask(uma_east, how, threat).
may_ask(uma_east, whether, threat).
may_ask(uma_east, why, threat).
may_ask(uma_east, when, threat).
may_ask(uma_east, which, threat).
competent(uma_east, trade).
willing(uma_east, trade, formal).
may_ask(uma_east, where, trade).
may_ask(uma_east, what, trade).
may_ask(uma_east, who, trade).
may_ask(uma_east, how, trade).
may_ask(uma_east, whether, trade).
may_ask(uma_east, why, trade).
may_ask(uma_east, when, trade).
may_ask(uma_east, which, trade).
competent(uma_east, health).
willing(uma_east, health, formal).
may_ask(uma_east, where, health).
may_ask(uma_east, what, health).
may_ask(uma_east, who, health).
may_ask(uma_east, how, health).
may_ask(uma_east, whether, health).
may_ask(uma_east, why, health).
may_ask(uma_east, when, health).
may_ask(uma_east, which, health).
stock(uma_east, greet, [hello, from, road_east]).
stock(uma_east, close, [farewell, from, uma_east]).
competent(vic_north, trade).
willing(vic_north, trade, plain).
may_ask(vic_north, where, trade).
may_ask(vic_north, what, trade).
may_ask(vic_north, who, trade).
may_ask(vic_north, how, trade).
may_ask(vic_north, whether, trade).
may_ask(vic_north, why, trade).
may_ask(vic_north, when, trade).
may_ask(vic_north, which, trade).
competent(vic_north, health).
willing(vic_north, health, plain).
may_ask(vic_north, where, health).
may_ask(vic_north, what, health).
may_ask(vic_north, who, health).
may_ask(vic_north, how, health).
may_ask(vic_north, whether, health).
may_ask(vic_north, why, health).
may_ask(vic_north, when, health).
may_ask(vic_north, which, health).
competent(vic_north, archive).
willing(vic_north, archive, plain).
may_ask(vic_north, where, archive).
may_ask(vic_north, what, archive).
may_ask(vic_north, who, archive).
may_ask(vic_north, how, archive).
may_ask(vic_north, whether, archive).
may_ask(vic_north, why, archive).
may_ask(vic_north, when, archive).
may_ask(vic_north, which, archive).
competent(vic_north, weather).
willing(vic_north, weather, plain).
may_ask(vic_north, where, weather).
may_ask(vic_north, what, weather).
may_ask(vic_north, who, weather).
may_ask(vic_north, how, weather).
may_ask(vic_north, whether, weather).
may_ask(vic_north, why, weather).
may_ask(vic_north, when, weather).
may_ask(vic_north, which, weather).
stock(vic_north, greet, [hello, from, bridge_north]).
stock(vic_north, close, [farewell, from, vic_north]).
competent(vic_south, map).
willing(vic_south, map, plain).
may_ask(vic_south, where, map).
may_ask(vic_south, what, map).
may_ask(vic_south, who, map).
may_ask(vic_south, how, map).
may_ask(vic_south, whether, map).
may_ask(vic_south, why, map).
may_ask(vic_south, when, map).
may_ask(vic_south, which, map).
competent(vic_south, route).
willing(vic_south, route, plain).
may_ask(vic_south, where, route).
may_ask(vic_south, what, route).
may_ask(vic_south, who, route).
may_ask(vic_south, how, route).
may_ask(vic_south, whether, route).
may_ask(vic_south, why, route).
may_ask(vic_south, when, route).
may_ask(vic_south, which, route).
competent(vic_south, threat).
willing(vic_south, threat, plain).
may_ask(vic_south, where, threat).
may_ask(vic_south, what, threat).
may_ask(vic_south, who, threat).
may_ask(vic_south, how, threat).
may_ask(vic_south, whether, threat).
may_ask(vic_south, why, threat).
may_ask(vic_south, when, threat).
may_ask(vic_south, which, threat).
competent(vic_south, trade).
willing(vic_south, trade, plain).
may_ask(vic_south, where, trade).
may_ask(vic_south, what, trade).
may_ask(vic_south, who, trade).
may_ask(vic_south, how, trade).
may_ask(vic_south, whether, trade).
may_ask(vic_south, why, trade).
may_ask(vic_south, when, trade).
may_ask(vic_south, which, trade).
stock(vic_south, greet, [hello, from, bridge_south]).
stock(vic_south, close, [farewell, from, vic_south]).
competent(vic_east, trade).
willing(vic_east, trade, plain).
may_ask(vic_east, where, trade).
may_ask(vic_east, what, trade).
may_ask(vic_east, who, trade).
may_ask(vic_east, how, trade).
may_ask(vic_east, whether, trade).
may_ask(vic_east, why, trade).
may_ask(vic_east, when, trade).
may_ask(vic_east, which, trade).
competent(vic_east, health).
willing(vic_east, health, plain).
may_ask(vic_east, where, health).
may_ask(vic_east, what, health).
may_ask(vic_east, who, health).
may_ask(vic_east, how, health).
may_ask(vic_east, whether, health).
may_ask(vic_east, why, health).
may_ask(vic_east, when, health).
may_ask(vic_east, which, health).
competent(vic_east, archive).
willing(vic_east, archive, plain).
may_ask(vic_east, where, archive).
may_ask(vic_east, what, archive).
may_ask(vic_east, who, archive).
may_ask(vic_east, how, archive).
may_ask(vic_east, whether, archive).
may_ask(vic_east, why, archive).
may_ask(vic_east, when, archive).
may_ask(vic_east, which, archive).
competent(vic_east, weather).
willing(vic_east, weather, plain).
may_ask(vic_east, where, weather).
may_ask(vic_east, what, weather).
may_ask(vic_east, who, weather).
may_ask(vic_east, how, weather).
may_ask(vic_east, whether, weather).
may_ask(vic_east, why, weather).
may_ask(vic_east, when, weather).
may_ask(vic_east, which, weather).
stock(vic_east, greet, [hello, from, bridge_east]).
stock(vic_east, close, [farewell, from, vic_east]).
competent(wren_north, gold).
willing(wren_north, gold, brief).
may_ask(wren_north, where, gold).
may_ask(wren_north, what, gold).
may_ask(wren_north, who, gold).
may_ask(wren_north, how, gold).
may_ask(wren_north, whether, gold).
may_ask(wren_north, why, gold).
may_ask(wren_north, when, gold).
may_ask(wren_north, which, gold).
competent(wren_north, map).
willing(wren_north, map, brief).
may_ask(wren_north, where, map).
may_ask(wren_north, what, map).
may_ask(wren_north, who, map).
may_ask(wren_north, how, map).
may_ask(wren_north, whether, map).
may_ask(wren_north, why, map).
may_ask(wren_north, when, map).
may_ask(wren_north, which, map).
competent(wren_north, route).
willing(wren_north, route, brief).
may_ask(wren_north, where, route).
may_ask(wren_north, what, route).
may_ask(wren_north, who, route).
may_ask(wren_north, how, route).
may_ask(wren_north, whether, route).
may_ask(wren_north, why, route).
may_ask(wren_north, when, route).
may_ask(wren_north, which, route).
competent(wren_north, threat).
willing(wren_north, threat, brief).
may_ask(wren_north, where, threat).
may_ask(wren_north, what, threat).
may_ask(wren_north, who, threat).
may_ask(wren_north, how, threat).
may_ask(wren_north, whether, threat).
may_ask(wren_north, why, threat).
may_ask(wren_north, when, threat).
may_ask(wren_north, which, threat).
stock(wren_north, greet, [hello, from, vault_north]).
stock(wren_north, close, [farewell, from, wren_north]).
competent(wren_south, trade).
willing(wren_south, trade, brief).
may_ask(wren_south, where, trade).
may_ask(wren_south, what, trade).
may_ask(wren_south, who, trade).
may_ask(wren_south, how, trade).
may_ask(wren_south, whether, trade).
may_ask(wren_south, why, trade).
may_ask(wren_south, when, trade).
may_ask(wren_south, which, trade).
competent(wren_south, health).
willing(wren_south, health, brief).
may_ask(wren_south, where, health).
may_ask(wren_south, what, health).
may_ask(wren_south, who, health).
may_ask(wren_south, how, health).
may_ask(wren_south, whether, health).
may_ask(wren_south, why, health).
may_ask(wren_south, when, health).
may_ask(wren_south, which, health).
competent(wren_south, archive).
willing(wren_south, archive, brief).
may_ask(wren_south, where, archive).
may_ask(wren_south, what, archive).
may_ask(wren_south, who, archive).
may_ask(wren_south, how, archive).
may_ask(wren_south, whether, archive).
may_ask(wren_south, why, archive).
may_ask(wren_south, when, archive).
may_ask(wren_south, which, archive).
competent(wren_south, weather).
willing(wren_south, weather, brief).
may_ask(wren_south, where, weather).
may_ask(wren_south, what, weather).
may_ask(wren_south, who, weather).
may_ask(wren_south, how, weather).
may_ask(wren_south, whether, weather).
may_ask(wren_south, why, weather).
may_ask(wren_south, when, weather).
may_ask(wren_south, which, weather).
stock(wren_south, greet, [hello, from, vault_south]).
stock(wren_south, close, [farewell, from, wren_south]).
competent(wren_east, threat).
willing(wren_east, threat, brief).
may_ask(wren_east, where, threat).
may_ask(wren_east, what, threat).
may_ask(wren_east, who, threat).
may_ask(wren_east, how, threat).
may_ask(wren_east, whether, threat).
may_ask(wren_east, why, threat).
may_ask(wren_east, when, threat).
may_ask(wren_east, which, threat).
competent(wren_east, trade).
willing(wren_east, trade, brief).
may_ask(wren_east, where, trade).
may_ask(wren_east, what, trade).
may_ask(wren_east, who, trade).
may_ask(wren_east, how, trade).
may_ask(wren_east, whether, trade).
may_ask(wren_east, why, trade).
may_ask(wren_east, when, trade).
may_ask(wren_east, which, trade).
competent(wren_east, health).
willing(wren_east, health, brief).
may_ask(wren_east, where, health).
may_ask(wren_east, what, health).
may_ask(wren_east, who, health).
may_ask(wren_east, how, health).
may_ask(wren_east, whether, health).
may_ask(wren_east, why, health).
may_ask(wren_east, when, health).
may_ask(wren_east, which, health).
competent(wren_east, archive).
willing(wren_east, archive, brief).
may_ask(wren_east, where, archive).
may_ask(wren_east, what, archive).
may_ask(wren_east, who, archive).
may_ask(wren_east, how, archive).
may_ask(wren_east, whether, archive).
may_ask(wren_east, why, archive).
may_ask(wren_east, when, archive).
may_ask(wren_east, which, archive).
stock(wren_east, greet, [hello, from, vault_east]).
stock(wren_east, close, [farewell, from, wren_east]).
competent(xan_north, threat).
willing(xan_north, threat, cautious).
may_ask(xan_north, where, threat).
may_ask(xan_north, what, threat).
may_ask(xan_north, who, threat).
may_ask(xan_north, how, threat).
may_ask(xan_north, whether, threat).
may_ask(xan_north, why, threat).
may_ask(xan_north, when, threat).
may_ask(xan_north, which, threat).
competent(xan_north, trade).
willing(xan_north, trade, cautious).
may_ask(xan_north, where, trade).
may_ask(xan_north, what, trade).
may_ask(xan_north, who, trade).
may_ask(xan_north, how, trade).
may_ask(xan_north, whether, trade).
may_ask(xan_north, why, trade).
may_ask(xan_north, when, trade).
may_ask(xan_north, which, trade).
competent(xan_north, health).
willing(xan_north, health, cautious).
may_ask(xan_north, where, health).
may_ask(xan_north, what, health).
may_ask(xan_north, who, health).
may_ask(xan_north, how, health).
may_ask(xan_north, whether, health).
may_ask(xan_north, why, health).
may_ask(xan_north, when, health).
may_ask(xan_north, which, health).
competent(xan_north, archive).
willing(xan_north, archive, cautious).
may_ask(xan_north, where, archive).
may_ask(xan_north, what, archive).
may_ask(xan_north, who, archive).
may_ask(xan_north, how, archive).
may_ask(xan_north, whether, archive).
may_ask(xan_north, why, archive).
may_ask(xan_north, when, archive).
may_ask(xan_north, which, archive).
stock(xan_north, greet, [hello, from, maze_north]).
stock(xan_north, close, [farewell, from, xan_north]).
competent(xan_south, threat).
willing(xan_south, threat, cautious).
may_ask(xan_south, where, threat).
may_ask(xan_south, what, threat).
may_ask(xan_south, who, threat).
may_ask(xan_south, how, threat).
may_ask(xan_south, whether, threat).
may_ask(xan_south, why, threat).
may_ask(xan_south, when, threat).
may_ask(xan_south, which, threat).
competent(xan_south, trade).
willing(xan_south, trade, cautious).
may_ask(xan_south, where, trade).
may_ask(xan_south, what, trade).
may_ask(xan_south, who, trade).
may_ask(xan_south, how, trade).
may_ask(xan_south, whether, trade).
may_ask(xan_south, why, trade).
may_ask(xan_south, when, trade).
may_ask(xan_south, which, trade).
competent(xan_south, health).
willing(xan_south, health, cautious).
may_ask(xan_south, where, health).
may_ask(xan_south, what, health).
may_ask(xan_south, who, health).
may_ask(xan_south, how, health).
may_ask(xan_south, whether, health).
may_ask(xan_south, why, health).
may_ask(xan_south, when, health).
may_ask(xan_south, which, health).
competent(xan_south, archive).
willing(xan_south, archive, cautious).
may_ask(xan_south, where, archive).
may_ask(xan_south, what, archive).
may_ask(xan_south, who, archive).
may_ask(xan_south, how, archive).
may_ask(xan_south, whether, archive).
may_ask(xan_south, why, archive).
may_ask(xan_south, when, archive).
may_ask(xan_south, which, archive).
stock(xan_south, greet, [hello, from, maze_south]).
stock(xan_south, close, [farewell, from, xan_south]).
competent(xan_east, trade).
willing(xan_east, trade, cautious).
may_ask(xan_east, where, trade).
may_ask(xan_east, what, trade).
may_ask(xan_east, who, trade).
may_ask(xan_east, how, trade).
may_ask(xan_east, whether, trade).
may_ask(xan_east, why, trade).
may_ask(xan_east, when, trade).
may_ask(xan_east, which, trade).
competent(xan_east, health).
willing(xan_east, health, cautious).
may_ask(xan_east, where, health).
may_ask(xan_east, what, health).
may_ask(xan_east, who, health).
may_ask(xan_east, how, health).
may_ask(xan_east, whether, health).
may_ask(xan_east, why, health).
may_ask(xan_east, when, health).
may_ask(xan_east, which, health).
competent(xan_east, archive).
willing(xan_east, archive, cautious).
may_ask(xan_east, where, archive).
may_ask(xan_east, what, archive).
may_ask(xan_east, who, archive).
may_ask(xan_east, how, archive).
may_ask(xan_east, whether, archive).
may_ask(xan_east, why, archive).
may_ask(xan_east, when, archive).
may_ask(xan_east, which, archive).
competent(xan_east, weather).
willing(xan_east, weather, cautious).
may_ask(xan_east, where, weather).
may_ask(xan_east, what, weather).
may_ask(xan_east, who, weather).
may_ask(xan_east, how, weather).
may_ask(xan_east, whether, weather).
may_ask(xan_east, why, weather).
may_ask(xan_east, when, weather).
may_ask(xan_east, which, weather).
stock(xan_east, greet, [hello, from, maze_east]).
stock(xan_east, close, [farewell, from, xan_east]).
competent(yve_north, map).
willing(yve_north, map, urgent).
may_ask(yve_north, where, map).
may_ask(yve_north, what, map).
may_ask(yve_north, who, map).
may_ask(yve_north, how, map).
may_ask(yve_north, whether, map).
may_ask(yve_north, why, map).
may_ask(yve_north, when, map).
may_ask(yve_north, which, map).
competent(yve_north, route).
willing(yve_north, route, urgent).
may_ask(yve_north, where, route).
may_ask(yve_north, what, route).
may_ask(yve_north, who, route).
may_ask(yve_north, how, route).
may_ask(yve_north, whether, route).
may_ask(yve_north, why, route).
may_ask(yve_north, when, route).
may_ask(yve_north, which, route).
competent(yve_north, threat).
willing(yve_north, threat, urgent).
may_ask(yve_north, where, threat).
may_ask(yve_north, what, threat).
may_ask(yve_north, who, threat).
may_ask(yve_north, how, threat).
may_ask(yve_north, whether, threat).
may_ask(yve_north, why, threat).
may_ask(yve_north, when, threat).
may_ask(yve_north, which, threat).
competent(yve_north, trade).
willing(yve_north, trade, urgent).
may_ask(yve_north, where, trade).
may_ask(yve_north, what, trade).
may_ask(yve_north, who, trade).
may_ask(yve_north, how, trade).
may_ask(yve_north, whether, trade).
may_ask(yve_north, why, trade).
may_ask(yve_north, when, trade).
may_ask(yve_north, which, trade).
stock(yve_north, greet, [hello, from, hall_north]).
stock(yve_north, close, [farewell, from, yve_north]).
competent(yve_south, gold).
willing(yve_south, gold, urgent).
may_ask(yve_south, where, gold).
may_ask(yve_south, what, gold).
may_ask(yve_south, who, gold).
may_ask(yve_south, how, gold).
may_ask(yve_south, whether, gold).
may_ask(yve_south, why, gold).
may_ask(yve_south, when, gold).
may_ask(yve_south, which, gold).
competent(yve_south, map).
willing(yve_south, map, urgent).
may_ask(yve_south, where, map).
may_ask(yve_south, what, map).
may_ask(yve_south, who, map).
may_ask(yve_south, how, map).
may_ask(yve_south, whether, map).
may_ask(yve_south, why, map).
may_ask(yve_south, when, map).
may_ask(yve_south, which, map).
competent(yve_south, route).
willing(yve_south, route, urgent).
may_ask(yve_south, where, route).
may_ask(yve_south, what, route).
may_ask(yve_south, who, route).
may_ask(yve_south, how, route).
may_ask(yve_south, whether, route).
may_ask(yve_south, why, route).
may_ask(yve_south, when, route).
may_ask(yve_south, which, route).
competent(yve_south, threat).
willing(yve_south, threat, urgent).
may_ask(yve_south, where, threat).
may_ask(yve_south, what, threat).
may_ask(yve_south, who, threat).
may_ask(yve_south, how, threat).
may_ask(yve_south, whether, threat).
may_ask(yve_south, why, threat).
may_ask(yve_south, when, threat).
may_ask(yve_south, which, threat).
stock(yve_south, greet, [hello, from, hall_south]).
stock(yve_south, close, [farewell, from, yve_south]).
competent(yve_east, map).
willing(yve_east, map, urgent).
may_ask(yve_east, where, map).
may_ask(yve_east, what, map).
may_ask(yve_east, who, map).
may_ask(yve_east, how, map).
may_ask(yve_east, whether, map).
may_ask(yve_east, why, map).
may_ask(yve_east, when, map).
may_ask(yve_east, which, map).
competent(yve_east, route).
willing(yve_east, route, urgent).
may_ask(yve_east, where, route).
may_ask(yve_east, what, route).
may_ask(yve_east, who, route).
may_ask(yve_east, how, route).
may_ask(yve_east, whether, route).
may_ask(yve_east, why, route).
may_ask(yve_east, when, route).
may_ask(yve_east, which, route).
competent(yve_east, threat).
willing(yve_east, threat, urgent).
may_ask(yve_east, where, threat).
may_ask(yve_east, what, threat).
may_ask(yve_east, who, threat).
may_ask(yve_east, how, threat).
may_ask(yve_east, whether, threat).
may_ask(yve_east, why, threat).
may_ask(yve_east, when, threat).
may_ask(yve_east, which, threat).
competent(yve_east, trade).
willing(yve_east, trade, urgent).
may_ask(yve_east, where, trade).
may_ask(yve_east, what, trade).
may_ask(yve_east, who, trade).
may_ask(yve_east, how, trade).
may_ask(yve_east, whether, trade).
may_ask(yve_east, why, trade).
may_ask(yve_east, when, trade).
may_ask(yve_east, which, trade).
stock(yve_east, greet, [hello, from, hall_east]).
stock(yve_east, close, [farewell, from, yve_east]).
competent(zek_north, threat).
willing(zek_north, threat, formal).
may_ask(zek_north, where, threat).
may_ask(zek_north, what, threat).
may_ask(zek_north, who, threat).
may_ask(zek_north, how, threat).
may_ask(zek_north, whether, threat).
may_ask(zek_north, why, threat).
may_ask(zek_north, when, threat).
may_ask(zek_north, which, threat).
competent(zek_north, trade).
willing(zek_north, trade, formal).
may_ask(zek_north, where, trade).
may_ask(zek_north, what, trade).
may_ask(zek_north, who, trade).
may_ask(zek_north, how, trade).
may_ask(zek_north, whether, trade).
may_ask(zek_north, why, trade).
may_ask(zek_north, when, trade).
may_ask(zek_north, which, trade).
competent(zek_north, health).
willing(zek_north, health, formal).
may_ask(zek_north, where, health).
may_ask(zek_north, what, health).
may_ask(zek_north, who, health).
may_ask(zek_north, how, health).
may_ask(zek_north, whether, health).
may_ask(zek_north, why, health).
may_ask(zek_north, when, health).
may_ask(zek_north, which, health).
competent(zek_north, archive).
willing(zek_north, archive, formal).
may_ask(zek_north, where, archive).
may_ask(zek_north, what, archive).
may_ask(zek_north, who, archive).
may_ask(zek_north, how, archive).
may_ask(zek_north, whether, archive).
may_ask(zek_north, why, archive).
may_ask(zek_north, when, archive).
may_ask(zek_north, which, archive).
stock(zek_north, greet, [hello, from, gate_north]).
stock(zek_north, close, [farewell, from, zek_north]).
competent(zek_south, route).
willing(zek_south, route, formal).
may_ask(zek_south, where, route).
may_ask(zek_south, what, route).
may_ask(zek_south, who, route).
may_ask(zek_south, how, route).
may_ask(zek_south, whether, route).
may_ask(zek_south, why, route).
may_ask(zek_south, when, route).
may_ask(zek_south, which, route).
competent(zek_south, threat).
willing(zek_south, threat, formal).
may_ask(zek_south, where, threat).
may_ask(zek_south, what, threat).
may_ask(zek_south, who, threat).
may_ask(zek_south, how, threat).
may_ask(zek_south, whether, threat).
may_ask(zek_south, why, threat).
may_ask(zek_south, when, threat).
may_ask(zek_south, which, threat).
competent(zek_south, trade).
willing(zek_south, trade, formal).
may_ask(zek_south, where, trade).
may_ask(zek_south, what, trade).
may_ask(zek_south, who, trade).
may_ask(zek_south, how, trade).
may_ask(zek_south, whether, trade).
may_ask(zek_south, why, trade).
may_ask(zek_south, when, trade).
may_ask(zek_south, which, trade).
competent(zek_south, health).
willing(zek_south, health, formal).
may_ask(zek_south, where, health).
may_ask(zek_south, what, health).
may_ask(zek_south, who, health).
may_ask(zek_south, how, health).
may_ask(zek_south, whether, health).
may_ask(zek_south, why, health).
may_ask(zek_south, when, health).
may_ask(zek_south, which, health).
stock(zek_south, greet, [hello, from, gate_south]).
stock(zek_south, close, [farewell, from, zek_south]).
competent(zek_east, gold).
willing(zek_east, gold, formal).
may_ask(zek_east, where, gold).
may_ask(zek_east, what, gold).
may_ask(zek_east, who, gold).
may_ask(zek_east, how, gold).
may_ask(zek_east, whether, gold).
may_ask(zek_east, why, gold).
may_ask(zek_east, when, gold).
may_ask(zek_east, which, gold).
competent(zek_east, map).
willing(zek_east, map, formal).
may_ask(zek_east, where, map).
may_ask(zek_east, what, map).
may_ask(zek_east, who, map).
may_ask(zek_east, how, map).
may_ask(zek_east, whether, map).
may_ask(zek_east, why, map).
may_ask(zek_east, when, map).
may_ask(zek_east, which, map).
competent(zek_east, route).
willing(zek_east, route, formal).
may_ask(zek_east, where, route).
may_ask(zek_east, what, route).
may_ask(zek_east, who, route).
may_ask(zek_east, how, route).
may_ask(zek_east, whether, route).
may_ask(zek_east, why, route).
may_ask(zek_east, when, route).
may_ask(zek_east, which, route).
competent(zek_east, threat).
willing(zek_east, threat, formal).
may_ask(zek_east, where, threat).
may_ask(zek_east, what, threat).
may_ask(zek_east, who, threat).
may_ask(zek_east, how, threat).
may_ask(zek_east, whether, threat).
may_ask(zek_east, why, threat).
may_ask(zek_east, when, threat).
may_ask(zek_east, which, threat).
stock(zek_east, greet, [hello, from, gate_east]).
stock(zek_east, close, [farewell, from, zek_east]).

instance(gold_north).
isa(gold_north, gold).
located(gold_north, vault_north).
tradable(gold_north).
instance(map_north).
isa(map_north, map).
located(map_north, vault_north).
tradable(map_north).
instance(key_north).
isa(key_north, key).
located(key_north, vault_north).
tradable(key_north).
instance(lamp_north).
isa(lamp_north, lamp).
located(lamp_north, vault_north).
tradable(lamp_north).
instance(rope_north).
isa(rope_north, rope).
located(rope_north, vault_north).
tradable(rope_north).
instance(book_north).
isa(book_north, book).
located(book_north, vault_north).
tradable(book_north).
instance(ore_north).
isa(ore_north, ore).
located(ore_north, vault_north).
tradable(ore_north).
instance(herb_north).
isa(herb_north, herb).
located(herb_north, vault_north).
tradable(herb_north).
instance(coin_north).
isa(coin_north, coin).
located(coin_north, vault_north).
tradable(coin_north).
instance(seal_north).
isa(seal_north, seal).
located(seal_north, vault_north).
tradable(seal_north).
instance(chart_north).
isa(chart_north, chart).
located(chart_north, vault_north).
tradable(chart_north).
instance(blade_north).
isa(blade_north, blade).
located(blade_north, vault_north).
tradable(blade_north).
instance(cloak_north).
isa(cloak_north, cloak).
located(cloak_north, vault_north).
tradable(cloak_north).
instance(potion_north).
isa(potion_north, potion).
located(potion_north, vault_north).
tradable(potion_north).
instance(gold_south).
isa(gold_south, gold).
located(gold_south, vault_south).
tradable(gold_south).
instance(map_south).
isa(map_south, map).
located(map_south, vault_south).
tradable(map_south).
instance(key_south).
isa(key_south, key).
located(key_south, vault_south).
tradable(key_south).
instance(lamp_south).
isa(lamp_south, lamp).
located(lamp_south, vault_south).
tradable(lamp_south).
instance(rope_south).
isa(rope_south, rope).
located(rope_south, vault_south).
tradable(rope_south).
instance(book_south).
isa(book_south, book).
located(book_south, vault_south).
tradable(book_south).
instance(ore_south).
isa(ore_south, ore).
located(ore_south, vault_south).
tradable(ore_south).
instance(herb_south).
isa(herb_south, herb).
located(herb_south, vault_south).
tradable(herb_south).
instance(coin_south).
isa(coin_south, coin).
located(coin_south, vault_south).
tradable(coin_south).
instance(seal_south).
isa(seal_south, seal).
located(seal_south, vault_south).
tradable(seal_south).
instance(chart_south).
isa(chart_south, chart).
located(chart_south, vault_south).
tradable(chart_south).
instance(blade_south).
isa(blade_south, blade).
located(blade_south, vault_south).
tradable(blade_south).
instance(cloak_south).
isa(cloak_south, cloak).
located(cloak_south, vault_south).
tradable(cloak_south).
instance(potion_south).
isa(potion_south, potion).
located(potion_south, vault_south).
tradable(potion_south).
instance(gold_east).
isa(gold_east, gold).
located(gold_east, vault_east).
tradable(gold_east).
instance(map_east).
isa(map_east, map).
located(map_east, vault_east).
tradable(map_east).
instance(key_east).
isa(key_east, key).
located(key_east, vault_east).
tradable(key_east).
instance(lamp_east).
isa(lamp_east, lamp).
located(lamp_east, vault_east).
tradable(lamp_east).
instance(rope_east).
isa(rope_east, rope).
located(rope_east, vault_east).
tradable(rope_east).
instance(book_east).
isa(book_east, book).
located(book_east, vault_east).
tradable(book_east).
instance(ore_east).
isa(ore_east, ore).
located(ore_east, vault_east).
tradable(ore_east).
instance(herb_east).
isa(herb_east, herb).
located(herb_east, vault_east).
tradable(herb_east).
instance(coin_east).
isa(coin_east, coin).
located(coin_east, vault_east).
tradable(coin_east).
instance(seal_east).
isa(seal_east, seal).
located(seal_east, vault_east).
tradable(seal_east).
instance(chart_east).
isa(chart_east, chart).
located(chart_east, vault_east).
tradable(chart_east).
instance(blade_east).
isa(blade_east, blade).
located(blade_east, vault_east).
tradable(blade_east).
instance(cloak_east).
isa(cloak_east, cloak).
located(cloak_east, vault_east).
tradable(cloak_east).
instance(potion_east).
isa(potion_east, potion).
located(potion_east, vault_east).
tradable(potion_east).
instance(gold_west).
isa(gold_west, gold).
located(gold_west, vault_west).
tradable(gold_west).
instance(map_west).
isa(map_west, map).
located(map_west, vault_west).
tradable(map_west).
instance(key_west).
isa(key_west, key).
located(key_west, vault_west).
tradable(key_west).
instance(lamp_west).
isa(lamp_west, lamp).
located(lamp_west, vault_west).
tradable(lamp_west).
instance(rope_west).
isa(rope_west, rope).
located(rope_west, vault_west).
tradable(rope_west).
instance(book_west).
isa(book_west, book).
located(book_west, vault_west).
tradable(book_west).
instance(ore_west).
isa(ore_west, ore).
located(ore_west, vault_west).
tradable(ore_west).
instance(herb_west).
isa(herb_west, herb).
located(herb_west, vault_west).
tradable(herb_west).
instance(coin_west).
isa(coin_west, coin).
located(coin_west, vault_west).
tradable(coin_west).
instance(seal_west).
isa(seal_west, seal).
located(seal_west, vault_west).
tradable(seal_west).
instance(chart_west).
isa(chart_west, chart).
located(chart_west, vault_west).
tradable(chart_west).
instance(blade_west).
isa(blade_west, blade).
located(blade_west, vault_west).
tradable(blade_west).
instance(cloak_west).
isa(cloak_west, cloak).
located(cloak_west, vault_west).
tradable(cloak_west).
instance(potion_west).
isa(potion_west, potion).
located(potion_west, vault_west).
tradable(potion_west).
instance(gold_inner).
isa(gold_inner, gold).
located(gold_inner, vault_inner).
tradable(gold_inner).
instance(map_inner).
isa(map_inner, map).
located(map_inner, vault_inner).
tradable(map_inner).
instance(key_inner).
isa(key_inner, key).
located(key_inner, vault_inner).
tradable(key_inner).
instance(lamp_inner).
isa(lamp_inner, lamp).
located(lamp_inner, vault_inner).
tradable(lamp_inner).
instance(rope_inner).
isa(rope_inner, rope).
located(rope_inner, vault_inner).
tradable(rope_inner).
instance(book_inner).
isa(book_inner, book).
located(book_inner, vault_inner).
tradable(book_inner).
instance(ore_inner).
isa(ore_inner, ore).
located(ore_inner, vault_inner).
tradable(ore_inner).
instance(herb_inner).
isa(herb_inner, herb).
located(herb_inner, vault_inner).
tradable(herb_inner).
instance(coin_inner).
isa(coin_inner, coin).
located(coin_inner, vault_inner).
tradable(coin_inner).
instance(seal_inner).
isa(seal_inner, seal).
located(seal_inner, vault_inner).
tradable(seal_inner).
instance(chart_inner).
isa(chart_inner, chart).
located(chart_inner, vault_inner).
tradable(chart_inner).
instance(blade_inner).
isa(blade_inner, blade).
located(blade_inner, vault_inner).
tradable(blade_inner).
instance(cloak_inner).
isa(cloak_inner, cloak).
located(cloak_inner, vault_inner).
tradable(cloak_inner).
instance(potion_inner).
isa(potion_inner, potion).
located(potion_inner, vault_inner).
tradable(potion_inner).
instance(gold_outer).
isa(gold_outer, gold).
located(gold_outer, vault_outer).
tradable(gold_outer).
instance(map_outer).
isa(map_outer, map).
located(map_outer, vault_outer).
tradable(map_outer).
instance(key_outer).
isa(key_outer, key).
located(key_outer, vault_outer).
tradable(key_outer).
instance(lamp_outer).
isa(lamp_outer, lamp).
located(lamp_outer, vault_outer).
tradable(lamp_outer).
instance(rope_outer).
isa(rope_outer, rope).
located(rope_outer, vault_outer).
tradable(rope_outer).
instance(book_outer).
isa(book_outer, book).
located(book_outer, vault_outer).
tradable(book_outer).
instance(ore_outer).
isa(ore_outer, ore).
located(ore_outer, vault_outer).
tradable(ore_outer).
instance(herb_outer).
isa(herb_outer, herb).
located(herb_outer, vault_outer).
tradable(herb_outer).
instance(coin_outer).
isa(coin_outer, coin).
located(coin_outer, vault_outer).
tradable(coin_outer).
instance(seal_outer).
isa(seal_outer, seal).
located(seal_outer, vault_outer).
tradable(seal_outer).
instance(chart_outer).
isa(chart_outer, chart).
located(chart_outer, vault_outer).
tradable(chart_outer).
instance(blade_outer).
isa(blade_outer, blade).
located(blade_outer, vault_outer).
tradable(blade_outer).
instance(cloak_outer).
isa(cloak_outer, cloak).
located(cloak_outer, vault_outer).
tradable(cloak_outer).
instance(potion_outer).
isa(potion_outer, potion).
located(potion_outer, vault_outer).
tradable(potion_outer).
instance(gold_upper).
isa(gold_upper, gold).
located(gold_upper, vault_upper).
tradable(gold_upper).
instance(map_upper).
isa(map_upper, map).
located(map_upper, vault_upper).
tradable(map_upper).
instance(key_upper).
isa(key_upper, key).
located(key_upper, vault_upper).
tradable(key_upper).
instance(lamp_upper).
isa(lamp_upper, lamp).
located(lamp_upper, vault_upper).
tradable(lamp_upper).
instance(rope_upper).
isa(rope_upper, rope).
located(rope_upper, vault_upper).
tradable(rope_upper).
instance(book_upper).
isa(book_upper, book).
located(book_upper, vault_upper).
tradable(book_upper).
instance(ore_upper).
isa(ore_upper, ore).
located(ore_upper, vault_upper).
tradable(ore_upper).
instance(herb_upper).
isa(herb_upper, herb).
located(herb_upper, vault_upper).
tradable(herb_upper).
instance(coin_upper).
isa(coin_upper, coin).
located(coin_upper, vault_upper).
tradable(coin_upper).
instance(seal_upper).
isa(seal_upper, seal).
located(seal_upper, vault_upper).
tradable(seal_upper).
instance(chart_upper).
isa(chart_upper, chart).
located(chart_upper, vault_upper).
tradable(chart_upper).
instance(blade_upper).
isa(blade_upper, blade).
located(blade_upper, vault_upper).
tradable(blade_upper).
instance(cloak_upper).
isa(cloak_upper, cloak).
located(cloak_upper, vault_upper).
tradable(cloak_upper).
instance(potion_upper).
isa(potion_upper, potion).
located(potion_upper, vault_upper).
tradable(potion_upper).
instance(gold_lower).
isa(gold_lower, gold).
located(gold_lower, vault_lower).
tradable(gold_lower).
instance(map_lower).
isa(map_lower, map).
located(map_lower, vault_lower).
tradable(map_lower).
instance(key_lower).
isa(key_lower, key).
located(key_lower, vault_lower).
tradable(key_lower).
instance(lamp_lower).
isa(lamp_lower, lamp).
located(lamp_lower, vault_lower).
tradable(lamp_lower).
instance(rope_lower).
isa(rope_lower, rope).
located(rope_lower, vault_lower).
tradable(rope_lower).
instance(book_lower).
isa(book_lower, book).
located(book_lower, vault_lower).
tradable(book_lower).
instance(ore_lower).
isa(ore_lower, ore).
located(ore_lower, vault_lower).
tradable(ore_lower).
instance(herb_lower).
isa(herb_lower, herb).
located(herb_lower, vault_lower).
tradable(herb_lower).
instance(coin_lower).
isa(coin_lower, coin).
located(coin_lower, vault_lower).
tradable(coin_lower).
instance(seal_lower).
isa(seal_lower, seal).
located(seal_lower, vault_lower).
tradable(seal_lower).
instance(chart_lower).
isa(chart_lower, chart).
located(chart_lower, vault_lower).
tradable(chart_lower).
instance(blade_lower).
isa(blade_lower, blade).
located(blade_lower, vault_lower).
tradable(blade_lower).
instance(cloak_lower).
isa(cloak_lower, cloak).
located(cloak_lower, vault_lower).
tradable(cloak_lower).
instance(potion_lower).
isa(potion_lower, potion).
located(potion_lower, vault_lower).
tradable(potion_lower).

script(0, [greet(cor_south, ada_north), ask(cor_south, ada_north, where, gold), close(cor_south, ada_north)]).
script_topic(0, gold).
script_roles(0, guide, scholar).
script(1, [greet(cor_east, ada_south), ask(cor_east, ada_south, where, map), close(cor_east, ada_south)]).
script_topic(1, map).
script_roles(1, guide, scholar).
script(2, [greet(dax_north, ada_east), ask(dax_north, ada_east, where, route), close(dax_north, ada_east)]).
script_topic(2, route).
script_roles(2, guide, merchant).
script(3, [greet(dax_south, bas_north), ask(dax_south, bas_north, where, threat), close(dax_south, bas_north)]).
script_topic(3, threat).
script_roles(3, visitor, merchant).
script(4, [greet(dax_east, bas_south), ask(dax_east, bas_south, where, trade), close(dax_east, bas_south)]).
script_topic(4, trade).
script_roles(4, visitor, merchant).
script(5, [greet(eli_north, bas_east), ask(eli_north, bas_east, where, health), close(eli_north, bas_east)]).
script_topic(5, health).
script_roles(5, visitor, guard).
script(6, [greet(eli_south, cor_north), ask(eli_south, cor_north, where, archive), close(eli_south, cor_north)]).
script_topic(6, archive).
script_roles(6, scholar, guard).
script(7, [greet(eli_east, cor_south), ask(eli_east, cor_south, where, weather), close(eli_east, cor_south)]).
script_topic(7, weather).
script_roles(7, scholar, guard).
script(8, [greet(fay_north, cor_east), ask(fay_north, cor_east, where, law), close(fay_north, cor_east)]).
script_topic(8, law).
script_roles(8, scholar, pilot).
script(9, [greet(fay_south, dax_north), ask(fay_south, dax_north, where, ritual), close(fay_south, dax_north)]).
script_topic(9, ritual).
script_roles(9, merchant, pilot).
script(10, [greet(fay_east, dax_south), ask(fay_east, dax_south, where, navigation), close(fay_east, dax_south)]).
script_topic(10, navigation).
script_roles(10, merchant, pilot).
script(11, [greet(gio_north, dax_east), ask(gio_north, dax_east, where, supply), close(gio_north, dax_east)]).
script_topic(11, supply).
script_roles(11, merchant, medic).
script(12, [greet(gio_south, eli_north), ask(gio_south, eli_north, where, maze), close(gio_south, eli_north)]).
script_topic(12, maze).
script_roles(12, guard, medic).
script(13, [greet(gio_east, eli_south), ask(gio_east, eli_south, where, battery), close(gio_east, eli_south)]).
script_topic(13, battery).
script_roles(13, guard, medic).
script(14, [greet(hal_north, eli_east), ask(hal_north, eli_east, where, stench), close(hal_north, eli_east)]).
script_topic(14, stench).
script_roles(14, guard, ranger).
script(15, [greet(hal_south, fay_north), ask(hal_south, fay_north, where, wumpus), close(hal_south, fay_north)]).
script_topic(15, wumpus).
script_roles(15, pilot, ranger).
script(16, [greet(hal_east, fay_south), ask(hal_east, fay_south, where, ore), close(hal_east, fay_south)]).
script_topic(16, ore).
script_roles(16, pilot, ranger).
script(17, [greet(ira_north, fay_east), ask(ira_north, fay_east, where, herb), close(ira_north, fay_east)]).
script_topic(17, herb).
script_roles(17, pilot, broker).
script(18, [greet(ira_south, gio_north), ask(ira_south, gio_north, where, coin), close(ira_south, gio_north)]).
script_topic(18, coin).
script_roles(18, medic, broker).
script(19, [greet(ira_east, gio_south), ask(ira_east, gio_south, where, seal), close(ira_east, gio_south)]).
script_topic(19, seal).
script_roles(19, medic, broker).
script(20, [greet(joss_north, gio_east), ask(joss_north, gio_east, where, gold), close(joss_north, gio_east)]).
script_topic(20, gold).
script_roles(20, medic, archivist).
script(21, [greet(joss_south, hal_north), ask(joss_south, hal_north, where, map), close(joss_south, hal_north)]).
script_topic(21, map).
script_roles(21, ranger, archivist).
script(22, [greet(joss_east, hal_south), ask(joss_east, hal_south, where, route), close(joss_east, hal_south)]).
script_topic(22, route).
script_roles(22, ranger, archivist).
script(23, [greet(kai_north, hal_east), ask(kai_north, hal_east, where, threat), close(kai_north, hal_east)]).
script_topic(23, threat).
script_roles(23, ranger, guide).
script(24, [greet(kai_south, ira_north), ask(kai_south, ira_north, where, trade), close(kai_south, ira_north)]).
script_topic(24, trade).
script_roles(24, broker, guide).
script(25, [greet(kai_east, ira_south), ask(kai_east, ira_south, where, health), close(kai_east, ira_south)]).
script_topic(25, health).
script_roles(25, broker, guide).
script(26, [greet(lea_north, ira_east), ask(lea_north, ira_east, where, archive), close(lea_north, ira_east)]).
script_topic(26, archive).
script_roles(26, broker, visitor).
script(27, [greet(lea_south, joss_north), ask(lea_south, joss_north, where, weather), close(lea_south, joss_north)]).
script_topic(27, weather).
script_roles(27, archivist, visitor).
script(28, [greet(lea_east, joss_south), ask(lea_east, joss_south, where, law), close(lea_east, joss_south)]).
script_topic(28, law).
script_roles(28, archivist, visitor).
script(29, [greet(mio_north, joss_east), ask(mio_north, joss_east, where, ritual), close(mio_north, joss_east)]).
script_topic(29, ritual).
script_roles(29, archivist, scholar).
script(30, [greet(mio_south, kai_north), ask(mio_south, kai_north, where, navigation), close(mio_south, kai_north)]).
script_topic(30, navigation).
script_roles(30, guide, scholar).
script(31, [greet(mio_east, kai_south), ask(mio_east, kai_south, where, supply), close(mio_east, kai_south)]).
script_topic(31, supply).
script_roles(31, guide, scholar).
script(32, [greet(ned_north, kai_east), ask(ned_north, kai_east, where, maze), close(ned_north, kai_east)]).
script_topic(32, maze).
script_roles(32, guide, merchant).
script(33, [greet(ned_south, lea_north), ask(ned_south, lea_north, where, battery), close(ned_south, lea_north)]).
script_topic(33, battery).
script_roles(33, visitor, merchant).
script(34, [greet(ned_east, lea_south), ask(ned_east, lea_south, where, stench), close(ned_east, lea_south)]).
script_topic(34, stench).
script_roles(34, visitor, merchant).
script(35, [greet(ora_north, lea_east), ask(ora_north, lea_east, where, wumpus), close(ora_north, lea_east)]).
script_topic(35, wumpus).
script_roles(35, visitor, guard).
script(36, [greet(ora_south, mio_north), ask(ora_south, mio_north, where, ore), close(ora_south, mio_north)]).
script_topic(36, ore).
script_roles(36, scholar, guard).
script(37, [greet(ora_east, mio_south), ask(ora_east, mio_south, where, herb), close(ora_east, mio_south)]).
script_topic(37, herb).
script_roles(37, scholar, guard).
script(38, [greet(pim_north, mio_east), ask(pim_north, mio_east, where, coin), close(pim_north, mio_east)]).
script_topic(38, coin).
script_roles(38, scholar, pilot).
script(39, [greet(pim_south, ned_north), ask(pim_south, ned_north, where, seal), close(pim_south, ned_north)]).
script_topic(39, seal).
script_roles(39, merchant, pilot).

addressable(A, B) :- named_agent(A), named_agent(B), A \== B.
opens_with(greet(A, B)) :- addressable(A, B).
follows(greet(A, B), ask(A, B, Q, T)) :- may_ask(B, Q, T).
follows(ask(A, B, Q, T), tell(B, A, topic(T))) :- competent(B, T).
follows(ask(A, B, _, T), clarify(B, A, T)) :- \+ competent(B, T).
follows(tell(A, B, _), ack(B, A)) :- addressable(A, B).
follows(offer(A, B, O), accept(B, A, O)) :- tradable(O).
follows(_, close(A, B)) :- addressable(A, B).

licensed(Act) :- opens_with(Act).
licensed(Act) :- follows(_, Act).

% run_script(Id, Trace) uses the core dialogue/2 engine
run_script(Id, Trace) :- script(Id, Acts), dialogue(Acts, Trace).

expanded_clauses_marker(3844).
