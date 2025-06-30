#!/bin/bash

###############################################################################
# In-Place JPG Optimizer (with Originals Backup, Progress, mtime Copy, and Temp Log)
###############################################################################

PROCESS_DIR="${PROCESS_DIR:-/workdir}"
JPEG_QUALITY="${JPEG_QUALITY:-85}"
JPEG_OPT_FLAGS="-optimize -progressive"
SIZE_THRESHOLD_KB="${SIZE_THRESHOLD_KB:-5250}"
SIZE_THRESHOLD=$((SIZE_THRESHOLD_KB * 1024))
ORIGINALS_DIR="$PROCESS_DIR/originals"
TEMP_LOG_FILE="$PROCESS_DIR/.jpg_files_optimized--keepme.log"
SUFFIX="${SUFFIX:-}"
# Log file with pipe-delimited format: filepath|hash|size|date|original_size|compressed_size


# --- File Locking ---
LOCKFILE="/tmp/.jpg_optimizer.lock"
exec 200>"$LOCKFILE"
flock -n 200 || {
  echo "Another instance is already running. Exiting." >&2
  exit 1
}

cleanup() {
  echo "Cleaning up..."
  rm -f "$LOCKFILE"
  flock -u 200
}

# If the script receives any of these signals (INT, TERM, or EXIT), call the function cleanup before the script exits.
trap cleanup INT TERM EXIT


init_logs() { 
    touch "$TEMP_LOG_FILE"
}

get_file_hash() {
    local file="$1"
    if command -v md5sum >/dev/null 2>&1; then
        md5sum "$file" 2>/dev/null | cut -d' ' -f1
    elif command -v md5 >/dev/null 2>&1; then
        md5 -q "$file" 2>/dev/null
    else
        # Fallback to size and mtime if no hash available
        local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
        local mtime=$(stat -c%Y "$file" 2>/dev/null || stat -f%m "$file" 2>/dev/null)
        echo "${size}_${mtime}"
    fi
}

get_file_size_bytes() {
    local file="$1"
    stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null
}

is_file_processed() {
    local file="$1"
    local current_hash=$(get_file_hash "$file")
    local current_size=$(get_file_size_bytes "$file")
    
    # Check if file exists in temp log with matching hash and size
    if [[ -f "$TEMP_LOG_FILE" ]]; then
        while IFS='|' read -r logged_file logged_hash logged_size logged_date logged_original_size logged_compressed_size; do
            if [[ "$logged_file" == "$file" && "$logged_hash" == "$current_hash" && "$logged_size" == "$current_size" ]]; then
                return 0  # File already processed
            fi
        done < "$TEMP_LOG_FILE"
    fi
    return 1  # File not processed
}

add_to_temp_log() {
    local file="$1"
    local file_hash="$2"
    local original_size="$3"
    local compressed_size="$4"
    local current_date=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "${file}|${file_hash}|${compressed_size}|${current_date}|${original_size}|${compressed_size}" >> "$TEMP_LOG_FILE"
}

file_above_threshold() {
    local file="$1"
    local file_size=$(get_file_size_bytes "$file")
    [[ -n "$file_size" && "$file_size" -gt "$SIZE_THRESHOLD" ]]
}

get_file_mtime() {
    local file="$1"
    date -r "$file" +"%Y%m%d%H%M.%S"
}

set_file_mtime() {
    local file="$1"
    local timestamp="$2"
    if [[ -n "$timestamp" ]]; then
        touch -t "$timestamp" "$file" 2>/dev/null
        echo "   Time for $(basename "$file") set to $timestamp"
    fi
}

backup_original() {
    local file="$1"
    local rel_path="${file#$PROCESS_DIR/}"
    local backup_dir="$ORIGINALS_DIR/$(dirname "$rel_path")"
    local filename="$(basename "$file")"
    local base="${filename%.*}"
    local ext="${filename##*.}"
    
    # Construct the backup filename with optional suffix
    if [[ -n "$SUFFIX" ]]; then
        local backup_name="${base}${SUFFIX}.$ext"
    else
        # Use timestamp if no suffix provided
        local timestamp=$(date +%s)
        local backup_name="${base}_${timestamp}.$ext"
    fi
    local backup_path="$backup_dir/$backup_name"
    
    # Ensure unique filename
    local counter=1
    while [[ -f "$backup_path" ]]; do
        if [[ -n "$SUFFIX" ]]; then
            backup_name="${base}${SUFFIX}_${counter}.$ext"
        else
            backup_name="${base}_${timestamp}_${counter}.$ext"
        fi
        backup_path="$backup_dir/$backup_name"
        ((counter++))
    done

    mkdir -p "$backup_dir"
    mv "$file" "$backup_path"
    echo "$backup_path"
}

# Get all files that need optimization (above threshold and not already processed)
get_files_to_optimize() {
    find "$PROCESS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0 2>/dev/null | \
    while IFS= read -r -d '' file; do
        # Skip files in originals directory
        if [[ "$file" == *"/originals/"* ]]; then
            continue
        fi
        
        if file_above_threshold "$file" && ! is_file_processed "$file"; then
            echo "$file"
        fi
    done
}

