# VimL 脚本模块导入的一种机制实现

Sorry, Englist document is not available now, but the source code is commented
in Englist well.

如果将一个 `.vim` 脚本文件视为一个 VimL 语言的模块，则每个模块都有一个独立的命
名空间 `s:` 用以保存该脚本作用域内的私有变量与函数。但是对于通用工具类模块，另
一个问题是如何复用其内的私有函数。本插件就是为了解决 VimL 模块的导入与共享问题
，提供了一个 `import()` 函数，及一个 `:USE` 命令，便于在开发较复杂的 vim 插件
时使用多脚本的 VimL 代码组织与管理。

## 快速安装

核心只是一个文件：`autoload/package.vim`，可以单独下载这个文件，扔到任意一个
`&rtpp` 目录下的相应位置，如 `~/.vim/autoload/package.vim`，然后使用以下命令激
活加载插件（可写入 `vimrc` ）：

```vim
: call package#load()
```

当然也可以用任意的插件管理工具自动安装。

`autoload/package.vim` 无其他依赖，可兼容 vim7 版本，因此也可以单独将它复制到
其他更大型的 vim 插件中，作为基础设施使用。

## 功能速览

本插件意不在直接增强 vim 的编辑功能，甚至重心也不如何增强编辑 `.vim` 文件的功
能，而在于指导与阐明（较规范化）的 vim 脚本可以如何导入运行与互相引用。

### let dict = package#import('path#to#module', ...)

`package#import()` 函数导入一个模块，以一个字典的形式返回。参数是模块名，相对
于 `autoload/` 的路径，但按 vim 自动加载机制以 `#` 分隔路径。可以有额外参数，
指定导入哪些符号，则返回的 `dict` 字典中只包含指定的键。

该函数会试图利用待导入的目标源模块中的以下几个函数：

1. `path#to#module#export()` 或其中的 `s:export()`
1. `path#to#module#class()` 或其中的 `s:class()`
1. `path#to#module#package()` 或其中的 `s:package()`

将按此顺序调用第一个找到的函数，获取其返回值（一般也应返回字典）。如果没有定义
所有这些函数，将导入一个空字典；除非还指定了额外参数，则将再度尝试导入与参数名
相同的 `s:` 作用域的函数。

值得注意的是，如果源模块定义如 `path#to#module#export()` 这类函数，可直接调用
，不一定要用到本插件提供的 `package#import()` 函数。不过本插件提供的模块导入功
能更丰富与灵活。

### let Funref = package#imports('path#to#module', 'funcname')

`package#imports()` 函数用法类似，但必须指定一个（或多个）额外参数，限定要导入
的函数，且返回值类型不一样。如果只指定一个额外参数，返回一个标量函数引用变量，
如果指定多个额外参数，则返回一个列表，每个列表元素对应参数的函数引用。例如还可
这样用：

```vim
let [Funref1, Funcref2] = package#imports('path#to#module', 'fun1', 'fun2')
```

这个变异的导入函数名，末尾的 `s` ，可以理解为 `specific` 限定函数名；也可以理
解为复数形式，可一次导入多个函数；但更多的情况可能只是想利用其他模块的一个特定
函数，导入一个函数的用法更方便，故也可理解为标量（`scalar`）

注意如果在函数内调用 `package#imports()` 函数，接收导出的函数引用变量，不论是
使用局部变量 (`l:`) 还是全局变量（`g:`），都必须用大写字母开头。但是用脚本作用
域（`s:`）的变量接收函数引用，不受此限，也可用小写字母开头。

### :USE path#to#module [name1, name2 ...]

`USE` 是一个自定义命令，是命令形式的模块导入方法。与 `package#import()` 函数的
最大不同是，字符串参数不必写引号，但是命令没有返回值。

所以 `USE` 命令会在本地脚本中创建一个 `s:module` 字典变量，名字取自参数的最后
一部分。与 `package#import()` 函数相同，如果指定了额外参数，则字典中只新导入这
些键。

但这有一个必须的关键前提，使用该命令的脚本，即被导入的目标客户脚本，必须提供一
个全局的 `#package()` 函数，并且返回 `s:`。例如：

```vim
function! client#to#module#package()
    return s:
endfunction
```

