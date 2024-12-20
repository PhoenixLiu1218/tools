#!/bin/bash

# ----------------------------------------------------------------------
# Script Name:    data_collection.sh
# Description:    Script to collect data and compress it into a tgz file.
# Version:        1.0.0
# Author:         F.Kuwana
# Date:           2023-11-05
# ----------------------------------------------------------------------
# History:
#   Version 1.0.0 - 2023-11-05 - F.Kuwana
#     - Initial version.
# ----------------------------------------------------------------------

# Enable debug mode
###set -x

# Set the log file
LOG_FILE="execute.log"
# List to keep track of copied files and directories
COPIED_ITEMS_LIST="copied_items.list"

# Function to log output
log() {
    echo "$1" | tee -a ${LOG_FILE}
}

# Function to log current datetime
log_datetime() {
    echo "$(date '+%Y-%m-%d %H:%M:%S')" | tee -a ${LOG_FILE}
}

# Pre-processing
log "Starting pre-processing..."
log "Script started at: $(log_datetime)"

# Check the executing user
if [ "$(id -u)" -ne 0 ]; then
    log "This script must be run as root. Exiting."
    exit 1
fi

# Check the existence of all_file.list
if [ ! -f "all_file.list" ]; then
    log "all_file.list does not exist. Exiting."
    exit 1
fi

# Create a new list with the execution date
EXECUTION_DATE=$(date '+%Y%m%d') TODO: not the current date, should be the date was typed by users.
NEW_LIST="all_file_temp.list"

# Replace "yyyymmdd" with the actual execution date in the new list
sed "s/yyyyMMdd/${EXECUTION_DATE}/g" all_file.list > ${NEW_LIST}

# Overwrite the original list with the new list
mv ${NEW_LIST} all_file.list TODO:is this really necessary?

# Determine the target product
PRODUCT=""

if [ -f "/webmail/etc/updated_patch.list" ]; then
    PRODUCT="CM"
elif [ -f "/mailgates/mg/etc/version" ]; then
    PRODUCT="MG"
elif [ -f "/webmail/mbase/etc/version" ]; then
    PRODUCT="EA"
else
    log "Could not determine the target product. Exiting."
    exit 1
fi

log "The target product is ${PRODUCT}."

# Determine the targets to be collected
TARGETS=$(awk -v product="${PRODUCT}" 'BEGIN { FS="\t" } { if ($2 == "ALL" || $2 == product) print $0 }' all_file.list)

# Confirm execution server
read -p "Do you want to proceed with the data collection on this server? (Y/N): " CONFIRM
if [ "$CONFIRM" != "Y" ]; then
    log "Process aborted by user."
    exit 0
fi

# Copy the targets and execute the commands
log "Starting data collection..."

# Clear the copied items list
> ${COPIED_ITEMS_LIST}

# Iterate over each target
echo "${TARGETS}" | while IFS=$'\t' read -r NO PRODUCT TARGET_PATH TYPE USER; do
    # Handle Local and Share types by copying the target
    if [ "${TYPE}" == "Local" ] || [ "${TYPE}" == "Share" ]; then
        # Expand the TARGET_PATH if it contains a wildcard
        for FILE in ${TARGET_PATH}; do
            if [ -f "${FILE}" ]; then
                BASENAME=$(basename "${FILE}")
                DEST_FILE="${BASENAME}_${EXECUTION_DATE}_$(date '+%H%M%S')"
                cp -Lp "${FILE}" "${DEST_FILE}" 2>&1 | tee -a ${LOG_FILE}
                log "Copied file target ${FILE} to ${DEST_FILE}."
                echo "${DEST_FILE}" >> ${COPIED_ITEMS_LIST}
            elif [ -d "${FILE}" ]; then
                DIRNAME=$(basename "${FILE}")
                DEST_DIR="${DIRNAME}_${EXECUTION_DATE}_$(date '+%H%M%S')"
                mkdir -p "${DEST_DIR}"
                find "${FILE}" -type f -exec cp -Lp {} "${DEST_DIR}" \; 2>&1 | tee -a ${LOG_FILE}
                log "Copied directory target ${FILE} to ${DEST_DIR}."
                find "${DEST_DIR}" -type f -exec basename {} \; >> ${COPIED_ITEMS_LIST}
            else
                log "Target ${FILE} does not exist. Moving to the next target."
                continue
            fi
        done
    # Handle Cmd type by executing the command as the specified user
    elif [ "${TYPE}" == "Cmd" ]; then
        CMD_NAME=$(echo ${TARGET_PATH} | tr '/ -' '_')
        OUTPUT_FILE="${CMD_NAME}_info.txt"
        su - ${USER} -c "${TARGET_PATH}" > "${OUTPUT_FILE}" 2>&1 | tee -a ${LOG_FILE}
        if [ $? -eq 0 ]; then
            log "Executed command ${TARGET_PATH}. Output saved to ${OUTPUT_FILE}."
            echo "${OUTPUT_FILE}" >> ${COPIED_ITEMS_LIST}
        else
            log "Failed to execute command ${TARGET_PATH}. Moving to the next target."
            continue
        fi
    else
        log "Unknown target type ${TYPE}. Moving to the next target."
        continue
    fi
done

# Disable debug mode
###set +x

# Post-processing
log "Starting post-processing..."

HOSTNAME=$(hostname)
DATE=$(date '+%Y%m%d_%H%M%S')
TAR_FILE="${HOSTNAME}_${DATE}_info.tgz"

# Compress the collected files and log into a single archive
tar czf ${TAR_FILE} $(cat ${COPIED_ITEMS_LIST}) *info.txt execute.log

# Check if tar command was successful
if [ $? -eq 0 ]; then
    log "Compression successful. Deleting collected files..."
    while IFS= read -r ITEM; do
        rm -rf "${ITEM}"
    done < ${COPIED_ITEMS_LIST}
    rm -f *info.txt
    log "Collected files deleted."
else
    log "Compression failed. Collected files are not deleted."
fi

log "All processes are complete. Results have been compressed into ${TAR_FILE}."
log "Script finished at: $(log_datetime)"
