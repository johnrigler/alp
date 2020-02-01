a.F () 
{ 
    __T=a.F;
    : : List all function names;
    declare -F $1
}
a.S () 
{ 
    __T=a.S;
    : : renders a.sho in Octal;
    cksum | while read A B; do
        A=$(echo "obase=8; $A" | bc | a.sho);
        B=$(echo "obase=8; $B" | bc | a.sho);
        echo $A.$B;
    done
}
a.Sh () 
{ 
    __T=a.Sh;
    : : Creates ALP file variant for a.S;
    a.f $1 > $1-$(a.f $1 | a.S | cut -c 1-7)
}
a.c () 
{ 
    __T=a.c;
    : : color Changed the color in the shell or web version;
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
a.dir () 
{ 
    __T=a.dir;
    : : Change to ALP Home directory;
    cd $_ALP_DIR/$1
}
a.e () 
{ 
    __T=a.e;
    : : Shows _ALP Environment Variables;
    env | grep '_ALP'
}
a.f () 
{ 
    __T=a.f;
    : : Shows Specified ALP Function, takes one argument;
    declare -f $1
}
a.fS () 
{ 
    __T=a.fS;
    : : Creates ALP file for a.S variant;
    _FS=$(echo $1 $(a.f $1 | a.S) | sed 's/ /-/');
    a.f $1 > $_FS;
    echo $_FS
}
a.fs () 
{ 
    __T=a.fs;
    : : Creates a CRC Checksum ALP file in the local directory;
    _FS=$(echo $1 $(a.f $1 | a.s) | sed 's/ /-/');
    a.f $1 > $_FS;
    echo $_FS
}
a.h () 
{ 
    __T=a.h;
    : : Transforms the last command into a function;
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
    : - "$1 () { $_T ; }";
    function - () 
    { 
        :
    }
}
a.help () 
{ 
    __T=a.help;
    : : Help Facility;
    a.l | while read CMD; do
        HELP=$(a.f $CMD | grep "^    : :");
        echo "$CMD	$HELP";
    done
}
a.l () 
{ 
    __T=a.l;
    : : List all base ALP functions;
    a.F | grep "declare -f a." | cut -c 12-
}
a.make () 
{ 
    __T=a.make;
    : : Returns all ALP functions;
    a.F | grep "declare -f a." | cut -c 12- | while read CMD; do
        a.f $CMD;
    done
}
a.mkmod () 
{ 
    __T=a.mkmod;
    : : Create ALP Module, takes two variables: DIR PRE;
    export _ALP_MODULE="$1";
    export _ALP_MODULE_PRE="$2";
    mkdir -p $_ALP_MODULE 2> /dev/null;
    touch $_ALP_MODULE/alp.bash;
    source alp.bash
}
a.mod () 
{ 
    __T=a.mod;
    : : Set ALP Module, takes one variable;
    export _ALP_MODULE="$1"
}
a.s () 
{ 
    __T=a.s;
    : : Creates a CRC Sum extension;
    sum | while read A B; do
        echo $A.$B;
    done
}
a.sho () 
{ 
    __T=a.sho;
    : : Creates Shoctal numbers;
    while read LINE; do
        echo $LINE | sed 's/7/9/g' | sed 's/6/8/g' | sed 's/5/7/g' | sed 's/4/6/g' | sed 's/3/5/g' | sed 's/2/4/g' | sed 's/1/3/g' | sed 's/0/2/g';
    done
}
a.v () 
{ 
    __T=a.v;
    : : vi specified function or ALP_TARGET;
    a.f $1 > $$;
    _ALP_TARGET=$$;
    if [ $_ALP_TARGET ]; then
        vi $_ALP_TARGET;
        . $_ALP_TARGET;
        rm $$;
    else
        vi $_ALP_SRC;
        . $_ALP_SRC;
    fi
}
a.vb () 
{ 
    __T=a.vb;
    : : vi bashrc;
    vi ~/.bashrc;
    . ~/.bashrc
}
