local IsDead = false
local animDict = "missarmenian2"
local animName = "drunk_loop"

AddEventHandler('esx:onPlayerDeath', function(data)
    ESX.SetPlayerData('dead', true)
	revivePlayer()
    if Death.PreDeath then
        preDeath()
        progressbarpredeath()
        

    else
        playPassoutAnimation()
        
    end
	mutepma()
	mutesalty()

end)

AddEventHandler('playerSpawned', function(spawn)
    ESX.SetPlayerData('dead', false)
end)


function Notify(message)
    local notifyType = Death.Notify or 'esx' 
    if notifyType == 'esx' then
        ESX.ShowNotification(message)
    elseif notifyType == 'ox' then
        lib.notify({
			title = Death.ServerName,
			description = message,
			type = 'success'
		})
    elseif notifyType == 'custom' then
        CustomNotify(message)
    else
        print('Unknown notification type specified in Death.Notify.')
    end
end


function mutepma()
    if Death.PmaVoice then
        exports['pma-voice']:overrideProximityCheck(function(player)
            return false
        end)
    end
end

function mutesalty()
    if Death.Saltychat then
        local playerId = PlayerId()  -- Make sure playerId is defined
        exports['saltychat']:SetPlayerRadioChannel(playerId, 'none')
    end
end

local stopAnimation = false

function preDeath()
    if Death.PreDeath then
        local indietro = false
        progressbarpredeath()
        ESX.SetPlayerData('dead', true)
        RequestAnimDict('missarmenian2')
        RequestAnimDict('move_injured_ground')
        RequestAnimDict('random@dealgonewrong')
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        local Ncoords = {x = (math.floor((coords.x * 10^1) + 0.5) / (10^1)), y = (math.floor((coords.y * 10^1) + 0.5) / (10^1)), z = (math.floor((coords.z * 10^1) + 0.5) / (10^1)), h = (math.floor((heading * 10^1) + 0.5) / (10^1))}
        local stoppato = false

        ClearPedTasks(ped)
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        ClearPedTasksImmediately(ped)
        SetEntityCoordsNoOffset(ped, Ncoords.x, Ncoords.y, Ncoords.z, false, false, false, true)
        NetworkResurrectLocalPlayer(Ncoords.x, Ncoords.y, Ncoords.z, Ncoords.h, false, false)
        DoScreenFadeOut(300)
        Wait(350)
        DoScreenFadeIn(300)
        TaskPlayAnim(ped, 'random@dealgonewrong', 'idle_a', 8.0, -8.0, -1, 0, 0, 0, 0)

        stopAnimation = false

        Citizen.CreateThread(function()
            while not stopAnimation do
                DisableAllControlActions(0)
                DisableAllControlActions(1)
                DisableAllControlActions(28)
                EnableControlAction(1, 1, true)
                EnableControlAction(1, 2, true)
                EnableControlAction(0, 6, true)
                EnableControlAction(0, 5, true)
                EnableControlAction(0, 33, true)
                EnableControlAction(0, 32, true)

                if IsControlPressed(0, 32) then
                    if not IsEntityPlayingAnim(ped, 'move_injured_ground', 'sidel_loop', 3) then
                        TaskPlayAnim(ped, 'move_injured_ground', 'sidel_loop', 1.0, -8.0, -1, 1, 0, 0, 0, 0)
                    end
                else
                    if not indietro then
                        if not IsEntityPlayingAnim(ped, 'random@dealgonewrong', 'idle_a', 3) then
                            TaskPlayAnim(ped, 'random@dealgonewrong', 'idle_a', 2.0, -8.0, -1, 0, 0, 0, 0)
                        end
                    end
                end

                camRot = Citizen.InvokeNative(0x837765A25378F0BB, 0, Citizen.ResultAsVector())
                SetEntityHeading(ped, camRot.z)

                if IsControlPressed(0, 33) then
                    indietro = true
                    if not IsEntityPlayingAnim(ped, 'move_injured_ground', 'back_loop', 3) then
                        TaskPlayAnim(ped, 'move_injured_ground', 'back_loop', 3.5, -8.0, -1, 1, 0, 0, 0, 0)
                    end
                else
                    indietro = false
                end

                Wait(0)
            end

            -- Clear the animations and re-enable controls when stopping
            ClearPedTasksImmediately(ped)
            EnableAllControlActions(0)
        end)
    end
