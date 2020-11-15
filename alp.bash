# Copyright 2020 Secret Beach Solutions, LLC 

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#    http://www.apache.org/licenses/LICENSE-2.0
#               or 
#    https://ipfs.io/ipfs/QmNprJ78ovcUuGMoMFiihK7GBpCmH578JU8hm43uxYQtBw


# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



alp() {
:: () 
{ 
    :
}
: Welcome to ALP
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

-eval() {
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
    cd $_ALP_
} 
}
