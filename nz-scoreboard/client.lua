ESX = nil

local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
    
    Citizen.Wait(2000)
    ESX.TriggerServerCallback('esx_scoreboard:getConnectedPlayers', function(connectedPlayers)
		UpdatePlayerTable(connectedPlayers)
	end)
end)

local changed

-- Code

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()

    ESX.TriggerServerCallback('qb-scoreboard:server:GetConfig', function(config)
        Config.IllegalActions = config
    end)
end)

local scoreboardOpen = false

DrawText3D = function(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

GetClosestPlayer = function()
    local closestPlayers = ESX.Game.GetClosestPlayer()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(GetPlayerPed(-1))

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
	end

	return closestPlayer, closestDistance
end


GetPlayers = function()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            table.insert(players, player)
        end
    end
    return players
end

GetPlayersFromCoords = function(coords, distance)
    local players = GetPlayers()
    local closePlayers = {}


    if coords == nil then
		coords = GetEntityCoords(GetPlayerPed(-1))
    end


    if distance == nil then
        distance = 5.0
    end
    for _, player in pairs(players) do
		local target = GetPlayerPed(player)
		local targetCoords = GetEntityCoords(target)
		local targetdistance = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)
		if targetdistance <= distance then
			table.insert(closePlayers, player)
		end
    end
    
    return closePlayers
end

function UpdatePlayerTable(connectedPlayers)
	local formattedPlayerList, num = {}, 1
    local ems, police, cardealer, mechanic, groove, import, ammu, taxi, staff, players = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  

	for k,v in pairs(connectedPlayers) do

		if num == 1 then
			table.insert(formattedPlayerList, ('<tr><td>%s</td><td>%s</td><td>%s</td>'):format(v.name, v.id, v.ping))
			num = 2
		elseif num == 2 then
			table.insert(formattedPlayerList, ('<td>%s</td><td>%s</td><td>%s</td></tr>'):format(v.name, v.id, v.ping))
			num = 1
		end

		players = players + 1

		if v.job == 'ambulance' then
			ems = ems + 1
		elseif v.job == 'police' or v.job == 'fbi' or v.job == 'jandarma' then
			police = police + 1
		elseif v.job == 'cardealer' then
			cardealer = cardealer + 1
		elseif v.job == 'mecano' then
			mechanic = mechanic + 1
		elseif v.job == 'import' then
			import = import + 1
		elseif v.job == 'groove' then
			groove = groove + 1
		elseif v.job == 'ammu' then
			ammu = ammu + 1
		elseif v.job == 'taxi' then
            taxi = taxi + 1
        end
    end
    
	if num == 1 then
		table.insert(formattedPlayerList, '</tr>')
	end

	SendNUIMessage({
		action = 'updatePlayerJobs',
		jobs   = {ems = ems, police = police, cardealer = cardealer, mechanic = mechanic, import = import, groove = groove,ammu = ammu, taxi = taxi, staff = staff, player_count = players}
	})
end

RegisterNetEvent('esx_scoreboard:updateConnectedPlayers')
AddEventHandler('esx_scoreboard:updateConnectedPlayers', function(connectedPlayers)
	UpdatePlayerTable(connectedPlayers)
end)
local lvJob

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    while true do
        Citizen.Wait(1)
        local isActivatorPressed = IsControlJustPressed(0, 213)
        local isSecondaryPressed =  IsControlPressed(0, 21)
        if isActivatorPressed and isSecondaryPressed then
            if not scoreboardOpen then
                ESX.TriggerServerCallback('qb-scoreboard:server:GetActiveCops', function(cops)
                    Config.CurrentCops = cops

                    if changed then
                        SendNUIMessage({
                            action = "open",
                            players = GetCurrentPlayers(),
                            maxPlayers = Config.MaxPlayers,
                            requiredCops = Config.IllegalActions,
                            currentCops = Config.CurrentCops,
                            job = lvJob,
                            
                        })
                        scoreboardOpen = true
                        changed = false
                    end
                    Citizen.Wait(250)
                end)
            end
        end

        if isActivatorPressed and isSecondaryPressed then
            if scoreboardOpen then
                SendNUIMessage({
                    action = "close",
                })
                scoreboardOpen = false

            end
            
        end


        if scoreboardOpen then
            for _, player in pairs(GetPlayersFromCoords(GetEntityCoords(GetPlayerPed(-1)), 10.0)) do
                local PlayerId = GetPlayerServerId(player)
                local PlayerPed = GetPlayerPed(player)
                local PlayerName = GetPlayerName(player)
                local PlayerCoords = GetEntityCoords(PlayerPed)


                if Config.showIdPlayer then
                    DrawText3D(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 1.0, '['..PlayerId..']')
                end
            end
        end



		if IsPauseMenuActive() and not IsPaused then
			IsPaused = true
			SendNUIMessage({
				action  = 'close'
			})
		elseif not IsPauseMenuActive() and IsPaused then
			IsPaused = false
		end
        
    end
end)



Citizen.CreateThread(function()
    Citizen.Wait(2000)
	while true do
        Citizen.Wait(1000)
        
		TriggerServerEvent("getJob")
		changed = true

	end
end)

function GetCurrentPlayers()
    local TotalPlayers = 0

    for _, player in ipairs(GetActivePlayers()) do
        TotalPlayers = TotalPlayers + 1
    end

    return TotalPlayers
end


RegisterNetEvent('qb-scoreboard:client:SetActivityBusy')
AddEventHandler('qb-scoreboard:client:SetActivityBusy', function(activity, busy)
    Config.IllegalActions[activity].busy = busy
end)


RegisterNetEvent('nk_scoreboard:attivatore')
AddEventHandler('nk_scoreboard:attivatore', function(info)

    SendNUIMessage({ action = 'setText', id = 'job', value = info['job'] })
    
    TriggerEvent('esx:getSharedObject', function(obj)
		ESX = obj
		ESX.PlayerData = ESX.GetPlayerData()
    end)
end)

RegisterNetEvent ("returnJob")
AddEventHandler("returnJob", function (jobg)
	lvJob = jobg
end)