#!/bin/bash

# Dump every variable in a notification to /tmp/dunst_variables_dump to allow matching
# in the main config
# tail -f /tmp/dunst_variables_dump

# Available dunst variables:
# DUNST_APP_NAME
# DUNST_SUMMARY
# DUNST_BODY
# DUNST_ICON_PATH
# DUNST_URGENCY
# DUNST_ID
# DUNST_PROGRESS
# DUNST_CATEGORY
# DUNST_STACK_TAG
# DUNST_URLS
# DUNST_TIMEOUT
# DUNST_TIMESTAMP
# DUNST_DESKTOP_ENTRY
# DUNST_STACK_TAG

# Quick way to log notification data:
OUT="/tmp/dunst_variables_dump"
touch ${OUT}
echo "DUNST_APP_NAME: "${DUNST_APP_NAME}"" >> ${OUT}
echo "DUNST_SUMMARY: "${DUNST_SUMMARY}"" >> ${OUT}
echo "DUNST_BODY: "${DUNST_BODY}"" >> ${OUT}
echo "DUNST_ICON_PATH: "${DUNST_ICON_PATH}"" >> ${OUT}
echo "DUNST_URGENCY: "${DUNST_URGENCY}"" >> ${OUT}
echo "DUNST_ID: "${DUNST_ID}"" >> ${OUT}
echo "DUNST_PROGRESS: "${DUNST_PROGRESS}"" >> ${OUT}
echo "DUNST_CATEGORY: "${DUNST_CATEGORY}"" >> ${OUT}
echo "DUNST_STACK_TAG: "${DUNST_STACK_TAG}"" >> ${OUT}
echo "DUNST_URLS: "${DUNST_URLS}"" >> ${OUT}
echo "DUNST_TIMEOUT: "${DUNST_TIMEOUT}"" >> ${OUT}
echo "DUNST_TIMESTAMP: "${DUNST_TIMESTAMP}"" >> ${OUT}
echo "DUNST_DESKTOP_ENTRY: "${DUNST_DESKTOP_ENTRY}"" >> ${OUT}
echo "DUNST_STACK_TAG: "${DUNST_STACK_TAG}"" >> ${OUT}
echo "=============================================================" >> ${OUT}
