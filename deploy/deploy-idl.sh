#!/bin/bash
#
# Script to download required IDL installer and license file.
#
# Command line arguments:
# [1] s3_bucket: URI of S3 bucket to get files from
# 
# Example usage: ./deploy-idl.sh "SIT" "s3://bucket" "idl882-linux.tar.gz"

VENUE=$1
S3_BUCKET=$2
IDL_INSTALLER=$3
ROOT_PATH="$PWD"

# Determine correct license file to download
if [ $VENUE = 'SIT' ]; then
    LICENSE_FILE=sintegration_lic_server.dat
elif [ $VENUE = 'UAT' ]; then
    LICENSE_FILE=uacceptance_lic_server.dat
else
    LICENSE_FILE=production_lic_server.dat
fi

# Download files
aws s3 cp $S3_BUCKET/$IDL_INSTALLER $ROOT_PATH/idl/install/$IDL_INSTALLER
aws s3 cp $S3_BUCKET/$LICENSE_FILE $ROOT_PATH/idl/install/lic_server.dat
