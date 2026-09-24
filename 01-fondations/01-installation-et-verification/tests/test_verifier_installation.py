"""Contrats du script de vérification d'installation Hermes."""

from pathlib import Path
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "examples" / "verifier-installation-hermes.sh"


class VerifyInstallationScriptTests(unittest.TestCase):
    """Vérifie que l'exemple de cours reste non destructif et exécutable."""

    def test_script_exists_and_has_valid_bash_syntax(self):
        """Le cours doit fournir un script exécutable et syntaxiquement valide."""
        self.assertTrue(SCRIPT.exists())
        result = subprocess.run(["bash", "-n", str(SCRIPT)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_script_uses_only_non_destructive_diagnostics(self):
        """Le script pédagogique ne doit ni installer ni modifier la machine."""
        content = SCRIPT.read_text(encoding="utf-8")

        self.assertIn("hermes --version", content)
        self.assertIn("hermes doctor", content)
        self.assertNotIn("install.sh", content)
        self.assertNotIn("rm -rf", content)


if __name__ == "__main__":
    unittest.main()
