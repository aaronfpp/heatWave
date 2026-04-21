# Simple test spec for debugging
from PyInstaller.building.api import PYZ, EXE, COLLECT
from PyInstaller.building.build_main import Analysis

a = Analysis(
    ['run_streamlit.py'],
    pathex=[],
    binaries=[],
    datas=[('src', 'src'), ('data', 'data')],
    hiddenimports=['streamlit'],
    hookspath=[],
    runtime_hooks=[],
    excludes=['matplotlib', 'scipy', 'sklearn'],
)

pyz = PYZ(a.pure, a.zipped_data)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    name='heatWave',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    console=False,
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=False,
    name='heatWave'
)
