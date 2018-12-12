;===============================================================================
; extract_ice.pro - IDL program for extracting sea ice concentrations from
;                   Polar Stereographic grid files.
;===============================================================================

;-------------------------------------------------------------------------------
; get_processing_type - gets user's choice of near real-time or batch.
;
; Input:
;     None.
;
; Output:
;     None.
;
; Return Values:
;     1: near real-time; 2: batch.
;-------------------------------------------------------------------------------
function get_processing_type

prod_type = 0
while (prod_type lt 1 or prod_type gt 3) do begin
    PRINT, 'Enter the processing type (1 = SSM/I)'
    PRINT, '                          (2 = ESMR)'
    READ, prod_type
endwhile

return, prod_type
end


;-------------------------------------------------------------------------------
; get_time_resolution - gets user's choice of daily or monthly data.
;
; Input:
;     prod_type - 1: near real-time; 2: SSM/I batch; 3: ESMR.
;
; Output:
;     None.
;
; Return Value:
;     1: daily; 2: monthly; 3: climatology
;-------------------------------------------------------------------------------
function get_time_resolution, prod_type

if (prod_type eq 1) then begin
    timeRes = 0
    while (timeRes lt 1 or timeRes gt 2) do begin
        PRINT, 'Enter the time resolution (1 = daily)'
        PRINT, '                          (2 = monthly)'
        READ, timeRes
    endwhile
endif else if (prod_type eq 2) then begin
    timeRes = 0
    while (timeRes lt 1 or timeRes gt 3) do begin
        PRINT, 'Enter the time resolution (1 = daily)'
        PRINT, '                          (2 = monthly)'
        PRINT, '                          (3 = climatology)'
        READ, timeRes
    endwhile
endif

return, timeRes
end


;-------------------------------------------------------------------------------
; get_dates gets the user's start and end dates.
;
; Input:
;     timeRes - 1: daily; 2: monthly.
;
; Output:
;     none.
;
; Return Value:
;     the start and end dates in yyyymmdd format or start and end months in
;     yyyymm format (depends on the value of input variable timeRes).
;-------------------------------------------------------------------------------
function get_dates, timeRes

dates = {start_date: 0L, $
         end_date: 0L}

i = 0L
if timeRes eq 1 then begin
    PRINT, 'Enter start and end dates (yyyymmdd, e.g., 19950610).'
    READ, i, PROMPT='Start Date: '
    dates.start_date = i
    READ, i, PROMPT='End Date: '
    dates.end_date = i
    if (dates.start_date lt 10000000 or dates.end_date lt 10000000 or $
        dates.end_date lt dates.start_date) then begin
        PRINT, 'You entered  an invalid date range.'
        dates.start_date = 0
        dates.end_date = 0
    endif
endif else if timeRes eq 2 then begin
    PRINT, 'Enter start and end months (yyyymm, e.g., 199506).'
    READ, i, PROMPT='Start Date: '
    dates.start_date = i
    READ, i, PROMPT='End Date: '
    dates.end_date = i
    if dates.start_date gt 1000000 or dates.end_date gt 1000000 then begin
        PRINT, 'You entered more than a year and month. Did you really want daily data?'
        dates.start_date = 0
        dates.end_date = 0
    endif else if dates.start_date lt 100000 or dates.end_date lt 100000 $
      or dates.end_date lt dates.start_date then begin
        PRINT, 'You entered  an invalid date range.'
        dates.start_date = 0
        dates.end_date = 0
    endif        
endif else if timeRes eq 3 then begin
    PRINT, 'Enter start and end months for animation (mm, e.g., 06).'
    READ, i, PROMPT='Start Date: '
    dates.start_date = i
    READ, i, PROMPT='End Date: '
    dates.end_date = i
    if dates.start_date lt 1 or dates.end_date lt 1 or $
      dates.start_date gt 12 or dates.end_date gt 12 then begin
        PRINT, 'Months must be between 01 and 12'
        dates.start_date = 0
        dates.end_date = 0
    endif else if dates.end_date lt dates.start_date then begin
        PRINT, 'You entered an invalid date range.'
        dates.start_date = 0
        dates.end_date = 0
    endif
endif

return, dates
end


