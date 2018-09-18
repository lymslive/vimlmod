let s:export = {}
function! s:hello() abort "{{{
    return 1
endfunction "}}}
function! s:hello2() abort "{{{
    return 2
endfunction "}}}
let s:export.hello = function('s:hello')
" s: function must define first before get it's funcref

" export by s: function
function! s:_export_() abort "{{{
    return s:export
endfunction "}}}

" YES, s:export can be variable and function at the same time
" echo s:export
" echo s:export()
