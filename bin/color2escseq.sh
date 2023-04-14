#!/bin/sh
set -eu

######################################################################
# 設定
######################################################################

print_usage_and_exit () {
  cat <<-USAGE 1>&2
	Usage   : ${0##*/} [カラーファイル]
	Options : -c

	全角大文字アルファベットで指定した色をエスケープシーケンスによるカラー出力に変換する。

	-cオプションで出力できる色を確認できる（他に処理をせずに終了）。
	USAGE
  exit 1
}

######################################################################
# パラメータ
######################################################################

# 変数を初期化
opr=''
opt_c='no'

# 引数をパース
i=1
for arg in ${1+"$@"}
do
  case "$arg" in
    -h|--help|--version) print_usage_and_exit ;;
    -c)                  opt_c='yes'          ;;
    *)
      if [ $i -eq $# ] && [ -z "$opr" ]; then
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

# パラメータを決定
content=$opr
ischeck=$opt_c

######################################################################
# 本体処理
######################################################################

if [ "$ischeck" = 'yes' ]; then
  # カラーチェックの場合は標準入力や入力ファイルを無視
  echo 'this is dummy'
else  
  # コンテンツを入力
  cat ${content:+"$content"}
fi                                                                   |

gawk -v FS='' -v OFS='' '
BEGIN {
  # 表示文字
  c   = "■"
  fmt = "\033[38;5;%dm%c\033[0m";

  # オプション
  ischeck = "'"${ischeck}"'";

  # インデックスは全角なので注意
  t["Ｒ"] = sprintf(fmt, 0x09, c); # 赤
  t["Ｏ"] = sprintf(fmt, 0xD0, c); # 橙
  t["Ｙ"] = sprintf(fmt, 0xE2, c); # 黄
  t["Ｚ"] = sprintf(fmt, 0x0B, c); # 黄緑
  t["Ｇ"] = sprintf(fmt, 0x0A, c); # 緑
  t["Ｈ"] = sprintf(fmt, 0x30, c); # 青緑
  t["Ｃ"] = sprintf(fmt, 0x0E, c); # 緑みの青
  t["Ｂ"] = sprintf(fmt, 0x21, c); # 青
  t["Ｑ"] = sprintf(fmt, 0x1B, c); # 青紫
  t["Ｐ"] = sprintf(fmt, 0x0C, c); # 紫
  t["Ｓ"] = sprintf(fmt, 0x81, c); # 赤紫
  t["Ｍ"] = sprintf(fmt, 0x0D, c); # マゼンタ
  t["Ｗ"] = sprintf(fmt, 0x0F, c); # 白
  t["Ｋ"] = sprintf(fmt, 0x00, c); # 黒
  t["Ａ"] = sprintf(fmt, 0xF2, c); # 灰

  # カスタム色
  t["Ｄ"] = sprintf(fmt, 0x15, c); # 濃い青
  t["Ｉ"] = sprintf(fmt, 0x16, c); # 濃い緑
  t["Ｔ"] = sprintf(fmt, 0x5F, c); # 薄い茶
  t["Ｕ"] = sprintf(fmt, 0x34, c); # 濃い茶
  t["Ｘ"] = sprintf(fmt, 0x5E, c); # 木

  if (ischeck == "yes") {
    # 出力色の確認用  
    printf "%s: %s\n", "Ｒ", t["Ｒ"];
    printf "%s: %s\n", "Ｏ", t["Ｏ"];
    printf "%s: %s\n", "Ｙ", t["Ｙ"];
    printf "%s: %s\n", "Ｚ", t["Ｚ"];
    printf "%s: %s\n", "Ｇ", t["Ｇ"];
    printf "%s: %s\n", "Ｈ", t["Ｈ"];
    printf "%s: %s\n", "Ｃ", t["Ｃ"];
    printf "%s: %s\n", "Ｂ", t["Ｂ"];
    printf "%s: %s\n", "Ｑ", t["Ｑ"];
    printf "%s: %s\n", "Ｐ", t["Ｐ"];
    printf "%s: %s\n", "Ｓ", t["Ｓ"];
    printf "%s: %s\n", "Ｍ", t["Ｍ"];
    printf "%s: %s\n", "Ｗ", t["Ｗ"];
    printf "%s: %s\n", "Ｋ", t["Ｋ"];
    printf "%s: %s\n", "Ａ", t["Ａ"];

    printf "%s: %s\n", "Ｄ", t["Ｄ"];
    printf "%s: %s\n", "Ｉ", t["Ｉ"];
    printf "%s: %s\n", "Ｔ", t["Ｔ"];
    printf "%s: %s\n", "Ｕ", t["Ｕ"];
    printf "%s: %s\n", "Ｘ", t["Ｘ"];

    exit;
  }
}

{
  for (i = 1; i <= NF; i++) { $i = t[$i]; }
  print;
}
'
