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

CONF="/etc/redis";
BCK="/tmp/redis_bck";
DB="/var/redis/6379";

. /opt/pakfire/lib/functions.sh

# Create tmp backup dir
mkdir -p ${BCK};
# Save redis config
cp -rv ${CONF}/redis.conf ${BCK};
cp -rv ${DB}/dump.rdb ${BCK};

./uninstall.sh
./install.sh

# Recover redis configuration
mv ${BCK}/redis.conf ${CONF};
mv ${BCK}/dump.rdb ${DB};
# Delete temporary backup dir
rm -rf ${BCK};

# Restart service
/etc/init.d/redis restart

# EOF
