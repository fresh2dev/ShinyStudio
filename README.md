# ShinyStudio

## *A fully Dockerized, self-hosted development environment for teams. Develop where you serve.*

  - [Overview](#overview)
  - [Getting Started](#getting-started)
  - [Develop](#develop)
  - [Tools](#tools)
  - [References](#references)

## Overview

![](https://i.imgur.com/rtd29qCh.png)

The ShinyStudio project is an orchestration of various open-source
solutions with the goal of providing:

  - a secured, collaborative development environment for R, Python,
    PowerShell, and more.
  - a secured, convenient way to share apps and documents written in
    Shiny, RMarkdown, plain Markdown, or HTML.
  - easily reproducible, cross-platform setup leveraging Docker
    containers.

The ShinyStudio ecosystem includes:

  - **ShinyProxy** (authentication and orchestration) \[
    [Website](https://www.shinyproxy.io/configuration/) ;
    [GitHub](https://github.com/openanalytics/shinyproxy) \]
  - **Shiny Server** (web server) \[
    [Website](https://rstudio.com/products/shiny/shiny-server/) ;
    [GitHub](https://github.com/rstudio/shiny-server) \]
  - **RStudio Server** (IDE) \[
    [Website](https://rstudio.com/products/rstudio/) ;
    [GitHub](https://github.com/rstudio/rstudio) \]
      - **Rocker** (RStudio in Docker) \[
        [Website](https://www.rocker-project.org/) ;
        [GitHub](https://github.com/rocker-org/rocker-versioned) \]
  - **VS Code** (IDE) \[ [Website](https://code.visualstudio.com/) ;
    [GitHub](https://github.com/microsoft/vscode) \]
      - **code-server** (VS Code in a browser) \[
        [Website](https://coder.com/) ;
        [GitHub](https://github.com/cdr/code-server) \]
  - **InfluxDB** (DB for usage tracking) \[
    [Website](https://www.influxdata.com/products/influxdb-overview/) ;
    [GitHub](https://github.com/influxdata/influxdb) \]
  - **Cronicle** (task scheduler) \[ [Website](http://cronicle.net/) ;
    [GitHub](https://github.com/jhuckaby/Cronicle) \]
  - **NGINX** (reverse proxy) \[ [Website](https://www.nginx.com/) ;
    [GitHub](https://github.com/nginx/nginx) \]
  - **Certbot** (LetsEncrypt daemon) \[
    [Website](https://certbot.eff.org/about/) ;
    [GitHub](https://github.com/certbot/certbot) \]

Each component of the stack is run in a Docker container for
reproducibility, scalability, and security. Only the NGINX port is
exposed on the host system; all communication between ShinyProxy and
other components happens inside an isolated Docker network.

![](https://i.imgur.com/PRDW25E.png)

The ShinyStudio “stack” includes the [ShinyStudio
image](https://hub.docker.com/r/dm3ll3n/shinystudio), which builds upon
the [rocker/verse image on
DockerHub](https://hub.docker.com/r/rocker/verse).

While this guide focuses on the stack, spin up the image in Bash or
PowerShell with these commands:

<details>

<summary>Bash (Linux/Mac)</summary>

``` text
docker network create shinystudio-net && \
docker run -d --restart always --name shinyproxy \
    --network shinystudio-net \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e USERID=$UID \
    -e USER=$USER \
    -e PASSWORD=password \
    -e CONTENT_PATH="${HOME}/ShinyStudio" \
    -e SITE_NAME=shinystudio \
    -e TAG=latest \
    -p 80:8080 \
    dm3ll3n/shinystudio:latest
```

</details>

<br/>

<details>

<summary>PowerShell</summary>

``` text
docker network create shinystudio-net;
docker run -d --restart always --name shinyproxy `
    --network shinystudio-net `
    -v /var/run/docker.sock:/var/run/docker.sock `
    -e USERID=1000 `
    -e USER=$([environment]::UserName) `
    -e PASSWORD=password `
    -e CONTENT_PATH="/host_mnt/c/Users/$([environment]::UserName)/ShinyStudio" `
    -e SITE_NAME=shinystudio `
    -e TAG=latest `
    -p 80:8080 `
    dm3ll3n/shinystudio:latest
```

> Notice the unique form of the path for the `CONTENT_PATH` variable
> required when in a Windows environment.

</details>

<br/>

![](https://i.imgur.com/qc7bL1I.gif)

## Getting Started

PreReqs:

  - Docker on Linux, Mac, or Windows
  - [docker-compose](https://docs.docker.com/compose/install/)
  - [Git](https://git-scm.com/downloads)

#### Minimal setup:

``` text
# copy the setup files from version branch 0.5.0
git clone -b 0.5.0 https://github.com/dm3ll3n/ShinyStudio

# enter the directory.
cd ShinyStudio

# run certify to generate self-signed cert.
## Bash users run:
./certify.sh

## Powershell users run:
./certify.ps1
```

> Important\! As a crucial first step, log in to the job scheduler at
> `https://<hostname>:8443` using the username `admin` and password
> `administrator`. Once in, go into settings and set a unique password.

Now, browse to `http://<hostname>` (e.g., `http://localhost`) to access
ShinyStudio. On first launch, you will need to accept the warning about
an untrusted certificate. See the customized setup to see how to request
a trusted cert from LetsEncrypt.

The default logins are below.

| **username** | **password**  |
| :----------: | :-----------: |
|     user     |     user      |
|     dev      |   developer   |
|    admin     | administrator |

#### Customized setup:

Customized setup checklist:

  - [ ] Clone a version branch.
      - [ ] Optionally, push to your own private repo.
  - [ ] set users/passwords in `application.yml`
  - [ ] set CONTENT\_PATH in `.env`
  - [ ] set domain name in `nginx.conf`
  - [ ] certify and start.
  - [ ] login to cronicle, change password.
      - [ ] optionally, schedule jobs.
  - [ ] login to shinystudio.
  - [ ] set your own user-specific preferences.

The files essential to a customized configuration are described more
in-depth below:

<details>

<summary>.env</summary>

> The docker-compose environment file. The project name, content path,
> and HTTP ports can be changed here.

Note that Docker volume names are renamed along with the project name,
so be prepared to migrate or recreate data stored in Docker volumes when
changing the project name.

</details>

<br/>

<details>

<summary>application.yml</summary>

> The ShinyProxy config file. Users can be added/removed here. Other
> configurations are available too, such as the site title and the
> ability to provide a non-standard landing page.

Using the provided template, you can assign users to the following
groups with tiered access:

  - **readers**: can only view content from “Apps & Reports”,
    “Documents”, and “Personal”.
  - **admins**: can view all site content and develop content with
    RStudio and VS Code.
  - **superadmins**: can view and develop site content across multiple
    instances of ShinyStudio. Can also manage *all* user files.

Review the [ShinyProxy configuration
documentation](https://www.shinyproxy.io/configuration/) for all
options.

</details>

<br/>

<details>

<summary>nginx.conf</summary>

> The NGINX config file. Defines the accepted site name and what ports
> to listen on.

If you change the ports here, you must also change the ports defined in
the `.env` file. Also, if you change the domain name, you must
provide/generate a new certificate for it.

</details>

<br>

<details>

<summary>certify.\[sh/ps1\]</summary>

> The script used to generate a self-signed cert, or to request a
> trusted cert from LetsEncrypt.

With no parameters, `certify` generates a self-signed cert for
`example.com` (the default domain name defined in `nginx.conf`).

To generate a self-signed cert with another domain name, first edit the
domain name in `nginx.conf`. Afterward, generate a new cert with:

    ./certify.sh <domain name>
    
    # e.g., ./certify.sh www.shinystudio.com

If your server is accessible from the web, you can request a trusted
certificate from LetsEncrypt. First, edit `nginx.conf` with your domain
name, then request a new cert from LetsEncrypt like so:

    ./certify.sh <domain name> <email>
    
    # e.g., ./certify.sh www.shinystudio.com donald@email.com

CertBot, included in the stack, will automatically renew your
LetsEncrypt certificate.

To manage the services in the stack, use the native docker-compose
commands, e.g.:

    # stop all services.
    docker-compose down
    
    # start all services.
    docker-compose up -d

</details>

<br/>

## Develop

Open either RStudio or VS Code and notice two important directories:

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
  - Python 3 (via miniconda)
  - PowerShell

…and ODBC drivers for:

  - SQL Server
  - PostgresSQL
  - Cloudera Impala.

These are persistent because they are built into the image.

|                               |              Persistent               |
| ----------------------------: | :-----------------------------------: |
| \_\_ShinyStudio\_\_ directory |                  Yes                  |
|    \_\_Personal\_\_ directory |                  Yes                  |
|             Other directories |                **No**                 |
|    Python (conda) Enviroments |                  Yes                  |
|               Python Packages |                  Yes                  |
|                   R Libraries |                  Yes                  |
|            PowerShell Modules |                  Yes                  |
|         RStudio User Settings |                  Yes                  |
|         VS Code User Settings |                  Yes                  |
|                Installed Apps | **No**, unless installed with `conda` |
|             Installed Drivers |                **No**                 |

## References

  - <https://telethonkids.wordpress.com/2019/02/08/deploying-an-r-shiny-app-with-docker/>
  - <https://appsilon.com/alternatives-to-scaling-shiny>
  - <https://github.com/wmnnd/nginx-certbot>
