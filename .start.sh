SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


for file in $SCRIPT_DIR/.start/*; do
  source $file
done