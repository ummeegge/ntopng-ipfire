#!/bin/bash
############################################################################
#                                                                          #
# This file is part of the IPFire Firewall.                                #
#                                                                          #
# IPFire is free software; you can redistribute it and/or modify           #
# it under the terms of the GNU General Public License as published by     #
# the Free Software Foundation; either version 2 of the License, or        #
# (at your option) any later version.                                      #
#                                                                          #
# IPFire is distributed in the hope that it will be useful,                #
# but WITHOUT ANY WARRANTY; without even the implied warranty of           #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
# GNU General Public License for more details.                             #
#                                                                          #
# You should have received a copy of the GNU General Public License        #
# along with IPFire; if not, write to the Free Software                    #
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA #
#                                                                          #
# Copyright (C) 2007 IPFire-Team <info@ipfire.org>.                        #
#                                                                          #
############################################################################
#
. /opt/pakfire/lib/functions.sh
NAME="ntopng";
#stop_service ${NAME}
#extract_backup_includes
#make_backup ${NAME}
#remove_files

# Stop processes
if pidof -x "ntopng" >/dev/null; then
    /etc/init.d/ntopng stop;
fi
if pidof -x "redis-server" >/dev/null; then
    /etc/init.d/redis stop;
fi

# Delete files
rm -rvf \
/etc/ntopng \
/etc/rc.d/init.d/ntopng \
/usr/bin/ntopng \
/usr/share/ntopng \
/var/nst \
/var/tmp/ntopng \
/opt/pakfire/db/installed/meta-ntopng;

# Delete old symlink if presant
rm -rfv /etc/rc.d/rc?.d/???${NAME};

if grep -q "${NAME}" /etc/passwd; then
	userdel ${NAME};
	groupdel ${NAME};
	echo "Have deleted group and user 'ntopng'... ";
fi

# Check if Redis-Server is still there, if yes start it again
if ls /etc/rc.d/init.d/ | grep -q "redis"; then
	/etc/init.d/redis start;
fi

# EOF
