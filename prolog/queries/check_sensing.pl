% SPDX-License-Identifier: AGPL-3.0-only
% Copyright (C) 2026 Ahmad Ali Parr
% GNU Affero General Public License version 3 only.
%
% Load with alpprolog.pl and sensing.pl. Do not load maze.pl.
%   ?- [alpprolog, sensing, queries/check_sensing].
%   ?- check_sensing.

check_sensing :-
    alp_run(check_cell),
    alp_state(S),
    member([unsafe(2)], S).
