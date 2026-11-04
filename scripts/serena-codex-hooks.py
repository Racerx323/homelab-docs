#!/usr/bin/env python3
"""Stateless Serena reminders for Codex; emits context without running Serena."""

import argparse
import json
import sys


ACTIVATION_CONTEXT = (
    "For repository work, follow its discovery order: vexp first when orientation "
    "is needed, Codebase Memory for unresolved structural questions, then Serena. "
    "Before using Serena, read initial_instructions if needed to obtain the current "
    "Serena session ID; this is separate from Codex's session ID. Request facade "
    "documentation with s.info before using it. Inspect s.cfg.get_current_config() "
    "and confirm the intended repository's absolute root. If necessary, call "
    "activate_project with that root and the Serena session ID as session, then "
    "confirm the project and ready language servers through s.cfg.get_current_config(). "
    "A parent multi-repository workspace is not a substitute for the target repository. "
    "Retain this confirmation until a repository switch, reconnect, or language-server "
    "error requires rechecking. Preserve existing project configuration and memories; "
    "do not repeat onboarding because the client restarted."
)

PLAN_CONTEXT = (
    "Codex is in plan mode. Serena REPL queries are permitted for read-only analysis: "
    "configuration inspection, memory listing/reading, and symbol or reference queries. "
    "Do not edit repository files, write or delete memories, change configuration, "
    "perform refactors, or execute mutating shell commands. Return bounded REPL results "
    "as the cell's final expression. Follow the repository's discovery order and the "
    "user's authorized scope. The REPL can perform writes; this reminder supplies "
    "guidance and does not enforce a sandbox or grant additional permissions."
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("activate", "plan-context"))
    action = parser.parse_args().action
    try:
        payload = json.load(sys.stdin)
    except (ValueError, OSError):
        return
    if not isinstance(payload, dict):
        return

    event = "SessionStart" if action == "activate" else "UserPromptSubmit"
    if payload.get("hook_event_name") != event:
        return
    if action == "plan-context" and payload.get("permission_mode") != "plan":
        return

    context = ACTIVATION_CONTEXT if action == "activate" else PLAN_CONTEXT
    json.dump(
        {"hookSpecificOutput": {"hookEventName": event, "additionalContext": context}},
        sys.stdout,
    )
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
