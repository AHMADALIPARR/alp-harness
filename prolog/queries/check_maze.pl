% SPDX-License-Identifier: AGPL-3.0-only
% Copyright (C) 2026 Ahmad Ali Parr
% GNU Affero General Public License version 3 only.
%
% Load with alpprolog.pl and maze.pl. Do not load sensing.pl or patrol.pl.
%   ?- [alpprolog, maze, queries/check_maze].
%   ?- check_maze.

check_maze :-
    alp_run(explore([1,2,3,4], [])),
    alp_state(S),
    member([at(agent, 4)], S),
    member([at(gold, 4)], S).
