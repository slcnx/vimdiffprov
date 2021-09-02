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




function process_list_files() {
	origin_dir=$1
	dest_dir=$2
	for sub_dir1 in $(ls $origin_dir); do
		if [ -e $dest_dir/$sub_dir1 ]; then
			# 目录1和目录2有相同的文件，就关联
			# echo dir1["${origin_dir}/$sub_dir1"]="${dest_dir}/$sub_dir1"
			dir1["${origin_dir}/$sub_dir1"]="${dest_dir}/$sub_dir1"
		else
			# 如果目录2没有文件，说明仅第1个有
			dir1_only_exists[${#dir1_only_exists[@]}]="${origin_dir}/$sub_dir1"
		fi
	done
	for sub_dir2 in $(ls $dest_dir); do
                # dir1 key 
		if echo "${dir1[@]}" | grep -q "\b$dest_dir/${sub_dir2}\b" ; then
			continue
		else
			# 如果目录2的文件不在目录中关联的文件中，就记录
			dir2_only_exists[${#dir2_only_exists[@]}]="${dest_dir}/$sub_dir2"
		fi	
	done
	#echo 源key: 源值 ${!dir1[@]} ===== ${dir1[@]}
	#echo ${!dir1_only_exists[@]} ===== ${dir1_only_exists[@]}
	#echo ${!dir2_only_exists[@]} ==== ${dir2_only_exists[@]}

}
function proccess_diff_both_file_1() {
	origin=$(echo "$*" | awk  '{print $2}')
	origin_dir=$(readlink -f $(dirname $origin))
	dest=$(echo "$*" | awk  '{print $3}')
	dest_dir=$(readlink -f $(dirname $dest))
	
	if [[ "$dest" =~ /#$ ]]; then
		local f=$(echo "$*" | awk '{print $2}')
	fi
	if [[ "$origin" =~ /#$ ]]; then
		local f=$(echo "$*" | awk '{print $3}')
	fi
	if [[ ! "$origin" =~ /#$ ]] && [[ ! "$dest" =~ /#$ ]]; then
		local f=$(echo "$*" | awk '{print $2}')
	fi
	if [ ! -f "$origin" -a ! -f "$dest" ]; then
		#errortext[$f]="<both_not_file>"
		true
	elif [ ! -f "$origin"  ]; then
		#errortext[$f]="<origin_not_file>"
		true
	elif [ ! -f "$dest" ]; then
		#errortext[$f]="<dest_not_file>"
		true
	fi
	if [[ "$dest" =~ /#$ ]] || [[ "$origin" =~ /#$ ]]; then
		errortext[$f]="${errortext[$f]}:<NotExists>"	
	fi
	if [[ ! "$origin" =~ /#$ ]] && [[ ! "$dest" =~ /#$ ]]; then
		
		if ! diff -q ${origin} ${dest} > /dev/null; then
			errortext[$f]="${errortext[$f]}:<CanChange>"	
		else
			true
		fi
	fi
}
function proccess_diff_both_file() {
	origin=$(echo "$*" | awk  '{print $2}')
	origin_dir=$(readlink -f $(dirname $origin))
	dest=$(echo "$*" | awk  '{print $3}')
	dest_dir=$(readlink -f $(dirname $dest))
	
	if [[ "$dest" =~ /#$ ]]; then
		local f=$(echo "$*" | awk '{print $2}')
	fi
	if [[ "$origin" =~ /#$ ]]; then
		local f=$(echo "$*" | awk '{print $3}')
	fi
	if [[ ! "$origin" =~ /#$ ]] && [[ ! "$dest" =~ /#$ ]]; then
		local f=$(echo "$*" | awk '{print $2}')
	fi
	edited[$f]="edited"
	
	if [[ "$dest" =~ /#$ ]]; then
		ok=false
		until $ok; do
			echo -n "whether copy $(blue origin) $origin to $(red dest) $dest_dir? [yes or enter/no]: "; read confirm
			case $confirm in
			yes)
				#errortext[$f]="${errortext[$f]}:<copy>"	
				cp -a $origin $dest_dir
				sleep 3
				ok=true
				;;
			"")
				#errortext[$f]="${errortext[$f]}:<copy>"	
				cp -a $origin $dest_dir
				sleep 3
				ok=true
				;;
			no)
				#errortext[$f]="${errortext[$f]}:<nocopy>"	
				ok=true
				continue
				;;
			*)
				ok=false
				;;
			esac
		done			
	fi
	if [[ "$origin" =~ /#$ ]]; then
		ok=false
		until $ok; do
			echo -n "whether copy $( red dest) $dest to $(blue origin) $origin_dir? [yes or enter/no]: "; read confirm
			case $confirm in
			yes)
				#errortext[$f]="${errortext[$f]}:<copy>"	
				cp -a $dest $origin_dir
				sleep 3
				ok=true
				;;
			"")
				#errortext[$f]="${errortext[$f]}:<copy>"	
				cp -a $dest $origin_dir
				sleep 3
				ok=true
				;;
			no)
				#errortext[$f]="${errortext[$f]}:<nocopy>"	
				ok=true
				continue 
				;;
			*)
				ok=false
				;;
			esac
		done			
	fi
	if [[ ! "$origin" =~ /#$ ]] && [[ ! "$dest" =~ /#$ ]]; then
		
		if ! diff -q ${origin} ${dest} > /dev/null; then
			vimdiff ${origin} ${dest} 
			green "${origin} ${dest} don't same, editing"
			#errortext[$f]="${errortext[$f]}:<diff>"	
		else
			ok=false
			until $ok; do
				#errortext[$f]="<same>"
				read -p "${origin} ${dest} is same, would you want to edit? [yes/no]:" yes_confirm
				case $yes_confirm in
					yes)
						#errortext[$f]="${errortext[$f]}:<diff>"	
						vimdiff ${origin} ${dest} 
						ok=true
						;;
					"")
						#errortext[$f]="${errortext[$f]}:<diff>"	
						vimdiff ${origin} ${dest} 
						ok=true
						;;
					no)
						#errortext[$f]="${errortext[$f]}:<nodiff>"	
						ok=true
						;;
					*)
						ok=false
						;;
					esac
			done
		fi
	fi
}
function process_edit_files_1() {
	unset text
	for i in ${!dir1[@]}; do
		local f=$(echo "$i" | awk '{print $1}')
		text[${#text[@]}]="$(printf "[ %20s %20s %12s] %s\n" $i ${dir1[$i]}             ${edited[$f]} ${errortext[$f]})"
	done
	for i in "${dir1_only_exists[@]}"; do
		local f=$(echo "$i" | awk '{print $1}')
		text[${#text[@]}]="$(printf "[ %20s %20s %12s] %s\n" $i $(basename $dest_dir)/# ${edited[$f]} ${errortext[$f]})"
	done
	for i in "${dir2_only_exists[@]}"; do
		local f=$(echo "$i" | awk '{print $1}')
		text[${#text[@]}]="$(printf "[ %20s %20s %12s] %s\n" $(basename $origin_dir)/# $i ${edited[$f]} ${errortext[$f]})"
	done
	for file in "${text[@]}"; do
		clear
		proccess_diff_both_file_1 $file 
	done
}
function process_edit_files() {
	unset text
	for i in ${!dir1[@]}; do
		local f=$(echo "$i" | awk '{print $1}')
		text[${#text[@]}]="$(printf "[ %20s %20s %12s] %s\n" $i ${dir1[$i]}             ${edited[$f]} ${errortext[$f]})"
	done
	for i in "${dir1_only_exists[@]}"; do
		local f=$(echo "$i" | awk '{print $1}')
		text[${#text[@]}]="$(printf "[ %20s %20s %12s] %s\n" $i $(basename $dest_dir)/# ${edited[$f]} ${errortext[$f]})"
	done
	for i in "${dir2_only_exists[@]}"; do
		local f=$(echo "$i" | awk '{print $1}')
		text[${#text[@]}]="$(printf "[ %20s %20s %12s] %s\n" $(basename $origin_dir)/# $i ${edited[$f]} ${errortext[$f]})"
	done
	select file in "${text[@]}"; do
		clear
		proccess_diff_both_file $file 
		break
	done
}

function usage() {
blue "
	vimdiff进入之后
	# 1. 切换窗口
	ctrl+w hjkl或w : 来切换窗口
	
	# 2. 切换到不同位置处
	] [ : 切换到下一个或前一个不同的位置.

	# 3. 颜色表示
	红色的字: 就是两边都会有部分相同的字符，差异的字符会显示.
	白色是缓存区: 你添加的文件，当前文件存在，另一个文件不存在.

	# 4. 应用修改
	dp(diff put) 将当前光标的差异，推到另一个窗口.
	do(diff obtain) 获取另一个窗口的差异。一般在不可选择的下一行执行.
	进行do之后，可以命令行模式 u 撤回
	进行dp之后，需要光标切换到对应窗口，再 u撤回

	# 5. 刷新修改
	:diffupdate 重新刷新diff
"
}

main() {
	declare -A dir1
	declare -A dir1_only_exists
	declare -A dir2_only_exists
	declare -A edited
	declare -A text
	declare -A errortext
	CURRENT_DIR=$(readlink -f $(pwd))
	ok=false

	until $ok; do
		read -p 'wheter improve ~/.vimrc' confirm
		case $confirm in
		yes)
			[ -f ~/.vimrc ] && cp ~/.vimrc ~/.vimrc-$(date +%F_%H%M)
			cp .vimrc ~/.vimrc
			ok=true
			;;
		"")
			[ -f ~/.vimrc ] && cp ~/.vimrc ~/.vimrc-$(date +%F_%H%M)
			cp .vimrc ~/.vimrc
			ok=true
			;;
		no)
			ok=false
			continue
			;;
		*)
			ok=false
			;;
		esac
	done

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


	is_ok=false
	until $is_ok; do
		process_list_files $1 $2
		usage
		green "选择你要修正的文件, 输入序号即可: \n\t 1. 如果不相同直接进入编辑模式 \n\t 2. 相同会询问"
		process_edit_files_1
	 	process_edit_files
		unset dir1
		unset dir1_only_exists
		unset dir2_only_exists
		unset edited
		unset text
		unset errortext
		declare -A dir1
		declare -A dir1_only_exists
		declare -A dir2_only_exists
		declare -A edited
		declare -A text
		declare -A errortext
	done
}

main $1 $2
