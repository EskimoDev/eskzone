local timers = {} -- Table to track timers for each sphere

Citizen.CreateThread(function()
    local isInside = {} -- Table to track player's state for each sphere
    while true do
        Citizen.Wait(0) -- Run every frame
        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)

        for i, sphere in ipairs(Config.Spheres) do
            -- Draw the sphere with configurable transparency
            DrawMarker(
                28,                          -- Marker type (sphere)
                sphere.coords.x, sphere.coords.y, sphere.coords.z, -- Position
                0.0, 0.0, 0.0,              -- Direction (not used)
                0.0, 0.0, 0.0,              -- Rotation (not used)
                sphere.scale, sphere.scale, sphere.scale, -- Radius
                255, 0, 0, sphere.alpha or 255, -- Red color with alpha (default 255 if not set)
                0,                          -- bobUpAndDown: 0 (false)
                0,                          -- faceCamera: 0 (false)
                0,                          -- p19: unused, set to 0
                0,                          -- rotate: 0 (false)
                nil, nil,                   -- textureDict, textureName: nil (no texture)
                0                           -- drawOnEnts: 0 (false)
            )

            -- Detect if player is inside the sphere
            local distance = #(playerCoords - sphere.coords)
            local currentInside = distance <= sphere.scale

            -- Initialize state for the sphere if not set
            if isInside[i] == nil then
                isInside[i] = currentInside
            else
                -- Check for state change and handle timer
                if currentInside and not isInside[i] then
                    print("Entered sphere " .. i)
                    -- Start the timer for this sphere
                    if not timers[i] then
                        timers[i] = {
                            startTime = GetGameTimer(),
                            duration = sphere.timerDuration * 1000 -- Convert to milliseconds
                        }
                        -- Send message to NUI with position included
                        SendNUIMessage({
                            action = "startTimer",
                            index = i,
                            duration = sphere.timerDuration,
                            position = Config.TimerPosition
                        })
                    end
                elseif not currentInside and isInside[i] then
                    print("Left sphere " .. i)
                    -- Stop the timer for this sphere
                    if timers[i] then
                        timers[i] = nil
                        SendNUIMessage({action = "stopTimer", index = i})
                    end
                end
                -- Update the state
                isInside[i] = currentInside
            end
        end

        -- Check for shooting or punching and reset timers if inside a sphere
        local isShooting = IsPedShooting(playerPed)
        local isPunching = IsPedInMeleeCombat(playerPed) and GetSelectedPedWeapon(playerPed) == GetHashKey("WEAPON_UNARMED")
        if isShooting or isPunching then
            for i, sphere in ipairs(Config.Spheres) do
                if isInside[i] and timers[i] then
                    timers[i].startTime = GetGameTimer()
                    SendNUIMessage({
                        action = "startTimer",
                        index = i,
                        duration = sphere.timerDuration,
                        position = Config.TimerPosition
                    })
                end
            end
        end
    end
end)