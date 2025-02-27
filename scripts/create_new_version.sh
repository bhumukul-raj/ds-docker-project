#!/bin/bash

# Set strict error handling
set -euo pipefail

# Function to display script usage
show_usage() {
    echo "Usage: $0 <new_version> [current_version]"
    echo "Example: $0 1.1.0 1.0.0"
    echo "If current_version is not provided, it will try to detect from existing directories"
}

# Function to validate semantic version
validate_version() {
    if ! [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Version must be in semantic versioning format (e.g., 1.0.0)"
        exit 1
    fi
}

# Function to update version in file
update_version() {
    local file=$1
    local old_version=$2
    local new_version=$3
    
    if [[ -f "$file" ]]; then
        sed -i "s/$old_version/$new_version/g" "$file"
        echo "Updated version in $file"
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

# Create directory structure
mkdir -p "$NEW_DIR"/{docker,docs,environments,scripts}

# Copy files with version updates
echo "Copying and updating files..."

# Copy and update docker files
cp "$CURRENT_DIR/docker/docker-compose.yml" "$NEW_DIR/docker/"
cp "$CURRENT_DIR/docker/Dockerfile.cpu" "$NEW_DIR/docker/"
cp "$CURRENT_DIR/docker/Dockerfile.gpu" "$NEW_DIR/docker/"

# Copy and update environment files
cp "$CURRENT_DIR/environments/environment-cpu.yml" "$NEW_DIR/environments/"
cp "$CURRENT_DIR/environments/environment-gpu.yml" "$NEW_DIR/environments/"

# Copy and update documentation
cp "$CURRENT_DIR/docs/"* "$NEW_DIR/docs/"
cp "$CURRENT_DIR/README.md" "$NEW_DIR/"

# Copy scripts
cp "$CURRENT_DIR/scripts/docker-entrypoint.sh" "$NEW_DIR/scripts/"

# Copy configuration files
cp "$CURRENT_DIR/.env" "$NEW_DIR/"
cp "$CURRENT_DIR/.dockerignore" "$NEW_DIR/"
cp "$CURRENT_DIR/.pre-commit-config.yaml" "$NEW_DIR/"

# Update version numbers in files
find "$NEW_DIR" -type f -exec sed -i "s/Version: $CURRENT_VERSION/Version: $NEW_VERSION/g" {} +
find "$NEW_DIR" -type f -exec sed -i "s/version: '$CURRENT_VERSION'/version: '$NEW_VERSION'/g" {} +
find "$NEW_DIR" -type f -exec sed -i "s/:$CURRENT_VERSION/:$NEW_VERSION/g" {} +

# Update CHANGELOG.md
CURRENT_DATE=$(date +%Y-%m-%d)
NEW_CHANGELOG_ENTRY="## [$NEW_VERSION] - $CURRENT_DATE\n\n### Added\n- \n\n### Changed\n- \n\n### Fixed\n- \n\n### Security\n- \n"
sed -i "0,/## \[$CURRENT_VERSION\]/s//## [$NEW_VERSION] - $CURRENT_DATE\n\n### Added\n- \n\n### Changed\n- \n\n### Fixed\n- \n\n### Security\n- \n\n## [$CURRENT_VERSION]/" "$NEW_DIR/docs/CHANGELOG.md"

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
echo "2. Update version numbers in any additional files if needed"
echo "3. Review and update dependencies in environment-*.yml files"
echo "4. Test the new version"
echo "5. Use version_update_commit_msg.txt as a template for your commit message"
echo ""
echo "Don't forget to:"
echo "- Update documentation with any new features or changes"
echo "- Test both CPU and GPU environments"
echo "- Update any version-specific instructions"
echo "- Review resource limits and requirements" 