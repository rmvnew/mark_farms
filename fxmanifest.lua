fx_version 'cerulean'
game 'gta5'



client_scripts {
    '@vrp/lib/utils.lua',
    'config_default.lua',
    'client.lua',
}

server_scripts {
    '@vrp/lib/utils.lua',
    'config_default.lua',
    'service.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
