" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#taglist_by_type
" Purpose: extract records by type. help module for taglist_by_class , etc..

function! railmoon#oscan#extractor#taglist_by_type#create(type)
    let new_extractor = copy(s:tag_scan_taglist_by_type_extractor)

    let new_extractor.file_name = expand("%:p")
    let new_extractor.file_extension = expand("%:e")
    let new_extractor.filetype = &filetype
    let new_extractor.type = a:type
    let new_extractor.description = 'Go to tag type "'.new_extractor.type.'"'

    return new_extractor
endfunction

let s:tag_scan_taglist_by_type_extractor = {}
function! s:tag_scan_taglist_by_type_extractor.process(record)
    exec 'tag '.self.word_under_cursor
    exec 'edit '.a:record.data.filename
    update
    let cmd = a:record.data.cmd

    if cmd =~ '^\d\+$'
        exec cmd
    else
        exec escape(cmd, '*')
    endif
endfunction

function! s:record_for_language_tag( language, ctag_item )
    return railmoon#oscan#extractor#ctags#language_function( a:language, 'record', a:ctag_item )
endfunction

function! s:tag_scan_taglist_by_type_extractor.extract()
    let result = []

    let extension = self.file_extension
    let language = railmoon#oscan#extractor#ctags#language_by_extension(extension)

"    let ctags_tags = taglist('.*')

"    for item in ctags_tags
"        if item.kind !~ self.type
"            continue
"        endif

"        let record = s:record_for_language_tag(language, item)
"        let record.data = item
"        call add(result, record)
"    endfor

    return result
endfunction

function! s:tag_scan_taglist_by_type_extractor.colorize()
    let &filetype = self.filetype
    call railmoon#oscan#extractor#ctags#colorize_keywords()
endfunction

