#!/usr/bin/env bash
# Fonctions réutilisables pour contrôler une installation Hermes existante.

# Signale clairement l'absence de la commande avant de lancer d'autres vérifications.
require_hermes() {
  if ! command -v hermes >/dev/null 2>&1; then
    echo "ERREUR : la commande hermes est absente du PATH." >&2
    return 1
  fi
}

# Affiche la version et lance le diagnostic officiel, sans modifier la configuration.
run_hermes_diagnostics() {
  require_hermes
  echo "Version Hermes :"
  hermes --version
  echo "Diagnostic Hermes :"
  hermes doctor
}
