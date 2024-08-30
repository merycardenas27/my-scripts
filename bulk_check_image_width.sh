#!/bin/bash

# Run script
# ./bulk_check_image_width.sh ./input_file.csv ./images

# Read the file
INPUT_FILE="$1"
sed -i $'s/\r$//' "$INPUT_FILE"

# Directory to search in
SEARCH_DIR="$2"

# Define the output CSV file name
OUTPUT_FILE="output_file.csv"

# Initialize empty arrays
FILENAMES=()
CODES=()

while IFS=',' read -r FILENAME HANDLE SKU SOURCE FORMAT; do
  # Skip the header line (assuming first line is header)
  if [[ $FILENAME == "Image Name" && $HANDLE == "Handle" && $SKU == "Variant SKU" && $SOURCE == "Image Src" && $FORMAT == "Image Format" ]]; then
    continue
  fi
  # Add values to arrays
  FILENAMES+=("$FILENAME")
  CODES+=("$SKU")
done < $INPUT_FILE

for i in "${!FILENAMES[@]}"; do
  # Path to the image file
  IMAGE_PATH="$SEARCH_DIR/${FILENAMES[i]}"

  # Get the image width
  IMAGE_WIDTH=$(identify -format "%w" "$IMAGE_PATH")

  # Check if the width is 1000 pixels
  if [ "$IMAGE_WIDTH" -eq 1000 ]; then
    echo "The ${CODES[i]} image is 1000 pixels wide."
  else
    echo "${CODES[i]}" >> "$OUTPUT_FILE"
    echo "The ${CODES[i]} image is not 1000 pixels wide. It is $IMAGE_WIDTH pixels wide."
  fi
  # echo "Index $i: ${FILENAMES[i]} ${CODES[i]}"
done
