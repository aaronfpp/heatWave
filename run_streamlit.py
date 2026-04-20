#!/usr/bin/env python
"""
Launch script for heatWave Streamlit UI
Run from project root: python run_streamlit.py
"""
import subprocess
import sys

if __name__ == "__main__":
    # Run streamlit app
    subprocess.run([
        sys.executable, "-m", "streamlit", "run",
        "src/ui/streamlit_app.py",
        "--logger.level=info"
    ])
