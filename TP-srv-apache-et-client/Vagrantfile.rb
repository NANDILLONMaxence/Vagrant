# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

    config.vm.box = "debian/bullseye64"
    config.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.memory = "512"
      vb.cpus = 2
    end
  
    # Server avec Apache
    config.vm.define "server" do |server|
      # Nommage de la machine
      server.vm.hostname = "server-apache"
      # Interface reseau
      server.vm.network "private_network", ip: "192.168.56.10"
      # Redirection de port pour le ssh
      # La redirection ne sert a rien, car elle est deja appliquee par defaut. 
      # server.vm.network "forwarded_port", guest: 22, host: 2222

      # Script d'installation et de configuration
      server.vm.provision "shell", inline: <<-SHELL
         # Plugin VirtualBox Guest Additions
         /sbin/rcvboxadd quicksetup all
         # Mise a jour & install packets
         echo 'deb http://deb.debian.org/debian/ bullseye-backports main' >> /etc/apt/sources.list
         apt update
         apt upgrade -y
         apt install -y openssh-server apache2 bind9

         # Configuration du service DNS

         # Pre-requis a la l'installation d'un DNS Maitre du reseau local
         # Configuration /etc/host.conf
         echo "order hosts, bind" | tee -a /etc/host.conf
         echo "multi on" | tee -a /etc/host.conf

         # Configuration /etc/hosts
         # Modification du nom de domaine du localhost
         sed -i 's/127.0.0.1[[:space:]]*localhost[[:space:]]*$/127.0.0.1\tlocalhost.nandillon.local\tlocalhost/' /etc/hosts
         # Enregistrer les noms de domaine du serveur apache et de l'utilisateur 
         sed -i '3i 192.168.56.10\tserveur-apache.nandillon.local\tserveur-apache\n192.168.56.20\tclient' /etc/hosts

         # Mise a jour automatique pour le resolv.conf
         # Creation d'un deamon pour mettre a jour le resolv.conf automatiquement au demarrage
         echo '#!/bin/sh' > /etc/network/if-up.d/update-resolv-conf
         echo 'echo "domain nandillon.local" > /etc/resolv.conf' >> /etc/network/if-up.d/update-resolv-conf
         echo 'echo "search nandillon.local" > /etc/resolv.conf' >> /etc/network/if-up.d/update-resolv-conf
         echo 'echo "nameserver 127.0.0.1" > /etc/resolv.conf' >> /etc/network/if-up.d/update-resolv-conf
         chmod +x /etc/network/if-up.d/update-resolv-conf

         # Config Bind9
         # Fichier named.conf.local
         echo 'zone "nandillon.local" {' >> /etc/bind/named.conf.local
         echo '    type master;' >> /etc/bind/named.conf.local
         echo '    file "/etc/bind/db.nandillon.local";' >> /etc/bind/named.conf.local
         echo '};' >> /etc/bind/named.conf.local

         # Fichier db.nandillon.local
         echo '$TTL 604800' > /etc/bind/db.nandillon.local
         echo '@ IN SOA server-apache.nandillon.local. root.nandillon.local. (' >> /etc/bind/db.nandillon.local
         echo '                  1     ; Serial' >> /etc/bind/db.nandillon.local
         echo '             604800     ; Refresh' >> /etc/bind/db.nandillon.local
         echo '              86400     ; Retry' >> /etc/bind/db.nandillon.local
         echo '            2419200     ; Expire' >> /etc/bind/db.nandillon.local
         echo '             604800 )   ; Negative Cache TTL' >> /etc/bind/db.nandillon.local
         echo ';' >> /etc/bind/db.nandillon.local
         echo '@        IN      A       192.168.56.10' >> /etc/bind/db.nandillon.local
         echo '@        IN      NS      server-apache.nandillon.local.' >> /etc/bind/db.nandillon.local
         echo 'server-apache   IN      A       192.168.56.10' >> /etc/bind/db.nandillon.local
         echo 'client          IN      A       192.168.56.20' >> /etc/bind/db.nandillon.local
        
         # Activation / start bind9
         systemctl restart bind9
         systemctl enable bind9

         # Activation / start apache2
         systemctl enable apache2
         systemctl start apache2

         # Code html
         echo "<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
         <html>
          <head>
             <title>Site BTS SIO</title>
             <style>
                 .navbar {
                     list-style-type: none;
                     margin: 0;
                     padding: 0;
                     overflow: hidden;
                     background-color: #333;
                 }
  
                 .navbar li a {
                     display: block;
                     color: white;
                     text-align: center;
                     padding: 14px 16px;
                     text-decoration: none;
                 }
  
                 .navbar li a:hover {
                     background-color: #111;
                 }
  
                 h1 {
                     color: blue;
                 }
  
                 p {
                     font-family: verdana, sans-serif;
                     font-size: 14px;
                 }
  
                 address {
                     color: #666;
                     font-size: 12px;
                 }
             </style>
         </head>
         <body>
             <ul class="navbar">
                 <li><a href="index.html">Home page</a></li>
                 <li><a href="reflexions.html">Reflexions</a></li>
                 <li><a href="ville.html">Ma ville</a></li>
                 <li><a href="liens.html">Liens</a></li>
             </ul>
  
             <h1>Ma premiere page avec du style</h1>
  
             <p>Bienvenue sur ma page avec du style!</p>
  
             <p>Il lui manque des images, mais au moins, elle a du style. Et elle a des liens, meme s'ils ne menent nulle part...  &hellip;</p>
  
             <address>Fait le 14 decembre 2023<br>par moi.</address>
          </body>
         </html>" | tee /var/www/html/index.html

         systemctl restart apache2

         # Configuration du nouveau port SSH
         sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
         #sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
         #sed -i '/^#AuthorizedKeysFile/ s/.*/AuthorizedKeysFile %h\/.ssh\/authorized_keys/' /etc/ssh/sshd_config

         # Configuration apache et restart
         echo "ServerName 192.168.56.10" >> /etc/apache2/apache2.conf
         systemctl restart apache2

         # Creation utilisateurs
         # --gecos permet de skip les informations demmandees nom, prenom, numero ...
         # Utilisateur root
         adduser --gecos "" root-max
         echo "root-max:max" | chpasswd
         usermod -aG sudo root-max

         # Utilisateur vienney
         adduser --gecos "" vienne
         echo "vienne:Vienne36!" | chpasswd
         # Ajout des droits de modification sur la page html
         chown vienne:vienne /var/www/html/index.html
         # Creation repertoire .ssh 
         mkdir -p /home/vienne/.ssh
         chown -R vienne:vienne /home/vienne/.ssh
         systemctl restart sshd

         # Ajout de l'address du DNS sur les interfaces reseaux
         echo "dns-nameservers 192.168.56.10" | tee -a /etc/network/interfaces

         # Ajouter le clavier en azerty
         localectl set-keymap fr
         # Changer la langue du systeme en francais
         localectl set-locale LANG=fr_FR.UTF-8
         # definir le fuseau horaire sur Paris
         ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
         reboot
       SHELL
    end


    # Creation de la machine cliente
    config.vm.box = "debian/bullseye64"
    config.vm.provider :virtualbox do |vb|
      # Indique que nous souhaitons activer l'interface graphique pour la machine virtuelle
      vb.gui = true
      vb.memory = "2048"
      vb.cpus = 2
    end

    # Client avec GNOME
    config.vm.define "client" do |client|
      # Nommage de la machine 
      client.vm.hostname = "client"
      # Interface reseau
      client.vm.network "private_network", ip: "192.168.56.20"

      # Script d'installation et de configuration
      client.vm.provision "shell", inline: <<-SHELL
         # Plugin VirtualBox Guest Additions
         /sbin/rcvboxadd quicksetup all

         # Mise a jour & install packets
         echo 'deb http://deb.debian.org/debian/ bullseye-backports main' >> /etc/apt/sources.list
         apt update
         apt upgrade -y
         apt install -y gnome openssh-client

         # Ajouter l'utilisateur user a la machine
         # --gecos permet de skip les informations demmandees nom, prenom, numero ...
         # Utilisateur root max
         adduser --gecos "" root-max
         echo "root-max:max" | chpasswd
         usermod -aG sudo root-max

         # Utilisateur vienne
         adduser --gecos "" vienne
         echo "vienne:Vienne36!" | chpasswd

         # Utilisateur user
         adduser --gecos "" user
         echo "user:user" | chpasswd

         # Restart / start interface gnome et ssh 
         systemctl mask gdm
         systemctl unmask gdm
         systemctl start gdm

         # Configurez la page d'accueil de Firefox pour tous les utilisateurs
         # Redirection a l'ouverture de firefox vers l'IP du server apache 
         # echo 'pref("browser.startup.homepage", "http://192.168.56.10");' | tee /usr/lib/firefox-esr/browser/defaults/preferences/all-users.js > /dev/null
         # Redirection a l'ouverture de firefox vers le nom de domain du serveur apache
         echo 'pref("browser.startup.homepage", "http://server-apache.nandillon.local");' | tee /usr/lib/firefox-esr/browser/defaults/preferences/all-users.js > /dev/null

         # Ajout de l'address du DNS sur les interfaces reseaux
         echo "dns-nameservers 192.168.56.10" | tee -a /etc/network/interfaces

         # Creation d'un deamon pour mettre a jour le resolv.conf automatiquement au demarrage
         echo '#!/bin/sh' > /etc/network/if-up.d/update-resolv-conf
         echo 'echo "domain nandillon.local" > /etc/resolv.conf' >> /etc/network/if-up.d/update-resolv-conf
         echo 'echo "search nandillon.local" > /etc/resolv.conf' >> /etc/network/if-up.d/update-resolv-conf
         echo 'echo "nameserver 192.168.56.10" > /etc/resolv.conf' >> /etc/network/if-up.d/update-resolv-conf
         chmod +x /etc/network/if-up.d/update-resolv-conf
        
         # Ajouter le clavier en azerty
         localectl set-keymap fr
         # Changer la langue du systeme en francais
         localectl set-locale LANG=fr_FR.UTF-8
         # Definir le fuseau horaire sur Paris
         ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
         reboot
      SHELL
    end
    config.vm.post_up_message = <<-MESSAGE
     Server-apache
     Utilisateur : root-max - Mot de passe : max
     Utilisateur : vienne - Mot de passe : Vienne36!

     SSH
     vagrant ssh server
     ssh vienne@127.0.0.1 -p 2222
     ssh vienne@192.168.33.10

     Client
     Utilisateur : user - Mot de passe : user
     Utilisateur : root-max - Mot de passe : max
     Utilisateur : vienne - Mot de passe : Vienne36!
     Si l'interface ne se lance pas connecter vous et taper gdm.
   MESSAGE
end 

