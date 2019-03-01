#!/bin/bash

# Script that tests a given contest problem from Kattis.
# This script supports C, C++, and Python 3.

# Global variables.
SOURCE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DIR="${SOURCE_PATH}/.tmp"
CONFIG="${DIR}/prob.conf"
ARGS=("$@")

# Argument iterator.
i="0"

# All possible flag variables.
# oflag, hflag, cmnd

# Flags to compile C/C++ programs with.
CFLAGS="-g -O2 -static -std=gnu++17 -Wall"

# Full credit to Dave Dopson from Stack Overflow for the command that is used to find the path of the GitHub repo.
# https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself

# Prints correct usage. Takes in an argument as the error message.
usage() {
	echo -e "\033[31mError\033[m: $1"
	echo -e "\033[33mUsage\033[m: ./uatest.sh [options] <command> [-p problem] [file-name]"
	exit 2
}

# Verify a command argument is given.
test $# -eq 0 && usage "No command given."

# Parse every argument.
while [ $i -lt $# ]
do
	case ${ARGS[$(( i++ ))]} in
		-h|--help|help) # Help option.
			hflag="1" ;;
		-o|--output) # Output option.
			oflag="1" ;;
		-p) # Problem id argument.
			test $i -lt $# && prob="${ARGS[$(( i++ ))]}" || usage "Missing problem id." ;;
		clean) # Clean command.
			test -z $cmnd && cmnd="clean" ;;
		test) # Test command.
			test -z $cmnd && cmnd="test" ;;
		submit) # Submit command.
			test -z $cmnd && cmnd="submit" ;;
		*) # General catch for file or invalid arguments.
			if [ -z $file ]
			then
				file="${ARGS[$i - 1]}"
				test -z $prob && prob="${file##*/}" && prob="${prob%.*}"
			else
				usage "Invalid argument, '${ARGS[$i - 1]}'."
			fi
			;;
	esac
done

# Get problem id and file from config if possible.
test -f $CONFIG && . $CONFIG
test -z $prob && prob="$CPROB"
test -z $file && file="$CFILE"

# Help option.
test $hflag && cat $SOURCE_PATH/src/help.txt && exit 0

# Make sure a command was actually given in the arguments.
test -z $cmnd && usage "No valid command given."

# Clean command.
test $cmnd = "clean" && rm -rf $DIR && exit 0

# Test command.
if [ $cmnd = "test" ]
then
	# Check if problem id or file has been given.
	test -z $prob$file && usage "Please specify a problem id and file."
	test -z $file && usage "Please specify a file."

	# If arguments differ from config data, download new test cases.
	if [ -z $CPROB ] || [ $prob != $CPROB ]
	then
		# Information for the user and download sample test cases.
		printf "Downloading test cases..."
		mkdir -p $DIR
		wget -q -O $DIR/samples.zip https://open.kattis.com/problems/$prob/file/statement/samples.zip > /dev/null

		# Catch when not downloadable.
		if [ $? -ne 0 ]; then
			echo "unable to download test cases."
			echo -e "Problem id: $prob\nFile: $file\n"
			rm -f $DIR/samples.zip
			exit 1
		else
			echo "downloaded!"
			rm -f $DIR/*.in $DIR/*.ans
			unzip -q $DIR/samples.zip -d $DIR
			rm -f $DIR/samples.zip
		fi
	fi

	# Catch non-supported languages.
	if [[ $file != *".c" ]] && [[ $file != *".cpp" ]] && [[ $file != *".py" ]]
	then
		echo "This script only supports C, C++, and Python 3."
		exit 2
	fi

	# Update config file and print problem id and file name for the user.
	echo -e "CPROB=$prob\nCFILE=$file" > $CONFIG
	echo -e "Problem id: $prob\nFile: $file\n"

	# Compile C or C++.
	if [[ $file == *".c" ]] || [[ $file == *".cpp" ]]
	then
		# Compile the program.
		g++ $file $CFLAGS -o $DIR/a.out
		
		# Exit on a compile error.
		if [ $? -ne 0 ]
		then
			echo -e "Failed tests: \033[31mCompile Error\033[m"
			exit 1
		fi
	fi

	# Run against test cases.
	for i in $DIR/*.in
	do
		# Run the program against the test case.
		if [[ $file == *".c" ]] || [[ $file == *".cpp" ]]
		then
			start=$(date +%s%3N)
			$DIR/a.out < $i > ${i%.*}.test
			comp=$?
			time=$(($(date +%s%3N)-start))
		elif [[ $file == *".py" ]]
		then
			start=$(date +%s%3N)
			python3 $file < $i > ${i%.*}.test
			comp=$?
			time=$(($(date +%s%3N)-start))
		else
			echo "This script only supports C, C++, and Python 3."
			exit 2
		fi

		# See what the result was.
		if diff ${i%.*}.test ${i%.*}.ans > /dev/null
		then
			echo -e "${i##*/}: \033[32mCorrect Answer\033[m...${time}ms"
		elif [ $comp -eq 0 ]
		then
			echo -e "${i##*/}: \033[31mWrong Answer\033[m...${time}ms"
		else
			echo -e "${i##*/}: \033[31mRuntime Error\033[m...${time}ms\n"
		fi

		# If the output flag was set, print the output.
		if [ $oflag ] && [ $comp -eq 0 ]
		then
			cat ${i%.*}.test && echo
		fi

		# Remove the produced output file.
		rm -f ${i%.*}.test
	done
	
	# Remove C/C++ binary and exit.
	rm -f $DIR/a.out
	exit 0
fi

# Submit command.
if [ $cmnd = "submit" ]
then
	# Check if problem id or file has been given.
	test -z $prob$file && usage "Please specify a problem id and file."
	test -z $file && usage "Please specify a file."

	# Tells the user what problem they are testing incase of issues.
	echo -e "Problem id: $prob\nFile: $file\n"

	# Submit the file to Kattis, clean, and exit.
	python3 $SOURCE_PATH/src/submit.py -p $prob $file -f
	rm -rf $DIR
	exit 0
fi
