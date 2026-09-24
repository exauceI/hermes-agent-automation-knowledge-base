# Installer, configurer et vérifier Hermes Agent

> **Objectif :** passer d'une machine sans Hermes à un agent local qui répond à un vrai message, dont l'installation est vérifiée et prête à recevoir ensuite des automatisations, un gateway ou un déploiement.

Ce chapitre est une **formation complète**, pas une liste de commandes. Il suit la documentation officielle Hermes Agent, mais explique aussi dans quel ordre agir, pourquoi, et ce que chaque commande permet de vérifier.

> Les commandes d'installation évoluent. La documentation officielle reste la référence : [Installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation) · [Quickstart](https://hermes-agent.nousresearch.com/docs/getting-started/quickstart) · [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/).

---

## 1. Problème concret : pourquoi commencer par le local ?

On veut souvent aller directement vers « créer un bot Telegram », « lancer une tâche tous les matins » ou « déployer Hermes sur un VPS ». C'est une mauvaise première étape.

Un agent automatisé dépend de plusieurs couches :

```text
Machine et terminal
        ↓
Installation Hermes
        ↓
Fournisseur de modèle + authentification
        ↓
Conversation locale fonctionnelle
        ↓
Outils, skills et mémoire
        ↓
Gateway / cron / messagerie
        ↓
Service déployé et surveillé
```

Si la conversation locale ne fonctionne pas, un problème de Telegram, de cron ou de service sera plus difficile à isoler. Cette mini-formation valide donc la fondation : **Hermes est accessible, configuré et capable de répondre localement.**

---

## 2. Concepts essentiels avant les commandes

### Hermes CLI

La CLI est la commande `hermes` utilisée dans le terminal. Elle permet de converser, choisir un modèle, modifier une configuration, diagnostiquer l'installation et gérer un gateway.

### Fournisseur et modèle

Hermes est l'agent, mais il a besoin d'un **modèle de langage** pour raisonner et répondre. Ce modèle peut venir par exemple de Nous Portal, OpenAI Codex, Anthropic, OpenRouter ou d'un endpoint compatible OpenAI. Le choix se fait avec `hermes model` ou avec l'assistant `hermes setup`.

### Profil

Un profil isole des configurations, des sessions, des skills et des mémoires. C'est utile pour séparer par exemple un agent personnel, un agent de cours et un agent de production. Un autre profil n'hérite pas automatiquement de tes skills ou secrets du profil courant.

### Gateway

Le gateway est le processus de fond qui relie Hermes à Telegram, Discord et d'autres plateformes. Il exécute aussi le planificateur cron. Il vient **après** la validation locale, pas avant.

### Diagnostic

`hermes doctor` inspecte l'installation réelle : versions Python, configuration, outils disponibles, authentifications et dépendances facultatives. C'est plus fiable que de deviner l'état de la machine.

---

## 3. Exemple autonome complet : installation → premier chat → diagnostic

L'exemple de cette mini-formation n'est pas artificiellement court. Il représente tout le chemin minimal utile : installer, recharger le shell, configurer un modèle, faire un vrai chat, puis diagnostiquer.

### Étape A — Installer Hermes

Sous Linux, macOS ou WSL, la documentation officielle indique actuellement cette commande :

```bash
# Télécharge et exécute l'installeur officiel Hermes.
# Il prépare notamment Python, le dépôt Hermes et la commande globale `hermes`.
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# Recharge la configuration Bash afin que le terminal trouve la commande `hermes`.
source ~/.bashrc

# Vérifie que le shell accède réellement à Hermes.
hermes --version
```

Sous Windows natif, utilise la commande PowerShell de la documentation officielle plutôt que celle-ci. Sur macOS et Windows, l'application Desktop est également proposée.

### Étape B — Configurer le modèle

```bash
# Ouvre l'assistant de configuration complet : modèle, fournisseur, outils et options.
hermes setup

# Alternative : configure ou change uniquement le fournisseur et le modèle.
hermes model
```

Choisis une seule voie et termine-la. Ne configure pas Telegram, cron ou des plugins avant d'avoir validé un modèle. Les identifiants et OAuth sont gérés par l'assistant ; ne colle jamais de clé API ou de token dans un dépôt Git.

### Étape C — Prouver qu'une conversation marche

```bash
# Ouvre une session locale interactive avec l'agent configuré.
hermes
```

Envoie un message simple, par exemple : `Explique en une phrase ce que fait Hermes Agent.`

**Critère de réussite :** Hermes répond sans erreur de fournisseur ni d'authentification. Si ce n'est pas le cas, corrige d'abord ce problème avec `hermes model`, `hermes setup` ou `hermes doctor`.

### Étape D — Exécuter le script de vérification fourni

```bash
# Lance le script autonome et non destructif de ce cours.
# Il vérifie la commande, affiche la version et exécute le diagnostic officiel.
bash examples/verifier-installation-hermes.sh
```

Le script ne télécharge rien, ne modifie pas de configuration et n'enregistre aucun secret. Il est donc utilisable avant chaque déploiement ou dans un script de pré-vol.

---

## 4. Décomposition du script autonome

Le fichier [`examples/verifier-installation-hermes.sh`](examples/verifier-installation-hermes.sh) est abondamment commenté. Voici sa logique.

### Vérifier le PATH avant tout

