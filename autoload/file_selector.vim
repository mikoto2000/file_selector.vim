function file_selector#OpenFileSelector()
    " 呼び出し元のウィンドウ ID を記憶
    let s:caller_window_id = win_getid()

    " バッファ作成
    silent bo new __FILE_SELECTOR_FILE_LIST__

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
    silent inoremap <buffer> q <Esc>:bwipeout!<Return>
    silent noremap <buffer> q <Esc>:bwipeout!<Return>

    " バッファ開く
    silent inoremap <buffer> <C-l> <Esc>:call file_selector#OpenBuffer()<Return>

    " パターン文字削除
    silent inoremap <buffer> <BS> <Esc>:call file_selector#DelChar()<Return>

    " 移動
    silent inoremap <buffer> <C-p> <Up>
    silent inoremap <buffer> <C-n> <Down>

    " 絞り込み用バッファ初期化
    silent % delete _
    silent call setline(1, "pattern > ")

    " findgrep の結果を取得
    let s:all_file_list = glob("**/*", 1, 1)

    """ 検索モード設定
    " インサートモードにしたうえで、入力無効にする
    set insertmode
    augroup insert_disable
        autocmd!
        autocmd InsertCharPre <buffer> call file_selector#AddChar()
        autocmd TextChangedI <buffer> call file_selector#UpdateBuffer()
        autocmd BufEnter <buffer> set insertmode
        autocmd BufLeave <buffer> set noinsertmode
    augroup END
    inoremap <buffer> <Enter> <nop>

    call file_selector#UpdateBuffer()
endfunction

function file_selector#UpdateBuffer()
    " 先頭行(プロンプト) を split して入力された pattern を取得する
    let first_line = getline(1)
    let splited_line = split(first_line, "pattern > ", 1)
    let pattern = get(splited_line, 1)

    " <BS> で消しすぎると、split で要素が取得できなくなる
    " その場合、 pattern は空文字とする
    if (pattern is 0)
        let pattern = ""
    endif

    silent % delete _
    call setline(1, s:all_file_list)
    if (pattern != "")
        silent execute "v/" . pattern . "/d"
    endif
    call append(0, "pattern > " . pattern)
    call cursor(1,0)
    startinsert!
endfunction

""" 何かを入力しようとしたら、必ずプロンプトの末尾に文字が追加されるようにする
function file_selector#AddChar()
    call cursor(1,0)
    startinsert!
endfunction

""" プロンプト末尾の文字を削除
function file_selector#DelChar()
    call cursor(1,0)
    normal $x
    call file_selector#UpdateBuffer()
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
