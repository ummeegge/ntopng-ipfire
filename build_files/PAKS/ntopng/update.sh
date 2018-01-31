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

CONF="/etc/ntopng";
DB="/var/nst";
BCK="/tmp/ntopng_bck";
CERT="/usr/share/ntopng/httpdocs/ssl";

. /opt/pakfire/lib/functions.sh

# Stop services
/etc/init.d/ntopng stop && /etc/init.d/redis stop;

# Create backup dir
mkdir -p /tmp/ntopng_bck;
# Save ntopng config and protos.txt
mv -f ${CONF}/ntopng.conf ${CONF}/scripts/protos.txt ${DB}/ntopng ${CERT}/ntopng-cert.pem ${BCK};

./uninstall.sh
./install.sh

# Recover configs back
mv -f ${BCK}/ntopng.conf ${CONF};
mv -f ${BCK}/protos.txt ${CONF}/scripts;
mv -f ${BCK}/ntopng-cert.pem ${CERT};
mv -f ${BCK}/ntopng ${DB};

# Restart service
/etc/init.d/redis restart && /etc/init.d/ntopng restart;

# Delete tmp backup dir
rm -rf ${BCK};

# EOF

