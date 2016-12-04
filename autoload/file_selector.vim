function file_selector#OpenFileSelector()
    " 呼び出し元のウィンドウ ID を記憶
    let s:caller_window_id = win_getid()

    " 検索文字初期化
    let s:pattern = ""

    " バッファ作成
    silent bo new __FILE_SELECTOR_FILE_LIST__

    """ キーマッピング
    " バッファ閉じる
    silent inoremap <buffer> q <Esc>:bwipeout!<Return>
    silent noremap <buffer> q <Esc>:bwipeout!<Return>

    " バッファ開く
    silent inoremap <buffer> <C-l> <Esc>:call file_selector#OpenBuffer()<Return>

    " パターン文字削除
    silent inoremap <buffer> <BS> <Esc>:call file_selector#DelChar()<Return>

    " 移動
    silent inoremap <buffer> <C-p> <Up>
    silent inoremap <buffer> <C-n> <Down>

    " バッファクリア
    silent % delete _

    " findgrep の結果をバッファに設定
    let s:all_file_list = glob("**/*", 1, 1)
    call setline(1, s:all_file_list)

    """ 検索モード設定
    " インサートモードにしたうえで、入力無効にする
    augroup insert_disable
        autocmd!
        autocmd InsertCharPre <buffer> call file_selector#AddChar()
        autocmd TextChangedI <buffer> call file_selector#UpdateBuffer()
    augroup END
    inoremap <buffer> <Enter> <nop>

    call file_selector#UpdateBuffer()

    startinsert
endfunction

function file_selector#UpdateBuffer()
    silent % delete _
    call setline(1, s:all_file_list)
    if (s:pattern != "")
        silent execute "v/" . s:pattern . "/d"
    endif
    normal gg
    echo "pattern: " . s:pattern
endfunction

function file_selector#AddChar()
    let s:pattern = s:pattern . v:char
endfunction

function file_selector#DelChar()
    let s:pattern = s:pattern[0:-2]
    call file_selector#UpdateBuffer()
    startinsert
endfunction

function file_selector#OpenBuffer()
    """ カーソル上のファイルパスを取得
    let target_file = getline(".")

    """ 呼び出し元ウィンドウをアクティブにする
    call win_gotoid(s:caller_window_id)

    """ ファイルを開く
    execute ":e " . target_file

    """ 絞り込み用バッファ削除
    bwipeout! __FILE_SELECTOR_FILE_LIST__
endfunction
