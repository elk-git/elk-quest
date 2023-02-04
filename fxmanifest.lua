fx_version "cerulean"
game "rdr3"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

shared_scripts {'config.lua','@qr-core/shared/locale.lua', "locales/en.lua"}
client_script  "client/main.lua"
server_scripts {'@oxmysql/lib/MySQL.lua', "server/main.lua"}
files {'html/index.html', 'html/assets/*.js', 'html/assets/*.css'}
dependencies {'qr-core'}
 ui_page "html/index.html"

-- ui_page "http://localhost:5173"

-- change row 5 to prefered language.