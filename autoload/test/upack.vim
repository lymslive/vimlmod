" File: upack
" Author: lymslive
" Description: test how to use package
" Create: 2018-09-14
" Modify: 2018-09-14

" package: 
function! test#upack#package() abort "{{{
    return s:
endfunction "}}}

let v:errors = []

let s:PA = package#import('test#packA')
call assert_true(s:PA.hello(), 'fail to import packA')

let s:PAS = package#import('test#packAs')
call assert_true(s:PAS.hello(), 'fail to import packAs')

let s:PB = package#import('test#packB')
call assert_true(s:PB.hello(), 'fail to import packB')

let s:PBS = package#import('test#packBs')
call assert_true(s:PBS.hello(), 'fail to import packBs')

let s:PBE = package#import('test#packBe')
call assert_true(s:PBE.hello(), 'fail to import packBe')

let s:private = package#imports('test#packBe', 'private')
call assert_true(s:private(), 'fail to import packBe private')

USE test#packC
call assert_false(s:packC.hasname())
let s:obj = s:packC.new()
call assert_true(s:obj.hasname(), 'fail to new object')
call assert_true(s:packC.hello(), 'fail to import packC')
call assert_true(s:obj.hello(), 'fail to import packC')

USE! @private.subA hello
call assert_true(s:hello(), 'fail to import in current package')

USE ./@private/struct-B.vim
call assert_true(has_key(s:, 'B'), 'fail to USE struct-B')
call assert_true(has_key(s:B, 'str'), 'fail to USE struct-B')
call assert_true(s:B.num, 'fail to USE struct-B')

call assert_false(has_key(s:B, 'new'), 'fail to USE struct-B')
USE ./@private/struct-B.vim new
call assert_true(has_key(s:B, 'new'), 'fail to re-USE struct-B')
call assert_true(s:B.num, 'fail to re-USE struct-B')
let s:nodeB = s:B.new('x', 1)
call assert_equal(s:nodeB.str, 'x')
call assert_equal(s:nodeB.num, 1)

" report: 
function! s:report() abort "{{{
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
call s:report()
