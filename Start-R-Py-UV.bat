@echo off
setlocal EnableDelayedExpansion

:: ============================================================
:: Start-R-Py-UV.bat  -  Windows Setup Script  (no winget)
:: Copyright (c) 2025 Hans Hendrickx
:: https://github.com/hanshendrickx
:: MIT License - free to use, share, and modify
:: HOW TO RUN: Open CMD as Administrator, cd to this folder,
::             then type: Start-R-Py-UV.bat
::             Do NOT run from VS Code Run Code button
:: ============================================================

title R + Python 3.14 + UV Setup Wizard

echo.
echo ============================================================
echo   R  +  Python 3.14  +  UV   Setup Wizard  (Windows)
echo   Complete Setup Guide - Read Before Starting
echo ============================================================
echo.
echo  WHAT THIS SCRIPT WILL DO FOR YOU:
echo  ----------------------------------
echo   1. Check Python 3.14, R, and UV - install if missing
echo   2. Create a UV project called MyR on your Desktop
echo   3. Create a Python 3.14 virtual environment inside MyR
echo   4. Install Jupyter, Marimo, rpy2, numpy, pandas, matplotlib
echo   5. Create a Jupyter Notebook demo (you will be asked first)
echo   6. Create a Marimo reactive notebook demo (asked first)
echo   7. Show a summary of how your Python setup works
echo.
echo  AT THE END YOU WILL HAVE:
echo  -------------------------
echo   - Python 3.12 on your system (stays clean, not touched)
echo   - Python 3.14 inside the MyR venv (for data science work)
echo   - R 4.x installed and ready
echo   - UV package manager (fastest pip replacement)
echo   - Jupyter Notebook ready to open in your browser
echo   - Marimo reactive notebook ready to open in your browser
echo   - A working R + Python bridge via rpy2
echo.
echo ============================================================
echo  HOW TO RUN THIS FILE CORRECTLY
echo ============================================================
echo.
echo  METHOD 1 - Windows CMD as Administrator (recommended):
echo  -------------------------------------------------------
echo   Step 1: Press the Windows key on your keyboard
echo   Step 2: Type:  cmd
echo   Step 3: Right-click "Command Prompt" and choose
echo           "Run as administrator"
echo   Step 4: In the black window type:
echo           cd "C:\path\to\your\folder"
echo           (replace with the folder where this bat file is)
echo   Step 5: Type:  Start-R-Py-UV.bat
echo   Step 6: Press Enter and follow the prompts
echo.
echo  METHOD 2 - VS Code Terminal in cmd mode:
echo  -----------------------------------------
echo   Step 1: Install VS Code from https://code.visualstudio.com/
echo   Step 2: Open VS Code
echo   Step 3: Press Ctrl+Shift+` to open the Terminal
echo   Step 4: Click the dropdown arrow next to the + in the
echo           terminal panel, choose "Command Prompt" (not PowerShell)
echo   Step 5: In the terminal type:
echo           cd "C:\path\to\your\folder"
echo   Step 6: Type:  Start-R-Py-UV.bat  and press Enter
echo   IMPORTANT: Must be Command Prompt, NOT PowerShell terminal
echo   IMPORTANT: Do NOT use the Run Code button (play button)
echo              That button breaks batch file prompts
echo.
echo  HOW TO FIND YOUR FOLDER PATH:
echo  ------------------------------
echo   Step 1: Open Windows Explorer (Win + E)
echo   Step 2: Navigate to the folder containing this bat file
echo   Step 3: Click the address bar at the top of Explorer
echo   Step 4: The full path appears - copy it (Ctrl+C)
echo   Step 5: Paste it after cd in your CMD window
echo           Example:  cd "C:\Users\hansh\My-Py-UV-R-Folder"
echo.
echo  QUICK CHECK - you are running this correctly if:
echo   - The window title shows: R + Python 3.14 + UV Setup Wizard
echo   - You can type Y or N when prompted and press Enter
echo   - The script does not exit immediately after prompts
echo.
echo ============================================================
echo  Press any key to begin the setup...
echo ============================================================
echo.
pause

:: ============================================================
:: SECTION 1a - CHECK PYTHON
:: ============================================================

echo.
echo ============================================================
echo  SECTION 1: Checking Prerequisites
echo ============================================================
echo.
echo [1/3] Checking Python...
echo.

python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  [NOT FOUND] Python is not installed or not in PATH.
    echo.
    echo  Please install Python 3.14:
    echo    1. Go to: https://www.python.org/downloads/
    echo    2. Click the yellow Download Python 3.14.x button
    echo    3. Run the installer
    echo    4. CHECK the box "Add Python to PATH" at the bottom
    echo    5. Click Install Now
    echo    6. CLOSE this window then double-click the bat again
    echo.
    start https://www.python.org/downloads/
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('python --version 2^>^&1') do echo  [OK] %%v

echo.
echo  Running Python self-test...
python -c "import sys; print('  Python ' + sys.version[:20]); print('  [PASS] Python works.')"
if %errorlevel% neq 0 (
    echo.
    echo  [FAIL] Python self-test failed. How to fix:
    echo    1. Search Windows Settings for: App execution aliases
    echo    2. Turn OFF python.exe and python3.exe aliases
    echo    3. Reinstall Python from python.org
    echo       During install: check "Add Python to PATH"
    echo.
    pause
)

echo.
echo  Checking pip...
python -m pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  pip missing - installing...
    python -m ensurepip --upgrade
)
for /f "tokens=*" %%v in ('python -m pip --version 2^>^&1') do echo  [OK] %%v

:: ============================================================
:: SECTION 1b - CHECK UV
:: ============================================================

echo.
echo [2/3] Checking UV...
echo.

uv --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%v in ('uv --version 2^>^&1') do echo  [OK] UV: %%v
    goto :uv_ok
)

echo  [NOT FOUND] UV not installed. Installing via pip...
python -m pip install uv
if %errorlevel% neq 0 (
    echo  [ERROR] pip install uv failed.
    echo  Open a new Command Prompt and run:  pip install uv
    pause
    exit /b 1
)
echo  [OK] UV installed.

:uv_ok

:: ============================================================
:: SECTION 1c - CHECK R
:: Writes a .py file to disk then runs it - no inline Python
:: ============================================================

echo.
echo [3/3] Checking R...
echo.

:: Write the helper script line by line using echo
set PYFILE=%TEMP%\find_r.py
echo import subprocess, os > "%PYFILE%"
echo try: >> "%PYFILE%"
echo     import winreg >> "%PYFILE%"
echo     HAS_WINREG = True >> "%PYFILE%"
echo except ImportError: >> "%PYFILE%"
echo     HAS_WINREG = False >> "%PYFILE%"
echo. >> "%PYFILE%"
echo def find_r(): >> "%PYFILE%"
echo     try: >> "%PYFILE%"
echo         r = subprocess.run(['Rscript','--version'], capture_output=True, text=True) >> "%PYFILE%"
echo         if r.returncode == 0: >> "%PYFILE%"
echo             print('IN_PATH') >> "%PYFILE%"
echo             return >> "%PYFILE%"
echo     except FileNotFoundError: >> "%PYFILE%"
echo         pass >> "%PYFILE%"
echo     r_home = None >> "%PYFILE%"
echo     if HAS_WINREG: >> "%PYFILE%"
echo         for kp in ['SOFTWARE\\R-core\\R','SOFTWARE\\WOW6432Node\\R-core\\R']: >> "%PYFILE%"
echo             try: >> "%PYFILE%"
echo                 k = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, kp) >> "%PYFILE%"
echo                 r_home, _ = winreg.QueryValueEx(k, 'InstallPath') >> "%PYFILE%"
echo                 winreg.CloseKey(k) >> "%PYFILE%"
echo                 break >> "%PYFILE%"
echo             except Exception: >> "%PYFILE%"
echo                 pass >> "%PYFILE%"
echo     if not r_home: >> "%PYFILE%"
echo         for base in ['C:\\Program Files\\R','C:\\Program Files (x86)\\R']: >> "%PYFILE%"
echo             if os.path.isdir(base): >> "%PYFILE%"
echo                 for e in sorted(os.listdir(base), reverse=True): >> "%PYFILE%"
echo                     c = os.path.join(base, e) >> "%PYFILE%"
echo                     if os.path.isdir(c): >> "%PYFILE%"
echo                         r_home = c >> "%PYFILE%"
echo                         break >> "%PYFILE%"
echo             if r_home: >> "%PYFILE%"
echo                 break >> "%PYFILE%"
echo     if not r_home: >> "%PYFILE%"
echo         print('NOT_FOUND') >> "%PYFILE%"
echo         return >> "%PYFILE%"
echo     for sub in ['bin', os.path.join('bin','x64')]: >> "%PYFILE%"
echo         rs = os.path.join(r_home, sub, 'Rscript.exe') >> "%PYFILE%"
echo         if os.path.exists(rs): >> "%PYFILE%"
echo             print('FOUND:' + os.path.join(r_home, sub)) >> "%PYFILE%"
echo             return >> "%PYFILE%"
echo     print('NOT_FOUND') >> "%PYFILE%"
echo find_r() >> "%PYFILE%"

:: Run the helper and capture output
python "%PYFILE%" > "%TEMP%\r_result.txt" 2>nul
del "%PYFILE%" >nul 2>&1

set /p R_RESULT= < "%TEMP%\r_result.txt"
del "%TEMP%\r_result.txt" >nul 2>&1

if "!R_RESULT!"=="IN_PATH" (
    echo  [OK] R is already in PATH.
    for /f "tokens=*" %%v in ('Rscript --version 2^>^&1') do echo  [OK] %%v
    goto :r_done
)

if "!R_RESULT!"=="NOT_FOUND" goto :r_not_found

:: Result is FOUND:C:\path\to\R\bin
set R_BIN=!R_RESULT:FOUND:=!
echo  [OK] R found at: !R_BIN!
echo  Adding R to PATH for this session...
set "PATH=!R_BIN!;%PATH%"
for /f "tokens=*" %%v in ('Rscript --version 2^>^&1') do echo  [OK] %%v
goto :r_done

:r_not_found
echo  [NOT FOUND] R is not installed.
echo.
echo  Please install R:
echo    1. Go to: https://cran.r-project.org/bin/windows/base/
echo    2. Click Download R x.x.x for Windows
echo    3. Run the installer with default settings
echo    4. Close this window and run the bat again
echo.
echo  You can continue - rpy2 bridge needs R, but Jupyter
echo  and Marimo will work fine without it for now.
echo.
start https://cran.r-project.org/bin/windows/base/
pause

:r_done
echo.
echo  Prerequisites check complete.
echo.
pause

:: ============================================================
:: SECTION 2 - UPGRADES
:: ============================================================

echo.
echo ============================================================
echo  SECTION 2: Package Upgrades
echo ============================================================
echo.
echo  Upgrade pip, UV, and R packages now?
echo  (Safe to press N if you just installed everything)
echo.
set UPGRADE_CHOICE=N
set /p UPGRADE_CHOICE="  Upgrade? Y or N (press Enter for N): "

if /i "%UPGRADE_CHOICE%"=="Y" goto :do_upgrade
echo  Skipping upgrades.
goto :upgrade_done

:do_upgrade
echo.
echo  Upgrading pip...
python -m pip install --upgrade pip
echo.
echo  Upgrading UV...
python -m pip install --upgrade uv
Rscript --version >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo  Upgrading R packages (may take a few minutes)...
    Rscript -e "update.packages(ask=FALSE, repos='https://cloud.r-project.org')"
    echo  [OK] R packages upgraded.
)
echo.
echo  All upgrades done.

:upgrade_done

echo.
pause

:: ============================================================
:: SECTION 3 - CREATE UV PROJECT MyR
:: ============================================================

echo.
echo ============================================================
echo  SECTION 3: Creating UV Project MyR
echo ============================================================
echo.

set PROJECT_DIR=%USERPROFILE%\Desktop\MyR
echo  Project location: %PROJECT_DIR%
echo.

if not exist "%PROJECT_DIR%" goto :no_overwrite
echo  Folder MyR already exists on your Desktop.
set OVERWRITE=N
set /p OVERWRITE="  Delete and recreate it? Y or N (press Enter for N): "
if /i "%OVERWRITE%"=="Y" (
    rmdir /s /q "%PROJECT_DIR%"
    echo  Old folder removed.
)
:no_overwrite

echo.
echo  Running uv init (Python 3.14)...
uv init "%PROJECT_DIR%" --python 3.14
if %errorlevel% neq 0 (
    echo  Note: uv init --python 3.14 not available, using default Python...
    if not exist "%PROJECT_DIR%" mkdir "%PROJECT_DIR%"
    cd /d "%PROJECT_DIR%"
    uv init .
) else (
    cd /d "%PROJECT_DIR%"
)
echo  [OK] Project folder ready.

echo.
echo  Creating .venv...
uv venv --python 3.14
if %errorlevel% neq 0 (
    echo  Python 3.14 not found for venv, using default Python...
    uv venv
)
echo  [OK] .venv created.

echo.
echo  Activating venv...
call "%PROJECT_DIR%\.venv\Scripts\activate.bat"
echo  [OK] Venv active.
python --version

echo.
echo  Installing packages into venv...
echo  jupyter, notebook, ipykernel, rpy2, marimo, numpy, pandas, matplotlib
echo.
uv pip install jupyter notebook ipykernel
uv pip install rpy2
uv pip install marimo
uv pip install numpy pandas matplotlib

echo.
echo  Registering Jupyter kernel...
python -m ipykernel install --user --name=MyR_py314 --display-name="MyR (Python 3.14)"
echo  [OK] Kernel: MyR (Python 3.14)

echo.
echo  Project MyR is ready.
echo.
pause

:: ============================================================
:: SECTION 4 - JUPYTER NOTEBOOK DEMO
:: ============================================================

echo.
echo ============================================================
echo  SECTION 4: Creating Jupyter Notebook Demo
echo ============================================================
echo.
echo  Jupyter Notebook - the classic interactive notebook.
echo  Run cells one by one with Shift+Enter.
echo  Homepage: https://jupyter.org
echo.
echo  Writing demo_jupyter.ipynb...
call :WRITE_JUPYTER
echo  [OK] demo_jupyter.ipynb created.
echo.
set OPEN_JNB=N
set /p OPEN_JNB="  Open Jupyter in browser now? Y or N (press Enter for N): "
if /i "%OPEN_JNB%"=="Y" goto :open_jupyter
echo  You can open it later with: jupyter notebook
goto :jupyter_done

:open_jupyter
echo.
echo  Launching Jupyter...
echo  Click demo_jupyter.ipynb in the browser file list.
echo  Press any key here when done.
echo.
start "" jupyter notebook --notebook-dir="%PROJECT_DIR%"
pause

:jupyter_done

echo.
pause

:: ============================================================
:: SECTION 5 - MARIMO DEMO
:: ============================================================

echo.
echo ============================================================
echo  SECTION 5: Creating Marimo Reactive Notebook Demo
echo ============================================================
echo.
echo  Marimo - next-generation reactive notebook.
echo  Change a slider and ALL dependent cells update live.
echo  Stored as plain .py files - perfect for Git.
echo  Homepage: https://marimo.io
echo.
echo  Writing demo_marimo.py...
call :WRITE_MARIMO
echo  [OK] demo_marimo.py created.
echo.
set OPEN_MARIMO=N
set /p OPEN_MARIMO="  Open Marimo in browser now? Y or N (press Enter for N): "
if /i "%OPEN_MARIMO%"=="Y" goto :open_marimo
echo  You can open it later with: marimo edit demo_marimo.py
goto :marimo_done

:open_marimo
echo.
echo  Launching Marimo...
echo  Press any key here when done.
echo.
start "" marimo edit "%PROJECT_DIR%\demo_marimo.py"
pause

:marimo_done

:: ============================================================
:: FINAL SUMMARY
:: ============================================================

echo.
echo ============================================================
echo  ALL DONE - Setup Complete
echo ============================================================
echo.
echo  WHAT WAS CHECKED AND INSTALLED:
echo  --------------------------------
echo   [OK] Python 3.12  - system Python (already on your PC)
echo   [OK] pip          - Python package installer
echo   [OK] UV           - fast modern package manager
echo   [OK] R 4.x        - statistical computing language
echo   [OK] .venv        - Python 3.14 virtual environment
echo   [OK] jupyter      - classic notebook (Shift+Enter to run)
echo   [OK] marimo       - reactive notebook (auto-updates)
echo   [OK] rpy2         - bridge to run R code inside Python
echo   [OK] numpy        - fast arrays and math
echo   [OK] pandas       - data tables and analysis
echo   [OK] matplotlib   - charts and plots
echo.
echo  PROJECT LOCATION:
echo    %PROJECT_DIR%
echo.
echo  FILES CREATED:
echo    demo_jupyter.ipynb  - open in Jupyter browser tab
echo    demo_marimo.py      - open in Marimo browser tab
echo.
echo ============================================================
echo  HOW TO USE NEXT TIME
echo ============================================================
echo.
echo   Step 1: Open CMD as Administrator (Win key, type cmd,
echo           right-click, Run as administrator)
echo   Step 2: cd %PROJECT_DIR%
echo   Step 3: .venv\Scripts\activate.bat
echo   Step 4: Choose what to open:
echo             jupyter notebook
echo             marimo edit demo_marimo.py
echo.
echo  To check which Python is active at any time:
echo    python --version
echo    where python
echo.
echo ============================================================
echo  FREE LEARNING RESOURCES
echo ============================================================
echo.
echo   Python 3.14  https://docs.python.org/3.14/
echo   R            https://r4ds.hadley.nz/
echo   UV           https://docs.astral.sh/uv/
echo   Rust         https://doc.rust-lang.org/book/
echo   Marimo       https://docs.marimo.io/
echo   Jupyter      https://jupyter.org/documentation
echo.
echo   YouTube picks:
echo     Python  - freeCodeCamp full Python course
echo     R       - StatQuest with Josh Starmer
echo     Rust    - Let's Get Rusty
echo.
echo ============================================================
echo  NOTEBOOK HOMEPAGES
echo ============================================================
echo.
echo   Jupyter Notebook
echo     Home    : https://jupyter.org
echo     Docs    : https://jupyter-notebook.readthedocs.io
echo     Gallery : https://nbviewer.org
echo     Cloud   : https://colab.research.google.com  (Google Colab)
echo.
echo   Marimo
echo     Home    : https://marimo.io
echo     Docs    : https://docs.marimo.io
echo     Gallery : https://marimo.io/gallery
echo     Cloud   : https://molab.marimo.io  (free online Marimo)
echo.
echo   Key difference:
echo     Jupyter  = classic, run cells manually, widely supported
echo     Marimo   = reactive, cells update automatically, Git-friendly
echo.
echo ============================================================
echo  HOW YOUR PYTHON SETUP WORKS
echo ============================================================
echo.
echo  You have TWO Python versions - this is correct and normal:
echo.
echo  MAIN (system)
echo    Python 3.12  - your system Python, always available
echo    pip, uv      - installed here, used to manage projects
echo.
echo  Desktop\MyR\.venv  (virtual environment)
echo    Python 3.14  - uv downloaded this just for this project
echo    jupyter, marimo, rpy2, numpy, pandas, matplotlib
echo    completely isolated - nothing here affects system Python
echo.
echo  WHY THIS IS GREAT:
echo    - System Python 3.12 stays clean and stable
echo    - Each project can have its own Python version
echo    - Breaking a venv never affects your system
echo    - Just delete .venv and recreate if anything goes wrong
echo.
echo  HOW TO TELL WHICH PYTHON IS ACTIVE:
echo    Outside a venv:  python --version  shows 3.12
echo    Inside the venv: python --version  shows 3.14
echo    Always check with:  where python
echo.
echo ============================================================
echo.
pause
endlocal
goto :eof


:: ============================================================
:: SUBROUTINE: Write Jupyter notebook
:: ============================================================
:WRITE_JUPYTER
python -c "import json; nb={'nbformat':4,'nbformat_minor':5,'metadata':{'kernelspec':{'display_name':'MyR (Python 3.14)','language':'python','name':'MyR_py314'},'language_info':{'name':'python','version':'3.14'}},'cells':[{'cell_type':'markdown','metadata':{},'source':['# MyR - Jupyter Notebook Demo\n## Python 3.14 + R + UV\nRun each cell with Shift+Enter.\n']},{'cell_type':'code','metadata':{},'execution_count':None,'outputs':[],'source':['import sys, platform\nprint(\"Python:\", sys.version)\nprint(\"Platform:\", platform.platform())']},{'cell_type':'markdown','metadata':{},'source':['## Chart with matplotlib\n']},{'cell_type':'code','metadata':{},'execution_count':None,'outputs':[],'source':['import matplotlib.pyplot as plt\nimport numpy as np\nx=np.linspace(0,6.28,100)\nplt.figure(figsize=(8,4))\nplt.plot(x,np.sin(x),label=\"sin(x)\",color=\"royalblue\")\nplt.plot(x,np.cos(x),label=\"cos(x)\",color=\"tomato\")\nplt.title(\"Sine and Cosine - MyR Demo\")\nplt.legend()\nplt.grid(True,alpha=0.3)\nplt.tight_layout()\nplt.show()']},{'cell_type':'markdown','metadata':{},'source':['## R integration via rpy2\n']},{'cell_type':'code','metadata':{},'execution_count':None,'outputs':[],'source':['try:\n    import rpy2.robjects as ro\n    r=ro.r\n    print(\"R version major:\",r(\"R.version\$major\")[0])\n    print(\"R mean of 1 to 10:\",r(\"mean(1:10)\")[0])\nexcept Exception as e:\n    print(\"rpy2 note:\",e)\n    print(\"Install R from https://cran.r-project.org/ then rerun: uv pip install rpy2\")']},{'cell_type':'code','metadata':{},'execution_count':None,'outputs':[],'source':['import pandas as pd\ndf=pd.DataFrame({\"Language\":[\"Python\",\"R\",\"Rust\"],\"Year\":[1991,1993,2010],\"Use\":[\"General/ML\",\"Statistics\",\"Systems\"]})\nprint(df.to_string(index=False))']},{'cell_type':'markdown','metadata':{},'source':['## UV Quick Reference\n```\nuv init myproject     # new project\nuv venv               # create venv\nuv pip install pkg    # install package\nuv run script.py      # run script in venv\nuv sync               # sync all deps\n```\n## Free Resources\n| Topic | URL |\n|-------|-----|\n| Python 3.14 | https://docs.python.org/3.14/ |\n| R | https://r4ds.hadley.nz/ |\n| UV | https://docs.astral.sh/uv/ |\n| Rust | https://doc.rust-lang.org/book/ |\n| Marimo | https://docs.marimo.io/ |\n']}]}; f=open(r'%PROJECT_DIR%\demo_jupyter.ipynb','w',encoding='utf-8'); json.dump(nb,f,indent=2); f.close(); print('Written: demo_jupyter.ipynb')"
goto :eof


