un () 
{ 
    local __T="un"
    local _ARG1=$1;
    shift;
    python3 $_ALP_DIR/unspendable/unspendable.py $_ARG1 "$*"
}
d () 
{ 
    un DCx "$*"
}
s () 
{ 
    un 9s "$*"
}
t () 
{ 
    un 9t "$*"
}
dc.list.receivedbyaddress () 
{ 
    dogecoin-cli listreceivedbyaddress
}
