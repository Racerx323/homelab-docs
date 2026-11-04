"""Exercise the Codex stdin/stdout hook contract without a running MCP server."""

import json
from pathlib import Path
import subprocess
import sys
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "serena-codex-hooks.py"


class SerenaHookTests(unittest.TestCase):
    def invoke(self, action, payload):
        return subprocess.run(
            [sys.executable, "-B", str(SCRIPT), action],
            input=payload,
            text=True,
            capture_output=True,
            timeout=5,
            check=False,
        )

    def context(self, action, payload):
        result = self.invoke(action, json.dumps(payload))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        output = json.loads(result.stdout)
        self.assertEqual(set(output), {"hookSpecificOutput"})
        hook = output["hookSpecificOutput"]
        self.assertEqual(set(hook), {"hookEventName", "additionalContext"})
        self.assertEqual(hook["hookEventName"], payload["hook_event_name"])
        return hook["additionalContext"]

    def test_startup_and_resume_preserve_session_and_discovery_order(self):
        for source in ("startup", "resume", "clear", "compact"):
            with self.subTest(source=source):
                text = self.context(
                    "activate", {"hook_event_name": "SessionStart", "source": source}
                )
                self.assertLess(text.index("vexp"), text.index("Codebase Memory"))
                self.assertLess(text.index("initial_instructions"), text.index("activate_project"))
                self.assertIn("absolute root", text)
                self.assertIn("do not repeat onboarding", text)

    def test_plan_mode_allows_read_only_repl_without_a_permission_decision(self):
        text = self.context(
            "plan-context",
            {"hook_event_name": "UserPromptSubmit", "permission_mode": "plan"},
        )
        self.assertIn("REPL queries are permitted for read-only analysis", text)
        self.assertIn("Do not edit repository files", text)
        self.assertIn("does not enforce a sandbox", text)

    def test_other_modes_are_silent(self):
        for mode in (None, "default", "auto", "acceptEdits", "dontAsk", "PLAN"):
            with self.subTest(mode=mode):
                result = self.invoke(
                    "plan-context",
                    json.dumps({"hook_event_name": "UserPromptSubmit", "permission_mode": mode}),
                )
                self.assertEqual((result.returncode, result.stdout, result.stderr), (0, "", ""))

    def test_payload_text_is_not_injected_into_context(self):
        text = self.context(
            "activate",
            {"hook_event_name": "SessionStart", "cwd": "UNTRUSTED_CWD", "prompt": "UNTRUSTED_PROMPT"},
        )
        self.assertNotIn("UNTRUSTED", text)

    def test_malformed_missing_or_wrong_events_are_silent(self):
        for action in ("activate", "plan-context"):
            for payload in ("", "{", "null", "[]", "{}", '{"hook_event_name":"PreToolUse"}'):
                with self.subTest(action=action, payload=payload):
                    result = self.invoke(action, payload)
                    self.assertEqual((result.returncode, result.stdout, result.stderr), (0, "", ""))

    def test_unknown_action_is_rejected(self):
        self.assertNotEqual(self.invoke("unknown", "{}").returncode, 0)


if __name__ == "__main__":
    unittest.main()
