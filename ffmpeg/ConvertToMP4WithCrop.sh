#!/bin/bash
# Converts input video files to MP4 format using ffmpeg utility.
# The following 5 input arguments should be supplied:
#	1st argument	: Input video file path
#	2nd argument	: Average video rate
#	3rd argument	: Maximum video rate
#	4th argument	: Crop rectangle
#	5th argument	: Output MP4 video path
# v1.0

ffmpeg_BIN_PATH=/usr/bin/ffmpeg
INPUT_VIDEO_FILE=$1
AVERAGE_VIDEO_BITRATE=$2
MAXIMUM_VIDEO_BITRATE=$3
# Crop rectangle has 4 numbers separated by colon as output width, output height, x and y
# x is the horizontal y is the vertical start position of the rectangle
# e.g. 720:432:0:72
CROP_RECTANGLE=$4
OUTPUT_MP4_FILE=$5
PASS_LOG_FILE_PREFIX=${OUTPUT_MP4_FILE%.*}.pass
# Obtain the filename part of the current script file
CURRENT_SCRIPT_FILE=${0##*/}
CURRENT_SCRIPT_FILE=${CURRENT_SCRIPT_FILE%.*}
LOG_FILE_PATH=${OUTPUT_MP4_FILE%/*}/${CURRENT_SCRIPT_FILE}_$(date +"%d-%h-%Y_%H.%M.%S").log

function write_log
{
# If the second argument is 1 then display one blank line before
if [ "$2" == "1" ] ; then
	printf "\n" >> ${LOG_FILE_PATH}
fi
echo -e $(date +"%d-%h-%Y %H:%M:%S") $1 >> ${LOG_FILE_PATH}
}

# Perform the current encoding pass by executing the ffmpeg command line
# and log the output
function perform_encoding_pass
{
write_log "Issued ffmpeg command line as follows:"
echo -e $ffmpeg_command_line >> ${LOG_FILE_PATH}
$ffmpeg_command_line 2>${OUTPUT_MP4_FILE%/*}/ffmpeg_out_$(date +"%d-%h-%Y_%H.%M.%S").log
write_log ffmpeg execution return code:$?
}

# Check the existence of the input argument
# 1st argument is the arguments value, 2nd argument is the error message if it is not supplied
# and 3rd argument is the exit code
function check_input_argument
{
if [ -z "$1" ]; then
	echo "Error: "$2" is not supplied!" 
	exit $3
fi
}

check_input_argument "${INPUT_VIDEO_FILE}" "Input video file path" 1
check_input_argument "${AVERAGE_VIDEO_BITRATE}" "Average video bit rate" 2
check_input_argument "${MAXIMUM_VIDEO_BITRATE}" "Maximum video bit rate" 3
check_input_argument "${CROP_RECTANGLE}" "Video crop rectangle" 4
check_input_argument "${OUTPUT_MP4_FILE}" "Output MP4 file path" 5

# Explanations related to used command line options for ffmpeg executable
# -an				: Disable audio
# -b:v				: Video bitrate
# -maxrate			: Set maximum bitrate tolerance
# -bufsize     		: set ratecontrol buffer size (in bits)
# yadif				: specify the interlacing mode
# -bf				: B-Frames valid values from -1 to 16
# -mbd				: macroblock decision algorithm
# rd				: use best rate distortion
# mv4				: use four motion vectors per macroblock
# aic				: H.263 advanced intra coding / MPEG-4 AC
# mv0				: always try a mb with mv=<0,0>
# -trellis  		: rate-distortion optimal quantization
# -cmp				: full-pel ME compare function
# -subcmp			: sub-pel ME compare function
# -g				: set the group of picture (GOP) size
# -pass				: select the pass number (1 to 3)
# -fastfirstpass	: Use fast settings when encoding first
# -passlogfile		: select two pass log file name prefix
# strict			: how strictly to follow the standards (experimental: allow non-standardized experimental things)
# -y				: overwrite output files

write_log "Invoked command line as follows:"
echo -e "$0" "$@" >> ${LOG_FILE_PATH}

write_log "Starting 1st pass of video encoding..." 1
ffmpeg_command_line="${ffmpeg_BIN_PATH} -i ${INPUT_VIDEO_FILE} -an -vf "crop=${CROP_RECTANGLE}" -b:v ${AVERAGE_VIDEO_BITRATE} -maxrate:v ${MAXIMUM_VIDEO_BITRATE} -bufsize ${MAXIMUM_VIDEO_BITRATE} -pass 1 -fastfirstpass 0 -passlogfile ${PASS_LOG_FILE_PREFIX} -f mp4 -y /dev/null"
perform_encoding_pass
write_log "Finished 1st pass of video encoding."

write_log "Starting 2nd pass of video encoding..." 1 
ffmpeg_command_line="${ffmpeg_BIN_PATH} -i ${INPUT_VIDEO_FILE} -an -vf "crop=${CROP_RECTANGLE}" -b:v ${AVERAGE_VIDEO_BITRATE} -maxrate:v ${MAXIMUM_VIDEO_BITRATE} -bufsize ${MAXIMUM_VIDEO_BITRATE} -pass 2 -passlogfile ${PASS_LOG_FILE_PREFIX} -f mp4 -y /dev/null"
perform_encoding_pass
write_log "Finished 2nd pass of video encoding."

write_log "Starting 3rd pass of video encoding..." 1
ffmpeg_command_line="${ffmpeg_BIN_PATH} -i ${INPUT_VIDEO_FILE} -vf "crop=${CROP_RECTANGLE}" -b:v ${AVERAGE_VIDEO_BITRATE} -maxrate:v ${MAXIMUM_VIDEO_BITRATE} -bufsize ${MAXIMUM_VIDEO_BITRATE} -c:a copy -pass 3 -passlogfile ${PASS_LOG_FILE_PREFIX} ${OUTPUT_MP4_FILE}"
perform_encoding_pass
write_log "Finished 3rd pass of video encoding."
