# Changelog

## v1.0.0

> This version is a major overhaul that includes *many* changes that are not backwards compatible. If you are running an existing version, backup existing content and re-setup from scratch.

- Added VS Code with persistent user-specific extensions and workspace settings. 
- Added new "__Personal__" directory to store and persist user-specific content.
- Restuctured content directories.
- Redesigned landing page.
- Added example content illustrating how to serve pre-rendered Jupyter notebooks.
- Added drivers for SQL Server and Postgres.

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
