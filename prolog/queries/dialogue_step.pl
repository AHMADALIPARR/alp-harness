% SPDX-License-Identifier: AGPL-3.0-only
% Copyright (C) 2026 Ahmad Ali Parr
% GNU Affero General Public License version 3 only.
%
% Load after alp_kernel.pl and dialog_kb.pl.
%   ?- [alp_kernel, dialog_kb, queries/dialogue_step].
%   ?- gold_exchange(Trace, S).
%
% The tell from reply/4 is stored with set_fluent, then exec_online sees it.

gold_exchange(Trace, S2) :-
    dialogue([greet(visitor, guide), ask(visitor, guide, where, gold)], Trace),
    member(tell(guide, visitor, located(gold, Place)), Trace),
    set_fluent(gold_at, Place, [], S2),
    holds(gold_at=Place, S2).

agent_proc(note_gold, nil).

see_gold(Trace, Final, History) :-
    gold_exchange(Trace, S),
    exec_online(call(note_gold), S, [S], Final, History),
    holds(gold_at=vault, Final).
