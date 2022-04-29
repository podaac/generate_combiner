# combiner

The combiner processes and combines files for MODIS Aqua and MODIS Terra (SST/SST4/OC) as well as VIIRS (SST/SST3). Input data is created from the downloader component.

## pre-requisites to building

An IDL license for executing IDL within the Docker container. This can be accomplished by mounting your local IDL installation into the Docker container.

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

`docker build --tag combiner:0.1 . `

## execute command

MODIS A: 
`docker run --name gen-comb -v /combiner/input:/data/input -v /combiner/jobs:/data/jobs -v /combiner/logs:/data/logs -v /combiner/scratch:/data/scratch -v /usr/local:/usr/local combiner:0.1 30 300 yes MODIS_A QUICKLOOK`
`docker run --name gen-comb -v /combiner/input:/data/input -v /combiner/jobs:/data/jobs -v /combiner/logs:/data/logs -v /combiner/scratch:/data/scratch -v /usr/local:/usr/local combiner:0.1 30 300 yes MODIS_A REFINED`

MODIS T: 
`docker run --name gen-comb -v /combiner/input:/data/input -v /combiner/jobs:/data/jobs -v /combiner/logs:/data/logs -v /combiner/scratch:/data/scratch -v /usr/local:/usr/local combiner:0.1 30 300 yes MODIS_T QUICKLOOK`
`docker run --name gen-comb -v /combiner/input:/data/input -v /combiner/jobs:/data/jobs -v /combiner/logs:/data/logs -v /combiner/scratch:/data/scratch -v /usr/local:/usr/local combiner:0.1 30 300 yes MODIS_T REFINED`

VIIRS: 
`docker run --name gen-comb -v /combiner/input:/data/input -v /combiner/jobs:/data/jobs -v /combiner/logs:/data/logs -v /combiner/scratch:/data/scratch -v /usr/local:/usr/local combiner:0.1 25 300 yes VIIRS QUICKLOOK`
`docker run --name gen-comb -v /combiner/input:/data/input -v /combiner/jobs:/data/jobs -v /combiner/logs:/data/logs -v /combiner/scratch:/data/scratch -v /usr/local:/usr/local combiner:0.1 25 300 yes VIIRS REFINED`

**NOTES**
- In order for the commands to execute the `/combiner/` directories will need to point to actual directories on the system.
- The `/usr/local` directory contains the IDL license requirements.