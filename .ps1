# Set your game here
$GameProcessName = "r5apex_dx12"   # Replace with your game's process name (no .exe)
$SteamAppID = "1172470"            # Optional: Replace with your game's Steam ID

# Define ThreadTunerV2
Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class ThreadTunerV2 {
    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenThread(int dwDesiredAccess, bool bInheritHandle, uint dwThreadId);

    [DllImport("kernel32.dll")]
    public static extern bool SetThreadPriority(IntPtr hThread, int nPriority);

    [DllImport("kernel32.dll")]
    public static extern bool CloseHandle(IntPtr hObject);

    [DllImport("kernel32.dll")]
    public static extern int GetThreadPriority(IntPtr hThread);

    public const int THREAD_ALL_ACCESS = 0x1F03FF;
    public const int THREAD_PRIORITY_HIGHEST = 2;

    public static bool BoostThreadIfNeeded(int threadId) {
        IntPtr hThread = OpenThread(THREAD_ALL_ACCESS, false, (uint)threadId);
        if (hThread != IntPtr.Zero) {
            int currentPriority = GetThreadPriority(hThread);
            if (currentPriority != THREAD_PRIORITY_HIGHEST) {
                bool result = SetThreadPriority(hThread, THREAD_PRIORITY_HIGHEST);
                CloseHandle(hThread);
                return result;
            }
            CloseHandle(hThread);
        }
        return false;
    }
}
"@

# Check if game is running
$game = Get-Process -Name $GameProcessName -ErrorAction SilentlyContinue

if (-not $game) {
    Write-Host "Not running... Launching via Steam now"
    if ($SteamAppID -ne "") {
        Start-Process "steam://rungameid/$SteamAppID"
    }

    while (-not $game) {
        Start-Sleep -Milliseconds 500
        $game = Get-Process -Name $GameProcessName -ErrorAction SilentlyContinue
    }
    Write-Host "Game is launching (PID: $($game.Id))"
} else {
    Write-Host "Game already running (PID: $($game.Id))"
}

# Boost threads loop
while ($true) {
    $game = Get-Process -Name $GameProcessName -ErrorAction SilentlyContinue
    if (-not $game) {
        Write-Host "`nGame is not running"
        break
    }

    try {
        foreach ($pt in $game.Threads) {
            $wasBoosted = [ThreadTunerV2]::BoostThreadIfNeeded($pt.Id)
            if ($wasBoosted) {
                Write-Host "[Thread ID: $($pt.Id)] Boosted"
            } else {
                Write-Host "[Thread ID: $($pt.Id)] Wait"
            }
        }
    } catch {
        Write-Host "Error when attempting to boost thread priority: $_"
    }

    Start-Sleep -Seconds 10
}

Start-Sleep -Seconds 5; exit
