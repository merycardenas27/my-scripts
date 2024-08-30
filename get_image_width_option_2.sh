#!/bin/bash

# This script gets the width of an image
# using ImageMagick (identify command)

# 1. Verify ImageMagick Installation
# Make sure that ImageMagick is correctly installed. You can check if the identify command is available by running:
# which identify

# If it is not installed, you can install it using the package manager for your operating system:
# Ubuntu/Debian:
# sudo apt-get install imagemagick

# 2. Make this script executable
# chmod +x get_image_width_option_2.sh

# 3. Run this script
# ./get_image_width_option_2.sh ./example_image.jpg

# Path to the image file
IMAGE_PATH="$1"

# Get the image width
IMAGE_WIDTH=$(identify -format "%w" "$IMAGE_PATH")

# Output the width
echo "The width of the image is: $IMAGE_WIDTH pixels"