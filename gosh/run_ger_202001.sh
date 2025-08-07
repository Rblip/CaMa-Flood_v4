#!/bin/sh
#==========================================================
# CaMa-Flood German simulation script for January 2020
# -- Daily flood inundation dataset (FLD) for Germany
# -- Period: 2020-01-01 → 2020-01-31 (31 days)
# -- Based on test1-glb_15min.sh template
#
# (C) Modified for German flood simulation
#==========================================================

#*** PBS setting when needed
#PBS -q E20
#PBS -l select=1:ncpus=8:mem=16gb
#PBS -j oe
#PBS -m ea
#PBS -V

#================================================
# (0) Basic Setting

#*** 0a. Set CaMa-Flood base directory
BASE=`pwd`/..

echo $BASE

#*** 0b. Set dynamic library if needed
export IFORTLIB="/opt/intel/lib:/opt/intel/mkl/lib"
export HDF5LIB="/opt/local/hdf5/lib"
export DYLD_LIBRARY_PATH="${HDF5LIB}:${IFORTLIB}:${DYLD_LIBRARY_PATH}"

#*** 0c. OpenMP thread number (as specified in requirements)
export OMP_NUM_THREADS=8

#================================================
# (1) Experiment setting

#============================
#*** 1a. Experiment directory setting
EXP="ger_202001"                            # experiment name (German Jan 2020)
RDIR=${BASE}/out/${EXP}                     # directory to run CaMa-Flood
EXE="MAIN_cmf"                              # Execute file name
PROG=${BASE}/src/${EXE}                     # location of Fortran main program
NMLIST="./camakey_ger_202001.nml"           # namelist for German simulation
LOGOUT="./log_CaMa.txt"                     # standard log output

#============================
#*** 1b. Model physics option
DT=3600                                     # base DT (1 hour for 3-hourly forcing)
LADPSTP=".TRUE."                            # .TRUE. for adaptive time step
LPTHOUT=".TRUE."                            # .TRUE. to activate bifurcation flow
LDAMOUT=".FALSE."                           # .FALSE. no dams for this simulation

#============================
#*** 1c. simulation time (January 2020)
YSTA=2020                                   # start year
YEND=2020                                   # end year (same year)
SPINUP=0                                    # [0]: zero-storage start
NSP=1                                       # no spinup needed for this simulation

#============================
#*** 1d. spinup setting
LRESTART=".FALSE."                          # start from zero storage
CRESTSTO=""                                 # no restart file needed

#* output restart file
CRESTDIR="./"                               # output restart file directory
CVNREST="restart"                           # output restart file prefix
LRESTCDF=".FALSE."                          # .FALSE. for binary restart
IFRQ_RST="0"                                # only at last time

#============================
#*** 1e. river map & topography (placeholder - would need German map data)
FMAP="${BASE}/map/ger_6min"                 # German map directory (to be created)

#----- for plain binary map input
LMAPCDF=".FALSE."                           # .FALSE. for binary map input
CNEXTXY="${FMAP}/nextxy.bin"                # downstream xy (river network map)
CGRAREA="${FMAP}/ctmare.bin"                # unit-catchment area   [m2]
CELEVTN="${FMAP}/elevtn.bin"                # channel top elevation [m]
CNXTDST="${FMAP}/nxtdst.bin"                # downstream distance   [m]
CRIVLEN="${FMAP}/rivlen.bin"                # channel length        [m]
CFLDHGT="${FMAP}/fldhgt.bin"                # floodplain elevation profile [m]

#** channel parameter
CRIVWTH="${FMAP}/rivwth.bin"                # channel width [m]
CRIVHGT="${FMAP}/rivhgt.bin"                # channel depth [m]
CRIVMAN="${FMAP}/rivman.bin"                # manning coefficient river

#** bifurcation channel info
CPTHOUT="${FMAP}/bifprm.txt"                # bifurcation channel list

#============================
#*** 1f. forcing setting
CDIMINFO="${FMAP}/diminfo_efas_ger.txt"     # dimension information for EFAS
CINPMAT="${FMAP}/inpmat_efas_ger.bin"       # runoff input matrix for EFAS

IFRQ_INP="3"                                # 3-hourly EFAS forcing
DROFUNIT="0.001"                            # [mm/3h->m/s] unit conversion

#----- for netCDF runoff forcing (EFAS)
LINPCDF=".TRUE."                            # true for netCDF EFAS runoff
LINTERP=".TRUE."                            # .TRUE. to interpolate with input matrix
CROFDIR="${BASE}/inp/efas_ger/"             # EFAS runoff directory
CROFPRE=""                                  # netCDF file prefix
CROFSUF="EFAS_3h_GER_2020.nc"              # EFAS 3-hourly data for Germany

#============================
#*** 1g. Output Settings for flood inundation
IFRQ_OUT=24                                 # daily output (24h frequency)

LOUTCDF=".FALSE."                           # .FALSE. for binary output (as required)
COUTDIR="./"                                # output directory
CVARSOUT="flddph"                           # flood depth output (main requirement)
COUTTAG=""                                  # no tag (for daily files: outfldYYYYMMDD.bin)

##### Model Parameters ################
PMANRIV="0.03D0"                            # manning coefficient river
PMANFLD="0.10D0"                            # manning coefficient floodplain  
PCADP="0.7"                                 # safety coefficient for CFL condition
PDSTMTH="10000.D0"                          # downstream distance at river mouth [m]

#================================================
# (2) Initial setting

#*** 2a. create running dir
mkdir -p ${RDIR}
cd ${RDIR}

