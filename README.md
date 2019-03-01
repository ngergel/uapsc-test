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

Note that the file only needs to be specified only the first time either `test` or `submit` is called.
If no problem id is specified, the problem id is infered from the file name. If the script has
been installed as a command, the command `uatest` can be used instead of the script.

## Sub Commands
- `clean` - Deletes test cases and problem meta data.
- `test` - Tests the file given against sample input. May download test cases when needed.
- `submit` - Submits the solution code remotely. This is not enabled by default, see below for details.
- `install` - Installs the script as a command 'uatest', which works in place of the script. The terminal may need to be restarted.
- `uninstall` - Uninstalls the command.

## Options
- `-h`, `--help`, `help` - Prints a help message and exits.
- `-o`, `--output` - When using the 'test' subcommand, print the output of the solution code.
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
the problem id and file name as arguments. If no problem id is given, it infers it
from the file name. Furthermore, the problem id and file name only need to specified
the first time `test` is run, as it remembers the last id and file used.

## Submitting
Initially, remote submissions are disabled. To submit remotely, the user must have
an account-specific file called `.kattisrc` on their system to authenticate them.
To download the file, login to Kattis and go to this link:<br/>
https://open.kattis.com/help/submit.<br/>
The `.kattisrc` file needs to be moved to the `src` folder in this repo or the home
directory in order for the `submit` subcommand to work. In reality this script uses
one made by Kattis, and just simplifies the process. Furthermore their script needs
Python 2/3 to work. Their script, called `submit.py`, is included in this repo for
completeness but was not modified.

## Copyright and Citations
This project is built for a non-commercial educational purpose and is open source
under an MIT licence.
<br/><br/>
This project and it's contributors are not affiliated with or endorsed by Kattis
in any capacity. The file `submit.py` was not written by this project's contributors,
and is entirely the property of Kattis.<br/>
It is under an MIT licence: https://github.com/Kattis/kattis-cli.
<br/><br/>
Additionally, in the development of this script the Stack Overflow article below is referenced:<br/>
https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself.<br/>
Full credit to Dave Dopson for a command used to in the script. See the script `uatest.sh` for details.

<br/>

---

<br/>

For any issues, concerns, or questions feel free to email ngergel@ualberta.ca.
