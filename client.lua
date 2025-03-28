local timers = {} -- Table to track timers for each sphere
local timerExpired = {} -- Table to track if the timer has expired for each sphere
local isInside = {} -- Table to track player's state for each sphere

Citizen.CreateThread(function()
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

            -- Handle timer logic
            if timers[i] then
                if GetGameTimer() - timers[i].startTime < timers[i].duration then
                    -- Timer is active
                    if not currentInside then
                        -- Teleport player back inside the sphere
                        local direction = (playerCoords - sphere.coords) / distance
                        local newPos = sphere.coords + direction * (sphere.scale - 0.1) -- Slightly inside boundary
                        SetEntityCoords(playerPed, newPos.x, newPos.y, newPos.z, false, false, false, true)
                        currentInside = true -- Update after teleport
                    end
                else
                    -- Timer has expired
                    if not timerExpired[i] then
                        timerExpired[i] = true
                    end
                end
            end

            -- Handle entering and leaving the sphere
            if currentInside and not isInside[i] then
                -- Entering the sphere
                print("Entered sphere " .. i)
                if not timers[i] then
                    timers[i] = {
                        startTime = GetGameTimer(),
                        duration = sphere.timerDuration * 1000 -- Convert to milliseconds
                    }
                    timerExpired[i] = false
                    SendNUIMessage({
                        action = "startTimer",
                        index = i,
                        duration = sphere.timerDuration,
                        position = Config.TimerPosition
                    })
                end
            elseif not currentInside and isInside[i] then
                -- Leaving the sphere
                if timerExpired[i] then
                    print("Left sphere " .. i)
                    timers[i] = nil
                    timerExpired[i] = false
                    SendNUIMessage({action = "stopTimer", index = i})
                end
            end

            -- Update the state
            isInside[i] = currentInside
        end

        -- Check for shooting or punching and reset timers if inside a sphere and timer is active
        local isShooting = IsPedShooting(playerPed)
        local isPunching = IsPedInMeleeCombat(playerPed) and GetSelectedPedWeapon(playerPed) == GetHashKey("WEAPON_UNARMED")
        if isShooting or isPunching then
            for i, sphere in ipairs(Config.Spheres) do
                if isInside[i] and timers[i] and (GetGameTimer() - timers[i].startTime < timers[i].duration) then
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