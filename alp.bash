export _ALP_DIR=~/alp
export _ALP_SRC=$_ALP_DIR/alp.bash
export VISUAL=vim
export EDITOR="$VISUAL"


a.e() {
env | grep '_ALP'
}

a.f() {
declare -f $1;

}

a.F() {
declare -F $1;

}

a.v() {

if [ $_ALP_TARGET ]; then
vi $_ALP_TARGET
. $_ALP_TARGET
else
vi $_ALP_SRC
. $_ALP_SRC 
fi
} 

a.vb() {

vi ~/.bashrc
. ~/.bashrc
}

a.s() {
sum | while read A B
do
echo $A.$B
done 

}

a.sho() {
while read LINE
do
echo $LINE \
 | sed 's/7/9/g' \
 | sed 's/6/8/g' \
 | sed 's/5/7/g' \
 | sed 's/4/6/g' \
 | sed 's/3/5/g' \
 | sed 's/2/4/g' \
 | sed 's/1/3/g' \
 | sed 's/0/2/g' 
done
}

a.S() {
cksum | while read A B
do
A=$(echo "obase=8; $A" | bc | a.sho)
B=$(echo "obase=8; $B" | bc | a.sho)
echo $A.$B
done
} 

a.fs () 
{ 
    _FS=$(echo $1 $(a.f $1 | a.s) | sed 's/ /-/');
    declare -f $1 > $_FS
    echo $_FS
}

a.fS ()
{
    _FS=$(echo $1 $(a.f $1 | a.S) | sed 's/ /-/');
    declare -f $1 > $_FS
    echo $_FS
}
a.Sh () 
{ 
    a.f $1 > $1-$(a.f $1 | a.S | cut -c 1-7)
}
a.ots () 
{ 
    echo $1 | tr '01234567' '23456789'
}
a.ttd () 
{ 
    T=$(echo $1 | tr 'abcdefghIjklmnOpqrstuvwxyz(){}:; .' 'ABCDEFGHiJKLMNoPQRSTUVWXYZdbqpcsxz');
    echo $T | sed 's/-/t/g' | sed "s/'/v/g" | sed 's/\//j/g'
}
ustest () 
{ 
    unspendable D $(a.ttd "DCx-() { : stuff; }")xxxxxxxxx 30
}
