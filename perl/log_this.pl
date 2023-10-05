#!/usr/local/bin/perl
#  Copyright 2012, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$

#------------------------------------------------------------------------------------------------------------------------

sub log_this {
    # Function to log a message to screen.
    my $i_log_type      = shift;  # Possible types are {INFO,WARN,ERROR}
    my $i_function_name = shift;  # Where the logging is coming from.  Useful in debuging if something goes wrong.
    my $i_log_message   = shift;  # The text you wish to log screen.

    # my $now_is = localtime;

    # print $now_is . " " . $i_log_type . " [" . $i_function_name . "] " . $i_log_message . "\n";

    print $i_function_name . " - " . $i_log_type . ": " . $i_log_message . "\n";
}

