fx_version "cerulean"
games {"gta5"}

title "Death System"
description "death system"
author "Lithe"
version "v1.0"
lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
    '@es_extended/imports.lua',
}

client_script 'config.lua'
client_script 'client/*.lua'
server_script 'config.lua'
server_script 'server/*.lua'