#!/bin/sh
set -eu

######################################################################
# help
#####################################################################

print_usage_and_exit () {
  cat <<-USAGE 1>&2
	Usage   : ${0##*/} <text file>
	Options : -n<repeat num>

	Output the text repeatedly.

	-n: Specify the number of repeat (default: 2).
	USAGE
  exit 1
}

#####################################################################
# parameter
#####################################################################

opr=''
opt_n='2'

i=1
for arg in ${1+"$@"}
do
  case "${arg}" in
    -h|--help|--version) print_usage_and_exit ;;
    -n*)                 opt_n="${arg#-n}"    ;;
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

if ! printf '%s\n' "${opt_n}" | grep -Eq '^[0-9]+$'; then
  echo "ERROR:${0##*/}: invalid number specified <${opt_n}>" 1>&2
  exit 1
fi

readonly TEXT_FILE="${opr}"
readonly REPEAT_NUM="${opt_n}"

#####################################################################
# main routine
#####################################################################

cat "${TEXT_FILE}"                                                  |

gawk '
BEGIN {
  REPEAT_NUM = '"${REPEAT_NUM}"';
}

{
  buf[NR] = $0;
}

END {
  for (i = 1; i <= REPEAT_NUM; i++) {
    for (j = 1; j <= NR; j++) { print buf[j]; }
  }
}
'
