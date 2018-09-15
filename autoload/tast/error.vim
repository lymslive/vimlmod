" package: 
function! tast#error#package() abort "{{{
    return s:
endfunction "}}}
USE! package error

" ErrFun: 
function! ErrFun(...) abort "{{{
    echo 'before error'
    if a:0 > 0 && !empty(a:1)
        echoerr 'on error'
        return
    endif
    " real error syntax
    echo 'afer error'
    return 1
endfunction "}}}

function! s:first() abort "{{{
    echomsg 'in s:first()'
    call s:error('error in s:first()')
    call s:second()
endfunction "}}}

function! s:second() abort "{{{
    echomsg 'in s:second()'
    call s:error('error in s:second()')
    call s:third()
endfunction "}}}

function! s:third() abort "{{{
    echomsg 'in s:third()'
    call s:error('error in s:third()')
endfunction "}}}

call s:error('error in script error.vim')
call s:first()
