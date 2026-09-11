#!/bin/bash


function user_prompt() {
  read -r -p "Press [Enter] to continue "
}

function display_extension_info() {
    echo -e "\vextension_url: $extension_url"

    echo -e "extension_name:\t${extension_name}"
    echo -e "extension_id\t${extension_id}"

    echo -e "extension_download_url:\t${extension_download_url}"

    user_prompt
}

# Download the crx to the user's downloads directory
function download_extension() {
    echo -e "Downloading ${extension_download_url}"
    sleep 1
    wget -O "/home/$USER/Downloads/${extension_name}.crx" ${extension_download_url}
}


# gets info based on the now checked and valid (in a few ways) Chrome store URL,
# to create the download link

function get_extension_info() {
    # idea:
    #latest_version="152.0.7977.82"
    latest_version="152.0"


    extension_name=$(echo "${extension_url}" | sed 's/^.*detail\///g;s/\/.*$//' )
    extension_id=$(echo "${extension_url}" | sed 's/^.*\///')


    #curl "https://clients2.google.com/service/update2/crx?response=redirect&prod=chromecrx&prodchannel=&prodversion=${latest_version}lang=en-US&acceptformat=crx3,puff&x=id%3D${extension_id}%26installsource%3Dondemand%26uc&authuser=0"

    # what to wget
    extension_download_url="https://clients2.google.com/service/update2/crx?response=redirect&prod=chromecrx&prodchannel=&prodversion=${latest_version}lang=en-US&acceptformat=crx3,puff&x=id%3D${extension_id}%26installsource%3Dondemand%26uc&authuser=0"


   # idea: show the info ... in my head this is 100% a debugging type function that can be commented out "in production"
   display_extension_info

   download_extension "${extension_download_url}"
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
    if [[ "${extension_url}" =~ ^https://chromewebstore\.google\.com/detail/([^/]+)/([a-z]{32})/?$ ]]; then
        # function to get information
        get_extension_info "${extension_url}"
    else
        echo "Error: URL doesn't appear to be a Chrome Web Store extension URL."
        exit 1
    fi




}

function get_extension_url_from_user() {

    echo -e "Enter Google Chrome Store link to the extension you want\n"
    read -rp "extension_url: " extension_url

    # TODO: Validate extension_url variable content

    validate_user_inputted_url "${extension_url}"

    get_extension_info "$extension_url"
}

#get_extension_id "https://chromewebstore.google.com/detail/material-simple-dark-grey/ookepigabmicjpgfnmncjiplegcacdbm"

get_extension_url_from_user