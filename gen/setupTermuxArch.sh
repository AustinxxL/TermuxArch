#!/bin/env bash
# Copyright 2017-2018 by SDRausty. All rights reserved.  🌎 🌍 🌏 🌐 🗺
# Hosted https://sdrausty.github.io/TermuxArch courtesy https://pages.github.com
# https://sdrausty.github.io/TermuxArch/CONTRIBUTORS Thank you for your help.  
# https://sdrausty.github.io/TermuxArch/README for TermuxArch information. 
################################################################################
IFS=$'\n\t'
set -Eeuo pipefail
shopt -s nullglob globstar
unset LD_PRELOAD
versionid="gen.v1.6 id825626334855"

## Init Functions ###################################################################################################################################

aria2cif() { 
	dm=aria2c
	if [[ -x "$(command -v aria2c)" ]] && [[ -x "$PREFIX"/bin/aria2c ]] ; then
		:
	else
		aptin+="aria2 "
		apton+="proot "
	fi
}

aria2cifdm() {
	if [[ "$dm" = aria2c ]] ; then
		aria2cif 
	fi
}

arg2dir() {  # Argument as rootdir.
	arg2="${@:2:1}"
	if [[ -z "${arg2:-}" ]] ; then
		rootdir=/arch
		preptermuxarch
	else
		rootdir=/"$arg2" 
		preptermuxarch
	fi
}

axelif() { 
	dm=axel
	if [[ -x "$(command -v axel)" ]] && [[ -x "$PREFIX"/bin/axel ]] ; then
		:
	else
		aptin+="axel "
		apton+="proot "
	fi
}

axelifdm() {
	if [[ "$dm" = axel ]] ; then
		axelif 
	fi
}

bsdtarif() {
	tm=bsdtar
	if [[ -x "$(command -v bsdtar)" ]] && [[ -x "$PREFIX"/bin/bsdtar ]] ; then
		:
	else
		aptin+="bsdtar "
		apton+="proot "
	fi
}

chk() {
	if "$PREFIX"/bin/applets/sha512sum -c termuxarchchecksum.sha512 1>/dev/null ; then
 		chkself "$@"
		printf "\\e[0;34m%s \\e[1;34m%s \\e[1;32m%s\\e[0m\\n" " 🕛 > 🕜" "TermuxArch $versionid integrity:" "OK"
		loadconf
		. archlinuxconfig.sh
		. espritfunctions.sh
		. getimagefunctions.sh
		. maintenanceroutines.sh
		. necessaryfunctions.sh
		. printoutstatements.sh
		if [[ "$opt" = bloom ]] ; then
			rm -f termuxarchchecksum.sha512 
		fi
		if [[ "$opt" = manual ]] ; then
			manual
		fi
	else
		printsha512syschker
	fi
}

chkdwn() {
	if "$PREFIX"/bin/applets/sha512sum -c setupTermuxArch.sha512 1>/dev/null ; then
		printf "\\e[0;34m 🕛 > 🕐 \\e[1;34mTermuxArch download: \\e[1;32mOK\\n\\n"
		if [[ "$tm" = tar ]] ; then
	 		proot --link2symlink -0 "$PREFIX"/bin/tar xf setupTermuxArch.tar.gz 
		else
	 		proot --link2symlink -0 "$PREFIX"/bin/applets/tar xf setupTermuxArch.tar.gz 
		fi
	else
		printsha512syschker
	fi
}

chkself() {
	if [[ -f "setupTermuxArch.tmp" ]] ; then
		if [[ "$(<setupTermuxArch.sh)" != "$(<setupTermuxArch.tmp)" ]] ; then
			cp setupTermuxArch.sh "${wdir}setupTermuxArch.sh"
			printf "\\e[0;32m%s\\e[1;34m: \\e[1;32mUPDATED\\n\\e[1;32mRESTART %s %s \\n\\e[0m"  "${0##*/}" "${0##*/}" "$@"
			.  "${wdir}setupTermuxArch.sh" "$@"
		fi
	fi
}

curlif() {
	dm=curl
	if [[ -x "$(command -v curl)" ]] && [[ -x "$PREFIX"/bin/curl ]] ; then
		:
	else
		aptin+="curl "
		apton+="proot "
	fi
}

curlifdm() {
	if [[ "$dm" = curl ]] ; then
		curlif 
	fi
}

dependbp() {
	if [[ "$cpuabi" = "$cpuabix86" ]] || [[ "$cpuabi" = "$cpuabix86_64" ]] ; then
		bsdtarif 
		prootif 
	else
		prootif 
	fi
}

