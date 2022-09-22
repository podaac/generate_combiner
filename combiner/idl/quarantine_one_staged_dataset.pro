;  Copyright 2014, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

; Function quarantine a staged granule to a directory so the operator can inspect it.
; This function should be called before the usual clean up because of the new way the files are staged by using
; a move instead of a copy, the original file is no longer around.  Using this function will allow us to keep a copy around for inspection.
;

FUNCTION quarantine_one_staged_dataset, $
             i_data_filename

; Load constants.  No ending semicolon is required.

@modis_data_config.cfg

; Returned status.  Value of 0 means ok, 1 means bad.

o_status = SUCCESS;

; Remove the data file.
destination_of_quarantine = GETENV('SCRATCH_AREA') + "/quarantine";

; Create the directory if it does not exist yet.

if (~FILE_TEST(destination_of_quarantine)) then begin
    print, 'quarantine_one_staged_dataset:INFO, Creating directory ' + destination_of_quarantine 
    FILE_MKDIR, destination_of_quarantine;
endif

if (FILE_TEST(i_data_filename)) then begin
    now_is = SYSTIME();
    print, now_is + ' ERROR ' + '[quarantine_one_staged_dataset] FILE_MOVE_TO_QUARANTINE ' + i_data_filename + ' ' + destination_of_quarantine;
    FILE_COPY, i_data_filename, destination_of_quarantine, /OVERWRITE;
endif

if (FILE_TEST(i_data_filename + ".bz2")) then begin
    now_is = SYSTIME();
    print, now_is + ' ERROR ' + '[quarantine_one_staged_dataset] FILE_MOVE_TO_QUARANTINE ' + i_data_filename + '.bz2' + ' ' + destination_of_quarantine;
    FILE_COPY, i_data_filename + '.bz2' , destination_of_quarantine, /OVERWRITE;
endif

RETURN, o_status;
END