her.story () 
{ 
    : her story was always better than his.tory
    _HER_STORY=`history | tail -2 | head -1 | cut -c 8-`
    echo "$1 () { $_HER_STORY ; }"
           
}

