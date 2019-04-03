ShinyStudio
================

* [What is ShinyStudio?](#what-is-shinystudio)
  * [Motivation](#motivation)
* [How to get it](#how-to-get-it)
* [Basic Use](#basic-use)
  * [Create some content](#create-some-content)
  * [Backup / Export Content](#backup--export-content)
* [Basic Configuration](#basic-configuration)
  * [Default Roles](#default-roles)
  * [Multiple Sites](#multiple-sites)
* [Updating ShinyStudio](#updating-shinystudio)
* [Setup Conclusion](#setup-conclusion)
* [Appendix](#appendix)
  * [Backstory](#backstory)
  * [Future Plans](#future-plans)

## What is ShinyStudio?

The ShinyStudio project is an orchestration of Docker services that
allows for easy, free, and secure development and hosting of rich,
interactive content with RStudio and Shiny Server, secured with
ShinyProxy.

The ShinyStudio ecosystem primarily consists of the products described
below. If you are unfamiliar with some or all of them, keep calm and
read on.

  - [RStudio Server](https://www.rstudio.com/): RStudio Server is a
    hosted instance of the RStudio, the development environment for
    authoring applications and documents in R. When you think RStudio,
    think *R development*.
  - [Shiny Server](https://shiny.rstudio.com/): Shiny is a web framework
    and Shiny Server is the web server component to serve and display
    created content. When you think Shiny, think *interactive
    presentation* of content.
  - [ShinyProxy](https://www.shinyproxy.io/): ShinyProxy is an
    open-source tool used to provide a secure entrypoint into the
    ShinyStudio ecosystem and is the driver behind on-demand invocation
    of Docker containers containing instances of RStudio or Shiny
    Server. When you think ShinyProxy, think *security and Docker
    container management*.
  - [Docker](https://www.docker.com/resources/what-container): Docker
    allows creating and deploying “containerized” instances of a
    service. In the ShinyStudio ecosystem, RStudio Server, Shiny Server,
    and ShinyProxy are all services delivered in a container. When you
    think Docker, think *configurable, scalable, containerized
    services*.

![](https://github.com/dm3ll3n/ShinyStudio/tree/master/controls/content/_docs/ShinyStudio/img/shinyrstudio.png?raw=true)

> ShinyStudio is not a product; it is a project / ecosystem wholly
> composed of the above products. ShinyStudio is not affiliated or
> supported by RStudio or OpenAnalytics. Anyone benefitting from this
> project should direct their appreciation to the developers of these
> products, RStudio, OpenAnalytics, and Docker.

### Motivation

If you have heard of the R language, you may rightfully associate it
with advanced statistical computing, machine learning and the like. In
recent years, however, the folks at RStudio have done amazing things
with R, both with RStudio and the R Shiny web framework. With their
products, R becomes an invaluable tool for creating rich, modern
applications and documents.

The problem is, when it comes to sharing the content, free options are
limiting and other options are… not free. ShinyStudio leverages
ShinyProxy to bring some essential features to the free versions of
RStudio and R Shiny, such as authentication and multiple sessions.

If you need enterprise-level abilities and support from RStudio,
consider premium solutions such as [RStudio Server
Pro](https://www.rstudio.com/products/rstudio-server-pro/), [Shiny
Server Pro](https://www.rstudio.com/products/shiny-server-pro/), and
[RStudio Connect](https://www.rstudio.com/products/connect/).

If your Shiny app / RMarkdown document is for public consumption and has
no need for authentication, explore these free-mium options for hosting
your content: (1) [shinyapps.io](https://www.shinyapps.io/) for hosting
Shiny apps or (2) [rpubs.com](https://rpubs.com/) for hosting static
RMarkdown docs.

If you’re struggling to decide between “totally free” and “totally
secure”, the ShinyStudio project can help bridge the gap.

## How to get it

Every component of the ShinyStudio project is delivered with Docker. To
get started, you do not need to know Docker, but you need to install
Docker and [Docker Compose](https://docs.docker.com/compose/install/).
See Docker install instructions for [Debian
Linux](https://docs.docker.com/install/linux/docker-ce/debian/),
[CentOS](https://docs.docker.com/install/linux/docker-ce/centos/),
[Mac](https://docs.docker.com/docker-for-mac/install/). I have not
designed or tested this process on Docker for Windows, but that is in
the future plans.

Once you get to a point where you can execute `docker info` with no
errors, you can proceed with the rest of this guide.

After installing Docker and Docker Compose, setup your ShinyStudio site
with:

``` text
# clone this repository.
git clone https://github.com/dm3ll3n/ShinyStudio

# enter it.
cd ShinyStudio

# setup site(s) with default configuration.
./control.sh setup
```

This operation can take a few minutes, as it is downloading all the
requisite components (RStudio Server, Shiny Server, ShinyProxy) along
with the default set of R packages.

Once complete, you can confirm that the necessary services are running
by executing `docker ps`. You should see both `shinystudio_shinyproxy`
and `shinystudio_influxdb` in the resulting output.

Once complete, open a web browser and navigate to
`http://localhost:8080`. When prompted, sign in with the username
`admin` and the password `admin`.

![](https://github.com/dm3ll3n/ShinyStudio/tree/master/controls/content/_docs/ShinyStudio/img/1554226694.png?raw=true)

You are now in the ShinyStudio ecosystem, ready to consume content with
Shiny Server or produce content with RStudio Server.

## Basic Use

At this point, you should have a running and accessible instance of
ShinyProxy, the gateway into the ShinyStudio ecosystem. When you sign in
with the `admin` account, you will see four tiles:

1.  Apps & Reports: open an instance of Shiny Server to view
    *applications* hosted on this site.
2.  Documents: open an instance of Shiny Server to view *documents*
    hosted on this site.
3.  All Content: (admin only) opens an instance of Shiny Server directed
    to the root directory of this site.
4.  RStudio: (admin only) opens an instance of RStudio Server for
    creating site content.

![](https://github.com/dm3ll3n/ShinyStudio/tree/master/controls/content/_docs/ShinyStudio/img/1554226778.png?raw=true)

Open RStudio to begin creating your own content. In the file explorer
pane of RStudio (bottom-right), you will see a folder named
"\_\_ShinyStudio\_\_“; that folder contains all the content for the
site. *Everything* outside of the”\_\_ShinyStudio**" directory will be
purged after exiting RStudio. That is because each instance of RStudio
is spun up in its own Docker container that is destroyed after each use
(more on this later). Only files created/modified within the
"\_\_ShinyStudio**" folder will persist between sessions.

![](https://github.com/dm3ll3n/ShinyStudio/tree/master/controls/content/_docs/ShinyStudio/img/1554226835.png?raw=true)

> *Everything* outside of the "\_\_ShinyStudio\_\_" directory will be
> purged after exiting RStudio. Only files created/modified within the
> "\_\_ShinyStudio\_\_" folder will persist between sessions.

### Create some content

There is great documentation for getting started with
[Shiny](https://shiny.rstudio.com/tutorial/) and
[RMarkdown](https://rmarkdown.rstudio.com/articles_intro.html). For now,
just create a new RMarkdown document by clicking `File > New File > R
Markdown`, or by opening one of the templates in the `templates` folder.
Edit the file, then `File > Save As...`, and save it to
`__ShinyStudio__/_docs/My Document/document.Rmd`.

> To properly serve the content, it is important that you place your
> document(s) in a folder. The folder name is what is displayed as the
> content title in Shiny Server.

Now, with the file saved under
`__ShinyStudio__/_docs/{TITLE}/{FILE}.Rmd`, browse to the ShinyStudio
home screen, select the “Documents” pane, and you will see your rendered
document.

![](https://github.com/dm3ll3n/ShinyStudio/tree/master/controls/content/_docs/ShinyStudio/img/1554232012.png?raw=true)

All content within the "\_\_ShinyStudio\_\_" folder is viewable from the
“Site Content” pane. Only content in the "\_apps" and "\_docs" folder is
viewable by a standard users.

So, admins can place content within "\_\_ShinyStudio\_\_“, but outside
of”\_apps" or "\_docs" in order to develop and test their work before
giving access to a standard user.

![](https://github.com/dm3ll3n/ShinyStudio/tree/master/controls/content/_docs/ShinyStudio/img/1554226895.png?raw=true)

Note that the differentiation between “apps” and “docs” is purely for
organization; there’s no harm in, say, putting a document in the
"\_apps" folder or vice versa.

It’s as simple as that, and the process for creating Shiny apps is
almost exactly the same.

### Backup / Export Content

To persist content as Docker containers are created and destroyed, all
site content is stored on the host server at `/srv/shiny-server/{PORT}`
(by default). Thus, you can use whatever method you want to backup and
restore content in this folder.

In addition, site admins can use RStudio to download a zip of all the
content in the "\_\_ShinyStudio\_\_" directory. Also, it’s a good idea
to initialize a git repo in this here; RStudio has a useful git
interface for managing versions of apps and documents.

![](https://github.com/dm3ll3n/ShinyStudio/tree/master/controls/content/_docs/ShinyStudio/img/1554226952.png?raw=true)

You may notice the hidden directory `/srv/shiny-server/.rstudio`. This
contains user preferences within RStudio. While session states are not
saved between instances of RStudio, user preferences (e.g., theme, font)
are persistent. You may want to include this in your backups.

## Basic Configuration

When ShinyProxy is running, your site’s content is accessible by others
over port `8080` (by default). It is a good idea to apply a custom
security configuration before going any further.

ShinyProxy offers a variety of authentication mechanisms, detailed
[here](https://www.shinyproxy.io/configuration/). To alter your sites
security, modify the configuration file for that site.

To do nothing other than change the default passwords, locate the config
file for the site hosted on port 8080; you can find it here:

``` text
./shinyproxy/config/sites/8080.yml
```

> In this folder, you will see example configurations that have been
> disabled. These provide examples of using ShinyProxy with basic auth
> (default), social auth, Active Directory auth, and no auth. These also
> show how you can easily switch from a 2-column layout to a 1-column
> layout in ShinyProxy.

Open `8080.yml` in your editor of choice. Then, locate and edit the
following lines as desired:

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

Once you’ve made the desired edits, setup the site again with:

``` bash
./control.sh setup
```

### Default Roles

By default, ShinyStudio defines three levels of access:

  - readers: can only view content from “Apps & Reports” or “Documents”.
  - admins: can view all site content and develop content with RStudio.
  - superadmins: can view and develop site content across multiple
    sites.

### Multiple Sites

Spawning multiple instances of ShinyProxy is an uncomplicated process.
This can be useful to segment content or provide unique customizations,
as each site own configuration, port, and content.

To create a new site, copy an existing site configuration, make the
desired edits, and name the new file with the desired port number.

The default setup spawns one instance of ShinyProxy at the default port
8080.

``` text
./shinyproxy/config/sites/8080.yml
```

![](https://github.com/dm3ll3n/ShinyStudio/tree/master/controls/content/_docs/ShinyStudio/img/1554255282.png?raw=true)

#### Add Sites

The setup below will spawn three unique, independent instances of
ShinyProxy, hosted on ports 8080, 8081, and 8082.

``` text
./shinyproxy/config/sites/8080.yml
./shinyproxy/config/sites/8081.yml
./shinyproxy/config/sites/8082.yml
```

![](https://github.com/dm3ll3n/ShinyStudio/tree/master/controls/content/_docs/ShinyStudio/img/1554255306.png?raw=true)

> Note: ShinyProxy logs usage to InfluxDB, which is typically served on
> port 8086. To avoid conflicts with multiple ShinyProxy sites, InfluxDB
> is served on port 8886 in the ShinyStudio ecosystem.

#### Disable Sites

To disable a site, just the extension of its config file. In the setup
below, only sites 8080 and 8082 will be hosted.

``` text
./shinyproxy/config/sites/8080.yml
./shinyproxy/config/sites/8081.yml_
./shinyproxy/config/sites/8082.yml
```

#### Shared Content

It is possible to have two sites with independent configurations have
access to the same content. To do this, name the file `PORT_SITE.yml`,
where `PORT` is the port to broadcast on, and `SITE` is the port number
of the site that already has content.

In the setup below, three unique instances of ShinyProxy will be
invoked, hosted on ports 8080, 8081, and 8082. However, each site
contains the same content (from 8080), and any changes to content in one
site will be reflected in another.

``` text
./shinyproxy/config/sites/8080.yml
./shinyproxy/config/sites/8081_8080.yml
./shinyproxy/config/sites/8082_8080.yml
```

![](https://github.com/dm3ll3n/ShinyStudio/tree/master/controls/content/_docs/ShinyStudio/img/1554255374.png?raw=true)

## Updating ShinyStudio

After editing site configurations, you will have to rebuild your
ShinyStudio ecosystem with the command below. The same command will also
pull the latest version of RStudio Server and Shiny Server.

``` bash
./control.sh setup
```

## Setup Conclusion

At this point, you should have one or more ShinyStudio sites, accessible
and secured with ShinyProxy. It is my goal that this ecosystem is
valuable to both technical and non-technical audiences, to both R
statisticians and college notetakers.

The information below is not essential to the use of the ShinyStudio
ecosystem, so feel free to stop here and get to creating\!

## Appendix

### Backstory

I had the goal of having a secured Shiny Server that would be usable by
people with no experience with RStudio, Docker, Git. A quick search led
me to [ShinyProxy.io](https://www.shinyproxy.io/), which is what drives
this solution.

Aside from the thorough documentation on their site, I landed on this
[article from Paul Stevenson of the Telethon Kids
Institute](https://telethonkids.wordpress.com/2019/02/08/deploying-an-r-shiny-app-with-docker/)
in which he describes [his ShinyProxy / Shiny Server Docker
stack](https://github.com/TelethonKids/deploy_shiny_app). His stack is
tidy, well-explained, and includes an NGINX proxy and automatic SSL
configuration that are essentially required if you want ShinyProxy to be
internet-facing.

There were two major problems I had with documented approaches which
invoke the Shiny R package via standalone instances of R:

  - Tedius effort involved in “containerizing” *each* app/doc to be
    hosted.
  - Downloading and compiling libraries for *each* app/doc can take
    several minutes.
  - ShinyProxy requires an edit to the `application.yml` file, followed
    by a restart, for *each* new app/doc.

These two limitations result in content creation being both a tedious
and service-interrupting event. I wanted a reliable system that had a
low learning curve and facilitated rapid development of content.

On the search for alternative approaches, I found [this article from
Appsilon.com](https://appsilon.com/alternatives-to-scaling-shiny) which
featured some [useful and though-provoking
diagrams](https://appsilon.com/assets/uploads/2018/12/Scaling-Shiny-1.png?raw=true)
on the matter.

It was while reviewing those diagrams that I came to the conclusion that
it would be better to “containerize” Shiny Server for invocation with
ShinyProxy, as opposed to individual instances of standlone R. That
simple trick is the magic to the ShinyStudio approach.

### ShinyProxy: documented approach

![](https://github.com/dm3ll3n/ShinyStudio/tree/master/controls/content/_docs/ShinyStudio/img/1554234336.png?raw=true)

### ShinyProxy: the ShinyStudio approach

![](https://github.com/dm3ll3n/ShinyStudio/tree/master/controls/content/_docs/ShinyStudio/img/1554234393.png?raw=true)

### Comparison

There are trade-offs between the two ShinyProxy workflows, discussed
below.

|                   |   R Standalone    |     Shiny Server      |
| :---------------: | :---------------: | :-------------------: |
|   R environment   |    Independent    |        Shared         |
|  Authentication   |     Low-level     |      High-level       |
|    Access logs    |     Low-level     |      High-level       |
|   Docker images   |       Many        |          One          |
| Docker containers |       Many        |         Fewer         |
| Content delivery  | Manual w/ Restart | Automatic; No restart |

**R environment**

By packaging each app into a Docker image, each apps is independent of
others and has a unique set of R libraries at its disposal.

In the ShinyStudio ecosystem, all apps share the same image which
contains both RStudio and Shiny Server and all the R libraries. This
facilitates rapid development, but can be an issue if you have two apps
with conflicting dependency requirements.

**Authentication**

ShinyProxy allows group-based authentication to each Docker image. When
each Docker image is an individual app, you have granular security
controls for each app.

In the ShinyStudio ecosystem, you can control who can see “Apps &
Reports”, who can see “Documents”, and who can author content with
RStudio, but you cannot control *which* apps or documents they have
access to.

**Access logs**

ShinyProxy logs the logins and Docker image launches. When each Docker
image is an individual app, you have granular access logs.

In the ShinyStudio ecosystem, logs are generated when a user opens a
particular pane, but which apps/docs they access from there are not
logged.

**Images / Containers**

Naturally, when each app has its own Docker image, you’ll have a lot of
images. Likewise, if each app invocation spawns a new container, one
user could feverishly spawn many containers.

In the ShinyStudio ecosystem, there is only one image for RStudio and
Shiny, and content is stored externally. Containers are spun up when a
new instance of Shiny / RStudio Server is needed, e.g. when a user
accesses “Apps & Reports”. Accessing multiple apps within this container
will not spawn new containers; the apps will share the resources of the
executing Shiny Server container.

**Content delivery**

As stated earlier, changes to the list of Docker images available to
ShinyProxy requires a restart of ShinyProxy itself, which is not ideal
for rapid development.

In the ShinyStudio ecosystem, spawned instances of Shiny Server have
immediate access to the latest apps and docs in the site’s directory.

### Future Plans

  - \[ \] Enhance thumbnail quality, enhance ShinyProxy index page.
  - \[ \] Enhance `setup.sh` and other scripts to eliminate the need to
    restart when adding a new site.
  - \[ \] Load common database drivers in RStudio image.
  - \[ \] Test and document setup on Docker for Windows.
  - \[ \] Cross-site content access for non-admin users.
  - \[ \] Allow Shiny bookmark functionality.
  - \[ \] Allow for customizing navbar colors for each site.
  - \[ \] Shiny app to serve as searchable index page for each section.
  - \[ \] Shiny app for viewing ShinyProxy events from InfluxDB.
  - \[ \] Automated SSL setup

Pull requests are welcome and appreciated\!
