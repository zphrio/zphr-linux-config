"""Exercise real Git/Stow operations without touching the user's dotfiles."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]


@unittest.skipUnless(shutil.which("git") and shutil.which("stow"), "requires Git and GNU Stow")
class DotfilesSyncTest(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory(prefix="dotfiles-test-")
        self.addCleanup(self.scratch.cleanup)
        self.base = Path(self.scratch.name)
        self.home = self.base / "home"
        self.home.mkdir()
        self.upstream = self.base / "upstream"
        self.upstream.mkdir()
        self.env = {
            **os.environ,
            "HOME": str(self.home),
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_GLOBAL": os.devnull,
            "GIT_AUTHOR_NAME": "Dotfiles Test",
            "GIT_AUTHOR_EMAIL": "test@example.invalid",
            "GIT_COMMITTER_NAME": "Dotfiles Test",
            "GIT_COMMITTER_EMAIL": "test@example.invalid",
        }
        for name in ("dotfiles-sync.sh", "stow-packages.sh"):
            self.write(f"scripts/{name}", (ROOT / "scripts" / name).read_text())
        for package in ("btop", "kitty", "systemd"):
            self.write(f"{package}/.config/{package}/settings", "initial\n")
        self.write("nvim/.config/nvim/lua/plugins/old-agent.lua", "return {}\n")
        self.run_cmd("git", "init", "--initial-branch=main", cwd=self.upstream)
        self.commit("initial")
        self.repo = self.home / "zphr-linux-config"
        self.run_cmd("git", "clone", str(self.upstream), str(self.repo))

    def run_cmd(self, *args, cwd=None):
        result = subprocess.run(
            args, cwd=cwd or self.base, env=self.env,
            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        )
        self.assertEqual(result.returncode, 0, result.stdout)
        return result.stdout

    def write(self, name, content):
        path = self.upstream / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)

    def commit(self, message):
        self.run_cmd("git", "add", ".", cwd=self.upstream)
        self.run_cmd("git", "commit", "-m", message, cwd=self.upstream)

    def test_sync_skips_metadata_and_handles_removed_files_without_folding(self):
        # Force individual editor links, as on a machine with existing config dirs.
        plugins = self.home / ".config/nvim/lua/plugins"
        plugins.mkdir(parents=True)
        self.run_cmd(
            "bash", "-c",
            'source scripts/stow-packages.sh; '
            'for pkg in nvim btop kitty systemd; do stow_package "$pkg" || exit; done',
            cwd=self.repo,
        )
        self.assertTrue((plugins / "old-agent.lua").is_symlink())

        for package in ("btop", "kitty", "systemd"):
            directory = self.home / ".config" / package
            self.assertFalse(directory.is_symlink())
            (directory / "generated-local-file").write_text("local state\n")
            self.write(f"{package}/.config/{package}/settings", "updated\n")

        (self.upstream / "nvim/.config/nvim/lua/plugins/old-agent.lua").unlink()
        self.write("nvim/.config/nvim/lua/plugins/opencode.lua", "return { 'new' }\n")
        self.write("AGENTS.md", "Project instructions\n")
        self.write("opencode.jsonc", "{}\n")
        self.write(".agents/skills/example/SKILL.md", "Project skill\n")
        self.write(".opencode/commands/example.md", "Project command\n")
        self.write("scripts/should-not-stow", "Project script\n")
        self.commit("migrate agent configuration")

        self.run_cmd("bash", "scripts/dotfiles-sync.sh", cwd=self.repo)

        self.assertFalse(os.path.lexists(plugins / "old-agent.lua"))
        self.assertTrue((plugins / "opencode.lua").is_symlink())
        for name in (".agents", ".opencode", "AGENTS.md", "opencode.jsonc", "should-not-stow"):
            self.assertFalse(os.path.lexists(self.home / name), name)
        for package in ("btop", "kitty", "systemd"):
            directory = self.home / ".config" / package
            self.assertFalse(directory.is_symlink())
            self.assertEqual((directory / "settings").read_text(), "updated\n")
            self.assertEqual((directory / "generated-local-file").read_text(), "local state\n")
            self.assertFalse((self.repo / package / ".config" / package / "generated-local-file").exists())
        self.assertEqual(self.run_cmd("git", "status", "--porcelain", cwd=self.repo), "")
        self.assertEqual(
            self.run_cmd("git", "rev-parse", "HEAD", cwd=self.repo),
            self.run_cmd("git", "rev-parse", "HEAD", cwd=self.upstream),
        )

    def test_helper_targets_home_from_an_external_checkout(self):
        self.run_cmd(
            "bash", "-c", 'source "$1/scripts/stow-packages.sh"; stow_package nvim',
            "bash", str(self.upstream),
        )
        linked = self.home / ".config/nvim/lua/plugins/old-agent.lua"
        self.assertEqual(linked.resolve(), self.upstream / "nvim/.config/nvim/lua/plugins/old-agent.lua")
        self.assertFalse((self.base / ".config").exists())

    def test_helper_rejects_project_metadata(self):
        self.run_cmd(
            "bash", "-c",
            'source scripts/stow-packages.sh; '
            'if stow_package scripts; then exit 1; fi; '
            'if is_stow_package .agents; then exit 1; fi',
            cwd=self.repo,
        )
        self.assertFalse((self.home / "dotfiles-sync.sh").exists())


if __name__ == "__main__":
    unittest.main()
