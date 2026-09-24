#!/usr/bin/env bash
# Vérifie une installation Hermes existante sans installer ni modifier quoi que ce soit.
# Usage : bash examples/verifier-installation-hermes.sh

# Arrête le script à la première commande en erreur, variable non définie ou erreur de pipe.
set -euo pipefail

# Affiche un titre clair afin que la sortie puisse être conservée dans un ticket ou un cours.
echo "=== Vérification Hermes Agent ==="

# Vérifie d'abord que la commande est accessible depuis le PATH du shell.
if ! command -v hermes >/dev/null 2>&1; then
  echo "ERREUR : la commande 'hermes' est introuvable dans le PATH."
  echo "Consulte le chapitre d'installation avant de poursuivre."
  exit 1
fi

# Affiche la version réellement installée, sans déduire son état depuis la documentation.
echo
printf 'Version installée : '
hermes --version

# Le doctor Hermes vérifie les composants et fournit des correctifs ciblés si nécessaire.
echo
echo "=== Diagnostic Hermes ==="
hermes doctor

# Affiche la configuration Git locale uniquement comme aide pour les futurs exercices GitHub.
echo
echo "=== Identité Git (optionnelle pour les exercices GitHub) ==="
printf 'Nom : '
git config --global user.name 2>/dev/null || echo "non configuré"
printf 'E-mail : '
git config --global user.email 2>/dev/null || echo "non configuré"

echo
echo "Vérification terminée : Hermes est accessible et le diagnostic a été exécuté."
