" =============================================================================
" Filename: autoload/calendar/day/germany.vim
" Author: itchyny
" License: MIT License
" Last Change: 2015/03/29 06:28:45.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:constructor = calendar#constructor#day_hybrid#new(1583, 1, 11)

function! calendar#day#germany#new(y, m, d) abort
  return s:constructor.new(a:y, a:m, a:d)
endfunction

function! calendar#day#germany#new_mjd(mjd) abort
  return s:constructor.new_mjd(a:mjd)
endfunction

function! calendar#day#germany#today() abort
  return s:constructor.today()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
