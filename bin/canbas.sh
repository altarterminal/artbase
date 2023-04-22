#!/bin/sh
set -eu

######################################################################
# 設定
######################################################################

print_usage_and_exit () {
  cat <<-USAGE 1>&2
	Usage   : ${0##*/} -r<行数> -c<列数>
	Options : -p<構成文字>

	文字を矩形状に並べて出力する。

	-rオプションで行数を指定する。
	-cオプションで列数を指定する。
	-pオプションで構成文字を指定できる。デフォルトは"□"。
	USAGE
  exit 1
}

######################################################################
# パラメータ
######################################################################

# 変数を初期化
opt_r=''
opt_c=''
opt_p='□'

# 引数をパース
i=1
for arg in ${1+"$@"}
do
  case "$arg" in
    -h|--help|--version) print_usage_and_exit ;;    
    -r*)                 opt_r=${arg#-r}      ;;
    -c*)                 opt_c=${arg#-c}      ;;
    -p*)                 opt_p=${arg#-p}      ;;
    *)
      echo "${0##*/}: invalid args" 1>&2
      exit 11
      ;;
  esac

  i=$((i + 1))
done

# 有効な数値であるか判定
if ! printf '%s\n' "$opt_r" | grep -Eq '^[0-9]+$'; then
  echo "${0##*/}: \"$opt_r\" invalid number" 1>&2
  exit 21
fi

# 有効な数値であるか判定
if ! printf '%s\n' "$opt_c" | grep -Eq '^[0-9]+$'; then
  echo "${0##*/}: \"$opt_c\" invalid number" 1>&2
  exit 31
fi

# 有効な１文字であるか判定
if ! printf '%s\n' "$opt_p" | grep -Eq '^.$'; then
  echo "${0##*/}: \"$opt_p\" invalid character" 1>&2
  exit 41
fi

# パラメータを決定
height=$opt_r
width=$opt_c
tchar=$opt_p

######################################################################
# 本体処理
######################################################################

gawk '
BEGIN {
  height = '"${height}"';
  width  = '"${width}"';
  tchar  = "'"${tchar}"'";

  for (i = 1; i <= height; i++) {
    for (j = 1; j <= width; j++) { printf "%s", tchar; }
    print "";
  }
}
'
