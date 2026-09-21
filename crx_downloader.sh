#!/bin/bash


function user_prompt() {
  read -r -p "Press [Enter] to continue "
}

# a sort of debugging function to display output 
function display_extension_info() {
    echo -e "\vextension_url: $extension_url"

    echo -e "extension_name:\t${extension_name}"
    echo -e "extension_id:\t${extension_id}"
    echo -e "extension_version:\t${extension_version}"

    # echo -e "extension_download_url:\t${extension_download_url}"

    # echo -e "latest_browser_version\t${latest_browser_version}"

    user_prompt
  
}

# Download the crx to the user's downloads directory
function download_extension() {
    echo -e "\vDownloading ${extension_name} from \n${extension_download_url}"
    sleep 1
    wget -O "/home/$USER/Downloads/${extension_name}_${extension_version}.crx" ${extension_download_url}
}


# gets info based on the now checked and valid (in a few ways) Chrome store URL,
# to create the download link

function get_extension_info() {
    #latest_browser_version="152.0"
    
    # note to self: if issues happen, it MAY have to do with the tab i just added
    latest_browser_version=$(
        curl -fsSL 'https://versionhistory.googleapis.com/v1/chrome/platforms/linux/channels/stable/versions' |
        jq -r '.versions[0].version' |
        cut -d. -f1
    )

    # echo -e "Latest Chromium/Chrome version: ${latest_browser_version}"

    extension_name=$(echo "${extension_url}" | sed 's/^.*detail\///g;s/\/.*$//' )
    extension_id=$(echo "${extension_url}" | sed 's/^.*\///')
    extension_version=$(curl -fsSL \
        "https://clients2.google.com/service/update2/crx?response=update&prodversion=9999&x=id%3D${extension_id}%26uc&acceptformat=crx3" |
        sed -n 's/.*<updatecheck[^>]*version="\([^"]*\)".*/\1/p' | \
        sed 's/\./_/g'
    )

    # create download link
    extension_download_url="https://clients2.google.com/service/update2/crx?response=redirect&prod=chromecrx&prodchannel=&prodversion=${latest_browser_version}lang=en-US&acceptformat=crx3,puff&x=id%3D${extension_id}%26installsource%3Dondemand%26uc&authuser=0"


   # idea: shows the info 
    # ... in my head this is 100% a debugging type function that can be commented out "in production"
   # display_extension_info

}

# Validates the user input
function validate_user_inputted_url() {
    
    # Basic URL/domain check
    ## idea: this could be removed since the second check has this i suppose 
    echo "Checking for a valid Chrome Web Store link"
    if [[ ! "${extension_url}" =~ ^https://chromewebstore\.google\.com/ ]]; then
        echo "Error: URL must be a Chrome Web Store URL."
        exit 1
    fi

    # check to see if its a valid chrome store link
    ## THIS DOES NOT check if the URL "exists" .. just if the FORMAT is correct
    if [[ ! "$extension_url" =~ ^https://chromewebstore\.google\.com/detail/[^/]+/[a-z]{32}/?$ ]]; then
        echo "Error: URL doesn't appear to be a Chrome Web Store extension URL."
        exit 1
    fi

    echo "Checking to see if there is a Chrome extension at the Web Store URL, given"
    # validates if there seems to be a chrome extension at this link
    # if the response is a redirect (to the Chrome Store frontpage, then its likely there is not a valid extension at the given address)
    [[ "${extension_url}" == *"301"* ]] && echo "redirect detected" && exit 1 || echo "no redirect detected"

function process_url() {
    validate_user_inputted_url "${extension_url}"

    get_extension_info "$extension_url"

    download_extension "${extension_download_url}"
}

function get_extension_url_from_user() {

    echo -e "Enter Google Chrome Store link to the extension you want\n"
    read -rp "extension_url: " extension_url

    process_url "${extension_url}"
}

#get_extension_id "https://chromewebstore.google.com/detail/material-simple-dark-grey/ookepigabmicjpgfnmncjiplegcacdbm"

get_extension_url_from_user