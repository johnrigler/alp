-() { echo $*; } 
_ALP_DIR=~/alp
_ALP_SRC=$_ALP_DIR/alp.bash
echo welcome from alp;

ƒ() {

declare -f $1;

}

Ï() {

declare -F $1;

}

√() {

vi $_ALP_SRC
. $_ALP_SRC 
} 

√∫() {

vi ~/.bashrc
. ~/.bashrc
}

ß() {

sum | sed 's/\ .*//';

} 

. $_ALP_DIR/public/ƒß-38889;
