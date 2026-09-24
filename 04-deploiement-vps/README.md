# Déployer Hermes sur un VPS — AWS, Hostinger ou Ubuntu similaire

> **Objectif :** installer Hermes sur un VPS Ubuntu, le tester en local sur le serveur, connecter une plateforme de messagerie, puis le rendre persistant avec le gateway comme service.

Cette procédure fonctionne pour une instance **AWS EC2**, un VPS **Hostinger**, Hetzner, DigitalOcean ou tout fournisseur donnant un accès SSH à Ubuntu récent. Les écrans de création diffèrent selon le fournisseur ; le serveur à préparer reste le même.

Sources : [Installation Hermes](https://hermes-agent.nousresearch.com/docs/getting-started/installation) · [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/) · [CLI Gateway](https://hermes-agent.nousresearch.com/docs/reference/cli-commands).

## 1. Problème concret

Un laptop s'éteint, change de réseau et n'est pas forcément disponible. Un VPS permet au gateway, aux bots et aux tâches cron de rester actifs 24 h/24. En échange, tu dois gérer l'accès SSH, les mises à jour, les secrets, les coûts et la supervision.

Le but n'est pas d'exposer une interface Hermes ouverte sur Internet. Pour Telegram et WhatsApp, le serveur fait généralement des connexions sortantes vers les plateformes. Tu n'ouvres donc pas un port public « juste pour le bot ».

## 2. Architecture et prérequis

```text
Téléphone / Telegram / WhatsApp
              ⇅
      API de la plateforme
              ⇅  connexions sortantes
VPS Ubuntu ── Hermes Gateway ── Fournisseur de modèle
       └── compte Linux non-root, secrets, logs, service
```

### Configuration minimale recommandée

- VPS Ubuntu LTS 22.04 ou 24.04 ;
- au moins 1 vCPU et 1 Go de RAM pour un gateway léger ; 2 Go donnent davantage de marge ;
- accès SSH par clé ;
- un utilisateur Linux non-root avec `sudo` ;
- un fournisseur de modèle déjà choisi ;
- une plateforme de messagerie si tu veux un bot.

Les coûts viennent principalement du VPS et des appels au modèle. Hermes lui-même est léger quand l'inférence est distante.

## 3. Exemple autonome : déploiement sûr de bout en bout

```bash
# Depuis ton ordinateur, génère une clé SSH moderne si tu n'en as pas déjà une.
ssh-keygen -t ed25519 -C "patrice-vps-hermes"

# Connecte-toi au VPS avec l'utilisateur fourni par AWS, Hostinger ou ton installateur Ubuntu.
ssh ubuntu@ADRESSE_IP_DU_VPS

# Mets à jour les paquets de sécurité du serveur après la première connexion.
sudo apt update && sudo apt upgrade -y

# Installe uniquement les prérequis système annoncés par la documentation Hermes.
sudo apt install -y git curl xz-utils

# Télécharge et exécute l'installeur officiel Hermes dans le compte utilisateur courant.
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# Recharge le shell afin de rendre la commande Hermes disponible.
source ~/.bashrc

# Vérifie l'installation et configure un modèle avant de configurer le bot.
hermes doctor
hermes setup

# Teste une conversation locale dans le VPS : c'est le prérequis du gateway.
hermes chat -q "Réponds uniquement : Hermes VPS prêt"
```

N'exécute pas Hermes en `root` sauf besoin exceptionnel et compris. Les fichiers de configuration, credentials, sessions et logs doivent appartenir au compte Linux qui exploite l'agent.

## 4. Créer le VPS chez AWS EC2

1. Ouvre AWS Console → **EC2** → **Launch instance**.
2. Choisis une image Ubuntu LTS officielle.
3. Choisis une petite instance selon ton budget ; vérifie le prix régional avant de créer.
4. Crée ou sélectionne une **Key Pair** SSH et télécharge la clé privée une seule fois.
5. Dans le Security Group, autorise **SSH TCP 22 uniquement depuis ton IP publique**. Ne choisis pas `0.0.0.0/0` si tu peux l'éviter.
6. N'ouvre pas HTTP/HTTPS tant que tu ne déploies pas un dashboard ou un webhook public.
7. Lance l'instance puis récupère son IPv4 publique ou une IP Elastic si tu veux une adresse stable.

```bash
# Restreint localement les permissions de la clé privée téléchargée par AWS.
chmod 400 ~/chemin/vers/ma-cle-aws.pem

# Connecte-toi à l'image Ubuntu standard d'EC2.
ssh -i ~/chemin/vers/ma-cle-aws.pem ubuntu@IP_PUBLIQUE_EC2
```

L'utilisateur SSH peut varier selon l'image (`ubuntu`, `ec2-user`, etc.). Lis le détail de l'AMI choisie plutôt que d'essayer au hasard.

## 5. Créer le VPS chez Hostinger

1. Dans hPanel, crée un **VPS** et sélectionne Ubuntu LTS.
2. Configure une clé SSH lors de la création si l'interface le propose ; sinon, utilise le mot de passe temporaire seulement pour la première connexion puis ajoute une clé.
3. Note l'adresse IP publique et l'utilisateur initial communiqués par Hostinger.
4. Connecte-toi, crée un utilisateur non-root et donne-lui `sudo`.
5. Reconnecte-toi avec ce nouvel utilisateur avant d'installer Hermes.

```bash
# Connecte-toi avec les identifiants initiaux transmis par Hostinger.
ssh root@IP_PUBLIQUE_VPS

# Crée un utilisateur dédié qui exécutera Hermes au lieu de root.
adduser hermes
usermod -aG sudo hermes

# Crée le dossier SSH puis y ajoute ta clé publique depuis ton ordinateur.
install -d -m 700 -o hermes -g hermes /home/hermes/.ssh
# Édite ce fichier avec ta clé publique ed25519, jamais avec ta clé privée.
nano /home/hermes/.ssh/authorized_keys

# Protège le fichier contenant les clés autorisées.
chown hermes:hermes /home/hermes/.ssh/authorized_keys
chmod 600 /home/hermes/.ssh/authorized_keys
```

Ensuite reconnecte-toi avec `ssh hermes@IP_PUBLIQUE_VPS`, vérifie `sudo -v`, puis suis l'exemple autonome du chapitre.

## 6. Sécuriser le serveur avant le gateway

```bash
# Active le pare-feu Ubuntu et autorise SSH avant de bloquer les autres entrées.
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status verbose

# Installe les mises à jour de sécurité automatiques proposées par Ubuntu.
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

- Vérifie que ta clé SSH fonctionne **dans un second terminal** avant de désactiver l'authentification par mot de passe.
- Restreins le port SSH au Security Group AWS et/ou au firewall VPS.
- Pour WhatsApp Cloud API ou un webhook HTTP, ouvre seulement les ports nécessaires, derrière HTTPS, après avoir compris le modèle de sécurité Meta.
- Ne mets pas de token dans une commande shell affichée, dans `history` ou dans Git.

## 7. Connecter le gateway et le rendre persistant

Après avoir validé le chat local, configure Telegram ou WhatsApp :

```bash
# Ouvre l'assistant de messagerie, qui demande les secrets de façon interactive.
hermes gateway setup

# Teste le gateway au premier plan avant de créer un service persistant.
hermes gateway run

# Installe le gateway comme service de fond pour le profil courant.
hermes gateway install --start-now

# Vérifie que le service est en cours de fonctionnement.
hermes gateway status
```

Sur Linux, `hermes gateway install` crée un service systemd/approprié pour le profil. La variante `--system --run-as-user hermes` existe pour une installation système démarrant au boot ; utilise-la uniquement si tu comprends la séparation entre service système et service utilisateur.

```bash
# Variante système Linux : démarre au boot sous l'utilisateur dédié `hermes`.
# À employer après les tests en avant-plan, pas comme première commande.
sudo hermes gateway install --system --run-as-user hermes --start-now
```

Après l'installation, redémarre volontairement le VPS une fois et vérifie que le bot revient en ligne. Cette étape est indispensable : un processus qui marche dans une session SSH n'est pas automatiquement persistant.

## 8. Exploitation : logs, état, sauvegardes et mises à jour

```bash
# Vérifie l'état global de l'agent et de ses composants.
hermes status --all

# Vérifie l'état du gateway après une reconnexion ou un redémarrage.
hermes gateway status

# Suit les logs Hermes pour diagnostiquer un message non reçu.
hermes logs -f

# Crée une archive de sauvegarde avant une opération importante.
hermes backup

# Vérifie les changements disponibles avant une mise à jour planifiée.
hermes update

# Lance un diagnostic complet après la mise à jour.
hermes doctor
```

Planifie des sauvegardes chiffrées hors du VPS. Une sauvegarde peut contenir des configurations et des données de sessions : ne la publie jamais dans GitHub.

## 9. Limites et bonnes pratiques

- **AWS / Hostinger ne remplacent pas la sécurité** : le choix du fournisseur ne protège ni un token divulgué ni un SSH ouvert à tout Internet.
- **Une IP publique n'est pas un webhook HTTPS** : WhatsApp Cloud API demande une URL publique et des contrôles adaptés ; utilise un domaine, TLS et la documentation Meta.
- **Teste par couches** : SSH → `hermes doctor` → chat local → gateway en premier plan → service → reboot.
- **Utilise un profil et un utilisateur dédiés** pour un bot partagé ou de production.
- **Surveille la consommation** avec `hermes insights` et le tableau du provider, surtout lorsqu'un bot est accessible à plusieurs personnes.
- **Mets à jour avec méthode** : sauvegarde, mise à jour, doctor, test chat, test gateway.

## À retenir

Le chemin robuste est : **VPS Ubuntu sécurisé → Hermes sous un utilisateur non-root → chat local validé → gateway testé au premier plan → service installé → reboot et surveillance.**
