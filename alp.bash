::() { :; }
alp () 
{ 
    export _ALP_DIR="$1";
    export _ALP_MOD="$2";
    . $_ALP_DIR/$_ALP_MOD.bash
}
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
a.back () 
{ 
    cd $_WD
}
a.build () 
{ 
    _WD=$(pwd);
    a.dir;
    mkdir build 2> /dev/null;
    cd build;
    a.l | while read FUNCTION; do
        a.fs $FUNCTION;
    done;
    cd $_WD
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
    export _WD=$(pwd);
    cd $_ALP_DIR;
    function a.back () 
    { 
        cd $_WD
    }
}
a.div () 
{ 
    local __T=a.div;
    : : Creates a simple DIV wrapper for HTML;
    function - () 
    { 
        echo "$*"
    };
    - '<div>';
    - '</div>'
}
a.dte () 
{ 
    date "+%Y/%W%w"
}
a.env () 
{ 
    local __T=a.env;
    : : Shows _ALP_ Environment Variables;
    env | grep '_ALP_'
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
        shift;
        history 2 | head -1 | while read T T T REST; do
            echo "$REST";
        done;
        echo "}"
    };
    - $1 > $$;
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
    local __T='a.make';
    : : Build new ALP file.;
    _FILE="alp.bash";
    a.dir;
    echo "::() { :; }" > $_FILE;
    a.f alp >> $_FILE;
    a.l | while read CMD; do
        a.f $CMD;
    done >> $_FILE;
    a.back
}
a.mkmod () 
{ 
    local __T=a.mkmod;
    : : Create ALP Module, takes two variables: DIR PRE;
    export _ALP_MODULE="$1";
    a.dir;
    source $_ALP_MODULE.bash;
    function _a.mkmod () 
    { 
        NAME="$_ALP_MODULE".a.$1;
        declare -f a.$1;
        echo "$NAME () { __T=$NAME; :: $2 ; $3; }" > $$;
        source $$;
        rm $$
    };
    _a.mkmod dir "Change to module home directory" "cd $_A_MODULE/"'$1';
    CMD="declare -F | grep 'declare -f $_A_MODULE_PRE.' | cut -c 12-";
    _a.mkmod l "List module functions" "$CMD"
}
a.mod () 
{ 
    local __T=a.mod;
    : : Set ALP Module, takes one variable;
    export _ALP_MOD="$1";
    if [[ $_ALP_MOD != 'alp' ]]; then
        _FILE=$_ALP_DIR/$_ALP_MOD.bash;
        touch $_FILE;
        source $_FILE;
        function _a.mod () 
        { 
            NAME="$1.$2";
            echo $NAME;
            echo "$NAME () { __T=$NAME; :: $3 ; $4; }" > $$;
            source $$;
            rm $$;
            declare -f $NAME
        };
        CMD="declare -F | grep 'declare -f $_ALP_MOD' | cut -c 12-";
        _a.mod $_ALP_MOD l "List module functions" "$CMD";
    fi
}
a.pre () 
{ 
    : YYYY/MMWw;
    T=$(a.dte);
    mkdir -p ~/$1/$T;
    : Create a script file with date stamp;
    WD=$(pwd);
    : Move into Directory;
    cd ~/$1/$T;
    script $(a.tme);
    pwd;
    cd $WD
}
a.s () 
{ 
    local __T=a.s;
    : : Creates a CRC Sum extension;
    sum | while read A B; do
        echo $A.$B;
    done
}
a.sbdir () 
{ 
    local __T='a.sbdir';
    : : Create an initial sbshell structure;
    mkdir $1;
    cd $1;
    ln -s ../index.php;
    ln -s ../style.css;
    cd ..;
    chmod g-w $1
}
a.sho () 
{ 
    local __T=a.sho;
    : : Creates Shoctal numbers;
    while read LINE; do
        echo $LINE | sed 's/7/9/g' | sed 's/6/8/g' | sed 's/5/7/g' | sed 's/4/6/g' | sed 's/3/5/g' | sed 's/2/4/g' | sed 's/1/3/g' | sed 's/0/2/g';
    done
}
a.tme () 
{ 
    date "+%H%M"
}
a.v () 
{ 
    local __T='a.v';
    _T=$1;
    if [[ ! -n $_T ]]; then
        : no parms given, assume base file;
        _T=$_ALP_DIR/$_ALP_MOD.bash;
        vim $_T;
        . $_T;
        rm $_T;
    else
        : single function repl;
        _T=$_ALP_DIR/$1.$$;
        _WD=$(pwd);
        a.dir;
        _T=$(a.fs $1);
        vim $_T;
        . $_T;
        rm $_T;
        cd $_WD;
    fi
}
a.vb () 
{ 
    local __T=a.vb;
    : : vi bashrc;
    vim ~/.bashrc;
    . ~/.bashrc
}
alp () 
{ 
    export _ALP_DIR="$1";
    export _ALP_MOD="$2";
    . $_ALP_DIR/$_ALP_MOD.bash
}
a.date.w () 
{ 
    date "+%w"
}
a.date.W () 
{ 
    date "+%W"
}
a.date.yyyy () 
{ 
    date "+%Y"
}