depends() { # Checks for missing commands.  
	printf "\\e[1;34mChecking prerequisites…\\n\\e[1;32m"
# 	# Checks if download manager is set. 
	aria2cifdm 
	axelifdm 
	lftpifdm 
	curlifdm 
	wgetifdm 
# 	# Checks if download manager is present. 
# 	# IMPORTANT NOTE: CURRENTLY ONLY curl AND wget ARE THOROUGHLY TESTED.   All the download managers are NOT yet fully implemented.    
	if [[ "$dm" = "" ]] ; then
		if [[ -x "$(command -v curl)" ]] || [[ -x "$PREFIX"/bin/curl ]] ; then
			curlif 
		elif [[ -x "$(command -v wget)" ]] && [[ -x "$PREFIX"/bin/wget ]] ; then
			wgetif 
		elif  [[ -x "$(command -v aria2c)" ]] || [[ -x "$PREFIX"/bin/aria2c ]]; then
			aria2cif 
	 	elif [[ -x "$(command -v lftpget)" ]] || [[ -x "$PREFIX"/bin/lftpget ]] ; then
			lftpif 
	 	elif [[ -x "$(command -v axel)" ]] || [[ -x "$PREFIX"/bin/axel ]] ; then
			axelif 
		fi
	fi
#	# Sets and installs wget if nothing else was found, installed and set. 
	if [[ "$dm" = "" ]] ; then
		wgetif 
	fi
	dependbp 
#	# Installs missing commands.  
	tapin "$aptin"
#	# Checks whether install missing commands was successful.  
# 	pe "$aptin"
	echo
	echo "Using ${dm:-curl} to manage downloads." 
	printf "\\n\\e[0;34m 🕛 > 🕧 \\e[1;34mPrerequisites: \\e[1;32mOK  \\e[1;34mDownloading TermuxArch…\\n\\n\\e[0;32m"
}

dependsblock() {
	depends 
	if [[ -f archlinuxconfig.sh ]] && [[ -f espritfunctions.sh ]] && [[ -f getimagefunctions.sh ]] && [[ -f knownconfigurations.sh ]] && [[ -f maintenanceroutines.sh ]] && [[ -f necessaryfunctions.sh ]] && [[ -f printoutstatements.sh ]] && [[ -f setupTermuxArch.sh ]] ; then
		. archlinuxconfig.sh
		. espritfunctions.sh
		. getimagefunctions.sh
		. knownconfigurations.sh
		. maintenanceroutines.sh
		. necessaryfunctions.sh
		. printoutstatements.sh
		if [[ "$opt" = manual ]] ; then
			manual
		fi 
	else
		cd "$tampdir" 
		dwnl
		if [[ -f "${wdir}setupTermuxArch.sh" ]] ; then
			cp "${wdir}setupTermuxArch.sh" setupTermuxArch.tmp
		fi
		chkdwn
		chk "$@"
	fi
}

dwnl() {
	if [[ "$dm" = aria2c ]] ; then
		aria2c https://raw.githubusercontent.com/sdrausty/TermuxArch/master"$dfl"/setupTermuxArch.sha512 
		aria2c https://raw.githubusercontent.com/sdrausty/TermuxArch/master"$dfl"/setupTermuxArch.tar.gz 
	elif [[ "$dm" = axel ]] ; then
		axel https://raw.githubusercontent.com/sdrausty/TermuxArch/master"$dfl"/setupTermuxArch.sha512 
		axel https://raw.githubusercontent.com/sdrausty/TermuxArch/master"$dfl"/setupTermuxArch.tar.gz 
	elif [[ "$dm" = lftp ]] ; then
		lftpget -v https://raw.githubusercontent.com/sdrausty/TermuxArch/master"$dfl"/setupTermuxArch.sha512 
		lftpget -v https://raw.githubusercontent.com/sdrausty/TermuxArch/master"$dfl"/setupTermuxArch.tar.gz 
	elif [[ "$dm" = wget ]] ; then
		wget "$dmverbose" -N --show-progress https://raw.githubusercontent.com/sdrausty/TermuxArch/master"$dfl"/setupTermuxArch.sha512 
		wget "$dmverbose" -N --show-progress https://raw.githubusercontent.com/sdrausty/TermuxArch/master"$dfl"/setupTermuxArch.tar.gz 
	else
		curl "$dmverbose" -OL https://raw.githubusercontent.com/sdrausty/TermuxArch/master"$dfl"/setupTermuxArch.sha512 -OL https://raw.githubusercontent.com/sdrausty/TermuxArch/master"$dfl"/setupTermuxArch.tar.gz
	fi
	printf "\\n\\e[1;33m"
}