;--------------------------------------------------------------------------------
; get_algorithm - gets user's choice of which algorithm (NASATeam or
;                 Bootstrap). Displays a warning message if there are no
;                 files matching the user's selections.
;
; Input:
;     dir_name - the name of the directory where the sea ice concentation
;                files are.
;     hemisphere - 1: northern hemisphere; 2: southern hemisphere.
;     sat_no - the satellite number (7, 8, 11, 13, or 17).
;
; Output:
;     none.
;
; Return Value:
;     structure containing algorithm (1: NASATeam; 2: Bootstrap; -1: error)
;--------------------------------------------------------------------------------
function get_algorithm, dir_name, hemisphere, sat_no

if (dir_name eq ' ' or hemisphere lt 1 or hemisphere gt 2) then begin
    algorithm = -1
    goto, FINISH
endif

;
; Get the algorithm.
;
algorithm = 0
while (algorithm lt 1 or algorithm gt 2) do begin
    PRINT,'Enter the algorithm (1 = NASATeam)'
    PRINT,'                    (2 = Bootstrap)'
    READ, algorithm
    if (algorithm eq 1) then begin
        PRINT,'You selected the NASATeam algorithm'
    endif else if (algorithm eq 2) then begin
        PRINT,'You selected the Bootstrap algorithm'
    endif
endwhile

FINISH:

return, algorithm
end


;--------------------------------------------------------------------------------
; get_hemisphere - gets the user's choice of which hemisphere (northern or
;                  southern).
;
; Input:
;     none.
;
; Output:
;     none.
;
; Return Value:
;     1 - Northern Hemisphere; 2 - Southern Hemisphere
;-------------------------------------------------------------------------------
function get_hemisphere

hemisphere = 0

while (hemisphere lt 1 or hemisphere gt 2) do begin
    PRINT, 'Enter the hemisphere (1 = northern)'
    PRINT, '                     (2 = southern)'
    READ, hemisphere
endwhile

return, hemisphere
end


;-------------------------------------------------------------------------------
; get_dir - gets the directory that the sea ice concentration files are in.
;
; Input:
;     none.
;
; Output:
;     none.
;
; Return Value:
;     the directory name.
;-------------------------------------------------------------------------------
function get_dir

dir_name = ' '
PRINT, 'Enter the full name of the directory that the sea ice files are in.'
PRINT, '(Note: directory names are case-sensitive.)'
READ, dir_name

return, dir_name
end


;-----------------------------------------------------------------------------
; get_ESMR_threshold - gets the ice concentration threshold (0% or 15%)
;                      for ESMR sea ice concencentrations.
;
; Input:
;     none.
;
; Output:
;     none.
;
; Return Value:
;     1: 0%; 2: 15%
;--------------------------------------------------------------------------------
function get_ESMR_threshold
threshold = 0
while (threshold lt 1 or threshold gt 2) do begin
    PRINT, 'Enter the sea ice concentration threshold (1 = 0%)'
    PRINT, '                                          (2 = 15%)'
    READ, threshold
endwhile

return, threshold
end


;--------------------------------------------------------------------------------
; get_satellite_number - gets the user choice of satellite.
;
; Input:
;     none.
;
; Output:
;     none.
;
; Return Value:
;     the satellite number (8, 11, 13, or 17).
;--------------------------------------------------------------------------------
function get_satellite_number

sat_no = -1
PRINT, 'Enter the satellite number (e.g., 7, 8, 11, 13, or 17)'
READ, sat_no

return, sat_no
end


;--------------------------------------------------------------------------------
; date_increment - properly increments a date in yyyymmdd format (at least
;                  for the period 1901-2099).
;
; Input/Output:
;     the date in yyyymmdd format.
;
; Effect: changes the date.
;--------------------------------------------------------------------------------
pro date_increment, date

monthLength = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

year = date/10000
month = (date mod 10000)/100
day = date mod 100

day = day + 1
if (day gt monthLength(month-1) and (not((year mod 4) eq 0 and month eq 2 $
                                       and day eq 29))) then begin
    day = 1
    month = month + 1
    if (month eq 13) then begin
        month = 1
        year = year + 1
    endif
endif

date = year*10000 + month*100 + day

end


