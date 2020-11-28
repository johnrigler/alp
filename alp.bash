alp() {
# Copyright 2020 Secret Beach Solutions, LLC 

# Proof of Organization on May 14, 2020 

: copyright 2020 DCxSECRETxBEACHxSoLUTioNSzzzY84D1u
: dogecoin:3f00bfca5133b8e68bab5146628157d3ca21de92221a712627bc1e02e5c74500

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#    http://www.apache.org/licenses/LICENSE-2.0

: license QmNprJ78ovcUuGMoMFiihK7GBpCmH578JU8hm43uxYQtBw

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

:: () 
{ 
# This function is useful for recursion
    :
}
: Welcome to ALP
# The name of this system is a reference to
# Anna Livia Plurabelle, who is perhaps
# the dreamer of the sui generis 
# steam-of-consciousness novel: Finnegans Wake

# ALP is also inspired by the language LISP
# and acts as a read-eval-print-loop
# in its automated form as well as when
# a user is working from a bash shell

# ALP requirements:
# must be installed on a *nix environment
# bash shell (this all gets sourced into bash)
# ipfs
# php5 and python3
# apache or nginx

# Finally, you must run a cryptocurrency
# This will work with dogecoind, digibyted (and probably verge)

# DiMECASH (https://dime.cash) is built with ALP
# and is a running example of how it works.
}

a.f () 
{ 
    :: Shows Specified ALP Function, takes one argument;
    declare -f -- $1
}
a.F ()
{
    :: Shows Function names;
    declare -F -- $1
}
-()
{
    :: Special EVAL operator;
    echo "$*";
}

a.eval() {
    :: Initial EVAL FUNCTION
_WD=$(pwd);

cd $_ALP_/functions;

ls | while read FUNCTION
do
	echo ". $_ALP_/functions/$FUNCTION"
done > $HOME/exec.$$

. $HOME/exec.$$
rm $HOME/exec.$$
cd $_WD;
} 
a.dir () 
{ 
cd $_ALP_;
}
## End of ALP function
## ALP
a.Sh () 
{ 
    local __T=a.Sh;
    : : renders a Seven Digit Shoctal;
    T=$(cksum | awk '{ print $1 }' | tr '01234567' '23456789' | cut -c 1-7);
    echo ".0$T"
}
un () 
{ 
    local __T="un";
    local _ARG1=$1;
    shift; 

    python3 $_ALP_/QmZEF7LGBicfaNgtoJyT2uo11YX7L6SYdKMYA1tAMH6pfc $_ARG1 "$*"
}
