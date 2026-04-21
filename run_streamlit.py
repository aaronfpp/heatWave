#!/usr/bin/env python
"""
Launch script for heatWave Streamlit UI

This script:
1. Starts a Streamlit server on localhost:8501
2. Opens the user's default browser automatically
3. Works as both a Python script and PyInstaller .exe

Run from project root: python run_streamlit.py
Or double-click heatWave.exe (when packaged)
"""
import subprocess
import sys
import webbrowser
import time
import os
from pathlib import Path


def main():
    """Start heatWave Streamlit app and open browser."""
    
    # Determine if we're running as a PyInstaller .exe or regular Python
    if getattr(sys, 'frozen', False):
        # Running as .exe
        app_path = os.path.dirname(sys.executable)
        os.chdir(app_path)
        is_exe = True
    else:
        # Running as Python script
        is_exe = False
    
    # Build the Streamlit command
    cmd = [
        sys.executable, "-m", "streamlit", "run",
        "src/ui/streamlit_app.py",
        "--logger.level=info",
        "--client.showErrorDetails=true",
    ]
    
    # Add .exe-specific settings for better UX
    if is_exe:
        cmd.extend([
            "--server.headless=true",
            "--server.port=8501",
        ])
    
    print("🏊 Starting heatWave...")
    print("   - Streamlit server starting on http://localhost:8501")
    
    try:
        # Start Streamlit in subprocess
        proc = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        # Wait for server to start (increased to 5 seconds for .exe)
        print("   - Waiting for server to initialize...")
        time.sleep(5)
        
        # Open browser
        print("   - Opening your browser...")
        try:
            webbrowser.open("http://localhost:8501")
        except Exception as e:
            print(f"   ⚠️  Could not auto-open browser: {e}")
            print("   ➜ Manually visit: http://localhost:8501")
        
        print("\n✅ heatWave is ready!")
        print("   The Streamlit interface should open in your browser.")
        print("   Close this window to stop the server.\n")
        
        # Keep the process running
        proc.wait()
    
    except KeyboardInterrupt:
        print("\n\n👋 heatWave stopped.")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Error starting heatWave: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
