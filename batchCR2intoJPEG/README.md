# Immich CR2 --> JPEG

I made a script to import a family memeber's CR2 library. This library will remain on their prem, but we all wanted to see the photos in Immich.

- [Immich CR2 --> JPEG](#immich-cr2----jpeg)
  - [What CR2 into JPEG will do](#what-cr2----jpeg-will-do)
  - [Try it out](#try-it-out)
  - [CR2JPEG - Step 1: Copy the Github Files](#cr2jpeg---step-1-copy-the-github-files)
  - [CR2JPEG - Step 2: Organize Your Files](#cr2jpeg---step-2-organize-your-files)
  - [CR2JPEG - Step 3: Modify docker-compose.yml for Your Purposes](#cr2jpeg---step-3-modify-docker-composeyml-for-your-purposes)
  - [CR2JPEG - Step 4: Run the Container](#cr2jpeg---step-4-run-the-container)


* * *

## What CR2 --> JPEG will do

If you run the script, it is because you need the following features:

* Convert your `.CR2` to optimized lossy`.JPG`

* Compresses `.JPG`s above a specific size (>5.25MB)

* Copies all `.JPG`s & `.MP4`s

* Preserves folders & EXIF timestamps

* Avoids reprocessing files (uses a log)


* * *

## Try it out

You can just run the script in Linux, it will do as detailed above, but you will need to specifiy the input and output directories.

```bash

SRC_ROOT=/path/to/your/test_input DST_ROOT=/path/to/test_output ./cr2jpeg.sh

```


* * *

## Now Try it out with Docker

This script was originally built to run in a Docker container, why install software on your Laptop you're only using the script once?

If you want, you can use the dockerized version - just make sure to:

1. Put your photos in a folder (e.g., `/home/you/photos_input`)

2. Make an output folder (e.g., `/home/you/photos_output`)

3. Run Docker Compose


* * *

## CR2JPEG - Step 1: Copy the Github Files

If you haven’t copied this Github repo yet, you'll need a `Dockerfile` that installs tools, a `docker-compose.yml` file to define how the container should be set-up, and the `cr2jpeg.sh` script.


* * *

### Bash/ZSH Script to Download All the Files

Here is a `Bash` script to download all the required files for the CR2 --> JPEG script ran in Docker.

```bash
#!/bin/bash

# --- Config Section ---

# Base URL for GitHub repo
BASE_URL="https://raw.githubusercontent.com/MarcusHoltz/immich-setup/main/batchCR2intoJPEG/"

# Files to download
FILE_1="cr2jpeg.sh"
FILE_2="docker-compose.yml"
FILE_3="Dockerfile"

# --- Script to download files ---

# Loop through all files defined with FILE_# syntax
for i in $(compgen -A variable | grep '^FILE_'); do
    file_url="${BASE_URL}${!i}"  # Create the full URL by getting the value of each FILE_#
    file_name="${!i}"  # Extract the file name from the variable
    echo "Downloading ${file_name} from ${file_url}..."
    
    # Download the file using curl
    curl -O "$file_url"
    
    if [ $? -eq 0 ]; then
        echo "Downloaded: $file_name"
    else
        echo "Failed: $file_name"
    fi
done

echo "All files processed."
```


* * *

### Powershell Script to Download All the Files

Here is a `Powershell` script to download all the required files for the CR2 --> JPEG script ran in Docker.


```powershell
# --- Config Section ---

# Define the base URL for your GitHub repo
$BASE_URL = "https://raw.githubusercontent.com/MarcusHoltz/immich-setup/main/batchCR2intoJPEG/"

# Add files you want to download here
$FILE_1 = "cr2jpeg.sh"
$FILE_2 = "docker-compose.yml"
$FILE_3 = "Dockerfile"

# --- Script to download files ---

# Loop through all files defined with FILE_# syntax
$files = @($FILE_1, $FILE_2, $FILE_3)

foreach ($file in $files) {
    $file_url = "${BASE_URL}${file}"  # Create the full URL
    Write-Host "Downloading $file from $file_url..."

    # Define the path where the file will be saved
    $destination_path = ".\$file"

    # Download the file using Invoke-WebRequest
    Invoke-WebRequest -Uri $file_url -OutFile $destination_path

    Write-Host "Downloaded $file to $destination_path"
}

Write-Host "All files processed."
```


* * *

## CR2JPEG - Step 2: Organize Your Files

You'll need two directories:

- One **input directory** (e.g., `/home/you/photos_input`)

- One **output directory** (e.g., `/home/you/photos_output`)

The input directory should contain folders/files with `.CR2`, `.JPG`, `.MP4` content.


* * *

## CR2JPEG - Step 3: Modify docker-compose.yml for Your Purposes

The docker-compose.yml file contains many variables that can be configured to fit your needs. Please look into them:

- `JPEG_QUALITY`: This is the compression factor. How much to compress your images?  (85-90 is typical for Google Pixel/GCam)

- `SIZE_THRESHOLD`: Set this to the minimum size you'd like to compress (in bytes)


* * *

## CR2JPEG - Step 4: Run the Container

If you get these three files in the working directory, you can run:


* * *

### 1. Build the Docker image

`docker-compose build`


* * *

### 2. Run the processing

Then run the script with:

`docker-compose run --rm photo-processor`


* * *

### 3. Change the script? Re-create the container (optional)

If you modify the script, you will need to load the script back into the image, and re-run the container.

`docker-compose up --build --force-recreate`

