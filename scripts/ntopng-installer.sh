#!/bin/bash

#
# Description: In- and Uninstaller for ntopng on IPFire platforms for 32 and 64 bit systems.
# Installer includes also installation of redis and json-c
#
# $Author ummeegge ipfire org ; $date: 05.10.2017 13:47:23
############################################################################################
#

INSTALLDIR="/opt/pakfire/tmp";

# Download address
URL="https://people.ipfire.org/~ummeegge/ntopng/";
# Packages
#32bit
PACKAGEA="ntopng-32bit_dev_v3.tar.gz";
PACKAGESUMA="ced96e26a78ece34fd480ac92d3a1af7ce764a598dac3fb6fa3f0c2b22b7f838";
# 64bit
PACKAGEB="ntopng-64bit_dev_v3.tar.gz";
PACKAGESUMB="763deed77126f1e278134e5c552932f74d0ead8d94882c25ac520d3f522a7fbd";

# Platform check
TYPE=$(uname -m | tail -c 3);
TAR="tar xvf";


# Packages
ZE="zeromq-4.2.2-1.ipfire";
JS="json-c-json-c-0.12.1-20160607-1.ipfire";
RE="redis-4.0.2-1.ipfire";
NT="ntopng-3.1.171122-2.ipfire";
PACKAGES="${JS} ${ZE} ${RE} ${NT}";

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
	if [[ "${TYPE}" = "86" ]]; then
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
	elif [[ ${TYPE} = "64" ]]; then
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
	cd /tmp
	cp ntopng-*.tar.gz ${INSTALLDIR};
	cd ${INSTALLDIR};
	tar xvfz ntopng-*.tar.gz;
	${TAR} ${ZE};
	./install.sh;
	${TAR} ${JS};
	./install.sh;
	${TAR} ${RE};
	./install.sh;
	${TAR} ${NT};
	./install.sh;
	clean_up;
}

# Update function
update_function() {
	cd /tmp
	cp ntopng-*.tar.gz ${INSTALLDIR};
	cd ${INSTALLDIR};
	tar xvfz ntopng-*.tar.gz;
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
				rm -rfv /etc/rc.d/rc?.d/???ntopng \
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
			echo "             To uninstall ntopng press  'u' and [ENTER]";
			echo;
			read -p " To start the installer again press [ENTER] , to quit use [CTRL-c]";
			echo;
		;;

	esac

done

## EOF
