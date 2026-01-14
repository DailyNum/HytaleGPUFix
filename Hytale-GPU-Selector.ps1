# ============================================
#  Hytale GPU Selector v1.0
#  Fixes invisible models & rendering issues
#
#  - Detects all GPUs automatically
#  - Works on any Windows PC
#  - No admin rights required
#
#  GitHub: github.com/[YOUR-USERNAME]/HytaleGPUFix
# ============================================

# --- Configuration ---
$script:Version = "1.0"
$script:CounterNamespace = "hytalegpufix"
$script:CounterKey = "runs"
$script:PrefsFile = Join-Path $env:APPDATA "HytaleGPUFix\prefs.json"

# ============================================
#  ANALYTICS (Opt-in, Anonymous)
# ============================================

function Get-UserConsent {
    # Check if user already gave consent preference
    if (Test-Path $script:PrefsFile) {
        try {
            $prefs = Get-Content $script:PrefsFile -Raw | ConvertFrom-Json
            return $prefs.analyticsConsent
        } catch {
            # Corrupted file, ask again
        }
    }

    # First run - ask for consent
    Clear-Host
    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor Cyan
    Write-Host "       HYTALE GPU SELECTOR v$($script:Version)" -ForegroundColor White
    Write-Host "  ========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Welcome! Before we start, a quick question:" -ForegroundColor White
    Write-Host ""
    Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
    Write-Host "  ANONYMOUS USAGE TRACKING" -ForegroundColor Yellow
    Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  To help improve this tool, we'd like to" -ForegroundColor White
    Write-Host "  count how many times it's been used." -ForegroundColor White
    Write-Host ""
    Write-Host "  What we track:" -ForegroundColor Yellow
    Write-Host "    - Just a simple counter (+1 each run)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  What we DON'T track:" -ForegroundColor Yellow
    Write-Host "    - No personal information" -ForegroundColor DarkGray
    Write-Host "    - No IP addresses" -ForegroundColor DarkGray
    Write-Host "    - No hardware details" -ForegroundColor DarkGray
    Write-Host "    - No usernames or paths" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  This is completely optional." -ForegroundColor White
    Write-Host "  The tool works exactly the same either way." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [Y] Yes, count my usage (anonymous)" -ForegroundColor Green
    Write-Host "  [N] No thanks, skip tracking" -ForegroundColor White
    Write-Host ""

    $response = Read-Host "  Your choice (Y/N)"

    $consent = $response -match "^[Yy]"

    # Save preference
    try {
        $prefsDir = Split-Path $script:PrefsFile -Parent
        if (!(Test-Path $prefsDir)) {
            New-Item -ItemType Directory -Path $prefsDir -Force | Out-Null
        }

        $prefs = @{
            analyticsConsent = $consent
            consentDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            version = $script:Version
        }

        $prefs | ConvertTo-Json | Set-Content $script:PrefsFile -Force

        Write-Host ""
        if ($consent) {
            Write-Host "  [OK] Thanks! Your preference has been saved." -ForegroundColor Green
        } else {
            Write-Host "  [OK] No problem! Tracking disabled." -ForegroundColor Green
        }
        Write-Host "  (You can delete %APPDATA%\HytaleGPUFix to reset)" -ForegroundColor DarkGray
        Start-Sleep -Seconds 2
    } catch {
        # Couldn't save prefs, continue anyway
    }

    return $consent
}

function Send-AnonymousPing {
    param([bool]$hasConsent)

    if (-not $hasConsent) { return }

    try {
        # Use CountAPI - free, anonymous counter service
        # Only increments a counter, no data collected
        $uri = "https://api.countapi.xyz/hit/$($script:CounterNamespace)/$($script:CounterKey)"
        $null = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 3 -ErrorAction SilentlyContinue
    } catch {
        # Silently fail - don't interrupt user experience
    }
}

function Get-TotalRuns {
    try {
        $uri = "https://api.countapi.xyz/get/$($script:CounterNamespace)/$($script:CounterKey)"
        $result = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 3 -ErrorAction SilentlyContinue
        return $result.value
    } catch {
        return $null
    }
}

