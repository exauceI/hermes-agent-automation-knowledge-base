# Se connecter à Hermes à distance en mode CLI — SSH et tmux

> **Objectif :** utiliser l'installation Hermes qui tourne sur ton VPS depuis ton ordinateur, sans exposer le terminal Hermes sur Internet et sans perdre un travail long si la connexion SSH se coupe.

Cette formation complète le [déploiement VPS](../04-deploiement-vps/README.md). Le principe est simple : **tu te connectes de façon sécurisée au serveur via SSH, puis tu lances Hermes sur le serveur.** Les modèles, les sessions, les skills et les credentials utilisés sont alors ceux du VPS, pas ceux de ton ordinateur local.

## 1. Problème concret

Après avoir installé Hermes sur un VPS, tu veux pouvoir reprendre une session, lancer un diagnostic ou travailler avec l'agent depuis ton laptop. Une session SSH ordinaire peut se couper à cause du Wi-Fi, de la veille ou d'un changement de réseau. Si Hermes est lancé directement dans cette session, l'interface interactive peut s'arrêter avec elle.

La méthode robuste est :

```text
Ordinateur personnel
       │  SSH chiffré par clé
       ▼
VPS Ubuntu sous utilisateur non-root
       │
       ├── tmux : session terminal persistante
       │      └── hermes : chat interactif distant
       │
       └── hermes chat -q : tâches ponctuelles scriptables
```

## 2. Concepts essentiels

- **SSH** : protocole chiffré pour ouvrir un terminal distant. Il ne faut pas le confondre avec le gateway Hermes.
- **Clé SSH** : paire cryptographique ; la clé privée reste sur ton ordinateur, la clé publique est placée sur le VPS.
- **`~/.ssh/config`** : fichier local qui donne un alias lisible à un serveur et évite de répéter l'IP et le chemin de clé.
- **PTY** : pseudo-terminal requis par une interface interactive comme le CLI Hermes.
- **tmux** : multiplexeur terminal. Une session tmux survit à la déconnexion SSH ; tu peux t'y rattacher plus tard.
- **Gateway** : service de messagerie autonome. Il ne remplace pas SSH pour administrer le serveur en CLI.

## 3. Exemple autonome complet : connexion, session persistante, reprise

### Sur ton ordinateur : créer une clé et un alias SSH

```bash
# Crée une clé moderne. La clé privée reste sur cet ordinateur et doit rester secrète.
ssh-keygen -t ed25519 -C "patrice-hermes-vps"

# Ouvre ou crée la configuration SSH locale avec des permissions restrictives.
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/config
```

Ajoute cet exemple dans `~/.ssh/config`. Remplace uniquement les valeurs entre crochets ; ne copie jamais une vraie clé privée dans ce fichier.

```sshconfig
# Alias local : il remplace une adresse IP difficile à mémoriser.
Host hermes-vps
    # Adresse IP publique ou nom DNS de ton VPS.
    HostName [IP_OU_DNS_DU_VPS]
    # Utilisateur Linux non-root créé pour exécuter Hermes.
    User hermes
    # Chemin local vers ta clé privée ; elle ne quitte jamais ton ordinateur.
    IdentityFile ~/.ssh/id_ed25519
    # Refuse l'authentification par mot de passe après validation de la clé.
    PasswordAuthentication no
    # Ferme une connexion bloquée après trente secondes.
    ConnectTimeout 30
```

```bash
# Protège la configuration SSH locale, qui peut contenir des informations d'hôtes.
chmod 600 ~/.ssh/config

# Ouvre un terminal chiffré sur le VPS via l'alias défini ci-dessus.
ssh hermes-vps
```

### Sur le VPS : créer ou rejoindre la session Hermes persistante

```bash
# Installe tmux une seule fois sur le VPS. Cette commande modifie le serveur.
sudo apt update && sudo apt install -y tmux

# Crée une session tmux nommée `hermes-cli` et lance le CLI Hermes à l'intérieur.
# Si tmux existe déjà, cette commande rejoint simplement la session existante.
tmux new-session -A -s hermes-cli 'hermes --cli'
```

Tu es maintenant dans Hermes sur le VPS. Travaille normalement. Pour te détacher sans arrêter Hermes, tape la combinaison **Ctrl-b**, puis **d**. Elle te ramène au shell du VPS, mais la session continue en arrière-plan.

### Plus tard : reprendre depuis un autre réseau

```bash
# Reconnecte-toi au serveur, quelle que soit l'adresse réseau de ton ordinateur.
ssh hermes-vps

# Rouvre exactement la session terminal persistante et son agent encore actif.
tmux attach -t hermes-cli
```

Si tu avais quitté Hermes mais pas tmux, relance `hermes --continue` dans tmux pour reprendre la dernière session Hermes enregistrée.

## 4. Décomposition : choisir la bonne méthode

### A. Travail interactif long : SSH + tmux

```bash
# Crée ou rejoint une session tmux déjà nommée ; `-A` évite une erreur si elle existe.
tmux new-session -A -s hermes-cli

# Lance le CLI classique Hermes dans cette session persistante.
hermes --cli
```