#*** 2b. clean old files
rm -rf ${RDIR}/*.bin
rm -rf ${RDIR}/*.nc
rm -rf ${RDIR}/*.log
rm -rf ${RDIR}/*.txt
rm -rf ${RDIR}/restart*

#================================================
# (3) Single simulation for January 2020

ln -sf $PROG $EXE

#*** 3a. Set simulation period (January 1-31, 2020)
SYEAR=2020
SMON=1
SDAY=1  
SHOUR=0

EYEAR=2020
EMON=2
EDAY=1
EHOUR=0

#================================================
# (4) Create NAMELIST for German simulation

rm -f ${NMLIST}

#*** 0. config
cat >> ${NMLIST} << EOF
&NRUNVER
LADPSTP  = ${LADPSTP}                  ! true: use adaptive time step
LPTHOUT  = ${LPTHOUT}                  ! true: activate bifurcation scheme  
LDAMOUT  = ${LDAMOUT}                  ! false: no dam operation
LRESTART = ${LRESTART}                 ! false: start from zero storage
/
&NDIMTIME
CDIMINFO = "${CDIMINFO}"               ! dimension information file
DT       = ${DT}                       ! time step length (sec)
IFRQ_INP = ${IFRQ_INP}                 ! input forcing frequency (3 hour for EFAS)
/
&NPARAM
PMANRIV  = ${PMANRIV}                  ! manning coefficient river
PMANFLD  = ${PMANFLD}                  ! manning coefficient floodplain
PDSTMTH  = ${PDSTMTH}                  ! downstream distance at river mouth [m]
PCADP    = ${PCADP}                    ! CFL coefficient
/
EOF

#*** 1. time  
cat >> ${NMLIST} << EOF
&NSIMTIME
SYEAR   = ${SYEAR}                     ! start year: 2020
SMON    = ${SMON}                      ! start month: 1 (January)
SDAY    = ${SDAY}                      ! start day: 1
SHOUR   = ${SHOUR}                     ! start hour: 0
EYEAR   = ${EYEAR}                     ! end year: 2020
EMON    = ${EMON}                      ! end month: 2 (February)  
EDAY    = ${EDAY}                      ! end day: 1
EHOUR   = ${EHOUR}                     ! end hour: 0
/
EOF

#*** 2. map
cat >> ${NMLIST} << EOF
&NMAP
LMAPCDF    = ${LMAPCDF}                ! false for binary map input
CNEXTXY    = "${CNEXTXY}"              ! river network nextxy
CGRAREA    = "${CGRAREA}"              ! catchment area
CELEVTN    = "${CELEVTN}"              ! bank top elevation
CNXTDST    = "${CNXTDST}"              ! distance to next outlet
CRIVLEN    = "${CRIVLEN}"              ! river channel length
CFLDHGT    = "${CFLDHGT}"              ! floodplain elevation profile
CRIVWTH    = "${CRIVWTH}"              ! channel width
CRIVHGT    = "${CRIVHGT}"              ! channel depth
CRIVMAN    = "${CRIVMAN}"              ! river manning coefficient
CPTHOUT    = "${CPTHOUT}"              ! bifurcation channel table
/
EOF

#*** 3. restart
cat >> ${NMLIST} << EOF
&NRESTART
CRESTSTO = "${CRESTSTO}"               ! restart file (empty for new start)
CRESTDIR = "${CRESTDIR}"               ! restart directory
CVNREST  = "${CVNREST}"                ! restart variable name
LRESTCDF = ${LRESTCDF}                 ! false for binary restart file
IFRQ_RST = ${IFRQ_RST}                 ! restart write frequency
/
EOF

#*** 4. forcing
cat >> ${NMLIST} << EOF
&NFORCE
LINPCDF  = ${LINPCDF}                  ! true for netCDF EFAS runoff
LINTERP  = ${LINTERP}                  ! true for runoff interpolation
CINPMAT  = "${CINPMAT}"                ! input matrix file name
DROFUNIT = ${DROFUNIT}                 ! runoff unit conversion [mm/3h->m/s]
CROFDIR  = "${CROFDIR}"                ! runoff input directory
CROFPRE  = "${CROFPRE}"                ! runoff input prefix
CROFSUF  = "${CROFSUF}"                ! EFAS runoff file
/
EOF

#*** 5. outputs
cat >> ${NMLIST} << EOF
&NOUTPUT
COUTDIR  = "${COUTDIR}"                ! output directory
CVARSOUT = "${CVARSOUT}"               ! flood depth output
COUTTAG  = "${COUTTAG}"                ! output tag (empty for daily files)
LOUTVEC  = .FALSE.                     ! false for 2D grid output
LOUTCDF  = ${LOUTCDF}                  ! false for binary output
NDLEVEL  = 0                           ! netCDF deflation level 
IFRQ_OUT = ${IFRQ_OUT}                 ! daily output frequency (24 hour)
/
EOF

#================================================
# (5) Execute main program

echo "Starting German flood simulation for January 2020..." `date` >> log.txt
time ./${EXE} >> log.txt 2>&1
echo "Finished German simulation" `date` >> log.txt

mv ${LOGOUT} log_CaMa-ger-202001.txt

#================================================
# (6) Post-processing: Verify daily flood files

echo "Verifying daily flood output files..." 
ls -la outfld*.bin 2>/dev/null | wc -l > file_count.txt
NFILES=`cat file_count.txt`

if [ $NFILES -eq 31 ]; then
  echo "SUCCESS: Found all 31 daily flood files for January 2020"
  ls -la outfld*.bin 
else
  echo "WARNING: Expected 31 files, found $NFILES daily flood files"
  ls -la outfld*.bin 2>/dev/null
fi

echo "German flood simulation completed!"
exit 0