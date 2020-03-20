un () 
{ 
    local __T="un"
    local _T=$1;
    shift;
    python3 ~/unspendable/unspendable.py $_T "$*"
}
