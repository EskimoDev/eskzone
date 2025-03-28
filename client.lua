local timers = {} -- Table to track timers for each sphere
local lastPositions = {} -- Table to store last position inside each sphere

Citizen.CreateThread(function()
    local isInside = {} -- Table to track player's state for each sphere
    while true do
        Citizen.Wait(0) -- Run every frame
        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)

        -- Handle timer expiration and teleportation
        for i, sphere in ipairs(Config.Spheres) do
            local distance = #(playerCoords - sphere.coords)
            local currentInside = distance <= sphere.scale

            -- Draw the sphere
            DrawMarker(
                28,                          -- Marker type (sphere)
                sphere.coords.x, sphere.coords.y, sphere.coords.z, -- Position
                0.0, 0.0, 0.0,              -- Direction (not used)
                0.0, 0.0, 0.0,              -- Rotation (not used)
                sphere.scale, sphere.scale, sphere.scale, -- Radius
                255, 0, 0, sphere.alpha or 255, -- Red color with alpha
                0,                          -- bobUpAndDown: 0 (false)
                0,                          -- faceCamera: 0 (false)
                0,                          -- p19: unused
                0,                          -- rotate: 0 (false)
                nil, nil,                   -- textureDict, textureName: nil
                0                           -- drawOnEnts: 0 (false)
            )

            -- Update last position if inside
            if currentInside then
                lastPositions[i] = playerCoords
            end

            -- Check timer status
            if timers[i] then
                local elapsed = GetGameTimer() - timers[i].startTime
                if elapsed >= timers[i].duration then
                    -- Timer expired
                    timers[i] = nil
                    lastPositions[i] = nil -- Clear last position
                elseif distance > sphere.scale then
                    -- Timer active and player outside, teleport back
                    local lastPos = lastPositions[i] or sphere.coords -- Fallback to center if no last position
                    -- Calculate direction from last position to center
                    local vectorToCenter = sphere.coords - lastPos
                    local distToCenter = #vectorToCenter
                    local dir = distToCenter > 0 and vectorToCenter / distToCenter or vector3(0, 0, 0)
                    -- Move 2 units further in from the last position towards the center
                    local offset = 2.0 -- Adjust 2 units inward
                    local newPos = lastPos + dir * offset
                    -- Ensure the new position is within the sphere
                    if #(newPos - sphere.coords) > sphere.scale then
                        newPos = sphere.coords + dir * (sphere.scale * 0.8) -- Fallback to 80% radius
                    end
                    SetEntityCoords(playerPed, newPos.x, newPos.y, newPos.z, false, false, false, true)
                    playerCoords = GetEntityCoords(playerPed) -- Update coords after teleport
                end
            end

            -- Handle entering and leaving
            if isInside[i] == nil then
                isInside[i] = currentInside
            else
                if currentInside and not isInside[i] then
                    print("Entered sphere " .. i)
                    timers[i] = {
                        startTime = GetGameTimer(),
                        duration = sphere.timerDuration * 1000
                    }
                    SendNUIMessage({
                        action = "startTimer",
                        index = i,
                        duration = sphere.timerDuration,
                        position = Config.TimerPosition
                    })
                elseif not currentInside and isInside[i] then
                    print("Left sphere " .. i)
                    -- Timer continues, no stop here
                end
                isInside[i] = currentInside
            end
        end

        -- Reset timer on shooting or punching
        local isShooting = IsPedShooting(playerPed)
        local isPunching = IsPedInMeleeCombat(playerPed) and GetSelectedPedWeapon(playerPed) == GetHashKey("WEAPON_UNARMED")
        if isShooting or isPunching then
            for i, sphere in ipairs(Config.Spheres) do
                if timers[i] and (GetGameTimer() - timers[i].startTime < timers[i].duration) then
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