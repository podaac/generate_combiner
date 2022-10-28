# combiner

The combiner processes and combines files for MODIS Aqua and MODIS Terra (SST/SST4/OC) as well as VIIRS (SST/SST3). Input data is created from the downloader component.

## pre-requisites to building

An IDL license for executing IDL within the Docker container. This can be accomplished by pointing a build argument to an IDL license server (see build command section).

The following IDL files must be compiled to `.sav` files:
- combine_netcdf_sst_and_sst3_files_to_netcdf.pro
- combine_netcdf_sst_and_sst4_files_to_netcdf.pro
- is_netcdf_granule_night_or_day.pro

To compile IDL files:
1. `cd` to the IDL directory (`combiner/idl`).
2. Execute `idl`.
3. Inside the IDL command prompt, execute: `.FULL_RESET_SESSION`
4. Inside the IDL command prompt, execute: `.COMPILE {file name without '.pro' extension}` 
    1. Example: `.COMPILE combine_netcdf_sst_and_sst3_files_to_netcdf`
5. Inside the IDL command prompt, execute: `RESOLVE_ALL`
6. Inside the IDL command prompt, execute: `SAVE, /ROUTINES, FILENAME='{file name}.sav'`
    1. Example: `SAVE, /ROUTINES, FILENAME='combine_netcdf_sst_and_sst3_files_to_netcdf.sav'`

## build command

`docker build --build-arg LICENSE_SERVER=http://xxx.xx.xx.xxx:4080 --build-arg IDL_INSTALLER=idlxxx-linux.tar.gz --build-arg IDL_VERSION=idlxx --tag combiner:0.1 .`

Build arguments:
- LICENSE_SERVER: The IP address of an IDL license server.
- IDL_INSTALLER: The file name of the IDL installer.
- IDL_VERSION: The version of IDL that will be installed.

## execute command

Arguemnts:
1.	num_files_to_combine
2.	num_minutes_to_wait
3.	value_move_instead_of_copy
4.	data_source
5.	processing_type
6.	job_index

MODIS A: 
`docker run --name gen-comb -v /combiner/input:/data -v /processor/input:/data/scratch combiner:0.1 30 300 yes MODIS_A QUICKLOOK 0`
`docker run --name gen-comb -v /combiner/input:/data -v /processor/input:/data/scratch combiner:0.1 30 300 yes MODIS_A REFINED 0`

MODIS T: 
`docker run --name gen-comb -v /combiner/input:/data -v /processor/input:/data/scratch combiner:0.1 30 300 yes MODIS_T QUICKLOOK 0`
`docker run --name gen-comb -v /combiner/input:/data -v /processor/input:/data/scratch combiner:0.1 30 300 yes MODIS_T REFINED 0`

VIIRS: 
`docker run --name gen-comb -v /combiner/input:/data -v /processor/input:/data/scratch combiner:0.1 25 300 yes VIIRS QUICKLOOK 0`
`docker run --name gen-comb -v /combiner/input:/data -v /processor/input:/data/scratch combiner:0.1 25 300 yes VIIRS REFINED 0`

**NOTES**
- In order for the commands to execute the `/combiner/` directories will need to point to actual directories on the system.
- IDL is installed and configured by the Dockerfile.