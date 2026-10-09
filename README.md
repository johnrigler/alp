ALP is a set of bash functions which almost all start with 'a.'.
I load these into my shell environment via entries in the
$HOME/.bashrc file.

## Directory loader and source browser

The ALP installation can live in `/opt/alp`, while each working directory holds
its own functions, scripts, and other files. Source the installation once:

```bash
export _ALP_=/opt/alp
. "$_ALP_/alp.bash"
```

`_ALP_` defaults to the directory containing `alp.bash` if it is not already set.
The corrected helpers in `core.bash` are loaded after the original `functions/`
snapshots. Existing checksum-named files are kept as historical versions.

```bash
alp2 "$HOME/my-functions"    # Create a missing manifest, then source its entries.
a.index "$HOME/my-functions" # Regenerate the manifest after adding files.
a.web "$HOME/my-functions"   # Copy the static alp-view.html source browser.
```

`alp2` defaults to `_ALP2_`, or `$HOME/alp2` on its first call. It reads the
manifest directly into a `while` loop, so loaded definitions stay in the calling
shell. It does not change directories. `_ALP2_` records the selected directory.
Updating a source file requires loading it again to replace a live definition.

The generated `.files.txt` lists visible files in filename order. Each line has
an action, a literal tab, and a relative path. You can reorder or edit it:

```text
# ALP mode: functions
source<TAB>first.bash
source<TAB>second function-38699.1
script<TAB>ingest.py
view<TAB>notes.txt
directory<TAB>archive
```

Replace `<TAB>` with a real tab. Plain paths from the original `alp2` manifest
still mean `source`. Blank lines, comments, CRLF endings, and a final line without
a newline are supported. The loader uses an existing manifest unchanged. Hidden
files and the generated `alp-view.html` are excluded when indexing.

`a.index DIRECTORY MODE` accepts `functions` (the default), `scripts`, and `view`.
Function mode selects Bash files and ALP function snapshots for sourcing;
JavaScript/Python files are script entries and ordinary documents are view entries.
Script mode marks shell, Python, JavaScript, and executable files as scripts.
View mode displays all files without loading them. Filename classification is a
starting point: edit the manifest to mark extensionless scripts or data snapshots
correctly. `source` entries execute top-level Bash statements as well as defining
functions; only list files you intend to source. Syntax is checked before each
source entry. Missing or failing entries are reported and produce a nonzero
return, while successful earlier entries remain loaded.

```bash
a.index "$HOME/my-scripts" scripts
alp2 "$HOME/my-scripts"                 # Runs no script entries.
a.run "$HOME/my-scripts" ingest.py arg  # Run one selected script explicitly.
```

Scripts run in their directory in a separate process. Shell scripts use Bash,
Python scripts use `python3`, and executable files use their shebang. JavaScript
scripts require an executable file with a shebang selecting your runtime.
The browser itself uses vanilla JavaScript and does not require Node or a CDN.

Open `alp-view.html` on any static HTTP server or IPFS gateway. It reads the same
manifest and shows source with Bash, JavaScript, Python, JSON, HTML, or CSS colors.
Hash URLs preserve the selected directory and file across refreshes. Index each
subdirectory you want to browse. For `file://` use **Open local folder**; files stay
in the browser and are not uploaded. HTML and scripts are displayed as text.
The colorizer is lexical rather than a full parser; choose **Plain text** for
unusual formats. Files over 1 MB are displayed without coloring.

## Corrected helpers

```bash
a.h d.task            # Define a function from the previous history command.
a.h d.task 123        # Select a specific history event.
a.v d.task            # Edit the live definition; validate before reloading.
a.fs d.task           # Save with the original BSD sum filename.
a.fS d.task           # Save with shifted-octal cksum.
a.fss d.task          # Save with the original short SHA-1 format.
a.save d.task . d.s   # Use another namespace's existing checksum function.
```

`a.h` uses Bash's `fc` builtin to preserve quotes, pipes, whitespace, and multiline
history entries. It defines the function without executing its body. `a.v` uses
`VISUAL`, then `EDITOR`, then `vi`; set these to an editor executable. Failed
syntax checks keep the live definition and leave the edited file for recovery.
Saving uses local scratch variables and reports a missing function rather than
writing an empty snapshot. An existing snapshot with different content is treated
as a checksum collision. These short historical checksums are labels, not
cryptographic integrity guarantees.

Development checks:

```bash
bash tests/test-alp.bash
python3 tests/test-history.py
node tests/test-viewer.cjs
```

The viewer check uses Node only to test the browser JavaScript; the delivered
viewer has no Node dependency.

## Original ALP notes

Alp is used to repurpose the bash function as a native data store.
Here is an example. Given that a function called 'example' is loaded
into the shell, the following command will return it's content in
a standard way. 
<pre>
> a.f example
example () 
{ 
    : this gets formatted automatically
}

The 'a.f' function is simply a wrapper for 'declare -f $FUNCTION'
> a.f a.f
a.f () 
{ 
    __T=a.f;
    : : Shows Specified ALP Function, takes one argument;
    declare -f $1
}
The double-underscore "T" variable is an internalization of the function's
name. The ": :" line is retrieved by 'a.help'.

Almost all of the "alp" functions can be seen by typing "a." and hitting tab. 'a.f' 
can be used to show content.[1] 'a.v' edits the function live and puts it back 
into memory. To save a function, it must be written into the "functions" 
subdirectory. This is done with the 'a.fs' command. The function is then 
rendered into a single file where its name contains its simple (BSD) sum:

> a.f example | sum
38699     1
> a.fs example
example-38699.1
> cat example-38699.1 | sum
38699     1

The a.v function is and example of a reader. Readers are the first step in
creating a native Read-Eval-Print Loop or "REPL" for short. A reader also
exists for the eval command and servers the same purpose as a.v. This reader
is called "a.h" and means "her.story". It renders the last command run into 
a function by retrieving it from the history command. 

Finally, the "alp" command does not have to be run, but can be used to 
render special purpose code in the "alp" style. I install "alp" into 
/opt/alp and keep these special functions in $HOME/alp/$MODULE.bash

I usually end up creating a module where I work and this gives a nice wall of 
separation between /opt/alp and customer code. 

Add this to your .bashrc file (which should be in your home directory):

export _ALP_=/opt/alp
. $_ALP_/alp.bash

<hr>
[1] One notable exception is the minus function. The minus symbol can be
overloaded to serve different purposes, but I almost exclusively use it to
mean print to screen. This drives towards the high level of human readability 
of the fuctions. A YAML reader could be hastily assembled by defining a value for 
triple minus in a similar style:

 ---() { :; } 

A minus function could also be seen as a lambda function within this system. 
