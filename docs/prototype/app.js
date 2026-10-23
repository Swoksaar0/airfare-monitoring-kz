"use strict";

// Deliberately synthetic fixtures. No real provider/API requests or push delivery.
const DEMO_DATE = "2026-11-06";
const DEMO_TODAY = "2026-10-23";
const STORAGE_KEY = "airfare-kz-prototype-rules-v1";
const routes = [
  ["ALA", "NQZ", "Алматы", "Астана"], ["NQZ", "ALA", "Астана", "Алматы"],
  ["ALA", "CIT", "Алматы", "Шымкент"], ["ALA", "SCO", "Алматы", "Актау"],
  ["ALA", "GUW", "Алматы", "Атырау"], ["ALA", "AKX", "Алматы", "Актобе"],
  ["NQZ", "CIT", "Астана", "Шымкент"], ["NQZ", "SCO", "Астана", "Актау"],
  ["NQZ", "GUW", "Астана", "Атырау"], ["NQZ", "AKX", "Астана", "Актобе"],
  ["NQZ", "UKK", "Астана", "Усть-Каменогорск"], ["ALA", "KGF", "Алматы", "Караганда"]
];
const offers = [
  {id:"fs-demo", airline:"FlyArystan", code:"FS", number:"FS DEMO-01", time:"10:30", arrival:"12:10", duration:"1 ч 40 мин", price:32900},
  {id:"dv-demo", airline:"SCAT", code:"DV", number:"DV DEMO-02", time:"14:10", arrival:"15:55", duration:"1 ч 45 мин", price:34200},
  {id:"kc-demo", airline:"Air Astana", code:"KC", number:"KC DEMO-03", time:"19:05", arrival:"20:50", duration:"1 ч 45 мин", price:43800}
];
const historyDates = ["15.10", "17.10", "19.10", "21.10", "23.10"];
const historyOffsets = [8000, 6000, 4600, 2000, 0];
const state = {routeIndex:0, date:DEMO_DATE, offerId:offers[0].id, mode:"ready", rules:[], persistent:true, notice:null};
const screen = document.getElementById("screen");
const stateSelect = document.getElementById("demo-state");
let loadingTimer;
let toastTimer;

