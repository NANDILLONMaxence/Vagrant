# Installation & Configuration par Vagrant pour un environnement composé d'un serveur Apache et d'un client avec une interface GNOME

But : Le fichier VagrantFile permet de déployer deux machines virtuelles, l'une avec un serveur Apache + DNS et l'autre avec un environnement GNOME avec une redirection à l'ouverture de la page Firefox sur la page apache du serveur web via son IP et son nom de domaine.

## Configuration de la machine serveur Apache

### Informations de la machine
- Nom d'hôte: server-apache
- Adresse IP: 192.168.56.10
- Utilisateurs:
  - root-max: Mot de passe - max
  - vienne: Mot de passe - Vienne36!

### Services installés
- Apache2
- Bind9 (Serveur DNS)
- Openssh-server

## Configuration de la machine cliente avec GNOME

### Informations de la machine
- Nom d'hôte: client
- Adresse IP: 192.168.56.20
- Utilisateurs:
  - user: Mot de passe - user
  - root-max: Mot de passe - max
  - vienne: Mot de passe - Vienne36!

### Services installés
- GNOME
- Openssh-client

---
### Instructions

1. Clonez le dépôt.
2. Lancer un terminal de puis le répertoire ( shift clique droit ouvrir avec... )
3. Exécutez `vagrant up` pour lancer l'installation des machines.
4. Pour comprendre et voir les configurations des deux machines, vous pouvez ouvrir le fichier VagrantFile.

## Accès SSH

### Serveur Apache
- Utilisateur: root-max
  - Connexion locale: `vagrant ssh server`
  - Connexion à distance: `ssh vienne@127.0.0.1 -p 2222` ou `ssh vienne@192.168.56.10`

### Client GNOME
- Utilisateur: user
  - Connexion locale: `vagrant ssh client` ou via l'interface graphique

**Note**
- Si l'interface GNOME ne se lance pas automatiquement, connectez-vous et exécutez `gdm` dans le terminal.
- Si vous avez une "erreur" du type Building the VirtualBox Guest Additions kernel ...
  * Relancer manuellement la machine et refaite un vagrant up 
- Pensé à supprimer les clés similaires dans le fichier ~/.ssh/known_host.

Pour plus d'informations sur la configuration des services et les détails des scripts d'installation, consultez le fichier Vagrantfile.
