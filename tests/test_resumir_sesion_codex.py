#!/usr/bin/env python3
import os
import sqlite3
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "resumir-sesion-codex.sh"
INSTALLER = ROOT / "instalar.sh"
TEMPLATE = ROOT / "plantillas" / "resumir-sesion-codex.desktop.template"
ICON = ROOT / "assets" / "logo.svg"


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
                ("calendar", str(self.project_dir), "calendario vacaciones", "crear calendario", 100, 250, 2222, 0, None, "cli"),
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

    def _write_summary_codex_stub(self):
        self.codex_bin.write_text(
            """#!/usr/bin/env bash
out=''
while [[ $# -gt 0 ]]; do
  if [[ "$1" == "-o" ]]; then
    out="$2"
    shift 2
    continue
  fi
  shift
done
if [[ -n "$out" ]]; then
  printf '**Objetivo**\\nResumen de prueba\\n' > "$out"
fi
exit 0
"""
        )
        self.codex_bin.chmod(0o755)

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

    def test_codex_detection_finds_local_bin(self):
        local_bin = self.home / ".local" / "bin"
        local_bin.mkdir(parents=True)
        local_codex = local_bin / "codex"
        local_codex.write_text("#!/usr/bin/env bash\nexit 0\n")
        local_codex.chmod(0o755)
        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(CODEX_BIN=""),
            check=True,
        )
        self.assertIn("~/project", proc.stdout)

    def test_installer_reports_detected_codex_path(self):
        proc = subprocess.run(
            [str(INSTALLER)],
            input="",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn(f"Codex detectado en: {self.codex_bin}", proc.stdout)

    def test_diagnostics_explain_session_visibility(self):
        proc = subprocess.run(
            [str(SCRIPT)],
            input="h\nd\n\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn("Resumen de sesiones", proc.stdout)
        self.assertIn("Activas que puedes abrir ahora", proc.stdout)
        self.assertIn("Que significa", proc.stdout)
        self.assertIn("Siguiente paso", proc.stdout)
        self.assertNotIn("a    Ver archivadas", proc.stdout)
        self.assertNotIn("x    Limpiar sesiones", proc.stdout)

    def test_diagnostics_can_be_exported_to_markdown(self):
        summary_dir = self.home / "summaries"
        proc = subprocess.run(
            [str(SCRIPT)],
            input="h\ne\n\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(CODEX_SUMMARY_DIR=str(summary_dir)),
            check=True,
        )
        self.assertIn("Diagnostico guardado en:", proc.stdout)
        reports = sorted(summary_dir.glob("diagnostico-sesiones-codex-*.md"))
        self.assertEqual(len(reports), 1)
        content = reports[0].read_text()
        self.assertIn("# Diagnostico de sesiones de Codex", content)
        self.assertIn("Activas que puedes abrir ahora", content)

    def test_session_list_can_be_exported_to_markdown_and_csv(self):
        summary_dir = self.home / "summaries"
        proc = subprocess.run(
            [str(SCRIPT)],
            input="h\nl\n\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(CODEX_SUMMARY_DIR=str(summary_dir)),
            check=True,
        )
        self.assertIn("Listado guardado en:", proc.stdout)
        md_files = sorted(summary_dir.glob("listado-sesiones-codex-*.md"))
        csv_files = sorted(summary_dir.glob("listado-sesiones-codex-*.csv"))
        self.assertEqual(len(md_files), 1)
        self.assertEqual(len(csv_files), 1)
        self.assertIn("calendario vacaciones", md_files[0].read_text())
        self.assertIn("calendar", csv_files[0].read_text())

    def test_console_render_uses_unicode_boxes_by_default(self):
        proc = subprocess.run(
            [str(SCRIPT)],
            input="q\n",
            text=True,
            capture_output=True,
            env=self._env(LC_ALL="C.UTF-8", LANG="C.UTF-8"),
            check=True,
        )
        self.assertIn("┌", proc.stdout)
        self.assertIn("│ Automatizacion-Codex", proc.stdout)
        self.assertNotIn("\033[", proc.stdout)

    def test_console_render_falls_back_to_ascii_without_utf8(self):
        proc = subprocess.run(
            [str(SCRIPT)],
            input="q\n",
            text=True,
            capture_output=True,
            env=self._env(LC_ALL="C", LANG="C"),
            check=True,
        )
        self.assertIn("+-------------------------------------------------------------------------------+", proc.stdout)
        self.assertNotIn("┌", proc.stdout)

    def test_missing_cwd_blocks_summary_generation(self):
        self.project_dir.rmdir()
        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertNotIn("~/project", proc.stdout)

    def test_state_schema_validation_reports_missing_columns(self):
        broken_db = self.codex_dir / "broken-state.sqlite"
        con = sqlite3.connect(broken_db)
        con.execute("create table threads (id text primary key, cwd text not null)")
        con.commit()
        con.close()

        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n",
            text=True,
            capture_output=True,
            env=self._env(STATE_DB=str(broken_db)),
            check=False,
        )
        self.assertNotEqual(proc.returncode, 0)
        self.assertIn("La base local de Codex no tiene el esquema esperado", proc.stdout)
        self.assertIn("Columnas que faltan", proc.stdout)

    def test_state_schema_diagnostics_warn_about_missing_recommended_indexes(self):
        proc = subprocess.run(
            [str(SCRIPT)],
            input="q\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn("Aviso: no se detectaron indices para columnas recomendadas", proc.stdout)

    def test_missing_cwd_is_hidden_by_default(self):
        self.project_dir.rmdir()
        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertNotIn("~/project", proc.stdout)

    def test_missing_cwd_can_be_removed_with_cleanup(self):
        self.project_dir.rmdir()
        proc = subprocess.run(
            [str(SCRIPT)],
            input="\nx\nLIMPIAR\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn("Limpieza completada", proc.stdout)
        con = sqlite3.connect(self.state_db)
        rows = con.execute("select id from threads where id = 'inside'").fetchall()
        con.close()
        self.assertEqual(rows, [])

    def test_cleanup_backup_rotation_keeps_latest_n(self):
        backup_dir = self.desktop / "Documentacion" / "Codex" / "Resumenes" / "backups"
        backup_dir.mkdir(parents=True)
        for stamp in ("20260101-000001", "20260101-000002", "20260101-000003"):
            (backup_dir / f"state-before-cleanup-{stamp}.sqlite").write_text("old")

        self.project_dir.rmdir()
        proc = subprocess.run(
            [str(SCRIPT)],
            input="\nx\nLIMPIAR\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(MAX_BACKUPS="2"),
            check=True,
        )
        self.assertIn("Limpieza completada", proc.stdout)
        backups = sorted(backup_dir.glob("state-before-cleanup-*.sqlite"))
        self.assertEqual(len(backups), 2)

    def test_read_only_mode_hides_write_actions(self):
        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n1\n0\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(CODEX_READ_ONLY="1"),
            check=True,
        )
        self.assertIn("Modo solo lectura activo", proc.stdout)
        self.assertNotIn("Limpiar sesiones con ruta inexistente", proc.stdout)
        self.assertNotIn("Archivar sesion", proc.stdout)

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

    def test_low_signal_title_uses_one_line_fallback_description(self):
        con = sqlite3.connect(self.state_db)
        con.execute(
            """
            insert into threads
            (id, cwd, title, first_user_message, created_at, updated_at, tokens_used, archived, archived_at, source)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            ("fallback", str(self.project_dir), ".", "preparar release local", 100, 450, 10, 0, None, "cli"),
        )
        con.commit()
        con.close()

        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn("preparar release local", proc.stdout)
        self.assertIn("Trabajo en project", proc.stdout)
        self.assertNotIn("Sesion sin titulo util", proc.stdout)

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

    def test_generate_summary_also_writes_markdown(self):
        self._write_summary_codex_stub()
        summary_dir = self.home / "summaries"
        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n1\n1\n\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(CODEX_SUMMARY_DIR=str(summary_dir)),
            check=True,
        )
        self.assertIn("Resumen Markdown guardado en:", proc.stdout)
        txt_files = sorted(summary_dir.glob("resumen-codex-calendar-*.txt"))
        md_files = sorted(summary_dir.glob("resumen-codex-calendar-*.md"))
        self.assertEqual(len(txt_files), 1)
        self.assertEqual(len(md_files), 1)
        md_content = md_files[0].read_text()
        self.assertIn("# Resumen de sesion Codex", md_content)
        self.assertIn("Resumen de prueba", md_content)

    def test_open_latest_summary_uses_configured_opener(self):
        summary_dir = self.home / "summaries"
        summary_dir.mkdir()
        summary_file = summary_dir / "resumen-codex-calendar-20260519-120000.md"
        summary_file.write_text("# Resumen\n")
        opener_log = self.home / "opener.log"
        opener = self.bin_dir / "open-summary"
        opener.write_text("#!/usr/bin/env bash\nprintf '%s\\n' \"$1\" > \"$OPENER_LOG\"\n")
        opener.chmod(0o755)

        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n1\n6\n\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(
                CODEX_SUMMARY_DIR=str(summary_dir),
                CODEX_SUMMARY_OPENER=str(opener),
                OPENER_LOG=str(opener_log),
            ),
            check=True,
        )
        self.assertIn("Abrir resumen en editor predeterminado", proc.stdout)
        self.assertEqual(opener_log.read_text().strip(), str(summary_file))

    def test_open_summary_and_backup_directories_from_main_menu(self):
        summary_dir = self.home / "summaries"
        opener_log = self.home / "paths.log"
        opener = self.bin_dir / "open-path"
        opener.write_text("#!/usr/bin/env bash\nprintf '%s\\n' \"$1\" >> \"$PATH_OPENER_LOG\"\n")
        opener.chmod(0o755)

        subprocess.run(
            [str(SCRIPT)],
            input="h\no\n\nb\n\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(
                CODEX_SUMMARY_DIR=str(summary_dir),
                CODEX_PATH_OPENER=str(opener),
                PATH_OPENER_LOG=str(opener_log),
            ),
            check=True,
        )
        opened = opener_log.read_text().splitlines()
        self.assertEqual(opened, [str(summary_dir), str(summary_dir / "backups")])

    def test_session_details_show_full_metadata(self):
        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n1\n7\n\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn("ID completo: calendar", proc.stdout)
        self.assertIn("Ruta completa:", proc.stdout)
        self.assertIn("Tokens:", proc.stdout)

    def test_project_view_groups_sessions_by_directory(self):
        proc = subprocess.run(
            [str(SCRIPT)],
            input="p\n\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn("Sesiones por proyecto", proc.stdout)
        self.assertIn("~/project", proc.stdout)
        self.assertIn("2", proc.stdout)

    def test_project_view_groups_by_git_root(self):
        nested = self.project_dir / "src" / "feature"
        nested.mkdir(parents=True)
        (self.project_dir / ".git").mkdir()
        con = sqlite3.connect(self.state_db)
        con.execute(
            """
            insert into threads
            (id, cwd, title, first_user_message, created_at, updated_at, tokens_used, archived, archived_at, source)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            ("nested", str(nested), "nested work", "mensaje", 100, 600, 10, 0, None, "cli"),
        )
        con.commit()
        con.close()

        proc = subprocess.run(
            [str(SCRIPT)],
            input="p\n\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn("~/project", proc.stdout)
        self.assertIn("3", proc.stdout)
        self.assertNotIn("~/project/src/feature", proc.stdout)

    def test_restore_backup_replaces_state_database_with_confirmation(self):
        backup_dir = self.desktop / "Documentacion" / "Codex" / "Resumenes" / "backups"
        backup_dir.mkdir(parents=True)
        backup = backup_dir / "state-before-cleanup-20260519-120000.sqlite"
        source = sqlite3.connect(self.state_db)
        target = sqlite3.connect(backup)
        source.backup(target)
        target.close()
        source.close()

        con = sqlite3.connect(backup)
        con.execute("delete from threads where id = 'calendar'")
        con.commit()
        con.close()

        proc = subprocess.run(
            [str(SCRIPT)],
            input="h\nr\n1\nRESTAURAR\n\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn("Restauracion completada", proc.stdout)
        self.assertIn("Resumen del backup seleccionado", proc.stdout)
        self.assertIn("Activas visibles", proc.stdout)
        con = sqlite3.connect(self.state_db)
        rows = con.execute("select id from threads where id = 'calendar'").fetchall()
        con.close()
        self.assertEqual(rows, [])
        self.assertTrue(list(backup_dir.glob("state-before-restore-*.sqlite")))

    def test_restore_backup_is_disabled_in_read_only_mode(self):
        proc = subprocess.run(
            [str(SCRIPT)],
            input="h\nr\n\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(CODEX_READ_ONLY="1"),
            check=True,
        )
        self.assertIn("Modo solo lectura activo. Restauracion deshabilitada.", proc.stdout)

    def test_session_title_sanitizes_tabs_and_newlines(self):
        con = sqlite3.connect(self.state_db)
        con.execute(
            """
            insert into threads
            (id, cwd, title, first_user_message, created_at, updated_at, tokens_used, archived, archived_at, source)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            ("weird", str(self.project_dir), "titulo\tcon\nsaltos", "mensaje", 100, 400, 10, 0, None, "cli"),
        )
        con.commit()
        con.close()

        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        self.assertIn("titulo con saltos", proc.stdout)
        self.assertNotIn("titulo\tcon", proc.stdout)

    def test_state_db_detection_uses_latest_versioned_database(self):
        newer_db = self.codex_dir / "state_2.sqlite"
        con = sqlite3.connect(newer_db)
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
        con.execute(
            """
            insert into threads
            (id, cwd, title, first_user_message, created_at, updated_at, tokens_used, archived, archived_at, source)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            ("latestdb", str(self.project_dir), "base mas nueva", "mensaje", 100, 500, 10, 0, None, "cli"),
        )
        con.commit()
        con.close()

        proc = subprocess.run(
            [str(SCRIPT)],
            input="\n0\nq\n",
            text=True,
            capture_output=True,
            env=self._env(STATE_DB=""),
            check=True,
        )
        self.assertIn("base mas nueva", proc.stdout)
        self.assertNotIn("calendario vacaciones", proc.stdout)

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
        asset_dir = special_root / "assets"
        asset_dir.mkdir()
        (asset_dir / ICON.name).write_text(ICON.read_text())

        subprocess.run(
            [str(installer_copy)],
            input="",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        launcher = self.desktop / "Resumir sesion de Codex.desktop"
        menu_launcher = self.home / ".local" / "share" / "applications" / "automatizacion-codex.desktop"
        self.assertIn(str(script_copy), launcher.read_text())
        self.assertIn(str(asset_dir / ICON.name), launcher.read_text())
        self.assertIn(str(script_copy), menu_launcher.read_text())

    def test_installer_uses_terminal_fallback_when_xdg_terminal_exec_is_missing(self):
        special_root = Path(self.tmp.name) / "fallback project"
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
        asset_dir = special_root / "assets"
        asset_dir.mkdir()
        (asset_dir / ICON.name).write_text(ICON.read_text())

        tool_dir = self.home / "tools"
        tool_dir.mkdir()
        for name, target in {
            "python3": sys.executable,
            "dirname": "/usr/bin/dirname",
            "chmod": "/usr/bin/chmod",
            "mkdir": "/usr/bin/mkdir",
        }.items():
            (tool_dir / name).symlink_to(target)
        kgx = tool_dir / "kgx"
        kgx.write_text("#!/usr/bin/env bash\nexit 0\n")
        kgx.chmod(0o755)

        env = self._env(PATH=str(tool_dir))
        subprocess.run(
            ["/bin/bash", str(installer_copy)],
            input="",
            text=True,
            capture_output=True,
            env=env,
            check=True,
        )
        launcher = self.desktop / "Resumir sesion de Codex.desktop"
        self.assertIn("Exec=kgx --", launcher.read_text())
        self.assertIn(f'"{script_copy}"', launcher.read_text())

    def test_custom_summary_dir_is_honored_by_installer(self):
        custom_dir = self.home / "Documentos" / "Codex" / "Resumenes"
        proc = subprocess.run(
            [str(INSTALLER)],
            text=True,
            capture_output=True,
            env=self._env(CODEX_SUMMARY_DIR=str(custom_dir)),
            check=True,
        )
        self.assertTrue(custom_dir.is_dir())
        self.assertIn(str(custom_dir), proc.stdout)

    def test_installer_creates_user_application_launcher(self):
        subprocess.run(
            [str(INSTALLER)],
            input="",
            text=True,
            capture_output=True,
            env=self._env(),
            check=True,
        )
        menu_launcher = self.home / ".local" / "share" / "applications" / "automatizacion-codex.desktop"
        self.assertTrue(menu_launcher.is_file())
        self.assertIn("Name=Resumir sesion de Codex", menu_launcher.read_text())

    def test_interactive_prompt_does_not_pollute_summary_path(self):
        install_text = INSTALLER.read_text()
        self.assertIn("printf 'Carpeta para resumenes, logs y backups:\\n' >&2", install_text)
        self.assertIn("printf ' [Enter] %s\\n' \"$default_dir\" >&2", install_text)
        self.assertIn("printf ' Ruta personalizada: ' >&2", install_text)

if __name__ == "__main__":
    unittest.main()
