if has('win32')
    augroup imeauto
        autocmd InsertLeave * set imdisable | set iminsert=0
        autocmd InsertEnter * set noimdisable | set iminsert=2
    augroup END
endif
