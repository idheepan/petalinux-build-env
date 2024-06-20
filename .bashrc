# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


export DL_DIR=$HOME/cache/downloads
export SSTATE_DIR=$HOME/cache/sstate-cache
source /opt/petalinux/settings.sh