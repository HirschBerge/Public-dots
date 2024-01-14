"=============================================================================
" utils.vim --- utils function for neoformat
" Copyright (c) 2016-2023 Wang Shidong & Contributors
" Author: Wang Shidong < wsdjeg@outlook.com >
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================


let s:LOGGER =SpaceVim#logger#derive('neoformat')

function! neoformat#utils#log(msg) abort
    call s:LOGGER.info(a:msg)
endfunction

function! neoformat#utils#log_file_content(path) abort
    if neoformat#utils#should_be_verbose()
        return s:better_echo(readfile(a:path))
    endif
endfunction

function! neoformat#utils#warn(msg) abort
    call s:LOGGER.warn(a:msg)
endfunction

function! neoformat#utils#msg(msg) abort
    if exists('g:neoformat_only_msg_on_error') && g:neoformat_only_msg_on_error
        return
    endif
    return s:better_echo(a:msg)
endfunction

function! neoformat#utils#should_be_verbose() abort
    if !exists('g:neoformat_verbose')
        let g:neoformat_verbose = 0
    endif
    return &verbose || g:neoformat_verbose
endfunction

function! s:better_echo(msg) abort
    if type(a:msg) != type('')
        echom 'Neoformat: ' . string(a:msg)
    else
        echom 'Neoformat: ' . a:msg
    endif
endfunction

function! neoformat#utils#var(name) abort
    return neoformat#utils#var_default(a:name, 0)
endfunction

function! neoformat#utils#var_default(name, default) abort
    if exists('b:' . a:name)
        return get(b:, a:name)
    endif

    return get(g:, a:name, a:default)
endfunction
