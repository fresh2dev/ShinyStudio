v0.5.0:
  * https by default
  * simplified management
  * removed many preinstalled packages (thinner img)
  * renamed 'start.sh' to 'entrypoint.sh'
  * properly used COMMAND as arg to ENTRYPOINT.
  * replaced standard python install w/ miniconda.
    * multiple environments
    * persistent apps
  * handled run-as-root scenarios.
  * readers/admins/superadmins -> viewers/developers/administrators

  * included cronicle
  * added sample scripts
    * backup content
    * refresh report(s)
    * http status check

  Added Digital Ocean Droplet management script.

v0.4.0:
* Redesigned for simpler setup and management.
  * "control" scripts now unnecessary; manage with docker-compose.
* HTTPS by default.
* Default HTTP port is now 80; HTTPS is 443.
* CertBot included for LetsEncrypt cert request/refresh.
* Created certify.[sh/ps1] to generate / request certs.

v0.3.0:
* Added NGINX reverse-proxy and enhanced setup scripts for all platforms.

v0.2.0:
* Separated Image from Stack
* Added '\_\_Personal\_\_' folder

v0.1.0:
* initial release

