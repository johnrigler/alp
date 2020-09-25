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

cd $_ALP_DIR/functions;

ls | while read FUNCTION
do
	echo ". $_ALP_DIR/functions/$FUNCTION"
done > $HOME/exec.$$

. $HOME/exec.$$
rm $HOME/exec.$$
cd $_WD;
