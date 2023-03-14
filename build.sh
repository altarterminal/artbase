#!/bin/sh
set -eu

######################################################################
# 設定
######################################################################

######################################################################
# 本体処理
######################################################################

# ビルドを実行
(
  cd ./src/linevalve

  cargo build --release
)

# バイナリを配置
mv ./src/linevalve/target/release/linevalve ./bin
