#!/usr/bin/env bash

remove_parent_directories() {
    local file_path=$1
    local dry_run=$2

    # Extract the parent directory
    local parent_dir=$(dirname "$file_path")

    # Check if the parent directory exists
    if [ -d "$parent_dir" ]; then
        # Dry run: Print what would be removed
        if [ "$dry_run" = true ]; then
            echo "Would remove: $parent_dir"
        else
            # Remove the parent directory and its contents
            rm -r "$parent_dir"
            echo "Removed: $parent_dir"
        fi
    fi
}

# Check if the file_paths.txt file exists
if [ ! -f file_paths.txt ]; then
    echo "Error: file_paths.txt not found."
    exit 1
fi

# Dry run flag
dry_run=true

# Parse command line options
while getopts ":d" opt; do
    case $opt in
        d)
            dry_run=false
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Read each line from file_paths.txt
while IFS= read -r file_path; do
    remove_parent_directories "$file_path" "$dry_run"
done < file_paths.txt
