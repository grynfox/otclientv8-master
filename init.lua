-- CONFIG
APP_NAME = "Tibia" -- important, change it, it's name for config dir and files in appdata
APP_VERSION = ""      -- client version for updater and login to identify outdated client

-- If you don't use updater or other service, set it to updater = ""
Services = {
  website = "http://otclient.ovh", -- currently not used
  updater = "http://otclient.ovh/api/updater.php",
  news = "http://otclient.ovh/api/news.php",
  stats = "",
  crash = "http://otclient.ovh/api/crash.php",
  feedback = "http://otclient.ovh/api/feedback.php"
}

-- Servers accept http login url or ip:
Servers = {
  OTClientV8 = "177.234.152.26:7171:1100",
  --OTClientV8proxy = "177.234.152.26:7171",
  --OTClientV8classic = "177.234.152.26:7171",
  --OTClientV8cwithfeatures = "177.234.152.26:7171",
  --OTClientV8Test = "177.234.152.26:7171"
}
ALLOW_CUSTOM_SERVERS = false -- if true it shows option ANOTHER on server list
-- CONFIG END

-- print first terminal message
--g_logger.info(os.date("== application started at %b %d %Y %X"))
--g_logger.info(g_app.getName() .. ' ' .. g_app.getVersion() .. ' rev ' .. g_app.getBuildRevision() .. ' (' .. g_app.getBuildCommit() .. ') made by ' .. g_app.getAuthor() .. ' built on ' .. g_app.getBuildDate() .. ' for arch ' .. g_app.getBuildArch())

if not g_resources.directoryExists("/data") then
  g_logger.fatal("Data dir doesn't exist.")
end

if not g_resources.directoryExists("/modules") then
  g_logger.fatal("Modules dir doesn't exist.")
end

-- send and delete crash report if exist
if Services.crash ~= nil and Services.crash:len() > 4 then
  local crashLog = g_resources.readCrashLog(false)
  local crashLogTxt = g_resources.readCrashLog(true)
  local normalLog = g_logger.getLastLog()
  local crashed = false
  if crashLog:len() > 0 then
    g_http.post(Services.crash .. "?txt=0", crashLog)
    crashed = true
  end
  if crashLogTxt:len() > 0 then
    g_http.post(Services.crash .. "?txt=1", crashLogTxt)
    crashed = true
  end
  if crashed and normalLog:len() > 0 then
    g_http.post(Services.crash .. "?txt=2", normalLog)
  end
  g_resources.deleteCrashLog()
end

-- settings
g_configs.loadSettings("/config.otml")

-- load mods
g_modules.discoverModules()

-- libraries modules 0-99
g_modules.autoLoadModules(99)
g_modules.ensureModuleLoaded("corelib")
g_modules.ensureModuleLoaded("gamelib")

-- client modules 100-499
g_modules.autoLoadModules(499)
g_modules.ensureModuleLoaded("client")

-- game modules 500-999
g_modules.autoLoadModules(999)
g_modules.ensureModuleLoaded("game_interface")

-- mods 1000-9999
g_modules.autoLoadModules(9999)