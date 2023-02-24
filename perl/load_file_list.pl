#!/usr/local/bin/perl

#  Copyright 2012, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
#
# Function that takes an input directory and JSON file and extracts a file list
# to process based on an index value.
#
#------------------------------------------------------------------------------------------------

use File::Basename;
use JSON;

sub load_file_list {

    my $status = 0;

    # Inputs
    my $download_dir = shift;
    my $processing_type = shift;
    my $job_index = shift;

    # Determine if running in cloud
    my $index;
    if ($job_index == -235) {
        $index = $ENV{AWS_BATCH_JOB_ARRAY_INDEX};
    } else {
        $index = $job_index;
    }

    # JSON data
    my $json_file = dirname($download_dir) . '/' . $ENV{JSON_FILE};
    my $json = do {
        open(my $json_fh, "<:encoding(UTF-8)", $json_file)
            or die("Can't open \"$json_file\": $!\n");
        local $/;
        <$json_fh>
    };
    
    # Retreive file list
    my $decoded = decode_json($json);
    my $file_list = $decoded->[$index];
    my @file_list_ref;
    for my $list ( @$file_list ) {
        push(@file_list_ref, "$download_dir/$list\n");
    }

    return ($status, \@file_list_ref);    
}

# ------------------------------------------------------------------------------

# my $download_dir = "/data/combiner/downloads/MODIS_AQUA_L2_SST_OBPG_REFINED";
# my $processing_type = "REFINED";
# my $job_index = 0;

# my ($status,$file_list_ref) = load_file_list($download_dir, $processing_type, $job_index);
# print "@$file_list_ref\n";