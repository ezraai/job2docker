set -e
#set -x

source ../string-util.sh

myvar="   hello world   "
trim myvar
echo "|${myvar}|"
