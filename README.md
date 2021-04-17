ALP is a set of bash functions which almost all start with 'a.'.
I load these into my shell environment via entries in the
$HOME/.bashrc file.

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
