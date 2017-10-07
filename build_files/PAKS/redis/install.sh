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
NAME="redis";
extract_files
restore_backup ${NAME}

# Delete old symlink if presant
rm -rfv /etc/rc.d/rc?.d/???${NAME};

## Add symlinks
# Possible runlevel ranges
SO="[7-9][0-9]";
SA="[1-3][0-9]";
RE="[7-9][0-9]";
# Search free runlevel
STOP=$(ls /etc/rc.d/rc0.d/ | sed -e 's/[^0-9]//g' | awk '$1!=p+1{print p+1" "$1-1}{p=$1}' | sed -e '1d' | tr ' ' '\n' | grep -E "${SO}" | head -1);
START=$(ls /etc/rc.d/rc3.d/ | sed -e 's/[^0-9]//g' | awk '$1!=p+1{print p+1" "$1-1}{p=$1}' | sed -e '1d' | tr ' ' '\n' | grep -E "${SA}" | head -1);
REBOOT=$(ls /etc/rc.d/rc6.d/ | sed -e 's/[^0-9]//g' | awk '$1!=p+1{print p+1" "$1-1}{p=$1}' | sed -e '1d' | tr ' ' '\n' | grep -E "${RE}" | head -1);
## Add symlinks 
ln -s ../init.d/${NAME} /etc/rc.d/rc0.d/K${STOP}${NAME};
ln -s ../init.d/${NAME} /etc/rc.d/rc3.d/S${START}${NAME};
ln -s ../init.d/${NAME} /etc/rc.d/rc6.d/K${REBOOT}${NAME};

# Add meta file for IPFire WUi status section
if ! ls /opt/pakfire/db/installed/ | grep -q "meta-${NAME}"; then
	touch /opt/pakfire/db/installed/meta-${NAME};
	echo "${Y}Have added now meta file for de- or activation via IPfire WUI ${NAME} on reboot... ${N}";
	echo;
	seperator;
else
	echo "${NAME} meta file has already been set, will do nothing... ";
fi

# Start redis
/etc/init.d/${NAME} start;

# EOF
