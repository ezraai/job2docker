myarray=( a b c )

echo "myarray=${myarray[@]}"
echo "myarray=${#myarray[@]}"

unset myarray[1]

echo "myarray=${myarray[@]}"
echo "myarray=${#myarray[@]}"

declare -A mydict
mydict=( [key1]=value1 [key2]=value2 [key3]=value3 )

echo "mydict=${mydict[@]}"
echo "mydict=${!mydict[@]}"
echo "mydict=${#mydict[@]}"

unset mydict[key2]

echo "mydict=${mydict[@]}"
echo "mydict=${!mydict[@]}"
echo "mydict=${#mydict[@]}"

