#!/bin/bash
#

#
if [ -f /etc/yget.conf ]; then
	. /etc/yget.conf
	if [ ! -h $HOME/Apps ] && [ -d $YPPATH_PKGDEST ]; 
		ln -sf $YPPATH_PKGDEST $HOME/Apps
	fi
fi
#
if [ -f $HOME/.config/user-dirs.dirs ] && [ ! -f $HOME/.flag ]; then
	. $HOME/.config/user-dirs.dirs
	for i in 115u-web.desktop chromium.desktop; do
		cp /usr/share/applications/${i}	$XDG_DESKTOP_DIR
	done
	touch $HOME/.flag
fi

exit 0
