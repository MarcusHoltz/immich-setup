#!/bin/bash

###############################################################################
# Enhanced Batch CR2/JPG/MP4 Photo & Video Processor - Docker Version
#
# This script batch-processes Canon CR2 RAW files, JPGs, and MP4s from a source
# directory, converting CR2 files to optimized JPEGs, copying JPG and MP4 files,
# and preserving metadata. It includes size-based JPG processing and EXIF
# timestamp setting. It logs processed files to avoid duplicates and displays progress.
#
# --- DOCKER USAGE ---
# This version is designed to run in a Docker container with mounted volumes.
# The source and destination paths are set via environment variables.
###############################################################################

# --- Config Section ---

# Use environment variables if set, otherwise use default paths
src_root="${SRC_ROOT:-/input}"
dst_root="${DST_ROOT:-/output}"

log_file="$dst_root/processed_files.log"   # Log of processed files
progress_file="$dst_root/.progress_counter" # Progress tracker file

# JPEG Quality setting (85-90 is typical for Google Pixel/GCam, balancing quality & file size)
JPEG_QUALITY=85                       # JPEG output quality (1-100)
JPEG_OPT_FLAGS="-optimize -progressive" # JPEG optimization flags

# Size threshold in bytes (5250KB = 5,376,000 bytes)
SIZE_THRESHOLD=5376000

# --- Log Functions ---

# Initializes the log file and destination directory.
init_log() {
    mkdir -p "$dst_root"
    touch "$log_file"
}

# Returns the number of processed files (lines in the log).
count_processed() {
    if [ -f "$log_file" ]; then
        wc -l < "$log_file"
    else
        echo 0
    fi
}

# Checks if a given file has already been processed (logged).
already_processed() {
    if [ -f "$log_file" ]; then
        grep -Fxq "$1" "$log_file"
    else
        return 1
    fi
}

# Adds a file path to the processed files log.
add_to_log() {
    echo "$1" >> "$log_file"
}

# --- Progress Functions ---

# Initializes the progress counter based on already processed files.
init_progress() {
    local processed_files
    processed_files=$(count_processed)
    echo "$processed_files" > "$progress_file"
}

# Displays progress as "current/total (percent%)"
show_progress() {
    local current=$(cat "$progress_file")
    local total=$1
    local percent=0
    if [ "$total" -gt 0 ]; then
        percent=$((current * 100 / total))
    fi
    echo "Progress: $current/$total ($percent% complete)"
}

# Increments progress counter and displays progress.
update_progress() {
    local current=$(cat "$progress_file")
    current=$((current + 1))
    echo "$current" > "$progress_file"
    show_progress "$1"
}

# Removes the progress counter file (cleanup).
cleanup_progress() {
    rm -f "$progress_file"
}

# --- EXIF Timestamp Functions ---

# Function to set file timestamp based on EXIF data
set_file_timestamp() {
    local file="$1"
    
    # Get the file's original date from EXIF
    local original_date=$(exiftool -DateTimeOriginal -s3 "$file" 2>/dev/null)
    if [[ -z "$original_date" ]]; then
        # Fall back to ImageDateTime if DateTimeOriginal is not available
        original_date=$(exiftool -ImageDateTime -s3 "$file" 2>/dev/null)
    fi

    # If we found a valid date, set the file's modified date to it
    if [[ -n "$original_date" ]]; then
        # Convert to a format that `touch` can understand
        local timestamp=$(date -d "$original_date" +"%Y%m%d%H%M.%S" 2>/dev/null)
        if [[ -n "$timestamp" ]]; then
            touch -t "$timestamp" "$file" 2>/dev/null
            echo "  → Set timestamp for $(basename "$file") to $original_date"
            return 0
        fi
    fi
    return 1
}

# --- Size Check Functions ---

# Check if file size is above threshold
file_above_threshold() {
    local file="$1"
    local file_size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
    
    if [[ -n "$file_size" && "$file_size" -gt "$SIZE_THRESHOLD" ]]; then
        return 0  # File is above threshold
    else
        return 1  # File is below threshold
    fi
}

