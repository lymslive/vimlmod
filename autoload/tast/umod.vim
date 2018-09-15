" package: 
function! tast#umod#package() abort "{{{
    return s:
endfunction "}}}

let s:name = 'umod.vim'
echo 'before USE'
echo s:

USE tast#modA

echo 'after USE'
echo s:

call s:modA.hello('happy to use modA')
