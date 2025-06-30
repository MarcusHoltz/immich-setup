# In-Place JPG Optimizer

- [In-Place JPG Optimizer](#in-place-jpg-optimizer)
  - [In-Place JPG Optimizer Introducton](#in-place-jpg-optimizer-introducton)
  - [What exactly does In-Place JPG Optimizer Do](#what-exactly-does-in-place-jpg-optimizer-do)
  - [Quick Instructions](#quick-instructions)
  - [FAQ](#faq)
  - [Example Output](#example-output)
  - [Troubleshooting](#troubleshooting)
  - [Details](#details)

* * *


## In-Place JPG Optimizer Introducton

- **This script will:** Shrink big JPGs in-place, keep all metadata, and back up originals.

- **To use this script:** Just run this in your photo folder with Docker.

- **What happens:** All big JPGs are optimized, originals are moved to an `originals/` backup, and you get to see the progress.

- **What to configure:** `JPEG_QUALITY` and `SIZE_THRESHOLD_KB` - Compression level, and min size of files to compress.


* * *

## What exactly does In-Place JPG Optimizer Do

- **Finds all JPG/JPEG files in your folder tree above a certain size (default: 5250KB)**

- **Optimizes the files in-place, meaning, same filename and same location**

- **Preserves ALL metadata (EXIF, GPS, etc) and keeps the original modified date**

- **Backs up the original file (with folder structure) to an `originals/` directory**

- **Shows progress as it works**

- **Skips files it already processed if interrupted (resumes cleanly)**


* * *

## Quick Instructions

1. Have [Docker](https://docs.docker.com/get-docker/) Ready

2. Put your photos in a folder, e.g. `./photos`

3. Copy the provided `docker-compose.yml`, `Dockerfile`, and `inplace_jpg_optimizer.sh` into that folder

4. Edit `docker-compose.yml` to change the size threshold or quality:

- `PROCESS_DIR`: Folder to process (default: `./`)

- `JPEG_QUALITY`: Output JPG quality (default: 85, range: 1-100)

- `SIZE_THRESHOLD_KB`: Only optimize files *larger* than this (default: 5250)

5. Run the container and have it remove itself when complete:

   ```bash

   docker compose run --rm jpg-optimizer

   ```

6. Done!

   - Optimized JPGs are now in place

   - Originals are in `originals/`  

   - Progress is shown as it works


* * *

## In-Place JPG Optimizer Downloader: Copy the Github Files

If you haven’t copied this Github repo yet, you'll need a `Dockerfile` that installs tools, a `docker-compose.yml` file to define how the container should be set-up, and the `inplace_jpg_optimizer.sh` script.


* * *

### Bash/ZSH Script to Download All the Files

Here is a `Bash` script to download all the required files for the In-Place JPG Optimizer script ran in Docker.


<details>

<summary>Bash/ZSH Script</summary>  


```bash
#!/bin/bash

# --- Config Section ---

# Base URL for GitHub repo
BASE_URL="https://raw.githubusercontent.com/MarcusHoltz/immich-setup/main/compress2largeIMAGES/"

# Files to download
FILE_1="inplace_jpg_optimizer.sh"
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

</details>


* * *

### Powershell Script to Download All the Files

Here is a `Powershell` script to download all the required files for the In-Place JPG Optimizer script ran in Docker.

<details>

<summary>Powershell Script</summary>  


```powershell
# --- Config Section ---

# Define the base URL for your GitHub repo
$BASE_URL = "https://raw.githubusercontent.com/MarcusHoltz/immich-setup/main/compress2largeIMAGES/"

# Add files you want to download here
$FILE_1 = "inplace_jpg_optimizer.sh"
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

</details>


* * *

## FAQ

**Q: Will this overwrite my photos?**  
A: Yes, but it moves the original to `originals/` first, preserving the folder structure.

**Q: What if the process is interrupted?**  
A: It keeps a log and will skip already optimized files on the next run.

**Q: What if I want to keep all metadata?**  
A: All metadata is preserved in the optimized file.

**Q: Will it change the timestamp on my files?**  
A: Only optimized files get their modified date set to the original's modified date. Files not optimized are untouched.

**Q: How do I change the size threshold or quality?**  
A: Edit `docker-compose.yml` and set `SIZE_THRESHOLD_KB` or `JPEG_QUALITY` as you wish.


* * *

## Example Output

```
Scanning for JPG files...
Total JPG files found: 412
Files below 5250KB (untouched): 309
Files to optimize: 103

Starting optimization of 103 files...

[1/103] (0%)
Optimizing: ./IMG_1234.JPG
✓ Optimized: IMG_1234.JPG (8123KB → 4210KB, saved 48%)
 → Set mtime for IMG_1234.JPG to 202406221530.12
```

...some time passes...

```text
[103/103] (100%)
Processing complete!
- Optimized: 103 files
- Failed: 0 files

All done! JPG files larger than 5250KB have been optimized in-place.
Optimized files have had their mtimes set to their original modified date.
Originals have been moved to: ./originals
```


* * *

## Troubleshooting

- **Not enough space:** Make sure you have room for the `originals/` backup.

- **Permissions:** Run as a user with read/write access to your photo folder.

- **Docker not installed:** To fix, [Install Docker](https://docs.docker.com/get-docker/) or [Docker Destkop](https://www.docker.com/products/docker-desktop/).



* * *
* * *

## Details

I have included a details section if you wanted a deeper dive into how this script was made, and it's function.


* * *

### Tools Used

- `djpeg` and `cjpeg` – from a JPEG toolkit (e.g. [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo) or [MozJPEG](https://github.com/mozilla/mozjpeg)).  The script pipes each image through `djpeg` (to decode) into `cjpeg` (to re-encode) with options `-optimize -progressive`.  These flags produce smaller final JPEGs (the `-optimize` option “is worth using when you are making a ‘final’ version”).  *(Note: piping can strip EXIF data, so the script uses [exiftool](#) below to restore metadata.)*

- `exiftool` – for copying metadata.  After recompression the script runs:

- `md5sum` (or `md5`) – for hashing files.  The script uses `md5sum` (Linux) or `md5 -q` (macOS) to detect if an image has already been processed.


* * *

### Log File

The script keeps a history log of processed files (`$PROCESS_DIR/.jpg_files_optimized--keepme.log`).  This log stores one line per image, with fields separated by `|`:

```
filepath|hash|compressed_size|date|original_size|compressed_size
```

After each successful optimization, the script appends a line via the `add_to_temp_log` function:

```bash
add_to_temp_log "$jpg_file" "$compressed_hash" "$original_size" "$new_size"
```

This function calculates the current date and writes the entry: e.g.

```
/path/to/image.jpg|d41d8cd98f00b204e9800998ecf8427e|123456|2025-06-25 23:00:00|234567|123456
```

(Last two columns are original and new sizes in bytes.)

The log is also used to check if a file was already processed: before re-optimizing, the script compares the current file’s hash and size to the log entries.  If a match is found, that file is skipped as “already processed”.


* * *

### File Locking

To prevent multiple instances from running at once (which could corrupt the log or compete for files), the script uses a lock file.  It does this by redirecting a file descriptor and using `flock`:

```bash
LOCKFILE="/tmp/.jpg_optimizer.lock"
exec 200>"$LOCKFILE"
flock -n 200 || {
  echo "Another instance is already running. Exiting." >&2
  exit 1
}
```

Here `exec 200> "$LOCKFILE"` opens file descriptor 200 on the lockfile, and `flock -n 200` obtains an exclusive non-blocking lock.  If locking fails, the script exits.  This is a common Bash pattern for locking.  A `cleanup()` function is hooked via `trap` on `INT`, `TERM`, and `EXIT` to remove the lock on exit.


* * *

### Scanning and Threshold Check

The script builds its list of images with `find`.  In the function `get_files_to_optimize`, it runs:

```bash
find "$PROCESS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0 | while IFS= read -r -d '' file; do
    # Skip files under the backups folder
    if [[ "$file" == *"/originals/"* ]]; then continue; fi
    # Only select if above size threshold and not already in log
    if file_above_threshold "$file" && ! is_file_processed "$file"; then
        echo "$file"
    fi
done
```

This ensures only JPEGs in (or below) `PROCESS_DIR` are considered, skipping any in the `originals` backup subdirectory.  The helper `file_above_threshold` checks `stat` to compare the file’s size to the threshold in bytes.  Small files are skipped (counted as “untouched”), and already-logged files are ignored.

A summary function `count_jpg_files` prints counts of total files found, below-threshold, already processed, and to-be-optimized.  This gives an overview before the actual optimization run.


* * *

### Backup Originals

Before overwriting any JPEG, the script moves the original file into the backup directory (`$ORIGINALS_DIR`) using the `backup_original` function.  This function:

- Strips off the base `PROCESS_DIR` path to determine a relative path.

- Creates a mirrored directory under `originals/`.

- Builds a new filename: either appending the `SUFFIX` (if set) or adding a UNIX timestamp.

- Ensures uniqueness by appending a counter if that filename already exists.

- Finally `mv`s the file to the backup location, preserving the full relative folder structure, and echoes the backup path.

> For example, `image.jpg` might be backed up as `image_1624567890.jpg` in `originals/`, or `image_suffix.jpg` if `SUFFIX=_suffix`. This way you never lose the uncompressed original.  (The script logs the original path in the log as well.)


* * *

### Optimization Pipeline

For each file to optimize, the script runs `optimize_jpg_file`.  Here’s an excerpt of that code:

```bash
# Copy original to a temp location for metadata and fallback
cp "$jpg_file" "$temp_backup"

# Recompress JPG with cjpeg for optimization
if djpeg "$temp_backup" | cjpeg -quality "$JPEG_QUALITY" $JPEG_OPT_FLAGS > "$temp_file"; then
    # Copy all metadata from original to recompressed
    if exiftool -TagsFromFile "$temp_backup" -all:all "$temp_file" -overwrite_original > /dev/null; then
        local new_size=$(stat -c%s "$temp_file")
        # Move original to backup dir
        backup_original "$jpg_file"
        # Replace original with optimized
        mv "$temp_file" "$jpg_file"
        # Restore original modification time
        set_file_mtime "$jpg_file" "$original_mtime"
        # Log the compression
        local compressed_hash=$(get_file_hash "$jpg_file")
        add_to_temp_log "$jpg_file" "$compressed_hash" "$original_size" "$new_size"
        ...
        echo "✓ Optimized: $(basename "$jpg_file") (saved ${percent_savings}% )"
    fi
else
    echo "✗ Error recompressing: $jpg_file"
fi
```

So, for each image, the script:

1. **Copy to temp**: The original is first `cp`ed to `$file.tempbackup`, so we have it safe for metadata and size checks.

2. **Recompress**: It pipes `djpeg` into `cjpeg` with the quality and flags, outputting a new `.tmp` file.  (This effectively decodes the JPEG to raw pixels and re-encodes it.)  As noted, piping can drop EXIF metadata, so…

3. **Restore metadata**: The script runs `exiftool -TagsFromFile original backupfile.jpg` to copy all metadata into the new file.  This ensures EXIF/IPTC data is retained.

4. **Check success**: If the above steps succeed, it then computes the new file’s size and hash.

5. **Backup original**: The original `$jpg_file` is moved into the backup directory by calling `backup_original`.

6. **Replace and touch**: The optimized temp file replaces the original (`mv` into its place), and the script uses `touch -t` to set its modification time back to the original date.  (This preserves the original timestamp.)

7. **Log entry**: Finally it logs the operation (file path, hash, old size, new size, date) using `add_to_temp_log`.


After each file, the script prints a message like “✓ Optimized: image.jpg (1234KB → 987KB, saved 20%)” based on the size savings.  If any step fails (recompression or metadata copy), it prints an error and cleans up temp files.

These steps are run in a loop over all found files.  The `process_all_jpgs` function collects the file list, then iterates with progress counters, printing `[N/M (P%)]` before each file. At the end it summarizes how many succeeded/failed and total log entries.

Check out the ASCII flow diagram below to help illustrate this pipeline from scanning → compressing → backing-up → logging.


* * *

### ASCII Flow of the In-Place JPG Optimizer script


<details>

<summary>Visual Script Breakdown</summary>

```
IN-PLACE JPG OPTIMIZER - EXECUTION FLOW
═══════════════════════════════════════════════════════════════════════════════════════════════

START
  │
  ├─ PROCESS LOCKING & INITIALIZATION
  │   ├─ Create lockfile (/tmp/.jpg_optimizer.lock)
  │   ├─ Check for existing instance ──[RUNNING]──► EXIT "Already running"
  │   │                                    │
  │   │                                   [OK]
  │   │                                    ▼
  │   ├─ Set trap for cleanup (INT/TERM/EXIT signals)
  │   └─ Initialize environment variables:
  │       ├─ PROCESS_DIR=/workdir
  │       ├─ JPEG_QUALITY=85
  │       ├─ SIZE_THRESHOLD=5250KB (5,376,000 bytes)
  │       ├─ ORIGINALS_DIR=/workdir/originals
  │       └─ TEMP_LOG_FILE=.jpg_files_optimized--keepme.log
  │
  ├─ VALIDATION & SETUP
  │   ├─ Check if PROCESS_DIR exists ──[NO]──► EXIT ERROR
  │   │                                  │
  │   │                                 [YES]
  │   │                                  ▼
  │   ├─ init_logs() - Create/touch temp log file
  │   └─ Load existing processing history
  │
  ├─ FILE DISCOVERY & ANALYSIS
  │   ├─ Scan for JPG/JPEG files (case-insensitive)
  │   ├─ Skip files in /originals/ directory
  │   ├─ For each file found:
  │   │   ├─ Check file_above_threshold() (>5250KB)
  │   │   ├─ Check is_file_processed() (hash+size match in log)
  │   │   └─ Categorize file for processing
  │   │
  │   └─ Display file count summary:
  │       ├─ Total JPG files found: X
  │       ├─ Files below 5250KB (untouched): Y
  │       ├─ Files already processed: Z
  │       └─ Files to optimize: W
  │
  ├─ PRE-PROCESSING VALIDATION
  │   ├─ Check if files_to_optimize > 0 ──[NO]──► EXIT "No files to optimize"
  │   │                                     │
  │   │                                    [YES]
  │   │                                     ▼
  │   └─ Display processing warnings and backup info
  │
  ├─ MAIN PROCESSING LOOP
  │   │
  │   └─ For each file to optimize:
  │       │
  │       ├─ Display progress: [N/Total] (X%)
  │       │
  │       ├─ optimize_jpg_file() PROCESS:
  │       │   │
  │       │   ├─ Capture original mtime: get_file_mtime()
  │       │   ├─ Create temp backup: file.jpg.tempbackup
  │       │   ├─ Record original_size for statistics
  │       │   │
  │       │   ├─ RECOMPRESSION PIPELINE:
  │       │   │   ├─ djpeg tempbackup | cjpeg -quality 85 -optimize -progressive
  │       │   │   └─ Output to: file.jpg.tmp
  │       │   │
  │       │   ├─ METADATA PRESERVATION:
  │       │   │   ├─ exiftool -TagsFromFile tempbackup -all:all file.jpg.tmp
  │       │   │   └─ Check success ──[FAIL]──► Cleanup & Return Error
  │       │   │                        │
  │       │   │                       [OK]
  │       │   │                        ▼
  │       │   ├─ BACKUP & REPLACEMENT:
  │       │   │   ├─ backup_original() - Move original to /originals/
  │       │   │   │   ├─ Create backup directory structure
  │       │   │   │   ├─ Generate unique backup filename:
  │       │   │   │   │   ├─ With SUFFIX: basename_SUFFIX.jpg
  │       │   │   │   │   └─ With timestamp: basename_timestamp.jpg
  │       │   │   │   └─ Handle filename conflicts with counter
  │       │   │   │
  │       │   │   ├─ mv file.jpg.tmp → file.jpg (replace original)
  │       │   │   └─ set_file_mtime() - Restore original timestamp
  │       │   │
  │       │   ├─ LOGGING & STATISTICS:
  │       │   │   ├─ Calculate compression savings (KB & percentage)
  │       │   │   ├─ Generate file hash: get_file_hash()
  │       │   │   ├─ add_to_temp_log() with pipe-delimited format:
  │       │   │   │   └─ filepath|hash|size|date|original_size|compressed_size
  │       │   │   └─ Display: "✓ Optimized: file.jpg (XKB → YKB, saved Z%)"
  │       │   │
  │       │   └─ Cleanup temp files & return success
  │       │
  │       └─ Update progress counter
  │
  ├─ FINAL STATISTICS & CLEANUP
  │   ├─ Display processing summary:
  │   │   ├─ Files optimized: X
  │   │   ├─ Files failed: Y
  │   │   └─ Total in log: Z
  │   │
  │   └─ cleanup() function (via trap):
  │       ├─ Remove lockfile
  │       └─ Release file lock
  │
  └─ END

PROCESSING DECISION TREE
════════════════════════
For each JPG file found:
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│  File: example.jpg                                                              │
│  │                                                                              │
│  ├─ In /originals/ directory? ──[YES]──► SKIP (avoid processing backups)       │
│  │                                │                                             │
│  │                               [NO]                                           │
│  │                                ▼                                             │
│  ├─ Size > 5250KB? ──[NO]──► SKIP (below threshold)                            │
│  │                    │                                                         │
│  │                   [YES]                                                      │
│  │                    ▼                                                         │
│  ├─ Already processed? ──[YES]──► SKIP (hash+size match in log)                │
│  │   (hash + size check)  │                                                     │
│  │                       [NO]                                                   │
│  │                        ▼                                                     │
│  └─ ADD TO OPTIMIZATION QUEUE                                                   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘

TEMP LOG FILE STRUCTURE
═══════════════════════
File: .jpg_files_optimized--keepme.log
Format: filepath|hash|size|date|original_size|compressed_size

Example entries:
/workdir/photo1.jpg|a1b2c3d4e5f6|2048000|2024-01-15 14:30:25|3145728|2048000
/workdir/subdir/photo2.jpg|f6e5d4c3b2a1|1536000|2024-01-15 14:31:12|2621440|1536000

BACKUP DIRECTORY STRUCTURE
═══════════════════════════
Original: /workdir/subdir/photo.jpg
Backup:   /workdir/originals/subdir/photo_1642251825.jpg
                                    └─ timestamp or suffix

TOOLS & UTILITIES USED
═══════════════════════
┌─ Image Processing ─┐    ┌─ Metadata Handling ─┐    ┌─ File Operations ─┐
│ • djpeg (decode)    │    │ • exiftool (copy)    │    │ • find (discover)  │
│ • cjpeg (encode)    │    │ • date (timestamps)  │    │ • stat (file info) │
│ • Quality: 85       │    │ • touch (set mtime)  │    │ • mv/cp (move/copy)│
│ • -optimize flag    │    │ • md5sum/md5 (hash)  │    │ • flock (locking)  │
│ • -progressive flag │    │                      │    │ • trap (cleanup)   │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘

HELPER FUNCTIONS USED:
═════════════════════
• get_file_hash() - MD5 hash or size_mtime fallback
• get_file_size_bytes() - Cross-platform file size
• is_file_processed() - Check against temp log
• file_above_threshold() - Size comparison
• get_file_mtime() / set_file_mtime() - Timestamp handling
• backup_original() - Move to originals directory
• add_to_temp_log() - Pipe-delimited logging


SAFETY FEATURES
═══════════════
├─ Process Locking: Prevents multiple instances
├─ Original Backup: All originals moved to /originals/ before modification
├─ Metadata Preservation: Full EXIF data copied to optimized files
├─ Timestamp Preservation: Original modification times restored
├─ Processing History: Permanent log prevents duplicate processing
├─ Error Handling: Failed operations don't affect originals
├─ Unique Filenames: Backup naming prevents overwrites
└─ Signal Trapping: Clean exit on interruption

```

</details>
