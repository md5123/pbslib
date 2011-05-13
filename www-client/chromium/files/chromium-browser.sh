#!/bin/sh

# Chromium launcher

# Authors:
#  Fabien Tassin <fta@sofaraway.org>
# License: GPLv2 or later

APPNAME=chromium
LIBDIR=/usr/lib/chromium
GDB=/usr/bin/gdb

usage () {
  echo "$APPNAME [-h|--help] [-g|--debug] [options] [URL]"
  echo
  echo "        -g or --debug           Start within $GDB"
  echo "        -h or --help            This help screen"
  echo
  echo " Other supported options are:"
  MANWIDTH=80 man chromium-browser | sed -e '1,/OPTIONS/d; /ENVIRONMENT/,$d'
  echo " See 'man chromium-browser' for more details"
}

# Prefer user defined CHROMIUM_USER_FLAGS (fron env) over system
# default CHROMIUM_FLAGS (from /etc/$APPNAME/default)
CHROMIUM_FLAGS=${CHROMIUM_USER_FLAGS:-"$CHROMIUM_FLAGS"}

# FFmpeg needs to know where its libs are located
if [ "Z$LD_LIBRARY_PATH" != Z ] ; then
  LD_LIBRARY_PATH=$LIBDIR:$LD_LIBRARY_PATH
else
  LD_LIBRARY_PATH=$LIBDIR
fi
export LD_LIBRARY_PATH

# For the Default Browser detection to work, we need to give access
# to xdg-settings. Also set CHROME_WRAPPER in case xdg-settings is
# not able to do anything useful
export PATH="$LIBDIR:$PATH"
export CHROME_WRAPPER=true

# We include some xdg utilities next to the binary, and we want to prefer them
# over the system versions when we know the system versions are very old. We
# detect whether the system xdg utilities are sufficiently new to be likely to
# work for us by looking for xdg-settings. If we find it, we leave $PATH alone,
# so that the system xdg utilities (including any distro patches) will be used.
HERE="`dirname "$0"`"
if ! which xdg-settings &> /dev/null; then
	# Old xdg utilities. Prepend $HERE to $PATH to use ours instead.
	export PATH="$HERE:$PATH"
else
	# Use system xdg utilities. But first create mimeapps.list if it doesn't
        # exist; some systems have bugs in xdg-mime that make it fail without it.
	xdg_app_dir="${XDG_DATA_HOME:-$HOME/.local/share/applications}"
	mkdir -p "$xdg_app_dir"
	[ -f "$xdg_app_dir/mimeapps.list" ] || touch "$xdg_app_dir/mimeapps.list"
fi

# Set CHROME_VERSION_EXTRA visible in the About dialog and in about:version
export CHROME_VERSION_EXTRA="Ylmf OS"

want_debug=0
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help | -help )
      usage
      exit 0 ;;
    -g | --debug )
      want_debug=1
      shift ;;
    -- ) # Stop option prcessing
      shift
      break ;;
    * )
      break ;;
  esac
done

if [ $want_debug -eq 1 ] ; then
  if [ ! -x $GDB ] ; then
    echo "Sorry, can't find usable $GDB. Please install it."
    exit 1
  fi
  tmpfile=`mktemp /tmp/chromiumargs.XXXXXX` || { echo "Cannot create temporary file" >&2; exit 1; }
  trap " [ -f \"$tmpfile\" ] && /bin/rm -f -- \"$tmpfile\"" 0 1 2 3 13 15
  echo "set args $CHROMIUM_FLAGS ${1+"$@"}" > $tmpfile
  echo "# Env:"
  echo "#     LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
  echo "#                PATH=$PATH"
  echo "#            GTK_PATH=$GTK_PATH"
  echo "# CHROMIUM_USER_FLAGS=$CHROMIUM_USER_FLAGS"
  echo "#      CHROMIUM_FLAGS=$CHROMIUM_FLAGS"
  echo "$GDB $LIBDIR/$APPNAME -x $tmpfile"
  $GDB "$LIBDIR/$APPNAME" -x $tmpfile
  exit $?
else
  #cp default Preferences to HOME
  #	
  if [ ! -d $HOME/.config/chromium ]; then
  	mkdir -p $HOME/.config
	tar xf /usr/lib/chromium/chromium.tar.bz2 -C $HOME/.config/
	chown -R $USER:$USER $HOME/.config/chromium
  fi
  exec $LIBDIR/$APPNAME $CHROMIUM_FLAGS "$@"
fi

