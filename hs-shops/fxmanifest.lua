fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'hs-shops-modern'
author 'HS Store'
description 'Modern Arabic QBCore shop UI with qb-target and greeting audio.'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts { 'config.lua' }
client_scripts { 'client.lua' }
server_scripts { 'server.lua' }

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/sounds/*',
}

dependencies {
    'qb-core',
    'qb-target',
}
