---
title: "makefileのハマりポイント"
emoji: "🦔"
type: "tech"
topics:
  - "makefile"
published: true
---

# はじめに

## make とは？

UNIX シェルコマンドのジェネレータ。ビルドツールとして C/C++の開発でよく使う。makefile にはターゲット(主にビルドターゲットファイル)を依存関係付きで定義でき、コマンド実行時に make がファイルシステムのタイムスタンプから、再コンパイルが必要なターゲットを認識、必要なコマンドだけ生成して実行してくれる。ビルドターゲットには最終的な実行形式のファイル名や.o などの中間ファイル名を指定する。

Python で使う場合、タスクランナーとして使う場合がほとんどと思う。ターゲットはファイル名でなく、適当な名前をつけてダミーターゲットとし、依存関係のあるダミーターゲットを実行するコマンドを生成してくれる。

:::message

ダミーターゲット名のファイルが存在すると、make は実行をスキップするので、`.PHONY` ターゲットとして明示してスキップを回避する。

:::

## makefile のマクロ変数

makefile 内で使われる変数にはいくつか種類があり、以下のような優先順位がある。

マクロ変数参照の優先順位(高い順)

1. 実行時に渡す変数
2. makefile 内で定義されたマクロ変数
3. 環境変数
4. make の定義済みのデフォルトマクロ

※ make -e オプションで起動すると 2 と 3 が逆転する

# ハマりポイント１：makefile 内で定義するマクロ変数

上記「2. makefile 内で定義されたマクロ変数」に関して、マクロ変数の定義は makefile 内で上から順になされるが、定義方法により評価値が異なるため注意が必要。

- Simple assignment `:=`
  マクロ変数の最後の定義時の値を評価。
  同じマクロ変数に複数回割り当てた場合、makefile で下の方に書いた値に評価される。

  ```makefile
  X := first # 1回目定義
  Y := ${X} # 1回目定義
  X := second # 2回目定義

  target:
  	@echo ${X} # second (最終定義値)
  	@echo ${Y} # first (最終定義値)
  ```

  :::message
  Simple assignment での変数定義が多くなると make コマンドのタブ補完が遅くなっていく。。タブ補完するときにも毎回変数の割り当てがされるぽい。以下の Recursive assignment と Conditional assignment では、そのような挙動にはならなかった。
  :::

- Recursive assignment `=`

  マクロ変数の参照時に値を評価。

  ```makefile
  X = first
  Y = ${X}
  X = second

  target:
  	@echo ${X} # second (参照時の評価値)
  	@echo ${Y} # second (参照時の評価値)
  ```

- Conditional assignment `?=`
  マクロ変数の最初の定義時の値を評価。

  ```makefile
  X ?= first # 1回目定義
  Y ?= ${X} # 1回目定義
  X ?= second # 2回目定義

  target:
  	@echo ${X} # first (一回目定義値)
  	@echo ${Y} # first (一回目定義値)
  ```

# ハマりポイント２：make ターゲットのシェルコマンド実行

make はターゲットのコマンド行の各行を、ぞれぞれ別のシェルに渡して実行させる。上から順番にコマンド実行し、各シェルでの完了を待ってから次のコマンドへ移る。ただし、バックグラウンドプロセスとして起動するコマンドの場合は、すぐに次のコマンドへ移る。同じシェルでシェルコマンドを逐次処理させたい場合は注意が必要。また、マクロ変数とシェル変数の参照の仕方にも気を付けるポイントがある。

:::message

make が実行するコマンドから 0 以外の(エラー)終了コードが返ってきた場合、make は構築途中のターゲットを全て消去して終了する。-i オプションをつけるか、.IGNORE: ターゲットを記述するか、コマンドの前にハイフン-をつけることで、エラー時も無視して処理を継続する。

:::

- 改行がある場合の振る舞い
  以下は改行されているので、make は各行ごとにシェルを起動する。意図した結果にはならない。
  ```makefile
  cd dir;
  rm *
  ```
  同じシェルで実行するには、一行で書くかセミコロンとバックスラッシュで改行を解釈することを防ぐ。make が複数行を有効なコマンドとしてまとめて、一度にシェルに渡せるようにする。
  一行で書くか
  ```makefile
  target:
  	cd dir; rm *
  ```
  バックスラッシュで複数行をまとめて書く
  ```makefile
  target:
  	cd dir;  \
  	rm *
  ```
  複数行のシェルプログラムを書く
  ```makefile
  target:
  	if \
  		condition; \
  	then \
  		command1; \
  		command2; \
  	else \
  		command1; \
  		command2; \
  	fi
  ```
