#!/bin/bash
#
#********************************************************************
#Author:                SongLiangCheng
#QQ:                    1062670898
#Date:                  2021-09-01
#FileName：             a.sh
#URL:                   http://www.magedu.com
#Description：          test toy.
#Copyright (C):        2021 All rights reserved
#********************************************************************


temp=$(mktemp .XXXX)
> $temp

clean_script() {
	rm -f $temp
	exit
}

trap 'clean_script' EXIT



red() {
	echo -e "\033[1;31m$1\033[0m"
}
green() {
	echo -e "\033[1;32m$1\033[0m"
}
blue() {
	echo -e "\033[1;36m$1\033[0m"
}


# if both file. vimdiff
if  [ -f "$1" -a -f "$2" ]; then
	vimdiff $1 $2
fi 


# if both dir, ....
if [ ! -d "$1" -o ! -d "$2" ]; then
	echo script.sh dir1 dir2
	echo script.sh file1 file2
	exit
fi	
dir1=$1
dir2=$2
for i in $(ls $dir1); do
	origin=$dir1/$i 
	dest=$dir2/$i

	[ -s "$temp" ] && blue "$(cat $temp | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' )"
	echo
	green "Processing $i"
	ok=false
	until $ok; do
	red "need Proccessing? [yes/no] "; read yes_confirm
	case $yes_confirm in
		yes)
			ok=true
			;;
		"")
			ok=true
			;;
		no)
			ok=false
			continue 2
			;;
		*)
			ok=false
			;;
		esac
	done

	if [ -f ${dest} ]; then 
		if ! diff -q ${origin} ${dest} > /dev/null; then
			green "vimdiff ${origin} ${dest}"  | tee -a $temp
			vimdiff ${origin} ${dest}
		else
			green "${origin} ${dest} same!"    | tee -a $temp
		fi
	else
		red "$i not exists $dir2" | $temp
		ok=false
		until $ok; do
			red "whether copy ${origin} to ${dest} [yes/no] "; read confirm
			if [ "$confirm" == "yes" -o -z "$confirm" ]; then
				green "copy  ${origin}  ${dest} " | tee -a $temp
				cp ${origin}  ${dest} 
				ok=true
			elif [ "$confirm" == "no" ]; then
				red "don't copy  ${origin}  ${dest} "  | tee -a $temp
				ok=true
			else	       
				red "read error"
				sleep 1
			fi
		done
	fi
	echo
done

blue "$(cat $temp | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' )"
