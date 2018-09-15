let s:export = {}
function! s:hello() abort "{{{
    return 1
endfunction "}}}
let s:export.hello = function('s:hello')
" s: function must define first before get it's funcref

" export by # function
function! test#packA#export() abort "{{{
    return s:export
endfunction "}}}
