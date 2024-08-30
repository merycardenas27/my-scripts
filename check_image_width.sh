#!/bin/bash

# This script checks if the width of an image is equal to the expected width,
# using ImageMagick (identify command)

# 1. Verify ImageMagick Installation
# Make sure that ImageMagick is correctly installed. You can check if the identify command is available by running:
# which identify

# If it is not installed, you can install it using the package manager for your operating system:
# sudo apt-get install imagemagick

# 2. Make this script executable
# chmod +x check_image_width.sh

# 3. Run this script
# ./check_image_width.sh ./example_image.jpg

# Path to the image file
IMAGE_PATH="$1"

# Get the image width
IMAGE_WIDTH=$(identify -format "%w" "$IMAGE_PATH")

# Check if the width is 1000 pixels
if [ "$IMAGE_WIDTH" -eq 1000 ]; then
  echo "The image is 1000 pixels wide."
else
  echo "The image is not 1000 pixels wide. It is $IMAGE_WIDTH pixels wide."
fi