file_selector.vim
=================

シンプルで簡単に使えるファイルセレクターです。

Usage:
------

`buffer_selector#OpenFileSelector()` を、お好みのキーにマッピングしてください。

`file_selector#OpenFileSelector()` を実行すると、ファイル絞り込み用バッファーが開きます。
ファイル絞り込み用バッファーには、カレントディレクトリ以下のファイルを再帰的に取得した一覧が表示されます。


必要に応じて `g:file_selector_exclude_pattern` の設定を行ってください。
`g:file_selector_exclude_pattern` で指定したパターンが含まれる行は、ファイル一覧から除外されます。

文字を入力すると、ファイル絞り込み用バッファのファイル一覧が絞り込まれていきます。

ある程度絞り込まれたら、 ``<C-n>``, ``<C-p>`` でカーソルを上下に動かし、 ``<C-l>`` を押すことでカーソル上のファイルを開きます。

設定例 :

```vim
let g:file_selector_exclude_pattern = '\(bin\|build\|gradle\|config\)'
noremap <Leader>f <Esc>:call file_selector#OpenFileSelector()<Enter>
```


License:
--------

Copyright (C) 2017 mikoto2000

This software is released under the MIT License, see LICENSE

このソフトウェアは MIT ライセンスの下で公開されています。 LICENSE を参照してください。


Author:
-------

mikoto2000 <mikoto2000@gmail.com>
