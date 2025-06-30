# UnRAID Immich Install

- [UnRAID Immich Install](#unraid-immich-install)
  - [Use UnRAID for Immich](#use-unraid-for-immich)
    - [UnRAID Requirements](#unraid-requirements)
    - [Docker Immich Compose Stack](#docker-immich-compose-stack)
    - [Env File](#env-file)
    - [Docker-Compose Additional UnRAID Overrides](#docker-compose-additional-unraid-overrides)
  - [Start the Docker Compose Stack on Boot](#start-the-docker-compose-stack-on-boot)


* * *

## Use UnRAID for Immich

I have most of my long term and speedy storage on UnRAID. 

So, to me, it made sense to setup Immich on the UnRAID server, no point of having the service up if the files are unavailable.

You can find the files I have used on the UnRAID server in this [Immich Setup Repo](https://github.com/MarcusHoltz/immich-setup/unraid-immich-compose).


* * *

## UnRAID Requirements: Part 1

To get this up and running, we need additonal software in UnRAID to support how this is set-up.

The easiest way is to install the [Docker Compose Manager](https://github.com/dcflachs/plugin-repository/blob/master/compose.manager.xml) from the UnRAID Community Applications.

You can find out more about [UnRAID's Unofficial Docker Compose Manager Plugin](https://forums.unraid.net/topic/114415-plugin-docker-compose-manager).

- Once it's installed, you can find it under `Plugins`.

- Start a new stack and name it `immich`.

> This will create a new folder under:
`/boot/config/plugins/compose.manager/projects/immich/`


* * *

## Immich Docker Compose Stack

This is what lies inside the docker compose stack I decided to use:

- `Immich Server` - Webserver handling requests

- `Immich Machine Learning` - The sweet juice Immich pours into my computer

- `Reddis` - In-memory database, for speedy lookups

- `Postgres` - For that good olde database feel

- `Immich Public Proxy` - Unused, but available

- `Prometheus` - The official tutorial for Immich included this, so I left it

- `Grafana` - If it aint Kabana, it's Grafana

- `Pgadmin4` - Edit the database before the kids come home

- `Immich Kiosk` - Turn your photos into a Screensaver


### Compose File

The docker-compose.yml file is below:

GITHUB
GITHUB
GITHUB
GITHUB
GITHUB
GITHUB






### Env File

This stack also relies on an Environment Varriable to help set some of the configuration information.

My Env File is as follows:


GITHUB
GITHUB
GITHUB
GITHUB
GITHUB
GITHUB
GITHUB





* * *

### Docker-Compose Additional UnRAID Overrides


UnRAID uses docker, but also is able to use special labels to allow the interface to better present the user with these services.



GITHUB
GITHUB
GITHUB
GITHUB
GITHUB
GITHUB
GITHUB
GITHUB





* * *

## Auto-Start Immich On Boot

Immich will fail, as the network has not fully come up yet. YMMV.


* * *

### UnRAID Requirements: Part 2

#### Install Userscripts on UnRAID

To fix this we're using the [User Scripts](https://github.com/Squidly271/user.scripts/blob/master/plugins/user.scripts.plg) plugin.

You can find out more about [The Community Application: User Scripts](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/).

Make sure it is installed before continuing.



* * *

### Using User Scripts for Immich Delay

I have this script in my User Scripts and it runs at the start of the array.

My docker-compose stack name is `immich`. The rest should be copy and paste.

This script waits 100 seconds and then updates & restarts the docker-compose stack so it can see the network.

It then proceeds to do the same to NetBird. 


GITHUB
GITHUB
GITHUB
GITHUB
GITHUB
GITHUB
GITHUB
GITHUB


