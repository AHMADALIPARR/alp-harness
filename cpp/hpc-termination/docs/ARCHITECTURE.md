<!-- SPDX-License-Identifier: AGPL-3.0-only -->
<!-- Copyright (C) 2026 Ahmad Ali Parr. GNU Affero General Public License version 3 only. -->
<!-- From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz. -->

# I5 Architecture

```text
Program
  |
  +--> signed dependency graph
  |       |
  |       +--> SCCs
  |       +--> negative-cycle check
  |       +--> stratification
  |
  +--> range restriction
  |
  +--> active domain
  |       |
  |       +--> finite-domain check
  |       +--> Herbrand-base bound
  |
  +--> certificate
          |
          +--> NonRecursive
          +--> Stratified
          +--> Rejected
```

The certificate is an input to the HPC query planner. No downstream backend may convert a rejected or absent certificate into a successful logical result.
