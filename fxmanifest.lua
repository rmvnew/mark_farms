fx_version 'cerulean'
game 'gta5'

shared_scripts {
    '@vrp/lib/utils.lua',
    'lib/tunel.lua',
    'config_default.lua'
}

client_scripts {
    
    'client.lua',
}

server_scripts {
   
    'service.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
