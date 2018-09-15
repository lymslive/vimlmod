" File: autoload/package.vim
" Author: lymslive
" Description: viml script packge schema, implemented in single file
" Create: 2018-09-11
" Modify: 2018-09-12

" LICENSE: "{{{1
" The MIT License (MIT)
" 
" Copyright (c) 2018 lymslive (403708621@qq.com)
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.

" Package Example Style:  "{{{1
" A package(or module) is just a script under the 'autoload/' subdirctory
" of some &rtp. Each package has a private namespace, the special s: dict.
" This is schema to share private function with other package.
" The following global '#' functions are all optional, while usefull.

" #package() typically return s: to represent the current package.
" you can return other reasonable dict variables such as:
" s:_inner_pack_but_not_so_long_name_
" It is only mandatory to ":USE" command, as import to where?
function! package#package() abort
    return s:
endfunction

" #export() return a dict to represent export what to client.
function! package#export() abort
    return s:EXPORT
endfunction

" #load() mainly to triggle autoload package script.
" Also a good place for initial code, and is safer when reload.
function! package#load() abort "{{{
    let s:__name__ = 'package'
    let s:EXPORTOR_FUNC = ['export', 'class', 'package']
    let s:EXPORTOR_NAME = 'EXPORT'
    let s:SLASH = fnamemodify('.', ':p')[-1:]
    let s:scripts = []
    let s:mapSID = {}
    let s:EXPORT = {}
    let s:EXPORT.get_sid = function('s:get_sid')
    let s:EXPORT.file_sid = function('s:file_sid')
    let s:EXPORT.error = function('s:error')
    let s:EXPORT.scripts = function('s:script_list')
    return 1
endfunction "}}}

" Some way to use(import) other (lib) package from cliend script.
" Of course "package" should be "real#path#to#module".
" But ":USE" also support relative path based on current scipt.
" Note ":USE!" may pollution namespace, and symbol conflict.
function! package#usage() abort "{{{
    let s:P = package#import('package')
    echo s:P.get_sid('package')

    let s:sid = package#imports('package', 'get_sid')
    echo s:sid('package')

    USE package
    echo s:package.get_sid('package')

    USE! package get_sid
    echo s:get_sid('package')
endfunction "}}}

" Import Function API: "{{{1
" a:srcpack -- autoload package name like 'path#to#mod'
" a:000  -- specific symbol name to be imported
" return -- a dict with key is imported symbols
function! package#import(srcpack, ...) abort "{{{
    let l:sid = s:get_sid(a:srcpack)
    if l:sid <= 0
        try
            call {a:srcpack}#load()
        catch /E117/
            " pass, just for autoload, #load() may not exist
        endtry
        let l:sid = s:get_sid(a:srcpack)
        if l:sid <=0
            return s:error('package not found: ' . a:srcpack, {})
        endif
    endif

    let l:srcpack = s:try_export(a:srcpack, l:sid)
    return call('s:_import', [l:srcpack, l:sid] + a:000)
endfunction "}}}

" imports: 
" must specific at least a symbol name to imported
" return a single or a list of symbol directlly
function! package#imports(srcpack, ...) abort "{{{
    if a:0 == 0
        return s:error('must privide imported symbol name, or use package#import() instead')
    endif

    let l:export = call('package#import', [a:srcpack] + a:000)
    if empty(l:export)
        return s:error('fail to import')
    endif

    if a:0 == 1
        return l:export[a:1]
    else
        return map(copy(a:000), 'l:export[v:val]')
    endif
endfunction "}}}

" importo: import symbols form src to dst namespace
" a:dstpack -- must be a dict
" a:srcpack -- can be a dict or string as autoload package name
" a:1 -- not overwrite exists key in dstpack, default will overwrite.
" return: less meanning, modify a:dstpack directlly.
function! package#importo(dstpack, srcpack, ...) abort "{{{
    if type(a:dstpack) != type({})
        return s:error('target namespace expect a dict')
    endif
    if type(a:srcpack) == type({})
        let l:srcpack = a:srcpack
    elseif type(a:srcpack) == type('')
        let l:srcpack = package#import(a:srcpack)
    else
        return s:error('export a dict or string as package name')
    endif
    let l:bKeep = get(a:000, 0, 0)
    return s:importto(a:dstpack, l:srcpack, l:bKeep)
endfunction "}}}

" rimport: import through relative path other than autoload
" a:basedir -- the base directory
" a:srcpath -- must has '/' or '.' as path separator, 
"   when '.' should without '.vim' extention
"   when '/' should with '.vim' extention
" return a dict as package#import()
function! package#rimport(basedir, srcpath, ...) abort "{{{
    if stridx(a:srcpath, s:SLASH) >= 0
        if a:srcpath =~# '^\.'
            let l:srcpath = a:basedir . s:SLASH . a:srcpath
        else
            let l:srcpath = a:srcpath
        endif
    elseif stridx(a:srcpath, '.') >= 0
        let l:srcpath = substitute(a:srcpath, '\.', s:SLASH, 'g')
        let l:srcpath = a:basedir . s:SLASH . l:srcpath
        let l:srcpath .= '.vim'
    else 
        return s:error('relative path muse has slash or dot')
    end

    let l:srcpath = resolve(expand(l:srcpath))
    let l:sid = s:file_sid(l:srcpath)
    if l:sid <= 0
        if !filereadable(l:srcpath)
            return s:error('cannot read source script', {})
        endif
        execute 'source ' . l:srcpath
        let l:sid = s:file_sid(l:srcpath)
        if l:sid <= 0
            return s:error('fials to source script', {})
        endif
    endif

    let l:srcpack = s:try_export('', l:sid)
    return call('s:_import', [l:srcpack, l:sid] + a:000)
endfunction "}}}

" USE Command API: "{{{1
" An user defined command that can only be used in script but command line.
" That will be simpler than package#import() function.
" USE path#to#mod
" USE subdir.mod
" USE ./../relative/to/mod
" with '!' import to current s: namespace

" function Impletemention for USE command
" a:mix -- import to current s: namespace or not
" a:dstpack -- full path of current script <sfile>
" a:srcpack -- '#'ed autoload package name or '/' '.' relative path
function! package#use(mix, dstpack, srcpack, ...) abort "{{{
    if type(a:dstpack) != type('')
        return s:error('argument error, import to where, expect a path')
    endif
    if type(a:srcpack) != type('')
        return s:error('argument error, import from where, expect a path')
    endif

    let l:autopath = s:auto_name(a:dstpack)
    " must have #package() to return s:, or let it abort on error
    let l:dstpack = {l:autopath}#package()
    if type(l:dstpack) != type({})
        return s:error('#package() should return a dict')
    endif

    " import from relative path, when has '/' or '.'
    let l:srcpack = expand(a:srcpack)
    if stridx(l:srcpack, s:SLASH) >= 0 || stridx(l:srcpack, '.') >= 0
        let l:thisdir = fnamemodify(a:dstpack, ':p:h')
        let l:srcpack = call('package#rimport', [l:thisdir, l:srcpack] + a:000)
    else
        let l:srcpack = call('package#import', [l:srcpack] + a:000)
    end

    if !a:mix
        let l:name = s:tail_name(a:srcpack)
        if !has_key(l:dstpack, l:name)
            let l:dstpack[l:name] = {}
        endif
        let l:dstpack = l:dstpack[l:name]
    endif
    return s:importto(l:dstpack, l:srcpack)
endfunction "}}}
command! -nargs=+ -bang USE call package#use(<bang>0, expand('<sfile>:p'), <f-args>)

" Private Impletement: "{{{1
" tail_name: the last part of (may full long) package name
function! s:tail_name(package) abort "{{{
    if type(a:package) != type('')
        return s:error('not string module name', '')
    endif
    let l:package = substitute(a:package, '\.vim$', '', 'g')
    let l:name = matchstr(l:package, '\w\+$')
    if empty(l:name)
        return s:error('invalid module name: ' a:package, '')
    endif
    return l:name
endfunction "}}}

" auto_name: convert to autoload name from full path
function! s:auto_name(path) abort "{{{
    let l:autoload = s:SLASH . 'autoload' . s:SLASH
    let l:idx = stridx(a:path, l:autoload)
    if l:idx == -1
        return s:error('may not a autoload script name', '')
    endif

    let l:autopath = strpart(a:path, l:idx + len(l:autoload))
    let l:autopath = substitute(l:autopath, s:SLASH, '#', 'g')
    let l:autopath = substitute(l:autopath, '\.vim$', '', 'g')
    return l:autopath
endfunction "}}}

" try_export: try to call #export(), s:export() ... ect.
" a:srcpack -- string as autoload name.
" a:sid -- number as <SID> of the corresponding script.
" expect to return a dict.
function! s:try_export(srcpack, sid) abort "{{{
    let l:export = {}
    for l:fun in s:EXPORTOR_FUNC
        if !empty(a:srcpack)
            let l:sharp = a:srcpack . '#' . l:fun
            if exists('*' . l:sharp)
                let l:Funref = function(l:sharp)
                let l:export = l:Funref()
            endif
        endif
        if empty(l:export) && !empty(a:sid)
            let l:private = s:sid_func_name(a:sid, l:fun)
            if exists('*' . l:private)
                let l:Funref = function(l:private)
                let l:export = l:Funref()
            endif
        endif
        if !empty(l:export)
            if type(l:export) == type({}) && has_key(l:export, s:EXPORTOR_NAME)
                return l:export[s:EXPORTOR_NAME]
            endif
            return l:export
        endif
    endfor
    return l:export
endfunction "}}}

" importto: 
function! s:importto(dstpack, srcpack, ...) abort "{{{
    let l:bKeep = get(a:000, 0, 0)
    let l:num = 0
    for [l:key, l:Val] in items(a:srcpack)
        if has_key(a:dstpack, l:key)
            if l:bKeep
                continue
            else
                echomsg 'import will overwrite dest package key: ' . l:key
            endif
        endif
        let a:dstpack[l:key] = deepcopy(l:Val)
        let l:num += 1
        unlet l:key  l:Val
    endfor
    return l:num
endfunction "}}}

" _import: 
" a:pack -- a dict may exported by source package
" a:sid  -- the SID of the sourced script of package
" return a dict, it will be copy of a:pack if no extra argument.
" with optional argument, will also check private s: function.
function! s:_import(pack, sid, ...) abort "{{{
    if type(a:pack) != type({})
        return s:error('export function should return a dict: ' . a:pack)
    endif

    if a:0 == 0
        return deepcopy(a:pack)
    endif

    let l:export = {}
    for l:sName in a:000
        if has_key(a:pack, l:sName)
            let l:export[l:sName] = deepcopy(a:pack[l:sName])
        else
            let l:private = s:sid_func_name(a:sid, l:sName)
            if exists('*' . l:private)
                let l:export[l:sName] = function(l:private)
            else
                call s:error('fail to import: ' . l:sName)
            endif
        endif
    endfor

    return l:export
endfunction "}}}

" Manage SID: "{{{1

" scipt_list: 
function! s:script_list() abort "{{{
    call s:fresh_script()
    return copy(s:scripts)
endfunction "}}}

" fresh_script: track the loaded script, list by :scriptnames
function! s:fresh_script() abort "{{{
    let l:sOut = ''
    try
        redir => l:sOut
        silent execute 'scriptnames'
    finally
        redir END
    endtry
    if empty(l:sOut)
        return
    endif

    let l:scripts = split(l:sOut, "\n")
    let l:end = len(l:scripts)
    let l:idx = len(s:scripts)
    while l:idx < l:end
        let l:script = matchstr(l:scripts[l:idx], '^\s*\d\+:\s*\zs.*')
        let l:script = resolve(expand(l:script))
        call add(s:scripts, l:script)
        if l:script =~# 'autoload'
            let l:package = s:auto_name(l:script)
            if !empty(l:package) && !has_key(s:mapSID, l:package)
                let s:mapSID[l:package] = l:idx + 1
            endif
        endif
        let l:idx += 1
    endwhile

    return l:end - l:idx
endfunction "}}}

" get_sid: 
" get the SID of a package under autoload/ subdirctory
" return 0 when script not load
function! s:get_sid(package) abort "{{{
    if has_key(s:mapSID, a:package)
        return s:mapSID[a:package]
    else
        call s:fresh_script()
    endif
    return get(s:mapSID, a:package)
endfunction "}}}

" sid_func_name: 
" s: function actually has global name with special prifix.
function! s:sid_func_name(sid, fun) abort "{{{
    return printf('<SNR>%d_%s', a:sid, a:fun)
endfunction "}}}

" file_sid: find SID from full path of script file
function! s:file_sid(path) abort "{{{
    call s:fresh_script()
    let l:idx = 0
    let l:end = len(s:scripts)
    while l:idx < l:end
        if s:scripts[l:idx] ==# resolve(expand(a:path))
            return l:idx + 1
        endif
        let l:idx += 1
    endwhile
    return 0
endfunction "}}}

" Common Utils: {{{1
" print error massage and return a error code(default 0).
function! s:error(msg, ...) abort "{{{
    let l:stacks = split(expand('<sfile>'), '\.\.')
    if len(l:stacks) > 1
        let l:location = join(l:stacks[0:-2], '...')
    else
        let l:location = 'script'
    endif
    echohl ErrorMsg | echomsg 'vim> ' . l:location | echohl None
    echohl Error    | echomsg a:msg | echohl None
    return get(a:000, 0, 0)
endfunction "}}}

" a shortter global Import function, if you like
if get(g:, 'global_import_function', 0)
function! Import(...) abort
    return call('package#import', a:0000)
endfunction
endif
