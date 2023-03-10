#!/bin/sh
set -eu

######################################################################
# 設定
######################################################################

print_usage_and_exit () {
  cat <<-USAGE 1>&2
	Usage   : ${0##*/} -n<繰り返し回数> [テキストファイル]
	Options :

	テキストを繰り返し出力する。

	-nオプションで繰り返し回数を指定できる。
	USAGE
  exit 1
}

######################################################################
# パラメータ
######################################################################

# 変数を初期化
opr=''
opt_n=''

# 引数をパース
i=1
for arg in ${1+"$@"}
do
  case "$arg" in
    -h|--help|--version) print_usage_and_exit ;;    
    -n*)                 opt_n=${arg#-n}      ;;
    *)
      if [ $i -eq $# ] && [ -z "$opr" ] ; then
        opr=$arg
      else
        echo "${0##*/}: invalid args" 1>&2
        exit 11
      fi
      ;;
  esac

  i=$((i + 1))
done

# 標準入力または読み取り可能な通常ファイルであるか判定
if   [ "_$opr" = '_' ] || [ "_$opr" = '_-' ]; then     
  opr=''
elif [ ! -f "$opr"   ] || [ ! -r "$opr"    ]; then
  echo "${0##*/}: \"$opr\" cannot be opened" 1>&2
  exit 21
else
  :
fi

# 有効な数値であるか判定
if ! printf '%s' "$opt_n" | grep -Eq '^[0-9]+$'; then
  echo "${0##*/}: \"$opt_n\" invalid number" 1>&2
  exit 31
fi

# パラメータを決定
text=$opr
nrep=$opt_n

######################################################################
# 本体処理
######################################################################

# コンテンツを入力
cat ${text:+"$text"}                                                 |

gawk '
BEGIN {
  nrep = '"${nrep}"';
}

{
  buf[NR] = $0;
}

END {
  for (i = 1; i <= nrep; i++) {
    for (j = 1; j <= NR; j++) {
      print buf[j];
    }
  }
}
'
