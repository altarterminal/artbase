#!/bin/sh
set -eu

#####################################################################
# help
#####################################################################

print_usage_and_exit () {
  cat <<-USAGE 1>&2
	Usage   : ${0##*/} <text file>
	Options : -n<number seq> -s<character seq>

	Transform the brightness to character according to its value.

	-n: Specify the borders of brightness (default: "51,102,160,214").
	-s: Specify the display characters (default: "　,・,＋,※,■").
	USAGE
  exit 1
}

#####################################################################
# parameter
#####################################################################

opr=''
opt_n='51,102,160,214'
opt_s='　,・,＋,※,■'

i=1
for arg in ${1+"$@"}
do
  case "${arg}" in
    -h|--help|--version) print_usage_and_exit ;;
    -n*)                 opt_n="${arg#-n}"    ;;
    -s*)                 opt_s="${arg#-s}"    ;;
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

if ! printf '%s\n' "${opt_n}" | grep -Eq '^[0-9]+(,[0-9]+)*$'; then
  echo "ERROR:${0##*/}: invalid number sequence specified <${opt_n}>" 1>&2
  exit 1
fi

if ! printf '%s\n' "${opt_s}" | grep -Eq '^.(,.)*$'; then
  echo "ERROR:${0##*/}: invalid character sequence specified <${opt_s}>" 1>&2
  exit 1
fi

readonly TEXT_FILE="${opr}"
readonly NUM_SEQ="${opt_n}"
readonly CHAR_SEQ="${opt_s}"

#####################################################################
# main routine
#####################################################################

cat "${TEXT_FILE}"                                                  |

gawk '
BEGIN {
  num_seq  = "'"${NUM_SEQ}"'";
  char_seq = "'"${CHAR_SEQ}"'";

  max_num = 255;

  nn = split(num_seq, num_list, ",");
  cn = split(char_seq, char_list, ",");

  if (nn != (cn - 1)) {
    print "ERROR:'"${0##*/}"': invalid sequence length" >"/dev/stderr";
    exit 1;
  }

  for (i = 1; i <= (nn - 1); i++) {
    if (num_list[i] >= num_list[i+1]) {
      print "ERROR:'"${0##*/}"': invalid size relationship" >"/dev/stderr";
      exit 1;
    }
  }

  num_list[0]  = 1;
  num_list[cn] = 256;

  begin_idx = num_list[0]
  end_idx   = num_list[1];

  for (ci = 1; ci <= cn; ci++) {
    for (j = begin_idx; j < end_idx; j++) { c[j] = char_list[ci]; }

    begin_idx = num_list[ci];
    end_idx   = num_list[ci+1];
  }

  c[begin_idx] = char_list[cn]
}

{
  for (i = 1; i <= NF; i++) { printf "%s", c[$i]; }
  print "";
}
'
