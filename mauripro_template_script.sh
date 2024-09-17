#!/bin/bash

# Run the Script:
# ./mauripro_template_script.sh ./input_file.csv ./brand-images

BRAND="$1"
DATA_FILE="$2"
# TARGET_DIRECTORY="$3"
# SEARCH_DIRECTORY="$3"

DEFAULT_FILEPATH="images/NO-IMAGE.jpg"
BRAND_FILEPATHS=()

# Andersen brand
BRAND_FILEPATHS+=("Andersen/images/pi/2024/Andersen_logo.jpg")
# Lewmar brand
BRAND_FILEPATHS+=("Lewmar/images/pi/Jun-18/spares_540x540.jpg")
BRAND_FILEPATHS+=("Lewmar/images/pi/Jun-18/spares.jpg")

# Dessalator brand
BRAND_FILEPATHS+=("Dessalator/pi/logo.jpg")

# Initialize empty arrays
CODES=()
BRANDS=()
FILEPATHS=()

# Define the output CSV file name
REPORT_FILE="Reports/${BRAND}-image-report.csv"

# Define the output directory
TARGET_DIRECTORY="Fixed-Images/${BRAND}_fixed"

VERIFY_BRAND_FILEPATH (){
  local SEARCH_STRING="$1"

  # Flag to indicate if the string was found
  IS_FOUND=false

  # Loop through the array
  for ELEMENT in "${BRAND_FILEPATHS[@]}"; do
    if [ "$ELEMENT" = "$SEARCH_STRING" ]; then
      IS_FOUND=true
      break
    fi
  done

  echo "$IS_FOUND"
}

EXTRACT_DATA () {
  # Define the CSV file
  CSV_FILE="$1"
  sed -i $'s/\r$//' "$CSV_FILE"

  # Use awk to extract the first and third columns and store them in arrays
  readarray -t COLUMN1 < <(awk -F, 'NR > 1 { print $1 }' "$CSV_FILE")
  readarray -t COLUMN2 < <(awk -F, 'NR > 1 { print $2 }' "$CSV_FILE")
  readarray -t COLUMN3 < <(awk -F, 'NR > 1 { print $3 }' "$CSV_FILE")

  # readarray -t COLUMN1 < <(awk -F, 'NR > 101 && NR<=111 { print $1 }' "$CSV_FILE")
  # readarray -t COLUMN2 < <(awk -F, 'NR > 101 && NR<=111 { print $2 }' "$CSV_FILE")
  # readarray -t COLUMN3 < <(awk -F, 'NR > 101 && NR<=111 { print $3 }' "$CSV_FILE")

  CODES=("${COLUMN1[@]}")
  BRANDS=("${COLUMN2[@]}")
  FILEPATHS=("${COLUMN3[@]}")
}

EXTRACT_DATA "$DATA_FILE"

SEARCH_FILE () {
  local FILEPATH="$1"

  local DIRECTORY=$(dirname "$FILEPATH")
  local FILENAME=$(basename "$FILEPATH")

  # local FULL_DIRECTORY="$SEARCH_DIRECTORY/$DIRECTORY"
  local FULL_DIRECTORY="$DIRECTORY"

  if [ -d $FULL_DIRECTORY ]; then
    FOUND_IMAGE=$(find $FULL_DIRECTORY -type f -iname $FILENAME | grep $FILEPATH 2>/dev/null)

    if [ -n "$FOUND_IMAGE" ]; then
      echo $FOUND_IMAGE
    else
      echo ""
    fi
  else
    echo ""
  fi
}

GET_IMAGE_WIDTH () {
  # Path to the image file
  FILEPATH="$1"

  # Get the image width
  IMAGE_WIDTH=$(identify -format "%w" "$FILEPATH")
  
  echo "$IMAGE_WIDTH"
}

DUPLICATE_IMAGE () {
    local FILEPATH="$1"
    local KEY="$2"

    # Get the file NAME and EXTENSION
    local FILENAME=$(basename -- "$FILEPATH")
    local EXTENSION="${FILENAME##*.}"
    local NAME="${FILENAME%.*}"

    # local FULL_PATH="$SEARCH_DIRECTORY/$FILEPATH"
    local FULL_PATH="$FILEPATH"

    # Duplicate the image file
    cp "$FULL_PATH" "${TARGET_DIRECTORY}/${KEY}.${EXTENSION}"
}

CREATE_REPORT_COLUMNS () {
  # Define the columns (adjust this according to your needs)
  COLUMNS=("PRODUCT_CODE" "BRAND" "IMAGE_TYPE:_DEFAULT" "STATUS" "CURRENT_IMAGE_TYPE" "IMAGE_SIZE")

  # Create the header row
  echo "${COLUMNS[*]}" | sed 's/ /,/g' > "$REPORT_FILE"
}

CREATE_REPORT_ROW () {
  local COLUMN1="$1"
  local COLUMN2="$2"
  local COLUMN3="$3"
  local COLUMN4="$4"
  local COLUMN5="$5"
  local COLUMN6="$6"

  ROW=("$COLUMN1", "$COLUMN2", "$COLUMN3", "$COLUMN4","$COLUMN5", "$COLUMN6")
  echo "${ROW[@]}"
}

CREATE_REPORT () {
  CREATE_REPORT_COLUMNS

  for i in "${!CODES[@]}"; do
    FILEPATH="${FILEPATHS[i]}"
    STATUS=""

    IMAGE_SIZE=""
    IMAGE_TYPE="DEFAULT NO IMAGE"
    IMAGE_PATH="$DEFAULT_FILEPATH"

    # Check if the string is empty
    if [ -z "$FILEPATH" ]; then
      STATUS="NO FILEPATH"
    fi

    IS_BRAND_FILEPATH=$(VERIFY_BRAND_FILEPATH "$FILEPATH")

    if $IS_BRAND_FILEPATH; then
      STATUS="USED THE BRAND'S LOGO"
    fi

    # Check if the string is not empty and "$IS_BRAND_FILEPATH is false"
    if [ -n "$FILEPATH" ] && [ "$IS_BRAND_FILEPATH" = false ]; then
      # Check if the SEARCH_FILE function returned true or false
      FOUND_IMAGE=$(SEARCH_FILE "$FILEPATH")

      if [ -n "$FOUND_IMAGE" ]; then
        IMAGE_SIZE=$(GET_IMAGE_WIDTH "$FOUND_IMAGE")
        IMAGE_TYPE="PRODUCT IMAGE"
        IMAGE_PATH="$FILEPATH"

        if [ "$IMAGE_SIZE" -eq 1000 ]; then
          STATUS="OK"
        elif [ "$IMAGE_SIZE" -gt 1000 ]; then
          STATUS="IMAGE SIZE IS GREATER THAN 1000PX"
        else
          STATUS="IMAGE SIZE IS LESS THAN 1000PX"
        fi
      else
        STATUS="IMAGE NOT FOUND"
      fi
    fi

    DUPLICATE_IMAGE "$IMAGE_PATH" "${CODES[i]}"
    
    NEW_ROW=$(CREATE_REPORT_ROW "${CODES[i]}" "${BRANDS[i]}" "${FILEPATHS[i]}" "$STATUS" "$IMAGE_TYPE" "$IMAGE_SIZE")
    echo "$NEW_ROW" >> "$REPORT_FILE"
    echo "${NEW_ROW[@]}"
  done
}

CREATE_REPORT