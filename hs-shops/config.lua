-- HS Store | HS Shops Modern
Config = {}
Config.Debug = false
Config.PaymentAccount = 'cash' -- 'cash' or 'bank'
Config.MaxPurchaseAmount = 20
Config.GreetingAudio = 'sounds/hs-shops1.mp3'
Config.GreetingVolume = 0.85
Config.TargetLabel = 'تصفح المتجر'
Config.TargetIcon = 'fas fa-basket-shopping'
Config.CashierModel = 'mp_m_shopkeep_01'

-- إحداثية الكاشير الأولى مأخوذة من المستخدم؛ باقي الإحداثيات تقديرية وقابلة للتعديل.
Config.Stores = {
    { id = 'ltd_rockford', label = 'بقالة LTD', subtitle = 'تسوق سريع • منتجات يومية', coords = vector3(25.7, -1347.3, 29.5), cashier = vector4(24.4857, -1346.9771, 28.4971, 271.8456) },
    { id = 'ltd_vespucci', label = 'بقالة LTD', subtitle = 'تسوق سريع • منتجات يومية', coords = vector3(-47.3, -1758.6, 29.4), cashier = vector4(-47.13, -1758.48, 29.42, 48.0) },
    { id = 'ltd_mirror', label = 'بقالة LTD', subtitle = 'تسوق سريع • منتجات يومية', coords = vector3(1163.4, -323.8, 69.2), cashier = vector4(1164.86, -322.73, 69.2, 100.0) },
    { id = '24_7_sandy', label = 'متجر 24/7', subtitle = 'مفتوح دائماً لخدمتك', coords = vector3(1961.2, 3740.5, 32.3), cashier = vector4(1960.13, 3740.08, 32.34, 300.0) },
    { id = '24_7_paleto', label = 'متجر 24/7', subtitle = 'مفتوح دائماً لخدمتك', coords = vector3(1728.6, 6414.9, 35.0), cashier = vector4(1728.29, 6414.12, 35.04, 240.0) },
}

-- تأكد أن أسماء العناصر مطابقة تماماً لعناصر الإنفنتوري عندك.
Config.Products = {
    { item = 'water_bottle', label = 'مياه', description = 'مياه نقية ومنعشة', price = 5, category = 'مشروبات', icon = '💧' },
    { item = 'kurkakola', label = 'كولا', description = 'مشروب غازي بارد', price = 8, category = 'مشروبات', icon = '🥤' },
    { item = 'coffee', label = 'قهوة', description = 'قهوة ساخنة لوقتك', price = 10, category = 'مشروبات', icon = '☕' },
    { item = 'sandwich', label = 'ساندويش', description = 'وجبة خفيفة ولذيذة', price = 12, category = 'طعام', icon = '🥪' },
    { item = 'twerks_candy', label = 'حلوى', description = 'حلوى بطعم مميز', price = 6, category = 'طعام', icon = '🍬' },
}
