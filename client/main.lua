local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local LastEntity              = nil
local CurrentActionMsg        = ''
local blipsCops               = {}


ESX                           = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

function startAnim(lib, anim)
	Citizen.CreateThread(function()
		RequestAnimDict(lib)
		while not HasAnimDictLoaded( lib) do
			Citizen.Wait(1)
		end

		TaskPlayAnim(GetPlayerPed(-1), lib ,anim ,8.0, -8.0, -1, 0, 0, false, false, false )
	end)
end

function TeleportFadeEffect(entity, coords)
	Citizen.CreateThread(function()
		startAnim("move_m@hiking", "idle", "Hiking")
		DoScreenFadeOut(2400)

		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		ESX.Game.Teleport(entity, coords, function()
			DoScreenFadeIn(7000)
			SetFollowPedCamViewMode(4)
		end)
	end)
end


function OpenElevator(station, partNum)

	local elements = {
		--{ label = _U('elevator_top'), value = 'elevator_top' },
		{ label = _U('elevator_down'), value = 'elevator_down' },
		{ label = _U('elevator_mohem'), value = 'elevator_mohem' },
		{ label = _U('elevator_Bastan'), value = 'elevator_Bastan' },
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'elevator', {
		title    = _U('elevator'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'elevator_down' then
			TeleportFadeEffect(PlayerPedId(), Config.chatrStations[station].Elevator[partNum].Down)
		end
		menu.close()

	end, function(data, menu)
		menu.close()
		
		CurrentAction     = 'menu_elevator'
		CurrentActionMsg  = _U('open_elevator')
		CurrentActionData = {}
	end)
end


AddEventHandler('sm_chatr:hasExitedMarker', function(station, part, partNum)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

AddEventHandler('sm_chatr:hasEnteredEntityZone', function(entity)
	local playerPed = PlayerPedId()

	if PlayerData.job ~= nil and PlayerData.job.name == 'fbi' and IsPedOnFoot(playerPed) then
		CurrentAction     = 'remove_entity'
		CurrentActionMsg  = _U('remove_prop')
		CurrentActionData = {entity = entity}
	end

	if GetEntityModel(entity) == GetHashKey('p_ld_stinger_s') then
		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed)

			for i=0, 7, 1 do
				SetVehicleTyreBurst(vehicle, i, true, 1000)
			end
		end
	end
end)

AddEventHandler('sm_chatr:hasExitedEntityZone', function(entity)
	if CurrentAction == 'remove_entity' then
		CurrentAction = nil
	end
end)




AddEventHandler('sm_chatr:hasEnteredMarker', function(station, part, partNum)

	if part == 'Elevator' then

		CurrentAction     = 'menu_elevator'
		CurrentActionMsg  = _U('open_elevator')
		CurrentActionData = {station = station, partNum = partNum}

	end

end)



-- Create blips
Citizen.CreateThread(function()

	for k,v in pairs(Config.chatrStations) do
		local blip = AddBlipForCoord(v.Blip.Pos.x, v.Blip.Pos.y, v.Blip.Pos.z)

		SetBlipSprite (blip, v.Blip.Sprite)
		SetBlipDisplay(blip, v.Blip.Display)
		SetBlipScale  (blip, v.Blip.Scale)
		SetBlipColour (blip, v.Blip.Colour)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('map_blip'))
		EndTextCommandSetBlipName(blip)
	end

end)

-- Display markers
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(1)

			local playerPed = PlayerPedId()
			local coords    = GetEntityCoords(playerPed)

			for k,v in pairs(Config.chatrStations) do

				for i=1, #v.Elevator, 1 do
					if GetDistanceBetweenCoords(coords, v.Elevator[i].Top.x, v.Elevator[i].Top.y, v.Elevator[i].Top.z, true) < Config.DrawDistance then
						DrawMarker(Config.MarkerType, v.Elevator[i].Top.x, v.Elevator[i].Top.y, v.Elevator[i].Top.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.p, 100, false, true, 2, false, false, false, false)
					end
				end

			end

	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()

	while true do

		Citizen.Wait(10)


			local playerPed      = PlayerPedId()
			local coords         = GetEntityCoords(playerPed)
			local isInMarker     = false
			local currentStation = nil
			local currentPart    = nil
			local currentPartNum = nil

			for k,v in pairs(Config.chatrStations) do


				for i=1, #v.Elevator, 1 do
					if GetDistanceBetweenCoords(coords, v.Elevator[i].Top.x, v.Elevator[i].Top.y, v.Elevator[i].Top.z, true) < Config.MarkerSize.x then
						isInMarker     = true
						currentStation = k
						currentPart    = 'Elevator'
						currentPartNum = i
					end

					if GetDistanceBetweenCoords(coords, v.Elevator[i].Down.x, v.Elevator[i].Down.y, v.Elevator[i].Down.z, true) < Config.MarkerSize.x then
						isInMarker     = true
						currentStation = k
						currentPart    = 'Elevator'
						currentPartNum = i
					end

				end

			end

			local hasExited = false

			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then

				if
					(LastStation ~= nil and LastPart ~= nil and LastPartNum ~= nil) and
					(LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
				then
					TriggerEvent('sm_chatr:hasExitedMarker', LastStation, LastPart, LastPartNum)
					hasExited = true
				end

				HasAlreadyEnteredMarker = true
				LastStation             = currentStation
				LastPart                = currentPart
				LastPartNum             = currentPartNum

				TriggerEvent('sm_chatr:hasEnteredMarker', currentStation, currentPart, currentPartNum)
			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('sm_chatr:hasExitedMarker', LastStation, LastPart, LastPartNum)
			end

	end
end)


-- Key Controls
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(10)

		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, Keys['E']) then

			if CurrentAction == 'menu_elevator' then
				OpenElevator(CurrentActionData.station, CurrentActionData.partNum)
			end
				
				CurrentAction = nil
			end
		end -- CurrentAction end
	end