optimize_jpg_file() {
    local jpg_file="$1"
    local temp_file="${jpg_file}.tmp"
    local original_mtime
    original_mtime=$(get_file_mtime "$jpg_file")
    echo "Optimizing: $jpg_file"

    # Copy original to a temp location for metadata and fallback
    local temp_backup="${jpg_file}.tempbackup"
    cp "$jpg_file" "$temp_backup"
    
    # Get original file info for logging
    local original_size=$(get_file_size_bytes "$temp_backup")

    # Recompress JPG with cjpeg for optimization
    if djpeg "$temp_backup" | cjpeg -quality "$JPEG_QUALITY" $JPEG_OPT_FLAGS > "$temp_file"; then
        # Copy all metadata from original to recompressed
        if exiftool -TagsFromFile "$temp_backup" -all:all "$temp_file" -overwrite_original > /dev/null 2>&1; then
            local new_size=$(get_file_size_bytes "$temp_file")
            
            # Move original to backup location
            backup_original "$jpg_file"
            
            # Move optimized file to original location
            mv "$temp_file" "$jpg_file"
            
            # Set file's mtime to original mtime
            set_file_mtime "$jpg_file" "$original_mtime"
            
            # Get hash of compressed file for logging
            local compressed_hash=$(get_file_hash "$jpg_file")
            
            # Add to temp log
            add_to_temp_log "$jpg_file" "$compressed_hash" "$original_size" "$new_size"
            
            rm "$temp_backup"
            
            # Calculate space savings
            if [[ -n "$original_size" && -n "$new_size" ]]; then
                local savings=$((original_size - new_size))
                local percent_savings=$((savings * 100 / original_size))
                local original_kb=$((original_size / 1024))
                local new_kb=$((new_size / 1024))
                echo "✓ Optimized: $(basename "$jpg_file") (${original_kb}KB → ${new_kb}KB, saved ${percent_savings}%)"
                echo "   Logged to processing history"
                echo ""
            else
                echo "✓ Optimized: $(basename "$jpg_file")"
            fi
            return 0
        else
            echo "✗ Error copying metadata for: $jpg_file"
            rm -f "$temp_file" "$temp_backup"
            return 1
        fi
    else
        echo "✗ Error recompressing: $jpg_file"
        rm -f "$temp_file" "$temp_backup"
        return 1
    fi
}

count_jpg_files() {
    local count=0
    local total_found=0
    local below_threshold=0
    local already_processed=0
    
    while IFS= read -r -d '' file; do
        # Skip files in originals directory
        if [[ "$file" == *"/originals/"* ]]; then
            continue
        fi
        
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
    done < <(find "$PROCESS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0 2>/dev/null)
    
    echo "Total JPG files found: $total_found"
    echo "Files below ${SIZE_THRESHOLD_KB}KB (untouched): $below_threshold"
    echo "Files already processed: $already_processed"
    echo "Files to optimize: $count"
}

get_temp_log_count() {
    if [[ -f "$TEMP_LOG_FILE" ]]; then
        wc -l < "$TEMP_LOG_FILE" | tr -d ' '
    else
        echo "0"
    fi
}

process_all_jpgs() {
    local processed=0
    local failed=0
    local total_to_optimize
    local files_to_optimize=()
    
    # Build list of files to optimize and count
    while IFS= read -r file; do
        files_to_optimize+=("$file")
    done < <(get_files_to_optimize)
    
    total_to_optimize=${#files_to_optimize[@]}
    
    if [[ $total_to_optimize -eq 0 ]]; then
        echo "No files to optimize."
        return
    fi

    echo ""
    echo "Starting optimization of $total_to_optimize files..."
    echo ""

    for jpg_file in "${files_to_optimize[@]}"; do
        ((processed++))
        percent=$((processed * 100 / total_to_optimize))
        echo "[${processed}/${total_to_optimize}] (${percent}%)"
        if optimize_jpg_file "$jpg_file"; then
            :
        else
            ((failed++))
        fi
    done

    echo ""
    echo "Processing complete!"
    echo "- Optimized: $processed files"
    echo "- Failed: $failed files"
    
    local total_in_log=$(get_temp_log_count)
    echo "- Total in log: $total_in_log files"
}

# --- Main Program ---
echo "In-Place JPG Optimizer (with Originals Backup, Progress, mtime Copy, and Temp Log)"
echo "=================================================================================="
echo "Processing directory: $PROCESS_DIR"
echo "JPEG Quality: $JPEG_QUALITY"
echo "Optimization flags: $JPEG_OPT_FLAGS"
echo "Size threshold: ${SIZE_THRESHOLD_KB}KB ($SIZE_THRESHOLD bytes)"
echo "Originals backup directory: $ORIGINALS_DIR"
echo "Temp log file: $TEMP_LOG_FILE"
echo ""

if [[ ! -d "$PROCESS_DIR" ]]; then
    echo "Error: Directory $PROCESS_DIR does not exist!"
    exit 1
fi

init_logs

# Show existing log info
existing_log_count=$(get_temp_log_count)
if [[ $existing_log_count -gt 0 ]]; then
    echo "Loaded temp log with $existing_log_count previously processed files"
    echo ""
fi

echo "Scanning for JPG files..."
count_jpg_files
echo ""
suffix_display="${SUFFIX:-(timestamp-based)}"
echo "Suffix for originals: $suffix_display"
echo "Only files larger than ${SIZE_THRESHOLD_KB}KB will be optimized."
echo "Optimized files will have their mtimes set to their original modified date."
echo "Originals will be moved to: $ORIGINALS_DIR"
echo ""
echo "WARNING: This will modify your original JPG files in-place!"
echo "Make sure you have backups if needed."
echo ""
process_all_jpgs

echo ""
echo "All done! JPG files larger than ${SIZE_THRESHOLD_KB}KB have been optimized in-place."
echo "Optimized files have had their mtimes set to their original modified date."
echo "Originals have been moved to: $ORIGINALS_DIR"
echo "Temp log maintained at: $TEMP_LOG_FILE"
