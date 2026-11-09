-- HS Store | HS Shops Modern
local QBCore = exports['qb-core']:GetCoreObject()

local function findStore(storeId)
    for _, store in ipairs(Config.Stores) do
        if store.id == storeId then return store end
    end
end

local function findProduct(itemName)
    for _, product in ipairs(Config.Products) do
        if product.item == itemName then return product end
    end
end

RegisterNetEvent('hs-shops-modern:server:buy', function(storeId, itemName, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local store = findStore(storeId)
    local ped = GetPlayerPed(src)
    if not store or not ped or ped == 0 or #(GetEntityCoords(ped) - store.coords) > 6.0 then
        TriggerClientEvent('hs-shops-modern:client:purchaseResult', src, false, 'لازم تكون قريب من المتجر')
        return
    end

    amount = math.floor(tonumber(amount) or 0)
    if amount < 1 or amount > Config.MaxPurchaseAmount then
        TriggerClientEvent('hs-shops-modern:client:purchaseResult', src, false, 'الكمية غير صالحة')
        return
    end

    local product = findProduct(itemName)
    if not product or type(product.price) ~= 'number' or product.price < 0 then
        TriggerClientEvent('hs-shops-modern:client:purchaseResult', src, false, 'المنتج غير متوفر')
        return
    end
    if not QBCore.Shared.Items[product.item] then
        TriggerClientEvent('hs-shops-modern:client:purchaseResult', src, false, 'اسم المنتج غير موجود في إعدادات الإنفنتوري')
        return
    end

    local account = Config.PaymentAccount or 'cash'
    local total = product.price * amount
    if (Player.PlayerData.money[account] or 0) < total then
        TriggerClientEvent('hs-shops-modern:client:purchaseResult', src, false, 'ما معك فلوس كافية')
        return
    end
    if not Player.Functions.RemoveMoney(account, total, 'hs-shops-modern-purchase') then
        TriggerClientEvent('hs-shops-modern:client:purchaseResult', src, false, 'تعذر خصم المبلغ')
        return
    end

    local added = Player.Functions.AddItem(product.item, amount, false)
    if not added then
        Player.Functions.AddMoney(account, total, 'hs-shops-modern-refund')
        TriggerClientEvent('hs-shops-modern:client:purchaseResult', src, false, 'الحقيبة ممتلئة، وتم إرجاع المبلغ')
        return
    end

    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[product.item], 'add', amount)
    TriggerClientEvent('hs-shops-modern:client:purchaseResult', src, true,
        ('تم شراء %s × %d مقابل $%d'):format(product.label, amount, total))
end)
