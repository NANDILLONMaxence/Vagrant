## Bienvenue dans le Repository Vagrant Multiplateforme

En tant qu'étudiant, je suis souvent confronté à la mise en place de nombreuses solutions informatiques, que ce soit pour du développement ou la configuration de services réseau. Dans ma quête de méthodes rapides pour réaliser mes TP, j'ai découvert Vagrant. Cet outil permet de déployer rapidement des machines virtuelles, que ce soit avec Ubuntu, Debian, ou d'autres systèmes d'exploitation Linux. Commençons par les bases.

![Logo Vagrant](https://i.imgur.com/W65dAcT.png)

### Qu'est-ce que Vagrant et quelles machines virtuelles peuvent être créées ?

Vagrant est un outil open-source conçu pour créer et gérer des environnements de développement virtuels. Il simplifie la création, la configuration et le déploiement d'environnements de développement dans des machines virtuelles. Compatible avec divers fournisseurs de machines virtuelles tels que VirtualBox, VMware, Hyper-V et Docker, Vagrant utilise des fichiers de configuration pour décrire les caractéristiques des machines virtuelles, telles que le système d'exploitation, les packages installés, les paramètres réseau, etc.

### Comment installer Vagrant ?

Pour commencer, téléchargez la dernière version de Vagrant depuis [le site officiel](https://www.vagrantup.com/downloads). Une fois téléchargé, exécutez le fichier d'installation et suivez les instructions à l'écran.

Ensuite viens l'installation des plugins Vagrant, en fonctions du fournisseur que vous utilisez.
Par exemple, si vous utilisez VirtualBox, installez les plugins VirtualBox associés avec les commandes suivantes :

#### Plugin VirtualBox

Plugin essentiel :

> **Note :** Le plugin `vagrant-vbguest` permet de maintenir automatiquement à jour les *Guest Additions* de VirtualBox sur la machine virtuelle. Cela assure une compatibilité optimale entre la VM et l'hôte, en particulier pour la synchronisation des dossiers partagés.

```bash
vagrant plugin install vagrant-vbguest
```

Plugin opcionnel :

```bash
vagrant plugin install vagrant-share
vagrant plugin install vagrant-hostmanager
vagrant plugin install vagrant-cachier
```

#### Plugin VMware Workstation

Plugin essentiel :

> **Note :** Le plugin `vagrant-vmware-desktop` permet de maintenir automatiquement à jour les *Guest Additions* de VMware sur la machine virtuelle. Cela assure une compatibilité optimale entre la VM et l'hôte, en particulier pour la synchronisation des dossiers partagés.

```bash
vagrant plugin install vagrant-vmware-desktop
```

Plugin opcionnel :

```bash
vagrant plugin install vagrant-share
vagrant plugin install vagrant-reload
```

#### Vérification des plugins installés

Pour confirmer que les plugins ont été correctement installés :

```bash
vagrant plugin list
```

### Comment créer des machines virtuelles avec Vagrant (ex Ubuntu) ?

Une fois Vagrant installé, suivez ces étapes simples :

1. Créez un nouveau dossier pour votre projet et ouvrez-le dans votre terminal.
2. Initialisez un nouveau projet Vagrant :
   ```bash
   vagrant init
   ```
3. Ouvrez le fichier `Vagrantfile` avec votre éditeur de texte préféré et modifiez la configuration selon vos besoins.
   ```ruby
   config.vm.box = "ubuntu/focal64"
   ```
4. Lancez la machine virtuelle :
   ```bash
   vagrant up
   ```
5. Connectez-vous à la machine virtuelle en utilisant SSH :
   ```bash
   vagrant ssh
   ```

### Comment gérer les machines virtuelles avec Vagrant ?

Utilisez les commandes suivantes pour gérer vos machines virtuelles :

- `vagrant up`: démarrer la machine virtuelle.
- `vagrant halt`: arrêter la machine virtuelle.
- `vagrant reload`: redémarrer la machine virtuelle.
- `vagrant destroy`: supprimer la machine virtuelle.
- `vagrant status`: afficher l'état de la machine virtuelle.
- `vagrant ssh`: se connecter à la machine virtuelle en utilisant SSH.
- `vagrant provision`: exécuter à nouveau les scripts de provisionnement.

Maintenant que vous savez créer des machines virtuelles avec Vagrant (Ubuntu), passons à des utilisations plus avancées.

### Comment automatiser des machines virtuelles avec Vagrant (Ubuntu) ?

Pour automatiser des machines virtuelles, voici un exemple de script Ruby pour la mise en place d'un serveur web PHP avec Ubuntu.

#### Présentation de l'arborescence des fichiers

Organisez vos scripts VagrantFile dans un dossier unique par projet :

```
|- All_VM
  |- Vagrant_VM_Nom_du-projet
  |- Vagrant_Folder_Nom_du-projet
```

#### VagrantFile dans Vagrant_VM :

Configurer les propriétés de la machine virtuelle, l'hyperviseur, l'adresse IP, les ressources de la VM, et la synchronisation avec le dossier Vagrant_Folder.

```ruby
config.vm.box = "ubuntu/focal64"
config.vm.box_url = "https://vagrantcloud.com/ubuntu/focal64"

config.vm.network :private_network, ip: "192.168.56.156"

config.vm.provider "virtualbox" do |vb|
  vb.gui = false
  vb.memory = "2048"
end

config.vm.synced_folder "../Vagrant_Folder", "/var/www/html"

config.vm.provision "shell", inline: <<-SHELL
    # Code Bash Premier Démarrage
SHELL

config.vm.provision "shell", run: "always", inline: <<-SHELL
    # Code Bash Tous Démarrage
SHELL
```

Personnalisez les configurations en fonction de vos besoins. Utilisez ce modèle pour créer des machines virtuelles automatisées avec Vagrant.

## Mise en Place de Boxes et Création d'une Box à Partir d'une VM

### Qu'est-ce qu'une Box Vagrant ?

Une "box" Vagrant est une archive compressée qui contient une image de machine virtuelle prête à être utilisée. Les boxes Vagrant fournissent un moyen efficace de distribuer et de partager des environnements de développement.

### Utilisation de Boxes Existants

1. **Ajouter une Box :**
   Pour utiliser une box existante, ajoutez-la à votre projet avec la commande :

   ```bash
   vagrant box add nom-de-la-box chemin/vers/la-box-file
   ```
2. **Configurer Votre Projet avec la Nouvelle Box :**
   Modifiez le fichier `Vagrantfile` dans votre projet pour utiliser la nouvelle box :

   ```ruby
   config.vm.box = "nom-de-la-box"
   ```
3. **Lancer la Machine Virtuelle :**

   ```bash
   vagrant up
   ```

### Création d'une Box à Partir d'une VM

1. **Préparer la VM :**

   - Assurez-vous que la VM est configurée comme vous le souhaitez.
   - Supprimez les données sensibles ou inutiles de la VM.
2. **Arrêter la VM :**

   ```bash
   vagrant halt
   ```
3. **Packager la VM en tant que Box :**

   ```bash
   vagrant package --output nom-de-la-box.box
   ```

   Cette commande crée une box à partir de la VM actuelle et la stocke dans le fichier `nom-de-la-box.box`.
4. **Ajouter la Nouvelle Box à Vagrant :**

   ```bash
   vagrant box add nom-de-la-box nom-de-la-box.box
   ```
5. **Configurer Votre Projet avec la Nouvelle Box :**
   Modifiez le fichier `Vagrantfile` dans votre projet pour utiliser la nouvelle box :

   ```ruby
   config.vm.box = "nom-de-la-box"
   ```
6. **Lancer la Machine Virtuelle :**

   ```bash
   vagrant up
   ```

### Gestion des Boxes

- **Lister les Boxes Installées :**

  ```bash
  vagrant box list
  ```
- **Supprimer une Box :**

  ```bash
  vagrant box remove nom-de-la-box
  ```

### Conseils Pratiques

- Créez des boxes légères en supprimant les données inutiles avant de les empaqueter.
- Documentez votre box en spécifiant les configurations et les prérequis dans le `README`.

## Personnalisation Avancée et Gestion des Boxes (Suite)

### Personnalisation Avancée des Boxes

#### Configuration Avancée dans le `Vagrantfile`

- **Configurer les Ressources de la VM :**
  Ajoutez ces lignes dans le `Vagrantfile` pour spécifier la mémoire et le nombre de CPU :

  ```ruby
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end
  ```
- **Ajouter des Scripts de Provisionnement :**
  Utilisez des scripts pour installer des logiciels, configurer des services, etc. :

  ```ruby
  config.vm.provision "shell", path: "script.sh"
  ```

### Partager Vos Boxes avec la Communauté

1. **Créer un Compte Vagrant Cloud :**
   [Vagrant Cloud](https://app.vagrantup.com) est une plateforme pour partager des boxes Vagrant.
2. **Se Connecter avec Votre Compte Vagrant Cloud :**

   ```bash
   vagrant login
   ```
3. **Publier la Box sur Vagrant Cloud :**

   ```bash
   vagrant cloud publish utilisateur/nom-de-la-box version \
     virtualbox --force --release
   ```

### Mise à Jour de Vos Boxes

1. **Mettre à Jour la VM et Arrêter :**

   ```bash
   vagrant up
   vagrant halt
   ```
2. **Repackager la VM Mise à Jour :**

   ```bash
   vagrant package --output nom-de-la-box-v2.box
   ```
3. **Mettre à Jour la Box :**

   ```bash
   vagrant box add nom-de-la-box-v2 nom-de-la-box-v2.box --force
   ```

### Conseils de Sécurité

- Limitez les autorisations pour les boxes sensibles.
- Utilisez HTTPS lors de l'hébergement de vos boxes.