# ============================================
#  UI FUNCTIONS
# ============================================

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor Cyan
    Write-Host "       HYTALE GPU SELECTOR v$($script:Version)" -ForegroundColor White
    Write-Host "  ========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Fixes invisible models & rendering issues" -ForegroundColor DarkGray
    Write-Host "  by ensuring Hytale uses the correct GPU." -ForegroundColor DarkGray
    Write-Host ""
}

function Get-GPUColor {
    param($gpuName)
    if ($gpuName -match "NVIDIA|GeForce|RTX|GTX|Quadro|Tesla") { return "Green" }
    elseif ($gpuName -match "AMD|Radeon|Vega") { return "Red" }
    elseif ($gpuName -match "Intel|Arc|Iris|UHD|HD Graphics") { return "Blue" }
    else { return "White" }
}

function Get-GPUType {
    param($gpuName)
    if ($gpuName -match "RTX|GTX|Quadro|Radeon RX|Arc A\d|GeForce \d{3,4}") { return "Discrete" }
    elseif ($gpuName -match "UHD|Iris|Vega \d$|780M|760M|740M|680M|660M|integrated|Graphics \d{3,4}$") { return "Integrated" }
    elseif ($gpuName -match "NVIDIA|GeForce|Radeon") { return "Discrete" }
    else { return "Unknown" }
}

function Get-GPUVendor {
    param($gpuName)
    if ($gpuName -match "NVIDIA|GeForce|RTX|GTX|Quadro|Tesla") { return "NVIDIA" }
    elseif ($gpuName -match "AMD|Radeon") { return "AMD" }
    elseif ($gpuName -match "Intel|Arc|Iris|UHD") { return "Intel" }
    else { return "Unknown" }
}

function Find-HytaleExecutables {
    $exes = @()

    Write-Host "  Searching for Hytale..." -ForegroundColor DarkGray

    # Game client in AppData (standard location)
    $appDataHytale = Join-Path $env:APPDATA "Hytale\install\release\package"
    if (Test-Path $appDataHytale) {
        $gameDir = Join-Path $appDataHytale "game"
        if (Test-Path $gameDir) {
            Get-ChildItem -Path $gameDir -Recurse -Filter "HytaleClient.exe" -ErrorAction SilentlyContinue | ForEach-Object {
                $exes += $_.FullName
            }
        }

        $jreDir = Join-Path $appDataHytale "jre"
        if (Test-Path $jreDir) {
            Get-ChildItem -Path $jreDir -Recurse -Filter "java*.exe" -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.Name -match "^java(w)?\.exe$") {
                    $exes += $_.FullName
                }
            }
        }
    }

    # Find launcher in common locations
    $searchRoots = @(
        $env:ProgramFiles,
        ${env:ProgramFiles(x86)},
        $env:LOCALAPPDATA,
        "$env:LOCALAPPDATA\Programs"
    )

    Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue | Where-Object { $_.Used -gt 0 } | ForEach-Object {
        $searchRoots += "$($_.Root)Games"
        $searchRoots += "$($_.Root)Program Files"
        $searchRoots += "$($_.Root)Program Files (x86)"
    }

    $foundLauncher = $false
    foreach ($root in $searchRoots) {
        if ((Test-Path $root) -and (-not $foundLauncher)) {
            $launcher = Get-ChildItem -Path $root -Recurse -Filter "hytale-launcher.exe" -Depth 4 -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($launcher) {
                $exes += $launcher.FullName
                $foundLauncher = $true
            }
        }
    }

    return $exes | Select-Object -Unique
}

