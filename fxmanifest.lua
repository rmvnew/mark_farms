fx_version 'cerulean'
game 'gta5'

shared_scripts {
    '@vrp/lib/utils.lua',
    'lib/**',
    'config_default.lua'
}

client_scripts {
    'tunnel.lua', -- Adiciona o túnel antes do client.lua
    'client.lua',
}

server_scripts {
    'tunnel.lua', -- Adiciona o túnel antes do service.lua
    'service.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
