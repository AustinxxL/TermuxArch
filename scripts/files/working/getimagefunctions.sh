#!/bin/env bash
# Copyright 2017-2018 by SDRausty. All rights reserved.  🌎 🌍 🌏 🌐 🗺
# Hosting https://sdrausty.github.io/TermuxArch courtesy https://pages.github.com
# https://sdrausty.github.io/TermuxArch/CONTRIBUTORS Thank you for your help.  
# https://sdrausty.github.io/TermuxArch/README has information about this project. 
################################################################################

fstnd=""
ftchit() {
	getmsg
	_PRINTDOWNLOADINGFTCHIT_ 
	if [[ "$dm" = aria2c ]];then
		aria2c http://"$CMIRROR$path$file".md5 
		aria2c -c http://"$CMIRROR$path$file"
	elif [[ "$dm" = axel ]];then
		axel http://"$CMIRROR$path$file".md5 
		axel http://"$CMIRROR$path$file"
	elif [[ "$dm" = wget ]];then 
		wget "$dmverbose" -N --show-progress http://"$CMIRROR$path$file".md5 
		wget "$dmverbose" -c --show-progress http://"$CMIRROR$path$file" 
	else
		curl "$dmverbose" -C - --fail --retry 4 -OL http://"$CMIRROR$path$file".md5 -O http://"$CMIRROR$path$file" 
	fi
}

ftchstnd() {
	fstnd=1
	getmsg
	_PRINTCONTACTING_ 
	if [[ "$dm" = aria2c ]];then
		aria2c "$CMIRROR" | tee /dev/fd/1 > "$TAMPDIR/global2localCMIRROR"
		nCMIRROR="$(grep Redir "$TAMPDIR/global2localCMIRROR" | awk {'print $8'})" 
		_PRINTDONE_ 
		_PRINTDOWNLOADINGFTCH_ 
		aria2c http://"$CMIRROR$path$file".md5 
		aria2c -c -m 4 http://"$CMIRROR$path$file"
	elif [[ "$dm" = wget ]];then 
		wget -v -O/dev/null "$CMIRROR" 2>"$TAMPDIR/global2localCMIRROR"
		nCMIRROR="$(grep Location "$TAMPDIR/global2localCMIRROR" | awk {'print $2'})" 
		_PRINTDONE_ 
		_PRINTDOWNLOADINGFTCH_ 
		wget "$dmverbose" -N --show-progress "$nCMIRROR$path$file".md5 
		wget "$dmverbose" -c --show-progress "$nCMIRROR$path$file" 
	else
		curl -v "$CMIRROR" 2>"$TAMPDIR/global2localCMIRROR"
		nCMIRROR="$(grep Location "$TAMPDIR/global2localCMIRROR" | awk {'print $3'})" 
		_PRINTDONE_ 
		_PRINTDOWNLOADINGFTCH_ 
		curl "$dmverbose" -C - --fail --retry 4 -OL "$nCMIRROR$path$file".md5 -O "$nCMIRROR$path$file"
	fi
}

getimage() {
	_PRINTDOWNLOADINGX86_ 
	getmsg
	if [[ "$dm" = aria2c ]];then
		aria2c http://"$CMIRROR$path$file".md5 
		if [[ "$CPUABI" = "$CPUABIX86" ]];then
			file="$(grep i686 md5sums.txt | awk {'print $2'})"
		else
			file="$(grep boot md5sums.txt | awk {'print $2'})"
		fi
		sed '2q;d' md5sums.txt > "$file".md5
		rm md5sums.txt
		aria2c -c http://"$CMIRROR$path$file"
	elif [[ "$dm" = axel ]];then
		axel http://"$CMIRROR$path$file".md5 
		if [[ "$CPUABI" = "$CPUABIX86" ]];then
			file="$(grep i686 md5sums.txt | awk {'print $2'})"
		else
			file="$(grep boot md5sums.txt | awk {'print $2'})"
		fi
		sed '2q;d' md5sums.txt > "$file".md5
		rm md5sums.txt
		axel http://"$CMIRROR$path$file"
	elif [[ "$dm" = wget ]];then 
		wget "$dmverbose" -N --show-progress http://"$CMIRROR${path}"md5sums.txt
		if [[ "$CPUABI" = "$CPUABIX86" ]];then
			file="$(grep i686 md5sums.txt | awk {'print $2'})"
		else
			file="$(grep boot md5sums.txt | awk {'print $2'})"
		fi
		sed '2q;d' md5sums.txt > "$file".md5
		rm md5sums.txt
		_PRINTDOWNLOADINGX86TWO_ 
		wget "$dmverbose" -c --show-progress http://"$CMIRROR$path$file" 
	else
		curl "$dmverbose" --fail --retry 4 -OL http://"$CMIRROR${path}"md5sums.txt
		if [[ "$CPUABI" = "$CPUABIX86" ]];then
			file="$(grep i686 md5sums.txt | awk {'print $2'})"
		else
			file="$(grep boot md5sums.txt | awk {'print $2'})"
		fi
		sed '2q;d' md5sums.txt > "$file".md5
		rm md5sums.txt
		_PRINTDOWNLOADINGX86TWO_ 
		curl "$dmverbose" -C - --fail --retry 4 -OL http://"$CMIRROR$path$file" 
	fi
}

getmsg() {
 	if [[ "$dm" = axel ]] || [[ "$dm" = lftp ]];then
 		printf "\\n\\e[1;32m%s\\n\\n""The chosen download manager \`$dm\` is being implemented: curl (command line tool and library for transferring data with URLs) alternative https://github.com/curl/curl chosen:  DONE"
	fi
}

## EOF