end

RegisterNetEvent('stopPreAnimation')
AddEventHandler('stopPreAnimation', function()
    stopAnimation = true
end)

RegisterNetEvent("triggerbello")
AddEventHandler("triggerbello", function()
    TriggerEvent("stopPreAnimation")
    TriggerEvent("stopprogress")
    exports.rprogress:Stop()
end)

function playPassoutAnimation()
    local playerPed = PlayerPedId()
    ESX.SetPlayerData('dead', true)
    loadAnimDict(animDict)
    if not IsPedInAnyVehicle(playerPed, false) then
        TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
		DisableControlAction(0, 73, true) 
        TriggerEvent("triggerbello")
        progressbardeath()
    else
        print("You can't perform this animation while in a vehicle.")
    end
end

RegisterNetEvent("ProgressPreDeath")
AddEventHandler("ProgressPreDeath", function()
    progressbardeath()
end)

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

RegisterNetEvent("stopprogress", function()
    lib.cancelProgress()
    exports.rprogress:Stop()
end)

RegisterNetEvent('lithe-deathsystem:useMedikit')
AddEventHandler('lithe-deathsystem:useMedikit', function()
    local playerPed = PlayerPedId()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('lithe-deathsystem:revivePlayer', GetPlayerServerId(closestPlayer))
    else
        Notify(Death.NoOneNearby)
    end
end)

RegisterNetEvent('lithe-deathsystem:revive')
AddEventHandler('lithe-deathsystem:revive', function()
    revivePlayer()
end)

function revivePlayer()
    local playerPed = PlayerPedId()
    ESX.SetPlayerData('dead', false)
    ResurrectPed(playerPed)
    ClearPedTasksImmediately(playerPed)
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    SetPlayerInvincible(playerPed, false)
    ClearPedBloodDamage(playerPed)
    TriggerEvent("stopprogress")
    TriggerEvent("stopPreAnimation")
    exports.rprogress:Stop()

    if Death.PmaVoice then
        exports['pma-voice']:resetProximityCheck()
    end

    if Death.LoseItemsOnDeath then
        TriggerServerEvent("death:removeinv")
    end
    
    if Death.SaltyChat then
        local playerId = PlayerId()
        exports['saltychat']:SetPlayerRadioChannel(playerId, 'default')
    end
end

function revivePlayerHospital()
    local playerPed = PlayerPedId()
    
    ESX.SetPlayerData('dead', false)
    ResurrectPed(playerPed)
    ClearPedTasksImmediately(playerPed)
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    SetPlayerInvincible(playerPed, false)
    ClearPedBloodDamage(playerPed)
    TriggerEvent("stopprogress")
    exports.rprogress:Stop()
    TriggerEvent("stopPreAnimation")
    -- Teleport the player to the hospital coordinates
    local hospitalCoords = Death.RespawnCoords
    SetEntityCoords(playerPed, hospitalCoords.x, hospitalCoords.y, hospitalCoords.z, false, false, false, true)

    -- Reset proximity check for voice systems if applicable
    if Death.PmaVoice then
        exports['pma-voice']:resetProximityCheck()
    end
    if Death.LoseItemsOnDeath then
        TriggerServerEvent("death:removeinv")
    end
    
    if Death.SaltyChat then
        local playerId = PlayerId()
        exports['saltychat']:SetPlayerRadioChannel(playerId, 'default')
    end
end


