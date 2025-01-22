@echo off
set UV_CACHE_DIR=%~dp0cache
set UV_PYTHON_INSTALL_DIR=%~dp0python
set UV_TOOL_BIN_DIR=%~dp0
set UV_TOOL_DIR=%~dp0tool
"%~dp0python\uv.exe" %*