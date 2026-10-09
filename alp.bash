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

# DiMECASH (https://dime.cash) was built with ALP
# ALP is no longer associated with some DNS name, as that would
# be too centralized. Instead, it is references as the 
# D-form obviously unspendables:
# DAxALPzzz <-- first person (The book character)
# DBxALPzzz <-- second protocol level association
# DCxALPzzz <-- third person (Narrative channel
#
}

- () { printf '%s\n' "$*"; }

un ()
{
    local _alp_un_prefix=${1:-};
    [[ $# -gt 0 ]] || return 2;
    shift;
    python3 "$_UN_/unspendable.py" "$_alp_un_prefix" "$*";
}

# The installation can stay outside every working directory.
# Source this file into Bash; alp2 selects a separate directory of functions.
if [[ -z ${_ALP_:-} ]]; then
    _ALP_=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) || return;
fi;
. "$_ALP_/alp2.bash" || return;
. "$_ALP_/core.bash" || return;
a.eval
