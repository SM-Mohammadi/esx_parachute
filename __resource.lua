description 'sm_chatr'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@essentialmode/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'config.lua',
	'server/main.lua',
}

client_scripts {
	'@essentialmode/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'config.lua',
	'client/main.lua'
}

dependencies {
	'essentialmode',
	'esx_billing'
}