# --- File Counting Functions ---

# Counts unprocessed CR2 files in the source directory.
count_cr2_files() {
    local count=0
    while IFS= read -r -d '' file; do
        if ! already_processed "$file"; then
            ((count++))
        fi
    done < <(find "$src_root" -type f \( -iname "*.CR2" -o -iname "*.cr2" \) -print0)
    echo "$count"
}

# Counts unprocessed JPG files in the source directory.
count_jpg_files() {
    local count=0
    while IFS= read -r -d '' file; do
        if ! already_processed "$file"; then
            ((count++))
        fi
    done < <(find "$src_root" -type f \( -iname "*.JPG" -o -iname "*.jpg" \) -print0)
    echo "$count"
}

# Counts unprocessed MP4 files in the source directory.
count_mp4_files() {
    local count=0
    while IFS= read -r -d '' file; do
        if ! already_processed "$file"; then
            ((count++))
        fi
    done < <(find "$src_root" -type f \( -iname "*.MP4" -o -iname "*.mp4" \) -print0)
    echo "$count"
}

# --- File Processing Functions ---

# Converts unprocessed CR2 files to JPEG, copying metadata.
process_cr2_files() {
    local jpg_compressed=0
    find "$src_root" -type f \( -iname "*.CR2" -o -iname "*.cr2" \) -print0 | while IFS= read -r -d '' cr2file; do
        if already_processed "$cr2file"; then
            echo "Skipping already processed: $cr2file"
            continue
        fi
        rel_path="${cr2file#$src_root/}"              # Relative path from src_root
        rel_dir=$(dirname "$rel_path")                # Subdirectory structure
        base_name=$(basename "$cr2file")
        base_name="${base_name%.*}"                   # Remove extension
        out_dir="$dst_root/$rel_dir"                  # Output directory
        out_file="$out_dir/${base_name}.jpg"          # Output JPEG file path
        mkdir -p "$out_dir"
        
        # Convert CR2 to JPEG with dcraw and cjpeg
        if dcraw -c -w "$cr2file" | cjpeg -quality "$JPEG_QUALITY" $JPEG_OPT_FLAGS > "$out_file"; then
            # Copy all metadata from CR2 to JPEG
            exiftool -TagsFromFile "$cr2file" -all:all "$out_file" -overwrite_original > /dev/null 2>&1
            
            # Set timestamp based on EXIF data
            set_file_timestamp "$out_file"
            
            add_to_log "$cr2file"
            echo "✓ Converted: $cr2file -> $out_file"
            ((jpg_compressed++))
        else
            echo "✗ Error converting: $cr2file"
        fi
        update_progress "$1"
    done
    echo "$jpg_compressed" > "$dst_root/.cr2_converted"
}

# Process large JPG files with compression and metadata preservation
process_large_jpg_file() {
    local source_file="$1"
    local dest_file="$2"
    local temp_file="${dest_file}.tmp"
    
    local file_size=$(stat -c%s "$source_file" 2>/dev/null || stat -f%z "$source_file" 2>/dev/null)
    local file_kb=$((file_size / 1024))
    echo "Processing large JPG (${file_kb}KB > 5250KB): $(basename "$source_file")"
    
    # Recompress JPG with cjpeg for optimization
    if djpeg "$source_file" | cjpeg -quality "$JPEG_QUALITY" $JPEG_OPT_FLAGS > "$temp_file"; then
        # Copy all metadata from original JPG to recompressed JPG
        if exiftool -TagsFromFile "$source_file" -all:all "$temp_file" -overwrite_original > /dev/null 2>&1; then
            # Move the processed file to final location
            mv "$temp_file" "$dest_file"
            
            # Set timestamp based on EXIF data
            set_file_timestamp "$dest_file"
            
            # Calculate compression savings
            local new_size=$(stat -c%s "$dest_file" 2>/dev/null || stat -f%z "$dest_file" 2>/dev/null)
            if [[ -n "$new_size" ]]; then
                local savings=$((file_size - new_size))
                local percent_savings=$((savings * 100 / file_size))
                local new_kb=$((new_size / 1024))
                echo "✓ Compressed and optimized: ${file_kb}KB → ${new_kb}KB (saved ${percent_savings}%)"
            else
                echo "✓ Processed and optimized: $(basename "$dest_file")"
            fi
            return 0
        else
            echo "✗ Error copying metadata for: $source_file"
            rm -f "$temp_file"
            return 1
        fi
    else
        echo "✗ Error recompressing: $source_file"
        rm -f "$temp_file"
        return 1
    fi
}

