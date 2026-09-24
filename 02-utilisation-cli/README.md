# Utiliser Hermes en mode CLI — modèles, sessions, coût et diagnostic

> **Objectif :** savoir utiliser Hermes efficacement depuis un terminal : démarrer ou reprendre un chat, choisir un modèle, lancer une requête scriptable, vérifier les outils actifs, suivre la consommation et diagnostiquer les problèmes.

Cette fiche s'appuie sur la CLI réellement installée et sur la [référence officielle](https://hermes-agent.nousresearch.com/docs/reference/cli-commands). Lance `hermes <commande> --help` si une version plus récente affiche d'autres options.

## 1. Problème concret

Un agent en CLI est pratique pour travailler dans un projet, automatiser une tâche ou garder ses échanges sous contrôle. Mais sans quelques commandes de base, on ne sait pas quel modèle répond, combien les sessions consomment, où sont les logs ou comment reprendre un travail interrompu.

## 2. Concepts à connaître

- **Session** : conversation enregistrée ; elle conserve le contexte et les décisions précédentes.
- **Provider / model** : le fournisseur exécute un modèle. Le provider peut être OpenAI Codex, Nous Portal, Anthropic, etc.
- **Toolset** : groupe d'outils accessibles à l'agent (fichiers, terminal, web, etc.).
- **One-shot** : une seule question non interactive, utile dans un script.
- **Insights** : statistiques d'usage des sessions : tokens, coûts, outils et activité.

## 3. Exemple autonome : une journée en CLI

```bash
# Vérifie la version réellement utilisée dans ce terminal.
hermes --version

# Ouvre une conversation interactive : c'est la commande la plus courante.
hermes

# Lance une question unique et affiche seulement la réponse finale.
# Utile pour une tâche ponctuelle ou dans une automatisation shell.
hermes chat -q "Résume les changements Git de ce dépôt."

# Reprend la dernière session afin de conserver le contexte du travail précédent.
hermes --continue

# Choisit interactivement le fournisseur et le modèle par défaut.
hermes model

# Affiche l'état des composants Hermes ; `--all` détaille davantage sans afficher les secrets.
hermes status --all

# Analyse la consommation récente : tokens, coûts, activité et outils employés.
hermes insights --days 7
```

Ce bloc représente le flux complet : **vérifier → discuter → reprendre → contrôler le modèle → observer l'état et la consommation**.

## 4. Décomposition des commandes essentielles

### Démarrer et reprendre un chat

```bash
# Conversation interactive classique dans le terminal.
hermes

# Force l'interface terminal classique si une autre interface est configurée.
hermes --cli

# Force l'interface TUI si tu préfères une interface terminal enrichie.
hermes --tui

# Reprend une session précise avec son identifiant ou son titre.
hermes --resume "mon-projet-api"
```

Utilise `--continue` pour le dernier travail et `--resume` si tu veux éviter de reprendre la mauvaise conversation.

### Choisir ou remplacer un modèle

```bash
# Ouvre le sélecteur de fournisseur et de modèle.
hermes model

# Relance la récupération des modèles disponibles si le cache est obsolète.
hermes model --refresh

# Utilise exceptionnellement un modèle différent pour cette exécution seulement.
# Le réglage par défaut n'est pas modifié.
hermes -m "nom-du-modele" --provider "nom-du-provider" chat -q "Explique ce fichier."
```

Choisis d'abord un modèle stable pour le chat local. Les fallbacks et le multi-provider viennent ensuite, une fois le fonctionnement de base validé.

### Voir l'usage et la consommation

```bash
# Analyse les trente derniers jours par défaut : tokens, coût, outils et tendance.
hermes insights

# Limite l'analyse aux sept derniers jours.
hermes insights --days 7

# Filtre les conversations provenant du terminal.
hermes insights --source cli

# Filtre les conversations provenant de Telegram après configuration du gateway.
hermes insights --source telegram
```

`hermes insights` est la commande à utiliser pour suivre la consommation. Le coût dépend du provider et du modèle ; si le provider ne publie pas toutes ses données tarifaires, Hermes ne peut afficher qu'une estimation ou des métriques partielles.

### Sessions, outils et logs

```bash
# Liste les sessions récentes pour retrouver un travail.
hermes sessions list

# Affiche les statistiques de stockage des sessions.
hermes sessions stats

# Ouvre un navigateur interactif de sessions.
hermes sessions browse

# Affiche les outils et toolsets actuellement configurés.
hermes tools list

# Suit les logs Hermes en direct pendant un diagnostic.
hermes logs -f

# Lance le diagnostic officiel après une mise à jour ou une erreur.
hermes doctor
```

## 5. Brique réutilisable

Pour les scripts shell, utilise un one-shot au lieu d'essayer de piloter une conversation interactive :

```bash
# Arrête le script si une commande échoue ou si une variable n'est pas définie.
set -euo pipefail

# Donne une consigne complète afin que l'agent n'ait pas besoin d'un contexte interactif.
hermes chat -q "Analyse les erreurs du dernier build et réponds en trois points." \
  > rapport-hermes.txt

# Conserve la réponse dans un fichier pour une revue humaine ou un pipeline CI.
printf 'Rapport enregistré dans rapport-hermes.txt\n'
```

N'ajoute `--yolo` que si tu acceptes explicitement que l'agent contourne les confirmations des commandes dangereuses. Pour un script de production, préfère des toolsets limités et des instructions très précises.

## 6. Exemple réaliste : bilan hebdomadaire de consommation

```bash
# Crée un répertoire pour les rapports sans toucher aux secrets Hermes.
mkdir -p rapports

# Enregistre les statistiques des quatorze derniers jours dans un fichier daté.
hermes insights --days 14 > "rapports/usage-$(date +%F).txt"

# Ajoute l'état global pour savoir si une panne explique une baisse d'activité.
hermes status --all >> "rapports/usage-$(date +%F).txt"
```

Tu peux ensuite envoyer ce rapport par e-mail, le versionner sans secrets ou le traiter dans une tâche cron. Ne traite pas un rapport de consommation comme une facture exacte sans vérifier le tableau du provider.

## 7. Vérification rapide

```bash
# Affiche l'aide native, qui est la source de vérité pour la version installée.
hermes --help

# Vérifie les options exactes de la commande d'analyse de consommation.
hermes insights --help

# Vérifie l'état des composants sans modifier leur configuration.
hermes status
```

## 8. Limites et bonnes pratiques

- Ne mets jamais une clé API dans une ligne de commande, un historique shell ou Git ; utilise l'assistant de connexion ou les fichiers de secrets prévus.
- Une session longue peut accumuler beaucoup de contexte ; reprends seulement les sessions utiles et archive les anciennes si nécessaire.
- Avant une automatisation, teste toujours la requête avec `hermes chat -q` dans un terminal.
- Le coût d'une réponse dépend du modèle, du volume de contexte et des appels d'outils. Utilise `hermes insights` régulièrement, puis vérifie le tableau de consommation du provider.
- `hermes doctor` et `hermes status` diagnostiquent l'agent ; ils ne remplacent pas un test réel de ton provider ou de ton bot.

## À retenir

La boucle CLI essentielle est : **`hermes` pour travailler, `hermes model` pour choisir, `hermes insights` pour mesurer, `hermes status` et `hermes doctor` pour diagnostiquer.**
