# Développement Odoo avec le build d'une image


Contexte :
------

**_Pourquoi ?_**

Dans un premier temps c'était surtout pour apprendre et progresser sur la partie Docker.
C'est un monde que je connaissais très peu, seulement entendu parler à travers quelques discussions et dans lequel je n'avais jamais mis les pieds.

J'ai l'habitude de travailler sur Odoo avec des virtualenv pour mes différents projets en local.
Cela fonctionne très bien mais je souhaitais découvrir un peu plus Docker et progresser sur ce point.

Bien sur Odoo propose déjà [des images prêtes à l'emploi](https://hub.docker.com/_/odoo) mais c'est plus dans une optique de test de la version que pour le développement et la maintenance d'un projet sous Odoo.

Les Dockfiles présents dans ce repos sont basés sur le travail de [@junariltd](https://github.com/junariltd/junari-odoo-docker)

Merci à [@junariltd](https://github.com/junariltd/), pour leurs articles et leur exemple de [Dockerfile](https://github.com/junariltd/junari-odoo-docker) qui m'ont permis de tester et de me lancer.
D'ailleurs je vous conseille de lire les articles suivants qui m'ont permis d'avancer :

- [Running Odoo in Docker](https://medium.com/@dupski/odoo-development-running-odoo-in-docker-85a4cd41b4f0)
- [Database in a Docker container](https://wkrzywiec.medium.com/database-in-a-docker-container-how-to-start-and-whats-it-about-5e3ceea77e50)
- [How to Restore Database Dumps for Postgres in Docker Container](https://simkimsia.com/how-to-restore-database-dumps-for-postgres-in-docker-container/)
- Et bien sur la [documentation Docker](https://docs.docker.com/) pour des points précis

Utilisation des images et création d'un projet (avec une base de données) :
------

**_Quoi ?_**

Les informations présentées ici ne sont pas les seules et uniques méthodes de fonctionnement avec Docker et Odoo.  
Mais elles ont pour but de poser une première base de compréhension et de réflexion pour l'utilisation de Docker dans le développement et la maintenance Odoo.

Ici nous allons voir comment utiliser les Dockerfiles pour monter les images Odoo afin de les utiliser pour du développement Odoo.

Les images suivantes sont basées sur un Ubuntu 18.04 :
- odoo-8.0
- odoo-11.0
- odoo-12.0
- odoo-13.0

Les images suivantes sont basées sur un Ubuntu 20.04 :
- odoo-14.0

Odoo n'est pas installé en tant que package système, il est utilisé en mode "code source".
Odoo sera placé dans `/opt/odoo`.  
Le fichier de configuration sera dans `/etc/odoo`.  
(il est possible d'utiliser votre fichier de configuration dans le plaçant dans le dossier `./config` de votre projet)

**_Comment ?_**

**1. Création de votre répertoire "projet"**

```shell
$ mkdir -p ./my-projet/config
$ mkdir -p ./my-projet/custom_addons
$ cd my-projet
```

`my-projet/config`: contiendra le fichier de configuration odoo personnalisé  
`my-projet/custom_addons`: contiendra les différents addons du projet non standard à Odoo


**2. Build de l'image avec le Dockerfile**

Récupérez le **Dockerfile** en fonction de la version d'Odoo que vous souhaitez utiliser.  
(vous pouvez le déplacer dans le répertoire projet mais ce n'est pas obligatoire)

Montez l'image vous vers le répertoire contenant le Dockerfile
```shell
$ docker build -t IMAGE_NAME:IMAGE_TAG /path/to/the/Dockerfile
```

Entrez la commande suivante avec :
 - IMAGE_NAME = le nom de l'image (par exemple my-odoo-11.0)
 - IMAGE_TAG = le tag de l'image (par exemple 0.1)  

Dans mon exemple (le Dockerfile est dans mon répertoire projet) :
```shell
$ docker build -t my-odoo-11.0:0.1 .
```

L'option `-t` permet de "nommer" l'image qui sera créée.  
Il est possible de la nommer par la suite après création avec son id à récupérer via `docker images`.
```shell
$ docker tag IMAGE_ID IMAGE_NAME:IMAGE_TAG
```

**3. Création de votre `docker-compose.yml`**

Ce fichier permet de décrire (à travers un fichier YML) et de gérer plusieurs conteneurs docker comme un ensemble de service inter-connectés.  
Par exemple pour Odoo on a besoin du serveur Odoo et de la base de données Postgresql afin de pouvoir utiliser l'application.

Le fait de mettre en place ce fichier permettra de faciliter le lancement des conteneurs.

Voici un exemple de `docker-compose.yml` fonctionnel avec les images.  

```yaml
version: '2'
services:
  web:
    image: my-odoo-11.0:0.1
    depends_on:
      - db
    ports:
      - 8069:8069
    environment:
      - DB_HOST=db
      - DB_PORT=5432
      - DB_USER=odoo
      - DB_PASSWORD=odoo
    volumes:
      - myproject-odoo-data:/opt/odoo/data
      - ./config:/etc/odoo
      - ./custom_addons:/opt/odoo/custom_addons
    stdin_open: true
    tty: true
    extra_hosts:
      - "host.docker.internal:host-gateway"
  db:
    image: postgres:12
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_PASSWORD=odoo
      - POSTGRES_USER=odoo
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - myproject-db-data:/var/lib/postgresql/data/pgdata
      - myproject-backups-data:/backups
volumes:
  myproject-odoo-data:
  myproject-db-data:
  myproject-backups-data:
```

On ne verra pas en profondeur ici chaque partie de ce fichier.
Je vous renvoie vers [Overview of Docker Compose](https://docs.docker.com/compose/) pour plus de détail

Ce qu'il faut retenir ici c'est qu'on définit deux services `web` et `db`.  
Nous aurions pu les appeler `odoo` et `postresql` par exemple.  
```yaml
version: '2'
services:
  web:
    [...]
  db:
    [...]
```
Ces deux services font appels à une image Docker via la balise `image`
```yaml
version: '2'
services:
  web:
    image: my-odoo-11.0:0.1
    [...]
  db:
    image: postgres:12
    [...]
```
C'est le nom de l'image Docker à utiliser lors de la création des conteneurs.  
Dans l'exemple ici nous allons utiliser l'image `my-odoo-11.0:0.1` précédemment créée et une image Postresql version 12 `postgres:12`.  
Si elle n'existe pas localement alors Docker tentera d'aller la chercher sur le [registery Docker](https://hub.docker.com/) (il est également possible d'utiliser un registry local ou privé mais nous n'aborderons pas cela ici).


Les deux services ont également chacun des variables d'environnements `environment` et des `volumes`.  
Les variables d'environnement permettent de faire passer des informations dans le conteneur.  
Les volumes sont des disques virtuels montés lors de la construction des conteneurs.  
```yaml
volumes:
      - /local/path:/container/path
```

Il est important de noter que le premier service `web` dépend du deuxième service `db` grâce à la balise `depends`
```yaml
version: '2'
services:
  web:
    image: my-odoo-11.0:0.1
    depends_on:
      - db
    [...]
```

Pour l'option `extra_hosts` c'est pour permettre d'utiliser le "localhost" de votre host à travers le conteneur, par exemple pour des services comme mailcatcher qui tourne sur votre host et que vous souhaitez utiliser avec votre Odoo.  
Ce n'est pas nécessaire pour Windows.  
```yaml
version: '2'
services:
  web:
    [...]
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

**4. Créer et remonter une base de données**

Nous allons d'abord lancer uniquement le service pour la base de données appelé ici `db`.  
Lors du lancement du service `db` nous demandons l'utilisation de l'image `postgres:12`.  
Si elle n'existe pas Docker ira donc la récupérer dans un premier temps avant de lancer le service.

```shell
$ docker-compose up -d db
```

L'option `-d` ici permet de lancer le service en mode détaché afin de nous rendre la main.  
Il est possible de vérifier son exécution via la commande [`docker ps`](https://docs.docker.com/engine/reference/commandline/ps/) qui permet de voir les conteneurs actifs.

Si le conteneur a déjà été créé une première fois il est possible de le lancer via la commande :  
`docker start CONTAINER_NAME` ou `docker start CONTAINER_ID` (nous n'avons pas besoin des variables d'environnement ici, sinon il faudra les passer via le paramètre `-e`)

Pour la suite nous allons considérer que mon conteneur pour la base de données s'appelle `my_container_db` .  

Une fois le conteneur démarré nous allons lui déposer la base de donnée à remonter à l'aide de la commande [`docker cp`](https://docs.docker.com/engine/reference/commandline/cp/).  
Cela permet de copier/coller des fichiers entre le conteneur et le système de fichier local.  
Je souhaite déposer mon fichier dump dans le répertoire `/backups` de mon conteneur.  

```shell
$ docker cp /local/path/to/the/database/mybase.dump my_container_db:/backups
```
Pour exécuter des commandes à travers un conteneur il suffit d'utiliser la commande [`docker exec`](https://docs.docker.com/engine/reference/commandline/exec/)
Ensuite nous allons créer une base de données vide `my_empty_db` afin de restaurer le fichier .dump à travers cette dernière.  

```shell
$ docker exec my_container_db createdb -U odoo my_empty_db
```

Enfin nous allons restaurer le fichier .dump dans notre nouvelle base de données `my_empty_db`.

```shell
$ docker exec my_container_db pg_restore -U odoo -d my_empty_db /backups/mybase.dump
```
Une fois la restauration terminée libre à vous d'exécuter d'autre commande comme un script d'anonymisation technique de la base pour couper les actions planifiées ou encore fausser les urls / adresses emails etc.  
On effectuera exactement la même chose soit directement via les commandes, soit en transférant un fichier contenant les requêtes et en l'exécutant par la suite.

**5. Modifier le fichier de configuration et relancer les services via `docker-compose`**

Avant de démarrer notre conteneur Odoo appelé `web` il faudra créer/modifier le fichier de configuration du projet si nécessaire.


```shell
$ docker-compose up
```

ou  

```shell
$ docker-compose up -d
```


Debugger le code avec pdb :
------

**1. Placez la set_trace PDB dans votre code**
```python
    def write(self, vals):
      # some code here
      import pdb; pdb.set_trace()
      # some code here
      return super().write(vals)
```

**2. Lancez un terminal et attachez vous à votre conteneur**

Récupérez l'id ou le nom de votre conteneur en cours d’exécution via la commande `docker ps`, et attachez vous à ce dernier.  

```shell
docker attach (CONTAINER_NAME|CONTAINER_ID)
```

Effectuez l'action sur Odoo qui correspond à votre code à débug (par exemple ici la modification de l'objet)

(voir [Pdb](https://docs.python.org/3/library/pdb.html))


Debugger le code avec debugpy :
------
**1. Démarrer le service Odoo en mode débug**

Il faut surcharger la commande envoyée à l'`entrypoint`.

Le fichier `entrypoint.sh` prévoit une option `debug` afin de laisser `debugpy` lancer le serveur Odoo pour nous.

Soit vous modifiez le fichier `docker-compose.yml` de base de votre projet soit vous en créez un nouveau `docker-compose.override.yml` comportant juste les modifications des balises nécessaires.

```yaml
version: '2'
services:
  web:
    image: my-odoo-11.0:0.1
    entrypoint: /opt/odoo/entrypoint.sh
    command: debug
    [...]
    ports:
      - 8888:3001
      - 8879:8069
      - 8069:8069
```

La balise `command` ici permet de faire passer la commande `debug` en paramètre de l'`entrypoint`.
En fonction de la valeur `odoo` ou `debug` cela déclenchera le lancement de `debugpy`.

La balise `port` ici comporte des nouveaux mapping de ports pour que VSCode (`8888:3001` et `8879:8069`) puisse communiquer avec le `debugpy` du conteneur.
On sait que debugpy communiquera sur le port `3001` comme défini dans le `entrypoint.sh`.

Une fois le `docker-compose up` effectué c'est en réalité `debugpy` qui lancera Odoo pour nous.

**2. Attacher VScode à Debugpy et debuger**

Il faut maitenant pouvoir attacher VSCode au `debugpy` actuellement en train de tourner dans notre conteneur Odoo.

Pour se faire il faut créer une configuration VSCode pour le debugger (un fichier JSON).
En allant dans les options de debug VSCode (Ctrl + Shift + D) Vscode propose de créer un fichier `launch.json`.

Exemple de fichier : 
```json
{
  // Use IntelliSense to learn about possible attributes.
  // Hover to view descriptions of existing attributes.
  // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
      {
          "name": "Odoo: Attach",
          "type": "python",
          "request": "attach",
          "port": 8879,
          "debugServer": 8888,
          "host": "localhost",
          "pathMappings": [
              {
                  "localRoot": "${workspaceFolder}/odoo-14.0/",
                  "remoteRoot": "/opt/odoo/odoo",
              }
          ],
          "logToFile": true,
      }
  ],
}
```
Le port `8879` ici est un port qui redirige vers le `8069` dans mon conteneur. Cela est définit dans le `docker-compose.yml`.

Les valeurs dans `localRoot` et `remoteRoot` définies dans `pathMappings` sont les chemins vers le Odoo dans le conteneur.

Il vous suffira maintenant de placer un point d'arrêt dans le code en fonction des besoins et de lancer la configuration avant de réaliser l'action qui délanchera le point d'arrêt.

Si par exemple votre point d'arrêt est dans un `onchange` sur `partner_id` il faudra démarrer la configuration debug de VScode avant de réaliser la saisie du client dans `partner_id`.


Utiliser des sources Odoo locales au lieu de celles clonées dans le conteneur :
------

Pour utiliser les sources locales il faut monter un volume contenant les sources Odoo vers le répertoire des sources du conteneur.  
Mes sources Odoo se situent dans `./my-projet/odoo` et il faut donc monter ce dossier dans le dossier `/opt/odoo/odoo` du conteneur du service `web`.  

```yaml
web:
  image: my-odoo-11.0:0.1
  [...]
  volumes:
    - siclone-odoo-data:/opt/odoo/data
    - ./config:/etc/odoo
    - ./custom_addons:/opt/odoo/custom_addons
    - ./odoo:/opt/odoo/odoo
  [...]
```

Soit vous modifiez le fichier `docker-compose.yml` de base de votre projet soit vous en créez un nouveau `docker-compose.override.yml`.  
Lors du lancement de la commande `docker-compose up` cela prendra les deux fichiers automatiquement (voir [Docker compose extend](https://docs.docker.com/compose/extends/])).

Sinon si vous le souhaitez, vous pouvez créer un fichier spécifique par exemple `docker-compose-odoo-local.yml` contenant juste l'ajout du volume.  

```yaml
version: '2'
services:
  web:
    volumes:
      - ./odoo:/opt/odoo/odoo
```


Il faudra donc le préciser lors du lancement de la commande `docker-compose up`.  
```shell
$ docker-compose -f docker-compose.yml -f docker-compose-odoo-local.yml up -d
```


Todo :
------

* Mettre en place une image docker pour un remote debugger avec Pycharm ou autre
