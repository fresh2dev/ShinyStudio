# ShinyStudio

## *A Docker orchestration of open-source solutions to facilitate secure, collaborative development.*

  - [Overview](#overview)
      - [ShinyStudio Image](#shinystudio-image)
      - [ShinyStudio Stack](#shinystudio-stack)
  - [Getting Started](#getting-started)
      - [Image](#image)
      - [Stack](#stack)
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
  - easily reproducible, cross-platform setup leveraging Docker for all
    components.

![](https://i.imgur.com/qc7bL1I.gif)

![](https://i.imgur.com/PRDW25E.png)

There are two distributions of ShinyStudio, the *image* and the *stack*,
explained below.

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

[Get Started with the Image](#image)

![ShinyStudio](https://i.imgur.com/FIzE0d7.png)

### ShinyStudio Stack

The ShinyStudio stack builds upon the image to incorporate:

  - [NGINX](https://www.nginx.com/) with HTTPS enabled.
  - [InfluxDB](https://www.influxdata.com/) for monitoring site usage.

Each component of the stack is run in a Docker container for
reproducibility, scalability, and security. Only the NGINX port is
exposed on the host system; all communication between ShinyProxy and
other components happens inside an isolated Docker network.

[Get Started with the Stack](#stack)

![](https://i.imgur.com/RsLeueG.png)

## Getting Started

The setup has been verified to work on each of
[Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) (for
Linux) and [Docker
Desktop](https://www.docker.com/products/docker-desktop) (for Mac and
Windows).

> Note: when upgrading ShinyStudio, please setup from scratch and
> migrate existing content/settings afterward.

> Note: Setup must be run as a non-root user.

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
    -e CONTENT_PATH="${HOME}/ShinyStudio" \
    -e SITE_NAME=shinystudio \
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
    -e CONTENT_PATH="/host_mnt/c/Users/$env:USERNAME/ShinyStudio" `
    -e SITE_NAME=shinystudio `
    -p 8080:8080 `
    dm3ll3n/shinystudio
```

> Notice the unique form of the path for the `CONTENT_PATH` variable in
> the Windows setup.

Once complete, open a web browser and navigate to
`http://<hostname>:8080`. Log in with your username and the password
`password`.

### Stack

The *stack* distribution of ShinyStudio is delivered through the [GitHub
repo](https://github.com/dm3ll3n/ShinyStudio) and introduces two
additional requirements:

  - [docker-compose](https://docs.docker.com/compose/install/) (ships
    with Docker Desktop)
  - [Git](https://git-scm.com/downloads)

HTTPS is configured by default, so SSL/TLS certs are required in order
for the stack to operate. Use the provided script `certify.sh`
(`certify.ps1` for Windows) to create a self-signed certificate, or to
request one from LetsEncrypt (more on that).

#### Minimal setup:

``` text
# copy the setup files.
git clone https://github.com/dm3ll3n/ShinyStudio

# enter the directory.
cd ShinyStudio

# run certify to generate self-signed cert.
./certify.[sh/ps1]
```

Now, browse to `http://<hostname>` (e.g., `http://localhost`) to access
ShinyStudio. On first launch, you will need to accept the warning about
an untrusted certificate. See the customized setup to see how to request
a trusted cert from LetsEncrypt.

The default logins are below. See the customized setup to see how to
add/remove accounts.

| **username** | **password** |
| :----------: | :----------: |
|     user     |     user     |
|    admin     |    admin     |
|  superadmin  |  superadmin  |

#### Customized setup:

There are three files essential to a customized configuration:

1.  `.env`

> The docker-compose environment file. The project name, content path,
> and HTTP ports can be changed here.

Note that Docker volume names are renamed along with the project name,
so be prepared to migrate or recreate data stored in Docker volumes when
changing the project name.

2.  `application.yml`

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

3.  `nginx.conf`

> The NGINX config file. Defines the accepted site name and what ports
> to listen on.

If you change the ports here, you must also change the ports defined in
the `.env` file. Also, if you change the domain name, you must
provide/generate a new certificate for it.

4.  `certify.[sh/ps1]`

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

## References

  - <https://www.shinyproxy.io/>
  - <https://www.rocker-project.org/>
  - <https://telethonkids.wordpress.com/2019/02/08/deploying-an-r-shiny-app-with-docker/>
  - <https://appsilon.com/alternatives-to-scaling-shiny>
  - <https://github.com/wmnnd/nginx-certbot>
