export MOUNTPOINT="/srv/shiny-server"
export USER=$USER
export USERID=$UID
export SITEID=0         # placeholder to ensure successful build
export SITEPORT=8080    # placeholder to ensure successful build
export DESTSITE=8080    # placeholder to ensure successful build

pushd ./controls > /dev/null

source "./$1.sh"

popd > /dev/null
