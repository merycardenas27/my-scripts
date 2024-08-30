#!/bin/bash

# This script gets the width of an image
# using file and awk (for basic formats like PNG, JPEG)

# Notes:
# The file command works for common formats like PNG and JPEG,
# but may not be as robust for all types of images.

# 1. Make this script executable
# chmod +x get_image_width_option_1.sh

# 2. Run this script
# ./get_image_width_option_1.sh ./example_image.jpg

# Path to the image file
IMAGE_PATH="$1"

# Get the image dimensions
DIMENSIONS=$(file "$IMAGE_PATH" | grep -oP '\d+x\d+')

# Extract the width
IMAGE_WIDTH=$(echo $DIMENSIONS | awk -Fx '{print $1}')

# Output the width
echo "The width of the image is: $IMAGE_WIDTH pixels"