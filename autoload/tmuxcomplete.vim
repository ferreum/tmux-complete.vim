
function! tmuxcomplete#completions(base, flags)
    let script = s:create_script(
                \ '^' . escape(a:base, '*^$][.\') . '.',
                \ a:flags,
                \ get(g:, 'tmuxcomplete_list_args', '-a'),
                \ get(g:, 'tmuxcomplete_capture_args', '-J'),
                \ get(g:, 'tmuxcomplete_grep_args', ''),
                \ get(g:, 'tmuxcomplete_minlength', '4'))
    let completions = systemlist(script)
    if v:shell_error == 0 && type(completions) == type([])
        return completions
    else
        return []
    endif
endfunction

function! s:create_script(pattern, flags, list_args, capture_args, grep_args, minlen) abort
    let list_args = a:list_args . ' '
                \ . (a:flags =~# 'w' ? '' : get(g:, 'tmuxcomplete_list_select_args', '-a'))
    if a:flags =~# 'o'
        " list all panes
        let s = 'tmux list-panes ' . list_args . " -F '#{window_active}-#{session_id} #{pane_id}'"
        " filter out current pane (use -F to match $ in session id)
        let s .= ' | grep -v -F "$(tmux display-message -t "$TMUX_PANE" -p "1-#{session_id} ")"'
        " take the pane id
        let s .= " | cut -d' ' -f2"
    else
        " list all panes
        let s = 'tmux list-panes ' . list_args . " -F '#{pane_id}'"
        " exclude current pane
        let s .= ' | grep -v -F "$TMUX_PANE"'
    endif
    " capture panes
    let s .= printf(" | xargs -r -P0 -n1 tmux capture-pane %s -p -t", a:capture_args)
    " copy lines and split words
    let s .= " | sed -e 'p;s/[^a-zA-Z0-9_]/ /g'"
    " split on spaces
    let s .= " | tr -s '[:space:]' '\\n'"
    " remove surrounding non-word characters
    let s .= ' | grep -o "\\w.*\\w"'
    " filter out words not beginning with pattern
    let s .= printf(' | grep %s %s', a:grep_args, shellescape(a:pattern))
    " filter out short words
    let s .= printf(" | awk 'length($0) >= %d'", a:minlen)
    return s
endfunction

function! tmuxcomplete#complete(findstart, base)
    if a:findstart
        return tmuxcomplete#findstart()
    endif
    return tmuxcomplete#completions(a:base, '')
endfun

function! tmuxcomplete#findstart() abort
    let line = getline('.')
    let max = col('.') - 1
    let mode = get(g:, 'tmuxcomplete_mode', 'pattern')
    if mode ==# 'pattern'
        return s:findstart(line, max, get(g:, 'tmuxcomplete_match', '[[:alnum:]_]'))
    elseif mode ==# 'WORD'
        return s:findstartWORD(line, max)
    else
        throw "invalid complete mode"
    endif
endfunction

function! s:findstart(line, max, pat)
    let start = a:max
    " walk left upto first non word character
    while start > 0 && a:line[start - 1] =~ a:pat
        let start -= 1
    endwhile
    return start
endfunction

function! s:findstartWORD(line, max)
    " locate the start of the word
    let start = a:max
    " walk left upto first non WORD character
    while start > 0 && a:line[start - 1] =~ '\S'
        let start -= 1
    endwhile
    " walk right onto first word character
    while start < a:max && a:line[start] =~ '\H'
        let start += 1
    endwhile
    return start
endfunction
