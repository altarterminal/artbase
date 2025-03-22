#!/bin/sh
set -eu

######################################################################
# help
######################################################################

print_usage_and_exit () {
  cat <<-USAGE 1>&2
	Usage   : ${0##*/} -r<row num> -c<col num>
	Options : -p<character>

	Arrange characters in a rectangular shape and output them.

	-r: Specify the number of rows.
	-c: Specify the number of cols.
	-p: Specify the character (default "□").
	USAGE
  exit 1
}

#####################################################################
# parameter
#####################################################################

opt_r=''
opt_c=''
opt_p='□'

i=1
for arg in ${1+"$@"}
do
  case "${arg}" in
    -h|--help|--version) print_usage_and_exit ;;    
    -r*)                 opt_r="${arg#-r}"    ;;
    -c*)                 opt_c="${arg#-c}"    ;;
    -p*)                 opt_p="${arg#-p}"    ;;
    *)
      echo "ERROR:${0##*/}: invalid args" 1>&2
      exit 1
      ;;
  esac

  i=$((i + 1))
done

if ! printf '%s\n' "${opt_r}" | grep -Eq '^[0-9]+$'; then
  echo "ERROR:${0##*/}: invalid number specified <${opt_r}>" 1>&2
  exit 1
fi

if ! printf '%s\n' "${opt_c}" | grep -Eq '^[0-9]+$'; then
  echo "ERROR:${0##*/}: invalid number specified <${opt_c}>" 1>&2
  exit 1
fi

if ! printf '%s\n' "${opt_p}" | grep -Eq '^.$'; then
  echo "ERROR:${0##*/}: invalid character specified <${opt_p}>" 1>&2
  exit 1
fi

readonly HEIGHT="${opt_r}"
readonly WIDTH="${opt_c}"
readonly CHAR="${opt_p}"

######################################################################
# main routine
######################################################################

gawk '
BEGIN {
  height = '"${HEIGHT}"';
  width  = '"${WIDTH}"';

  char = "'"${CHAR}"'";

  for (i = 1; i <= height; i++) {
    for (j = 1; j <= width; j++) { printf "%s", char; }
    print "";
  }
}
'
