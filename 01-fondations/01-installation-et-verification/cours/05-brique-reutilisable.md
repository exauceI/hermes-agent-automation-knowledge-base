# 5. Brique réutilisable

Le fichier [`src/hermes_diagnostics.sh`](../src/hermes_diagnostics.sh) fournit deux fonctions :

- `require_hermes` vérifie l'accès à la commande ;
- `run_hermes_diagnostics` affiche la version puis lance le doctor.

```bash
# Charge les fonctions de diagnostic dans un autre script Bash.
source src/hermes_diagnostics.sh
# Arrête le script appelant si Hermes n'est pas installé.
require_hermes
# Lance la vérification standardisée de l'installation.
run_hermes_diagnostics
```

Cette interface évite de recopier la même logique dans les futurs scripts de déploiement ou de supervision.
