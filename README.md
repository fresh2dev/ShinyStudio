# ShinyStudio

## *A Docker orchestration of open-source solutions to facilitate secure, collaborative development.*

  - [Overview](#overview)
      - [ShinyStudio Image](#shinystudio-image)
      - [ShinyStudio Stack](#shinystudio-stack)
  - [Setup](#setup)
      - [Image](#image)
      - [Stack](#stack)
  - [Develop](#develop)
  - [Tools](#tools)
  - [Configuration](#configuration)
      - [Authentication](#authentication)
      - [SSL/TLS for HTTPS](#ssltls-for-https)
  - [References](#references)

## Overview

![](https://i.imgur.com/rtd29qCh.png)

The ShinyStudio project is an orchestration of various open-source
solutions with the goal of providing:

  - a secured, collaborative development environment for R, Python,
    PowerShell, and more.
  - a secured, convenient way to share apps and documents written in
    Shiny, RMarkdown, plain Markdown, or HTML.
  - easily reproducible, cross-platform setup leveraging Docker for all
    components.

![](https://i.imgur.com/PRDW25E.png)

There are two distributions of ShinyStudio, the *image* and the *stack*.

### ShinyStudio Image

The ShinyStudio image, hosted on
[DockerHub](https://hub.docker.com/r/dm3ll3n/shinystudio), builds upon
the [Rocker project](https://www.rocker-project.org/) to include:

  - [ShinyProxy](https://www.shinyproxy.io/)
  - [RStudio Server](https://www.rstudio.com/)
  - [VS Code](https://code.visualstudio.com/), modified by
    [Coder.com](https://coder.com/)
  - [Shiny Server](https://shiny.rstudio.com/)

The image is great for a personal instance, a quick demo, or the
building blocks for a very customized setup.

> LINK TO SETUP

![ShinyStudio](https://i.imgur.com/FIzE0d7.png)

### ShinyStudio Stack

The ShinyStudio stack builds upon the image to incorporate:

  - [NGINX](https://www.nginx.com/) for simple HTTPS support.
  - [InfluxDB](https://www.influxdata.com/) for tracking site usage.

The stack provides a more enterprise-ready distribution, as NGINX
provides an simple solution for HTTPS, and site usage is stored in
InfluxDB.

Moreover, each component of the stack is run in a Docker container for
reproducibility, scalability, and security. Only the NGINX port is
exposed on the host system; all communication between ShinyProxy and
other components happens inside an isolated Docker network.

> LINK TO SETUP

![](https://i.imgur.com/RsLeueG.png)

## Setup

The setup has been verified to work on each of
[Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) (for
Linux) and [Docker
Desktop](https://www.docker.com/products/docker-desktop) (for Mac and
Windows).

> Note: when upgrading ShinyStudio, setup from scratch and migrate
> existing content/settings afterward.

The instructions below assume a functional instance of Docker.

The *stack* distribution of ShinyStudio introduces two additional
requirements:

  - [docker-compose](https://docs.docker.com/compose/install/)
  - [Git](https://git-scm.com/downloads)

> Setup must be run as a non-root user.

### Image

To download and run the ShinyStudio image from
[DockerHub](https://hub.docker.com/r/dm3ll3n/shinystudio), first, create
a docker network named `shinystudio-net`:

``` text
docker network create shinystudio-net
```

Then, execute `docker run` in the terminal for your OS:

  - Bash (Linux/Mac)

<!-- end list -->

``` text
docker run -d --restart always --name shinyproxy \
    --network shinystudio-net \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e USERID=$USERID \
    -e USER=$USER \
    -e PASSWORD=password \
    -e CONTENTPATH="${HOME}/ShinyStudio" \
    -e SITEPORT=8080 \
    -p 8080:8080 \
    dm3ll3n/shinystudio
```

  - PowerShell (Windows)

<!-- end list -->

``` text
docker run -d --restart always --name shinyproxy `
    --network shinystudio-net `
    -v /var/run/docker.sock:/var/run/docker.sock `
    -e USERID=1000 `
    -e USER=$env:USERNAME `
    -e PASSWORD=password `
    -e CONTENTPATH="/host_mnt/c/Users/$env:USERNAME/ShinyStudio" `
    -e SITEPORT=8080 `
    -p 8080:8080 `
    dm3ll3n/shinystudio
```

> Notice the unique form of the path for the `CONTENTPATH` variable in
> the Windows setup.

Once complete, open a web browser and navigate to
`http://<hostname>:8080`. Log in with your username and the password
`password`.

### Stack

The *stack* distribution of ShinyStudio is delivered through the [GitHub
repo](https://github.com/dm3ll3n/ShinyStudio).

First, clone the repo and enter the new directory:

``` text
git clone https://github.com/dm3ll3n/ShinyStudio

cd ShinyStudio
```

Complete the setup using either the provided scripts or by executing the
commands manually. Once complete, open a web browser and navigate to
`http://<hostname>:8080`.

The default logins are:

| **username** | **password** |
| :----------: | :----------: |
|     user     |     user     |
|    admin     |    admin     |
|  superadmin  |  superadmin  |

  - readers: can only view content from “Apps & Reports”, “Documents”,
    and “Personal”.
  - admins: can view all site content and develop content with RStudio
    and VS Code.
  - superadmins: can view and develop site content across multiple
    instances of ShinyStudio.

#### Scripts

The quickest way to get up-and-running is to use the provided control
scripts. The scripts are provided as both Bash scripts (`.sh`) and
PowerShell scripts (`.ps1`); use the script that is appropriate for your
OS.

The command below will create a new site configuration based on the
template at `configs/template`, then start it.

``` text
# Bash
./control.sh start 8080

# OR

# PowerShell
./control.ps1 start 8080
```

#### Manual

To perform the setup without the provided scripts, first copy the
`configs/template` directory and rename it *according to the HTTP port
that this new site will listen on*.

``` text
# Bash
cp -R 'configs/template' 'configs/8080'

# OR

# PowerShell
Copy-Item 'configs/template' 'configs/8080' -Recurse
```

Then, set the required environment variables followed by `docker-compose
up`:

  - Bash (Linux/Mac)

<!-- end list -->

``` text
# specify the site's port (./configs/<port>)
export SITEPORT=8080

# specify where to store content.
export CONTENTPATH="./content"

# specify the HTTPS port defined in 'nginx.conf',
# or use a random high-port if SSL is not enabled.
export HTTPSPORT=$((50000 + RANDOM % 10000))

# use the current user ID and user name.
export USERID=$UID
export USER

# build and start the project; the project name is required.
docker-compose -p "shinystudio_${SITEPORT}" up -d --build
```

  - PowerShell (Windows)

<!-- end list -->

``` text
# specify the site's port (./configs/<port>)
$env:SITEPORT = '8080'

# specify where to store content.
$env:CONTENTPATH = '/host_mnt/c/Users/$env:USERNAME/ShinyStudio/content'

# specify the HTTPS port defined in 'nginx.conf',
# or use a random high-port if SSL is not enabled.
$env:HTTPSPORT = (Get-Random -Minimum 50000 -Maximum 60000).ToString()

# use the current user ID and user name.
$env:USER = $env:USERNAME
$env:USERID = 1000

# build and start the project; the project name is required.
docker-compose -p "shinystudio_$($env:SITEPORT)" up -d --build
```

## Develop

Open your IDE of choice and notice two important directories:

  - \_\_ShinyStudio\_\_
  - \_\_Personal\_\_

> Files must be saved in either of these two directories in order to
> persist between sessions.

![](https://i.imgur.com/ac7iKDHh.png)

These two folders are shared between instances RStudio, VS Code, and
Shiny Server. So, creating new content is as simple as saving a file to
the appropriate directory.

![](https://i.imgur.com/lAuTMgBh.png)

## Tools

The ShinyStudio image comes with…

  - R
  - Python 3
  - PowerShell

…and ODBC drivers for:

  - SQL Server
  - PostgresSQL
  - Cloudera Impala.

These are persistent because they are built into the image.

|                               | Persistent |
| ----------------------------: | :--------: |
| \_\_ShinyStudio\_\_ directory |    Yes     |
|    \_\_Personal\_\_ directory |    Yes     |
|             Other directories |   **No**   |
|                   R Libraries |    Yes     |
|               Python Packages |    Yes     |
|            PowerShell Modules |    Yes     |
|         RStudio User Settings |    Yes     |
|         VS Code User Settings |    Yes     |
|                Installed Apps |   **No**   |
|             Installed Drivers |   **No**   |

## Configuration

> The information below only applies to the ShinyStudio *stack*.

Many of the configuration options are accessible through the ShinyProxy
configuration file, `application.yml`. Here, you can change the site
title, change the authentication mechanism, and further refine access.

Review the [ShinyProxy configuration
documentation](https://www.shinyproxy.io/configuration/) for all
options.

### Authentication

ShinyProxy supports various authentication mechanisms (basic, LDAP,
social, …).

To change from basic auth (default) to LDAP auth, open the site’s
configuration file (`configs/8080/application.yml`), locate the section
below…

``` text
authentication: simple
users:
  - name: superadmin
    password: *change*me*
    groups: superadmins
  - name: admin
    password: *change*me*
    groups: admins
  - name: user
    password: *change*me*
    groups: readers
```

…and replace it with the following, after providing values appropriate
for your environment:

``` text
ldap:
    url: ldap://mydomain.com/DC=mydomain,DC=com
    manager-dn: CN=svc.user,OU=Users,DC=mydomain,DC=com
    manager-password: ...
    user-search-base: 
    user-search-filter: (sAMAccountName={0})
    group-search-base: OU=Groups
    group-search-filter: (member={0})
```

Afterward, you may want to refine access to various apps using the
`access-groups` option available to each:

``` text
access-groups: [ "reader-group", "admin-group", "superadmin-group" ]
```

### SSL/TLS for HTTPS

To encrypt communication over HTTPS, edit the provided NGINX
configuration file for the site in question (`configs/8080/nginx.conf`).

First, place the site’s certificate and key in `configs/8080/certs/`.

Then, uncomment the designated lines in `nginx.conf` and supply the
desired HTTPS port in the three sections indicated in the file.

Finally, restart the site with:

``` text
./control.[sh/ps1] restart 8080
```

If configured properly, HTTP requests to ShinyProxy will be redirected
to HTTPS.

## References

  - <https://www.shinyproxy.io/>
  - <https://www.rocker-project.org/>
  - <https://telethonkids.wordpress.com/2019/02/08/deploying-an-r-shiny-app-with-docker/>
  - <https://appsilon.com/alternatives-to-scaling-shiny>