C'est la meilleure méthode pour coder, discuter longtemps, approuver des actions ou voir les outils fonctionner. `tmux` protège contre les coupures réseau, mais ne remplace pas les sauvegardes et ne garantit pas qu'une tâche externe très longue terminera.

### B. Question ponctuelle : SSH avec une commande unique

```bash
# Exécute une question non interactive sur le VPS puis ferme la connexion.
# Les guillemets protègent la consigne jusqu'à son arrivée sur le serveur distant.
ssh hermes-vps 'hermes chat -q "Donne le statut du projet courant en trois points."'
```

Cette méthode est idéale pour un contrôle, une tâche cron externe ou une commande depuis un autre script. Elle n'est pas adaptée à un échange interactif nécessitant confirmations et tours multiples.

### C. Reprendre une session enregistrée Hermes

```bash
# Liste les conversations mémorisées sur le VPS pour retrouver un identifiant ou un titre.
hermes sessions list

# Reprend la session la plus récente depuis le shell distant.
hermes --continue

# Reprend explicitement une session donnée pour ne pas reprendre la mauvaise.
hermes --resume "titre-ou-identifiant-de-session"
```

Les sessions Hermes sont stockées sur le VPS. Elles ne sont pas automatiquement copiées vers ton ordinateur local : c'est précisément pourquoi il faut se connecter à la machine où l'agent s'exécute.

## 5. Brique réutilisable : un raccourci local sûr

Ajoute cette fonction à `~/.bashrc` ou `~/.zshrc` **sur ton ordinateur local**, puis ouvre un nouveau terminal.

```bash
# Ouvre le VPS, puis rejoint ou crée la session tmux où Hermes est exécuté.
hermes_vps() {
  # `exec` remplace le shell local par SSH et propage correctement la fermeture.
  exec ssh -t hermes-vps 'tmux new-session -A -s hermes-cli "hermes --cli"'
}
```

Le `-t` force l'allocation d'un pseudo-terminal, nécessaire à un CLI interactif. Utilisation :

```bash
# Lance le raccourci ; tu arrives directement dans Hermes sur le VPS.
hermes_vps
```

N'ajoute pas de mot de passe, token ou clé API dans ce raccourci. La clé SSH est gérée par OpenSSH et les identifiants Hermes restent stockés sur le VPS.

## 6. Exemple réaliste : administration distante du gateway

Tu n'as pas besoin de rester connecté à tmux pour que le gateway fonctionne : il doit être installé comme service. SSH sert à le contrôler et à diagnostiquer.

```bash
# Vérifie l'état de tous les composants Hermes à distance.
ssh hermes-vps 'hermes status --all'

# Vérifie si le gateway du profil courant est bien démarré.
ssh hermes-vps 'hermes gateway status'

# Suit les logs à distance ; Ctrl-c interrompt seulement l'affichage local.
ssh -t hermes-vps 'hermes logs -f'

# Analyse la consommation récente des sessions hébergées sur le VPS.
ssh hermes-vps 'hermes insights --days 7'
```

Après une mise à jour ou un changement de configuration, fais dans l'ordre : `hermes doctor`, un `hermes chat -q` local au VPS, puis un message réel sur Telegram ou WhatsApp.

## 7. Vérifications et dépannage

```bash
# Vérifie le mode verbeux SSH si une connexion échoue ; ne partage pas toute cette sortie publiquement.
ssh -v hermes-vps

# Vérifie que tmux voit les sessions persistantes sur le VPS.
ssh hermes-vps 'tmux list-sessions'

# Vérifie l'installation Hermes du serveur sans changer sa configuration.
ssh hermes-vps 'hermes doctor'

# Vérifie que le port SSH est atteignable depuis ton réseau actuel.
ssh -o ConnectTimeout=10 hermes-vps 'echo "SSH et Hermes VPS accessibles"'
```

Si `tmux attach` indique qu'aucune session n'existe, le serveur a peut-être redémarré ou tmux a été fermé. C'est normal : reconnecte-toi et relance `tmux new-session -A -s hermes-cli 'hermes --cli'`. Le gateway, lui, doit être géré par `hermes gateway install`, pas par tmux.

## 8. Limites et bonnes pratiques de sécurité

- N'expose pas le port d'un terminal Hermes ou d'un dashboard sans mécanisme d'authentification solide. SSH est le canal d'administration recommandé.
- Utilise des clés SSH, pas un mot de passe. Teste une seconde connexion par clé avant de désactiver les mots de passe côté serveur.
- Restreins SSH dans le Security Group AWS et le firewall UFW à ton IP lorsque c'est possible.
- N'utilise pas `--yolo` dans une session distante de production : les confirmations sont une protection utile.
- Sépare le compte Linux qui exécute Hermes, les profils Hermes et les clés SSH selon les usages personnel / test / production.
- tmux protège une session interactive contre la coupure réseau ; il ne remplace ni la supervision d'un service, ni une sauvegarde, ni des limites de consommation.

## À retenir

Pour administrer Hermes à distance : **clé SSH → alias `hermes-vps` → tmux pour l'interactif → `ssh hermes-vps 'hermes chat -q …'` pour le ponctuel → `hermes gateway status` pour le bot en service.**