- シェルコマンド内での変数参照は`$$`と`$`の違いに注意
  マクロ変数の参照は`${}`で、シェル変数の参照は`$${}`で参照する。`$`はエスケープ文字のように使われ、最初の`$`は make がマクロ参照のために取り除き、`${}`がシェルに渡される。コマンド内で正規表現の`$`を使うときにも、`$$`とする必要がある

  ```makefile
  FILE1 := foo.txt
  FILE2 := bar.txt

  echo:
  	@echo ${FILE1} # foo.txt
  	@echo ${FILE2} # bar.txt

  log:
  	for i in ${FILE1} ${FILE2}; do \
  		cat $$i ; \
  		grep -e ".*pattern$$" $$i >> logfile; \
  		rm $$i; \
  	done

  ```

# ハマりポイント３：makefile で条件分岐する

makefile で条件分岐をしようとしたときに手間取ったのでメモ。例として、gcloud コマンドで GCP のリソースの存在の有無を確認し、その結果で分岐させて異なるコマンドを実行したときの注意点を列挙。

- 注意点 1
  `ifdef`, `ifndef`といった make の条件分岐ディレクティブを使う場合、最低限の機能しかなく複数条件とか大小比較とかが面倒。。

  ⇒ シェルコマンド内で test コマンドで分岐させた方が楽

  ```makefile
  NAME:= # GCP resource name
  COUNT=$(shell gcloud command get ${NAME} --format="value(name)" --filter="name ~ ^.*${NAME}$$" | wc -l) # resource count

  target:
  ifndef NAME
  	$(error argument expected)
  endif
  	@if [ ${COUNT} -eq 0 ]; then \
  		gcloud create ...;
  	elif [ ${COUNT} -gt 0 ]; then \
  		gcloud update ...;
  	else \
  		echo no resources found!!; \
  	fi
  ```

- 注意点 2
  分岐処理の中で共通部分を関数呼び出しにしたい。上の例では gcloud コマンドの create or update 以下は同じなので、関数の呼び出しにして処理をまとめたい。

  ⇒ 再帰 make かマクロで解決
  make では、実行時に渡す変数が最も優先順位が高いので、makefile 内や環境変数で定義した変数を上書きして実行したい場合などはこちらが向いている。

  ```makefile
  NAME:= # GCP resource name
  COUNT=$(shell gcloud command get ${NAME} --format="value(name)" --filter="name ~ ^.*${NAME}$$" | wc -l) # resource count

  target:
  ifndef NAME
  	$(error argument expected)
  endif
  	@if [ ${COUNT} -eq 0 ]; then \
  		echo create resource!!; \
  		${MAKE} target2 "param=create"; \
  	elif [ ${COUNT} -gt 0 ]; then \
  		echo update resource!!; \
  		${MAKE} target2 "param=update"; \
  	else \
  		echo no resources found!!; \
  	fi

  target2:
  	gcloud command ${param} \
  	--option ... \
  	--option ... \
  	...
  ```

  マクロを`define`,`call`して呼び出す方法でも出来る。

  ```makefile
  NAME:= # GCP resource name
  COUNT=$(shell gcloud command get ${NAME} --format="value(name)" --filter="name ~ ^.*${NAME}$$" | wc -l) # resource count

  target:
  ifndef NAME
  	$(error argument expected)
  endif
  	@if [ ${COUNT} -eq 0 ]; then \
  		echo create resource!!; \
  		$(call func,create) \
  	elif [ ${COUNT} -gt 0 ]; then \
  		echo update resource!!; \
  		$(call func,update) \
  	else \
  		echo no resources found!!; \
  	fi

  define func:
  	gcloud command $1 \
  	--option ... \
  	--option ... \
  	...
  ```

  :::message
  マクロの呼び出しで、`$(call func,param);`のように、セミコロン`;`をつけると上手くいかなかった。この場合は`;`は不要らしい。
  :::

- 注意点 3
  gcloud コマンド等の出力結果をマクロ変数に代入する場合、代入する変数の数が多くなると make を起動するときにタブ補完が遅くなる。この原因は「ハマりポイント１：makefile 内で定義するマクロ変数」で書いた変数定義の種類の問題で、Simple assignment を多用すると、どうもタブ補完が遅くなる。

  ⇒ Recursive assignment にすることで、問題は解消。コマンド実行時に変数を評価してくれるためと思われる。

  ※ もしくは make のマクロ変数ではなく、以下のようにシェルコマンド内で eval でシェル変数に割り当ててもいいが、ちょっと見にくくなる。。

  ```makefile
  NAME:= # GCP resource name

  target:
  ifndef NAME
  	$(error argument expected)
  endif
  	$(eval COUNT:=$(shell gcloud command get ${NAME} --format="value(name)" --filter="name ~ ^.*${NAME}$$" | wc -l))
  	@if [ ${COUNT} ... ] ; ...
  ```
