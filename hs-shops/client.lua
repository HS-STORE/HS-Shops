-- HS Store | HS Shops Modern
local QBCore = exports['qb-core']:GetCoreObject()
local activeStore = nil
local cashierPeds = {}

local function findStore(storeId)
    for _, store in ipairs(Config.Stores) do
        if store.id == storeId then return store end
    end
end

local function openShop(storeId)
    local store = findStore(storeId)
    if not store then return end
    activeStore = storeId
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        store = { id = store.id, label = store.label, subtitle = store.subtitle or '' },
        products = Config.Products,
        maxAmount = Config.MaxPurchaseAmount,
        audio = Config.GreetingAudio,
        volume = Config.GreetingVolume,
    })
end

local function spawnCashier(store)
    if not store.cashier then
        print(('[hs-shops-modern] Missing cashier coordinates for store: %s'):format(store.id))
        return
    end

    local model = joaat(Config.CashierModel or 'mp_m_shopkeep_01')
    RequestModel(model)
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(model) do
        Wait(20)
        if GetGameTimer() > timeout then
            print(('[hs-shops-modern] Could not load cashier model for store: %s'):format(store.id))
            return
        end
    end

    local pos = store.cashier
    local ped = CreatePed(4, model, pos.x, pos.y, pos.z, pos.w, false, false)
    if not DoesEntityExist(ped) then
        SetModelAsNoLongerNeeded(model)
        print(('[hs-shops-modern] Could not create cashier ped for store: %s'):format(store.id))
        return
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedDiesWhenInjured(ped, false)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
    SetModelAsNoLongerNeeded(model)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                icon = Config.TargetIcon,
                label = Config.TargetLabel,
                action = function() openShop(store.id) end,
            },
        },
        distance = 2.0,
    })
    cashierPeds[#cashierPeds + 1] = ped
end

CreateThread(function()
    Wait(1000)
    for _, store in ipairs(Config.Stores) do
        spawnCashier(store)
        Wait(150)
    end
end)

local function closeShop()
    SetNuiFocus(false, false)
    activeStore = nil
    SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('close', function(_, cb)
    closeShop()
    cb({ ok = true })
end)

RegisterNUICallback('buy', function(data, cb)
    if not activeStore then
        cb({ ok = false, message = 'المتجر غير مفتوح' })
        return
    end
    TriggerServerEvent('hs-shops-modern:server:buy', activeStore, data.item, tonumber(data.amount) or 1)
    cb({ ok = true })
end)

RegisterNetEvent('hs-shops-modern:client:purchaseResult', function(success, message)
    SendNUIMessage({ action = 'result', success = success, message = message })
end)

RegisterCommand('hsclose', function() closeShop() end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    for _, ped in ipairs(cashierPeds) do
        if DoesEntityExist(ped) then
            exports['qb-target']:RemoveTargetEntity(ped, Config.TargetLabel)
            DeleteEntity(ped)
        end
    end
end)
