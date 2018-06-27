#!/bin/bash

#
# Description: In- uninstaller and updater for ntopng on IPFire platforms for 32 and 64 bit systems.
# Installer includes also installation of redis, json-c, Geoip-api-c, mysql perl modules and zeroMQ.
#
# $author ummeegge ipfire org ; $date: 23.06.2017 07:33:34
####################################################################################################
#

# Install directory
INSTALLDIR="/opt/pakfire/tmp";
DEV="3.4.230618_v8";

# Download address
URL="https://people.ipfire.org/~ummeegge/ntopng/";
# Packages
# 64bit
PACKAGEA="ntopng-64bit_${DEV}.tar.gz";
PACKAGESUMA="ea538787f9a987fc6ea4a9476f14ad55d1d5870b2833e74c440d2ba8ad892eca";
# 32bit
PACKAGEB="ntopng-32bit_${DEV}.tar.gz";
PACKAGESUMB="af1754818b45a208b69c26acb6866935c7a4b10218f14f03f6aec0df98adbdcc";

# Platform check
TAR="tar xvf";
TYPE=$(uname -m | tail -c 3);
ACTVERSION=$(curl -s ${URL} --list-only | awk -F'_' '/ntopng-/ { print $2 }' | head -1);
INSTALLEDVER=$(ntopng -V | head -1 | awk '{ print $1 }' | sed 's/v.//');

# Packages
GE="geoip-api-c-1.6.12-1.ipfire";
JS="json-c-0.13.1-1.ipfire";
NT="ntopng-3.4.230618-5.ipfire";
RE="redis-4.0.8-1.ipfire";
ZE="zeromq-4.2.3-1.ipfire";
MY="mysql-5.6.40-1.ipfire";

# Formatting Colors and text
COLUMNS="$(tput cols)";
R=$(tput setaf 1);
B=$(tput setaf 6);
b=$(tput bold);
N=$(tput sgr0);
seperator(){ printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -; }
WELCOME="Welcome to Ntopng on IPFire installation";
WELCOMEA="This script includes an in- and unstaller for Ntopng";
INSTALL="               If you want to install Ntopng press              ${B}${b}'i'${N} and [ENTER]";
UPDATE="               If you want to update ntopng press               ${B}${b}'u'${N} and [ENTER]"
UNINSTALL="               If you want to uninstall Ntopng press            ${B}${b}'r'${N} and [ENTER]";
QUIT="               If you want to quit this installation press      ${B}${b}'q'${N} and [ENTER]";


# Clean up function
clean_up() {
	cd ${INSTALLDIR};
	rm -rvf files.tar.xz *.sh *.ipfire ROOTFILES ntopng-*.tar.gz >/dev/null;
	cd /tmp;
}

download_function() {
	cd /tmp || exit 1;
	# Check for 32-bit system
	if [[ "${TYPE}" = "64" ]]; then
		# Check if package is already presant otherwise download it
		if [[ ! -e "${PACKAGEA}" ]]; then
			echo;
			curl -O ${URL}/${PACKAGEA};
			# Check SHA256 sum
			CHECK=$(sha256sum ${PACKAGEA} | awk '{print $1}');
			if [[ "${CHECK}" = "${PACKAGESUMA}" ]]; then
				echo;
				echo "${B}SHA256 sum is correct, will go to further processing :-) ...${N}";
				echo;
				sleep 3;
			else
				echo;
				echo -e "${R}SHA2 sum should be ${R}${PACKAGESUMA}${N}";
				echo -e "${R}SHA2 sum is        ${R}${CHECK}${N} and is not correct... ${N}";
				echo;
				echo -e "${R}Shit happens :-( the SHA256 sum is incorrect, please report this here https://forum.ipfire.org/viewtopic.php?f=50&t=19565${N}";
				echo;
				exit 1;
			fi
		fi
	elif [[ ${TYPE} = "86" ]]; then
		# Check if package is already presant otherwise download it
		if [[ ! -e "${PACKAGEB}" ]]; then
			echo;
			curl -O ${URL}/${PACKAGEB};
			# Check SHA256 sum
			CHECK=$(sha256sum ${PACKAGEB} | awk '{print $1}');
			if [[ "${CHECK}" = "${PACKAGESUMB}" ]]; then
				echo;
				echo "${B}SHA256 sum is correct, will go to further processing :-) ...${N}";
				echo;
				sleep 3;
			else
				echo;
				echo -e "${R}SHA2 sum should be ${R}${PACKAGESUMB}${N}";
				echo -e "${R}SHA2 sum is        ${R}${CHECK}${N} and is not correct… ";
				echo;
				echo -e "${R}Shit happens :-( the SHA256 sum is incorrect, please report this here https://forum.ipfire.org/viewtopic.php?f=50&t=19565${N}";
				echo;
				echo;
				echo "${R}Sorry this platform is currently not supported... Need to quit... ${N}";
				echo;
				exit 1;
			fi
		fi
	else
		echo;
		echo "${R}Sorry this platform is currently not supported... Need to quit... ${N}";
		echo;
		exit 1;
	fi
}


