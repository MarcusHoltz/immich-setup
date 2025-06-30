# In-Place MP4 Optimizer

- [In-Place MP4 Optimizer](#in-place-mp4-optimizer)
  - [In-Place MP4 Optimizer Introducton](#in-place-mp4-optimizer-introducton)
  - [What exactly does In-Place MP4 Optimizer Do](#what-exactly-does-in-place-mp4-optimizer-do)
  - [Quick Instructions](#quick-instructions)
  - [FAQ](#faq)
  - [Example Output](#example-output)
  - [Troubleshooting](#troubleshooting)
  - [Details](#details)


* * *

## In-Place MP4 Optimizer Introducton

- **This script will:** Scans a directory of MP4 videos, recompresses each file that meets certain condition, keep all metadata, and back up originals.

- **To use this script:** Just run this in your media folder with Docker.

- **What happens:** Replaces the original .mp4 with the optimized version. The original file is saved in a backup folder, and details of each processed file are logged. 

- **What to configure:** `CRF`, `PRESET` and `SIZE_THRESHOLD_KB` - Constant Compression Factor, Preset the speed of compression, and min size of files to compress.


* * *

## What exactly does In-Place MP4 Optimizer Do

- **Finds all mp4/MP4 files in your folder tree above a certain size (default: 5250KB)**

- **Optimizes the files in-place, meaning, same filename and same location**

- **Preserves ALL metadata (EXIF, GPS, etc) and keeps the original modified date**

- **Backs up the original file (with folder structure) to an `originals/` directory**

- **Shows progress as it works**

- **Skips files it already processed if interrupted (resumes cleanly)**


* * *

## Quick Instructions

1. Have [Docker](https://docs.docker.com/get-docker/) Ready

2. Put your media in a folder, e.g. `./media`

3. Copy the provided `docker-compose.yml`, `Dockerfile`, and `inplace_mp4_optimizer.sh` into that folder

4. Edit `docker-compose.yml` to change the size threshold or quality:

- `PROCESS_DIR`: Folder to process (default: `./`)

- `CRF`: Output MP4 quality (default: 21, range: 1-30)

   ```
   MP4 Quality ---
   - CRF 18-20: Very high quality – Almost indistinguishable from the original video. File size is noticeably larger than 21.
   - CRF 21: Default "good quality" – Best balance between quality and file size. This is the default for many tools like FFmpeg.
   - CRF=21       # Default CRF video compression value is 21
   ```

- `PRESET` – The FFmpeg preset for speed vs. compression (default `"slow"`).  Common values include `medium`, `slow`, `slowest`.

- `SUFFIX` – Optional text to append to backup filenames, to avoid confusion if using a flat filesystem.

- `SIZE_THRESHOLD_KB`:  Minimum file size (in kilobytes) to consider for optimization (default 5250 KB).  Files below this size are skipped entirely.

5. Run the container and have it remove itself when complete:

   ```bash

   docker compose run --rm mp4-optimizer

   ```

6. Done!

   - Optimized JPGs are now in place

   - Originals are in `originals/`  

   - Progress is shown as it works



* * *

## FAQ

**Q: Will this overwrite my MP4 files?**  
A: Yes, but it moves the original to `originals/` first, preserving the folder structure.

**Q: What if the process is interrupted?**  
A: It keeps a log and will skip already optimized files on the next run.

**Q: Will it change the quality of my videos?**  
A: The script uses CRF 21 (high quality) by default. You can adjust this with the `CRF` environment variable (lower = higher quality).

**Q: What metadata is preserved?**  
A: All metadata is preserved in the optimized file using exiftool.

**Q: Will it change the timestamp on my files?**  
A: Only optimized files get their modified date set to the original's modified date. Files not optimized are untouched.

**Q: How do I change the size threshold or quality settings?**  
A: Set environment variables: `SIZE_THRESHOLD_KB` for minimum file size, `CRF` for quality (18-28 range), and `PRESET` for encoding speed.

**Q: What video formats are supported?**  
A: Only MP4 files are processed. The script looks for `.mp4` and `.MP4` extensions.

**Q: Can I customize the backup file naming?**  
A: Yes, set the `SUFFIX` environment variable to add a custom suffix, otherwise it uses timestamps.

**Q: How much space will I save?**  
A: Typically 30-50% file size reduction with minimal quality loss, depending on the original encoding.

**Q: What happens to audio tracks?**  
A: Audio is copied without re-encoding to preserve quality and processing speed.


* * *

## Example Output

```bash
$ ./inplace_mp4_optimizer.sh

In-Place MP4 Optimizer (with Originals Backup, Progress, mtime Copy, and Temp Log)
==================================================================================
Processing directory: /workdir
JPEG Quality: 85
Optimization flags: -optimize -progressive
Size threshold: 5250KB (5376000 bytes)
Originals backup directory: /workdir/originals
Files converted log file: /workdir/.mp4_files_optimized--keepme.log
Errors and unconverted file: /workdir/.mp4_files_optimized--errors.log

Loaded temp log with 3 previously processed files

Scanning for MP4 files...
Total MP4 files found: 15
Files below 5250KB (untouched): 7
Files already processed: 3
Files to optimize: 5

Suffix for originals: (timestamp-based)
Only files larger than 5250KB will be optimized.
Optimized files will have their mtimes set to their original modified date.
Originals will be moved to: /workdir/originals

WARNING: This will modify your original MP4 files in-place!
Make sure you have backups if needed.

Starting optimization of 5 files...

[1/5] (20%)
Optimizing: /workdir/vacation_video.mp4
   Time for vacation_video.mp4 set to 202312151430.25
✓ Optimized: vacation_video.mp4 (15240KB → 8950KB, saved 41%)
   Logged to processing history

[2/5] (40%)
Optimizing: /workdir/conference_recording.mp4
   Time for conference_recording.mp4 set to 202401081245.15
✓ Optimized: conference_recording.mp4 (22100KB → 14800KB, saved 33%)
   Logged to processing history

[3/5] (60%)
Optimizing: /workdir/family_reunion.mp4
   Time for family_reunion.mp4 set to 202312201600.45
✓ Optimized: family_reunion.mp4 (18750KB → 11200KB, saved 40%)
   Logged to processing history

[4/5] (80%)
Optimizing: /workdir/presentation_demo.mp4
   Time for presentation_demo.mp4 set to 202401151030.12
✓ Optimized: presentation_demo.mp4 (9860KB → 6420KB, saved 35%)
   Logged to processing history

[5/5] (100%)
Optimizing: /workdir/sports_highlights.mp4
   Time for sports_highlights.mp4 set to 202312281900.33
✓ Optimized: sports_highlights.mp4 (12300KB → 7850KB, saved 36%)
   Logged to processing history

Processing complete!
- Optimized: 5 files
- Failed: 0 files
- Total in log: 8 files

All done! MP4 files larger than 5250KB have been optimized in-place.
Optimized files have had their mtimes set to their original modified date.
Originals have been moved to: /workdir/originals
Converted files logged at: /workdir/.mp4_files_optimized--keepme.log
```


* * *

## Troubleshooting

- **Not enough space:** Make sure you have room for the `originals/` backup folder, which will contain copies of all original files.

- **Permissions:** Run as a user with read/write access to your photo folder.

- **"Error compressing" messages:** Check that your MP4 files aren't corrupted. Try playing them in a video player first.

- **"Error copying metadata" messages:** This usually means ExifTool failed. Check that ExifTool is properly installed and the file isn't corrupted.

- **Files not being processed:** Check that files are above the size threshold (default 5250KB) and not already in the log file.

- **Slow processing:** The default preset is "slow" for better compression. Set `PRESET=medium` or `PRESET=fast` for faster processing.

- **Quality too low:** Decrease the CRF value (e.g., `CRF=18` for higher quality) or increase it (e.g., `CRF=28`) for smaller files.

- **Script stops with "Directory does not exist":** Make sure the `PROCESS_DIR` path is correct and accessible.

- **Docker not installed:** To fix, [Install Docker](https://docs.docker.com/get-docker/) or [Docker Destkop](https://www.docker.com/products/docker-desktop/).


* * *
* * *

## Details

I have included a details section if you wanted a deeper dive into how this script was made, and it's function.


* * *

### Tools Used

Here are the tools and utilities the In-Place MP4 Optimizer uses:


#### Core Video Processing

- **FFmpeg** - The main tool for MP4 recompression using H.264 codec with configurable CRF and preset values

- **ExifTool** - Used to copy all metadata from the original file to the optimized version


#### System Utilities

- **find** - Locates MP4 files recursively in the directory

- **stat** - Gets file sizes and modification times (with fallback for different systems)

- **md5sum/md5** - Generates file hashes for tracking processed files

- **date** - Handles timestamps for logging and file modification times

- **touch** - Sets file modification times back to original values

- **mv/cp** - File operations for backups and temporary files

- **mkdir** - Creates backup directory structure

- **wc** - Counts lines in log files


#### Shell Features

- **Bash** - The script is written for Bash shell

- Various bash built-ins like `read`, `while`, `if`, `echo`, etc.


* * *

### Step-by-Step Inside the Script

Here’s what happens step by step:

- We capture the original file’s mtime (`get_file_mtime`) so we can restore it later.

- A **temporary backup** `${mp4_file}.tempbackup` is made by copying the original.  This serves two purposes: it preserves the original content, and it provides the source for metadata (since `ffmpeg` might strip some metadata when re-encoding).

- The script then runs `ffmpeg` quietly (`-loglevel quiet`) to re-encode the video using `libx264` with the specified `CRF` and `PRESET`.  Audio is copied as-is (`-c:a copy`).  The `-map_metadata 0` flag attempts to carry over metadata as well.

- If `ffmpeg` succeeds, `exiftool` is run to copy **all** metadata tags from the backup file into the new `.tmp.mp4`.  This ensures things like camera info, subtitles, and other tags are preserved.

- Next, `backup_original "$mp4_file"` moves the original file into the `originals/` directory.  (See **Backups and Naming** below.)

- The optimized file `.tmp.mp4` is then renamed to the original filename, effectively replacing it.

- We use `set_file_mtime` to restore the original modification timestamp on the new file, so it looks unchanged in terms of date.

- Finally, the script records details in the log.  It computes a hash of the new file, notes the original and new sizes, and appends a line to the temp log file via `add_to_temp_log`.  Then it removes the temporary backup copy.


* * *

### Configuration (Environment Variables)

The script’s behavior can be customized via environment variables.  Each has a default value (shown here with code comments), and you can override them by exporting before running the script or by prefixing the command. For example, to change the directory or CRF value. The relevant lines from the script are:

```bash
PROCESS_DIR="${PROCESS_DIR:-/workdir}"
JPEG_QUALITY="${JPEG_QUALITY:-85}"
SIZE_THRESHOLD_KB="${SIZE_THRESHOLD_KB:-5250}"
SIZE_THRESHOLD=$((SIZE_THRESHOLD_KB * 1024))
ORIGINALS_DIR="$PROCESS_DIR/originals"
TEMP_LOG_FILE="$PROCESS_DIR/.mp4_files_optimized--keepme.log"
ERROR_LOG_FILE="$PROCESS_DIR/.mp4_files_optimized--errors.log"
SUFFIX="${SUFFIX:-}"
CRF="${CRF:-21}"           # Default CRF value is 21
PRESET="${PRESET:-slow}"    # Default preset value is "slow"
```

* * *

- `PROCESS_DIR` – The root directory to scan for MP4 files (default `/workdir`).

- `SIZE_THRESHOLD_KB` – Minimum file size (in kilobytes) to consider for optimization (default 5250 KB).  Files below this size are skipped entirely.

- `CRF` – The FFmpeg Constant Rate Factor for compression (default 21; higher = more compression but lower quality).

- `PRESET` – The FFmpeg preset for speed vs. compression (default `"slow"`).  Common values include `fast`, `medium`, `slow`.

- `SUFFIX` – Optional text to append to backup filenames.  If unset, the script will use a timestamp in the filename instead.

The other variables are derived from these (e.g. `SIZE_THRESHOLD` in bytes, `ORIGINALS_DIR` for backups, log file paths).


* * *

### How Files Are Selected

When you run the script, it first **scans** the target directory for MP4 files and decides which ones to optimize.  This involves two checks:

1. **Size threshold:** The file must be larger than the `SIZE_THRESHOLD_KB`.  This avoids wasting time on tiny files.

2. **Not already optimized:** The script keeps a log (`.mp4_files_optimized--keepme.log`) of files it has processed (including their hash and size).  If a file’s path, hash, and size all match an entry in that log, it is considered “already processed” and will be skipped.


* * *

A function called `count_mp4_files()` walks through the directory (using `find`) and prints a summary.  For example:

```bash
count_mp4_files() {
    local total_found=0 below_threshold=0 already_processed=0 count=0
    while IFS= read -r -d '' file; do
        if [[ "$file" == *"/originals/"* ]]; then continue; fi
        ((total_found++))
        if file_above_threshold "$file"; then
            if is_file_processed "$file"; then
                ((already_processed++))
            else
                ((count++))
            fi
        else
            ((below_threshold++))
        fi
    done < <(find "$PROCESS_DIR" -type f \( -iname "*.mp4" -o -iname "*.MP4" \) -print0)
    echo "Total MP4 files found: $total_found"
    echo "Files below ${SIZE_THRESHOLD_KB}KB (untouched): $below_threshold"
    echo "Files already processed: $already_processed"
    echo "Files to optimize: $count"
}
```

> Here `is_file_processed()` reads the log file and checks for matching entries, so any file already optimized (and unchanged) will be skipped.  This log-based check is a safety mechanism to prevent redoing work.


* * *

### The Optimization Pipeline

Once the script has the list of files to optimize, it processes them one by one. The high-level flow for **each** file is:

1. **Record original info:** Save the file’s original modification time (`get_file_mtime`), and create a temporary backup copy (`.tempbackup`) of the file.

2. **Recompress:** Run `ffmpeg` to compress the video into a new temporary file (`.tmp.mp4`), using H.264 (`libx264`), the chosen CRF, and preset. Audio streams are copied.

3. **Copy metadata:** Run `exiftool` on the new file to copy all metadata (tags) from the original backup.

4. **Backup original:** Move the original file into an `originals/` subfolder, optionally appending the given `SUFFIX` or a timestamp to its name.  This ensures the original is preserved.

5. **Replace and restore timestamp:** Move the optimized temp file into the original file’s place, and set its modification time back to the original timestamp.

6. **Log results:** Compute a hash and sizes of the new file, and write a line to the log file. Print a summary of space savings.


* * *

Below are excerpts from the core function `optimize_mp4_file()` in the script:

```bash
optimize_mp4_file() {
    local original_mtime=$(get_file_mtime "$mp4_file")
    echo "Optimizing: $mp4_file"
    # Copy original to a temp backup (for metadata and fallback)
    cp "$mp4_file" "${mp4_file}.tempbackup"
    local original_size=$(get_file_size_bytes "${mp4_file}.tempbackup")

    # Recompress with ffmpeg
    if ffmpeg -i "$mp4_file" -map_metadata 0 -c:v libx264 -crf "$CRF" -preset "$PRESET" \
              -c:a copy "${mp4_file}.tmp.mp4"; then
        # Copy metadata from original to recompressed file
        if exiftool -TagsFromFile "${mp4_file}.tempbackup" -all:all "${mp4_file}.tmp.mp4" -overwrite_original; then
            local new_size=$(get_file_size_bytes "${mp4_file}.tmp.mp4")

            # Move original to backup location
            backup_original "$mp4_file"

            # Replace original with optimized file
            mv "${mp4_file}.tmp.mp4" "$mp4_file"
            set_file_mtime "$mp4_file" "$original_mtime"

            # Log the operation
            local compressed_hash=$(get_file_hash "$mp4_file")
            add_to_temp_log "$mp4_file" "$compressed_hash" "$original_size" "$new_size"
            rm "${mp4_file}.tempbackup"
            ...
```

After a successful optimization, the script prints a message with the saved space.

In case of an error (either `ffmpeg` fails or metadata copying fails), the script logs an error message to `$ERROR_LOG_FILE` and cleans up the temp files, then continues to the next file.


* * *

### Backups, Logging, and Timestamp Restoration

Let me break down the next bit into three different sections.


* * *

#### Backups

The original (uncompressed) files are moved into an `originals/` directory under `PROCESS_DIR`, preserving the subdirectory structure.  The naming of the backup file depends on the `SUFFIX` variable:

* If `SUFFIX` is set (for example `"_orig"`), the backup is named `basename_SUFFIX.mp4`.
* If `SUFFIX` is empty, the script appends a Unix timestamp: e.g. `basename_1638316800.mp4`.

The code handling this is:

```bash
if [[ -n "$SUFFIX" ]]; then
    backup_name="${base}${SUFFIX}.$ext"
else
    timestamp=$(date +%s)
    backup_name="${base}_${timestamp}.$ext"
fi
```

This ensures unique backup names (incrementing a counter if needed).

For example, if you have `video.mp4`, a backup might be `video_orig.mp4` or `video_1638316800.mp4` in `originals/`.


* * *

#### Logging

The script maintains a tab-delimited log file `.mp4_files_optimized--keepme.log` inside `PROCESS_DIR`.  Each entry records the file path, a hash, sizes, and timestamp.  This log serves two purposes:

* It provides a history of what was done (which can help with auditing or undoing changes if needed).
* The script uses it to **skip** files already optimized.  The function `is_file_processed()` reads this log and checks if a file’s path, hash, and size match a logged entry.  If so, the file is left untouched.

For example, `is_file_processed()` works roughly like this:

```bash
is_file_processed() {
    local current_hash=$(get_file_hash "$file")
    local current_size=$(get_file_size_bytes "$file")
    while IFS='|' read -r logged_file logged_hash logged_size ...; do
        if [[ "$logged_file" == "$file" && "$logged_hash" == "$current_hash" && "$logged_size" == "$current_size" ]]; then
            return 0  # Already processed
        fi
    done < "$TEMP_LOG_FILE"
    return 1
}
```


If a file matches, `is_file_processed` returns success and the script skips that file.  This prevents wasting time recompressing the same file twice (assuming it hasn’t changed).

#### Timestamp restoration

Because compressing a file would normally update its modification time, the script captures the original `mtime` before processing and then applies it back to the new file with `touch -t`.  This makes the optimized file appear to have the same date as before.


* * *

### Safety Mechanisms and Warnings

Several safeguards are in place:

- **Size threshold:** By default, very small MP4 files (under \~5 MB) are skipped.  You can adjust `SIZE_THRESHOLD_KB` to your needs.

- **Log-based skip:** Already-processed files are detected via the log, so re-running the script won’t touch them again unless their contents change.

- **Backups:** Originals are not deleted outright; they are moved to `originals/` for safekeeping.

- **Dry-run notice:** The script prints a clear warning before proceeding:

  > `WARNING: This will modify your original MP4 files in-place! Make sure you have backups if needed.`

- **Error logging:** Any errors in compression or metadata copying are written to `.mp4_files_optimized--errors.log` in the processing directory.

Together, these ensure you don’t lose data inadvertently and can undo or re-run safely if needed.


* * *

### Running the Script by Itself (No Docker - Examples)

Assuming the script file is named `inplace_mp4_optimizer.sh`, make it executable and run it like this:

```bash
chmod +x inplace_mp4_optimizer.sh
PROCESS_DIR="/path/to/videos" ./inplace_mp4_optimizer.sh
```

By default, it will process all `*.mp4` files in `/path/to/videos` larger than 5250 KB.  If you want to adjust settings, you can set environment variables on the command line. For example:

- **Use a different CRF and preset:** `CRF=23 PRESET=fast ./inplace_mp4_optimizer.sh`

- **Lower the size threshold to 1000 KB (1 MB):**
  `SIZE_THRESHOLD_KB=1000 ./inplace_mp4_optimizer.sh`

- **Add a suffix to backups:** `SUFFIX="_old" ./inplace_mp4_optimizer.sh`

You can also combine them, e.g.:

```bash
PROCESS_DIR="/videos" CRF=25 PRESET=medium SIZE_THRESHOLD_KB=2000 ./inplace_mp4_optimizer.sh
```

When you run it, the script will echo its configuration (the values of `PROCESS_DIR`, `CRF`, etc.) and then show progress messages for each file, like `[1/10] (10%) Optimizing: example.mp4`, followed by a checkmark and savings on success. At the end, it summarizes how many files were optimized, how many failed, and how many are listed in the log.

Check out the MP4 optimization pipeline diagram below for a visual overview.


* * *

### ASCII Flow of the In-Place MP4 Optimizer script

```
               +------------------------------+
               |   Start: Main Script Runs    |
               +------------------------------+
                            |
                            v
            +-------------------------------+
            |  Check PROCESS_DIR exists     |
            +-------------------------------+
                            |
                            v
            +-------------------------------+
            |  Load or init temp log file   |
            +-------------------------------+
                            |
                            v
            +-----------------------------------------+
            |  Scan for *.mp4 files (recursive)       |
            |  Skip originals/, skip small files,     |
            |  skip already logged (processed) files  |
            +-----------------------------------------+
                            |
                            v
            +-----------------------------------+
            |  For each file to optimize:       |
            +-----------------------------------+
                            |
                            v
    +------------------------------------------------+
    | 1. Save original mtime                         |
    | 2. Copy file → .tempbackup                     |
    | 3. Run ffmpeg → recompress → .tmp.mp4          |
    | 4. Use exiftool to restore metadata            |
    | 5. Move original → /originals/ (with suffix)   |
    | 6. Replace original with optimized .tmp.mp4     |
    | 7. Restore mtime                                |
    | 8. Log to .mp4_files_optimized--keepme.log      |
    +------------------------------------------------+
                            |
                            v
               +----------------------------+
               |  Repeat for next file      |
               +----------------------------+
                            |
                            v
            +-------------------------------+
            |  Show summary + Done message  |
            +-------------------------------+
```
