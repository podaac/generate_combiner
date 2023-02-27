#!/bin/csh
#
#  Copyright 2012, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

#
# This is the C-shell wrapper to execute the 2 top level scripts uncompress the SST/SST4/OC files and combine the SST/SST4/OC files into one file
# to be made available as input to the MODIS L2P Processing.
#
# It will usually be ran as part of a cronjob.
# The log files created will be in directory $HOME/logs with the extension .log
# See below for the names for each script.  There should be 2 for the uncompression and 4 for the combining.

# Set the environments.

# source $HOME/define_modis_operation_environment_for_combiner
source /app/config/combiner_config    # NET edit (Docker container)

# Get the input.

if ($# != 7) then
    echo "startup_modis_level2_combiners:ERROR, You must specify exactly 6 arguments: num_files_to_combine num_minutes_to_wait value_move_instead_of_copy data_type processing_type job_index json_file"
    exit 1
endif

# Arguments:
#
#  1 = num_files_to_combine
#  2 = num_minutes_to_wait
#  3 = value_move_instead_of_copy 
#  4 = data_type    # Either MODIS_A, MODIS_T, VIIRS
#  5 = processing_type    # Either QUICKLOOK, REFINED
#  6 = job_index    # Intenger index to locate file list

set num_files_to_combine       = $1
set num_minutes_to_wait        = $2
set value_move_instead_of_copy = $3
set data_type                  = $4
set processing_type            = $5
set job_index                  = $6
set json_file                  = $7

# Create the $HOME/logs directory if it does not exist yet    # NET edit.

set logging_dir = `printenv | grep COMBINER_LOGGING | awk -F= '{print $2}'`    # NET edit.
if (! -e $logging_dir) then    # NET edit.
    mkdir $logging_dir    # NET edit.
endif
set log_top_level_directory = $logging_dir     # NET edit.

# Create the log file

set today_date = `date '+%m_%d_%y'`
set random_number = `bash -c 'echo $RANDOM'`
set combiner_log_name = "$log_top_level_directory/level2_combiner_{$data_type}_{$processing_type}_output_{$today_date}_{$random_number}.log"   # Create unique combiner log
touch $combiner_log_name

# Set the input file name as an environment variable
setenv JSON_FILE $json_file

# Determine which script to call with specific parameters based on data_type

if ($data_type == "MODIS_A") then
    set script_name = "modis_level2_combiner_historical_job_index.pl"
    if ($processing_type == "QUICKLOOK") then
        set p_type = "AQUA_QUICKLOOK"
    else
        set p_type = "AQUA_REFINED"
    endif
else if ($data_type == "MODIS_T") then
    set script_name = "modis_level2_combiner_historical_job_index.pl"
    if ($processing_type == "QUICKLOOK") then
        set p_type = "TERRA_QUICKLOOK"
    else
        set p_type = "TERRA_REFINED"
    endif
else
    setenv GHRSST_OBPG_USE_2019_NAMING_PATTERN true
    set script_name = "generic_level2_combiner_job_index.pl"
    if ($processing_type == "QUICKLOOK") then
        set p_type = "VIIRS_QUICKLOOK"
    else
        set p_type = "VIIRS_REFINED"
    endif
endif

# Call the script to combine the files

perl $GHRSST_PERL_LIB_DIRECTORY/$script_name -data_source=$data_type -processing_type=$p_type -max_files=$num_files_to_combine -threshold_to_wait=$num_minutes_to_wait -perform_move_instead_of_copy=$value_move_instead_of_copy -job_index=$job_index >> $combiner_log_name
exit
