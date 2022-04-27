#!/usr/local/bin/perl
#  Copyright 2019, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# Subroutine convert year, month, day to day of year.

use Date::Calc qw(Day_of_Year);

#my $o_doy = convert_year_mm_dd_to_doy(2019,1,1);
#print "2019,1,1,o_doy [$o_doy]\n";

#my $o_doy = convert_year_mm_dd_to_doy(2019,2,1);
#print "2019,2,1,o_doy [$o_doy]\n";
#my $o_doy = convert_year_mm_dd_to_doy(2019,2,1);
#print "2019,2,3,o_doy [$o_doy]\n";

#------------------------------------------------------------------------------------------------------------------------
sub convert_year_mm_dd_to_doy {
    my $i_year = shift;
    my $i_mm   = shift;
    my $i_dd   = shift;

    my $function_name = 'convert_year_mm_dd_to_doy:';

    my $o_doy = Day_of_Year($i_year, $i_mm, $i_dd);

    return($o_doy);
}