;--------------------------------------------------------------------------------
; get_ice_file_list - returns a list of the sea ice concentration files
;                     for the given date range, and hemisphere.
;
; Input:
;     start_date - the start of the date range in yyyymmdd format.
;     end_date - the end of the date range in yyyymmdd format.
;     hemisphere - 1: northern hemisphere; 2: southern hemisphere.
;     algorithm - 1: NASATeam; 2: Bootstrap
;     dir_name - the name of the directory the sea ice concentration files
;                are in.
;
; Output:
;     none.
;
; Return Value:
;     a list of file names or -1 if there is an error.
;--------------------------------------------------------------------------------
function get_ice_file_list, start_date, end_date, hemisphere, algorithm, $
                            sat_no, dir_name

if (start_date gt end_date or hemisphere lt 1 or hemisphere gt 2 or $
    algorithm lt 1 or algorithm gt 2 or STRLEN(dir_name) lt 1) then begin
    list_size = 0
    PRINT, 'Not able to generate list of sea ice concentration files.'
    goto, FINISH
endif

alg_char = ['n', 'b']
hemisphere_char = ['n', 's']

;
; Find out whether file names have 2-digit or 4-digit years.
;
result = FILE_SEARCH(STRING(FORMAT='(a,a1,a1,a,i2.2,a,a1,a4)', $
                            dir_name, '/', alg_char[algorithm-1], $
                            't_????????_[fn]', sat_no, '_*_', $
                            hemisphere_char[hemisphere-1], '.bin'))

;
; Loop thru the dates in the date range, construct the file names,
; and append them to the full directory name.
;
cur_date = start_date
list_size = 0
while (cur_date le end_date) do begin
    str_cur_date = STRING(FORMAT='(i6.6)', cur_date mod 1000000)
    for r=0,N_ELEMENTS(result) - 1 do begin
        if STRPOS(result[r], str_cur_date) gt -1 then begin
            list_size = list_size + 1
            temp = MAKE_ARRAY(list_size, /STRING)
            if (list_size gt 1) then temp[0:list_size - 2] = file_list
            temp[list_size - 1] = result[r]
            file_list = temp
        endif
    endfor

    ;
    ; Go to the next day.
    ;
    date_increment, cur_date

endwhile

FINISH: if list_size eq 0 then return, ['-1'] else return, file_list
end


;--------------------------------------------------------------------------------
; get_monthly_file_list - returns a list of the sea ice concentration files
;                         for the given month range and hemisphere.
;
; Input:
;     start_month - the start of the date range in yyyymm format.
;     end_month - the end of the date range in yyyymm format.
;     hemisphere - 1: northern hemisphere; 2: southern hemisphere.
;     algorithm - 1: NASATeam; 2: Bootstrap
;     sat_no - the satellite number (7, 8, 11, 13, or 17).
;     dir_name - the name of the directory the sea ice concentration files
;                are in.
;
; Output:
;     none.
;
; Return Value:
;     a list of file names or -1 if there is an error.
;--------------------------------------------------------------------------------
function get_monthly_file_list, start_month, end_month, hemisphere, algorithm, $
                                sat_no, dir_name

if (start_month gt end_month or hemisphere lt 1 or hemisphere gt 2 or $
    algorithm lt 1 or algorithm gt 2 or strlen(dir_name) lt 1 or $
    (sat_no eq 7 or sat_no ne 8 and sat_no ne 11 and $
     sat_no ne 13 and sat_no ne 17)) then begin
    list_size = 0
    PRINT, 'Not able to generate list of sea ice concentration files.'
    goto, FINISH
endif

alg_char = ['n', 'b']
hemisphere_char = ['n', 's']

result = FILE_SEARCH(STRING(FORMAT='(a,a1,a1,a,i2.2,a,a1,a)', $
                            dir_name, '/', alg_char[algorithm-1], $
                            't_??????_[fn]', sat_no, '_*_', $
                            hemisphere_char[hemisphere - 1], '.bin'))

;
; Loop thru the dates in the date range, construct the file names,
; and append them to the full directory name.
;
cur_month = start_month
list_size = 0
while (cur_month le end_month) do begin

   str_cur_month = STRING(format='(i6.6)', cur_month)
   for r=0,N_ELEMENTS(result)-1 do begin
      if STRPOS(result[r], str_cur_month) gt -1 then begin
         list_size = list_size + 1
         temp = MAKE_ARRAY(list_size, /STRING)
         if (list_size gt 1) then temp[0:list_size - 2] = file_list
         temp[list_size - 1] = result[r]
         file_list = temp
      endif
   endfor

    cur_month = cur_month + 1
    if ((cur_month mod 100) eq 13) then begin
        cur_month = cur_month - 12
        cur_month = cur_month + 100
    endif
