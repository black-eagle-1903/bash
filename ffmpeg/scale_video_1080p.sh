#!/bin/bash
# Scales source videdo file to 1080p without touching its audio

INPUT_VIDEO_FILE_PATH=$1
OUTPUT_VIDEO_FILE_PATH=$2

# 1st argument is the input video file
if [ -z "${INPUT_VIDEO_FILE_PATH}" ]; then
	echo "Error: Input video file path is not supplied!"
	exit 1
fi

# Check the existence of input video file path
if [ ! -e "${INPUT_VIDEO_FILE_PATH}" ]; then
	echo "Error: Input video file path does not exist!"
	exit 2
fi

# 3rd argument is the output video file
if [ -z "${OUTPUT_VIDEO_FILE_PATH}" ]; then
	echo "Error: Output video file path is not supplied!"
	exit 3
fi

ffmpeg -i "${INPUT_VIDEO_FILE_PATH}" -c:a copy -vf scale=1920:1080 "${OUTPUT_VIDEO_FILE_PATH}"