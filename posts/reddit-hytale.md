# [Tool] Fix for invisible models/mobs in Hytale (laptop users)

If you're playing on a **gaming laptop** and experiencing:

- Invisible character model in third person
- Mobs/NPCs that vanish or don't render
- Terrible graphics despite having a good GPU

**The problem:** Windows is running Hytale on your integrated GPU instead of your gaming GPU (NVIDIA/AMD).

I had this exact issue - game was completely unplayable until I forced it to use my RTX 4080 instead of the integrated AMD graphics.

---

## The Fix

I made a simple tool that sets Hytale to use your dedicated GPU:

**Download:** https://github.com/DailyNum/HytaleGPUFix/releases/latest

Just extract, run the .bat file, pick your gaming GPU, restart Hytale.

---

## Who this helps

✅ Laptops with dual GPUs (NVIDIA + Intel/AMD integrated)
✅ Desktops with multiple GPUs
✅ Invisible model/rendering issues caused by wrong GPU

## Who this WON'T help

❌ Single GPU systems (nothing to switch to)
❌ Actual game bugs that affect everyone
❌ Server/network issues

---

## How to know if this is your problem

1. Open Task Manager → Performance tab
2. If you see **two GPUs** listed, you might have this issue
3. Gaming laptops almost always have hybrid graphics

---

Open source, no admin needed, no system changes. Just sets a Windows preference.

Hope this helps someone else who was stuck like I was!
