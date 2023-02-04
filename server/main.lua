local QRCore = exports['qr-core']:GetCoreObject()

RegisterNetEvent('elkq:server:questDone', function(cash)
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)

        -- Player.Functions.AddItem("cattleman", 1, false, info)
        Player.Functions.AddMoney('cash', cash)
    
end)

RegisterNetEvent('elkq:server:questCooldownSet', function()

    local Player = QRCore.Functions.GetPlayer(source)
    local result = MySQL.scalar.await('SELECT citizenid FROM `elk-quest` WHERE citizenid = ?', {Player.PlayerData.citizenid})
    if not result then
    MySQL.insert(
    "INSERT INTO `elk-quest` (citizenid, timestamp) VALUES (:citizenid, :timestamp)",
    {
        citizenid = Player.PlayerData.citizenid,
        timestamp = os.time()

})
elseif result then 
    MySQL.Async.execute(
        'UPDATE `elk-quest` SET timestamp = ? WHERE citizenid = ?', {os.time(), Player.PlayerData.citizenid}
    )
end
end)


QRCore.Functions.CreateCallback('elkq:server:questCheck', function(source, cb, cdt, cdm)
    local Player =  QRCore.Functions.GetPlayer(source)
    local result = MySQL.scalar.await('SELECT citizenid FROM `elk-quest` WHERE citizenid = ?', {Player.PlayerData.citizenid})

   -- avrundade timmar är math.floor(((time[1].timestamp + Config.Cooldown) - os.time() ) / 60 / 60)
   -- icke avrundande timmar är ((time[1].timestamp + Config.Cooldown) - os.time() ) / 60 / 60

    if result then
   local time =  MySQL.Sync.fetchAll(
    'SELECT timestamp FROM `elk-quest` WHERE citizenid = ?',
    {Player.PlayerData.citizenid}
    )

    if  os.time() - time[1].timestamp  > Config.Cooldown then
    cb(true)
    else  cb(false, math.floor(((time[1].timestamp + Config.Cooldown) - os.time() ) / 60 / 60), math.ceil(((((time[1].timestamp + Config.Cooldown) - os.time() ) / 60 / 60) - (math.floor(((time[1].timestamp + Config.Cooldown) - os.time() ) / 60 / 60))) * 60 ))
        
        
    end

    elseif not result then
    cb(true)
    end

end)