" File:        tmux.vim
" Description: tmux
" Created:     2014-07-07
" Last Change: 2014-07-23

let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \ 'name' : 'tmux',
      \ 'kind' : 'manual',
      \ 'mark' : '[tmux]',
      \}

function! s:source.get_complete_position(context) abort
   return tmuxcomplete#findstart()
endfunction

function! s:source.gather_candidates(context) abort
   if len(a:context.complete_str) >= get(g:, 'tmuxcomplete_complete_minlength', 2)
      return extend(
               \ tmuxcomplete#completionsdicts(a:context.complete_str, 'w', 4),
               \ tmuxcomplete#completionsdicts(a:context.complete_str, 'o', 3))
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
