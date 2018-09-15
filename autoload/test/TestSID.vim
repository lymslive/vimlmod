" package: 
function! test#TestSID#package() abort "{{{
    return s:
endfunction "}}}

let v:errors = []

USE! package get_sid file_sid

call assert_true(s:get_sid('package') > 0)
call assert_true(s:file_sid('~/.vimrc') == 1)
call assert_true(s:file_sid($MYVIMRC) == 1)

USE $MYVIMRC
call assert_true(has_key(s:, 'MYVIMRC'))

USE ~/.vimrc StartVimrc
call assert_true(has_key(s:, 'vimrc'))

echo s:

if len(v:errors) > 0
    echo v:errors
else
    echo 'test passed!'
endif
