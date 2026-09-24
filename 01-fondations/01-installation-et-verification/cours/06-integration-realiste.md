# 6. Intégration réaliste — Pré-vol avant un bot Telegram

Avant de déployer un gateway sur un VPS, ajouter le diagnostic au script de pré-vol :

```bash
# Charge les contrôles Hermes communs au projet.
source src/hermes_diagnostics.sh
# Vérifie l'installation locale avant de configurer le gateway.
run_hermes_diagnostics
# Lance seulement ensuite l'assistant officiel de configuration des plateformes.
hermes gateway setup
```

Ne colle jamais le token Telegram dans ce script ou un commit. La documentation recommande le wizard `hermes gateway setup`, qui stocke les identifiants de manière appropriée.
