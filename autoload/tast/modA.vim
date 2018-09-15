" hello: 
function! s:hello(msg) abort "{{{
    echomsg 'Hello ModA:' a:msg
endfunction "}}}

let s:name = 'modA.vim'
call s:hello('in ModA')

" export: 
function! tast#modA#export() abort "{{{
    if !exists('s:_export')
        let s:_export = {}
        let s:_export.hello = function('s:hello')
    endif
    echo s:_export
    return s:_export
endfunction "}}}