```bash
# Vérifie que le shell peut localiser l'exécutable Hermes.
# Sans cela, les commandes suivantes échoueraient avec un message peu utile.
if ! command -v hermes >/dev/null 2>&1; then
  # Explique précisément le problème puis termine avec un code d'échec.
  echo "ERREUR : la commande 'hermes' est introuvable dans le PATH."
  exit 1
fi
```

Le PATH est la liste des dossiers dans lesquels ton shell cherche les commandes. Une installation peut être correcte mais non chargée dans le shell actuel : recharger `~/.bashrc` ou ouvrir un nouveau terminal est alors nécessaire.

### Lire l'état réel au lieu de le supposer

```bash
# Affiche la version réellement exécutée par le shell actuel.
hermes --version

# Lance le diagnostic officiel sans masquer ni interpréter ses résultats.
hermes doctor
```

Le doctor peut signaler des dépendances facultatives manquantes. Ce n'est pas toujours un blocage : par exemple, un navigateur Playwright ou Docker peuvent être inutiles si ton premier objectif est seulement un chat local.

### Pourquoi l'identité Git apparaît-elle ?

Le script affiche aussi le nom et l'e-mail Git uniquement comme information. Ce n'est pas requis pour Hermes ; c'est utile lorsque tu commenceras à versionner des scripts d'automatisation ou à pousser tes cours sur GitHub.

---

## 5. Brique réutilisable : diagnostic dans `src/`

L'exemple autonome enseigne tout le flux. Dans un autre script, il est préférable de ne pas recopier les contrôles. La brique [`src/hermes_diagnostics.sh`](src/hermes_diagnostics.sh) expose deux fonctions stables :

- `require_hermes` : échoue clairement si la CLI n'est pas disponible ;
- `run_hermes_diagnostics` : affiche la version puis lance `hermes doctor`.

```bash
# Charge les fonctions réutilisables de ce cours dans ton script.
source src/hermes_diagnostics.sh

# Vérifie que Hermes est accessible avant toute opération dépendante de l'agent.
require_hermes

# Lance une vérification standardisée et non destructive.
run_hermes_diagnostics
```

Tu peux réutiliser cette brique dans les prochains chapitres : avant d'installer un gateway, avant de créer un service système ou avant une mise à jour.

---

## 6. Exemple réaliste : préparer un bot Telegram sans exposer de secret

Quand le chat local fonctionne, le prochain objectif peut être de connecter Telegram. La documentation Hermes recommande de passer par l'assistant :

```bash
# Vérifie d'abord l'état de Hermes avant d'ajouter une couche réseau.
source src/hermes_diagnostics.sh
run_hermes_diagnostics

# Lance l'assistant interactif qui configure les plateformes de messagerie.
# Saisis le token uniquement dans l'assistant, jamais dans un fichier versionné.
hermes gateway setup

# Démarre le gateway au premier plan pour observer les messages de connexion.
hermes gateway
```

Pour Telegram, le token est créé avec **@BotFather**. C'est un secret : toute personne qui le possède peut contrôler le bot. Il ne doit jamais apparaître dans un README, un script, une capture publiée ou un commit. Teste toujours le gateway au premier plan avant de l'installer comme service.

---

## 7. Tests : protéger le cours et ses scripts

Le test [`tests/test_verifier_installation.py`](tests/test_verifier_installation.py) vérifie trois contrats :

1. le script de cours existe ;
2. sa syntaxe Bash est valide ;
3. il utilise les diagnostics attendus sans contenir une commande d'installation ou une suppression dangereuse.

```bash
# Exécute les tests avec la bibliothèque standard Python.
# Aucune installation de dépendance Python n'est nécessaire pour ce chapitre.
python -m unittest tests/test_verifier_installation.py -v
```

Les tests ne simulent pas un fournisseur de modèle ; cela demanderait de vraies identités et des appels externes. Ils sécurisent ce que ce dépôt contrôle réellement : la présence, la syntaxe et le caractère non destructif du script pédagogique.

---

## 8. Limites, diagnostic et bonnes pratiques

### Ce que ce chapitre ne déploie pas encore

Ce chapitre ne crée pas de bot, ne lance pas de tâche cron et n'installe pas de service permanent. Il pose les prérequis nécessaires à ces étapes. Le déploiement sera un chapitre distinct afin de ne pas mélanger installation, secrets, réseau et supervision.

### Bonnes pratiques à conserver

- Fais fonctionner un **chat local** avant d'ajouter gateway, cron, skills ou plugins.
- Garde les secrets hors des commits : ni token Telegram, ni clé API, ni fichier `.env` partagé.
- Utilise `hermes setup`, `hermes model` et `hermes gateway setup` plutôt que de modifier une configuration à la main sans comprendre son effet.
- Lance `hermes doctor` après une installation, une mise à jour ou un comportement inattendu.
- Pour la production, teste d'abord le gateway en avant-plan, puis ajoute seulement ensuite un service, une sauvegarde et des restrictions d'accès.
- Considère les avertissements facultatifs dans leur contexte : ne pas installer Docker ou Playwright si le cas d'usage ne l'exige pas.

## À retenir

1. **Installation ≠ agent fonctionnel** : la preuve est un vrai chat local.
2. Configure **un modèle** avant les automatisations et la messagerie.
3. `hermes doctor` décrit l'état réel de la machine.
4. Le gateway et le déploiement sont des couches supplémentaires qui demandent une validation et une sécurité dédiées.
5. Ne versionne jamais de secrets.
