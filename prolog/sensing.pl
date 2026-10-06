% SPDX-License-Identifier: AGPL-3.0-only
% Copyright (C) 2026 Ahmad Ali Parr
% GNU Affero General Public License version 3 only.
%
% Sensing fragment from Definition 3.5 / Section 3.5.3.
%
%   ?- [alpprolog, sensing].
%   ?- alp_run(check_cell).
%   ?- alp_state(S).

aux([adjacent/2]).
sensors([stench]).

adjacent(1, 2).
adjacent(2, 1).
adjacent(2, 3).
adjacent(3, 2).

% Gold hunter stands at 1. Safety of cell 2 is unknown (no unit clause).
initial_state([
    at(agent, 1),
    neg(at(agent, 2)),
    neg(at(agent, 3))
]).

% No physical effect; sensing is done by ?(stench(R)) / q(stench(R)).
action(sniff, [], [
    []-[]
]).

% sensor_axiom(stench(R), [Val-Index-Meaning, ...])
% Val = R-Result. Index must be entailed to select the context.
sensor_axiom(stench(R), [
    R-stench - [at(agent, 1)] - [[unsafe(2)]],
    R-clear  - [at(agent, 1)] - [[neg(unsafe(2))]],
    R-stench - [at(agent, 2)] - [[unsafe(1), unsafe(3)]],
    R-clear  - [at(agent, 2)] - [[neg(unsafe(1)), neg(unsafe(3))]]
]).

% Observed online result for this run.
sensing_result(stench(stench), stench).

check_cell :-
    do(sniff),
    !,
    q(stench(R)),
    R = stench,
    ?(unsafe(2)).
