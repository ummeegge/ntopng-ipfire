#!/bin/bash -

#
# Cronjob script to update GeoIP for ntopng periodically
#
# $author: ummeegge ipfire org ; $date: 30.09.2017
########################################################
#

# Locations
WORKDIR="/tmp/geoip";
GEOIPDIR="/usr/share/ntopng/httpdocs/geoip";
URLS="
https://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz \
https://geolite.maxmind.com/download/geoip/database/GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz \
https://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz \
https://download.maxmind.com/download/geoip/database/asnum/GeoIPASNumv6.dat.gz
";
# Create temporary work dir and switch to it
/bin/mkdir -p ${WORKDIR} && cd ${WORKDIR};
# Download GeoIP with download log. If download fails write it to messages
if ! /usr/bin/wget --no-check-certificate ${URLS} -o /tmp/geoip_update_dwn.log; then
    /usr/bin/logger -t ntopng "Error: Downloading GeoIP database has been failed";
    exit 1;
    /bin/rm -rf ${WORKDIR};
fi
# CleanUP GeoIP dir
/bin/rm -rf ${GEOIPDIR}/*.dat
# Unpack GeoIP dats
/bin/gunzip -f ./*.dat.gz
# Move GeoIP dats to ntopng
/bin/mv ./*.dat ${GEOIPDIR}/ 2>/dev/null;
# Restart ntopng
/etc/init.d/ntopng restart;
# Write to messages
/usr/bin/logger -t ntopng "GeoIP database has been updated";
# CleanUP
/bin/rm -rf ${WORKDIR} 2>/dev/null;

# EOF
