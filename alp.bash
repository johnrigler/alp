a.F () 
{ 
    : : List all function names;
    declare -F $1
}
a.S () 
{ 
    : : renders a.sho in Octal;
    cksum | while read A B; do
        A=$(echo "obase=8; $A" | bc | a.sho);
        B=$(echo "obase=8; $B" | bc | a.sho);
        echo $A.$B;
    done
}
a.Sh () 
{ 
    : : Creates ALP file variant for a.S;
    a.f $1 > $1-$(a.f $1 | a.S | cut -c 1-7)
}
a.e () 
{ 
    : : Shows _ALP Environment Variables;
    env | grep '_ALP'
}
a.f () 
{ 
    : : Shows Specified ALP Function, takes one argument;
    declare -f $1
}
a.fS () 
{ 
    : : Creates ALP file for a.S variant;
    _FS=$(echo $1 $(a.f $1 | a.S) | sed 's/ /-/');
    declare -f $1 > $_FS;
    echo $_FS
}
a.fs () 
{ 
    : : Creates a CRC Checksum ALP file in the local directory;
    _FS=$(echo $1 $(a.f $1 | a.s) | sed 's/ /-/');
    declare -f $1 > $_FS;
    echo $_FS
}
a.h () 
{ 
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
    : : Help Facility;
    a.l | while read CMD; do
        HELP=$(declare -f $CMD | grep "^    : :");
        echo "$CMD	$HELP";
    done
}
a.l () 
{ 
    : : List all base ALP functions;
    declare -F | grep "declare -f a." | cut -c 12-
}
a.make () 
{ 
    : : Returns all ALP functions;
    function - () 
    { 
        declare -f $1
    };
    declare -F | grep "declare -f a." | cut -c 12- | while read CMD; do
        - $CMD;
    done;
    function - () 
    { 
        :
    }
}
a.s () 
{ 
    : : Creates a CRC Sum extension;
    sum | while read A B; do
        echo $A.$B;
    done
}
a.sho () 
{ 
    : : Creates Shoctal numbers;
    while read LINE; do
        echo $LINE | sed 's/7/9/g' | sed 's/6/8/g' | sed 's/5/7/g' | sed 's/4/6/g' | sed 's/3/5/g' | sed 's/2/4/g' | sed 's/1/3/g' | sed 's/0/2/g';
    done
}
a.v () 
{ 
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
    : : vi bashrc;
    vi ~/.bashrc;
    . ~/.bashrc
}
a.c () 
{ 
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