endwhile

FINISH: if list_size eq 0 then return, ['-1'] else return, file_list
end


;--------------------------------------------------------------------------------
; get_ESMR_file_list - returns a list of the ESMR sea ice concentration files
;                      for the given date range, and hemisphere.
;
; Input:
;     start_date - the start of the date range in yyyymmdd format.
;     end_date - the end of the date range in yyyymmdd format.
;     hemisphere - 1: northern hemisphere; 2: southern hemisphere.
;     threshold - 1: 0%; 2: 15%.
;     dir_name - the name of the directory the sea ice concentration files
;                are in.
;
; Output:
;     none.
;
; Return Value:
;     a list of file names or -1 if there is an error.
;--------------------------------------------------------------------------------
function get_ESMR_file_list, start_date, end_date, hemisphere, threshold, $
                             dir_name


if (start_date gt end_date or hemisphere lt 1 or hemisphere gt 2 or $
    STRLEN(dir_name) lt 1) then begin
    list_size = 0
    PRINT, 'Not able to generate list of sea ice concentration files.'
    goto, FINISH
endif

hemisphere_char = ['n', 's']
threshold_str = ['00', '15']

;
; Loop thru the dates in the date range, construct the file names,
; and append them to the full directory name.
;
cur_date = start_date
list_size = 0
while (cur_date le end_date) do begin
    jday = JULDAY((cur_date/100) mod 100, cur_date mod 100, cur_date/10000, $
                  0, 0, 0)
    jday_1 = JULDAY(1, 1, cur_date/10000, 0, 0, 0)
    ydoy = (cur_date/10000)*1000 + (jday - jday_1 + 1)
    file_name = STRING('ESMR-' , ydoy, '.t', $
                       hemisphere_char(hemisphere - 1), 'e.', $
                       threshold_str(threshold - 1), $
                       FORMAT='(a5, i7.7, a2, a1, a2, a2)')
    file_name = dir_name + '/' + file_name

    ;
    ; Make sure the file exists.
    ;
    result = FINDFILE(file_name, COUNT=count)
    if count gt 0 then begin
        list_size = list_size + 1
        temp = MAKE_ARRAY(list_size, /STRING)
        if (list_size gt 1) then temp[0:list_size - 2] = file_list
        temp[list_size - 1] = file_name
        file_list = temp
    endif

    ;
    ; Go to the next day.
    ;
    date_increment, cur_date

endwhile

FINISH: if list_size eq 0 then return, ['-1'] else return, file_list
end


;--------------------------------------------------------------------------------
; get_ESMR_monthly_file_list - returns a list of the ESMR sea ice concentration
;                              files for the given month range and hemisphere.
;
; Input:
;     start_month - the start of the date range in yyyymm format.
;     end_month - the end of the date range in yyyymm format.
;     hemisphere - 1: northern hemisphere; 2: southern hemisphere.
;     dir_name - the name of the directory the sea ice concentration files
;                are in.
;
; Output:
;     none.
;
; Return Value:
;     a list of file names or -1 if there is an error.
;--------------------------------------------------------------------------------
function get_ESMR_monthly_file_list, start_month, end_month, hemisphere, $
                                     dir_name

if (start_month gt end_month or hemisphere lt 1 or hemisphere gt 2 or $
    STRLEN(dir_name) lt 1) then begin
    list_size = 0
    PRINT, 'Not able to generate list of sea ice concentration files.'
    goto, FINISH
endif

hemisphere_char = ['n', 's']

result = FILE_SEARCH(dir_name + '/ESMR-??????.t' + $
                     hemisphere_char[hemisphere - 1] + 'e.15')

;
; Loop thru the dates in the date range, construct the file names,
; and append them to the full directory name.
;
cur_month = start_month
list_size = 0
while (cur_month le end_month) do begin

    str_cur_month = STRING(format='(i6.6)', cur_month)
    for r=0,N_ELEMENTS(result) - 1 do begin
        if STRPOS(result[r], str_cur_month) gt -1 then begin
            list_size = list_size + 1
            temp = MAKE_ARRAY(list_size, /STRING)
            if (list_size gt 1) then temp[0:list_size - 2] = file_list
            temp[list_size - 1] = result[r]
            file_list = temp
        endif
    endfor

    cur_month = cur_month + 1
    if ((cur_month mod 100) eq 13) then begin
        cur_month = cur_month - 12
        cur_month = cur_month + 100
    endif
