# BoostThatThread

Automatically detects the running game process and boosts the priority of all active threads to reduce input latency and improve responsiveness. Includes an optional .exe

# Configuring for Your Game

By default, the script targets Apex Legends (`r5apex_dx12.exe`)

To change the target game:

1. Open the `.ps1` file in a text editor.

2. Find this line:
 
Set your game here
$GameProcessName = "r5apex_dx12"   # Replace with your game's process name (no .exe)
$SteamAppID = "1172470"            # Optional: Replace with your game's Steam ID (if you're unsure how to find the name of your games process, open task manager>details with the game running 

         Example for Valorant: "VALORANT-Win64-Shipping"
         Example for CS2: "cs2"
         Example for Fortnite: "FortniteClient-Win64-Shipping"

3. Save and run the script again.

