" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#search_in_windows
" Purpose: extract strings with search pattern from all windows

function! railmoon#oscan#extractor#search_in_windows#create()
    let new_extractor = copy(s:tag_scan_search_in_windows_extractor)

    let new_extractor.pattern = @/
    let new_extractor.buffer_number = bufnr('%')
    let new_extractor.filetype = &filetype
    let new_extractor.description = 'Search "'.new_extractor.pattern.'" in all windows'

    return new_extractor
endfunction

let s:tag_scan_search_in_windows_extractor = {}
function! s:tag_scan_search_in_windows_extractor.process(record)
    exec a:record.data[1].'tabnext'
    exec a:record.data[2].'wincmd w'
    exec a:record.data[0]
endfunction

function! s:tag_scan_search_in_windows_extractor.tags_by_line(line_number, line) " line
    return railmoon#oscan#extractor#util#tags_from_searched_line(a:line_number, a:line)
endfunction

function! s:tag_scan_search_in_windows_extractor.header_by_line(line_number, line)
    let line = substitute(a:line, '^\s*', '', 'g')
    return [ line ]
endfunction

function! s:tag_scan_search_in_windows_extractor.search_in_buffer(tabpage_number, window_number)
    let result = []

    let current_buffer_number = bufnr('%')
    exec a:window_number.'wincmd w'

    let pos = getpos('.')
    
    call cursor(1, 1)

    let pattern = self.pattern
    let last_search_result = -1

    let option = 'Wc'

    while 1
        let search_result = search(pattern, option)

        if search_result == 0
            break
        endif

        if search_result != last_search_result
            let line = getline(search_result)

            let data = self.header_by_line(search_result, line)
            let tag_list = self.tags_by_line(search_result, line)

            call add(result, railmoon#oscan#record#create(
                        \data, 
                        \tag_list, 
                        \[search_result, a:tabpage_number, a:window_number],
                        \ fnamemodify(bufname(winbufnr('%')), ':p:t')))
        endif

        let last_search_result = search_result
        let option = 'W'
    endwhile

    call setpos('.', pos)

    return result
endfunction

function! s:tag_scan_search_in_windows_extractor.extract()
    let lazyredraw_status = &lazyredraw

    set lazyredraw
    let result = []

    try

        let passed_buffers = []
        for tabpage_number in range(tabpagenr('$'))
            exec (tabpage_number + 1) . 'tabnext'
            
            for window_number in range(winnr('$'))
                let buffer_number = winbufnr(window_number + 1)

                if -1 == index(passed_buffers, buffer_number)
                    call add(passed_buffers, buffer_number)
                    call extend(result, self.search_in_buffer(tabpage_number + 1, window_number + 1))
                endif
            endfor 
        endfor

    catch /.*/
        echo v:exception
        echo v:throwpoint

    finally
        let &lazyredraw = lazyredraw_status
        return result
    endtry
endfunction

function! s:tag_scan_search_in_windows_extractor.colorize()
    let &filetype = self.filetype
endfunction

