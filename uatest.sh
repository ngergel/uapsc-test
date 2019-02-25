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

# Flags to compile C/C++ programs with.
CFLAGS="-g -O2 -static -std=gnu++17 -Wall"

# Full credit to Dave Dopson from Stack Overflow for the command that is used to find the path of the GitHub repo.
# https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself

# Prints correct usage. Takes in an argument as the error message.
usage() {
	echo -e "\033[31mError\033[m: Please specify a $1."
	echo -e "\033[33mUsage\033[m: ./uatest.sh [options] <command> [-p problem] [file-name]"
	exit 2
}

# Verify a command or option is given.
test $# -eq 0 && usage command

# Help option.
if [ $1 = "-h" ] || [ $1 = "--help" ] || [ $1 = "help" ]
then
	cat $SOURCE_PATH/src/help.txt && exit 0 || exit 1
fi

# Clean command.
test $1 = "clean" && rm -rf $DIR && exit 0

# Check for options.
test $i -lt $# && test ${ARGS[$i]} = "-o" || test ${ARGS[$i]} = "--output" && output_flag="1" && (( i++ ))

# Verify a command is given after the options.
test ! $i -lt $# && usage command

# Test command.
if [ ${ARGS[$i]} = "test" ]
then
	(( i++ ))

	# Get problem id from file if possible.
	test -f $CONFIG && . $CONFIG
	
	# Read in problem id and file arguments.
	if [ $((i + 2)) -lt $# ] && [ ${ARGS[$i]} = "-p" ]
	then
		# If both problem id and file name were given.
		new_prob="${ARGS[$(( ++i ))]}"
		new_file="${ARGS[$(( ++i ))]}"
	elif [ $i -lt $# ] && [ ${ARGS[$i]} != "-p" ]
	then
		# Read in file name if it was given and implicitly infer problem id.
		new_file="${ARGS[$i]}"
		new_prob="${ARGS[$i]##*/}" && new_prob="${new_prob%.*}"
	fi

	# If arguments differ from config data, download new test cases.
	if [ $new_prob ] && { [ -z $PROB ] || [ $new_prob != $PROB ]; }
	then
		# Information for the user.
		PROB="$new_prob" && FILE="$new_file"
		printf "Downloading test cases..."

		# Download sample test cases.
		mkdir -p $DIR
		wget -q -O $DIR/samples.zip https://open.kattis.com/problems/$PROB/file/statement/samples.zip > /dev/null

		# Catch when not downloadable.
		if [ $? -ne 0 ]; then
			echo "unable to download test cases."
			echo -e "Problem id: $PROB\nFile: $FILE\n"
			rm -f $DIR/samples.zip
			exit 1
		else
			echo "downloaded!"
			rm -f $DIR/*.in $DIR/*.ans
			unzip -q $DIR/samples.zip -d $DIR
			rm -f $DIR/samples.zip
		fi
	elif [ $new_file ]
	then
		# Update file if it has changed but the problem has not.
		FILE="$new_file"
	fi

	# Check if problem id or file has been given.
	test -z $PROB$FILE && usage "problem id and file"
	test -z $PROB && usage "problem id"
	test -z $FILE && usage file

	# Catch non-supported languages.
	if [[ $FILE != *".c" ]] && [[ $FILE != *".cpp" ]] && [[ $FILE != *".py" ]]
	then
		echo "This script only supports C, C++, and Python 3."
		exit 2
	fi

	# Update config file and print problem id and file name for the user.
	echo -e "PROB=$PROB\nFILE=$FILE" > $CONFIG
	echo -e "Problem id: $PROB\nFile: $FILE\n"

	# Compile C or C++.
	if [[ $FILE == *".c" ]] || [[ $FILE == *".cpp" ]]
	then
		# Compile the program.
		g++ $FILE $CFLAGS -o $DIR/a.out
		
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
		if [[ $FILE == *".c" ]] || [[ $FILE == *".cpp" ]]
		then
			START=$(date +%s%3N)
			$DIR/a.out < $i > ${i%.*}.test
			COMP=$?
			TIME=$(($(date +%s%3N)-START))
		elif [[ $FILE == *".py" ]]
		then
			START=$(date +%s%3N)
			python3 $FILE < $i > ${i%.*}.test
			COMP=$?
			TIME=$(($(date +%s%3N)-START))
		else
			echo "This script only supports C, C++, and Python 3."
			exit 2
		fi

		# See what the result was.
		if diff ${i%.*}.test ${i%.*}.ans > /dev/null
		then
			echo -e "${i##*/}: \033[32mCorrect Answer\033[m...${TIME}ms"
		elif [ $COMP -eq 0 ]
		then
			echo -e "${i##*/}: \033[31mWrong Answer\033[m...${TIME}ms"
		else
			echo -e "${i##*/}: \033[31mRuntime Error\033[m...${TIME}ms\n"
		fi

		# If the output flag was set, print the output.
		if [ $output_flag ] && [ $COMP -eq 0 ]
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
if [ ${ARGS[$i]} = "submit" ]
then
	(( i++ ))

	# Get problem id from file if possible.
	test -f $CONFIG && . $CONFIG
	
	# Read in problem id and file arguments.
	if [ $((i + 2)) -lt $# ] && [ ${ARGS[$i]} = "-p" ]
	then
		# If both problem id and file name were given.
		PROB="${ARGS[$(( ++i ))]}"
		FILE="${ARGS[$(( ++i ))]}"
	elif [ $i -lt $# ] && [ ${ARGS[$i]} != "-p" ]
	then
		# Read in file name if it was given and implicitly infer problem id.
		FILE="${ARGS[$i]}"
		PROB="${ARGS[$i]##*/}" && PROB="${PROB%.*}"
	fi

	# Check if problem id or file has been given.
	test -z $PROB$FILE && usage "problem id and file"
	test -z $PROB && usage "problem id"
	test -z $FILE && usage file

	# Tells the user what problem they are testing incase of issues.
	echo -e "Problem id: $PROB\nFile: $FILE\n"

	# Submit the file to Kattis, clean, and exit.
	python3 $SOURCE_PATH/src/submit.py -p $PROB $FILE -f
	rm -rf $DIR
	exit 0
fi
