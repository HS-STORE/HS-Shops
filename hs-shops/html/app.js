const root = document.getElementById('shop');
const productGrid = document.getElementById('products');
const categoriesEl = document.getElementById('categories');
const searchEl = document.getElementById('search');
const emptyEl = document.getElementById('empty');
const toastEl = document.getElementById('toast');
const audioEl = document.getElementById('welcome-audio');
let products = [];
let maxAmount = 20;
let selectedCategory = 'الكل';
let searchTerm = '';
let quantities = {};
let toastTimer;

function nui(name, payload = {}) {
  return fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(payload)
  }).then(response => response.json()).catch(() => ({ ok: false }));
}

function showToast(message, isError = false) {
  toastEl.textContent = message || '';
  toastEl.classList.toggle('hidden', !message);
  toastEl.classList.toggle('error', Boolean(isError));
  clearTimeout(toastTimer);
  if (message) toastTimer = setTimeout(() => toastEl.classList.add('hidden'), 3600);
}

function renderCategories() {
  const categories = ['الكل', ...new Set(products.map(product => product.category || 'أخرى'))];
  categoriesEl.replaceChildren();
  for (const category of categories) {
    const button = document.createElement('button');
    button.type = 'button';
    button.className = `category-button${category === selectedCategory ? ' active' : ''}`;
    button.textContent = category;
    button.addEventListener('click', () => { selectedCategory = category; renderCategories(); renderProducts(); });
    categoriesEl.append(button);
  }
}

function renderProducts() {
  productGrid.replaceChildren();
  const filtered = products.filter(product => {
    const matchesCategory = selectedCategory === 'الكل' || (product.category || 'أخرى') === selectedCategory;
    const query = searchTerm.trim().toLowerCase();
    const matchesSearch = !query || `${product.label} ${product.description || ''} ${product.category || ''}`.toLowerCase().includes(query);
    return matchesCategory && matchesSearch;
  });
  emptyEl.classList.toggle('hidden', filtered.length !== 0);

  filtered.forEach(product => {
    const card = document.createElement('article'); card.className = 'product-card';
    const top = document.createElement('div'); top.className = 'product-top';
    const icon = document.createElement('div'); icon.className = 'product-icon'; icon.textContent = product.icon || '🛍️';
    const price = document.createElement('span'); price.className = 'product-price'; price.textContent = `$${product.price}`;
    top.append(icon, price);
    const title = document.createElement('h3'); title.textContent = product.label;
    const description = document.createElement('p'); description.className = 'product-description'; description.textContent = product.description || product.category || '';
    const bottom = document.createElement('div'); bottom.className = 'product-bottom';
    const qtyWrap = document.createElement('div'); qtyWrap.className = 'quantity';
    const minus = document.createElement('button'); minus.type = 'button'; minus.textContent = '−'; minus.setAttribute('aria-label', 'تقليل الكمية');
    const qty = document.createElement('span'); qty.textContent = String(quantities[product.item] || 1);
    const plus = document.createElement('button'); plus.type = 'button'; plus.textContent = '+'; plus.setAttribute('aria-label', 'زيادة الكمية');
    minus.addEventListener('click', () => { quantities[product.item] = Math.max(1, (quantities[product.item] || 1) - 1); qty.textContent = String(quantities[product.item]); });
    plus.addEventListener('click', () => { quantities[product.item] = Math.min(maxAmount, (quantities[product.item] || 1) + 1); qty.textContent = String(quantities[product.item]); });
    qtyWrap.append(minus, qty, plus);
    const buy = document.createElement('button'); buy.type = 'button'; buy.className = 'buy-button'; buy.textContent = 'أضف للسلة';
    buy.addEventListener('click', async () => {
      buy.disabled = true;
      const result = await nui('buy', { item: product.item, amount: quantities[product.item] || 1 });
      buy.disabled = false;
      if (!result.ok) showToast(result.message || 'تعذر إرسال الطلب', true);
    });
    bottom.append(qtyWrap, buy);
    card.append(top, title, description, bottom);
    productGrid.append(card);
  });
}

function closeShop() {
  audioEl.pause();
  audioEl.currentTime = 0;
  root.hidden = true;
  root.setAttribute('aria-hidden', 'true');
  nui('close');
}

window.addEventListener('message', event => {
  const data = event.data || {};
  if (data.action === 'open') {
    products = Array.isArray(data.products) ? data.products : [];
    maxAmount = Number(data.maxAmount) || 20;
    quantities = {};
    selectedCategory = 'الكل';
    searchTerm = '';
    searchEl.value = '';
    document.getElementById('store-title').textContent = data.store?.label || 'أهلاً فيك!';
    document.getElementById('store-subtitle').textContent = data.store?.subtitle || 'اختار اللي تحتاجه، وطلبك يصلك فوراً.';
    renderCategories();
    renderProducts();
    showToast('');
    root.hidden = false;
    root.setAttribute('aria-hidden', 'false');

    // The welcome file is optional; a missing or blocked audio file never blocks the UI.
    audioEl.pause();
    audioEl.currentTime = 0;
    audioEl.volume = Math.max(0, Math.min(1, Number(data.volume) || 0.85));
    audioEl.src = data.audio || 'sounds/hs-shops1.mp3';
    const playback = audioEl.play();
    if (playback && typeof playback.catch === 'function') {
      playback.catch(() => showToast('إذا لم يعمل الترحيب، تأكد من وجود html/sounds/hs-shops1.mp3'));
    }
  } else if (data.action === 'close') {
    audioEl.pause();
    audioEl.currentTime = 0;
    root.hidden = true;
    root.setAttribute('aria-hidden', 'true');
  } else if (data.action === 'result') {
    showToast(data.message || '', !data.success);
  }
});

document.getElementById('close').addEventListener('click', closeShop);
searchEl.addEventListener('input', () => { searchTerm = searchEl.value; renderProducts(); });
document.addEventListener('keydown', event => { if (event.key === 'Escape' && !root.hidden) closeShop(); });
