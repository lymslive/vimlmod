" package: 
function! s:_package_() abort "{{{
    return s:
endfunction "}}}

let s:str = 'a string'
let s:num = 1

" new: 
function! s:new(s, n) abort "{{{
    let l:node = {}
    let l:node.str = a:s
    let l:node.num = a:n
    return l:node
endfunction "}}}
