ALP is a set of bash functions which almost all start with 'a.'.
I load these into my shell environment via entries in the
$HOME/.bashrc file.

Alp is used to repurpose the bash function as a native data store.
Here is an example. Given that a function called 'example' is loaded
into the shell, the following command will return it's content in
a standard way. 

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

All of the "alp" functions can be seen by typing "a." and hitting tab. 'a.f' can be used to show content. 'a.v' edits the function live and puts it back into memory. To change a function, it must be rewritten into the "functions" subdirector. This is done with the 'a.fs' command. The function is then rendered into a single file where its name contains its simple (BSD) sum:

> a.f example | sum
38699     1
> a.fs example
example-38699.1
> cat example-38699.1 | sum
38699     1

Other features are more obscure, such as "a.h" which was once called "herstory"  and renders the last command run into a function.

Finally, the "alp" command does not have to be run, but can be used to 
render special purpose code in the "alp" style. I install "alp" into /opt/alp and keep these special functions in $HOME/alp/$MODULE.bash

I usually end up creating a module where I work and this gives a nice wall of 
separation between /opt/alp and customer code. 

