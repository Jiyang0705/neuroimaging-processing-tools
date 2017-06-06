#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh

CNSP_webViewSlices_sliceBaseImg(){

	baseImgFolder=$1
	baseImgFilename=`echo $2 | awk -F'.' '{print $1}'`
	outputDir=$3

	# min_baseImg=`${FSLDIR}/bin/fslstats ${baseImgFolder}/${baseImgFilename} -R | awk '{print $1}'`
	# max_baseImg=`${FSLDIR}/bin/fslstats ${baseImgFolder}/${baseImgFilename} -R | awk '{print $2}'`
	min_baseImg=0
	max_baseImg=`${FSLDIR}/bin/fslstats ${baseImgFolder}/${baseImgFilename} -p 99.9`

	## slice base image
	${FSLDIR}/bin/slicer ${baseImgFolder}/${baseImgFilename} -i ${min_baseImg} ${max_baseImg} -u \
		-x 0.4 ${outputDir}/${baseImgFilename}_Slice_x1.png \
		-x 0.5 ${outputDir}/${baseImgFilename}_Slice_x2.png \
		-x 0.6 ${outputDir}/${baseImgFilename}_Slice_x3.png \
		-y 0.4 ${outputDir}/${baseImgFilename}_Slice_y1.png \
		-y 0.5 ${outputDir}/${baseImgFilename}_Slice_y2.png \
		-y 0.6 ${outputDir}/${baseImgFilename}_Slice_y3.png \
		-z 0.4 ${outputDir}/${baseImgFilename}_Slice_z1.png \
		-z 0.5 ${outputDir}/${baseImgFilename}_Slice_z2.png \
		-z 0.6 ${outputDir}/${baseImgFilename}_Slice_z3.png

	## merge base image slices
	${FSLDIR}/bin/pngappend ${outputDir}/${baseImgFilename}_Slice_x1.png \
		+ 10 ${outputDir}/${baseImgFilename}_Slice_x2.png \
		+ 10 ${outputDir}/${baseImgFilename}_Slice_x3.png \
		+ 10 ${outputDir}/${baseImgFilename}_Slice_y1.png \
		+ 10 ${outputDir}/${baseImgFilename}_Slice_y2.png \
		+ 10 ${outputDir}/${baseImgFilename}_Slice_y3.png \
		+ 10 ${outputDir}/${baseImgFilename}_Slice_z1.png \
		+ 10 ${outputDir}/${baseImgFilename}_Slice_z2.png \
		+ 10 ${outputDir}/${baseImgFilename}_Slice_z3.png \
		${outputDir}/png/${baseImgFilename}_Slices_merged.png

	## remove base image slices
	rm -f ${outputDir}/${baseImgFilename}_Slice_??.png
}


# $1 = base img folder
# $2 = base img filename
# $3 = output directory

CNSP_webViewSlices_sliceBaseImg $1 $2 $3