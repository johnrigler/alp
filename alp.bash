export _ALP_DIR=~/alp
export _ALP_SRC=$_ALP_DIR/alp.bash


a.e() {
env | grep '_ALP'
}

a.f() {
# ƒ() {
: https://en.wikipedia.org/wiki/Florin_sign
: is a shortcut for
declare -f $1;

}

a.F() {
# Ï() {
: https://en.wikipedia.org/wiki/%C3%8F
: is a shortcut for
declare -F $1;

}

a.v() {
# √() {

if [ $_ALP_TARGET ]; then
echo xxxxxxxxxxxx
vi $_ALP_TARGET
. $_ALP_TARGET
else
vi $_ALP_SRC
. $_ALP_SRC 
fi
} 

a.vb() {
# √∫() {

vi ~/.bashrc
. ~/.bashrc
}

a.s() {
# ß() {

sum | sed 's/\ .*//';

} 

. $_ALP_DIR/public/ƒß-38889;
