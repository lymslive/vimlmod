" export by #package
function! test#packB#package() abort "{{{
    return s:
endfunction "}}}

let s:EXPORT = {}
function! s:hello() abort "{{{
    return 1
endfunction "}}}
let s:EXPORT.hello = function('s:hello')
" s: function must define first before get it's funcref

let s:EXPORT.var = 1