function Open-NVIDIAControlPanel {
    param($hytaleExePath)

    Write-Host ""
    Write-Host "  Opening NVIDIA Control Panel..." -ForegroundColor Cyan

    $nvcplPath = "$env:SystemRoot\System32\nvcplui.exe"
    $nvControlPanel = "$env:ProgramFiles\NVIDIA Corporation\Control Panel Client\nvcplui.exe"

    $opened = $false
    if (Test-Path $nvcplPath) {
        Start-Process $nvcplPath
        $opened = $true
    } elseif (Test-Path $nvControlPanel) {
        Start-Process $nvControlPanel
        $opened = $true
    }

    if (-not $opened) {
        Write-Host "  [!] Could not find NVIDIA Control Panel." -ForegroundColor Yellow
        Write-Host "  Opening Windows Graphics Settings instead..." -ForegroundColor DarkGray
        Start-Process "ms-settings:display-advancedgraphics"
    }

    Write-Host ""
    Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
    Write-Host "  MANUAL SETUP INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  1. Go to: Manage 3D Settings" -ForegroundColor White
    Write-Host "  2. Click: Program Settings tab" -ForegroundColor White
    Write-Host "  3. Click: Add -> Browse" -ForegroundColor White
    Write-Host ""
    Write-Host "  4. Paste this path (copied to clipboard):" -ForegroundColor White
    Write-Host "     $hytaleExePath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  5. Set 'preferred graphics processor' to" -ForegroundColor White
    Write-Host "     your NVIDIA GPU" -ForegroundColor White
    Write-Host "  6. Click: Apply" -ForegroundColor White
    Write-Host ""

    try {
        Set-Clipboard -Value $hytaleExePath
        Write-Host "  [OK] Path copied to clipboard!" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Could not copy to clipboard" -ForegroundColor Yellow
    }
    Write-Host ""
}

function Open-AMDRadeonSoftware {
    param($hytaleExePath)

    Write-Host ""
    Write-Host "  Opening AMD Radeon Software..." -ForegroundColor Cyan

    $amdPaths = @(
        "$env:ProgramFiles\AMD\CNext\CNext\RadeonSoftware.exe",
        "$env:LocalAppData\AMD\CN\RadeonSoftware.exe",
        "${env:ProgramFiles(x86)}\AMD\CNext\CNext\RadeonSoftware.exe"
    )

    $opened = $false
    foreach ($path in $amdPaths) {
        if (Test-Path $path) {
            Start-Process $path
            $opened = $true
            break
        }
    }

    if (-not $opened) {
        Write-Host "  [!] Could not find AMD Radeon Software." -ForegroundColor Yellow
        Write-Host "  Opening Windows Graphics Settings instead..." -ForegroundColor DarkGray
        Start-Process "ms-settings:display-advancedgraphics"
    }

    Write-Host ""
    Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
    Write-Host "  MANUAL SETUP INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  1. Go to: Gaming tab" -ForegroundColor White
    Write-Host "  2. Click: Add a Game -> Browse" -ForegroundColor White
    Write-Host ""
    Write-Host "  3. Paste this path (copied to clipboard):" -ForegroundColor White
    Write-Host "     $hytaleExePath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  4. Select your preferred GPU" -ForegroundColor White
    Write-Host "  5. Save settings" -ForegroundColor White
    Write-Host ""

    try {
        Set-Clipboard -Value $hytaleExePath
        Write-Host "  [OK] Path copied to clipboard!" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Could not copy to clipboard" -ForegroundColor Yellow
    }
    Write-Host ""
}

function Open-WindowsGraphicsSettings {
    param($hytaleExePath)

    Write-Host ""
    Write-Host "  Opening Windows Graphics Settings..." -ForegroundColor Cyan

    Start-Process "ms-settings:display-advancedgraphics"

    Write-Host ""
    Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
    Write-Host "  MANUAL SETUP INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  1. Click: Browse (under 'Add an app')" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Paste this path (copied to clipboard):" -ForegroundColor White
    Write-Host "     $hytaleExePath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  3. Click on Hytale entry -> Options" -ForegroundColor White
    Write-Host "  4. Select: High Performance" -ForegroundColor White
    Write-Host "  5. Click: Save" -ForegroundColor White
    Write-Host ""

    try {
        Set-Clipboard -Value $hytaleExePath
        Write-Host "  [OK] Path copied to clipboard!" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Could not copy to clipboard" -ForegroundColor Yellow
    }
    Write-Host ""
}