finishe() { # Run on exit.
#	echo "Exit Code $?"
	rm -rf "$tampdir"
	printf "\\e[?25h\\e[0m"
	set +Eeuo pipefail 
  	printtail "$args"  
}

finisher() { # Run on script signal.
	printf "\\e[?25h\\e[1;7;38;5;0mTermuxArch warning:  Script signal $? generated!\\e[0m\\n"
	rm -rf "$tampdir"
 	exit 
}

finishs() { # Run on signal.
	printf "\\e[?25h\\e[1;7;38;5;0mTermuxArch warning:  Signal $? received!\\e[0m\\n"
	rm -rf "$tampdir"
 	exit 
}

finishq() { # Run on quit.
	printf "\\e[?25h\\e[1;7;38;5;0mTermuxArch warning:  Quit signal $? received!\\e[0m\\n"
	rm -rf "$tampdir"
 	exit 
}

intro() {
	printf '\033]2;  bash setupTermuxArch.sh $@ 📲 \007'
	rootdirexception 
	printf "\\n\\e[0;34m 🕛 > 🕛 \\e[1;34mTermuxArch $versionid will attempt to install Linux in \\e[0;32m$installdir\\e[1;34m.  Arch Linux in Termux PRoot will be available upon successful completion.  To run this BASH script again, use \`!!\`.  Ensure background data is not restricted.  Check the wireless connection if you do not see one o'clock 🕐 below.  "
	dependsblock "$@" 
	if [[ "$lcc" = "1" ]] ; then
		loadimage "$@" 
	else
		mainblock
	fi
}

introbloom() { # Bloom = `setupTermuxArch.sh manual verbose` 
	opt=bloom 
	printf '\033]2;  bash setupTermuxArch.sh bloom 📲 \007'
	printf "\\n\\e[0;34m 🕛 > 🕛 \\e[1;34mTermuxArch $versionid bloom option.  Run \\e[1;32mbash setupTermuxArch.sh help \\e[1;34mfor additional information.  Ensure background data is not restricted.  Check the wireless connection if you do not see one o'clock 🕐 below.  "
	dependsblock "$@" 
	bloom 
}

introsysinfo() {
	printf '\033]2;  bash setupTermuxArch.sh sysinfo 📲 \007'
	printf "\\n\\e[0;34m 🕛 > 🕛 \\e[1;34msetupTermuxArch $versionid will create a system information file.  Ensure background data is not restricted.  Run \\e[0;32mbash setupTermuxArch.sh help \\e[1;34mfor additional information.  Check the wireless connection if you do not see one o'clock 🕐 below.  "
	preptermuxarch
	dependsblock "$@" 
	sysinfo 
}

introrefresh() {
	printf '\033]2;  bash setupTermuxArch.sh refresh 📲 \007'
	rootdirexception 
	printf "\\n\\e[0;34m 🕛 > 🕛 \\e[1;34msetupTermuxArch $versionid will refresh your TermuxArch files in \\e[0;32m$installdir\\e[1;34m.  Ensure background data is not restricted.  Run \\e[0;32mbash setupTermuxArch.sh help \\e[1;34mfor additional information.  Check the wireless connection if you do not see one o'clock 🕐 below.  "
	dependsblock "$@" 
	refreshsys "$@"
}

introstnd() {
	printf '\033]2; %s\007' " bash setupTermuxArch.sh $args 📲 "
	rootdirexception 
	printf "\\n\\e[0;34m%s \\e[1;34m%s \\e[0;32m%s\\e[1;34m%s \\e[0;32m%s \\e[1;34m%s" " 🕛 > 🕛" "setupTermuxArch $versionid will $introstndidstmt your TermuxArch files in" "$installdir" ".  Ensure background data is not restricted.  Run " "bash setupTermuxArch.sh help" "for additional information.  Check the wireless connection if you do not see one o'clock 🕐 below.  "
}

introstndidstmt() { # depends $introstndid
	printf "the TermuxArch files in \\e[0;32m%s\\e[1;34m.  " "$installdir"
}

lftpif() {
	dm=lftp
	if [[ -x "$(command -v lftp)" ]] && [[ -x "$PREFIX"/bin/lftp ]] ; then
		:
	else
		aptin+="lftp "
		apton+="proot "
	fi
}

lftpifdm() {
	if [[ "$dm" = lftp ]] ; then
		lftpif 
	fi
}

