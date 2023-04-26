#!/bin/bash
#
# Script to delete required IDL installer and license file.
# 
# Example usage: ./deploy-clean.sh "s3://bucket"

ROOT_PATH="$PWD"
ROOT_LIST=$(ls $ROOT_PATH/idl/install/)
echo $ROOT_LIST

# rm -rf $ROOT_PATH/idl/install/idl882-linux.tar.gz
# rm -rf $ROOT_PATH/idl/install/lic_server.dat

# echo "Removed IDL installer and license files.
