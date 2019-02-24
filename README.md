# UAPSC Kattis Testing Script
Script/utility that tests sample cases from Kattis locally, built for UAPSC.
Furthermore, can submit problem solutions to Kattis problems remotely.
See below for details on how to set up remote submissions.
<br/><br/>
The script supports C, C++, and Python 3.
<br/>

---

<br/>

Usage: `./uatest.sh [options] <command> [-p problem] [file-name]`<br/><br/>
Note that this script was built to be called from anywhere in the user's home directory,
not just the repository directory.

## Commands
- `clean` - Deletes the local copies of sample test cases and data on what was the last problem id/file. 
- `test` - Tests the file given against sample input. May download test cases when needed.
- `submit` - Submits the solution code remotely. This is not enabled by default, see below for details.

## Options
- `-h`, `--help`, `help` - Prints a help message to terminal then exits.
- `-o`, `--output` - When this flag is given, it prints the output of the program after each test case.
- `-p <problem>` - Specifies the Kattis problem id to download test cases for/submit to.
- `<file-name>` - Specifies the file to test with.

## Example Usage
Some examples of calling the script:<br/>
`./uatest.sh clean`<br/>
`./uatest.sh test -p abc soln.cpp`<br/>
`~/<path-to-repo>/uatest.sh -o test -p abc diff_soln.py`<br/>
`./uatest.sh --output test` (Assuming the problem and file were specified previously.)<br/>
`./uatest.sh submit -p abc some_soln.c`<br/>
`./uatest.sh submit` (Assuming the problem and file were specified previously.)<br/>

## Testing
To test a given problem, run the script with the subcommand `test` and give
the problem id and file name as arguments. The script then downloads the sample test
cases, and runs the solution code against them, providing feedback. By default it
does not display the output of the program but can with the `-o` option. Furthermore,
the problem id and file name only need to specified the first time `test` is run,
as it remembers the last id and file used.

## Submitting
Initially, remote submissions are disabled. To submit remotely, this script uses a
different script written by developers at Kattis. Their script requires the user to
have an account-specific file called `.kattisrc` on their system to authenticate them.
To download the file, login to Kattis and go to this link:<br/>
https://open.kattis.com/help/submit.<br/>
The `.kattisrc` file needs to be moved to the `src` folder in this repo or the home
directory in order for the `submit` subcommand to work. In reality their script does
all the heavy lifting, and this script just simplifies the process. Furthermore their
script needs Python 2/3 to work. Their script `submit.py` is included in this repo
for completeness but was not modified.

## Copyright and Citations
This project is built for a non-commercial educational purpose and is open source
under a MIT licence.
<br/><br/>
This project and it's contributors are not affiliated with or endorsed by Kattis
in any capacity, and the file `submit.py` was not written by this project's contributors,
and is entirely the property of Kattis. Furthermore, full credit to Kattis and the contest
it gets its problems from for the sample test cases.
<br/><br/>
Additionally, in the development of this script the Stack Overflow article below is referenced:<br/>
https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself.<br/>
Full credit to Dave Dopson for a command used to in the script. See the script `uatest.sh` for details.

<br/>

---

<br/>

For any issues, concerns, or questions feel free to email ngergel@ualberta.ca.