loadconf() {
	if [[ -f "${wdir}setupTermuxArchConfigs.sh" ]] ; then
		. "${wdir}setupTermuxArchConfigs.sh"
		printconfloaded 
	else
		. knownconfigurations.sh 
	fi
}

manual() {
	printf '\033]2; `bash setupTermuxArch.sh manual` 📲 \007'
	editors
	if [[ -f "${wdir}setupTermuxArchConfigs.sh" ]] ; then
		"$ed" "${wdir}setupTermuxArchConfigs.sh"
		. "${wdir}setupTermuxArchConfigs.sh"
		printconfloaded 
	else
		cp knownconfigurations.sh "${wdir}setupTermuxArchConfigs.sh"
 		sed -i "7s/.*/\# The architecture of this device is $cpuabi; Adjust configurations in the appropriate section.  Change mirror (https:\/\/wiki.archlinux.org\/index.php\/Mirrors and https:\/\/archlinuxarm.org\/about\/mirrors) to desired geographic location to resolve 404 and checksum issues.  /" "${wdir}setupTermuxArchConfigs.sh" 
		"$ed" "${wdir}setupTermuxArchConfigs.sh"
		. "${wdir}setupTermuxArchConfigs.sh"
		printconfloaded 
	fi
}

nameinstalldir() {
	if [[ "$rootdir" = "" ]] ; then
		rootdir=arch
	fi
	installdir="$(echo "$HOME/${rootdir%/}" |sed 's#//*#/#g')"
}

namestartarch() { # ${@%/} removes trailing slash
 	darch="$(echo "${rootdir%/}" |sed 's#//*#/#g')"
	if [[ "$darch" = "/arch" ]] ; then
		aarch=""
		startbi2=arch
	else
 		aarch="$(echo "$darch" |sed 's/\//\+/g')"
		startbi2=arch
	fi
	declare -g startbin=start"$startbi2$aarch"
}

opt2() { 
	if [[ -z "${2:-}" ]] ; then
		arg2dir "$@" 
	elif [[ "$2" = [Bb]* ]] ; then
		echo Setting mode to bloom. 
		introbloom "$@"  
	elif [[ "$2" = [Dd]* ]] || [[ "$2" = [Ss]* ]] ; then
		echo Setting mode to sysinfo.
		introsysinfo "$@"  
	elif [[ "$2" = [Ii]* ]] ; then
		echo Setting mode to install.
		arg2dir shift 1 "$@" 
	elif [[ "$2" = [Mm]* ]] ; then
		echo Setting mode to manual.
		opt=manual
 		opt3 "$@"  
		intro "$@"  
	elif [[ "$2" = [Rr]* ]] ; then
		echo Setting mode to refresh.
		arg2dir shift 1 "$@" 
		introrefresh "$@"  
	else
		arg2dir "$@" 
	fi
}

opt3() { 
	if [[ -z "${3:-}" ]] ; then
		arg2dir shift 1 "$@" 
	elif [[ "$3" = [Ii]* ]] ; then
		echo Setting mode to install.
		arg2dir shift 2 "$@" 
	elif [[ "$3" = [Rr]* ]] ; then
		echo Setting mode to refresh.
		arg2dir shift 2 "$@" 
		introrefresh "$@"  
	else
		arg2dir shift 1 "$@" 
	fi
}

pe() {
	printf "\\n\\e[1;31mPrerequisites exception.  Run the script again…\\n\\n\\e[0m"
	printf '\033]2; Run `bash setupTermuxArch.sh %s` again…\007' "$args" 
	exit
}

pec() {
	if [[ "$apton" != "" ]] ; then
		pe @apton
	fi
}

preptmpdir() { 
	mkdir -p "$installdir/tmp"
	chmod 777 "$installdir/tmp"
	chmod +t "$installdir/tmp"
 	tampdir="$installdir/tmp/setupTermuxArch$stime"
	mkdir -p "$tampdir" 
}

preptermuxarch() { 
	nameinstalldir 
	namestartarch  
	preptmpdir
}

printconfloaded() {
	printf "\\n\\e[0;34m%s \\e[1;34m%s \\e[0;32m%s\\e[1;32m%s \\e[1;34m%s \\e[1;32m%s\\n" " 🕛 > 🕑" "TermuxArch configuration" "${wdir}" "setupTermuxArchConfigs.sh" "loaded:" "OK"
}

