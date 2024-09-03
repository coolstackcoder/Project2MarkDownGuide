#!/bin/bash

# Check if a directory is provided as an argument
if [ $# -eq 0 ]; then
    echo "Please provide a directory path as an argument."
    exit 1
fi

# Check if the provided path is a directory
if [ ! -d "$1" ]; then
    echo "The provided path is not a directory."
    exit 1
fi

# Get the base directory name
base_dir=$(basename "$1")

# Generate the tree structure with -a and --dirsfirst flags
tree_output=$(tree -L 3 -a --dirsfirst "$1" --noreport --charset=ascii)

# Generate the markdown content
markdown_content="# Project Setup

1. Create the project directory structure:

\`\`\`
$tree_output
\`\`\`

"

# Function to add file content to markdown
add_file_content() {
    local file_path="$1"
    local relative_path="${file_path#$1/}"
    local simplified_path="./${relative_path#*/}"
    local file_extension="${relative_path##*.}"
    local filename=$(basename "$simplified_path")
    
    # Check if file is empty
    if [ -s "$file_path" ]; then
        markdown_content="${markdown_content}
$(($step)). Create $simplified_path with content for **\`$filename\`**:

\`\`\`${file_extension}
$(cat "$file_path")
\`\`\`

"
        step=$((step + 1))
    fi
}

# Initialize step counter
step=2

# Recursively add content of all files
while IFS= read -r -d '' file
do
    # Skip hidden files and directories
    if [[ "$(basename "$file")" != .* ]]; then
        add_file_content "$file"
    fi
done < <(find "$1" -type f -print0 | sort -z)

# Output the markdown content
echo "$markdown_content" > "project_setup.md"

echo "Markdown file 'project_setup.md' has been generated."