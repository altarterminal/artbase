#!/bin/sh
set -eu

######################################################################
# 設定
######################################################################

print_usage_and_exit () {
  cat <<-USAGE 1>&2
	Usage   : ${0##*/} [輝度値ファイル]
	Options : -n<数列> -s<文字列>

	輝度値をアスキーアート文字に変換する。

	-nオプションで輝度値の境界を指定できる。数字は","で区切る。デフォルトは"51,102,160,214"。
	-sオプションで表示文字を指定できる。文字は","で区切る。デフォルトは"　,・,＋,※,■"。
	USAGE
  exit 1
}

######################################################################
# パラメータ
######################################################################

# 変数を初期化
opr=''
opt_n='51,102,160,214'
opt_s='　,・,＋,※,■'

# 引数をパース
i=1
for arg in ${1+"$@"}
do
  case "$arg" in
    -h|--help|--version) print_usage_and_exit ;;
    -n*)                 opt_n=${arg#-n}      ;;
    -s*)                 opt_s=${arg#-s}      ;;
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

# 有効な数列であるか判定
if ! printf '%s' "$opt_n" | grep -Eq '^[0-9]+(,[0-9]+)*$'; then
  echo "${0##*/}: \"$opt_n\" invalid number sequence" 1>&2
  exit 31
fi

# 有効な文字列であるか判定
if ! printf '%s' "$opt_s" | grep -Eq '^.(,.)*$'; then
  echo "${0##*/}: \"$opt_s\" invalid character sequence" 1>&2
  exit 41
fi

# パラメータを決定
bright=$opr
nums=$opt_n
chas=$opt_s

######################################################################
# 本体処理
######################################################################

gawk '
BEGIN {
  # パラメータを設定
  nums = "'"${nums}"'";
  chas = "'"${chas}"'";

  # 数列と文字列を配列に分離
  nn = split(nums, nary, ",");
  cn = split(chas, cary, ",");

  # 数字と文字の数に不整合があればエラーを出力して終了
  if (nn != (cn - 1)) {
     print "'"${0##*/}"': invalid sequence length" > "/dev/stderr";
     exit 51;
  }

  # 数列の大小関係に不整合があればエラーを出力して終了
  for (i = 1; i <= (nn-1); i++) {
    if (nary[i] >= nary[i+1]) {
      print "'"${0##*/}"': invalid number sequence" > "/dev/stderr";
      exit 52;
    }
  }
}

{
  for (i = 1; i <= NF; i++) {
    # 最後尾以外の区間に含まれる場合にこのコードで捕捉
    for (j = 1; j <= nn; j++) {
      if ($i <= nary[j]) { printf "%s", cary[j]; break; }
    }

    # 最後尾の区間に含まれる場合はこのコードで捕捉
    if (j == (nn+1)) { printf "%s", cary[j]; }
  }

  print "";
}
' ${bright-:"$bright"}
