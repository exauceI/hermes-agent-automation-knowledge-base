# Connecter Hermes à Telegram et WhatsApp

> **Objectif :** connecter un agent Hermes déjà fonctionnel en local à Telegram ou WhatsApp, contrôler les accès, tester le gateway au premier plan puis le préparer à fonctionner durablement.

Prérequis : l'installation locale et le premier chat doivent déjà fonctionner. Commence par la [formation d'installation](../01-fondations/01-installation-et-verification/README.md) puis vérifie `hermes doctor`.

Sources officielles : [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/) · [Telegram](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram) · [WhatsApp Baileys](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/whatsapp) · [WhatsApp Business Cloud API](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/whatsapp-cloud).

## 1. Problème concret

Le CLI est idéal pour une personne sur un terminal. Un gateway rend le même agent accessible depuis un téléphone, une équipe ou un canal de discussion. Il reçoit les messages, les dirige vers une session Hermes, livre les réponses et fait aussi fonctionner les jobs cron.

Cette puissance implique un risque : une personne non autorisée pourrait demander à un agent avec outils d'agir sur le serveur. La configuration d'accès est donc aussi importante que la connexion technique.

## 2. Concepts et choix

- **Bot Telegram** : compte automatisé créé dans `@BotFather`, identifié par un token secret.
- **Gateway** : processus Hermes qui reste actif pour recevoir les messages.
- **Allowlist / autorisation** : liste des personnes ou chats autorisés à utiliser le bot.
- **WhatsApp Baileys** : bridge qui émule une session WhatsApp Web ; adapté à des tests ou un compte personnel, avec QR code.
- **WhatsApp Business Cloud API** : API officielle Meta ; adaptée à la production, demande un compte Business et une URL webhook publique.

**Choix WhatsApp :** Baileys est simple pour expérimenter ; Cloud API est le chemin production. Ne les mélange pas : ils n'ont ni les mêmes identifiants ni les mêmes contraintes.

## 3. Exemple autonome : le flux commun à toute plateforme

```bash
# Vérifie d'abord l'installation et la configuration Hermes existantes.
hermes doctor

# Lance l'assistant de configuration officiel des plateformes.
# Il guide le choix de Telegram, WhatsApp ou une autre intégration.
hermes gateway setup

# Teste le gateway au premier plan : les erreurs de connexion restent visibles dans le terminal.
hermes gateway run

# Dans un second terminal, vérifie l'état du service ou du gateway configuré.
hermes gateway status
```

N'installe pas encore un service permanent. Envoie d'abord un message depuis la plateforme et vérifie qu'il arrive, qu'une réponse repart et que seul l'utilisateur autorisé peut interagir.

## 4. Telegram, étape par étape

### Créer le bot

1. Dans Telegram, ouvre `@BotFather`.
2. Envoie `/newbot`.
3. Choisis un nom visible et un identifiant qui se termine par `bot`.
4. Copie le token fourni **dans un gestionnaire sûr** ou saisis-le seulement dans le wizard Hermes.
5. Ne le colle jamais dans ce README, un script, un commit, une capture ou un chat public.

### Configurer Hermes

```bash
# Ouvre le wizard et sélectionne Telegram lorsqu'il le propose.
hermes gateway setup

# Démarre le gateway au premier plan après la configuration.
hermes gateway run
```

Le wizard demande le token et les règles d'accès. Utilise ton **identifiant numérique Telegram**, pas seulement ton `@username`, pour les listes d'autorisation. Ton username peut changer ; l'identifiant numérique reste stable. Tu peux l'obtenir auprès de `@userinfobot` sur Telegram.

### Tester proprement

1. Ouvre le chat privé avec ton bot et envoie `/start` ou un message simple.
2. Vérifie que le bot répond avec le modèle Hermes attendu.
3. Essaie depuis un compte non autorisé si possible : le bot ne doit pas donner accès à l'agent.
4. Consulte les logs si nécessaire : `hermes logs -f`.

Pour un groupe, commence avec une allowlist réduite et une configuration d'outils prudente. Un bot de groupe ne doit pas recevoir automatiquement l'accès à tout le système.

## 5. WhatsApp : deux chemins distincts

### A. WhatsApp personnel / laboratoire : bridge Baileys

```bash
# Lance le configurateur WhatsApp basé sur QR code.
hermes whatsapp

# Démarre ensuite le gateway et observe la connexion.
hermes gateway run
```

Le configurateur présente un QR code. Scanne-le depuis WhatsApp avec la fonction **Appareils connectés**. Cette méthode émule WhatsApp Web ; elle ne demande pas de compte Meta développeur, mais n'est pas le meilleur choix pour une application métier durable. Évite d'utiliser ton compte principal pour des essais sensibles.

### B. Production : WhatsApp Business Cloud API

La Cloud API Meta est la voie officielle. Elle demande :

1. un compte Meta Business ;
2. une application Meta configurée pour WhatsApp ;
3. un numéro WhatsApp Business ;
4. un token d'accès géré comme un secret ;
5. une URL HTTPS publique pour recevoir le webhook Meta.

```bash
# Ouvre le configurateur dédié à la Cloud API officielle Meta.
hermes whatsapp-cloud

# Vérifie les détails de l'adaptateur et les prérequis de webhook avant le déploiement.
hermes whatsapp-cloud --help
```

Ne déploie pas la Cloud API sur un serveur accessible sans HTTPS et sans filtrage des requêtes webhook. Le chapitre VPS explique comment préparer la machine ; la configuration exacte Meta doit suivre sa documentation actuelle.

## 6. Brique réutilisable : contrôles avant le gateway

```bash
# Vérifie que le modèle et les dépendances de l'agent sont sains avant d'ajouter une plateforme.
hermes doctor

# Affiche la configuration et l'état général sans écrire de secret à l'écran.
hermes status --all

# Vérifie les plateformes et services de gateway connus par ce profil.
hermes gateway list
```

Ce pré-vol doit être répété après chaque changement de provider, de profil, de réseau ou de système de service.

## 7. Tests de connexion et diagnostic

```bash
# Lance le gateway au premier plan pour lire les erreurs en direct.
hermes gateway run

# Dans un autre terminal, suit les logs Hermes pendant l'envoi d'un message test.
hermes logs -f

# Vérifie le statut une fois le test terminé.
hermes gateway status
```

Critères de réussite : le gateway se connecte, un utilisateur autorisé reçoit une réponse, un utilisateur non autorisé ne reçoit pas d'accès, et aucun token n'apparaît dans les logs ou Git.

## 8. Limites et bonnes pratiques

- Le gateway porte les mêmes capacités que l'agent local : limite les outils avant de le rendre accessible à d'autres personnes.
- Utilise un profil dédié à un bot partagé si ses mémoires, skills ou outils doivent être différents de ceux de ton agent personnel.
- Teste au premier plan avant `hermes gateway install`.
- Pour Telegram, révoque le token dans BotFather si tu penses l'avoir exposé.
- Pour WhatsApp Baileys, le QR code établit une session liée à un compte ; traite-la comme un accès sensible.
- Pour WhatsApp Cloud API, préfère une URL HTTPS, des webhooks validés et des secrets stockés hors Git.

## À retenir

**Telegram :** BotFather → `hermes gateway setup` → test avec `hermes gateway run`.

**WhatsApp personnel :** `hermes whatsapp` → QR code → test gateway.
**WhatsApp production :** Meta Business + Cloud API + webhook HTTPS → `hermes whatsapp-cloud`.
