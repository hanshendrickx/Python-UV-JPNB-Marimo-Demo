# Python-UV-JPNB-Marimo-Demo's
Demo setup for JPNB and Marimo Notebooks

# Start-R-Py-UV

Copyright (c) 2025 Hans Hendrickx
https://github.com/hanshendrickx
MIT License

**A one-click Windows setup script to install and configure R, Python 3.14, and UV — with Jupyter and Marimo notebooks ready to go.**

By [@hanshendrickx](https://github.com/hanshendrickx)
Find the app 

---

## What this does

Run `Start-R-Py-UV.bat` once and it will:

1. ✅ Check for **Python 3.14**, **R**, and **UV** — install anything missing
2. ✅ Create a **UV project** called `MyR` on your Desktop
3. ✅ Create a **Python 3.14 virtual environment** inside `MyR`
4. ✅ Install **Jupyter**, **Marimo**, **rpy2**, **numpy**, **pandas**, **matplotlib**
5. ✅ Write a **Jupyter Notebook demo** (`demo_jupyter.ipynb`)
6. ✅ Write a **Marimo reactive notebook demo** (`demo_marimo.py`)
7. ✅ Show a full summary of your setup and how to use it

---

## Requirements

- Windows 10 or Windows 11 (64-bit)
- Internet connection (for downloading packages)
- No winget needed — everything installs via pip or direct download

---

## How to run

> ⚠️ Do **not** run via VS Code's Run Code button — it breaks interactive prompts.

**Method 1 — Windows CMD as Administrator (recommended):**

```
1. Press Win key, type: cmd
2. Right-click "Command Prompt" → Run as administrator
3. cd "C:\path\to\this\folder"
4. Start-R-Py-UV.bat
```

**Method 2 — VS Code Terminal in cmd mode:**

```
1. Open VS Code
2. Press Ctrl+Shift+` to open Terminal
3. Click the dropdown next to + → choose "Command Prompt"
4. cd "C:\path\to\this\folder"
5. Start-R-Py-UV.bat
```

**How to find your folder path:**
- Open Windows Explorer, navigate to this folder
- Click the address bar — the full path appears
- Copy it and paste after `cd`

---

## What gets installed

| Tool | Purpose |
|------|---------|
| Python 3.12 | System Python (stays clean, untouched) |
| Python 3.14 | Inside the MyR venv (via UV) |
| R 4.x | Statistical computing |
| UV | Fast modern package manager |
| Jupyter | Classic interactive notebook |
| Marimo | Reactive next-gen notebook |
| rpy2 | Run R code inside Python |
| numpy | Fast arrays and math |
| pandas | Data tables and analysis |
| matplotlib | Charts and plots |

---

## How your Python setup works

```
Windows MAIN (system)
└── Python 3.12  ← always available everywhere
    └── pip, uv  ← manage your projects

Desktop\MyR\
└── .venv\
    └── Python 3.14  ← isolated, just for this project
        └── jupyter, marimo, rpy2, numpy, pandas, matplotlib
```

- System Python stays **clean and stable**
- Each UV project can have its **own Python version**
- Breaking a venv never affects your system
- To check which Python is active: `python --version` and `where python`

---

## Using it next time

```cmd
cd %USERPROFILE%\Desktop\MyR
.venv\Scripts\activate.bat

jupyter notebook                    # open Jupyter
marimo edit demo_marimo.py          # open Marimo
```

---

## The two notebooks

### Jupyter Notebook
The classic interactive notebook used across data science, research, and education.
Run cells one by one with `Shift+Enter`.

| | |
|--|--|
| 🏠 Home | https://jupyter.org |
| 📖 Docs | https://jupyter-notebook.readthedocs.io |
| ☁️ Cloud | https://colab.research.google.com |

### Marimo
A next-generation **reactive** notebook. Change a slider or variable and all dependent cells update automatically — like a spreadsheet. Stored as plain `.py` files, perfect for Git.

| | |
|--|--|
| 🏠 Home | https://marimo.io |
| 📖 Docs | https://docs.marimo.io |
| 🎨 Gallery | https://marimo.io/gallery |
| ☁️ Cloud | https://molab.marimo.io |

**Key difference:**
- **Jupyter** = widely supported, run cells manually, great for sharing
- **Marimo** = reactive auto-updates, Git-friendly, deployable as web apps

---

## Free learning resources

| Topic | Resource |
|-------|----------|
| Python 3.14 | https://docs.python.org/3.14/ |
| R for Data Science | https://r4ds.hadley.nz/ |
| UV package manager | https://docs.astral.sh/uv/ |
| The Rust Book | https://doc.rust-lang.org/book/ |

**YouTube:**
- Python → freeCodeCamp full Python course
- R → StatQuest with Josh Starmer
- Rust → Let's Get Rusty

---

## Files in this repo

```
Start-R-Py-UV.bat    ← the setup script (run this)
README.md            ← this file
```

After running the script, your `Desktop\MyR\` folder will contain:

```
MyR\
├── .venv\               ← Python 3.14 virtual environment
├── demo_jupyter.ipynb   ← Jupyter demo notebook
├── demo_marimo.py       ← Marimo reactive notebook
└── pyproject.toml       ← UV project config
```

---

## License -- Copyright (c) 2025 Hans Hendrickx

MIT — free to use, share, and modify.

---

*Made with ❤️ for anyone starting their journey with R, Python, and modern data science tooling.*
