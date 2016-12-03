file_selector.vim
=================

シンプルで簡単に使えるファイルセレクターです。

Usage:
------

`buffer_selector#OpenFileSelector()` を、お好みのキーにマッピングしてください。

設定例 :

```vim
noremap <Leader>f <Esc>:call file_selector#OpenFileSelector()<Enter>
```

`file_selector#OpenFileSelector()` を実行すると、ファイル絞り込み用バッファーが開きます。
ファイル絞り込み用バッファーには、カレントディレクトリ以下のファイルを再帰的に取得した一覧が表示されます。

文字を入力すると、ファイル絞り込み用バッファのファイル一覧が絞り込まれていきます。

ある程度絞り込まれたら、 ``<C-n>``, ``<C-p>`` でカーソルを上下に動かし、 ``<C-l>`` を押すことでカーソル上のファイルを開きます。


License:
--------

Copyright (C) 2016 mikoto2000

This software is released under the MIT License, see LICENSE

このソフトウェアは MIT ライセンスの下で公開されています。 LICENSE を参照してください。


Author:
-------

mikoto2000 <mikoto2000@gmail.com>
