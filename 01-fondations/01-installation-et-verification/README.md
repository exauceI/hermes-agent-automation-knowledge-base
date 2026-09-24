# Mini-formation — Installer et vérifier Hermes Agent

Cette première formation installe la base saine avant toute automatisation : un agent doit d'abord répondre correctement en local, avant d'ajouter gateway, Telegram, cron ou déploiement.

## Démarrage rapide

```bash
# Lance le diagnostic non destructif après avoir installé Hermes.
bash examples/verifier-installation-hermes.sh
# Vérifie les tests de structure du cours avec la bibliothèque standard Python.
python -m unittest tests/test_verifier_installation.py -v
```

## Parcours de la mini-formation

1. [Problème concret](cours/01-probleme-concret.md)
2. [Concepts expliqués](cours/02-concepts-expliques.md)
3. [Exemple autonome](cours/03-exemple-autonome.md)
4. [Décomposition](cours/04-decomposition.md)
5. [Brique réutilisable](cours/05-brique-reutilisable.md)
6. [Intégration réaliste](cours/06-integration-realiste.md)
7. [Tests](cours/07-tests.md)
8. [Limites et bonnes pratiques](cours/08-limites-bonnes-pratiques.md)

## Sources officielles

- [Installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation)
- [Quickstart](https://hermes-agent.nousresearch.com/docs/getting-started/quickstart)
- [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/)
