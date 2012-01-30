#!/bin/bash
# -----------------------------------------------------------------------------
# year-cal
#
# a silly program to print the output of `cal` in a different row/col 
# formats than the default 3 monthw wide by 4 months tall
# 
# 
# -----------------------------------------------------------------------------
# Author/Info
#
# T. Charles Yun
# License
#   released GPL version 2 for those silly enough to want this
#   that said, I do not have a copy of the license handy...
# 
# -----------------------------------------------------------------------------
# todo:
# - i have had more than one day in which the output highlighting broke.  just 
#   tried to check the code today (hard coding the dates on which errors 
#   occured) and things work fine.  not sure what was wrong prev.  odd...
#   - the 2011 may update should fix this prob.  remember to remove it...
#
# -----------------------------------------------------------------------------
# Updates
#
# 2011 may 15
# - i write some temp files for the months.  i clean them up now
#
# 2011 may 13
# - updated the code to (hopefully) be a bit more smart.  
#   - write each month individ to file
#   - pad the end of each month with spaces and then crop using colrm
#     which should get rid of the every once in a while odd output
#   - use the "lam" function to assemble the months into columns
#   - query the specific month to highlight a day
# - the month is now also highlighted
#
# 2009 Mar 25
# - added conditional so that date is only highlighted for current year
# 
# 2008 Oct 05
# - fixed prob with Sunday highlighting
# - fixed prob with first column highlighting
# - variable checks are now working (i hope)
#
# 2008 Jun
# - created first pass
#
# 
# -----------------------------------------------------------------------------
# usage

mcUsage() {
	echo "yc  (year calendar)"
	echo "" 
	echo "Description: "
	echo "    a script that modifies the output of calto print a year's calendar"
	echo "    with arbitrary numbers of columns and rows."
	echo "Usage:"
	echo "    year-cal [year [number of cols]]"
	echo ""
	echo "    If no year is provided, the current year is calculated via the date"
	echo "    command.  If a year is provided, the number of columns can be"
	echo "    provided."
	echo "Example:"
	echo "    yc 2008 4"
	echo "    would return the 2008 calendar, with four months in columns"
	echo "    and three months of rows.  Briefly as below:"
	echo "    "
	echo "              2008"
	echo "        jan feb mar apr"
	echo "        may jun jul aug"
	echo "        sep oct nov dec"
	echo "    "
	echo "    yc 2008 7"
	echo "    would return the 2008 calendar with 7 columns.  The columns do"
	echo "    not have to line up evenly at the end."
	echo "        jan feb mar apr may jun jul"
	echo "        aug sep oct nov dec"
	
	
	exit

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# all of the functions


# set up variables
	mainPath="/Users/tcyun/tcy-script/year-calendar/"

	pass1=$1
	pass2=$2
	
	width=4

	currYear=`date +%Y `
	currMonth=`date +%m `
	currDate=`date +%d `
	currHour=`date +%H `
	currMins=`date +%M `
	currSecs=`date +%S `
	
	month=1
	limit=13
	dumpLine=""
	
	#ornament left and right
	# this first set uses color
	#oL="\033[1;36m*"
	oL="\033[31m>\033[34m"
	oR="\033[31m<\033[0m"
	# the below uses just plain text
	#oL="*"
	#oR="*"
	
	#month ornament left and right
	# because the month does not have the asterisk
	mL="\033[1;36m"
	mR="\033[0m"
	# or you can set this to nothing
	#mL=""
	#mR=""
	
checkParams () {
	if [[ -n "$pass1" ]] 
	then
		if [[ "$pass1" -gt 0 ]] 
		then
			# if year is passed, use passed year
			currYear=$pass1
		else
			mcUsage
		fi
		
		# and then check to see if width was passed
		if [[ -n $pass2 ]] && [[ $pass2 -gt 0 ]]
		then
			width=$pass2
		else
			# default width is 4
			width=4
		fi
	else
		# if year is not passed as parameter, then use curr year
		currYear=`date +%Y`
	fi	
}

buildMonthFiles () {
	while [ "$month" -lt "$limit" ]
	do
		# so the purpose of the seds....
		# first, add a space to the beginning of the line so that a highlight 
		# marker can be inserted.
		# second, add a full month of spaces to the end of the line so that 
		# non-full weeks get space padded out for the full width
		# last, column remove all the extra spaces so that the month has the 
		# proper number of spaces to be laminated next to one another.
		
		cal $month $currYear | sed 's/^/\ /' | sed 's/$/                          /' | colrm 23 > "$mainPath"month$month
		
		month=`expr $month + 1`   
		
	done

	month=1	
}

renderCalendar () {
	while [ "$month" -lt 12 ]
	do
		count=0
		while [ "$count" -lt "$width" ]
		do
			if [ "$month" -lt 13 ]
			then
				dumpLine="$dumpLine "$mainPath"month$month"
			fi
			# echo -n "$count  "
			month=`expr $month + 1 `
			count=`expr $count + 1 `
		done
		
		#echo $dumpLine
		`echo "lam $dumpLine"`
		dumpLine=""
	done
	
	
}

highlightDate () {
	
	if [[ $currYear -eq `date +%Y ` ]] 
	then
		month=`expr $currMonth + 0  `
	
		# prepare date string 
		# first, add zero to turn leading zero number into non leading zero
		# then, take string length so that if it is single digit, you add a 
		# leading space
		# then add leading and trailing spaces so that you can get the prper
		# match at the end
		
		date=`expr $currDate + 0  `
		if [[ ${#date} -eq 1 ]]
		then 
			date=" $date"
		fi
		
		# copy the specific month to a temp file
		# manipulate the file by line
		# write the output of the manipulation to the orig file name
		
		mv    "$mainPath"month$month "$mainPath"monthTemp$month
		touch "$mainPath"month$month
	
		# now, take the selected month
		# pull apart by line
		# grep check each line
		# sed the line
		
		line=8
		
		while [ $line -gt 0 ]
		do 
			week=`tail -"$line" "$mainPath"monthTemp$month | head -1 `
			if [[ $line -eq 8 ]]
			then
				echo -e "$week" | sed -E "s/^/`echo -e "$mL"`/" | sed -E "s/$/`echo -e "$mR"`/" >>"$mainPath"month$month			
			elif [[ `echo "$week" | grep "$date"` ]]
			then
				echo -e "$week" | sed -E "s/ $date /`echo -e "$oL$date$oR"`/" >>"$mainPath"month$month
			else
				echo "$week" >>"$mainPath"month$month
			fi
			line=$(( $line - 1 ))
		done	
		
		month=1
	fi
	
}

doNothing () {
	# this is odd
	echo 
}

cleanUp () {
	cd $mainPath
	
	for a in {1..12}
	do
		rm month$a
		rm monthTemp$a &> /dev/null
	done
	
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ok, run everything form here

checkParams
buildMonthFiles
highlightDate
renderCalendar
cleanUp

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# and we are done

exit
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
