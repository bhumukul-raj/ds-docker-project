#!/bin/bash

# Set strict error handling
set -euo pipefail

# Function to display script usage
show_usage() {
    echo "Usage: $0 <new_version> [current_version]"
    echo "Example: $0 1.1 1.0"
    echo "If current_version is not provided, it will try to detect from existing directories"
}

# Function to validate version format
validate_version() {
    if ! [[ $1 =~ ^[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Version must be in format X.Y (e.g., 1.0)"
        exit 1
    fi
}

# Check if new version is provided
if [ $# -lt 1 ]; then
    show_usage
    exit 1
fi

NEW_VERSION=$1
validate_version "$NEW_VERSION"

# Determine current version
if [ $# -eq 2 ]; then
    CURRENT_VERSION=$2
    validate_version "$CURRENT_VERSION"
else
    # Try to detect current version from existing directories
    CURRENT_VERSION=$(ls -d v*/ 2>/dev/null | sort -V | tail -n 1 | sed 's/v\([0-9.]*\)\//\1/')
    if [ -z "$CURRENT_VERSION" ]; then
        echo "Error: Could not detect current version. Please provide it as second argument."
        show_usage
        exit 1
    fi
fi

echo "Creating new version v$NEW_VERSION from v$CURRENT_VERSION..."

# Create new version directory structure
NEW_DIR="v$NEW_VERSION"
CURRENT_DIR="v$CURRENT_VERSION"

# Check if current version directory exists
if [ ! -d "$CURRENT_DIR" ]; then
    echo "Error: Directory $CURRENT_DIR does not exist"
    exit 1
fi

# Check if new version directory already exists
if [ -d "$NEW_DIR" ]; then
    echo "Error: Directory $NEW_DIR already exists"
    exit 1
fi

# Copy all files from current version to new version
echo "Copying files from $CURRENT_DIR to $NEW_DIR..."
cp -r "$CURRENT_DIR" "$NEW_DIR"

# Update version numbers in all files
echo "Updating version numbers in files..."

# Update version in Docker files first
echo "Updating Docker files..."
find "$NEW_DIR/docker" -type f -name "Dockerfile.*" -exec sed -i "s/Version: $CURRENT_VERSION/Version: $NEW_VERSION/g" {} +
find "$NEW_DIR/docker" -type f -name "Dockerfile.*" -exec sed -i "s/DS_VERSION=$CURRENT_VERSION/DS_VERSION=$NEW_VERSION/g" {} +
find "$NEW_DIR/docker" -type f -exec sed -i "s/:$CURRENT_VERSION/:$NEW_VERSION/g" {} +

# Update version in other files
find "$NEW_DIR" -type f -exec sed -i "s/Version: $CURRENT_VERSION/Version: $NEW_VERSION/g" {} +
find "$NEW_DIR" -type f -exec sed -i "s/version: '$CURRENT_VERSION'/version: '$NEW_VERSION'/g" {} +
find "$NEW_DIR" -type f -exec sed -i "s/v$CURRENT_VERSION/v$NEW_VERSION/g" {} +

# Update CHANGELOG.md if it exists
if [ -f "$NEW_DIR/docs/CHANGELOG.md" ]; then
    echo "Updating CHANGELOG.md..."
    CURRENT_DATE=$(date +%Y-%m-%d)
    NEW_CHANGELOG_ENTRY="## [$NEW_VERSION] - $CURRENT_DATE\n\n### Added\n- \n\n### Changed\n- \n\n### Fixed\n- \n\n### Security\n- \n"
    sed -i "0,/## \[$CURRENT_VERSION\]/s//## [$NEW_VERSION] - $CURRENT_DATE\n\n### Added\n- \n\n### Changed\n- \n\n### Fixed\n- \n\n### Security\n- \n\n## [$CURRENT_VERSION]/" "$NEW_DIR/docs/CHANGELOG.md"
fi

# Create version update commit message template
echo "Creating version update commit message template..."
cat > version_update_commit_msg.txt << EOF
Version $NEW_VERSION

Changes in this version:
- 
- 
- 

Migration notes:
- 

Breaking changes:
- 

Dependencies updated:
- 
EOF

echo "New version v$NEW_VERSION has been created!"
echo "Next steps:"
echo "1. Review and update the CHANGELOG.md in $NEW_DIR/docs/"
echo "2. Review and update version numbers in all files"
echo "3. Test the new version"
echo "4. Use version_update_commit_msg.txt as a template for your commit message"
echo ""
echo "Don't forget to:"
echo "- Update documentation with any new features and changes"
echo "- Test both CPU and GPU environments"
echo "- Update any version-specific instructions" 