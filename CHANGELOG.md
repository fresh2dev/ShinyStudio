https by default
simplified mangement
removed many preinstalled packages (thinner img)
renamed 'start.sh' to 'entrypoint.sh'
properly used COMMAND as arg to ENTRYPOINT.
replaced traditional python install w/ miniconda.
  - multiple environments
  - persistent apps
added cronicle.
handled run-as-root scenarios.
readers/admins/superadmins -> viewers/developers/administrators

included cronicle
added sample scripts
  - refresh report
  - backup content
  - http status check
