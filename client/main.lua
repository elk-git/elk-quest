local QRCore = exports['qr-core']:GetCoreObject()
local activeUppdrag = false
local missionOne = false
local onCooldown = false
local isDone = false
local win = false
local missionTwo = false
local optionsReel = {
 
    {
        
        label = Lang:t('start'),
    
        action = function()
            startMissionCheck()

            
    end
    
    }, 


    
    

}
-- Get ped from config
local model = GetHashKey(Config.Ped)

-- Create ped on map

CreateThread(function()
    while (not HasModelLoaded(model)) do
        RequestModel(model)
        Wait(10)
    end
    local npc = CreatePed(model, Config.PedX , Config.PedY, Config.PedZ - 1 , Config.PedHeading, true, true, 0, 0)
    -- -366.77,
    while not DoesEntityExist(npc) do Wait(300) end
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    Wait(100)
    SetEntityCanBeDamagedByRelationshipGroup(npc, false, PLAYER)
    SetEntityAsMissionEntity(npc, true, true)
    exports['qr-target']:AddTargetEntity(npc, {
        options = optionsReel,
        distance = 2.5
    })

    -- Set gps for part 1

    function setCoordsOne()
        local coordsOne = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, Config.QuestX, Config.QuestY, Config.QuestZ)
        SetBlipSprite(coordsOne, 1475879922, 1)
        SetBlipScale(coordsOne, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, coordsOne, Lang:t('mission'))
        Citizen.InvokeNative(0x662D364ABF16DE2F, coordsOne, 0x900A4D0A)


    end

    -- Cooldown check 

    function startMissionCheck()
        QRCore.Functions.TriggerCallback('elkq:server:questCheck', function(cb, cdt, cdm)
            if cb then
                activeUppdrag = true
                missionOne = true
                QRCore.Functions.Notify(Lang:t('missionstarted'), 'success')
                QRCore.Functions.Notify(Lang:t('missionemerald'), 'success')
            TriggerServerEvent("elkq:server:questCooldownSet")
            setCoordsOne()
            startMission()
            else
                print(cdt)
                QRCore.Functions.Notify(Lang:t('cd1') .. tostring(cdt) .. Lang:t('cd2') .. tostring(cdm) .. Lang:t('cd3'), 'error')
            end
        end)
    end

    

        -- Starting mission

     function startMission() 
        --     while activeUppdrag == true do
        --     DrawScreenText(string.format(
        --         'Uppdrag aktivt'), 0.85, 0.95, false)
        --     DrawScreenText(string.format(
        --         'Skriv /avbrytuppdrag för att avbryta'), 0.85, 0.97, false)
            while missionOne == true do
                DrawScreenText(string.format(
                    Lang:t('missionactive')), 0.85, 0.95, false, 204, 229, 255)
                DrawScreenText(string.format(
                    Lang:t('missiondel')), 0.85, 0.965, false, 255,255,255)
                DrawScreenText(string.format(
                    Lang:t('missionemerald1')), 0.4, 0.95, false, 255,255,255)
                    Wait(0)
                --local playerPossy = GetEntityCoords(PlayerPedId())

                -- 3d text on letdown



                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                --local distanceText = GetDistanceBetweenCoords(playerPossy.x,playerPossy.y,playerPossy.z,1525.26, 442.36, 90.68)
                local dist = #(pos - vector3(Config.QuestX, Config.QuestY, Config.QuestZ))
                if dist <= 2 then
                    DrawText3D(Config.QuestX, Config.QuestY, Config.QuestZ + 0.5, Lang:t('missionpress'), false)
                   if IsControlJustPressed(0, 0x018C47CF) then
                    missionOne = false
                    missionTwo = true
                    RemoveBlip(coordsOne)
                    QRCore.Functions.Notify(Lang:t('missionemerald2'), 'success')
                    setCoordsTwo()
                    win = true
                    getBack()
                   end

                end
                    

            end
        

    end

    -- Set gps part 2

    function setCoordsTwo()
        local coordsTwo = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, Config.PedX, Config.PedY, Config.PedZ)
        SetBlipSprite(coordsTwo, 1475879922, 1)
        SetBlipScale(coordsTwo, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, coordsTwo, Lang:t('mission'))
        Citizen.InvokeNative(0x662D364ABF16DE2F, coordsTwo, 0x900A4D0A)
    end

    -- Add get reward to target after part 1 is done

    function getBack()
        exports['qr-target']:RemoveTargetEntity(npc, {
            options = optionsReel,
            distance = 2.5
        })
                        optionsReel = {
                    {
                        
                        label = Lang:t('takereward'),
                    
                        action = function()
                            if win == true then
                                win = false
                              endMission()
                            else
                                QRCore.Functions.Notify(Lang:t('error'), 'error')
                            end
                        end
                    }

        
                }

                exports['qr-target']:AddTargetEntity(npc, {
                    options = optionsReel,
                    distance = 2.5
                })

        while missionTwo == true do
            DrawScreenText(string.format(
                Lang:t('missionactive')), 0.85, 0.95, false, 204, 229, 255)
            DrawScreenText(string.format(
                Lang:t('missiondel')), 0.85, 0.965, false, 255,255,255)
            DrawScreenText(string.format(
                Lang:t('missionjones')), 0.4, 0.95, false, 255,255,255)
                Wait(0)
        end
    end

    -- ending mission. 

    function endMission()

        missionTwo = false
        missionOne = false
        activeUppdrag = false
        RemoveBlip(coordsTwo)
        local cash = math.random(Config.minReward,Config.maxReward)
        Citizen.InvokeNative(0xB059D7BD3D78C16F, coordsTwo, 0x900A4D0A)
        TriggerServerEvent("elkq:server:questDone", cash)
        QRCore.Functions.Notify(Lang:t('missiondone'), 'success')
        QRCore.Functions.Notify(Lang:t('missionget1') .. cash .. Lang:t('missionget2'), 'error')
        exports['qr-target']:RemoveTargetEntity(npc, {
            options = optionsReel,
            distance = 2.5
        })


    end

    -- function for 3dtext

     function DrawText3D(x, y, z, text, custom)
        local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
        local str = CreateVarString(10, "LITERAL_STRING", text,
                                    Citizen.ResultAsLong())
        local _me = me
        if onScreen and ((_x > 0 and _x < 1) or (_y > 0 and _y < 1)) then
            SetTextScale(0.25, 0.25)
            SetTextFontForCurrentCommand(21)
            Citizen.InvokeNative(1758329440 & 0xFFFFFFFF, true)
            SetTextDropshadow(1, 0, 0, 0, 255)
            SetTextColor(255, 255, 255, 165)
            SetTextCentre(1)
            onScreen, _x, _y = GetHudScreenPositionFromWorldPosition(x, y, z)
            DisplayText(str, _x, _y)
    
            local factor = (string.len(text)) / 360
            -- testing to not drawRect! DrawRect(_x, _y+0.01, 0.017 + factor, 0.025, 0, 0, 0, 75)
    
            if not custom then
                local factor = (string.len(text)) / 170
                local texture
                if string.len(text) < 20 then
                    texture = "score_timer_bg_small"
                elseif string.len(text) < 40 then
                    texture = "score_timer_large_black_bg"
                else
                    texture = "score_timer_extralong"
                end
    
            end
        end
    end

    DrawScreenText = function(text, x, y, centred, color1, color2, color3)
        SetTextScale(0.22, 0.22)
        SetTextColor(color1, color2,color3,255)
        SetTextCentre(centred)
        SetTextDropshadow(1, 0, 0, 0, 200)
        SetTextFontForCurrentCommand(0)
        DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
    end

    -- command for ending mission.

    RegisterCommand(
        "endmission",
        function()
           activeUppdrag = false
           missionOne = false
           missionTwo = false
           Citizen.InvokeNative(0xB059D7BD3D78C16F, coordsOne, 0x900A4D0A)
           RemoveBlip(coordsOne)
           Citizen.InvokeNative(0xB059D7BD3D78C16F, coordsTwo, 0x900A4D0A)
           RemoveBlip(coordsTwo)
           QRCore.Functions.Notify(Lang:t('endi'), 'error')
        end,
        false
    )

end)
