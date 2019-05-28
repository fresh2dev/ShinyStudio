ShinyStudio
===========

*A Docker image of RStudio + VS Code + Shiny Server, driven by ShinyProxy.*
---------------------------------------------------------------------------

-   [Overview](#overview)
-   [Branches](#branches)
    -   [Base](#base)
    -   [Master](#master)
-   [Develop](#develop)
    -   [Tools](#tools)
-   [Configuration](#configuration)
    -   [Security](#security)
    -   [Multiple Sites](#multiple-sites)
-   [References](#references)

![](https://i.imgur.com/rtd29qCh.png)

![ShinyStudio](https://i.imgur.com/FIzE0d7.png)

Overview
--------

ShinyStudio is a Docker image which extends
[rocker/verse](https://hub.docker.com/r/rocker/verse) to include
RStudio, Shiny Server, VS Code, and ShinyProxy.

ShinyStudio leverages ShinyProxy to provide:

-   a centralized, pre-configured development environment.
-   a centralized repository for documents written in Markdown,
    RMarkdown, or HTML.
-   a simple and secure method for sharing web apps developed with
    RStudio Shiny.

![](https://i.imgur.com/ppQsjIx.png)

The ShinyStudio image consists of the products described below:

-   [ShinyProxy](https://www.shinyproxy.io/)
-   [Shiny Server](https://shiny.rstudio.com/)
-   [RStudio Server](https://www.rstudio.com/)
-   [VS Code](https://code.visualstudio.com/), modified by
    [Coder.com](https://coder.com/)

![](https://i.imgur.com/qc7bL1I.gif)

Branches
--------

The [GitHub repo for
ShinyStudio](https://github.com/dm3ll3n/ShinyStudio) contains two major
branches: `base` and `master`.

-   The `base` branch is used to build the image published on DockerHub.
    The image is great for a personal instance, a quick demo, or the
    building blocks for a very customized setup.
-   The `master` branch builds upon the base image to provide an example
    of a more enterprise-ready setup of ShinyStudio.

> Setup must be run as a non-root user.

### Base

Setup of the base image can be done entirely with Docker.

First, create a network named `shinystudio-net` to be shared by all
spawned containers.

``` text
docker network create shinystudio-net
```

Then, pull and run the ShinyStudio image directly from DockerHub.

``` text
docker run --rm -it --name shinyproxy \
    --network shinystudio-net \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e USERID=$USERID \
    -e USER=$USER \
    -e PASSWORD=password \
    -e MOUNTPOINT="${HOME}/ShinyStudio" \
    -e SITEID=default \
    -p 8080:8080 \
    dm3ll3n/shinystudio
```

Once complete, open a web browser and navigate to
`http://<hostname>:8080`. Log in with your username and the password
`password`.

For a more customized experience, alter pertinent environment variables
and bind local volumes to the Docker image. A more personalized setup
could look like:

``` text
docker run --rm -it --name shinyproxy \
    --network shinystudio-net \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e USERID=$USERID \
    -e USER=$USER \
    -e PASSWORD=p@ssw0rd123 \
    -e MOUNTPOINT="${HOME}/ShinyStudio" \
    -e SITEID=MyShinyStudio \
    -p 8080:8080 \
    -v "${PWD}/application.yml:/opt/shinyproxy/application.yml"
    -v "${PWD}/imgs/background.png:/opt/shinyproxy/templates/grid=layout/assets/img/background.png" \
    -v "${PWD}/imgs/logo.png:/opt/shinyproxy/templates/grid=layout/assets/img/logo.png"
    dm3ll3n/shinystudio
```

Explained:

-   `MOUNTPOINT` defines the path to store site content and user
    settings.
-   `SITEID` defines the folder name that this site’s content will
    reside in (`$MOUNTPOINT/sites/$SITEID`).
-   The bind mount for `application.yml` specifies a custom ShinyProxy
    configuration file ([read more
    here](https://www.shinyproxy.io/configuration/)).
-   Bind mounts for `background.png` and `logo.png` allow easy
    personalization of the site background and logo.

### Master

Setup of the master branch requires both Docker and docker-compose.

For a more out-of-the-box setup, consider cloning/forking the [master
branch](https://github.com/dm3ll3n/ShinyStudio/tree/master) from GitHub.
e.g.,

``` text
# Clone the master branch.
git clone https://github.com/dm3ll3n/ShinyStudio

# Enter the new directory.
cd ShinyStudio

# Setup and run.
./control.sh setup
```

The default mountpoint is `$PWD/content`. To specify another mountpoint,
pass the desired path as an argument to the setup:

``` text
./control.sh setup "${HOME}/ShinyStudio"
```

Once complete, open a web browser and navigate to
`http://<hostname>:8080`.

The default logins are:

-   `user`: `user`
-   `admin`: `admin`
-   `superadmin`: `superadmin`

Develop
-------

Open your IDE of choice and notice two important directories:

-   \_\_ShinyStudio\_\_
-   \_\_Personal\_\_

> Files must be saved in either of these two directories in order to
> persist between sessions.

![](https://i.imgur.com/ac7iKDHh.png)

These two folders are shared between instances RStudio, VS Code, and
Shiny Server. So, creating new content is as simple as saving a file to
the appropriate directory.

![](https://i.imgur.com/lAuTMgBh.png)

### Tools

The ShinyStudio image comes with…

-   R
-   Python
-   PowerShell

…and ODBC drivers for:

-   SQL Server
-   PostgresSQL
-   Cloudera Impala.

These are persistent because they are built into the image.

Apps / drivers installed through RStudio/VS Code will *not* persist.

Libraries for R, Python, and PowerShell *will* persist. Additionally,
user workspace settings (e.g. themes) are persistent.

Configuration
-------------

> The details below apply only to the master branch setup.

### Security

Authentication is managed by ShinyProxy, which supports basic auth,
LDAP, Kerberos, and others ([read
more](https://www.shinyproxy.io/configuration/)).

By default, ShinyStudio defines three levels of access:

-   readers: can only view content from “Apps & Reports”, “Documents”,
    and “Personal”.
-   admins: can view all site content and develop content with RStudio
    and VS Code.
-   superadmins: can view and develop site content across multiple
    instances of ShinyStudio.

Admin/Superadmin landing page:

![](https://i.imgur.com/qz55Vs5h.png)

Readers:

![](https://i.imgur.com/LupXe8fh.png)

To apply a custom security configuration, modify the ShinyProxy
configuration file for the site. All available options are detailed
[here](https://www.shinyproxy.io/configuration/).

``` text
./sites/8080.yml
```

Open `8080.yml` and edit the following lines as desired:

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

After modifying any part of the configuration, stop and re-setup the
site with:

``` bash
./control.sh setup "<mountpoint>"
```

### Multiple Sites

Multiple instances of ShinyProxy can be mapped to different ports in
order to segment content or provide unique customizations.

The configs below will setup two unique, independent instances of
ShinyStudio, hosted on ports 8080, 8081.

``` text
./sites/8080.yml
./sites/8081.yml
```

![](https://i.imgur.com/xnIuVTW.png)

#### Shared Content

It is possible to have multiple sites with independent configurations
have access to the same content. To do this, name the file
`PORT_SITEID.yml`, where `PORT` is the port to broadcast on, and
`SITEID` is the SITEID of the site that already has content.

``` text
./sites/8080.yml
./sites/8081_8080.yml
```

![](https://i.imgur.com/lgKdx93.png)

References
----------

-   <https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/README.md>
-   <https://www.shinyproxy.io/>
-   <https://telethonkids.wordpress.com/2019/02/08/deploying-an-r-shiny-app-with-docker/>
-   <https://appsilon.com/alternatives-to-scaling-shiny>
