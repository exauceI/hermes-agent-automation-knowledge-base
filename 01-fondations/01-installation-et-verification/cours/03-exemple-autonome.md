# 3. Exemple autonome — Vérifier une installation Hermes

Le script [`examples/verifier-installation-hermes.sh`](../examples/verifier-installation-hermes.sh) est une mini-formation exécutable complète pour cette première brique. Il ne modifie pas la machine : il vérifie que `hermes` est accessible, affiche la version installée, lance le diagnostic officiel et montre l'identité Git utile pour les futurs exercices GitHub.

```bash
# Exécute le diagnostic depuis le dossier de la mini-formation.
bash examples/verifier-installation-hermes.sh
```

L'installation elle-même doit suivre la [documentation officielle](https://hermes-agent.nousresearch.com/docs/getting-started/installation), car elle évolue avec les plateformes. Sous Linux, macOS et WSL, elle indique actuellement :

```bash
# Télécharge et exécute l'installeur officiel Hermes pour Linux, macOS ou WSL.
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
# Recharge les commandes ajoutées au shell.
source ~/.bashrc
# Lance ensuite l'assistant de configuration.
hermes setup
```

Après l'installation, lancer un vrai chat local avant de passer à la messagerie.
