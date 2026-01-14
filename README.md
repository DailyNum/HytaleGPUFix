# Hytale GPU Fix

**Fixes rendering issues in Hytale caused by Windows selecting the wrong GPU.**

---

## ⚠️ Is This Tool For You?

This tool fixes a **specific problem**: Hytale running on your **integrated GPU** instead of your **gaming GPU**.

### ✅ This tool WILL help if:

- You have a **laptop with two GPUs** (e.g., NVIDIA + Intel/AMD integrated)
- You have a **desktop with multiple GPUs**
- Your character model is invisible in third person
- Mobs/NPCs are invisible or vanish
- Graphics look unusually bad despite having a good GPU
- The game runs poorly even though your hardware should handle it

### ❌ This tool WON'T help if:

- You only have **one GPU** (nothing to switch to)
- The issue is a **game bug** (affects everyone, not just you)
- You have **driver problems** (update your GPU drivers first)
- You're experiencing **server/network issues**
- The game is in Early Access and some features are just unfinished

### 🤔 How do I know if this is my problem?

**Signs you have a dual-GPU issue:**
1. You have a gaming laptop (most have hybrid graphics)
2. Task Manager → Performance shows two GPUs
3. Other games have had similar issues until you forced the GPU

---

## 📥 Download

**[Download Latest Release](../../releases/latest)**

1. Download `HytaleGPUFix-v1.0.zip`
2. Extract the zip
3. Double-click `Fix-Hytale-GPU.bat`
4. Select your gaming GPU
5. Restart Hytale

---

## 🖥️ What It Does

Windows sometimes runs games on the **power-saving integrated GPU** instead of your **gaming GPU**. This causes:

- Missing/invisible models
- Poor performance
- Visual glitches

This tool tells Windows: *"Always use my gaming GPU for Hytale."*

**Technical details:**
- Sets `GpuPreference=2` in `HKCU:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences`
- Configures: HytaleClient.exe, java.exe, javaw.exe, hytale-launcher.exe
- No admin rights required
- No system files modified
- Easily reversible

---

## 📸 Screenshot

```
  ========================================
       HYTALE GPU SELECTOR v1.0
  ========================================

  DETECTED GPUs:
  --------------

    GPU 1 : NVIDIA GeForce RTX 4080 (8 GB) [Discrete]
    GPU 2 : AMD Radeon 780M Graphics (Shared) [Integrated]

  SELECT GPU PREFERENCE:

    [0] Let Windows decide (Auto)
    [1] NVIDIA GeForce RTX 4080 <- Recommended
    [2] AMD Radeon 780M Graphics

  ---- Advanced ----
    [N] Open NVIDIA Control Panel
    [W] Open Windows Graphics Settings

    [Q] Quit
```

---

## 🔒 Privacy

On first run, the tool asks if you'd like to help count usage (optional).

**If you say YES:**
- Increments an anonymous counter (+1)
- No personal data, IPs, hardware info, or usernames collected

**If you say NO:**
- Nothing is sent, ever
- Tool works exactly the same

---

## 🛠️ Troubleshooting

**"Hytale installation not found"**
- Launch Hytale at least once first (it installs to AppData on first run)

**"Still having issues after using this tool"**
- Try option `[N]` to open NVIDIA Control Panel for manual setup
- Update your GPU drivers
- Check if others are reporting the same bug (might be a game issue)

**"I only have one GPU"**
- This tool won't help you - your issue is something else
- Check the [Hytale Discord](https://discord.gg/hytale) for support

---

## 📋 Requirements

- Windows 10 or 11
- Hytale installed
- A system with multiple GPUs (laptop hybrid graphics or multi-GPU desktop)

---

## 📄 License

MIT License - Free to use, modify, and distribute.

---

## 🙏 Credits

Created for the Hytale community.

If this helped you, consider starring the repo!
