" Name:    longline.vim
" Version: 0.1.0
" Author:  Markus Braun <markus.braun@krawel.de>
" Summary: Vim plugin to highlight too long lines
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt
"
" Section: Documentation {{{1
"
" Description: {{{2
"
"   This plugin highlights too long lines where the length exceeds the setting
"   of textwidth.
"
" Installation: {{{2
"
"   Copy the longline.vim file to the $HOME/.vim/plugin directory.
"   Refer to ':help add-plugin', ':help add-global-plugin' and ':help
"   runtimepath' for more details about Vim plugins.
"
"   To show data about long lines in the status line add something like
"   this to your .vimrc (beware this can be very slow for long files):
"
"     set statusline+=%([%{LongLinesStatusline()}]%)
"
" Commands: {{{2
"
"   :LongLinesToggle
"      Toggle long line highlighting in the current window.
"
"   :LongLinesGlobalToggle
"      Toggle long line highlighting globally.
"
" Mappings: {{{2
"
"   <Leader>ll     LongLinesToggle()
"   <Leader>lg     LongLinesGlobalToggle()
"
" Variables: {{{2
"
"   g:longlines_enabled
"     Enabled the highlighting globally. Default 1.
"
"   g:longlines_margin
"     width of the warning highlight. Default 10.
"
" Section: Plugin header {{{1

" guard against multiple loads {{{2
if (exists("g:loaded_longline") || &cp)
  finish
endif
let g:loaded_longline = 1

" check for correct vim version {{{2
" matchadd() requires at least 7.1.40
if !(v:version > 701 || (v:version == 701 && has("patch040")))
  finish
endif

" define default "longlines_enabled" {{{2
if (!exists("g:longlines_enabled"))
  let g:longlines_enabled = 1
endif

" define default "longlines_margin" {{{2
if (!exists("g:longlines_margin"))
  let g:longlines_margin = 10
endif

" define default "longlines_debug" {{{2
if (!exists("g:longlines_debug"))
  let g:longlines_debug = 0
endif

" Section: Autocmd setup {{{1
if has("autocmd")
  augroup longlines
    autocmd!

    " to handle the case, when textwidth is modified in a displayed window
    autocmd CursorMoved,CursorMovedI * call <SID>LongLines()
  augroup END
endif

" Section: Highlight setup {{{1
highlight default link LongLinesWarning Todo
highlight default link LongLinesError Error

" Section: Functions {{{1

" Function: s:LongLines() {{{2
"
" highlight the too long lines, if requested
"
function! s:LongLines()
  if has("syntax")
    if !exists("w:LongLinesIds")
      let w:LongLinesIds = []
    endif
    if !exists("w:longlines_enabled")
      let w:longlines_enabled = 1
    endif
    if &textwidth > 0 && g:longlines_enabled != 0 && w:longlines_enabled != 0
      if len(w:LongLinesIds) == 0
        let w:LongLinesIds += [ matchadd('LongLinesWarning',  '\%>' . &textwidth . 'v.*\%<' . (&textwidth + g:longlines_margin + 1) . 'v') ]
        let w:LongLinesIds += [ matchadd('LongLinesError',    '\%>' . (&textwidth + g:longlines_margin) . 'v.*') ]
      endif
    else
      if len(w:LongLinesIds) != 0
        for id in w:LongLinesIds
          call matchdelete(id)
        endfor
        let w:LongLinesIds = []
      endif
    endif
  endif
endfunction

" Function: s:LongLinesToggle() {{{2
"
" toggle on/off the highlighting
"
function! s:LongLinesToggle()
  if !exists("w:longlines_enabled")
    let w:longlines_enabled = 1
  else
    let w:longlines_enabled = !w:longlines_enabled
  endif

  call s:LongLines()
endfunction

" Function: s:LongLinesGlobalToggle() {{{2
"
" globally toggle on/off the highlighting
"
function! s:LongLinesGlobalToggle()
  let g:longlines_enabled = !g:longlines_enabled

  call s:LongLines()
endfunction

" Function: LongLinesEnabled() {{{2
"
" return if highlighting of too long lines is enabled
"
function! LongLinesEnabled()
  return (g:longlines_enabled && w:longlines_enabled)
endfunction

" Function: LongLinesStatusline() {{{2
"
" return a string for inclusion in status line with data about long lines
"
" return '' if no long lines
" return '#x,$y if long lines are found, were x is the number of long lines
" and y is the length of the longest line
"
function! LongLinesStatusline()
  let l:statusline = ""

  let l:longlines_list = []

  if &textwidth > 0
    let l:line = 1
    while l:line <= line("$")
      let l:len = virtcol([ l:line, "$", 0 ]) - 1
      if l:len > &textwidth
        let l:longlines_list += [ l:len ]
      endif
      let l:line += 1
    endwhile
  endif

  if len(l:longlines_list) > 0
    let l:statusline = '#' . len(l:longlines_list) . " " . '$' . max(l:longlines_list)
  endif

  return l:statusline
endfunction

" Function: s:LongLinesDebug(level, text) {{{2
"
" output debug message, if this message has high enough importance
"
function! s:LongLinesDebug(level, text)
  if (g:longlines_debug >= a:level)
    echom "longlines: " . a:text
  endif
endfunction

" Section: Commands {{{1

command! LongLinesToggle call s:LongLinesToggle()
command! LongLinesGlobalToggle call s:LongLinesGlobalToggle()

" Section: Mappings {{{1

map <Leader>ll :LongLinesToggle<CR>
map <Leader>lg :LongLinesGlobalToggle<CR>

" Section: Menu {{{1

if has("menu")
  amenu <silent> Plugin.LongLines.Toggle :LongLinesToggle<CR>
  amenu <silent> Plugin.LongLines.GlobalToggle :LongLinesGlobalToggle<CR>
endif

" vim600: foldmethod=marker foldlevel=0 :