function Apply-GPUPreference {
    param($exes, $preferenceValue, $gpuName)

    $regPath = "HKCU:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences"

    try {
        if (!(Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }

        Write-Host ""
        Write-Host "  APPLYING SETTINGS:" -ForegroundColor Yellow
        Write-Host "  -------------------" -ForegroundColor Yellow
        Write-Host ""

        foreach ($exe in $exes) {
            $fileName = Split-Path $exe -Leaf
            Set-ItemProperty -Path $regPath -Name $exe -Value "GpuPreference=$preferenceValue;" -Type String
            Write-Host "    [OK] $fileName" -ForegroundColor Green
        }

        return $true
    } catch {
        Write-Host ""
        Write-Host "  [ERROR] Failed to apply settings: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# ============================================
#  MAIN SCRIPT
# ============================================

# Check for analytics consent (first run will prompt)
$hasConsent = Get-UserConsent

# Send anonymous ping if user consented
Send-AnonymousPing -hasConsent $hasConsent

# Show main UI
Show-Banner

# Detect ALL GPUs
$gpus = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Where-Object {
    $_.Status -eq "OK" -or $_.Availability -eq 3
})

if ($gpus.Count -eq 0) {
    $gpus = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue)
}

if ($gpus.Count -eq 0) {
    Write-Host "  [ERROR] No GPUs detected!" -ForegroundColor Red
    Write-Host "  Please ensure your graphics drivers are installed." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 1
}

# Analyze GPU configuration
$discreteGPUs = @($gpus | Where-Object { (Get-GPUType $_.Name) -eq "Discrete" })
$nvidiaGPUs = @($gpus | Where-Object { (Get-GPUVendor $_.Name) -eq "NVIDIA" })
$amdDiscreteGPUs = @($gpus | Where-Object { (Get-GPUVendor $_.Name) -eq "AMD" -and (Get-GPUType $_.Name) -eq "Discrete" })
$hasMultipleDiscrete = $discreteGPUs.Count -gt 1

# Find Hytale
$hytaleExes = Find-HytaleExecutables

if ($hytaleExes.Count -eq 0) {
    Write-Host ""
    Write-Host "  [ERROR] Hytale installation not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Please ensure:" -ForegroundColor Yellow
    Write-Host "  - Hytale is installed" -ForegroundColor White
    Write-Host "  - You have launched it at least once" -ForegroundColor White
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 1
}

# Get main executable for control panel instructions
$mainExe = $hytaleExes | Where-Object { $_ -match "HytaleClient.exe" } | Select-Object -First 1
if (-not $mainExe) { $mainExe = $hytaleExes[0] }

Write-Host "  Found $($hytaleExes.Count) Hytale executable(s)" -ForegroundColor Green
Write-Host ""

# Display detected GPUs
Write-Host "  DETECTED GPUs:" -ForegroundColor Yellow
Write-Host "  --------------" -ForegroundColor Yellow
Write-Host ""

$menuOptions = @()

# Option 0: Let Windows Decide
$menuOptions += @{
    Number = 0
    Display = "Let Windows decide (Auto)"
    Preference = 0
    Type = "Auto"
}

# Add each GPU dynamically
$gpuIndex = 1
foreach ($gpu in $gpus) {
    $vram = if ($gpu.AdapterRAM -and $gpu.AdapterRAM -gt 0) {
        "$([math]::Round($gpu.AdapterRAM / 1GB, 1)) GB"
    } else {
        "Shared"
    }

    $gpuType = Get-GPUType -gpuName $gpu.Name
    $gpuVendor = Get-GPUVendor -gpuName $gpu.Name
    $color = Get-GPUColor -gpuName $gpu.Name

    Write-Host "    GPU $gpuIndex : " -NoNewline -ForegroundColor DarkGray
    Write-Host "$($gpu.Name) " -NoNewline -ForegroundColor $color
    Write-Host "($vram) " -NoNewline -ForegroundColor DarkGray
    Write-Host "[$gpuType]" -ForegroundColor DarkGray

    $prefValue = if ($gpuType -eq "Integrated") { 1 } else { 2 }

    $menuOptions += @{
        Number = $gpuIndex
        Display = $gpu.Name
        Preference = $prefValue
        Type = $gpuType
        Vendor = $gpuVendor
    }

    $gpuIndex++
}

# Build advanced options dynamically
$extraOptions = @()

if ($nvidiaGPUs.Count -gt 0) {
    $extraOptions += @{
        Key = "N"
        Display = "Open NVIDIA Control Panel"
        Action = "NVIDIA"
    }
}

if ($amdDiscreteGPUs.Count -gt 0) {
    $extraOptions += @{
        Key = "A"
        Display = "Open AMD Radeon Software"
        Action = "AMD"
    }
}

$extraOptions += @{
    Key = "W"
    Display = "Open Windows Graphics Settings"
    Action = "Windows"
}

Write-Host ""
Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# Multi-discrete GPU warning
if ($hasMultipleDiscrete) {
    Write-Host "  [!] Multiple gaming GPUs detected!" -ForegroundColor Yellow
    Write-Host "      Use [N] or [A] for precise GPU selection" -ForegroundColor DarkGray
    Write-Host ""
}

Write-Host "  SELECT GPU PREFERENCE:" -ForegroundColor Yellow
Write-Host ""

# Display numbered options
foreach ($opt in $menuOptions) {
    $marker = ""
    if ($opt.Type -eq "Discrete") { $marker = " <- Recommended" }

    if ($opt.Number -eq 0) {
        Write-Host "    [0] $($opt.Display)" -ForegroundColor White
    } else {
        $color = Get-GPUColor -gpuName $opt.Display
        Write-Host "    [$($opt.Number)] " -NoNewline -ForegroundColor White
        Write-Host "$($opt.Display)" -NoNewline -ForegroundColor $color
        Write-Host "$marker" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "  ---- Advanced ----" -ForegroundColor DarkGray

foreach ($opt in $extraOptions) {
    Write-Host "    [$($opt.Key)] $($opt.Display)" -ForegroundColor DarkCyan
}

Write-Host ""
Write-Host "    [Q] Quit" -ForegroundColor DarkGray
Write-Host ""

# Get user input
$maxChoice = $menuOptions.Count - 1
$choice = Read-Host "  Your choice"

# Handle quit
if ($choice -eq "Q" -or $choice -eq "q" -or $choice -eq "") {
    Write-Host ""
    Write-Host "  No changes made. Goodbye!" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# Handle advanced options
$extraOption = $extraOptions | Where-Object { $_.Key -eq $choice.ToUpper() }
if ($extraOption) {
    switch ($extraOption.Action) {
        "NVIDIA" { Open-NVIDIAControlPanel -hytaleExePath $mainExe }
        "AMD" { Open-AMDRadeonSoftware -hytaleExePath $mainExe }
        "Windows" { Open-WindowsGraphicsSettings -hytaleExePath $mainExe }
    }
    Read-Host "  Press Enter to exit"
    exit 0
}

# Handle numeric selection
$choiceNum = $null
if ([int]::TryParse($choice, [ref]$choiceNum)) {
    $selectedOption = $menuOptions | Where-Object { $_.Number -eq $choiceNum }
} else {
    $selectedOption = $null
}

if ($null -eq $selectedOption) {
    Write-Host ""
    Write-Host "  [ERROR] Invalid choice: '$choice'" -ForegroundColor Red
    Write-Host "  Please enter a number (0-$maxChoice) or letter option." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 1
}

# Apply settings
$success = Apply-GPUPreference -exes $hytaleExes -preference $selectedOption.Preference -gpuName $selectedOption.Display

Write-Host ""
if ($success) {
    Write-Host "  ========================================" -ForegroundColor Cyan
    if ($selectedOption.Number -eq 0) {
        Write-Host "    GPU set to: Auto (Windows decides)" -ForegroundColor Green
    } else {
        Write-Host "    GPU set to: $($selectedOption.Display)" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "    Restart Hytale for changes to apply!" -ForegroundColor White
    Write-Host "  ========================================" -ForegroundColor Cyan
} else {
    Write-Host "  [!] Settings may not have applied correctly." -ForegroundColor Yellow
    Write-Host "  Try running as Administrator or use option [W]." -ForegroundColor DarkGray
}

Write-Host ""
Read-Host "  Press Enter to exit"
