" File: ulib
" Author: lymslive
" Description: test how to use vimllib
" Create: 2018-09-18
" Modify: 2018-09-18

" package: 
function! test#ulib#package() abort "{{{
    return s:
endfunction "}}}

" todo: 
function! s:todo() abort "{{{
    packadd vimllib
    let v:errors = []
endfunction "}}}

" main: 
function! s:does() abort "{{{
    let l:pack = package#new('vital.vim', 'jp')
    let l:List = l:pack.import('Data.List')
    let a = [1,2,3]
    call assert_equal(List.pop(a), 3)
    call assert_equal(a, [1, 2])
    call assert_equal(List.pop(a), 2)
    call assert_equal(a, [1])
    call assert_equal(List.pop(a), 1)
    call assert_equal(a, [])
    call assert_equal(List.pop(range(10)), 9)
endfunction "}}}

" done: 
function! s:done() abort "{{{
    echomsg 'test errors: ' . len(v:errors)
    if len(v:errors)
        for l:error in v:errors
            echoms l:error
        endfor
    else
        echomsg 'test passed!'
    endif
    return len(v:errors)
endfunction "}}}

" test: 
function! test#ulib#test() abort "{{{
    call s:todo()
    call s:does()
    return s:done()
endfunction "}}}
