============================================
  HYTALE GPU FIX v1.0
============================================

WHAT THIS FIXES:
- Invisible character models in third person
- Invisible or vanishing mobs/NPCs
- Poor rendering quality
- Graphics glitches on hybrid GPU laptops

HOW IT WORKS:
This tool ensures Hytale uses your gaming GPU (like NVIDIA
or AMD Radeon) instead of the slower integrated graphics.

Many laptops have two GPUs, and sometimes Windows picks the
wrong one for games.

--------------------------------------------
HOW TO USE:
--------------------------------------------

1. Double-click "Fix-Hytale-GPU.bat"

2. (First run only) Choose if you want to help us count
   usage - completely optional and anonymous

3. The tool will show your available GPUs

4. Select your gaming GPU (usually the NVIDIA or AMD one)

5. Restart Hytale

That's it!

--------------------------------------------
PRIVACY & ANALYTICS:
--------------------------------------------

On first run, the tool asks if you'd like to help us
track how many people use it.

If you say YES:
  - We count +1 to an anonymous counter
  - No personal info, IPs, hardware, or usernames
  - Just a simple number to know if people find it useful

If you say NO:
  - No data is sent, ever
  - The tool works exactly the same

Your choice is saved so you won't be asked again.
To reset: delete %APPDATA%\HytaleGPUFix folder

--------------------------------------------
REQUIREMENTS:
--------------------------------------------

- Windows 10 or 11
- Hytale installed and launched at least once
- No admin rights needed
- No system changes - only user preferences

--------------------------------------------
TROUBLESHOOTING:
--------------------------------------------

"Hytale installation not found"
  -> Make sure you've launched Hytale at least once
  -> The game installs to AppData after first run

"Script won't run"
  -> Right-click the .bat file
  -> Select "Run as Administrator" (only if needed)

"Still having issues after fix"
  -> Try option [N] to open NVIDIA Control Panel
  -> Manually set Hytale to use your gaming GPU
  -> Check for GPU driver updates

--------------------------------------------
WHAT FILES ARE INCLUDED:
--------------------------------------------

Fix-Hytale-GPU.bat      - Double-click this to run
Hytale-GPU-Selector.ps1 - The actual tool (PowerShell)
README.txt              - This file

--------------------------------------------
SAFE TO USE:
--------------------------------------------

This tool only modifies YOUR user preferences in the
Windows Registry (HKCU). It does NOT:
- Require admin rights
- Modify system files
- Change anything permanently
- Affect other users on the PC

You can undo changes anytime by running the tool again
and selecting "Let Windows decide (Auto)".

--------------------------------------------
OPEN SOURCE:
--------------------------------------------

This tool is free and open source.
GitHub: github.com/[YOUR-USERNAME]/HytaleGPUFix

Found a bug? Have a suggestion?
Open an issue on GitHub!

--------------------------------------------
CREDITS:
--------------------------------------------

Created for the Hytale community
Works with Hytale Early Access (January 2026+)

============================================