printsha512syschker() {
	printf "\\n\\e[07;1m\\e[31;1m\\n%s \\e[34;1m\\e[30;1m%s \\n\\e[0;0m\\n" " 🔆 WARNING sha512sum mismatch!  Setup initialization mismatch!" "  Try again, initialization was not successful this time.  Wait a little while.  Then run \`bash setupTermuxArch.sh\` again…"
	printf '\033]2; Run `bash setupTermuxArch.sh %s` again…\007' "$args" 
	exit 
}

printtail() {   
 	printf "\\a\\a\\a\\a"
	sleep 0.4
 	printf "\\a\\n\\e[0;32m%s %s \\a\\e[0m$versionid\\e[1;34m: \\a\\e[1;32m%s\\e[0m\\n\\n\\a\\e[0m" "${0##*/}" "$args" "DONE 🏁 "
	printf '\033]2; %s: DONE 🏁 \007' "${0##*/} $args"
}

printusage() {
	printf "\\n\\n\\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\n\\n%s \\e[0;32m%s\\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s\\e[1;34m%s\\n" "Usage information for" "setupTermuxArch.sh" "$versionid.  Arguments can abbreviated to one, two and three letters each; Two letter arguments are acceptable.  For example," "bash setupTermuxArch.sh cs" "will use" "curl" "to download TermuxArch and produce a" "setupTermuxArchSysInfo$stime.log" "system information file." "User configurable variables are in" "setupTermuxArchConfigs.sh" ".  To create this file from" "kownconfigurations.sh" "in the working directory, run" "bash setupTermuxArch.sh manual" "to create and edit" "setupTermuxArchConfigs.sh" "." 
	printf "\\n\\e[1;33m%s\\e[1;34m     %s \\e[0;32m%s \\e[1;34m%s\\n" "HELP" "Use" "setupTermuxArch.sh help" "to output this help screen." 
	printf "\\n\\e[1;33m%s\\e[1;34m  %s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s\\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s \\e[1;34m%s\\n" "INSTALL" "Run" "./setupTermuxArch.sh" "without arguments in a bash shell to install Arch Linux in Termux.  Use" "bash setupTermuxArch.sh curl" "to envoke" "curl" "as the download manager.  Copy" "knownconfigurations.sh" "to" "setupTermuxArchConfigs.sh" "with" "bash setupTermuxArch.sh manual" "to edit preferred mirror site and to access more options.  After editing" "setupTermuxArchConfigs.sh" ", run" "bash setupTermuxArch.sh" "and" "setupTermuxArchConfigs.sh" "loads automatically from the working directory.  Change mirror to desired geographic location to resolve download errors." 
# 	printf "\\n\\e[1;33m%s\\e[1;34m     %s \\e[0;32m%s \\e[1;34m%s\\n" "PURGE" "Use" "setupTermuxArch.sh purge" "to uninstall Arch Linux from Termux." 
	printf "\\n\\e[1;33m%s\\e[1;34m    %s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s \\e[1;34m%s \\e[0;32m%s\\e[1;34m%s \\n" "SYSINFO" "Use" "setupTermuxArch.sh sysinfo" "to create" "setupTermuxArchSysInfo$stime.log" "and populate it with system information.  Post it along with detailed information at" "https://github.com/sdrausty/TermuxArch/issues" ".  If screenshots will help in resolving an issue better, include these along with information from the system information log file in a post as well." 
 	namestartarch 
	if [[ -x "$(command -v "$startbin")" ]] ; then
		"$startbin" help 2>/dev/null
	fi
}

prootif() {
	if [[ -x "$(command -v proot)" ]] &&  [[ -x "$PREFIX"/bin/proot ]] ; then
		:
	else
		aptin+="proot "
		apton+="proot "
	fi
}

rmarch() {
	namestartarch 
	nameinstalldir
	while true; do
		printf "\\n\\e[1;30m"
		read -n 1 -p "Uninstall $installdir? [Y|n] " ruanswer
		if [[ "$ruanswer" = [Ee]* ]] || [[ "$ruanswer" = [Nn]* ]] || [[ "$ruanswer" = [Qq]* ]] ; then
			break
		elif [[ "$ruanswer" = [Yy]* ]] || [[ "$ruanswer" = "" ]] ; then
			printf "\\e[30mUninstalling $installdir…\\n"
			if [[ -e "$PREFIX/bin/$startbin" ]] ; then
				rm -f "$PREFIX/bin/$startbin" 
			else 
				printf "Uninstalling $PREFIX/bin/$startbin: nothing to do for $PREFIX/bin/$startbin.\\n"
			fi
			if [[ -e "$HOME/bin/$startbin" ]] ; then
				rm -f "$HOME/bin/$startbin" 
			else 
				printf "Uninstalling $HOME/bin/$startbin: nothing to do for $HOME/bin/$startbin.\\n"
			fi
			if [[ -d "$installdir" ]] ; then
				rmarchrm 
			else 
				printf "Uninstalling $installdir: nothing to do for $installdir.\\n"
			fi
			printf "Uninstalling $installdir: \\e[1;32mDone\\n\\e[30m"
			break
		else
			printf "\\nYou answered \\e[33;1m$ruanswer\\e[30m.\\n\\nAnswer \\e[32mYes\\e[30m or \\e[1;31mNo\\e[30m. [\\e[32my\\e[30m|\\e[1;31mn\\e[30m]\\n"
		fi
	done
	printf "\\e[0m\\n"
}

