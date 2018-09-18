" export by #package
function! test#packBs#package() abort "{{{
    return s:
endfunction "}}}

let s:EXPORT = ['hello']
function! s:hello() abort "{{{
    return 1
endfunction "}}}
