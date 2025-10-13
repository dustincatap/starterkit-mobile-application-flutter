#!/bin/bash
set -e

# List of file patterns to ignore
file_patterns=("*.gen.dart" "*.config.dart" "*.g.dart" "*.gr.dart" "*.reflectable.dart" "*.auto_mappr.dart" "messages_*.dart" "l10n.dart" "*.steps.dart" "*_api.dart")

# Determine the correct sed command based on the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed_command="sed -i ''"
else
    sed_command="sed -i"
fi

# Loop over the file patterns and add the ignore line to each matching file
for pattern in "${file_patterns[@]}"; do
    # Find files matching the pattern
    find . -type f -name "$pattern" | while read -r file; do
        # Check if the file already contains the ignore line
        if grep -q '// coverage:ignore-file' "$file"; then
            echo "Skipping $file as it already contains // coverage:ignore-file"
        else
            # Add the ignore line to the file
            eval "$sed_command '1s/^/\/\/ coverage:ignore-file\\n/' \"$file\""
            echo "Added // coverage:ignore-file to $file"
        fi
    done
done
