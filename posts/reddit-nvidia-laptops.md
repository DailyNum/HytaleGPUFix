# [Tool] Hytale not using dedicated GPU - fix for hybrid graphics laptops

For anyone playing the new Hytale Early Access on a laptop with hybrid graphics (NVIDIA + integrated):

The game was completely broken for me - invisible character model, mobs not rendering, awful graphics. Turns out Windows was running it on my integrated AMD GPU instead of my RTX 4080.

Made a quick tool to fix it:

**https://github.com/DailyNum/HytaleGPUFix**

- Detects your GPUs
- Sets Hytale executables to use your NVIDIA card
- Also has option to open NVIDIA Control Panel for manual setup

Just sharing in case anyone else hits this. Hytale is Java-based so it needs both the game client AND the bundled Java runtime set to use the dedicated GPU.

---

**Only useful if:**
- You have a laptop with Optimus/hybrid graphics
- Or a desktop with multiple GPUs
- Won't help single-GPU systems
