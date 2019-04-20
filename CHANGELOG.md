# Changelog

## v0.3.0

- Python 3 and PowerShell Core are now installed in the RStudio / Shiny image.
- R, Python, and PowerShell packages are persistent.

## v0.2.0

- RStudio / Shiny image is now built with a few additional packages and an ODBC driver for Cloudera Impala.
- RStudio / Shiny startup script edited to create new user *first*, before adding to the new user's home folder.
- Reduced docker-compose.yml version from 3.7 to 3.5 to improve compatibility with older versions of docker-compose.
- Added sections to doc: "Customizing ShinyStudio" and "Persistent Drivers".

## v0.1.1

- Improved compatibility with SELinux.
- Restructured control scripts.
- Fixed issue #1; R packages not persisting.

## v0.1.0

Initial release