# Move small JPG files with timestamp setting (no compression)
move_small_jpg_file() {
    local source_file="$1"
    local dest_file="$2"
    
    local file_size=$(stat -c%s "$source_file" 2>/dev/null || stat -f%z "$source_file" 2>/dev/null)
    local file_kb=$((file_size / 1024))
    echo "Setting timestamp only for small JPG (${file_kb}KB ≤ 5250KB): $(basename "$source_file")"
    
    # Copy file preserving timestamps initially
    if cp -p "$source_file" "$dest_file"; then
        # Set timestamp based on EXIF data
        set_file_timestamp "$dest_file"
        echo "✓ Copied with timestamp update: $(basename "$dest_file")"
        return 0
    else
        echo "✗ Error copying: $source_file"
        return 1
    fi
}

# Processes unprocessed JPG files with size-based handling and timestamp setting
copy_jpg_files() {
    local jpg_compressed=0
    local jpg_timestamp_only=0
    local jpg_already_processed=0
    
    find "$src_root" -type f \( -iname "*.JPG" -o -iname "*.jpg" \) -print0 | while IFS= read -r -d '' jpgfile; do
        rel_path="${jpgfile#$src_root/}"
        rel_dir=$(dirname "$rel_path")
        base_name=$(basename "$jpgfile")
        out_dir="$dst_root/$rel_dir"
        out_file="$out_dir/$base_name"
        mkdir -p "$out_dir"
        
        if already_processed "$jpgfile"; then
            echo "Already processed, updating timestamp: $jpgfile"
            # Still set timestamp for already processed files
            if [[ -f "$out_file" ]]; then
                set_file_timestamp "$out_file"
                ((jpg_already_processed++))
            fi
            continue
        fi
        
        # Check file size and process accordingly
        if file_above_threshold "$jpgfile"; then
            # Large JPG file - compress and optimize
            if process_large_jpg_file "$jpgfile" "$out_file"; then
                add_to_log "$jpgfile"
                ((jpg_compressed++))
            else
                echo "Failed to compress $jpgfile, trying regular copy..."
                if move_small_jpg_file "$jpgfile" "$out_file"; then
                    add_to_log "$jpgfile"
                    ((jpg_timestamp_only++))
                fi
            fi
        else
            # Small JPG file - copy only with timestamp setting
            if move_small_jpg_file "$jpgfile" "$out_file"; then
                add_to_log "$jpgfile"
                ((jpg_timestamp_only++))
            fi
        fi
        update_progress "$1"
    done
    
    # Save statistics
    echo "$jpg_compressed" > "$dst_root/.jpg_compressed"
    echo "$jpg_timestamp_only" > "$dst_root/.jpg_timestamp_only"
    echo "$jpg_already_processed" > "$dst_root/.jpg_already_processed"
}