function progressbarpredeath()
    
    if Death.ProgressBar == 'ox' then
        
        if lib.progressCircle({
            duration = 100000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
            },
        }) then 
            TriggerEvent("stopPreAnimation")
            
            DoScreenFadeOut(300)
            Citizen.Wait(350)
            DoScreenFadeIn(300)
            playPassoutAnimation()
            progressbardeath()
        else 
            print("lascia stare") 
        end
    elseif Death.ProgressBar == 'rprogress' then
        exports.rprogress:Custom({
            Async = true,
            canCancel = false,       -- Allow cancelling
            cancelKey = 178,        -- Custom cancel key
            x = 0.5,                -- Position on x-axis
            y = 0.5,                -- Position on y-axis
            From = 0,               -- Percentage to start from
            To = 100,               -- Percentage to end
            Duration = Death.BleedOutTime,        -- Duration of the progress
            Radius = 60,            -- Radius of the dial
            Stroke = 10,            -- Thickness of the progress dial
            Cap = 'round',           -- or 'round'
            Padding = 0,            -- Padding between the progress dial and the background dial
            MaxAngle = 360,         -- Maximum sweep angle of the dial in degrees
            Rotation = 0,           -- 2D rotation of the dial in degrees
            Width = 300,            -- Width of bar in px if Type = 'linear'
            Height = 40,            -- Height of bar in px if Type = 'linear'
            ShowTimer = true,       -- Shows the timer countdown within the radial dial
            ShowProgress = false,   -- Shows the progress % within the radial dial    
            Easing = "easeLinear",
            Label = Death.LabelPreDeath,
            LabelPosition = "bottom",
            Color = "rgba(255, 255, 255, 1.0)",
            BGColor = "rgba(0, 0, 0, 0.4)",
            DisableControls = {
                Mouse = true,
                Player = true,
                Vehicle = false
            },    
            onStart = function()
             print("iniziato")
            end,
            onComplete = function(cancelled)
                TriggerEvent("stopPreAnimation")
                DoScreenFadeOut(300)
                Citizen.Wait(350)
                DoScreenFadeIn(300)
                playPassoutAnimation()
                progressbardeath()
            end
        })
    end
end



function progressbardeath()
    if Death.ProgressBar == 'ox' then
        if lib.progressCircle({
            duration = 100000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
            },
        }) then 
            DoScreenFadeOut(700)
            Citizen.Wait(750)
            DoScreenFadeIn(700)
           revivePlayerHospital()
        else 
            print("lascia stare") 
        end
    elseif Death.ProgressBar == 'rprogress' then
        exports.rprogress:Custom({
            Async = true,
            canCancel = false,       -- Allow cancelling
            cancelKey = 178,        -- Custom cancel key
            x = 0.5,                -- Position on x-axis
            y = 0.5,                -- Position on y-axis
            From = 0,               -- Percentage to start from
            To = 100,               -- Percentage to end
            Duration = Death.DeathTime,        -- Duration of the progress
            Radius = 60,            -- Radius of the dial
            Stroke = 10,            -- Thickness of the progress dial
            Cap = 'butt',           -- or 'round'
            Padding = 0,            -- Padding between the progress dial and the background dial
            MaxAngle = 360,         -- Maximum sweep angle of the dial in degrees
            Rotation = 0,           -- 2D rotation of the dial in degrees
            Width = 300,            -- Width of bar in px if Type = 'linear'
            Height = 40,            -- Height of bar in px if Type = 'linear'
            ShowTimer = true,       -- Shows the timer countdown within the radial dial
            ShowProgress = false,   -- Shows the progress % within the radial dial    
            Easing = "easeLinear",
            Label = Death.LabelDeath,
            LabelPosition = "bottom",
            Color = "rgba(255, 255, 255, 1.0)",
            BGColor = "rgba(0, 0, 0, 0.4)",
            DisableControls = {
                Mouse = true,
                Player = true,
                Vehicle = false
            },    
            onStart = function()
            end,
            onComplete = function(cancelled)
                DoScreenFadeOut(700)
                Citizen.Wait(750)
                DoScreenFadeIn(700)
               revivePlayerHospital()

            end
        })
    end
end


local animDict = "missarmenian2"
local animName = "drunk_loop"