endwhile

FINISH: if list_size eq 0 then return, ['-1'] else return, file_list
end


;--------------------------------------------------------------------------------
; get_ESMR_means_file_list - returns a list of the sea ice concentration files
;                            for the given month range and hemisphere.
;
; Input:
;     start_month - the start of the date range in mm format.
;     end_month - the end of the date range in mm format.
;     hemisphere - 1: northern hemisphere; 2: southern hemisphere.
;     dir_name - the name of the directory the sea ice concentration files
;                are in.
;
; Output:
;     none.
;
; Return Value:
;     a list of file names or -1 if there is an error.
;--------------------------------------------------------------------------------
function get_ESMR_means_file_list, start_month, end_month, hemisphere, $
                                   dir_name

if (start_month gt end_month or hemisphere lt 1 or hemisphere gt 2 or $
    STRLEN(dir_name) lt 1) then begin
    list_size = 0
    PRINT, 'Not able to generate list of sea ice concentration files.'
    goto, FINISH
endif

hemisphere_char = ['n', 's']

result = FILE_SEARCH(dir_name + '/ESMR-????-????-??.t' + $
                     hemisphere_char[hemisphere - 1] + 'e.15')

;
; Loop thru the dates in the date range, construct the file names,
; and append them to the full directory name.
;
cur_month = start_month
list_size = 0
while (cur_month le end_month) do begin

    str_cur_month = STRING(FORMAT='(i2.2)', cur_month)
    for r=0,N_ELEMENTS(result) - 1 do begin
        if STRPOS(result[r], str_cur_month) gt -1 then begin
            list_size = list_size + 1
            temp = MAKE_ARRAY(list_size, /STRING)
            if (list_size gt 1) then temp[0:list_size - 2] = file_list
            temp[list_size - 1] = result[r]
            file_list = temp
        endif
    endfor

    cur_month = cur_month + 1
endwhile

FINISH: if list_size eq 0 then return, ['-1'] else return, file_list
end


;-------------------------------------------------------------------------------
; read_data_file - gets the brightness temperatures from a data file.
;
; Input:
;     path - complete path name of data file.
;     xdim - the X dimension of the data grid.
;     ydim - the Y dimension of the data grid.
;
; Output:
;     none.
;
; Return Value:
;     structure containing an image array and a color palette array. Both
;     arrays will be zero-filled if there is an error.
;-------------------------------------------------------------------------------
function read_data_file, path, xdim, ydim

status = 0

tmp = INTARR(xdim, ydim)

if (STRLEN(path) lt 1 or xdim lt 1 or ydim lt 1) then goto, FINISH

result = FILE_SEARCH(path, COUNT=count)
if count gt 0 then begin
    ;
    ; Data file WAS found.
    ;
    if STRPOS(path, 'bt_') gt 0 then begin
       tmp = INTARR(xdim, ydim)
       OPENR, lun, path, /GET_LUN
       READU, lun, tmp
       FREE_LUN, lun
       filter = WHERE(tmp le 1000, count)
       if count gt 0 then tmp[filter] = BYTE(0.1*tmp[filter] + 0.5)
       filter = WHERE(tmp eq 1100, count)
       if count gt 0 then tmp[filter] = 157
       filter = WHERE(tmp eq 1200, count)
       if count gt 0 then tmp[filter] = 168
       ice = ROTATE(tmp, 7)
    endif else if STRPOS(path, 'nt_') gt 0 then begin
       tmp = BYTARR(xdim, ydim)
       hdr = BYTARR(300)
       OPENR, lun, path, /GET_LUN
       READU, lun, hdr
       READU, lun, tmp
       FREE_LUN, lun
       ice = tmp
       filter = WHERE(tmp le 250, count)
       if count gt 0 then tmp[filter] = BYTE(0.4*tmp[filter] + 0.5)
       filter = WHERE(tmp eq 253 or tmp eq 254, count)
       if count gt 0 then tmp[filter] = 168
       ice = ROTATE(tmp, 7)
    endif else begin
       tmp = BYTARR(xdim, ydim)
       palette = BYTARR(3, 256)
       HDF_DFR8_GETIMAGE, path, tmp, palette
       filter = WHERE(tmp eq 125, count)
       if count gt 0 then tmp[filter] = 0
       ice = ROTATE(tmp, 7)
    endelse
