% SPDX-License-Identifier: AGPL-3.0-only
% Copyright (C) 2026 Ahmad Ali Parr
% GNU Affero General Public License version 3 only.
%
% Load the engine and the sensing domain. Do not load maze.pl.
%   ?- [engine/alpprolog, domains/sensing, queries/check_sensing].
%   ?- check_sensing.

check_sensing :-
    alp_run(check_cell),
    alp_state(S),
    member([unsafe(2)], S).