end)

-- Create blip for colleagues
function createBlip(id)
	local ped = GetPlayerPed(id)
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		SetBlipNameToPlayerName(blip, id) -- update blip name
		SetBlipScale(blip, 1.8) -- set scale
		SetBlipAsShortRange(blip, true)
		
		table.insert(blipsCops, blip) -- add blip to array so we can remove it later
	end
end


local HasAlreadyEnteredMarker = false
local LastZone = nil
local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}
local ShopOpen = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	ESX.TriggerServerCallback('sm_chatr:getShop', function(shopItems)
		for k,v in pairs(shopItems) do
			Config.Zones[k].Items = v
		end
	end)
end)

RegisterNetEvent('sm_chatr:sendShop')
AddEventHandler('sm_chatr:sendShop', function(shopItems)
	for k,v in pairs(shopItems) do
		Config.Zones[k].Items = v
	end
end)


function OpenShopMenu(zone)
	local elements = {}
	ShopOpen = true

	for i=1, #Config.Zones[zone].Items, 1 do
		local item = Config.Zones[zone].Items[i]

		table.insert(elements, {
			label = ('%s - <span style="color: green;">%s</span>'):format(item.label, _U('shop_menu_item', ESX.Math.GroupDigits(item.price))),
			price = item.price,
			weaponName = item.item
		})
	end

	ESX.UI.Menu.CloseAll()
	PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {
		title = _U('shop_menu_title'),
		align = 'top-right',
		elements = elements
	}, function(data, menu)
		ESX.TriggerServerCallback('sm_chatr:buyWeapon', function(bought)
		end, data.current.weaponName, zone)
	end, function(data, menu)
		PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
		ShopOpen = false
		menu.close()
	end)
end


AddEventHandler('sm_chatr:hasEnteredMarker', function(zone)
	if zone == 'GunShop' then
		CurrentAction     = 'shop_menu'
		CurrentActionMsg  = _U('shop_menu_prompt')
		CurrentActionData = { zone = zone }
	end
end)

AddEventHandler('sm_chatr:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if ShopOpen then
			ESX.UI.Menu.CloseAll()
		end
	end
end)


-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones) do
			for i = 1, #v.Locations, 1 do
				if (Config.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Locations[i], true) < Config.DrawDistance) then
					DrawMarker(Config.Type, v.Locations[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.p, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())
		local isInMarker, currentZone = false, nil

		for k,v in pairs(Config.Zones) do
			for i=1, #v.Locations, 1 do
				if GetDistanceBetweenCoords(coords, v.Locations[i], true) < Config.Size.x then
					isInMarker, ShopItems, currentZone, LastZone = true, v.Items, k, k
				end
			end
		end
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('sm_chatr:hasEnteredMarker', currentZone)
		end
		
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('sm_chatr:hasExitedMarker', LastZone)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, Keys['E']) then

				if CurrentAction == 'shop_menu' then
					if Config.Zones[CurrentActionData.zone].Legal then
						OpenShopMenu(CurrentActionData.zone)
					else
						OpenShopMenu(CurrentActionData.zone)
					end
				end

				CurrentAction = nil
			end
		end
	end
end)
