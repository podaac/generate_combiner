;  Copyright 2014, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

; Function echo a message to screen with the time,  message type, routine name, and the message itself.
;

FUNCTION echo_message_to_screen, $
             i_routine_name, $
             i_msg_string, $
             i_msg_type

MSG_TYPE = 'UNKNOWN';

; Make a minor tweak the the message type to use all uppercase and using standard types.
; Unrecognized type will get UNKNOWN as the type.

if (i_msg_type EQ 'info')    then MSG_TYPE = 'INFO';
if (i_msg_type EQ 'error')   then MSG_TYPE = 'ERROR';
if (i_msg_type EQ 'warning') then MSG_TYPE = 'WARN';
if (i_msg_type EQ 'debug')   then MSG_TYPE = 'DEBUG';

; Print the message with the current time, message type, routine name and the message itself.

print, i_routine_name + ' - ' + MSG_TYPE + ': ' + i_msg_string;

RETURN, 1;
END