# Installation function of basic components
install_function() {
	cd /tmp || exit 1;
	cp ntopng-*_${DEV}.tar.gz ${INSTALLDIR};
	cd ${INSTALLDIR};
	tar xvfz ntopng-*_${DEV}.tar.gz;
	${TAR} ${ZE};
	./install.sh;
	${TAR} ${GE};
	./install.sh;
	${TAR} ${JS};
	./install.sh;
	${TAR} ${RE};
	./install.sh;
	${TAR} ${MY};
	./install.sh;
	${TAR} ${NT};
	./install.sh;
	clean_up;
}

# Update check
update_check() {
	if [ -e "/usr/bin/ntopng" ]; then
		if [ "${ACTVERSION}" != "${INSTALLEDVER}" ]; then
			echo -e "${B}There is an Update available${N}";
		else
			echo "${R}No update available${N}";
		fi
	fi
}

# Update function
update_function() {
	cd /tmp || exit 1;
	cp ntopng-*_${DEV}.tar.gz ${INSTALLDIR};
	cd ${INSTALLDIR};
	tar xvfz ntopng-*_${DEV}.tar.gz;
	${TAR} ${ZE};
	./update.sh;
	${TAR} ${GE};
	./update.sh;
	${TAR} ${JS};
	./update.sh;
	${TAR} ${RE};
	./update.sh;
	${TAR} ${MY};
	./install.sh;
	${TAR} ${NT};
	./update.sh;
	clean_up;
}

