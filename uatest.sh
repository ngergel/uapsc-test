#!/bin/bash

# Script that tests a given contest problem from Kattis.
# This script supports C, C++, and Python 3.

# Global variables.
SOURCEPATH="$(find ~/ -name "uapc-test" 2> >(grep -v 'Permission denied' >&2))"
DIR="~/.uapsc-test_tmp"
CONFIG="$DIR/prob.conf"

# Flags to compile C/C++ programs with.
CFLAGS="-Wall"

echo $DIR $CONFIG
# https://unix.stackexchange.com/questions/12068/how-to-measure-time-of-program-execution-and-store-that-inside-a-variable
# https://stackoverflow.com/questions/16548528/command-to-get-time-in-milliseconds
# https://www.tecmint.com/find-directory-in-linux/
# https://stackoverflow.com/questions/762348/how-can-i-exclude-all-permission-denied-messages-from-find

# Usage function. Takes in the first parameter as
# the error output, and prints that with the proper usage
# the script.
usage() {
	echo -e "Error: $1.\n\n"
	echo "Usage: ./uatest.sh [options] <command> [-p problem] [file-name]"
	exit 2
}

# Verify a command is given.
if [ -z $1 ]
then
	usage "please specify a command"
fi

# Help option.
if [ $1 = "-h" ]
then
	echo "-h, test, submit, "
	exit 0
fi

# Command to execute a test.
if [ $1 = "test" ]; then
	# Check if an option is specified.
	if [ $2 = "-o" ]; then
		FLAG="true"

		# Check that a problem id and file are specified.
		if [ $3 != "-p" ] || [ -z $4 ]; then
			usage "a valid problem id"
		elif [ -z $5 ]; then
			usage file
		fi

		# Set problem id and file.
		PROB="$4"
		FILE="$5"
	else
		# Check that a problem id and file are specified.
		if [[ $2 != "-p" ]] || [[ -z $3 ]]; then
			usage "a valid problem id"
		elif [[ -z $4 ]]; then
			usage file
		fi

		# Set problem id and file.
		PROB="$3"
		FILE="$4"
	fi

	# Catch non-supported languages.
	if [[ $FILE != *".c" ]] && [[ $FILE != *".cpp" ]] && [[ $FILE != *".py" ]]; then
		echo "This script only supports C, C++, and Python 3."
		exit 2
	fi

	# Make new directory to store test cases, and download them.
	rm -rf $DIR
	mkdir $DIR
	wget -q -O $DIR/samples.zip https://open.kattis.com/problems/$PROB/file/statement/samples.zip > /dev/null

	# Catch when not downloadable.
	if [ $? -ne 0 ]; then
		echo "Unable to download sample test cases from Kattis."
	else
		unzip -q $DIR/samples.zip -d $DIR
		rm -f $DIR/samples.zip
	fi

	# Test the file.

	# C or C++.
	if [[ $FILE == *".c" ]] || [[ $FILE == *".cpp" ]]; then
		g++ $FILE $CFLAGS -o a.out
		
		# Exit on a compile error.
		if [ $? -ne 0 ]; then
			exit 1
		fi

		# Print outputs.
		for i in $DIR/*.in; do
			START=$(date +%s%3N)
			./a.out < $i > $i.test
			COMP=$?
			TIME=$(($(date +%s%3N)-START))

			if diff $i.test ${i%.*}.ans > /dev/null; then
				echo "${i##*/}: Correct Answer, ${TIME}ms"
			elif [ $COMP -eq 0 ]; then
				echo "${i##*/}: Wrong Answer, ${TIME}ms"
			elif [ $COMP -ne 0 ]; then
				echo "${i##*/}: Runtime Error, ${TIME}ms"
			fi
		done
		
		rm -f a.out
	fi

	# Python 3.
	if [[ $FILE == *".py" ]]; then
		# Print outputs.
		for i in $DIR/*.in; do
			echo "${i##*/}" && echo "--------"
			python3 $FILE < $i
			echo ""
		done
	fi

	# Remove the created directory.
	rm -rf $DIR
fi
