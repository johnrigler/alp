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
