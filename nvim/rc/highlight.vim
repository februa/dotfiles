if has("win32") || has("win64")
	let s:separator = '\'
else
	let s:separator = '/'
endif

let s:execcount = 0
let s:default_path = expand('<sfile>:p:h').s:separator
let s:default_data_file = expand('<sfile>:p:r').'.csv'
let s:data_file = ''
let s:loaded_data = 0
let s:totalfields = 10
let s:highlightfields = 5
let s:regexfield = 5
let s:boldfield = 6
let s:underlinefield = 7
let s:italicfield = 8
let s:ignorecasefield = 9

function! LoadConfig(inputfile)
	let a:dfile = a:inputfile

	if !s:loaded_data
		if filereadable(a:dfile)
			let names = ['hl', 'ctermfg=', 'ctermbg=', 'guifg=', 'guibg=', 'regex=', 'bold', 'underline', 'italic', 'ignorecase']

			for line in readfile(a:dfile)
				" If the line starts with #, skip line (comment)
				if line =~ '^[ ]*#'
					continue
				endif
	
				let fields = split(line, ',', 1)
				let addstyle = ''
	
				if len(fields) == s:totalfields && fields[0] =~ '^\d\+$'
					let cmd = range(s:highlightfields)
					call map(cmd, 'names[v:val].fields[v:val]')
					call filter(cmd, 'v:val!~''=$''')

					if fields[s:boldfield] == 1
						let addstyle = 'bold'
					endif

					if fields[s:underlinefield] == 1
						if len(addstyle) > 0
							let addstyle = addstyle.',underline'
						else
							let addstyle = 'underline'
						endif
					endif

					if fields[s:italicfield] == 1
						if len(addstyle) > 0
							let addstyle = addstyle.',italic'
						else
							let addstyle = 'italic'
						endif
					endif

					if len(addstyle) > 0
						let ctermstyle='cterm='.addstyle
					else
						let ctermstyle='cterm=none'
					endif

					if len(addstyle) > 0
						let guistyle='gui='.addstyle
					else
						let guistyle='gui=none'
					endif

					call add(cmd, ctermstyle)
					call add(cmd, guistyle)

					execute 'silent highlight '.join(cmd)

					let regexstr = fields[s:regexfield]
					let ignorecasestr = fields[s:ignorecasefield]

					call s:DoHighlight(fields[0], regexstr, ignorecasestr, 0)
				endif
			endfor

			let s:loaded_data = 1
		endif

		if !s:loaded_data
			echo 'Error: Could not read highlight data from '.a:dfile
		endif
	endif

	let s:loaded_data = 0
endfunction

function! s:DoHighlight(hlnum, pat, igcase, decade)
	let hltotal = a:hlnum
	let ignorecase = a:igcase

	if 0 < a:decade && a:decade < 10
		let hltotal += a:decade * 10
	endif

	if ignorecase == 1
		let pattern = '\c'.a:pat
	else
		let pattern = a:pat
	endif

	let id = hltotal + 100
	silent! call matchdelete(id)

	if !empty(pattern)
		try
			call matchadd('hl'.hltotal, pattern, -1, id)
		catch /E28:/
			echo 'Highlight hl'.hltotal.' is not defined'
		endtry
	endif
endfunction

function! s:HiClear()
	for m in getmatches()
		call matchdelete(m.id)
	endfor
endfunction
command! HiClr call s:HiClear()

function! s:MultiHighlights()
	let s:execcount = s:execcount+1
	echo 'Multiple syntax highlights: ON's:execcount

	if len(s:data_file) == 0 
		let s:data_file = s:default_data_file
	endif
	call LoadConfig(s:data_file)
endfunction

function! s:UserDataFile(inputfile)
	let s:ufile = a:inputfile
	
	if len(s:ufile) == 0
		let s:data_file = s:default_data_file
 	else
		let s:data_file = s:default_path.s:ufile	
 	endif

	call s:HiClear()
	call s:MultiHighlights()	
endfunction
command! -nargs=? UsrCfg call s:UserDataFile("<args>")

function! s:ListUsrCfg()
	echo "Active configuration file = "s:data_file	
endfunction
command! -nargs=0 LstUsrCfg call s:ListUsrCfg()

nnoremap <silent> <Leader>m :call <SID>MultiHighlights()<CR>