function esc(value) { return String(value).replace(/[&<>"']/g, char=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[char])); }
function money(value) { return new Intl.NumberFormat("ru-RU",{maximumFractionDigits:0}).format(value); }
function dateLabel(value) { return new Date(value+"T12:00:00").toLocaleDateString("ru-RU",{day:"numeric",month:"long",year:"numeric"}); }
function route() { return routes[state.routeIndex]; }
function routeLabel() { const r=route(); return r[2]+" → "+r[3]; }
function selectedOffer() { return offers.find(offer=>offer.id===state.offerId)||offers[0]; }
function hasFixtures() { return state.routeIndex===0 && state.date===DEMO_DATE; }
function validDate(value) { return /^\d{4}-\d{2}-\d{2}$/.test(value) && !Number.isNaN(new Date(value+"T12:00:00").getTime()) && new Date(value+"T12:00:00").toISOString().slice(0,10)===value && value>DEMO_TODAY; }
function activePage() { return location.hash.slice(1)||"search"; }
function saveRules() { try { localStorage.setItem(STORAGE_KEY, JSON.stringify(state.rules)); } catch { state.persistent=false; } }
function loadRules() {
  try {
    const parsed=JSON.parse(localStorage.getItem(STORAGE_KEY)||"[]");
    if(Array.isArray(parsed)) state.rules=parsed.filter(rule=>rule && Number.isInteger(rule.routeIndex) && routes[rule.routeIndex] && validDate(rule.date) && offers.some(offer=>offer.id===rule.offerId) && Number.isFinite(rule.threshold) && rule.threshold>0 && typeof rule.active==="boolean" && typeof rule.id==="string").slice(0,50);
  } catch { state.persistent=false; }
}
function toast(message) { const node=document.getElementById("toast");node.textContent=message;node.hidden=false;clearTimeout(toastTimer);toastTimer=setTimeout(()=>{node.hidden=true;},4000); }
function go(page) { if(activePage()===page) render();else location.hash=page; }
function resetMode() { clearTimeout(loadingTimer);state.mode="ready";stateSelect.value="ready";state.notice=null; }
function demo(page) { resetMode();state.routeIndex=0;state.date=DEMO_DATE;state.offerId=offers[0].id;go(page); }
function backButton(page,label) { return `<button type="button" class="back" data-go="${page}">← ${label}</button>`; }
function routeSummary() { const r=route();return `<div class="route-direction"><div><strong>${r[0]}</strong><small>${r[2]}</small></div><div class="direction-line" aria-hidden="true"></div><div><strong>${r[1]}</strong><small>${r[3]}</small></div></div>`; }
function statusPill() { return state.mode==="stale"?'<span class="pill stale">Пример старой цены</span>':'<span class="pill">Искусственный пример</span>'; }
function selectionHeader(title) { return `${backButton("search","Изменить поиск")}<div class="section-label">${esc(dateLabel(state.date))}</div><h2>${esc(title)}</h2><p class="subtext">${esc(routeLabel())} · в одну сторону · 1 взрослый</p>`; }

function searchScreen() {
  return `<div class="section-label">ВНУТРЕННИЕ НАПРАВЛЕНИЯ</div><h2>Куда отправимся?</h2><p class="subtext">Выберите маршрут и дату.<br>Посмотрите, как менялась цена.</p>${routeSummary()}<form id="search-form" class="route-form"><label class="field" for="route">Направление</label><select id="route" name="route" class="form-control">${routes.map((r,i)=>`<option value="${i}" ${i===state.routeIndex?"selected":""}>${r[2]} → ${r[3]} · ${r[0]}–${r[1]}</option>`).join("")}</select><label class="field" for="departure-date">Дата вылета</label><input id="departure-date" name="date" type="date" class="form-control" min="2026-10-24" value="${esc(state.date)}" required><p id="search-error" class="form-error" role="alert"></p><button class="primary" type="submit">Посмотреть предложения <span aria-hidden="true">→</span></button></form><div class="info-box"><strong>Начните с демопримера</strong>Алматы → Астана, 6 ноября 2026. Для остальных маршрутов и дат показано состояние «нет демоданных».</div><p class="mini-note">12 выбранных направлений. Полнота покрытия реальных авиакомпаний пока не проверена.</p>`;
}
function unavailableScreen(page) {
  const mode=state.mode;
  if(mode==="ready"||mode==="stale") { if(hasFixtures())return null; }
  const config=mode==="error"?{glyph:"!",title:"Не удалось получить данные",text:"Пример ошибки источника. Сохранённые наблюдения не заменяются придуманной новой ценой.",button:"Повторить демосценарий",action:"retry"}:mode==="loading"?{glyph:"…",title:"Получаем предложения",text:"Демонстрация состояния загрузки. В этом прототипе запросы к авиакомпаниям не отправляются.",button:"Показать демоданные",action:"retry"}:{glyph:"⌕",title:"Пока нет наблюдений",text:"Для выбранного маршрута и даты в прототипе нет набора данных. Это не означает, что реальных рейсов нет.",button:"Открыть демопример",action:"demo-offers"};
  return `${selectionHeader(page==="history"?"Динамика цены":"Предложения")}<div class="state-panel"><div class="state-glyph" aria-hidden="true">${config.glyph}</div><h2>${config.title}</h2><p>${config.text}</p>${mode==="loading"?'<div class="loading-bar" aria-label="Демонстрация загрузки"></div>':""}<button type="button" class="primary" data-action="${config.action}">${config.button}</button><button type="button" class="secondary" data-go="search">Изменить маршрут и дату</button></div>`;
}
function offersScreen() {
  const missing=unavailableScreen("offers");if(missing)return missing;
  const r=route();
  return `${selectionHeader(routeLabel())}<div class="count-row"><span>3 демонстрационных предложения</span><span>По цене ↑</span></div>${state.mode==="stale"?'<div class="info-box"><strong>Свежесть не подтверждена</strong>Пример устаревшего наблюдения: не показываем его как новую цену. Все значения остаются искусственными.</div>':""}${offers.map((offer,i)=>`<article class="offer-card ${i===0?"best":""}"><div class="offer-top"><span class="carrier-mark">${offer.code}</span>${offer.airline}${i===0?'<span class="pill">Ниже в демонаборе</span>':""}</div><div class="flight-row"><div>${offer.time}<small>${r[0]}</small></div><div class="flight-duration">${offer.duration} · прямой</div><div>${offer.arrival}<small>${r[1]}</small></div></div><div class="offer-bottom"><div class="money">${money(offer.price)} <small>₸ / взрослый</small></div><button type="button" class="small-button" data-offer="${offer.id}">Подробнее</button></div></article>`).join("")}<p class="mini-note">Искусственные суммы для проверки интерфейса. Итоговая стоимость и доступность у перевозчиков не проверялись.</p>`;
}
function detailsScreen() {
  const missing=unavailableScreen("offers");if(missing)return missing;
  const offer=selectedOffer();
  return `${backButton("offers","К предложениям")}<div class="section-label">ДЕТАЛИ ПРЕДЛОЖЕНИЯ</div><h2>${offer.airline}</h2><p class="subtext">${esc(routeLabel())} · ${esc(dateLabel(state.date))}</p><div class="details-hero"><div class="section-label">ДЕМОНСТРАЦИОННАЯ ЦЕНА</div><div class="money">${money(offer.price)} <small>₸</small></div><p class="mini-note">В одну сторону · 1 взрослый · искусственный пример</p></div><div class="details-grid"><div class="detail-row"><span>Рейс (вымышленный)</span><strong>${offer.number}</strong></div><div class="detail-row"><span>Вылет / прилёт</span><strong>${offer.time} → ${offer.arrival}</strong></div><div class="detail-row"><span>Время</span><strong>Местное, UTC+5</strong></div><div class="detail-row"><span>Продолжительность</span><strong>${offer.duration}</strong></div><div class="detail-row"><span>Тариф</span><strong>Демопример · эконом</strong></div><div class="detail-row"><span>Ручная кладь</span><strong>Нет сведений в примере</strong></div><div class="detail-row"><span>Багаж</span><strong>Нет сведений в примере</strong></div></div><button type="button" class="primary" data-go="history">Посмотреть историю цены</button><button type="button" class="secondary" data-go="track-form">Отслеживать цену</button><div class="history-source"><p class="mini-note">Пример времени наблюдения: 23.10.2026, 14:15 UTC+5.<br>Источник цены не подключён. Сведения о багаже не додумываются.</p>${statusPill()}</div>`;
}
function chart(values) {
  const min=Math.min(...values)-2000,max=Math.max(...values)+2000;
  const points=values.map((value,i)=>[38+i*66,145-(value-min)/(max-min)*108]);
  return `<svg class="chart" viewBox="0 0 340 185" role="img" aria-label="Искусственная история цены: ${values.map((v,i)=>historyDates[i]+" — "+money(v)+" тенге").join("; ")}"><line x1="36" y1="42" x2="304" y2="42" stroke="#e7ede8"/><line x1="36" y1="94" x2="304" y2="94" stroke="#e7ede8"/><line x1="36" y1="146" x2="304" y2="146" stroke="#e7ede8"/><path d="M ${points[0][0]} 146 L ${points.map(p=>p.join(" ")).join(" L ")} L 302 146 Z" fill="#eaf5ef"/><polyline points="${points.map(p=>p.join(",")).join(" ")}" fill="none" stroke="#176a50" stroke-width="2.5" stroke-linejoin="round"/>${points.map((p,i)=>`<circle cx="${p[0]}" cy="${p[1]}" r="${i===4?4:3}" fill="#176a50"/><text x="${p[0]}" y="170" text-anchor="middle">${historyDates[i]}</text>`).join("")}<text x="7" y="18">KZT · искусственный пример</text></svg>`;
}
function historyScreen() {
  const missing=unavailableScreen("history");if(missing)return missing;
  const offer=selectedOffer(), values=historyOffsets.map(offset=>offer.price+offset), priorMedian=offer.price+5300,percent=Math.round(5300/priorMedian*100);
  return `${backButton("details","К деталям предложения")}<div class="section-label">ДИНАМИКА ДЛЯ ОДНОЙ ДАТЫ ВЫЛЕТА</div><h2>Как менялась цена</h2><p class="subtext">${esc(routeLabel())} · ${esc(dateLabel(state.date))}<br>${offer.airline} · ${offer.number} · демотариф</p><div class="history-metric"><div class="section-label">ПОСЛЕДНЕЕ ДЕМОНАБЛЮДЕНИЕ</div><div class="money">${money(offer.price)} <small>₸</small></div></div>${chart(values)}<div class="assessment"><strong>На ${percent}% ниже предыдущей медианы</strong><p>Медиана четырёх предыдущих демонаблюдений: ${money(priorMedian)} ₸. Текущая точка в неё не входит. Это описание примера, а не прогноз покупки.</p></div><ul class="history-list" aria-label="Демонстрационные наблюдения">${values.map((v,i)=>`<li><span>${historyDates[i]}.2026 · 14:15</span><strong>${money(v)} ₸</strong></li>`).join("")}</ul>${state.mode==="stale"?'<p class="mini-note">Выбран сценарий устаревших данных: свежесть исходной цены не подтверждена.</p>':""}<button type="button" class="primary" data-go="track-form">Настроить отслеживание</button><p class="mini-note">Даты по оси — моменты наблюдения. Дата вылета остаётся 6 ноября 2026. Все точки искусственные.</p>`;
}
function trackFormScreen() {
  const missing=unavailableScreen("offers");if(missing)return missing;
  const offer=selectedOffer();
  return `${backButton("history","К динамике")}<div class="section-label">ОТСЛЕЖИВАНИЕ</div><h2>Ваша желаемая цена</h2><p class="subtext">Посмотрим, как будет выглядеть правило уведомления о снижении цены.</p><div class="track-summary"><strong>${esc(routeLabel())}</strong><span>${esc(dateLabel(state.date))} · ${offer.airline}<br>Цена в примере: ${money(offer.price)} ₸</span></div><form id="track-form"><label for="threshold" class="field">Сообщить, когда цена не выше, ₸</label><input class="form-control" id="threshold" name="threshold" type="number" min="1" max="10000000" step="1" value="30000" required inputmode="numeric" aria-describedby="threshold-hint"><p class="mini-note" id="threshold-hint">Укажите целую сумму от 1 до 10 000 000 ₸.</p><p id="threshold-error" class="form-error" role="alert"></p><button type="submit" class="primary">Сохранить демоправило</button></form><div class="info-box"><strong>Только демонстрация</strong>Правило хранится в этом браузере. Реальные push-уведомления не отправляются; разрешения и контактные данные не запрашиваются.</div>`;
}
function trackingScreen() {
  const storage=state.persistent?"Сохранено только в этом браузере.":"Хранилище браузера недоступно: правила действуют только в этой вкладке.";
  return `<div class="section-label">ВАШИ ДЕМОПРАВИЛА</div><h2>Отслеживание</h2><p class="subtext">${storage}<br>Реальные уведомления не отправляются.</p>${state.notice?`<div class="notification" role="status"><strong>Пример уведомления · не push</strong>${esc(state.notice)}<p class="mini-note">Показано вручную для проверки интерфейса. Снижение реальной цены не обнаруживалось.</p></div>`:""}${state.rules.length?state.rules.map(rule=>{const r=routes[rule.routeIndex],o=offers.find(item=>item.id===rule.offerId);return `<article class="rule-card"><h3>${r[2]} → ${r[3]}</h3><p>${esc(dateLabel(rule.date))} · ${o.airline}</p><div class="money">до ${money(rule.threshold)} <small>₸</small></div><p><span class="pill ${rule.active?"":"stale"}">${rule.active?"Демоправило включено":"Демоправило отключено"}</span></p><div class="rule-actions"><button type="button" data-toggle="${esc(rule.id)}">${rule.active?"Отключить":"Включить"}</button><button type="button" data-notice="${esc(rule.id)}" ${rule.active?"":"disabled"}>Пример уведомления</button></div></article>`;}).join(""):`<div class="state-panel"><div class="state-glyph" aria-hidden="true">◇</div><h2>Пока ничего не отслеживаем</h2><p>Выберите демонстрационное предложение и задайте желаемую цену.</p><button type="button" class="primary" data-action="demo-offers">Выбрать предложение</button></div>`}<button type="button" class="secondary" data-action="demo-offers">Добавить отслеживание</button>`;
}
function render() {
  const page=activePage();
  const renderer={search:searchScreen,offers:offersScreen,details:detailsScreen,history:historyScreen,"track-form":trackFormScreen,tracking:trackingScreen}[page]||searchScreen;
  screen.innerHTML=renderer();screen.scrollTop=0;screen.focus({preventScroll:true});
  document.querySelectorAll("[data-nav]").forEach(node=>{const active=node.dataset.nav===(page==="history"?"history":page==="tracking"||page==="track-form"?"tracking":"search");node.classList.toggle("active",active);if(active)node.setAttribute("aria-current","page");else node.removeAttribute("aria-current");});
}
document.addEventListener("click",event=>{
  const button=event.target.closest("[data-action],[data-go],[data-offer],[data-toggle],[data-notice]");if(!button)return;
  if(button.dataset.go)go(button.dataset.go);
  if(button.dataset.offer){state.offerId=button.dataset.offer;go("details");}
  if(button.dataset.action){const action=button.dataset.action;if(action==="restart")demo("search");if(action==="demo-offers")demo("offers");if(action==="demo-history")demo("history");if(action==="demo-track")demo("track-form");if(action==="retry"){resetMode();if(!hasFixtures()){state.routeIndex=0;state.date=DEMO_DATE;}render();}}
  if(button.dataset.toggle){const rule=state.rules.find(item=>item.id===button.dataset.toggle);if(rule){rule.active=!rule.active;state.notice=null;saveRules();render();toast(rule.active?"Демоправило включено":"Демоправило отключено");}}
  if(button.dataset.notice){const rule=state.rules.find(item=>item.id===button.dataset.notice);if(rule&&rule.active){const r=routes[rule.routeIndex];state.notice=`${r[2]} → ${r[3]}: искусственная цена ${money(Math.max(1,rule.threshold-1000))} ₸ соответствует порогу ${money(rule.threshold)} ₸.`;render();}}
});
document.addEventListener("change",event=>{if(event.target.id==="route"){state.routeIndex=Number(event.target.value);document.querySelector(".route-direction").outerHTML=routeSummary();}if(event.target.id==="departure-date"&&validDate(event.target.value))state.date=event.target.value;});
document.addEventListener("submit",event=>{
  if(event.target.id==="search-form"){
    event.preventDefault();const data=new FormData(event.target);const date=String(data.get("date"));if(!validDate(date)){document.getElementById("search-error").textContent="Выберите дату после 23 октября 2026 — начала демопериода.";return;}
    state.date=date;state.routeIndex=Number(data.get("route"));state.offerId=offers[0].id;state.notice=null;
    if(state.mode==="ready"){state.mode="loading";go("offers");clearTimeout(loadingTimer);loadingTimer=setTimeout(()=>{state.mode="ready";if(activePage()==="offers")render();},450);}else go("offers");
  }
  if(event.target.id==="track-form"){
    event.preventDefault();const value=Number(new FormData(event.target).get("threshold"));if(!Number.isSafeInteger(value)||value<1||value>10000000){document.getElementById("threshold-error").textContent="Введите целую положительную сумму до 10 000 000 ₸.";return;}
    const id=`${state.routeIndex}|${state.date}|${state.offerId}`,existing=state.rules.find(rule=>rule.id===id);if(existing){existing.threshold=value;existing.active=true;}else state.rules.push({id,routeIndex:state.routeIndex,date:state.date,offerId:state.offerId,threshold:value,active:true});saveRules();state.notice=null;go("tracking");toast("Демоправило сохранено. Реальные уведомления не отправляются.");
  }
});
stateSelect.addEventListener("change",()=>{clearTimeout(loadingTimer);state.mode=stateSelect.value;state.notice=null;if(["search","tracking"].includes(activePage()))go("offers");else render();});
window.addEventListener("hashchange",render);
loadRules();render();
