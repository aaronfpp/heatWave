# -*- mode: python ; coding: utf-8 -*-
"""
PyInstaller spec file for heatWave .exe packaging
Build with: pyinstaller --clean heatWave.spec

This configuration:
- Bundles heatWave as a standalone Windows .exe
- Includes all Python dependencies
- Embeds src/ and data/ directories
- No external dependencies needed (except Windows)
- Produces a 150-250 MB executable

Run after building:
  dist/heatWave.exe (double-click to launch)
"""

import os
from PyInstaller.building.api import PYZ, EXE, COLLECT
from PyInstaller.building.build_main import Analysis

block_cipher = None

# Analysis phase: Find all modules and dependencies
a = Analysis(
    ['run_streamlit.py'],                    # Entry point
    pathex=[],                               # Add paths if needed
    binaries=[],                             # Add binary dependencies here
    datas=[
        ('src', 'src'),                      # Include source code
        ('data', 'data'),                    # Include sample data/output dirs
    ],
    
    # All hidden imports needed by heatWave and dependencies
    hiddenimports=[
        # Streamlit and web server
        'streamlit',
        'streamlit.components.v1',
        'streamlit.elements.arrow',
        'altair',
        'validators',
        'gitpython',
        'pydeck',
        'watchdog',
        'pymdown_extensions',
        
        # PDF and text processing
        'pdfplumber',
        'pdfplumber.utils',
        'PyPDF2',
        'fitz',  # PyMuPDF
        'pdf2image',
        'pytesseract',
        'PIL',
        
        # PDF generation
        'reportlab',
        'reportlab.lib',
        'reportlab.lib.colors',
        'reportlab.lib.pagesizes',
        'reportlab.lib.styles',
        'reportlab.lib.units',
        'reportlab.platypus',
        'reportlab.graphics',
        
        # Data validation
        'pydantic',
        'pydantic.json',
        
        # System and utilities
        'threading',
        'tempfile',
        'pathlib',
        'logging',
        'subprocess',
        'webbrowser',
        'time',
        
        # FastAPI and uvicorn (optional, but included)
        'fastapi',
        'uvicorn',
        'uvicorn.config',
        'uvicorn.server',
        'uvicorn.protocols.http.httptools_impl',
        'uvicorn.protocols.websocket.auto',
        'starlette',
        'starlette.routing',
        'starlette.responses',
        
        # Testing (not needed in .exe but safe to include)
        'pytest',
    ],
    
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        'matplotlib',           # Not used, saves space
        'scipy',                # Not used
        'sklearn',              # Not used
        'tcl',                  # Not needed for CLI
        'tk',                   # Not needed for web app
        'tkinter',
        'IPython',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

# PYZ: Create the archive of pure Python modules
pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

# EXE: Build the executable
exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    name='heatWave',                          # Output filename (heatWave.exe)
    debug=False,                              # No debug info in .exe
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,                                 # Use UPX to compress (smaller file)
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,                            # Hide console window for clean UX
    disable_windowed_traceback=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    
    # Optional: Add icon if it exists
    icon='icon.ico' if os.path.exists('icon.ico') else None,
)

# COLLECT: Create distribution folder
coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='heatWave'                           # Output folder: dist/heatWave/
)
