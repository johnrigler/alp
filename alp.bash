::() { :; }
a.F () 
{ 
    local __T=a.F;
    : : List all function names;
    declare -F $1
}
a.S () 
{ 
    local __T=a.S;
    : : renders a.sho in Octal;
    cksum | while read A B; do
        A=$(echo "obase=8; $A" | bc | a.sho);
        B=$(echo "obase=8; $B" | bc | a.sho);
        echo $A.$B;
    done
}
a.Sh () 
{ 
    local __T=a.Sh;
    : : Creates ALP file variant for a.S;
    a.f $1 > $1-$(a.f $1 | a.S | cut -c 1-7)
}
a.c () 
{ 
    local __T=a.c;
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
    local __T=a.dir;
    : : Change to ALP Home directory;
    cd $_A_DIR/$1
}
a.env () 
{ 
    local __T=a.env;
    : : Shows _A_ Environment Variables;
    env | grep '_A_'
}
a.f () 
{ 
    local __T=a.f;
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
    local __T=a.h;
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
    local __T=a.help;
    : : Help Facility;
    a.l | while read CMD; do
        HELP=$(a.f $CMD | grep "^    : :");
        echo "$CMD	$HELP";
    done
}
a.l () 
{ 
    local __T=a.l;
    : : List all base ALP functions;
    a.F | grep "declare -f a." | cut -c 12-
}
a.make () 
{ 
    local __T=a.make;
    : : Returns all ALP functions;
    echo "::() { :; }";
    a.F | grep "declare -f a." | cut -c 12- | while read CMD; do
        a.f $CMD;
    done
}
a.mkmod () 
{ 
    local __T=a.mkmod;
    : : Create ALP Module, takes two variables: DIR PRE;
    export _A_MODULE="$1";
    export _A_MODULE_PRE="$2";
    mkdir -p $_A_MODULE 2> /dev/null;
    touch $_A_MODULE/alp.bash;
    source alp.bash
}
a.mod () 
{ 
    local __T=a.mod;
    : : Set ALP Module, takes one variable;
    export _A_MODULE="$1";
    source $_A_MODULE/alp.bash;
    function _a.mod () 
    { 
        NAME="$_A_MODULE_PRE".a.$1;
        declare -f a.$1;
        echo "$NAME () { __T=$NAME; :: $2 ; $3; }" > $$;
        source $$;
        rm $$
    };
    _a.mod dir "Change to module home directory" "cd $_A_MODULE/"'$1';
    CMD="declare -F | grep 'declare -f $_A_MODULE_PRE.' | cut -c 12-";
    _a.mod l "List module functions" "$CMD"
}
a.s () 
{ 
    local __T=a.s;
    : : Creates a CRC Sum extension;
    sum | while read A B; do
        echo $A.$B;
    done
}
a.sho () 
{ 
    local __T=a.sho;
    : : Creates Shoctal numbers;
    while read LINE; do
        echo $LINE | sed 's/7/9/g' | sed 's/6/8/g' | sed 's/5/7/g' | sed 's/4/6/g' | sed 's/3/5/g' | sed 's/2/4/g' | sed 's/1/3/g' | sed 's/0/2/g';
    done
}
a.v () 
{ 
    local __T=a.v;
    : : vi specified function or ALP_TARGET;
    echo "$1 ()" > $$;
    echo "{" >> $$;
    echo "    local __T=$1;" >> $$;
    a.f $1 | grep -v "^    local __T=" | tail +3 >> $$;
    _A_TARGET=$$;
    if [ $_A_TARGET ]; then
        vi $_A_TARGET;
        . $_A_TARGET;
        rm $$;
    else
        vi $_A_SRC;
        . $_A_SRC;
    fi
}
a.vb () 
{ 
    local __T=a.vb;
    : : vi bashrc;
    vi ~/.bashrc;
    . ~/.bashrc
}
