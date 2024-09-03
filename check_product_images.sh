#!/bin/bash

# Run the Script:
# ./bulk_duplicate_and_rename_image.sh ./input_file.csv

BRAND="$1"
DATA_FILE="$2"
SEARCH_DIRECTORY="$3"
TARGET_DIRECTORY="$4"

# Initialize empty arrays
PRODUCTS=()
IMAGE_PATHS=()

# Define the output CSV file name
REPORT_FILE="${BRAND}_image_report.csv"

EXTRACT_DATA () {
    # Define the CSV file
    CSV_FILE="$1"
    sed -i $'s/\r$//' "$CSV_FILE"

    # Use awk to extract the first and third columns and store them in arrays
    readarray -t COLUMN1 < <(awk -F, '{ print $1 }' "$CSV_FILE")
    readarray -t COLUMN3 < <(awk -F, '{ print $3 }' "$CSV_FILE")

    # Remove the header (optional, if present)
    PRODUCTS=("${COLUMN1[@]:1}")
    IMAGE_PATHS=("${COLUMN3[@]:1}")
}

EXTRACT_DATA "$DATA_FILE"

GET_IMAGE_WIDTH () {
    # Path to the image file
    FILEPATH="$1"
    # echo "IMAGE_PATH: $FILEPATH"

    # Get the image width
    IMAGE_WIDTH=$(identify -format "%w" "$FILEPATH")
    echo "$IMAGE_WIDTH"
}

DUPLICATE_IMAGE () {
    local KEY="$1"
    local FILEPATH="$2"

    # Get the file NAME and EXTENSION
    local FILENAME=$(basename -- "$FILEPATH")
    local EXTENSION="${FILENAME##*.}"
    local NAME="${FILENAME%.*}"

    local FULL_PATH="$SEARCH_DIRECTORY/$FILEPATH"

    # Duplicate the image file
    # echo "New Path: ${TARGET_DIRECTORY}/${KEY}.${EXTENSION}"
    cp "$FULL_PATH" "${TARGET_DIRECTORY}/${KEY}.${EXTENSION}"
}

FIND_IMAGE () {
    local KEY="$1"
    local FILEPATH="$2"

    local DIRECTORY=$(dirname $FILEPATH)
    local FILENAME=$(basename $FILEPATH)

    local FULL_DIRECTORY="$SEARCH_DIRECTORY/$DIRECTORY"

    if [ -d $FULL_DIRECTORY ]; then
        FOUND_IMAGE=$(find $FULL_DIRECTORY -type f -iname $FILENAME 2>/dev/null)

        if [ -n $FOUND_IMAGE ]; then
            # echo "Image found: $FOUND_IMAGE"
            IMAGE_WIDTH=$(GET_IMAGE_WIDTH $FOUND_IMAGE)
            DUPLICATE_IMAGE "$KEY" "$FILEPATH"
            echo "New image path: ${TARGET_DIRECTORY}/${CODE}.${EXTENSION}"

            RESULT=("TRUE","$IMAGE_WIDTH")
            echo $RESULT
        else
            # echo "Image not found: $FILENAME in $FULL_DIRECTORY"
            RESULT=("FALSE","")
            echo $RESULT
        fi
    else
        echo "Directory does not exist: $FULL_DIRECTORY"
    fi
}
CREATE_REPORT_COLUMNS () {
    # Define the columns (adjust this according to your needs)
    COLUMNS=("PRODUCT_CODE" "IMAGE_TYPE:_DEFAULT" "IS_FOUND?" "IMAGE_SIZE")

    # Create the header row
    echo "${COLUMNS[*]}" | sed 's/ /,/g' > "$REPORT_FILE"
}

CREATE_REPORT_ROW () {
    local COLUMN1="$1"
    local COLUMN2="$2"
    local OTHER_COLUMNS="$3"

    ROW=("$COLUMN1", "$COLUMN2", "${OTHER_COLUMNS[@]}")
    echo "${ROW[@]}"
}

# Check if arrays has more than one element
if [[ ${#PRODUCTS[@]} -gt 0 && ${#IMAGE_PATHS[@]} -gt 0 ]]; then
    # echo "Array has more than one element."

    CREATE_REPORT_COLUMNS

    for i in "${!PRODUCTS[@]}"; do
        # echo "Index $i: ${IMAGE_PATHS[i]} ${PRODUCTS[i]}"
        NEW_ROW=$(CREATE_REPORT_ROW "${PRODUCTS[i]}" "${IMAGE_PATHS[i]}" $(FIND_IMAGE ${PRODUCTS[i]} ${IMAGE_PATHS[i]}))
        echo "$NEW_ROW" >> "$REPORT_FILE"
    done
else
    # echo "Array does not have more than one element."
    echo "PRODUCTS or IMAGE_PATHS does not have more than one element."
    exit 1
fi

# Notes:
# [ -d "$DIRECTORY" ]: Checks if the specified $DIRECTORY exists and is a directory.
# [ -n "$MY_STRING" ]: Checks if MY_STRING is not empty.