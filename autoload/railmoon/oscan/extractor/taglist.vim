" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#ctags
" Purpose: extract ctags record from tags

function! railmoon#oscan#extractor#taglist#create()
    let new_extractor = copy(s:tag_scan_taglist_extractor)

    let new_extractor.file_name = expand("%:p")
    let new_extractor.file_extension = expand("%:e")
    let new_extractor.filetype = &filetype
    let new_extractor.word_under_cursor = expand('<cword>')
    let new_extractor.description = 'Go to tag "'.new_extractor.word_under_cursor.'"'

    return new_extractor
endfunction

let s:tag_scan_taglist_extractor = {}
function! s:tag_scan_taglist_extractor.process(record)
    exec 'tag '.self.word_under_cursor
    exec 'edit +'.a:record.cmd.' '.a:record.data.filename
    update
endfunction

function! s:record_for_language_tag( language, ctag_item )
    return railmoon#oscan#extractor#ctags#language_function( a:language, 'record', a:ctag_item )
endfunction

function! s:tag_scan_taglist_extractor.extract()
    if empty(self.word_under_cursor)
        return []
    endif

    let result = []

    let extension = self.file_extension
    let language = exists( '&filetype' ) ? &filetype : railmoon#oscan#extractor#ctags#language_by_extension(extension)

    let ctags_tags = taglist('\<'.self.word_under_cursor.'\>')

    for item in ctags_tags
        let record = s:record_for_language_tag(language, item)
        let record.data = item
        call add(result, record)
    endfor

    return result
endfunction

function! s:tag_scan_taglist_extractor.colorize()
    let &filetype = self.filetype
    call railmoon#oscan#extractor#ctags#colorize_keywords()
endfunction

