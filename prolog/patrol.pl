% SPDX-License-Identifier: AGPL-3.0-only
% Copyright (C) 2026 Ahmad Ali Parr
% GNU Affero General Public License version 3 only.
%
% Example domain for the recursive kernel in alp_kernel.pl.
% Load the kernel first. Do not load this file together with maze.pl:
% both define a domain, and this file uses holds/2 from the kernel.
%
%   ?- [alp_kernel, patrol].
%   ?- RealS0 = [at=left, battery=high],
%      BS0 = [[at=left, battery=high], [at=left, battery=low]],
%      exec_online(call(patrol), RealS0, BS0, FinalS, History).
%
% Offline, complete information:
%   ?- exec(call(patrol), [at=left, battery=high], FinalS, History).

primitive_action(move_left).
primitive_action(move_right).
primitive_action(check_battery).

left_of(left, middle).
left_of(middle, right).
right_of(R, L) :-
    left_of(L, R).

impossible(move_left, S) :-
    holds(at=left, S).
impossible(move_right, S) :-
    holds(at=right, S).

effects(move_left, S, [at=L]) :-
    holds(at=R, S),
    left_of(L, R).
effects(move_right, S, [at=L]) :-
    holds(at=L0, S),
    right_of(L, L0).
effects(check_battery, _, []).

senses(move_left, []).
senses(move_right, []).
senses(check_battery, [battery]).

agent_proc(patrol,
    seq(prim(move_right),
        seq(prim(move_right),
            sense(check_battery)))).

agent_proc(to_right,
    while(neg(at=right), prim(move_right))).
