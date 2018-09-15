" export by s:package
function! s:package() abort "{{{
    return s:export
endfunction "}}}

let s:export = {}
function! s:hello() abort "{{{
    return 1
endfunction "}}}
let s:export.hello = function('s:hello')
" s: function must define first before get it's funcref

let s:var = 1

" private: 
function! s:private() abort "{{{
    return 1
endfunction "}}}
