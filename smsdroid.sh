#!/bin/bash

#
# Simple android cli sms reader and sender
#   requires:
#       android 9 or later
#       rooted phone
#       adb drivers linux
#       developer options with usb debbuging enabled
#       sqlite3
#

# Script arguments
ARGUMENTS=("${@}")

function dsms_help() {

    echo -e "    usage:\n\t${0} <option> <parameters>\n
    sendsms exalmple (sim card slot; +e164 destination number; message between quotes):
    \t${0} 0 +551122223333 \"my message here\" "

}

function dsms_read() {

    adb root
    adb pull /data/data/com.android.providers.telephony/databases/mmssms.db .
    echo 'select address,body from sms;' | sqlite3 -csv mmssms.db

}

function dsms_send() {

    # sms slot location
    local slot
    slot="${1}"

    # Destination number in +e164 standard e.g +551122223333
    local destination
    destination="${2}"

    # Message
    local message
    message="${3}"
    adb shell service call isms 5 i32 "${slot}" s16 "com.android.mms.service" s16 "null" s16 "${destination}" s16 "null" s16 "${message}" s16 "null"

}

case "${ARGUMENTS[0]}" in
    "--read")
        [ "${#ARGUMENTS[*]}" -ne 1 ] && dsms_help && exit
        dsms_read
    	;;
    "--send")
        [ "${#ARGUMENTS[*]}" -ne 4 ] && dsms_help && exit
        dsms_send "${ARGUMENTS[1]}" "${ARGUMENTS[2]}" "${ARGUMENTS[3]}"
    	;;
    *)
        dsms_help && exit
	    ;;
esac

#TODO
# improve help
# format database output to human readable
# add install as service
# add crontab sms check install or monitor via event
# add documentation
