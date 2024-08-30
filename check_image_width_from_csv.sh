#!/bin/bash

# Directory to search in
SEARCH_DIR="$1"

# Read the file
INPUT_FILE="./shopify_export_all_products.csv"
sed -i $'s/\r$//' "$INPUT_FILE"

# Define the output CSV file name
OUTPUT_FILE="image_size_to_fix.csv"

# Define the columns (adjust this according to your needs)
COLUMNS=("Handle" "Image_Size")

# Create the header row
echo "${COLUMNS[*]}" | sed 's/ /,/g' > "$OUTPUT_FILE"

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
    ROW=("${CODES[i]}","$IMAGE_WIDTH")
    echo "$ROW" >> "$OUTPUT_FILE"
    echo "The ${CODES[i]} image is not 1000 pixels wide. It is $IMAGE_WIDTH pixels wide."
  fi
  # echo "Index $i: ${FILENAMES[i]} ${CODES[i]}"
done

echo "CSV file '$OUTPUT_FILE' created successfully."