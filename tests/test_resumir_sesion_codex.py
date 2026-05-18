#!/usr/bin/env python3
import os
import sqlite3
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "resumir-sesion-codex.sh"
INSTALLER = ROOT / "instalar.sh"
TEMPLATE = ROOT / "plantillas" / "resumir-sesion-codex.desktop.template"


class CodexSessionScriptTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.home = Path(self.tmp.name) / "home"
        self.desktop = self.home / "Desktop"
        self.codex_dir = self.home / ".codex"
        self.bin_dir = self.home / "bin"
        self.project_dir = self.home / "project"
        self.other_home = Path(self.tmp.name) / "home2"
        for path in (self.desktop, self.codex_dir, self.bin_dir, self.project_dir, self.other_home):
            path.mkdir(parents=True, exist_ok=True)

        self.state_db = self.codex_dir / "state_1.sqlite"
        self._create_db()
        self.codex_bin = self.bin_dir / "codex"
        self.codex_bin.write_text("#!/usr/bin/env bash\nexit 0\n")
        self.codex_bin.chmod(0o755)

    def tearDown(self):
        self.tmp.cleanup()

    def _create_db(self):
        con = sqlite3.connect(self.state_db)
        con.execute(
            """
            create table threads (
                id text primary key,
                cwd text not null,
                title text not null,
                first_user_message text not null,
                created_at integer not null,
                updated_at integer not null,
                tokens_used integer not null,
                archived integer not null default 0,
                archived_at integer,
                source text not null
            )
            """
        )
        con.executemany(
            """
            insert into threads
            (id, cwd, title, first_user_message, created_at, updated_at, tokens_used, archived, archived_at, source)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                ("inside", str(self.project_dir), ".", ".", 100, 200, 1234, 0, None, "cli"),
                ("calendar", str(self.project_dir / "calendar"), "calendario vacaciones", "crear calendario", 100, 250, 2222, 0, None, "cli"),
                ("outside", str(self.other_home / "project"), ".", ".", 100, 300, 4321, 0, None, "cli"),
            ],
        )
        con.commit()
        con.close()

    def _env(self, **extra):
        env = os.environ.copy()
        env.update(
            {
                "HOME": str(self.home),
                "CODEX_BIN": str(self.codex_bin),
                "STATE_DB": str(self.state_db),
                "PATH": f"{self.bin_dir}:{env['PATH']}",
            }
        )
        env.update(extra)
        return env

    def test_home_filter_excludes_prefix_collision(self):
        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn("~/project", proc.stdout)
        self.assertNotIn("home2/project", proc.stdout)

    def test_missing_cwd_blocks_summary_generation(self):
        self.project_dir.rmdir()
        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n1\n1\n\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn("No se puede generar el resumen porque ya no existe el directorio original", proc.stdout)

    def test_text_filter_searches_visible_session_metadata(self):
        proc = subprocess.run(
            [str(SCRIPT)],
            input="\nf\ncalendario\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn("Filtro activo: calendario", proc.stdout)
        self.assertIn("calendario vacaciones", proc.stdout)

    def test_backup_rotation_keeps_latest_n(self):
        backup_dir = self.desktop / "Documentacion" / "Codex" / "Resumenes" / "backups"
        backup_dir.mkdir(parents=True)
        for stamp in ("20260101-000001", "20260101-000002", "20260101-000003"):
            (backup_dir / f"state-before-archive-{stamp}.sqlite").write_text("old")

        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n1\n4\nARCHIVAR\n\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(MAX_BACKUPS="2"),
            check=True,
        )
        self.assertIn("Sesion archivada correctamente", proc.stdout)
        backups = sorted(backup_dir.glob("state-before-archive-*.sqlite"))
        self.assertEqual(len(backups), 2)

    def test_installer_preserves_special_path_characters(self):
        special_root = Path(self.tmp.name) / "a&b"
        special_root.mkdir()
        script_copy = special_root / SCRIPT.name
        template_dir = special_root / "plantillas"
        template_dir.mkdir()
        installer_copy = special_root / INSTALLER.name
        script_copy.write_text(SCRIPT.read_text())
        script_copy.chmod(0o755)
        installer_copy.write_text(INSTALLER.read_text())
        installer_copy.chmod(0o755)
        (template_dir / TEMPLATE.name).write_text(TEMPLATE.read_text())

        subprocess.run(
            [str(installer_copy)],
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        launcher = self.desktop / "Resumir sesion de Codex.desktop"
        self.assertIn(str(script_copy), launcher.read_text())

if __name__ == "__main__":
    unittest.main()
