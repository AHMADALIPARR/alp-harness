% SPDX-License-Identifier: AGPL-3.0-only
% Copyright (C) 2026 Ahmad Ali Parr
% GNU Affero General Public License version 3 only.
%
% Load the kernel first.
%   ?- [kernel/alp_kernel, queries/check_ceiling].
%   ?- check_ceiling.

check_ceiling :-
    catch(exec(while(true, nil), [], _, _),
          execution_limit_exceeded(_),
          true).