## Installer Menu
while true
do
	# Choose installation
	echo ${N};
	clear;
	seperator;
	printf "%*s\n" $(((${#WELCOME}+COLUMNS)/2)) "${WELCOME}";
	printf "%*s\n" $(((${#WELCOMEA}+COLUMNS)/2)) "${WELCOMEA}";
	seperator;
	echo;
	printf "%*s\n" $(((${#INSTALL}+COLUMNS)/2)) "${INSTALL}";
	printf "%*s\n" $(((${#UPDATE}+COLUMNS)/2)) "${UPDATE}";
	printf "%*s\n" $(((${#UNINSTALL}+COLUMNS)/2)) "${UNINSTALL}";
	echo;
	seperator;
	printf "%*s\n" $(((${#QUIT}+COLUMNS)/2)) "${QUIT}";
	seperator;
	update_check;
	seperator;
	echo;
	read choice
	clear;

	# Install ntopng
	case "$choice" in
		i*|I*)
			clear;
			if ls /usr/bin/ | grep -q ntopng; then
				echo;
				echo "Ntopng is already installed on your system, please uninstall it first if needed. ";
				echo
				exit 1;
			else
				read -p "To install Ntopng now press [ENTER] , to quit use [CTRL-c]... ";
				download_function;
				## Installation part
				install_function;
				# Rename geoip updater to prevent deleting of posssible existing ones
				mv /etc/ntopng/scripts/geoip_updater.sh /etc/ntopng/scripts/geoip_ntopngDEV_updater.sh;
				echo;
				while true; do
					clear;
					echo -e "Since ntopng provides also GeoIP support for ASNs and GeoIP information you can \n
					${B}1)${N} Only download and integrate GeoIP for ntopng\n
					${B}2)${N} Download and integrate GeoIP data, will make a weekly cronjob for updates \n
					${B}3)${N} Download and integrate GeoIP data, will make a monthly cronjob for updates \n
					${B}4)${N} No GeoIP integration, will leave as it is";
					seperator;
					printf "%b" "\n
					For Installation only press '${B}1${N}'-[ENTER] \n
					For Download and weekly update press '${B}2${N}'-[ENTER] \n
					For Download and monthly update press '${B}3${N}'-[ENTER] \n
					For No GeoIP support press ${R}'4'${N}\n";
					seperator;
					printf "%b" "\n";
					read what;
					echo;
					case "$what" in
						1*)
							# Execute GeoIP downloader
							echo "Will download and integrate GeoIP data... ";
							sleep 2;
							/etc/ntopng/scripts/geoip_ntopngDEV_updater.sh;
							break;
						;;

						2*)
							# Execute GeoIP downloader
							echo "Will download and integrate GeoIP data now and do a weekly update (this can take a little time now, please be patient)... ";
							sleep 2;
							/etc/ntopng/scripts/geoip_ntopngDEV_updater.sh;
							cp -v /etc/ntopng/scripts/geoip_ntopngDEV_updater.sh /etc/fcron.weekly/;
							break;
						;;

						3*)
							# Execute GeoIP downloader
							echo "Will download and integrate GeoIP data now and do a monthly update (this can take a little time now, please be patient)... ";
							sleep 2;
							/etc/ntopng/scripts/geoip_ntopngDEV_updater.sh;
							cp -v /etc/ntopng/scripts/geoip_ntopngDEV_updater.sh /etc/fcron.monthly/;
							break;
						;;

						4*)
							# Execute GeoIP downloader
							echo "Will leave it without GeoIP support... ";
							sleep 2;
							break;
						;;

						*)
							echo;
							echo "This option does not exist";
							sleep 2;
							shift;
						;;
					esac
				done
			fi
			sleep 5;
			clear;
			echo "${B}Installation is finish now.${N}";
			if pidof -x "ntopng" >/dev/null; then
				echo -e "You can reach ntopng under '${B}$(awk '/--https-port/ { print "https://"$2 }' /etc/ntopng/ntopng.conf)${N}'. Happy testing. Goodbye. ";
				echo;
				exit 0;
			else
				echo;
				echo "${R}Something went wrong ntopng has NOT been started, please report this here --> https://forum.ipfire.org/viewtopic.php?f=50&t=19565 will then try to help you.${N}";
				echo;
				exit 1;
			fi
		;;

		r*|R*)
			clear;
			read -p "To uninstall ntopng now press [ENTER], to quit use [CTRL-c]... ";
			if ls /etc/rc.d/init.d | grep -q "ntopng"; then
				/etc/init.d/redis stop;
				/etc/init.d/ntopng stop;
				rm -rvf \
				/usr/lib/libjson-c.so* \
				/usr/bin/curve_keygen \
				/usr/lib/libzmq.so* \
				/etc/logrotate.d/redis \
				/etc/rc.d/init.d/redis \
				/etc/redis \
				/usr/bin/redis-* \
				/var/redis \
				/var/lib/redis \
				/var/log/redis \
				/opt/pakfire/db/installed/meta-redis \
				/etc/ntopng \
				/etc/rc.d/init.d/ntopng \
				/usr/bin/ntopng \
				/usr/share/ntopng \
				/var/nst \
				/var/tmp/ntopng \
				/opt/pakfire/db/installed/meta-ntopng \
				/usr/bin/geoiplookup \
				/usr/bin/geoiplookup6 \
				/usr/lib/libGeoIP.so* \
				/usr/lib/libmysqlclient.so.18*;
				rm -rfv /etc/rc.d/rc?.d/???ntopng;
				rm -rfv /etc/rc.d/rc?.d/???redis;
				userdel ntopng;
				find /etc/fcron.* -type f -name "geoip_ntopngDEV_updater.sh" -exec rm -vf {} \;
				echo ;
				echo "Uninstallation has been done. Thanks for testing. Goodbye.";
				exit 0;
			else
				echo;
				echo "${R}Can not find the ntopng installation, can not uninstall ntopng... ${R}";
				sleep 2;
				echo;
			fi
		;;

		u*|U*)
			if [ -e "/usr/bin/ntopng" ]; then
				if [ "${ACTVERSION}" != "${INSTALLEDVER}" ]; then
					if ! ls /usr/bin/ | grep -q ntopng; then
						echo;
						echo "Ntopng is not installed on this system, please install it first... ";
						sleep 5;
						echo;
					else
						clear;
						read -p "To update ntopng now press [ENTER], to quit use [CTRL-c]... ";
						download_function;
						update_function;
						echo "${B}Update is finish now.${N}";
						if pidof -x "ntopng" >/dev/null; then
							echo -e "You can reach ntopng under '${B}$(awk '/--https-port/ { print "https://"$2 }' /etc/ntopng/ntopng.conf)${N}'. Happy testing. Goodbye. ";
							echo;
							exit 0;
						else
							echo;
							echo "${R}Something went wrong ntopng has NOT been started, please report this here --> https://forum.ipfire.org/viewtopic.php?f=50&t=19565 will then try to help you.${N}";
							echo;
							sleep 3;
						fi
					fi
				else
					echo;
					echo "There is currently no update available... ";
					sleep 3;
				fi
			else
				echo
				echo "No Ntopng installation detected. Please install it first";
				echo;
				sleep 3;
			fi
		;;

		q*|Q*)
			exit 0
		;;

		*)
			echo;
			echo "   Ooops, there went something wrong 8-\ - for explanation again   ";
			echo "-------------------------------------------------------------------";
			echo "             To install ntopng press    'i' and [ENTER]";
			echo "             To uninstall ntopng press  'r' and [ENTER]";
			echo "             To uninstall ntopng press  'u' and [ENTER]";
			echo;
			read -p " To start the installer again press [ENTER] , to quit use [CTRL-c]";
			echo;
		;;

	esac

done

## EOF
