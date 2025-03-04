# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2024-03-19

### Added
- BuildKit caching support for faster image builds
- Structured JSON logging with rotation and compression
- Health check commands for both CPU and GPU containers
- Security features:
  - Read-only root filesystem
  - No new privileges restriction
  - Capability drops and minimal grants
  - AppArmor profile
  - User namespace remapping
- Resource monitoring and metrics collection
- Separate error logging
- Network isolation with bridge mode
- DNS configuration for better reliability
- Multi-stage builds for GPU image
- Resource-aware building process
- Log rotation and compression
- GPU metrics collection
- Container health monitoring

### Changed
- Reduced GPU memory fraction from 0.75 to 0.6 for better compatibility
- Updated resource limits:
  - CPU container: 10GB memory limit
  - GPU container: 12GB memory limit
- Network mode changed from host to bridge
- Datasets mounted as read-only
- Improved error handling in entrypoint script
- Enhanced logging format to JSON
- Updated health check commands
- Optimized build process with BuildKit
- Enhanced security configurations
- Improved resource management

### Fixed
- GPU memory management for 4GB GPUs
- Container startup reliability
- Log file permissions
- Resource limit enforcement
- Network isolation issues
- Build performance bottlenecks

### Security
- Implemented read-only root filesystem
- Added capability restrictions
- Enabled user namespace remapping
- Configured AppArmor profile
- Restricted network access
- Prevented privilege escalation
- Enhanced volume mount security

## [1.2.0] - 2024-02-15
- Initial release with basic Docker support
- Basic CPU and GPU environments
- Simple logging
- Basic security features

## [1.1.0] - 2024-01-20
- Prototype release
- Basic Jupyter environment
- Simple Docker configuration
- Limited GPU support

## [1.0.0] - 2024-01-01
- Initial project setup
- Basic documentation
- Development environment setup

Maintainer: bhumukulraj.ds@gmail.com 