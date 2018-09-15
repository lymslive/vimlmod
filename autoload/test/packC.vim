" calss: 
let s:class = {}
function! test#packC#class() abort "{{{
    return s:class
endfunction "}}}

" hello: 
function! s:class.hello() dict abort "{{{
    return 1
endfunction "}}}

" new: 
function! s:class.new() dict abort "{{{
    let l:obj = deepcopy(self)
    let l:obj.name =  'packC'
    return l:obj
endfunction "}}}

" hasname: 
function! s:class.hasname() dict abort "{{{
    return has_key(self, 'name') && len(self.name) > 0
endfunction "}}}
