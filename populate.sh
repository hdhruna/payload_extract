#!/bin/bash -e
# exit when any command fails

last_cmd=""
current_cmd=""


# help message function
display_help() {
    echo "Usage: $0 <url>" >&2
    echo
    echo "for e.g. $0 http://payload.io/"
    echo
    exit 1
}

# error message function, based on the SIG received in trap, appropriate message will be displayed.
display_error_msg() {
    p=$?
    if [[ $p -eq 1 ]]; then
        echo
        echo "No services were found in $url, please try a different url."
        elif [[ $p -eq 6 ]]; then
        echo
        echo "Malformed URL, please try a valid url."
        elif [[ $p -eq 28 ]]; then
        echo
        echo "Timeout occurred waiting for response from $url."
    else
        echo
        echo "Something's not right!"
    fi
}

# save input from user as a variable
url=$1

# exit the script if user does not provide any input and show the help function
[ $# -eq 0 ] && { display_help; exit 1; }

# keep track of the last executed command
trap 'last_cmd=$current_cmd; current_cmd=$BASH_COMMAND' DEBUG
# echo any error message before exiting
trap 'echo "\"${last_cmd}\" command failed with exit code $?.
$(display_error_msg)"' ERR

# Treat unset variables and parameters other than the special parameters "@" and "*" as an error when performing parameter expansion
set -uo pipefail

#execute curl on user provided URL and store in a temp file
curl -s "$url" --output /tmp/result.txt --connect-timeout 10.0

#remove HTML tags using regex from the temp file which has the curl output
sed -i -e 's/<[a-zA-Z\/][^>]*>/\n/g' /tmp/result.txt

# grep the service names using regex from the result file and pass it through a while loop which will get the status of the respective service name again using regex and remove the tab char from the result using sed with regex, if the status is not equal to OK, echo the service name to the user

services=$(grep -oP '.*?(?=:)' /tmp/result.txt)

[ -z "$services" ] && exit 1 || echo "$services" | while IFS=; read -r name; do
    
    status=$(grep -oP "(?<=$name:).+" /tmp/result.txt | sed -e 's/^[ \t]*//')
    
    if [  "$status" != "OK" ]; then
        echo "The service $name is $status"
    fi
done
