# eskzone

A simple redzone script that enables a combat timer when entered, stopping players from leaving until it ends.

The combat timer also resets upon combat, both gun and melee.

Currently running at 0.04ms

[Demo](https://streamable.com/08cl61 "@embed").


## Configuration

The script is configured via the `config.lua` file. Below are the available options:

- **`Config.TimerPosition`**  
  Sets the position of the timer on the screen.  
  **Possible values**: `"bottom-left"`, `"bottom"`, `"bottom-right"`, `"right"`, `"top-right"`, `"top"`, `"top-left"`, `"left"`.  
  **Default**: `"left"`.

- **`Config.Debug`**  
  If set to `true`, the script prints debug messages to the console, useful for troubleshooting.  
  **Default**: `true`.  
  **Note**: if you don't know what this is or means, you probably shouldn't touch it.


- **`Config.Spheres`**  
  A table defining the combat zones. Each entry represents a spherical zone with the following properties:  
  - `coords`: The center of the sphere as a `vector3(x, y, z)`.  
  - `scale`: The radius of the sphere (in meters).  
  - `alpha`: The transparency of the blip and sphere marker (0-255, optional, default 255).  
  - `timerDuration`: The timer duration in seconds.  

  **Example**:
  ```lua
  Config.Spheres = {
      {coords = vector3(231.8257, -874.4304, 30.4921), scale = 5.0, alpha = 128, timerDuration = 60},
      
  }
  ```

## How It Works

- **Combat Zones**: The script creates blips on the map for each zone defined in `Config.Spheres` and visualizes them with semi-transparent red spheres in the game world.
- **Timer Activation**: When a player enters a zone, a timer starts, displayed on-screen at the position set in `Config.TimerPosition`.
- **Teleportation**: If the player tries to leave the zone before the timer expires, they are teleported back to a position inside the zone (near their last valid position or the center).
- **Combat Reset**: Shooting or punching inside the zone resets the timer to its full duration.
- **Timer Completion**: Once the timer expires, the player can leave the zone freely without being teleported back.

## DISCLAIMER

This script is provided free of charge for personal/server use and modification. You are welcome to edit and adapt it as you see fit for your own purposes. However, redistribution or selling of this script, in whole or in part, is strictly prohibited without explicit permission.
