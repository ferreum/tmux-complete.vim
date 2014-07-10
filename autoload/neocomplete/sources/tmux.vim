" File:        tmux.vim
" Description: tmux
" Created:     2014-07-07
" Last Change: 2014-07-10

let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \ 'name' : 'tmux',
      \ 'kind' : 'manual',
      \ 'mark' : '[tmux]',
      \ 'volatile' : 0,
      \}

function! s:source.get_complete_position(context) abort
   return tmuxcomplete#findstart()
endfunction

function! s:source.gather_candidates(context) abort
   " BUG: need copy() here, otherwise map() cannot change the list
   if len(a:context.complete_str) >= get(g:, 'tmuxcomplete_complete_minlength', 2)
      return extend(
               \ map(copy(tmuxcomplete#completions(a:context.complete_str, 'w')), "{'rank' : 4, 'word' : v:val}"),
               \ map(copy(tmuxcomplete#completions(a:context.complete_str, 'o')), "{'rank' : 3, 'word' : v:val}"))
   else
      return []
   endif
endfunction

function! neocomplete#sources#tmux#define()
   return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set sw=3 ts=3 sts=0 et sta sr ft=vim fdm=marker:
