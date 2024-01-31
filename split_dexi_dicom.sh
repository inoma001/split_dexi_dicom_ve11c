#! /bin/bash

dcm_folder=$1
#first argument is the dicom folder (with no other files in it!)


# check if output directory already exists - don't want to overwrite data
if [ -d $dcm_folder"/nifti" ] 
then
    echo "Directory $dcm_folder"/nifti" exists - exiting ..." 
    exit 9999
else
    mkdir $dcm_folder"/nifti"
    mkdir $dcm_folder"/nifti/temp"
    mkdir $dcm_folder"/nifti/dexi_even"
    mkdir $dcm_folder"/nifti/dexi_odd"
fi

# calculate the effecitive TR

matlab -nodesktop -r "matlab_get_TReff('$dcm_folder');"

# read TReff from text file

fname=$dcm_folder"/TReff.txt"
TReff=$(cat "$fname")

echo $TReff

dcm2niix -o $dcm_folder"/nifti" $dcm_folder
dexi_file=$dcm_folder"/nifti/*.nii"

fslsplit $dexi_file $dcm_folder"/nifti/temp/split_data" "-t"

even_files=$dcm_folder"/nifti/temp/split*[02468].nii.gz"
odd_files=$dcm_folder"/nifti/temp/split*[13579].nii.gz"

cp $even_files $dcm_folder"/nifti/dexi_even/"
cp $odd_files $dcm_folder"/nifti/dexi_odd/"

echo "merging TE1 and TE2 data"

fslmerge "-tr" $dcm_folder"/nifti/TE2.nii.gz"  $odd_files $TReff
fslmerge "-tr" $dcm_folder"/nifti/TE1.nii.gz"  $even_files $TReff

echo "file clean up"
rm -R $dcm_folder"/nifti/temp"
rm -R $dcm_folder"/nifti/dexi_even"
rm -R $dcm_folder"/nifti/dexi_odd"

