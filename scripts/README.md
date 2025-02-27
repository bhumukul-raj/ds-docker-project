# Scripts Documentation

This directory contains utility scripts for managing the Data Science Docker project.

## create_new_version.sh

A utility script to help generate files for new versions of the project. This script automates the process of creating a new version directory with all necessary files and updating version numbers.

### Usage

```bash
./create_new_version.sh <new_version> [current_version]
```

**Arguments:**
- `new_version`: Required. The new version number (must follow semantic versioning, e.g., 1.1.0)
- `current_version`: Optional. The current version to base the new version on. If not provided, the script will try to detect it from existing directories.

**Example:**
```bash
# Create version 1.1.0 based on the latest existing version
./create_new_version.sh 1.1.0

# Create version 1.1.0 based on version 1.0.0
./create_new_version.sh 1.1.0 1.0.0
```

### Features

1. **Automated Directory Creation**
```
v<new_version>/
├── docker/
│   ├── docker-compose.yml
│   ├── Dockerfile.cpu
│   └── Dockerfile.gpu
├── docs/
│   ├── CHANGELOG.md
│   ├── CPU_OVERVIEW.md
│   ├── DOCKER_COMMANDS.md
│   └── GPU_OVERVIEW.md
├── environments/
│   ├── environment-cpu.yml
│   └── environment-gpu.yml
├── scripts/
│   └── docker-entrypoint.sh
├── .dockerignore
├── .env
├── .pre-commit-config.yaml
└── README.md
```

2. **Version Management**
- Validates semantic versioning
- Automatically detects existing versions
- Updates version numbers across all files
- Creates new CHANGELOG entry

3. **File Operations**
- Copies all necessary files from the current version
- Updates version references in all files
- Maintains file permissions
- Creates configuration files

4. **Documentation**
- Generates new CHANGELOG entry with the current date
- Creates a commit message template
- Updates version numbers in documentation
- Preserves existing documentation structure

### Generated Files

1. **New Version Directory**
- Complete directory structure with all necessary subdirectories
- Updated configuration files
- Modified version numbers in all files

2. **CHANGELOG Entry**
```markdown
## [NEW_VERSION] - CURRENT_DATE

### Added
- 

### Changed
- 

### Fixed
- 

### Security
- 
```

3. **Commit Message Template**
```
Version NEW_VERSION

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
```

### Post-Creation Steps

After running the script, you should:

1. Review and update the CHANGELOG.md in the new version directory
2. Update version numbers in any additional files if needed
3. Review and update dependencies in environment-*.yml files
4. Test the new version
5. Use the generated version_update_commit_msg.txt as a template for your commit message

### Important Reminders

- Update documentation with any new features or changes
- Test both CPU and GPU environments
- Update any version-specific instructions
- Review resource limits and requirements

### Safety Features

- Validates version numbers before proceeding
- Doesn't overwrite existing directories
- Maintains all configurations and permissions
- Creates backups of important files
- Provides clear error messages

### Error Handling

The script includes robust error handling:
- Validates semantic versioning format
- Checks for required arguments
- Verifies file existence before operations
- Provides clear error messages
- Uses strict bash error handling (set -euo pipefail)

### Dependencies

- Bash shell
- Standard Unix utilities (cp, mkdir, sed, etc.)
- Git (for version control operations)

### Notes

- The script assumes it's run from the project root directory
- All paths are relative to the project root
- Version numbers must follow semantic versioning (X.Y.Z)
- The script preserves file permissions during copying 