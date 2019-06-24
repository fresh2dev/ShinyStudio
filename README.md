ShinyStudio
===========

*A Docker image of RStudio + VS Code + Shiny Server, driven by ShinyProxy.*
---------------------------------------------------------------------------

-   [Overview](#overview)
-   [Flavors](#flavors)
-   [Setup from DockerHub](#setup-from-dockerhub)
    -   [Linux / Mac (Bash)](#linux-mac-bash)
    -   [Windows (PowerShell)](#windows-powershell)
-   [Setup from GitHub](#setup-from-github)
    -   [Linux / Mac (Bash)](#linux-mac-bash-1)
    -   [Windows (PowerShell)](#windows-powershell-1)
-   [Develop](#develop)
-   [Tools](#tools)
-   [Advanced Configuration](#advanced-configuration)
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

Flavors
-------

The ShinyStudio stack has been verified to work on native Docker, as
well as Docker Desktop for Mac and Windows.

The GitHub repo for the ShinyStudio image is used to build the image
published on DockerHub. The image is great for a personal instance, a
quick demo, or the building blocks for a very customized setup.

<a href="https://github.com/dm3ll3n/ShinyStudio-Image" class="uri">https://github.com/dm3ll3n/ShinyStudio-Image</a>

The repo for the enhanced setup of ShinyStudio builds upon the base
image to provide an example of a more enterprise-ready instance of
ShinyStudio, including NGINX, InfluxDB, and control scripts.

<a href="https://github.com/dm3ll3n/ShinyStudio" class="uri">https://github.com/dm3ll3n/ShinyStudio</a>

Setup from DockerHub
--------------------

> Setup must not be run as ‘root’.

First, create a network named `shinystudio-net` to be shared by all
spawned containers.

``` text
docker network create shinystudio-net
```

Then, pull and run the ShinyStudio image directly from DockerHub.

### Linux / Mac (Bash)

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

### Windows (PowerShell)

``` text
docker run --rm -it --name shinyproxy `
    --network shinystudio-net `
    -v /var/run/docker.sock:/var/run/docker.sock `
    -e USERID=1000 `
    -e USER=$env:USERNAME `
    -e PASSWORD=password `
    -e MOUNTPOINT="/host_mnt/c/Users/$env:USERNAME/ShinyStudio" `
    -e SITEID=default `
    -p 8080:8080 `
    dm3ll3n/shinystudio
```

> Notice the unique form of the path for the `MOUNTPOINT` variable in
> the Windows setup.

Once complete, open a web browser and navigate to
`http://<hostname>:8080`. Log in with your username and the password
`password`.

Variables:

<table>
<colgroup>
<col style="width: 10%" />
<col style="width: 17%" />
<col style="width: 72%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>Variable</strong></th>
<th><strong>Default</strong></th>
<th><strong>Explained</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>USERID</td>
<td>$USERID</td>
<td>For proper permissions, this value should not be changed.</td>
</tr>
<tr class="even">
<td>USER</td>
<td>$USER</td>
<td>Username to use at the ShinyProxy login screen.</td>
</tr>
<tr class="odd">
<td>PASSWORD</td>
<td>password</td>
<td>Password to use at the ShinyProxy login screen.</td>
</tr>
<tr class="even">
<td>MOUNTPOINT</td>
<td>“${HOME}/ShinyStudio”</td>
<td>The path to store site content and user settings.</td>
</tr>
<tr class="odd">
<td>SITEID</td>
<td>default</td>
<td>Defines the folder name that this site’s content will reside in (<code>$MOUNTPOINT/sites/$SITEID</code>).</td>
</tr>
<tr class="even">
<td>ROOT</td>
<td>false</td>
<td>Grant root permission in RStudio / VS Code? Useful for testing, but changes are not persistent.</td>
</tr>
</tbody>
</table>

Setup from GitHub
-----------------

The enhanced ShinyStudio setup requires Docker, docker-compose, and Git.

> Setup must be run as a non-root user.

``` text
# Clone the master branch.
git clone https://github.com/dm3ll3n/ShinyStudio

# Enter the new directory.
cd ShinyStudio
```

### Linux / Mac (Bash)

``` text
./control.sh setup
```

### Windows (PowerShell)

``` text
./control.ps1 setup
```

The default mountpoint is `$PWD/content`. To specify another mountpoint,
pass the desired path as an argument to the setup:

``` text
./control.[sh|ps1] setup "$HOME/ShinyStudio"
```

Once complete, open a web browser and navigate to
`http://<hostname>:8080`.

The default logins are:

| **username** | **password** |
|:------------:|:------------:|
|     user     |     user     |
|     admin    |     admin    |
|  superadmin  |  superadmin  |

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

Tools
-----

The ShinyStudio image comes with…

-   R
-   Python 3
-   PowerShell

…and ODBC drivers for:

-   SQL Server
-   PostgresSQL
-   Cloudera Impala.

These are persistent because they are built into the image.

|                               | Persistent |
|------------------------------:|:----------:|
|  \_\_ShinyStudio\_\_ directory|     Yes    |
|     \_\_Personal\_\_ directory|     Yes    |
|              Other directories|   **No**   |
|                    R Libraries|     Yes    |
|                Python Packages|     Yes    |
|             PowerShell Modules|     Yes    |
|          RStudio User Settings|     Yes    |
|          VS Code User Settings|     Yes    |
|                 Installed Apps|   **No**   |
|              Installed Drivers|   **No**   |

![](https://i.imgur.com/lgKdx93.png)

Advanced Configuration
----------------------

The information below applies only to the [“enhanced” setup on
GitHub](https://github.com/dm3ll3n/ShinyStudio).

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

Admin / SuperAdmin landing page:

![](https://i.imgur.com/qz55Vs5h.png)

Readers:

![](https://i.imgur.com/LupXe8fh.png)

To apply a custom security configuration, modify the ShinyProxy
configuration file for the site. All available options are detailed in
the [docs for ShinyProxy](https://www.shinyproxy.io/configuration/).

``` text
./sites/8080_Site1.yml
```

> The site config files should follow the covention
> "{SITEPORT}\_{SITEID}.yml“, where”SITEPORT" is the port to host the
> site, and “SITEID” is a unique idenfifier for the site.

Open `8080_Site1.yml` and edit the following lines as desired:

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

To enforce LDAP authentication, use:

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

After modifying any part of the configuration, stop and re-setup the
site with:

``` bash
# Linux / Mac
./control.sh setup "<mountpoint>"

# Windows
./control.ps1 setup "<mountpoint>"
```

### Multiple Sites

Multiple instances of ShinyProxy can be mapped to different ports in
order to segment content or provide unique customizations.

The configs below will setup two unique, independent instances of
ShinyStudio, hosted on ports 8080, 8081.

``` text
./sites/8080_Site1.yml
./sites/8081_Site2.yml
```

![](https://i.imgur.com/xnIuVTW.png)

#### Shared Content

It is possible to have multiple sites with independent configurations
have access to the same content. To do this, name the file
`PORT_SITEID.yml`, where `PORT` is the port to broadcast on, and
`SITEID` is the SITEID of the site that already has content.

``` text
./sites/8080_Site1.yml
./sites/8081_Site1.yml
```

![](https://i.imgur.com/lgKdx93.png)

References
----------

-   <a href="https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/README.md" class="uri">https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/README.md</a>
-   <a href="https://www.shinyproxy.io/" class="uri">https://www.shinyproxy.io/</a>
-   <a href="https://telethonkids.wordpress.com/2019/02/08/deploying-an-r-shiny-app-with-docker/" class="uri">https://telethonkids.wordpress.com/2019/02/08/deploying-an-r-shiny-app-with-docker/</a>
-   <a href="https://appsilon.com/alternatives-to-scaling-shiny" class="uri">https://appsilon.com/alternatives-to-scaling-shiny</a>
