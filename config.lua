Config = {}

Config.DrawDistance 			  = 100.0
Config.MarkerType    			  = 1
Config.MarkerSize   			  = { x = 1.5, y = 1.5, z = 1.0 }
Config.MarkerColor                = { r = 0, g = 0, p = 255 }
Config.MarkerDeletersColor        = { r = 255, g = 0, b = 0 }


Config.EnableJobBlip              = true 

Config.Locale = 'en'

Config.chatrStations = {

	chatr = {

		Blip = {
			Pos     = { x = 501.21, y = 5604.46, z = 796.9 },
			Sprite  = 377,
			Display = 4,
			Scale   = 1.5,
			Colour  = 0,
		},

		Elevator = {
			{
				Top = { x = 501.21, y = 5604.46, z = 796.9 },
				Down = { x = -0.5, y = 4449.25, z = 2695.96 },
}
		},

},
}


Config.DrawDistance  = 100
Config.Size          = { x = 1.5, y = 1.5, z = 0.5 }
Config.Color         = { r = 0, g = 0, p = 255 }
Config.Type          = 1

Config.LicenseEnable = false -- only turn this on if you are using esx_license
Config.LicensePrice  = 0

Config.Zones = {

	GunShop = {
		Legal = true,
		Items = {},
		Locations = {
			vector3(501.6, 5599.89, 795.50),
		}
	},
}

