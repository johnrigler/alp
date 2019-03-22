-() { echo $*; }
echo welcome from alp

dc-xf() {

declare -f $1;

}

dc-f() {

declare -F $1;

}

alp-edit() {

vi ~/alp/alp.bash
. ~/alp/alp.bash
} 

alp-edit-bashrc() {

vi ~/.bashrc
. ~/.bashrc
}

alp-sum() {

sum | sed 's/\ .*//';

} 

alias ƒ=dc-xf
alias Ï=dc-f
alias √=alp-edit
alias √∫=alp-edit-bashrc
alias Å=alias
alias ß=alp-sum
