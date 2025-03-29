local timers = {}
local lastPositions = {}

Citizen.CreateThread(function()
    local isInside = {}

    for i, sphere in ipairs(Config.Spheres) do
        local blip = AddBlipForRadius(sphere.coords.x, sphere.coords.y, sphere.coords.z, sphere.scale)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, sphere.alpha or 255)
    end

    if Config.Debug then
        print("Loaded " .. #Config.Spheres .. " spheres")
    end

    SendNUIMessage({
        action = "setDebug",
        debug = Config.Debug
    })

    while true do
        Citizen.Wait(0)
        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)

        for i, sphere in ipairs(Config.Spheres) do
            local distance = #(playerCoords - sphere.coords)
            local currentInside = distance <= sphere.scale

            DrawMarker(
                28,
                sphere.coords.x, sphere.coords.y, sphere.coords.z,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                sphere.scale, sphere.scale, sphere.scale,
                255, 0, 0, sphere.alpha or 255,
                0,
                0,
                0,
                0,
                nil, nil,
                0
            )

            if currentInside then
                lastPositions[i] = playerCoords
            end

            if timers[i] then
                local elapsed = GetGameTimer() - timers[i].startTime
                if elapsed >= timers[i].duration then
                    if Config.Debug then
                        print("Timer expired for sphere " .. i)
                    end
                    timers[i] = nil
                    lastPositions[i] = nil
                elseif not currentInside then
                    if Config.Debug then
                        print("Teleporting player back to sphere " .. i)
                    end
                    local lastPos = lastPositions[i] or sphere.coords
                    local vectorToCenter = sphere.coords - lastPos
                    local distToCenter = #vectorToCenter
                    local dir = distToCenter > 0 and vectorToCenter / distToCenter or vector3(0, 0, 0)
                    local offset = 2.0
                    local newPos = lastPos + dir * offset
                    if #(newPos - sphere.coords) > sphere.scale then
                        newPos = sphere.coords + dir * (sphere.scale * 0.8)
                    end
                    SetEntityCoords(playerPed, newPos.x, newPos.y, newPos.z, false, false, false, true)
                    playerCoords = GetEntityCoords(playerPed)
                    distance = #(playerCoords - sphere.coords)
                    currentInside = distance <= sphere.scale
                end
            end

            if isInside[i] == nil then
                isInside[i] = currentInside
            else
                if currentInside and not isInside[i] then
                    if Config.Debug then
                        print("Entered sphere " .. i)
                    end
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
                    if Config.Debug then
                        print("Left sphere " .. i)
                    end
                end
                isInside[i] = currentInside
            end
        end

        local isShooting = IsPedShooting(playerPed)
        local isPunching = IsPedInMeleeCombat(playerPed) and GetSelectedPedWeapon(playerPed) == GetHashKey("WEAPON_UNARMED")
        if isShooting or isPunching then
            for i, sphere in ipairs(Config.Spheres) do
                if timers[i] and (GetGameTimer() - timers[i].startTime < timers[i].duration) then
                    if Config.Debug then
                        print("Resetting timer for sphere " .. i .. " due to " .. (isShooting and "shooting" or "punching"))
                    end
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