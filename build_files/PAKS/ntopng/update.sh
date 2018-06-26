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

NTOPCONF="/etc/ntopng";
NTOPDB="/var/nst";
BCK="/tmp/ntopng_bck";
CERT="/usr/share/ntopng/httpdocs/ssl";
GEOIP="/usr/share/ntopng/httpdocs/geoip";

# Stop services
/etc/init.d/ntopng stop && /etc/init.d/redis stop;

# Create backup dir
echo "Create backup directory and store redis and ntopng configuration and data";
echo;
mkdir -p /tmp/ntopng_bck;
# Save ntopng config and protos.txt
mv -f ${NTOPCONF}/ntopng.conf ${NTOPCONF}/scripts/protos.txt ${NTOPDB}/ntopng ${CERT}/ntopng-cert.pem ${BCK};
# Back GeoIP dat´s if presant
if ls ${GEOIP} | grep -q '.*.dat'; then
    mv -f *.dat ${BCK};
fi

./uninstall.sh
./install.sh

# Recover configs back
echo "Play backup of redis and ntopng configuration and db back";
echo;
# Write ntopng config and db back
mv -f ${BCK}/ntopng.conf ${NTOPCONF};
mv -f ${BCK}/protos.txt ${NTOPCONF}/scripts;
mv -f ${BCK}/ntopng-cert.pem ${CERT};
mv -f ${BCK}/ntopng ${NTOPDB};
if ls ${BCK} | grep -q '.*.dat'; then
    mv -f *.dat ${GEOIP};
fi

# Set permissions for recovered ntopng dir
chown -R ntopng:ntopng /var/nst;

# Restart service
/etc/init.d/ntopng restart;

# Delete tmp backup dir
rm -rf ${BCK};

# EOF

