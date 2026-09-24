# 2. Concepts expliqués

- **CLI** : commande `hermes` utilisée depuis un terminal.
- **Fournisseur / modèle** : le LLM qui répond aux demandes ; il se choisit avec `hermes model` ou l'assistant `hermes setup`.
- **Profil** : environnement Hermes isolé avec sa configuration, ses sessions, ses skills et ses mémoires.
- **Gateway** : processus de fond qui connecte les plateformes de messagerie, le planificateur cron et les messages vocaux.
- **Diagnostic** : `hermes doctor` inspecte l'installation et indique les corrections adaptées.

La règle de progression officielle est simple : faire fonctionner un chat local avant de configurer les couches plus complexes.
