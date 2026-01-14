# [Tool] Fix: Invisible Character/Mobs on Gaming Laptops

Hey everyone,

If you're on a gaming laptop and having issues with:
- Character model invisible in third person view
- Mobs/NPCs not rendering or disappearing
- Graphics looking way worse than they should

**The cause:** Your laptop has two GPUs (gaming GPU + integrated), and Windows is picking the wrong one for Hytale.

I had this problem on my ASUS laptop with RTX 4080 + AMD Radeon 780M. Game was unplayable until I forced it to use the NVIDIA card.

---

## Download

**GitHub:** https://github.com/DailyNum/HytaleGPUFix/releases/latest

1. Download the zip
2. Extract and run Fix-Hytale-GPU.bat
3. Select your gaming GPU from the list
4. Restart Hytale

---

## What it does

Sets Windows GPU preference for:
- HytaleClient.exe
- java.exe / javaw.exe (Hytale uses bundled Java)
- hytale-launcher.exe

No admin rights needed. Doesn't modify game files. Easily reversible.

---

## Requirements

- Windows 10/11
- Must have multiple GPUs (check Task Manager → Performance)
- Won't help if you only have one GPU

---

Hope this helps! Let me know if you have questions.
