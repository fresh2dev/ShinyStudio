ShinyStudio
================

![](https://i.imgur.com/rtd29qC.png)

![](https://i.imgur.com/FIzE0d7.png)

- [What is ShinyStudio?](#what-is-shinystudio)
- [How to get it](#how-to-get-it)
- [Access](#access)
- [Develop](#develop)
  - [Tools](#tools)
- [Content](#content)
- [Configuration](#configuration)
  - [Security](#security)
  - [Multiple Sites](#multiple-sites)
- [Customizing](#customizing)
- [Reinstalling](#reinstalling)
- [References](#references)
- [Contributing](#contributing)

What is ShinyStudio?
--------------------

> NOTE: v1.0.0 is a major overhaul that includes *many* changes that are not backwards compatible. If you are running an existing version, backup existing content and re-setup from scratch.

The ShinyStudio project is an orchestration of Docker services with the goal of providing:

-   a collaborative, self-hosted development environment with a choice of IDE (RStudio or VS Code).
-   a centralized document repository, capable of displaying pre-rendered HTML, Markdown, or live, interactive RMarkdown documents.
-   a secure method for sharing web apps developed with RStudio Shiny.

The ShinyStudio ecosystem primarily consists of the products described below:

-   [ShinyProxy](https://www.shinyproxy.io/) (Reverse proxy & Docker manager)
-   [Shiny Server](https://shiny.rstudio.com/) (Web Server)
-   [RStudio Server](https://www.rstudio.com/) (IDE)
-   [VS Code](https://code.visualstudio.com/), modified by [Coder.com](https://coder.com/) (IDE)
-   [Docker](https://www.docker.com/resources/what-container) (Containers)

![](https://i.imgur.com/ppQsjIx.png)

> ShinyStudio is not a product; it is a project / ecosystem wholly composed of the above products. ShinyStudio is not affiliated with or supported by RStudio, Microsoft, or OpenAnalytics.

How to get it
-------------

Prereqs:

-   [Docker](https://docs.docker.com/install/linux/docker-ce/debian/) / [Docker for Mac](https://docs.docker.com/docker-for-mac/install/)
-   [Docker Compose](https://docs.docker.com/compose/install/)
-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Setup your ShinyStudio site with:

``` text
# Clone this repository.
git clone https://github.com/dm3ll3n/ShinyStudio

# Enter the new directory.
cd ShinyStudio

# Setup and run.
./control.sh setup
```

This operation can take a few minutes.

Once complete, open a web browser and navigate to `http://localhost:8080`.

The default logins are: \* `user`: `user` \* `admin`: `admin` \* `superadmin`: `superadmin`

Access
------

Authentication is managed by ShinyProxy, which supports basic auth, LDAP, Kerberos, and others ([read more](https://www.shinyproxy.io/configuration/)).

ShinyStudio defines three levels of access:

-   readers: can only view content from "Apps & Reports", "Documents", and "Personal".
-   admins: can view all site content and develop content with RStudio and VS Code.
-   superadmins: can view and develop site content across multiple instances of ShinyStudio.

Admin/Superadmin landing page:

![](https://i.imgur.com/rtd29qC.png)

Readers:

![](https://i.imgur.com/LupXe8f.png)

Develop
-------

Open your IDE of choice and notice two important directories:

-   \_\_ShinyStudio\_\_
-   \_\_Personal\_\_

![](https://i.imgur.com/ac7iKDH.png)

**Files must be saved in either of these two directories in order to persist between sessions.**

These two folders are shared between instances RStudio, VS Code, and Shiny Server. So, creating new content is as simple as saving a file to the appropriate directory.

![](https://i.imgur.com/lAuTMgB.png)

### Tools

The ShinyStudio ecosystem comes with...

-   R
-   Python
-   PowerShell

...and ODBC drivers for:

-   SQL Server
-   PostgresSQL
-   Cloudera Impala.

These are persistent because they are built into the image.

Apps / drivers installed through RStudio/VS Code will *not* persist.

Libraries for R, Python, and PowerShell *will* persist. Additionally, user workspace settings (e.g. themes) are persistent.

Content
-------

All persisted content is stored locally on the host system at:

``` text
/srv/shinystudio
```

To store files in another directory, edit the `MOUNTPOINT` variable in `control.sh`.

Configuration
-------------

### Security

To apply a custom security configuration, modify the ShinyProxy configuration file for the site. All available options are detailed [here](https://www.shinyproxy.io/configuration/).

``` text
./shinyproxy/config/sites/8080.yml
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

After modifying any part of the configuration, stop and re-setup the site with:

``` bash
./control.sh setup
```

### Multiple Sites

Multiple sites can be useful to segment content or provide unique customizations.

The configs below will setup two unique, independent instances of ShinyStudio, hosted on ports 8080, 8081.

``` text
./shinyproxy/config/sites/8080.yml
./shinyproxy/config/sites/8081.yml
```

![](https://i.imgur.com/xnIuVTW.png)

#### Shared Content

It is possible to have multiple sites with independent configurations have access to the same content. To do this, name the file `PORT_SITE.yml`, where `PORT` is the port to broadcast on, and `SITE` is the port number of the site that already has content.

``` text
./shinyproxy/config/sites/8080.yml
./shinyproxy/config/sites/8081_8080.yml
```

![](https://i.imgur.com/lgKdx93.png)

Customizing
-----------

To customize the landing page, edit:

``` text
./shinyproxy/config/templates/grid-layout/index.html
```

To simply replace the background, replace the file below with the background desired background:

``` text
./shinyproxy/config/templates/grid-layout/assets/img/background.png
```

![](https://i.imgur.com/Tl16HGv.png)

Reinstalling
------------

> Site content is never removed by any of the provided control scripts; you must do this manually, if desired.

To thoroughly remove and reinstall ShinyStudio:

``` bash
# remove ShinyStudio Docker containers & images.
./control.sh remove

# remove site content!
sudo rm -rf "$MOUNTPOINT"

# removes *all* unused Docker volumes!
docker volume prune

# setup ShinyStudio
./control.sh setup
```

By removing existing images, the setup will pull the latest versions of the base Docker image for RStudio/Shiny.

References
----------

-   <https://www.shinyproxy.io/>
-   <https://telethonkids.wordpress.com/2019/02/08/deploying-an-r-shiny-app-with-docker/>
-   <https://appsilon.com/alternatives-to-scaling-shiny>

Contributing
------------

Pull requests are welcome and appreciated, particularly with:

-   \[ \] Enhance the setup experience (e.g., parameterizing control.sh)
-   \[ \] Enable Shiny bookmark functionality.
-   \[ \] Shiny app to serve as searchable index page for each section.
-   \[ \] Shiny app for viewing ShinyProxy events from InfluxDB.
-   \[ \] Automated SSL setup
