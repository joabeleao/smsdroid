#!/bin/bash

#
# Simple android cli sms reader and sender
#   requires:
#       android 9 or later
#       rooted phone
#       adb drivers linux
#       developer options with usb debbuging enabled
#       phone connected via usb in tranfers or ptp mode
#       sqlite3
#

# Checking if adb drivers exist
[[ -z "$(which adb)" ]] && echo "No adb driver found, please install it." && exit
[[ -z "$(which sqlite3)" ]] && echo "No sqlite3 found, please install it." && exit

# Script arguments
ARGUMENTS=("${@}")

function dsms_help() {

    echo -e "\n    Help menu\n
    send sms usage and example:
    \t${0} <sim card slot number> <+e164 destination number> <message between quotes>
    \t${0} --send 0 +551122223333 \"my message here\"\n
    read sms example:
    \t${0} --read"

}

function dsms_read() {

    # Local variables
    local dbsms_android # path to sms database on android
    local dbsms_output # path to save sms db on pc
    local query # query to get messages
    local query_result # store result

    dbsms_android='/data/data/com.android.providers.telephony/databases/mmssms.db'
    dbsms_output='/tmp/dbsms.db'
    query='SELECT address,
    strftime("%Y-%m-%d %H:%M:%S", date/1000, "unixepoch"),
    strftime("%Y-%m-%d %H:%M:%S", date_sent/1000, "unixepoch"),
    body,
    service_center
    FROM
    sms;'

    adb root # the pull command only works with root adb
    adb pull "${dbsms_android}" "${dbsms_output}" # export database to pc

    oldifs=$IFS # saving field separator before changing
    IFS=$'\n' # changing field separator to newline to get individual messages

    query_result=$(sqlite3 -line -csv "${dbsms_output}" "${query}")
   
    # Format messages to human readable
    for i in ${query_result[@]}; do
        IFS=, read address date remote_date_sent body remote_service <<< "${i}"
        if [ -n "${remote_service}" ]; then
            echo -e "\nMensagem recebida:
            Remetente: ${address}
            Corpo: ${body}
            Hora enviada: ${remote_date_sent}
            Hora recebida: ${date}
            Centro de mensagens: ${remote_service}\n"
        elif [ -z "${remote_service}" ]; then
            echo -e "\nMensagem enviada:
            Destinatário: ${address}
            Corpo: ${body}
            Hora enviada: ${date}\n" 
        else
            # Just debugging in case something different appears
            echo -e "\n${address}, ${date}, ${remote_date_sent}, ${body}, ${remote_service}\n" 
        fi

    done

    IFS="${oldifs}" # returning file separator to normal state

}

function dsms_send() {

    # sms slot location on smartphone
    local slot
    slot="${1}"

    # Destination number in +e164 standard e.g +551122223333
    local destination
    destination="${2}"

    # Message
    local message
    message="${3}"
    adb shell service call isms 5 i32 \"${slot}\" s16 \"com.android.mms.service\" \
        s16 \"null\" s16 \""${destination}"\" s16 \"null\" s16 \"\'"${message}"\'\" s16 \"null\"

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
