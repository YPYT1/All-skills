---
name: ops-dashboard
description: Gather operational signals (disk usage, git status, recent commits, and resources) so you can answer "How is the Clawdy infrastructure doing?" without manually running multiple checks.
---

# Ops Dashboard

## Overview

`ops-dashboard` exposes a single CLI (`scripts/ops_dashboard.py`) that prints a snapshot of:

- Workspace disk usage (total vs. free) and storage availability.
- Git status and the latest commits for the current branch.
- System load averages plus the top-level directory sizes so you know where data is accumulating.

Use this skill whenever you need to check health before deployments, push updates, or support teammates struggling with a slow workspace.

## References

- `references/ops-dashboard.md` explains the meaning of each metric and how to interpret alerts like high disk usage or stale branches.

## Resources

- **GitHub:** https://github.com/CrimsonDevil333333/ops-dashboard
- **ClawHub:** https://www.clawhub.ai/skills/ops-dashboard
