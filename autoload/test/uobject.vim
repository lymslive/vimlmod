" File: uobject
" Author: lymslive
" Description: test how to use object
" Create: 2018-09-20
" Modify: 2018-09-20

" package: 
function! test#uobject#package() abort "{{{
    return s:
endfunction "}}}

let s:CA = {}
let s:CA.fa1 = 'a'

let s:CB = {}
let s:CB.fb1 = 'b'
function! s:CB.fun() dict abort
    return self.fb1
endfunction

" todo: 
function! s:todo() abort "{{{
    let v:errors = []
endfunction "}}}

" main: 
function! s:does() abort "{{{
    let l:OA = object#new(s:CA)
    call assert_fails('echo l:OA.fa1')
    call assert_true(l:OA.get('fa1') == 'a')
    call assert_true(l:OA.fa1 == 'a')

    let l:OB = object#new(s:CB)
    call l:OB.has('fun')
    call assert_fails('call l:OB.fun()')
    call l:OB.get('fb1')
    call assert_true(l:OB.fun() == 'b')
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
function! test#uobject#test() abort "{{{
    call s:todo()
    call s:does()
    return s:done()
endfunction "}}}