# Copies unprocessed MP4 files, preserving directory structure and setting timestamps.
copy_mp4_files() {
    find "$src_root" -type f \( -iname "*.MP4" -o -iname "*.mp4" \) -print0 | while IFS= read -r -d '' mp4file; do
        if already_processed "$mp4file"; then
            echo "Skipping already processed: $mp4file"
            continue
        fi
        rel_path="${mp4file#$src_root/}"
        rel_dir=$(dirname "$rel_path")
        base_name=$(basename "$mp4file")
        out_dir="$dst_root/$rel_dir"
        out_file="$out_dir/$base_name"
        mkdir -p "$out_dir"
        
        if cp -p "$mp4file" "$out_file"; then
            # Try to set timestamp based on EXIF data if available
            set_file_timestamp "$out_file"
            
            add_to_log "$mp4file"
            echo "✓ Copied: $mp4file -> $out_file"
        else
            echo "✗ Error copying: $mp4file"
        fi
        update_progress "$1"
    done
}

# --- Main Program ---

echo "Enhanced Photo Processing Script - Docker Version"
echo "================================================"
echo "Source directory: $src_root"
echo "Destination directory: $dst_root"
echo "JPEG Quality: $JPEG_QUALITY"
echo "Size threshold: 5250KB (files above this will be compressed)"
echo ""

# Check if source directory exists and has files
if [ ! -d "$src_root" ]; then
    echo "Error: Source directory $src_root does not exist!"
    exit 1
fi

# Initialize logging.
init_log

# Count already processed and to-be-processed files.
echo "Counting files to process..."
processed_files=$(count_processed)
total_cr2=$(count_cr2_files)
total_jpg=$(count_jpg_files)
total_mp4=$(count_mp4_files)
total_files=$((total_cr2 + total_jpg + total_mp4))

echo ""
echo "Already processed files: $processed_files"
echo ""
echo "Found $total_files files to process:"
echo " - CR2 files: $total_cr2"
echo " - JPG files: $total_jpg (all will get timestamp updates)"
echo " - MP4 files: $total_mp4"
echo ""

if [ "$total_files" -eq 0 ]; then
    echo "No files to process. Exiting."
    exit 0
fi

echo "Starting processing..."
echo "- Large JPG files (>5250KB): Will be compressed and optimized"
echo "- Small JPG files (≤5250KB): Will only get timestamp updates"
echo "- All files: Will have timestamps set based on EXIF data"
echo ""

# Initialize progress tracking.
init_progress

# Initialize statistics files
echo "0" > "$dst_root/.cr2_converted"
echo "0" > "$dst_root/.jpg_compressed"
echo "0" > "$dst_root/.jpg_timestamp_only"
echo "0" > "$dst_root/.jpg_already_processed"

# Process each file type.
if [ "$total_cr2" -gt 0 ]; then
    echo "Processing CR2 files..."
    process_cr2_files "$total_files"
fi

if [ "$total_jpg" -gt 0 ]; then
    echo "Processing JPG files..."
    copy_jpg_files "$total_files"
fi

if [ "$total_mp4" -gt 0 ]; then
    echo "Processing MP4 files..."
    copy_mp4_files "$total_files"
fi

# Clean up progress tracker.
cleanup_progress

# Read and display final statistics
cr2_converted=$(cat "$dst_root/.cr2_converted" 2>/dev/null || echo 0)
jpg_compressed=$(cat "$dst_root/.jpg_compressed" 2>/dev/null || echo 0)
jpg_timestamp_only=$(cat "$dst_root/.jpg_timestamp_only" 2>/dev/null || echo 0)
jpg_already_processed=$(cat "$dst_root/.jpg_already_processed" 2>/dev/null || echo 0)

echo ""
echo "Processing complete!"
echo "==================="
echo "Statistics:"
echo " - CR2 files converted: $cr2_converted"
echo " - JPG files compressed & optimized: $jpg_compressed"
echo " - JPG files with timestamp only: $jpg_timestamp_only"
echo " - Already processed files (timestamp updated): $jpg_already_processed"
echo " - MP4 files copied: $((total_mp4 > 0 ? total_mp4 : 0))"
echo ""
echo "All JPG files had their timestamps set based on EXIF data."

# Clean up statistics files
rm -f "$dst_root/.cr2_converted" "$dst_root/.jpg_compressed" "$dst_root/.jpg_timestamp_only" "$dst_root/.jpg_already_processed"
