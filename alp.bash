:: () 
{ 
    :
}
-()
{
    : : Special EVAL operator;
    echo "$*";
}

_WD=$(pwd);

cd $_ALP_/functions;

ls | while read FUNCTION
do
	echo ". $_ALP_/functions/$FUNCTION"
done > $HOME/exec.$$

. $HOME/exec.$$
rm $HOME/exec.$$
cd $_WD;
