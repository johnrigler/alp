
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

a.f $1 > $$
_ALP_TARGET=$$

if [ $_ALP_TARGET ]; then
vi $_ALP_TARGET
. $_ALP_TARGET
rm $$
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
a.seq () 
{ 
    /bin/ls $LS_OPTIONS -sort | cut -c 40- | sed 's/.*..-//g' | grep ".1" | sed 's/\.1//g' > seq.txt
}

color () 
{ 
    : color Changed the color in the shell or web version;
    : color Possible colors are white,bold,underline,error,red,green,yellow,blue,purple,aqua;
    if [ -n $1 ]; then
        case $1 in 
            white)
                FG='00m'
            ;;
            bold)
                FG='01m'
            ;;
            underline)
                FG='04m'
            ;;
            error)
                FG='31m'
            ;;
            red)
                FG='31m'
            ;;
            green)
                FG='32m'
            ;;
            yellow)
                FG='33m'
            ;;
            blue)
                FG='34m'
            ;;
            purple)
                FG='35m'
            ;;
            aqua)
                FG='36m'
            ;;
        esac;
        printf "\033[$FG";
    fi
}
a.her.story () 
{ 
    : her story was always better than his.tory;
    _HER_STORY=$(history | tail -2 | head -1 | while read FIRST REST
    do
    echo $REST
done 
    );
    echo "$1 () { $_HER_STORY ; }"
}
a.h () 
{ 
    function - () 
    { 
        echo "$1 () {";
        echo "$*" | while read FIRST SEC REST; do
            echo $REST;
        done;
        echo "}"
    };
    - $1 $(history | tail -2 | head -1) > $$;
    . $$;
    a.f $1;
    rm $$;
    : - "$1 () { $_T ; }"
}