rmarchrm() {
	rootdirexception 
	rm -rf "${installdir:?}"/* 2>/dev/null ||:
	find  "$installdir" -type d -exec chmod 700 {} \; 2>/dev/null ||:
	rm -rf "$installdir" 2>/dev/null ||:
}

rmarchq() {
	if [[ -d "$installdir" ]] ; then
		printf "\\n\\e[0;33m%s \\e[1;33m%s \\e[0;33m%s\\n\\n\\e[1;30m%s\\n" "TermuxArch:" "DIRECTORY WARNING!  $installdir/" "directory detected." "Purge $installdir as requested?"
		rmarch
	fi
}

tapin() {
	if [[ "$aptin" != "" ]] ; then
		printf "\\n\\e[1;34mInstalling \\e[0;32m%s\\b\\e[1;34m…\\n\\n\\e[1;32m" "$aptin"
#		apt update && apt -o APT::Keep-Downloaded-Packages="true" upgrade -y
#		apt -o APT::Keep-Downloaded-Packages="true" install "$aptin" -y
		pkg install "$aptin" -o APT::Keep-Downloaded-Packages="true" --yes 
		printf "\\n\\e[1;34mInstalling \\e[0;32m%s\\b\\e[1;34m: \\e[1;32mDONE\\n\\e[0m" "$aptin"
	fi
}

rootdirexception() {
	if [[ "$installdir" = "$HOME" ]] || [[ "$installdir" = "$HOME"/ ]] || [[ "$installdir" = "$HOME"/.. ]] || [[ "$installdir" = "$HOME"/../ ]] || [[ "$installdir" = "$HOME"/../.. ]] || [[ "$installdir" = "$HOME"/../../ ]] ; then
		printf  '\033]2;%s\007' "Rootdir exception.  Run bash setupTermuxArch.sh $args again with different options…"	
		printf "\\n\\e[1;31m%s\\n\\n\\e[0m" "Rootdir exception.  Run the script $args again with different options…"
		exit
	fi
}

setrootdir() {
	if [[ "$cpuabi" = "$cpuabix86" ]] ; then
	#	rootdir=/root.i686
		rootdir=/arch
	elif [[ "$cpuabi" = "$cpuabix86_64" ]] ; then
	#	rootdir=/root.x86_64
		rootdir=/arch
	else
		rootdir=/arch
	fi
}

standardid() {
	introstndid="$1" 
	introstndidstmt="$(printf "%s \\e[0;32m%s" "$1 the TermuxArch files in" "$installdir")" 
	introstnd
}

wgetif() {
	dm=wget 
	if [[ ! -x "$PREFIX"/bin/wget ]] ; then
		aptin+="wget "
		apton+="wget "
	fi
}

wgetifdm() {
	if [[ "$dm" = wget ]] ; then
		wgetif 
	fi
}

## User Information 
## Configurable variables such as mirrors and download manager options are in `setupTermuxArchConfigs.sh`.  Working with `kownconfigurations.sh` in the working directory is simple.  `bash setupTermuxArch.sh manual` will create `setupTermuxArchConfigs.sh` in the working directory for editing; See `setupTermuxArch.sh help` for more information.  
declare -a args="$@"
declare aptin="" ## apt string
declare apton="" ## exception string
declare commandif=""
declare cpuabi=""
declare cpuabi5="armeabi"
declare cpuabi7="armeabi-v7a"
declare cpuabi8="arm64-v8a"
declare cpuabix86="x86"
declare cpuabix86_64="x86_64"
declare dfl="/gen" # Used for development 
declare dm="wget"  ## download manager
declare dmverbose="-q" # -v for verbose download manager output from curl and wget;  for verbose output throughout runtime also change in `setupTermuxArchConfigs.sh` when using `setupTermuxArch.sh manual`. 
declare	ed=""
declare installdir=""
declare lcc=""
declare lcp=""
declare opt=""
declare rootdir=""
declare wdir="$PWD/"
declare sti=""   ## Generates pseudo random number.
declare stime="" ## Generates pseudo random number.
declare tm=""    ## tar manager
trap finishe EXIT
trap finisher ERR 
trap finishs INT TERM 
trap finishq QUIT 
if [[ -z "${tampdir:-}" ]] ; then
	tampdir=""
fi
setrootdir
commandif="$(command -v getprop)" ||:
if [[ "$commandif" = "" ]] ; then
	printf "\\n%s \\n\\n" "WARNING: Run \`bash setupTermuxArch.sh\` from the OS system in Termux, i.e. Amazon Fire, Android and Chromebook."
	exit
fi
## Gets information about device using getprop.
cpuabi="$(getprop ro.product.cpu.abi)" 
## Generates pseudo random number to create uniq strings.
if [[ -f  /proc/sys/kernel/random/uuid ]] ; then
	sti="$(cat /proc/sys/kernel/random/uuid)"
	stim="${sti//-}"	
	stime="${stim:0:3}"	
else
	sti="$(date +%s)" 
	stime="$(echo "${sti:7:4}"|rev)" 
fi
oned="$(date +%s)" 
onedi="${oned: -1}" 
stime="${onedi}${stime}"
## GRAMMAR: `setupTermuxArch.sh [HOW] [WHAT] [WHERE]`; all options are optional for network install.  AVAILABLE OPTIONS: `setupTermuxArch.sh [HOW] [WHAT] [WHERE]` and `setupTermuxArch.sh [./|/absolute/path/]systemimage.tar.gz [WHERE]`.  EXPLAINATION: [HOW (aria2c, axel, curl, lftp and wget (default 1: available on system (default 2: curl)))]  [WHAT (install, manual, purge, refresh and sysinfo (default: install))] [WHERE (default: arch)]  Defaults are implied.  USAGE EXAMPLES: `setupTermuxArch.sh wget sysinfo` will use wget as the download manager and produce a system information file in the working directory.  This can be abbreviated to `setupTermuxArch.sh ws` and `setupTermuxArch.sh w s`. `setupTermuxArch.sh wget manual install customname` will install the installation in customname with wget.  While `setupTermuxArch.sh wget refresh customname` will refresh this installation with wget.  IMPORTANT NOTE: CURRENTLY ONLY curl AND wget ARE THOROUGHLY TESTED.   All the download managers are NOT fully implemented yet.    
## []  Run default Arch Linux install; `bash setupTermuxArch.sh help` has more information.  
if [[ -z "${1:-}" ]] ; then
	preptermuxarch 
	intro "$@" 
## A systemimage.tar.gz file can be substituted for network install: `setupTermuxArch.sh ./[path/]systemimage.tar.gz` and `setupTermuxArch.sh /absolutepath/systemimage.tar.gz`; [./path/systemimage.tar.gz [installdir]]  Use path to system image file; install directory argument is optional. 
elif [[ "${args:0:1}" = . ]] ; then
 	echo
 	echo Setting mode to copy.
 	lcc="1"
 	lcp="1"
 	arg2dir "$@"  
 	intro "$@" 
## A systemimage.tar.gz file can substituted for network install:  [systemimage.tar.gz [installdir]]  Install directory argument is optional. 
# elif [[ "${wdir}${args}" = *.tar.gz* ]] ; then
elif [[ "${wdir}${args}" = *.tar.gz* ]] ; then
	echo
	echo Setting mode to copy.
	lcc="1"
	lcp="0"
	arg2dir "$@"  
	intro "$@" 
## [axd|axs]  Get device system information with `axel`.
elif [[ "${1//-}" = [Aa][Xx][Dd]* ]] || [[ "${1//-}" = [Aa][Xx][Ss]* ]] ; then
	echo
	echo Getting device system information with \`axel\`.
	dm=axel
	introsysinfo "$@" 
## [axel installdir|axi installdir]  Install Arch Linux with `axel`.
elif [[ "${1//-}" = [Aa][Xx]* ]] || [[ "${1//-}" = [Aa][Xx][Ii]* ]] ; then
	echo
	echo Setting \`axel\` as download manager.
	dm=axel
	opt2 "$@" 
	intro "$@" 
## [ad|as]  Get device system information with `aria2c`.
elif [[ "${1//-}" = [Aa][Dd]* ]] || [[ "${1//-}" = [Aa][Ss]* ]] ; then
	echo
	echo Getting device system information with \`aria2c\`.
	dm=aria2c
	introsysinfo "$@" 
## [aria2c installdir|ai installdir]  Install Arch Linux with `aria2c`.
elif [[ "${1//-}" = [Aa]* ]] ; then
	echo
	echo Setting \`aria2c\` as download manager.
	dm=aria2c
	opt2 "$@" 
	intro "$@" 
## [bloom]  Create and run a local copy of TermuxArch in TermuxArchBloom.  Useful for running a customized setupTermuxArch.sh locally, for developing and hacking TermuxArch.  
elif [[ "${1//-}" = [Bb]* ]] ; then
	echo
	echo Setting mode to bloom. 
	introbloom "$@"  
## [cd|cs]  Get device system information with `curl`.
elif [[ "${1//-}" = [Cc][Dd]* ]] || [[ "${1//-}" = [Cc][Ss]* ]] ; then
	echo
	echo Getting device system information with \`curl\`.
	dm=curl
	introsysinfo "$@" 
## [curl installdir|ci installdir]  Install Arch Linux with `curl`.
elif [[ "${1//-}" = [Cc][Ii]* ]] || [[ "${1//-}" = [Cc]* ]] ; then
	echo
	echo Setting \`curl\` as download manager.
	dm=curl
	opt2 "$@" 
	intro "$@" 
## [debug|sysinfo]  Generate system information.
elif [[ "${1//-}" = [Dd]* ]] || [[ "${1//-}" = [Ss]* ]] ; then
	echo 
	echo Setting mode to sysinfo.
	introsysinfo "$@" 
## [help|?]  Display builtin help.
elif [[ "${1//-}" = [Hh]* ]] || [[ "${1//-}" = [?]* ]] ; then
	printusage
## [install installdir|rootdir installdir]  Install Arch Linux in a custom directory.  Instructions: Install in userspace. $HOME is appended to installation directory. To install Arch Linux in $HOME/installdir use `bash setupTermuxArch.sh install installdir`. In bash shell use `./setupTermuxArch.sh install installdir`.  All options can be abbreviated to one or two letters.  Hence `./setupTermuxArch.sh install installdir` can be run as `./setupTermuxArch.sh i installdir` in BASH.
elif [[ "${1//-}" = [Ii]* ]] ||  [[ "${1//-}" = [Rr][Oo]* ]] ; then
	echo
	echo Setting mode to install.
	opt2 "$@" 
	intro "$@"  
## [ld|ls]  Get device system information with `lftp`.
elif [[ "${1//-}" = [Ll][Dd]* ]] || [[ "${1//-}" = [Ll][Ss]* ]] ; then
	echo
	echo Getting device system information with \`lftp\`.
	dm=lftp
	introsysinfo "$@" 
## [lftp installdir|li installdir]  Install Arch Linux with `lftp`.
elif [[ "${1//-}" = [Ll]* ]] ; then
	echo
	echo Setting \`lftp\` as download manager.
	dm=lftp
	opt2 "$@" 
	intro "$@" 
## [manual]  Manual Arch Linux install, useful for resolving download issues.
elif [[ "${1//-}" = [Mm]* ]] ; then
	echo
	echo Setting mode to manual.
	opt=manual
	opt2 "$@" 
	intro "$@"  
## [option]  Option
elif [[ "${1//-}" = [Oo]* ]] ; then
	printusage
	opt2 "$@" 
## [purge |uninstall]  Remove Arch Linux.
elif [[ "${1//-}" = [Pp]* ]] || [[ "${1//-}" = [Uu]* ]] ; then
	echo 
	echo Setting mode to purge.
	arg2dir "$@" 
	rmarchq
## [refresh|refresh installdir]  Refresh the Arch Linux in Termux PRoot scripts created by TermuxArch and the installation itself.  Useful for refreshing the installation and the TermuxArch generated scripts to their newest versions.  
elif [[ "${1//-}" = [Rr]* ]] ; then
	echo 
	echo Setting mode to refresh.
	arg2dir "$@" 
	introrefresh "$@"  
## [wd|ws]  Get device system information with `wget`.
elif [[ "${1//-}" = [Ww][Dd]* ]] || [[ "${1//-}" = [Ww][Ss]* ]] ; then
	echo
	echo Getting device system information with \`wget\`.
	dm=wget
	introsysinfo "$@" 
## [wget installdir|wi installdir]  Install Arch Linux with `wget`.
elif [[ "${1//-}" = [Ww]* ]] ; then
	echo
	echo Setting \`wget\` as download manager.
	dm=wget
	opt2 "$@" 
	intro "$@"  
else
	printusage
fi

## EOF
