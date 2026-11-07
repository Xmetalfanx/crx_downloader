#!/bin/bash


function user_prompt() {
  read -r -p "Press [Enter] to continue "
}

function display_extension_info() {
    echo -e "\nextension_url: ${extension_url}"

    echo -e "extension_name:\t${extension_name}"
    echo -e "extension_id:\t${extension_id}"

    echo -e "extension_download_url:\t${extension_download_url}"

    user_prompt
}

# Download the crx to the user's downloads directory
function download_extension() {
    local download_dir="${HOME}/Downloads"

    mkdir -p "${download_dir}"

    echo -e "Downloading ${extension_download_url}"
    sleep 1
    wget -O "${download_dir}/${extension_name}.crx" "${extension_download_url}"
}


# gets info based on the now checked and valid (in a few ways) Chrome store URL,
# to create the download link

function get_extension_info() {
    local extension_url="$1"

    #latest_browser_version="152.0"
    latest_browser_version=$(
        curl -fsSL 'https://versionhistory.googleapis.com/v1/chrome/platforms/linux/channels/stable/versions' |
        jq -r '.versions[0].version'
    )

    if [[ -z "${latest_browser_version}" || "${latest_browser_version}" == "null" ]]; then
        echo "Error: could not determine the latest Chrome version." >&2
        exit 1
    fi

    echo -e "Latest Chromium/Chrome version: ${latest_browser_version}"
    user_prompt

    # Ignore any query string or fragment when parsing the URL
    local clean_url="${extension_url%%[?#]*}"

    extension_name=$(echo "${clean_url}" | sed 's/^.*detail\///g;s/\/.*$//' )
    extension_id=$(echo "${clean_url}" | sed 's/^.*\///')


    #curl "https://clients2.google.com/service/update2/crx?response=redirect&prod=chromecrx&prodchannel=&prodversion=${latest_browser_version}&lang=en-US&acceptformat=crx3,puff&x=id%3D${extension_id}%26installsource%3Dondemand%26uc&authuser=0"

    # what to wget
    extension_download_url="https://clients2.google.com/service/update2/crx?response=redirect&prod=chromecrx&prodchannel=&prodversion=${latest_browser_version}&lang=en-US&acceptformat=crx3,puff&x=id%3D${extension_id}%26installsource%3Dondemand%26uc&authuser=0"


   # idea: show the info ... in my head this is 100% a debugging type function that can be commented out "in production"
   display_extension_info

   download_extension
}

# Validates the user input
function validate_user_inputted_url() {
    local extension_url="$1"

    # Basic URL/domain check
    ## idea: this could be removed since the second check has this i suppose
    echo "Checking for a valid Chrome Web Store link"
    if [[ ! "${extension_url}" =~ ^https://chromewebstore\.google\.com/ ]]; then
        echo "Error: URL must be a Chrome Web Store URL." >&2
        exit 1
    fi

    # Check the URL format (ignoring any query string or fragment)
    ## THIS DOES NOT check if the URL "exists" .. just if the FORMAT is correct
    local clean_url="${extension_url%%[?#]*}"

    if [[ ! "${clean_url}" =~ ^https://chromewebstore\.google\.com/detail/[^/]+/[a-p]{32}/?$ ]]; then
        echo "Error: URL doesn't appear to be a Chrome Web Store extension URL." >&2
        exit 1
    fi
}

function get_extension_url_from_user() {

    echo -e "Enter Google Chrome Store link to the extension you want\n"
    read -rp "extension_url: " extension_url

    if [[ -z "${extension_url}" ]]; then
        echo "Error: no URL was entered." >&2
        exit 1
    fi

    validate_user_inputted_url "${extension_url}"

    get_extension_info "${extension_url}"
}

#get_extension_id "https://chromewebstore.google.com/detail/material-simple-dark-grey/ookepigabmicjpgfnmncjiplegcacdbm"

get_extension_url_from_user
