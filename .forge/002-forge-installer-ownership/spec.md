Forge should not delete existing skills, commands, hooks, or agents in a project upon install, uninstall, or upgrade. It should be able to CRUD its own parts but should not affect anything outside of itself.

Root cause: install and update use `rsync -a --delete` on .claude/skills/, .claude/commands/, .claude/hooks/, .claude/agents/ — wiping any user-created files in those directories. Uninstall uses `rm -rf` on the entire directory.

Fix: Track every individual file forge installs in the manifest's `managed_files` array. On install/update, copy only forge-owned files (no --delete). On update, remove only files that were in the old manifest but are absent from the new source (intentionally deleted by forge). On uninstall, remove only files in the manifest.
