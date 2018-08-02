#!/bin/bash

#global variables
currentDir=$(cd "$(dirname "$0")";pwd)
totalOriginalSize=0
totalCurrentSize=0
totalReduceSize=0
totalReduceRate=0

#write the thining result to file
#param:result
#eg:writeThiningReport "1MB 500Kb /imgs/assets"
writeThiningReport(){
	if [[ -e ~/desktop/ThiningRepot.txt ]]; then
		echo $* >> ~/desktop/ThiningRepot.txt
	else
		echo "OriginalSize | CurrentSize | ReduceSize | ReduceRate | ResourcePath" > ~/desktop/ThiningRepot.txt
		writeThiningReport $*
	fi

  	# open ~/desktop/ThiningRepot.txt
  	column -t -s '|' ~/desktop/ThiningRepot.txt
}

#detect img type if it is a png
#param:filepath
#eg:isPngImage "/test/file.png"
isPngImage(){
	pngtype="PNG image data"
	type=$(file -b $1 | cut -d, -f1)

	if [[ $type = $pngtype ]]; then
		return 1
	else
		return 0
	fi
}

#thin the given img
#param:imagepath
#eg:thinPngImage "/imgs/eg.png"
thinPngImage(){
	isPngImage $*
	isPng=$?

	if [[ $isPng = 1 ]]; then
		originalSize=$(wc -c <"$*")
		echo "start thining：$* original size：$originalSize"
		crunch $1
		echo "complete thining，start replacing.."
		nosuffix=${1%.*}
		crunchname="$nosuffix-crunch.png"
		mv $crunchname $*
		currentSize=$(wc -c <"$*")
		echo "done：$* current size：$currentSize"

		#calculate
		totalOriginalSize=$(expr $totalOriginalSize + $originalSize)
		totalCurrentSize=$(expr $totalCurrentSize + $currentSize)

		echo $totalOriginalSize $totalCurrentSize
	else
		echo "$* isn't a png file."
	fi
}

#start thining all the png imgs under current directory
startThining(){
	for i in $(ls)
	do 
		if [[ -d "$i" ]]; then
			cd "$i"
			startThining
			cd ..
		else
			thinPngImage $i
		fi
	done
}

#start thining & log report
start(){
	startThining

	echo "=======================calculating======================="

	totalOriginalSize=$(echo "scale=2;$totalOriginalSize / 1204"|bc)
	totalCurrentSize=$(echo "scale=2;$totalCurrentSize / 1024"|bc)
	totalReduceSize=$(echo "scale=2;$totalOriginalSize - $totalCurrentSize"|bc)
	totalReduceRate=$(echo "scale=2;$totalReduceSize / $totalOriginalSize * 100"|bc)

	writeThiningReport "${totalOriginalSize}KB | ${totalCurrentSize}KB | ${totalReduceSize}KB | ${totalReduceRate}% | $*"
}

start