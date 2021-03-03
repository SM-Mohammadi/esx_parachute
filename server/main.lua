ESX = nil
local shopItems = {}
local WeaponHandeler

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()

	MySQL.Async.fetchAll('SELECT * FROM parachute', {}, function(result)
		for i=1, #result, 1 do
			if shopItems[result[i].zone] == nil then
				shopItems[result[i].zone] = {}
			end

			table.insert(shopItems[result[i].zone], {
				item  = result[i].item,
				price = result[i].price,
				label = ESX.GetWeaponLabel(result[i].item)
			})
		end

		TriggerClientEvent('sm_chatr:sendShop', -1, shopItems)
	end)

end)

ESX.RegisterServerCallback('sm_chatr:getShop', function(source, cb)
	cb(shopItems)
end)

ESX.RegisterServerCallback('sm_chatr:buyLicense', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.money >= Config.LicensePrice then
		xPlayer.removeMoney(Config.LicensePrice)

		TriggerEvent('esx_license:addLicense', source, 'weapon', function()
			cb(true)
		end)
	else
		TriggerClientEvent('esx:showNotification', source, _U('not_enough'))
		cb(false)
	end
end)

ESX.RegisterServerCallback('sm_chatr:buyWeapon', function(source, cb, weaponName, zone)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = GetPrice(weaponName, zone)

	if price == 0 then
		print(('sm_chatr: %s attempted to buy a unknown weapon!'):format(xPlayer.identifier))
		cb(false)
	end

	if xPlayer.hasWeapon(weaponName) then
		TriggerClientEvent('esx:showNotification', source, _U('already_owned'))
		cb(false)
	else
		if zone == 'BlackWeashop' then

			if xPlayer.money >= price then
				xPlayer.removeMoney(price)
				xPlayer.addWeapon(weaponName, 42)

				TriggerEvent('gangaccount:getGangAccount', WeaponHandeler, function(account)
					account.addMoney(price*0.9)
				end)

				cb(true)
			else
				TriggerClientEvent('esx:showNotification', source, _U('not_enough'))
				cb(false)
			end

		else

			if xPlayer.money >= price then
				xPlayer.removeMoney(price)
				xPlayer.addWeapon(weaponName, 42)

				cb(true)
			else
				TriggerClientEvent('esx:showNotification', source, _U('not_enough'))
				cb(false)
			end
	
		end
	end
end)

function GetPrice(weaponName, zone)
	local price = MySQL.Sync.fetchScalar('SELECT price FROM parachute WHERE zone = @zone AND item = @item', {
		['@zone'] = zone,
		['@item'] = weaponName 
	})

	if price then
		return price
	else
		return 0
	end
end
