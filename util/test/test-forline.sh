set -e
# set -x

source ../array-util.sh

function oper() {
    echo $1
}


forline test-forline.txt oper
