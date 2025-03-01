# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1] - 2025-02-27

### Added
- MLflow version upgrade to 2.8.1 with improved database handling and artifact management
- Enhanced GPU support with NVIDIA Container Toolkit integration
- Advanced resource monitoring and health checks for containers
- Detailed logging system with structured output and error handling
- Comprehensive documentation for both CPU and GPU environments
- Pre-commit hooks for code quality and formatting

### Changed
- Upgraded base CUDA version to 11.8 with cuDNN 8.9.2
- Improved Docker build process with BuildKit and caching optimizations
- Enhanced resource management with flexible memory and CPU allocation
- Restructured workspace organization for better data management
- Updated Python package versions for better compatibility
- Optimized MLflow server configuration with better process management

### Fixed
- Container startup issues with proper environment validation
- MLflow database initialization and permissions
- GPU environment detection and CUDA availability checks
- JupyterLab extension compatibility issues
- Resource allocation and memory management
- Log rotation and cleanup processes

### Security
- Implemented stricter password requirements for JupyterLab
- Enhanced container isolation with user namespace mapping
- Improved file permissions and access controls
- Added health monitoring with detailed status checks
- Updated security patches for base images and dependencies

## [1.0.0] - 2024-03-19

### Added
- Initial release of the Data Science Development Environment
- Multi-stage Docker build with optimized image size
- Separate CPU and GPU environments with:
  - Python 3.9 base
  - Conda/Mamba package management
  - OpenBLAS optimization

### Development Environment
- JupyterLab 3.6.5 with extensions:
  - Git integration
  - System monitor
  - Resource usage tracking
  - Server proxy
- MLflow 2.6.0 integration:
  - SQLite backend
  - Local artifact store
  - Multi-worker setup

### Core Packages
- Data Analysis:
  - NumPy 1.24.3
  - Pandas 1.5.3
  - Scipy 1.11.2
  - Scikit-learn 1.3.0
- Machine Learning:
  - XGBoost 1.7.6
  - LightGBM 4.0.0
  - MLflow 2.6.0
- Deep Learning (GPU):
  - PyTorch 2.0.1
  - TensorFlow 2.13.0
  - CUDA 11.8
  - cuDNN 8.9.2
- Visualization:
  - Matplotlib 3.7.2
  - Seaborn 0.12.2
  - Plotly 5.16.1

### Development Tools
- Version Control:
  - Git with LFS support
  - Pre-commit hooks
- Code Quality:
  - Black 23.7.0 for formatting
  - Flake8 6.1.0 for linting
  - MyPy 1.5.1 for type checking
  - isort 5.12.0 for import sorting

### Infrastructure
- Docker Compose configuration
- Resource management:
  - CPU/Memory limits
  - GPU memory management
  - Swap space configuration
- Health monitoring:
  - Container health checks
  - Resource usage tracking
  - Log rotation

### Security
- Non-root user execution
- Password-protected JupyterLab
- Read-only mounting of sensitive files
- Limited port exposure
- Regular security updates

### Documentation
- Comprehensive README files
- Docker commands reference
- Troubleshooting guide
- Performance optimization tips

### Fixed
- Initial setup of workspace permissions
- GPU environment configuration
- MLflow database initialization
- JupyterLab extension compatibility

### Changed
- Optimized Docker build process
- Improved resource allocation
- Enhanced logging system
- Streamlined environment setup

### Security
- Implemented non-root user execution
- Added password protection for JupyterLab
- Configured read-only mounts for sensitive files
- Limited exposed ports
- Set up regular security updates

Maintainer: bhumukulraj.ds@gmail.com 