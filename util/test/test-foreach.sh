#set -x

source ../array-util.sh

function oper() {
    echo $1
}

myarr=( "a" "b" "c" )

foreach myarr oper

declare -A mydict=( [key1]=value1 [key2]=value2 [key3]=value3 )

foreach mydict oper
