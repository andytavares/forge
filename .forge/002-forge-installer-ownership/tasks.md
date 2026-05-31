# Feature 002: Forge Installer File-Level Ownership

<!-- Single file change: scripts/forge.sh. All tasks are config/scaffolding. -->

---

## T-001 — Populate managed_files in write_manifest

**Title:** Enumerate and record forge-owned files in manifest
**Description:** Update `write_manifest()` to enumerate every file actually written into the target (all files under .claude/agents, .claude/skills, .claude/commands, .claude/hooks plus the flat files) and store the relative paths as a sorted JSON array in `managed_files`. This replaces the current hardcoded `managed_files: []`.
**Acceptance criteria:**
1. After `forge.sh install`, `.forge-manifest.json` contains a non-empty `managed_files` array with relative paths like `.claude/skills/find-reuse/SKILL.md`.
2. The array contains only files (not directories) and uses paths relative to the target root.
**Depends on:** (none)
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-002 — Replace rsync --delete in cmd_install with per-file copy

**Title:** Remove --delete flag from install's rsync calls
**Description:** Replace the four `rsync -a --delete` calls in `cmd_install` with a loop that copies each file from the forge source individually, creating parent directories as needed. No file in the target that is not present in the forge source should be deleted.
**Acceptance criteria:**
1. A file at `.claude/skills/user-skill/SKILL.md` that exists in the target before `forge.sh install` is still present after install completes.
2. All forge-owned files from the source are correctly copied to the target.
**Depends on:** T-001
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-003 — Implement manifest-diff logic in cmd_update

**Title:** Update only manifest-owned files; remove only forge-deleted files
**Description:** Replace the four `rsync -a --delete` calls in `cmd_update` with a three-step approach: (1) copy all current source files to target (add new, overwrite changed), (2) read the old manifest's `managed_files`, and remove any file that appears in the old manifest but is absent from the new source — these are files forge intentionally removed between versions. Files the user created are never in the manifest and are never removed.
**Acceptance criteria:**
1. A user file `.claude/commands/my-cmd.md` not present in the forge source survives `forge.sh update`.
2. A forge-owned file that was removed from the forge source between versions is removed from the target after update.
3. New forge files not present in the target before update are added.
**Depends on:** T-001
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-004 — Fix cmd_uninstall to remove only manifest files

**Title:** Uninstall only files listed in the manifest
**Description:** Replace the `rm -rf "$target/$p"` loop in `cmd_uninstall` (which removes entire directories) with a loop that reads `managed_files` from the manifest and removes only those individual files. After removal, use `find -type d -empty -delete` to clean up directories that are now empty. Directories containing user files are left intact.
**Acceptance criteria:**
1. After `forge.sh uninstall`, a user file at `.claude/skills/user-skill/SKILL.md` is still present.
2. After `forge.sh uninstall`, all forge-owned files listed in the manifest are removed.
3. After `forge.sh uninstall`, `.claude/skills/` is removed only if it is empty; otherwise it remains with user files intact.
**Depends on:** T-001
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-005 — Update cmd_status to show forge vs user files

**Title:** Show forge-owned and user files separately in status
**Description:** Update `cmd_status` to list the files from `managed_files` in the manifest (forge-owned) and also detect any files in the shared directories (`.claude/skills/`, `.claude/commands/`, `.claude/hooks/`, `.claude/agents/`) that are NOT in the manifest (user-owned). Display both lists separately.
**Acceptance criteria:**
1. `forge.sh status` outputs a "Forge files" section listing manifest-tracked files that are present.
2. `forge.sh status` outputs a "User files (not managed by Forge)" section listing any files in shared dirs not in the manifest.
3. If there are no user files, the user files section is omitted or shows "(none)".
**Depends on:** T-001
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-006 — Update help text and README for directory co-ownership

**Title:** Document directory co-ownership in help and README
**Description:** Update the `cmd_help` "WHAT IS NEVER OVERWRITTEN" section and the README.md "managed vs yours" table to clarify that `.claude/skills/`, `.claude/commands/`, `.claude/hooks/`, and `.claude/agents/` are shared directories — forge manages its own files within them but leaves user files untouched.
**Acceptance criteria:**
1. `forge.sh --help` output mentions that user files in shared directories (skills, commands, hooks, agents) are preserved.
2. README.md correctly describes the co-ownership model.
**Depends on:** T-004
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes
