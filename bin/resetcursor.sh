#!/bin/sh
set -eu

#####################################################################
# help
#####################################################################

print_usage_and_exit () {
  cat <<-USAGE 1>&2
	Usage   : ${0##*/} -r<row num> <text file>
	Options :

	Return the terminal cursor to the origin.

	-r: Specify the number of rows to reset cursor.
	USAGE
  exit 1
}

#####################################################################
# parameter
#####################################################################

opr=''
opt_r=''

i=1
for arg in ${1+"$@"}
do
  case "${arg}" in
    -h|--help|--version) print_usage_and_exit ;;    
    -r*)                 opt_r="${arg#-r}"    ;;
    *)
      if [ $i -eq $# ] && [ -z "${opr}" ]; then
        opr="${arg}"
      else
        echo "ERROR:${0##*/}: invalid args" 1>&2
        exit 1
      fi
      ;;
  esac

  i=$((i + 1))
done

if   [ "${opr}" = '' ] || [ "${opr}" = '-' ]; then
  opr='-'
elif [ ! -f "${opr}" ] || [ ! -r "${opr}"  ]; then
  echo "ERROR:${0##*/}: invalid file specified <${opr}>" 1>&2
  exit 1
else
  :
fi

if ! printf '%s\n' "${opt_r}" | grep -Eq '^[0-9]+$'; then
  echo "${0##*/}: invalid number specified <${opt_r}>" 1>&2
  exit 1
fi

readonly TEXT_FILE="${opr}"
readonly HEIGHT="${opt_r}"

#####################################################################
# main routine
#####################################################################

cat "${TEXT_FILE}"                                                  |

gawk '
BEGIN {
  height = '"${HEIGHT}"';

  row_cnt = 0;
}

{
  print;

  row_cnt++;
  if (row_cnt >= height) {
    printf "\033[1;1H";
    row_cnt = 0;
  }
}
'
