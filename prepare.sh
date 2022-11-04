#!/bin/bash

FILE_NAME="articles/20221104_professional-cloud-security-engineer.md"
IMAGE_DIR="/images/20221104_professional-cloud-security-engineer"

# 画像ファイルのファイル名の空白を変換
find $IMAGE_DIR -name "* *" | rename "s/ //g"

# .mdファイルの画像参照のパスをエディタで一括変換

# %20を削除
sed -i -e 's/%20//g' $FILE_NAME

# スペースだけの行を削除
sed -i -e 's/^\s*$//g' $FILE_NAME

# リストを見出しに変換(optional)
# sed -i -e 's/^- /# /g' $FILE_NAME
# 戻す場合
# sed -i -e 's/^## /- /g' $FILE_NAME



# 見出し変更
# from - VPCとは？
# to   - # VPCとは？
# sed -i -e 's/^- /- # /g' $FILE_NAME


# other
# プレビューで*を検索して修正→太字はできるだけ使わない方が楽。
# 画像を3MB以下にサイズ変更