RegisterCommand(Death.MedicHelpCommand, function()
    if Death.MedicHelp then
        -- Function to check if the player is playing the specified animation
        function isPlayerInAnimation(animDict, animName)
            local playerPed = PlayerPedId()
            return IsEntityPlayingAnim(playerPed, animDict, animName, 3)
        end

        -- Function for the medic progress bar
        function medicoprogbar()
            if Death.ProgressBar == 'ox' then
                if lib.progressCircle({
                    duration = Death.MedicHelpTime,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        car = true,
                    },
                }) then 
                    DoScreenFadeOut(700)
                    Citizen.Wait(750)
                    DoScreenFadeIn(700)
                    revivePlayer()
                else 
                    print("lascia stare") 
                end
            elseif Death.ProgressBar == 'rprogress' then
                exports.rprogress:Stop()
                exports.rprogress:Custom({
                    Async = true,
                    canCancel = false,       -- Allow cancelling
                    cancelKey = 178,        -- Custom cancel key
                    x = 0.5,                -- Position on x-axis
                    y = 0.5,                -- Position on y-axis
                    From = 0,               -- Percentage to start from
                    To = 100,               -- Percentage to end
                    Duration =  Death.MedicHelpTime,        -- Duration of the progress
                    Radius = 60,            -- Radius of the dial
                    Stroke = 10,            -- Thickness of the progress dial
                    Cap = 'butt',           -- or 'round'
                    Padding = 0,            -- Padding between the progress dial and the background dial
                    MaxAngle = 360,         -- Maximum sweep angle of the dial in degrees
                    Rotation = 0,           -- 2D rotation of the dial in degrees
                    Width = 300,            -- Width of bar in px if Type = 'linear'
                    Height = 40,            -- Height of bar in px if Type = 'linear'
                    ShowTimer = true,       -- Shows the timer countdown within the radial dial
                    ShowProgress = false,   -- Shows the progress % within the radial dial    
                    Easing = "easeLinear",
                    Label = Death.LabelMedicHelp,
                    LabelPosition = "bottom",
                    Color = "rgba(255, 255, 255, 1.0)",
                    BGColor = "rgba(0, 0, 0, 0.4)",
                    DisableControls = {
                        Mouse = true,
                        Player = true,
                        Vehicle = false
                    },    
                    onStart = function()
                   
                    end,
                    onComplete = function(cancelled)
                        DoScreenFadeOut(700)
                        Citizen.Wait(750)
                        DoScreenFadeIn(700)
                        revivePlayer()
                    end
                })
            end
        end
        
        -- Check if the player is in the specified animation before starting the process
        if isPlayerInAnimation(animDict, animName) then
            medicoprogbar()
        else
            print("Player is not in the specified animation.")
        end
    else
        print("Medic help is not enabled.")
    end
end)


RegisterNetEvent("callambulance")
AddEventHandler("callambulance", function(coords)
    local coords = GetEntityCoords(GetPlayerPed(-1))

       if Death.GksPhone then
        ESX.TriggerServerCallback('gksphone:namenumber', function(Races)
            local name = Races[2].firstname .. ' ' .. Races[2].lastname
            TriggerServerEvent('gksphone:gkcs:jbmessage', name, Races[1].phone_number, 'Emergency aid notification', '', GPS, 'ambulance')
        end)
       end
       if Death.GCPhone then
        TriggerServerEvent("esx_addons_gcphone:startCall","ambulance","Aiuto sono ferito, Ecco la mia posizione",coords)
       end
       if Death.QuasarPhone then
     TriggerServerEvent('qs-smartphone:server:AddJobMessage', {
        type = 'message',
        message = 'Injured person.'
    })
    Wait(300)
    TriggerServerEvent('qs-smartphone:server:AddJobMessage', {
        type = 'location',
        message = json.encode({
            x = coords.x,
            y = coords.y,
        })
    })
       end
       if Death.LBPhone then
             print("Incoming")
       end
end)

RegisterNetEvent("lithe-death:revivetohospital")
AddEventHandler("lithe-death:revivetohospital", function()
    revivePlayerHospital()
end)

RegisterNetEvent("lithe-death:revive")
AddEventHandler("lithe-death:revive", function()
    revivePlayer()
end)