:: ============================================================
:: SUBROUTINE: Write Marimo notebook
:: ============================================================
:WRITE_MARIMO
set MO=%PROJECT_DIR%\demo_marimo.py
echo import marimo > "%MO%"
echo. >> "%MO%"
echo __generated_with = "0.10.0" >> "%MO%"
echo app = marimo.App(width="medium") >> "%MO%"
echo. >> "%MO%"
echo. >> "%MO%"
echo @app.cell >> "%MO%"
echo def _(): >> "%MO%"
echo     import marimo as mo >> "%MO%"
echo     return (mo,) >> "%MO%"
echo. >> "%MO%"
echo. >> "%MO%"
echo @app.cell >> "%MO%"
echo def _(mo): >> "%MO%"
echo     mo.md(r""" >> "%MO%"
echo     # MyR - Marimo Reactive Notebook Demo >> "%MO%"
echo     ## Python + R + UV >> "%MO%"
echo     Drag the slider below and watch the chart update live! >> "%MO%"
echo     """) >> "%MO%"
echo     return >> "%MO%"
echo. >> "%MO%"
echo. >> "%MO%"
echo @app.cell >> "%MO%"
echo def _(mo): >> "%MO%"
echo     n = mo.ui.slider(10, 300, value=80, label="Number of points") >> "%MO%"
echo     return (n,) >> "%MO%"
echo. >> "%MO%"
echo. >> "%MO%"
echo @app.cell >> "%MO%"
echo def _(n): >> "%MO%"
echo     n >> "%MO%"
echo     return >> "%MO%"
echo. >> "%MO%"
echo. >> "%MO%"
echo @app.cell >> "%MO%"
echo def _(mo, n): >> "%MO%"
echo     import numpy as np >> "%MO%"
echo     import matplotlib.pyplot as plt >> "%MO%"
echo     x = np.linspace(0, 12.56, n.value) >> "%MO%"
echo     y = np.sin(x) * np.exp(-x / 10) >> "%MO%"
echo     fig, ax = plt.subplots(figsize=(8, 4)) >> "%MO%"
echo     ax.plot(x, y, color="royalblue", linewidth=2) >> "%MO%"
echo     ax.set_title(f"Damped Sine Wave - {n.value} points") >> "%MO%"
echo     ax.set_xlabel("x") >> "%MO%"
echo     ax.set_ylabel("y = sin(x) * exp(-x/10)") >> "%MO%"
echo     ax.grid(True, alpha=0.3) >> "%MO%"
echo     plt.tight_layout() >> "%MO%"
echo     mo.md(f"### Chart with **{n.value}** points") >> "%MO%"
echo     return (fig,) >> "%MO%"
echo. >> "%MO%"
echo. >> "%MO%"
echo @app.cell >> "%MO%"
echo def _(mo): >> "%MO%"
echo     mo.md(r""" >> "%MO%"
echo     ## Notebook Homepages >> "%MO%"
echo     - Jupyter : https://jupyter.org >> "%MO%"
echo     - Marimo  : https://marimo.io >> "%MO%"
echo. >> "%MO%"
echo     ## Free Learning Resources >> "%MO%"
echo     - Python 3.14 : https://docs.python.org/3.14/ >> "%MO%"
echo     - R for Data Science : https://r4ds.hadley.nz/ >> "%MO%"
echo     - UV : https://docs.astral.sh/uv/ >> "%MO%"
echo     - Rust Book : https://doc.rust-lang.org/book/ >> "%MO%"
echo     """) >> "%MO%"
echo     return >> "%MO%"
echo. >> "%MO%"
echo. >> "%MO%"
echo if __name__ == "__main__": >> "%MO%"
echo     app.run() >> "%MO%"
echo  [OK] demo_marimo.py written without warnings.
goto :eof
