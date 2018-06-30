set -e
set -u
#set -x

source ../util.sh
source ../file-util.sh

touch myfile.txt
if [ -e "myfile.txt" ]; then
    echo "File myfile.txt exists"
else
    echo "File myfile.txt does not exist"
fi
trap_add "rm -f myfile.txt" EXIT


declare temp_file_name
create_temp_file temp_file_name
echo "temp_file_name=${temp_file_name}"
if [ -e "${temp_file_name}" ]; then
    echo "File ${temp_file_name} exists"
else
    echo "File ${temp_file_name} does not exist"
fi


declare temp_file_name2
create_temp_file temp_file_name2
echo "temp_file_name2=${temp_file_name2}"
if [ -e "${temp_file_name2}" ]; then
    echo "File ${temp_file_name2} exists"
else
    echo "File ${temp_file_name2} does not exist"
fi

declare my_temp_dir
create_temp_dir my_temp_dir
echo "my_temp_dir=${my_temp_dir}"
if [ -d "${my_temp_dir}" ]; then
    echo "Directory ${my_temp_dir} exists"
else
    echo "Directory ${my_temp_dir} does not exist"
fi



# end with different results and verify file does not exist

# exit with error condition
# exit 1

# exit with success condition
exit 0
