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
CONF="/etc/ntopng/ntopng.conf";
SSL="/usr/share/ntopng/httpdocs/ssl";
SETTINGS="/var/ipfire/ethernet/settings";

extract_files
restore_backup ${NAME}

# Formatting and Colors
COLUMNS="$(tput cols)";
R=$(tput setaf 1);
Y=$(tput setaf 3);
B=$(tput setaf 6);
N=$(tput sgr0);
seperator(){ printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -; };

clear;

# Delete old symlink if presant
rm -rfv /etc/rc.d/rc?.d/???${NAME};

## Add symlinks
# Possible runlevel ranges
echo;
echo "${Y}Will set symlinks to activate the initscript for start|stop|reboot${N}";
seperator;
SO="[2-5][0-9]";
SA="[4-7][0-9]";
RE="[2-5][0-9]";
# Search free runlevel
STOP=$(ls /etc/rc.d/rc0.d/ | sed -e 's/[^0-9]//g' | awk '$1!=p+1{print p+1" "$1-1}{p=$1}' | sed -e '1d' | tr ' ' '\n' | grep -E "${SO}" | head -1);
START=$(ls /etc/rc.d/rc3.d/ | sed -e 's/[^0-9]//g' | awk '$1!=p+1{print p+1" "$1-1}{p=$1}' | sed -e '1d' | tr ' ' '\n' | grep -E "${SA}" | head -1);
REBOOT=$(ls /etc/rc.d/rc6.d/ | sed -e 's/[^0-9]//g' | awk '$1!=p+1{print p+1" "$1-1}{p=$1}' | sed -e '1d' | tr ' ' '\n' | grep -E "${RE}" | head -1);
## Add symlinks 
ln -s ../init.d/${NAME} /etc/rc.d/rc0.d/K${STOP}${NAME};
ln -s ../init.d/${NAME} /etc/rc.d/rc3.d/S${START}${NAME};
ln -s ../init.d/${NAME} /etc/rc.d/rc6.d/K${REBOOT}${NAME};

# Disable mprotect for ntopng otherwise it won´t start
echo;
echo "${Y}Disable mprotect for ntopng${N}";
seperator;
paxctl -c /usr/bin/ntopng 2>/dev/null;
paxctl -pemrxs /usr/bin/ntopng 2>/dev/null;

# Investigate existing subnets
echo;
echo "${Y}Add subnets to ntopng configuration file${N}";
seperator;
ADDRESSES=$(netstat -r | awk '/red/||/green/||/blue/||/orange/ { if ($1 ~ /^[0-9]/) print $1"/"$3}' | tr '\n' ',' | head -c-1);
# Investigate existing interfaces
INTERFACE=$(for i in $(ifconfig | awk '/green/ || /blue/ || /orange/ || /ppp/ || /red/ || /tun/ { print $1 }'); do
	echo "--interface ${i}";
done)
# Paste investigated networks into ntopng.conf if no entries exist
if ! grep -q "# Local Networks:" ${CONF}; then
	cat >> ${CONF} <<EOF

#
# Local Networks:
# ===== =========
# ***Note: To add more than one local network comma separate:
# --local-networks 172.16.1.0/24,172.31.1.0/24
$(echo "--local-networks ${ADDRESSES}")
EOF

else
	echo "There are already entries for your '--local-networks'. Please check it by your own under ${CONF}... ";
fi
# Paste investigated subnets into ntopng.conf if no entries exist
echo
echo "${Y}Add interfaces to ntopng configuration file${N}";
seperator;
if ! grep -q "# Network Interface(s):" ${CONF}; then
	cat >> ${CONF} <<EOF

#
# Network Interface(s):
# ======= =============
# ***Note: To add more than one interface use multiple entries:
#--interface p3p1
#--interface p3p2
${INTERFACE}
EOF

else
	echo "There are already entries for your '--interface'. Please check it by your own under ${CONF}... ";
fi

## Thanks gocart ;-)
# create https cert
echo;
echo "${Y}Create certificate for HTTPS support... ${N}";
seperator;
/usr/bin/openssl genrsa -out rsa.key 4096;
/bin/cat /etc/certparams | sed "s/HOSTNAME/`hostname -f`/" | /usr/bin/openssl req -new -key rsa.key -out rsa.csr 2>/dev/null;
/usr/bin/openssl x509 -req -days 1825 -sha256 -in rsa.csr -signkey rsa.key -out rsa.crt 2>/dev/null;
cat rsa.key rsa.crt > ${SSL}/ntopng-cert.pem
rm -f rsa.key rsa.crt rsa.csr;
# Investigate and add green interface to webinterface access
echo;
echo "${Y}Set HTTPS access from green interface only to ntopng WI... ${N}";
seperator;
HTTPSPORT=$(awk -F'=' '/GREEN_ADDRESS/ { print"--https-port " $2":"3001 }' ${SETTINGS});
sed -i "s/--http-port.*/${HTTPSPORT}/" ${CONF};

echo;
echo "${Y}Will start now ntopng... ${N}";
seperator;
/etc/init.d/ntopng start

if pidof -x "ntopng" >/dev/null; then
    echo;
    seperator;
    echo "You can reach ntopngs web interface over ${B}'$(awk -F'=' '/GREEN_ADDRESS/ { print"https://"$2":"3001 }' ${SETTINGS})'${N}";
    seperator;
    echo;
else
    echo "${R}Process can´t be started please come to https://forum.ipfire.org/viewtopic.php?f=50&t=19565 , try then to help you.${N}";
fi

# EOF
