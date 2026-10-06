% SPDX-License-Identifier: AGPL-3.0-only
% Copyright (C) 2026 Ahmad Ali Parr
% GNU Affero General Public License version 3 only.
%
% Gold-maze domain and strategy from Drescher & Thielscher 2011, Example 2.1.
%
%   ?- [alpprolog, maze].
%   ?- alp_run(explore([1,2,3,4], [])).
%   ?- alp_state(S).

aux([adjacent/2]).

adjacent(1, 2).
adjacent(2, 1).
adjacent(2, 3).
adjacent(3, 2).
adjacent(3, 4).
adjacent(4, 3).

initial_state([
    at(agent, 1),
    neg(at(agent, 2)),
    neg(at(agent, 3)),
    neg(at(agent, 4)),
    neg(at(gold, 1)),
    neg(at(gold, 2)),
    neg(at(gold, 3)),
    at(gold, 4)
]).

action(go(Y), [at(agent, X), adjacent(X, Y)], [
    []-[neg(at(agent, X)), at(agent, Y)]
]).

explore(_, _) :-
    ?(at(agent, X)),
    ?(at(gold, X)),
    !.
explore(Choicepoints, Backtrack) :-
    ?(at(agent, X)),
    select(Y, Choicepoints, NewChoicepoints),
    do(go(Y)),
    !,
    explore(NewChoicepoints, [X|Backtrack]).
explore(Choicepoints, [X|Backtrack]) :-
    do(go(X)),
    !,
    explore(Choicepoints, Backtrack).

select(X, [X|Xs], Xs).
select(X, [Y|Xs], [Y|Ys]) :-
    select(X, Xs, Ys).
