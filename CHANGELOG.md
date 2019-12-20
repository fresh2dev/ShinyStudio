v0.5.0:
  * included cronicle task scheduler with sample jobs.
  * replaced standard python install w/ miniconda.
    * multiple environments
    * persistent apps
  * removed many preinstalled packages (thinner img)
  * renamed 'start.sh' to 'entrypoint.sh'
  * properly used COMMAND as arg to ENTRYPOINT.
  * handled run-as-root scenarios.
  * default users/roles "readers/admin/superadmin" are now "viewers/developers/administrators"
  * generate self-signed cert if non exists.

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

