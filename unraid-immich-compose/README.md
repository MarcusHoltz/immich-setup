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


* * *

### ASCII Flow of the Immich Docker stack


<details>

<summary>Visual Breakdown of the Docker Compose file</summary>

```text
# Immich Docker Stack Logic Flow

## User Interaction Layer

USER ACCESS POINTS:
┌─────────────────┬──────────────────┬─────────────────┐
│ Web Interface   │ Admin Tools      │ Display Mode    │
│ Port 2283       │ Port 8888        │ Port 3000       │
│ (Photo Mgmt)    │ (DB Admin)       │ (Kiosk)         │
└─────────────────┴──────────────────┴─────────────────┘


## Core Service Dependencies & Execution Flow

### 1. Foundation Services (Start First)

REDIS (172.21.8.113)
├── Function: In-memory caching for speed
├── Health Check: redis-cli ping
└── Status: Always restart

DATABASE (172.21.8.114) 
├── Image: tensorchord/pgvecto-rs:pg14
├── Function: PostgreSQL with vector extensions
├── Environment Variables:
│   ├── POSTGRES_PASSWORD: ${DB_PASSWORD}
│   ├── POSTGRES_USER: ${DB_USERNAME}
│   └── POSTGRES_DB: ${DB_DATABASE_NAME}
├── Volume Mount: ${DB_DATA_LOCATION}:/var/lib/postgresql/data
├── Health Check: pg_isready + checksum validation
└── Command: postgres with vectors.so preload


### 2. Core Processing Services (Start After Dependencies)

IMMICH-SERVER (172.21.8.111:2283)
├── Depends On: redis + database
├── Volume Mounts:
│   ├── ${UPLOAD_LOCATION}:/usr/src/app/upload
│   ├── ${IMPORT_LOCATION}:/usr/src/app/import
│   └── /etc/localtime:/etc/localtime:ro
├── Function: Main web server handling HTTP requests
└── Health Check: Enabled

IMMICH-MACHINE-LEARNING (172.21.8.110)
├── Volume Mount: model-cache:/cache
├── Function: AI processing for photo analysis
├── Network: Internal communication only
└── Health Check: Enabled


## Data Flow Logic

### Photo Upload Process

1. USER UPLOADS → Immich Server (Port 2283)
                       ↓
2. Server writes to → ${UPLOAD_LOCATION} volume
                       ↓
3. Metadata stored → PostgreSQL Database
                       ↓
4. Cache updates → Redis
                       ↓
5. ML analysis → Machine Learning Service


### Photo Import Process

1. Files exist in → ${IMPORT_LOCATION}
                       ↓
2. Server scans → Import directory
                       ↓
3. Processing → Same as upload flow (steps 2-5)


## Monitoring & Administration Stack

### Observability Services

PROMETHEUS (172.21.8.117:9090)
├── Config: ${PRO_DATA_LOCATION}/prometheus.yml
├── Function: Metrics collection
└── Volume: prometheus-data:/prometheus

GRAFANA (172.21.8.118:3000)
├── Function: Metrics visualization
├── Command: -disable-reporting
└── Volume: grafana-data:/var/lib/grafana


### Database Administration

PGADMIN (172.21.8.119:8888)
├── Environment:
│   ├── PGADMIN_DEFAULT_EMAIL: los_emails@gmail.com
│   └── PGADMIN_DEFAULT_PASSWORD: passwardos
├── Function: PostgreSQL web interface
└── Volume: pgadmin-data:/var/lib/pgadmin


## Extended Services

### Public Access

IMMICH-PUBLIC-PROXY (172.21.8.116:3033)
├── Points to: http://172.21.8.111:2283
└── Function: External access proxy


### Kiosk Display Mode

IMMICH-KIOSK (172.21.8.120:3000)
├── API Connection: KIOSK_IMMICH_URL: "http://172.21.8.111:2283"
├── Authentication: KIOSK_IMMICH_API_KEY (from user5@gmail.com)
├── Display Settings:
│   ├── Time: 12-hour format, MM/DD/YYYY
│   ├── Refresh: Every 25 seconds
│   ├── Theme: fade
│   └── Layout: single
├── Content Filtering:
│   ├── Person Filter: 3 specific person IDs
│   ├── Show archived: false
│   └── Album order: random
└── Image Display:
    ├── Fit: contain
    ├── Effect: smart-zoom (120%)
    └── Metadata: owner, album, person, time, date, description, exif, location


## Network Architecture

All services communicate via br0.8 network (172.21.8.0/24)

Service IP Allocation:
├── Machine Learning: .110
├── Immich Server: .111 (main entry point)
├── Redis: .113
├── Database: .114
├── Public Proxy: .116
├── Prometheus: .117
├── Grafana: .118
├── PgAdmin: .119
└── Kiosk: .120


## Configuration Dependencies

Required .env file variables:
├── UPLOAD_LOCATION (photo storage)
├── IMPORT_LOCATION (import source)
├── DB_DATA_LOCATION (database files)
├── PRO_DATA_LOCATION (prometheus config)
├── IMMICH_VERSION (container version)
├── DB_PASSWORD, DB_USERNAME, DB_DATABASE_NAME
└── IMMICH_TELEMETRY_INCLUDE



## Execution Logic Summary

**WHY**: Photo management with AI analysis, monitoring, and display capabilities
**HOW**: Containerized microservices with shared storage and network communication
**FLOW**: Database/Cache → Core Services → Extended Features → User Interfaces
```

</details>
