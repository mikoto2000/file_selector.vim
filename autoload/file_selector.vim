let g:file_selector_exclude_pattern = get(g:, 'file_selector_exclude_pattern', '')

function file_selector#OpenFileSelector()
    " 呼び出し元のウィンドウ ID を記憶
    let s:caller_window_id = win_getid()

    " 検索文字初期化
    let s:pattern = ""

    " バッファ作成
    silent bo new __FILE_SELECTOR_FILE_LIST__

    """ 絞り込み用バッファの設定
    setlocal noshowcmd
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal nobuflisted
    setlocal nowrap
    setlocal nonumber

    " カーソル設定保存
    redir => cursor_highlight_line
    silent highlight Cursor
    redir END
    let s:cursor_highlight = get(split(cursor_highlight_line, "xxx "), 1)
    let s:cursorcolumn=&cursorcolumn
    let s:cursorline=&cursorline
    let s:guicursor=&guicursor

    " カーソル復元用 autocmd
    augroup file_selector
        autocmd!
        autocmd BufLeave <buffer> execute "highlight Cursor " . s:cursor_highlight
        autocmd BufLeave <buffer> execute "set guicursor=" . s:guicursor
        autocmd BufLeave <buffer> let &cursorcolumn = s:cursorcolumn
        autocmd BufLeave <buffer> let &cursorline = s:cursorline
    augroup END

    " カーソル設定
    highlight Cursor gui=NONE guifg=NONE guibg=NONE guisp=NONE
    set guicursor=i:iCursor
    set nocursorcolumn
    set cursorline

    " カーソルを消す
    set filetype=file_selector

    """ キーマッピング
    " バッファ閉じる
    silent inoremap <silent> <buffer> q <Esc>:bwipeout!<Return>
    silent noremap <silent> <buffer> q <Esc>:bwipeout!<Return>

    " バッファ開く
    silent inoremap <silent> <buffer> <C-l> <Esc>:call file_selector#OpenBuffer()<Return>

    " パターン文字削除
    silent inoremap <silent> <buffer> <BS> <Esc>:call file_selector#DelChar()<Return>

    " 移動
    silent inoremap <buffer> <C-p> <Up>
    silent inoremap <buffer> <C-n> <Down>

    " 絞り込み用バッファ初期化
    silent % delete _

    " findgrep の結果を取得
    let s:all_file_list = glob("**/*", 1, 1)

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

    " exclude_pattern の除外
    if (g:file_selector_exclude_pattern != "")
        silent execute "g/" . g:file_selector_exclude_pattern . "/d"
    endif

    " pattern の抽出
    if (s:pattern != "")
        silent execute "v/" . s:pattern . "/d"
    endif
    normal gg
    echo "pattern > " . s:pattern
endfunction

""" 何かを入力しようとしたら、必ずプロンプトの末尾に文字が追加されるようにする
function file_selector#AddChar()
    let s:pattern = s:pattern . v:char
endfunction

""" プロンプト末尾の文字を削除
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
