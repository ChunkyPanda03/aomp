#!/bin/bash
# 
#  create_release_tarball.sh: 
#
#  This is how we create the release source tarball.  Only run this after a successful build
#  so that this captures patched files because the root Makefile turns off patching
#
# --- Start standard header to set build environment variables ----
function getdname(){
   local __DIRN=`dirname "$1"`
   if [ "$__DIRN" = "." ] ; then
      __DIRN=$PWD;
   else
      if [ ${__DIRN:0:1} != "/" ] ; then
         if [ ${__DIRN:0:2} == ".." ] ; then
               __DIRN=`dirname $PWD`/${__DIRN:3}
         else
            if [ ${__DIRN:0:1} = "." ] ; then
               __DIRN=$PWD/${__DIRN:2}
            else
               __DIRN=$PWD/$__DIRN
            fi
         fi
      fi
   fi
   echo $__DIRN
}
thisdir=$(getdname $0)
[ ! -L "$0" ] || thisdir=$(getdname `readlink "$0"`)
. $thisdir/aomp_common_vars
# --- end standard header ----

#  We need to copy or create a makefile in the root directory before tar
cp -p $AOMP_REPOS/aomp/Makefile $AOMP_REPOS/Makefile


REPO_NAMES="$AOMP_PROJECT_REPO_NAME $AOMP_LIBDEVICE_REPO_NAME $AOMP_HCC_REPO_NAME $AOMP_HIP_REPO_NAME $AOMP_RINFO_REPO_NAME $AOMP_ROCT_REPO_NAME $AOMP_ROCR_REPO_NAME $AOMP_ATMI_REPO_NAME $AOMP_EXTRAS_REPO_NAME $AOMP_COMGR_REPO_NAME $AOMP_FLANG_REPO_NAME"
patchloc=$thisdir/patches
export IFS=" "
for repo_name in $REPO_NAMES
do
   patchdir=$AOMP_REPOS/$repo_name
   patchrepo
done

# Make the tarball from the parent of the aomp directory that contains all the git
# repositories and the Makefile used by spack
cd $AOMP_REPOS/..

# This file will be uploaded to the release directory
tarball="aomp-${AOMP_VERSION_STRING}.tar.gz"
cmd="tar --exclude-from $thisdir/create_release_tarball_excludes -czf $tarball aomp"
echo time $cmd
time $cmd
echo
ls -lh $tarball
echo 
echo done creating $PWD/$tarball
echo

for repo_name in $REPO_NAMES
do
   patchdir=$AOMP_REPOS/$repo_name
   removepatch
done