开启这样的后门，才能将导入的字典注入到本地的 `s:` 。当然本地 `#package()` 函数
也可以返回其他值，如果不想直接影响 `s:` 命令空间，例如返回 `s:X` ，那么用
`USE` 导入模块注入的空间也将是 `s:X`，就得用类似 `s:X.module.name1()` 的方式来
引用导入的函数了。

另外注意：本地 `#package()` 函数必须写在首次使用 `USE` 命令之前。一般建议写在
模块文件的最开头处，假装在声明一个 `package` 。此外，`USE` 命令不能用于命令行
，只能在脚本中使用，且只应在脚本顶层使用，不宜在脚本内的函数中使用。

### :USE! path#to#module [name1, name2 ...]

命令允许叹号变种，`USE!` 命令与 `USE` 相比，不会创建中间层 `s:module` 变量，而
是直接创建 `s:name1` `s:name2` 变量。这在只要用到其他模块一个或少数几个函数时
比较方便，但是谨防污染本地 `s:` 命令空间，导致变量名冲突。

即使用 `USE` 命令，如果要同时导入不同路径的模块，也可能导致名字冲突，此时请用
`package#import()` 函数，如：

```vim
let s:PA = package#import('path#one#module')
let s:PB = package#import('path#tow#module')
```

### :USE[!] subdir.module [name1, name2 ...]

`USE` 命令还可以使用相对路径表示要导入的模块名，用点号表示路径分隔。是相对本地
脚本的路径，不是 vim 的当前工作路径，是使用该命令的脚本所在的目录。

并且至少要有一层子目录，否则 `:USE module` 会搜索 `autoload/module.vim` 而不是
`./module.vim` 。要达成此目的，就要明确使用 `:USE ./module.vim` ，即下面介绍的
绝对路径引用变量。

### :USE[!] /root/path/to/module.vim [name1, name2 ...]

按模块文件的绝对路径名导入，须包含文件名后缀 `.vim` ；当然也可能没有后缀名，如
`~/.vimrc` 就没有后缀名。

注意 `USE! $MYVIMRC` 并不会重新加载 vim 配置，因为 vimrc 肯定是加载过的。用此
命令的效果是，在本地脚本中，可以直接使用之前在 vimrc 中定义的 `s:` 函数；当然
不加 `!` 时，得通过 `s:MYVIMRC` 变量来引用。如果使用 `USE ~/.vimrc` ，则注入的
字典变量名是 's:vimrc' 。

路径中的 `./` 与 `../` 按当前脚本所在目录为准。除了这两种表示当前目录与父目录
的情况，`USE` 命令接收的三种表示路径分隔的参数，不能混用 `#` `.` 与 `/` ，各有
不同的适用途径。

用 `#` 表示导入模块名路径分隔时，每个部分都必要是合法的标识符。但在用 `/` 或
`.` 则不受限制，只是若路径中有空格，需用 `\` 转义，否则后续部分会认为是额外参
数的函数名。例如：

```vim
USE ./@private/struct-A.vim
```

在当前脚本目录下建个特殊的子目录，如 `@private` ，可表达内部实现的意图，已无法
从外部使用 `package#import()` 函数导入了。但是当前脚本本身，仍必须在
`autoload/` 目录下的合法路径中，因为要求本地定义一个 `#package()` 函数。

### 使用 package 模块

本插件的 `package.vim` 除了提供一种模块导入导出机制外，该文件本身也是个良好的
模块范例，其中为了实现该机制的一些私有函数也被设计为可被导出至其他脚本参考使用
。可用 `USE! package` 直接导入当前脚本，或想安全点用 `let s:P =
package#import('package')` 。

* `s:scripts()` 已加载的脚本列表，类似 `:scriptnames` 输出，但是列表变量。
* `s:get_sid()` 获取一个模块（`#` 形式）的 <SID> 编号。
* `s:file_sid()` 获取一个文件的 <SID> 编号。
* `s:error()` 良好提示函数调用栈的错误信息。

此外，还有几个 `#` 全局函数，不用导出也可使用，虽是为实现 `import()` 与 `:USE`
而写，但在某些情况或也有独立用处。

* `package#importo()` 从一个命名空间导入符号到另一个命名空间，其实就是两个字典
   间的键拷贝。
* `package#rimport()` 按相对路径导入模块，需要手动传入基准目录。正因为手动传入
  当前脚本路径是件略麻烦的事，故主导函数 `package#import()` 不能像 `:USE` 命令
  一样支持相对路径导入。

## 其他参考

待议。
