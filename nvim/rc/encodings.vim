" encoding-names
"
" 1   ansi    same as latin1 (obsolete, for backward compatibility)
" 2   japan    Japanese: on Unix "euc-jp", on MS-Windows cp932
" 2   korea    Korean: on Unix "euc-kr", on MS-Windows cp949
" 2   prc        simplified Chinese: on Unix "euc-cn", on MS-Windows cp936
" 2   chinese     same as "prc"
" 2   taiwan    traditional Chinese: on Unix "euc-tw", on MS-Windows cp950
" u   utf8    same as utf-8
" u   unicode    same as ucs-2
" u   ucs2be    same as ucs-2 (big endian)
" u   ucs-2be    same as ucs-2 (big endian)
" u   ucs-4be    same as ucs-4 (big endian)
" u   utf-32    same as ucs-4
" u   utf-32le    same as ucs-4le

" Encoding UTF-8 on New File
autocmd MyAutoCmd VimEnter * if s:GetBufByte() == 0 | set encoding=utf8
function! s:GetBufByte()
  let byte = line2byte(line('$') + 1)
  if byte == -1
    return 0
  else
    return byte - 1
  endif
endfunction

set fileformats=unix,dos,mac
set fileencodings=iso-2022-jp,cp932,sjis,euc-jp,utf-8