endif else begin
    ;
    ; Data file was NOT found.
    ;
   tmp = BYTARR(xdim, ydim)
   tmp[0:xdim-1, 0:ydim-1] = 157
   PRINT, 'File ', path, ' not found.'
endelse

FINISH:

return, ice
end


;--------------------------------------------------------------------------------
; get_image_size - returns the dimensions of a sea ice concentration array.
;
; Input:
;     hemisphere - 1: northern hemisphere; 2: southern hemisphere.
;
; Output:
;     xdim - the number of columns or -1 if there is an error.
;     ydim - the number of rows or -1 if there is an error.
;--------------------------------------------------------------------------------
pro get_image_size, hemisphere, xdim, ydim

if (hemisphere eq 1) then begin
    xdim = 304
    ydim = 448
endif else if (hemisphere eq 2) then begin
    xdim = 316
    ydim = 332
endif else begin
    xdim = -1
    ydim = -1
endelse

end


;--------------------------------------------------------------------------------
; extract_ice - extracts a sea ice concentation time series.
;
; Input:
;     none.
;
; Output:
;     sea_ice - sea ice concentration time series (xdim x ydim x number of
;               days).
;--------------------------------------------------------------------------------
pro extract_ice, sea_ice


;
; Get input from user.
;
prod_type = get_processing_type()
timeRes = get_time_resolution(prod_type)
dates = get_dates(timeRes)
if (dates.start_date eq 0 or dates.end_date eq 0) then goto, FINISH
hemisphere = get_hemisphere()
dir_name = get_dir()

if (dir_name eq ' ') then begin
    PRINT, 'Directory name was not entered. Please start program again.'
    goto, FINISH
endif

;
; Get the files that match the input criteria.
;
if (prod_type eq 1) then begin
   sat_no = get_satellite_number()
   algorithm = get_algorithm(dir_name, hemisphere, sat_no)
   if (algorithm eq -1) then begin
      PRINT, 'Either there were no files for your selected algorithm/ice type'
      PRINT, 'combination or an invalid parameter was entered.'
      PRINT, 'Please start program again.'
      goto, FINISH
   endif
   if (timeRes eq 1) then begin
      ice_file_list = get_ice_file_list(dates.start_date, dates.end_date, $
                                        hemisphere, algorithm, sat_no, $
                                        dir_name)
   endif else if (timeRes eq 2) then begin
      ice_file_list = get_monthly_file_list(dates.start_date, $
                                            dates.end_date, $
                                            hemisphere, algorithm, $
                                            sat_no, dir_name)
   endif
endif else if (prod_type eq 2) then begin
    if (timeRes eq 1) then begin
        threshold = get_ESMR_threshold()
        ice_file_list = get_ESMR_file_list(dates.start_date, dates.end_date, $
                                           hemisphere, threshold, dir_name)
    endif else if (timeRes eq 2) then begin
        ice_file_list = get_ESMR_monthly_file_list(dates.start_date, $
                                                   dates.end_date, $
                                                   hemisphere, dir_name)
    endif else if (timeRes eq 3) then begin
        ice_file_list = get_ESMR_means_file_list(dates.start_date, $
                                                 dates.end_date, $
                                                 hemisphere, dir_name)
    endif
endif

;
; If files were found, read them.
;
if (N_ELEMENTS(ice_file_list) eq 1 and ice_file_list(0) eq '-1') then begin
    PRINT, 'No files for the period ', dates.start_date, ' to ', dates.end_date
endif else begin
    get_image_size, hemisphere, xdim, ydim
    sea_ice = BYTARR(xdim, ydim, n_elements(ice_file_list))
    for i=0,N_ELEMENTS(ice_file_list)-1 do begin
        PRINT, ice_file_list(i)
        ice = read_data_file(ice_file_list(i), xdim, ydim)
        sea_ice(*,*,i) = ice(*,*)
    endfor
endelse

FINISH:
end
