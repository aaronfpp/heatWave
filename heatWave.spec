# -*- mode: python ; coding: utf-8 -*-
"""
PyInstaller spec file for heatWave desktop app.

Build:  pyinstaller --clean heatWave.spec
Output: dist/heatWave/heatWave.exe  (folder mode — fastest startup)

Architecture:
  Entry point: run_desktop.py
    → starts Flask server (background thread)
    → opens native window via pywebview
  UI served from: src/ui/templates/index.html
  Core logic: src/parser, src/seeding, src/core, src/models
"""

import os
from PyInstaller.building.api import PYZ, EXE, COLLECT
from PyInstaller.building.build_main import Analysis

block_cipher = None

a = Analysis(
    ['run_desktop.py'],
    pathex=[],
    binaries=[],
    datas=[
        # Application source + templates  (needed at runtime for imports & Flask templates)
        ('src', 'src'),
        # Data directories (samples / output stubs)
        ('data', 'data'),
    ],

    hiddenimports=[
        # Flask & web server
        'flask',
        'flask.json',
        'werkzeug',
        'werkzeug.serving',
        'jinja2',

        # Desktop window
        'webview',

        # PDF extraction
        'pdfplumber',
        'pdfplumber.utils',
        'pdfminer',
        'pdfminer.high_level',
        'pymupdf',

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
        'pydantic_core',

        # Stdlib modules that Analysis sometimes misses
        'threading',
        'tempfile',
        'pathlib',
        'logging',
    ],

    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        # ---- Not used — saves ~100 MB off the bundle ----
        'streamlit',
        'altair',
        'matplotlib',
        'scipy',
        'sklearn',
        'tcl', 'tk', 'tkinter',
        'IPython',
        'notebook',
        'pytest',
        'fastapi',
        'uvicorn',
        'starlette',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],                        # binaries go in COLLECT, not in EXE (folder mode)
    exclude_binaries=True,     # ← key flag for folder mode
    name='heatWave',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    console=True,              # Keep console visible for now (set False after verified)
    disable_windowed_traceback=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='icon.ico' if os.path.exists('icon.ico') else None,
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=False,
    name='heatWave',
)
