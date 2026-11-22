# Update 4 main pages: khampha.html, bando.html, index.html, goiy.html
$ErrorActionPreference = "Stop"
$baseDir = $PSScriptRoot

$jsonText = [System.IO.File]::ReadAllText("$baseDir\restaurants.json", [System.Text.Encoding]::UTF8)
$restaurants = $jsonText | ConvertFrom-Json
Write-Host "Loaded $($restaurants.Count) restaurants from JSON"

function Get-Budget($price) {
    $nums = [regex]::Matches($price, '\d{1,3}(?:\.\d{3})+') | ForEach-Object { [double]($_.Value -replace '\.', '') }
    if ($nums.Count -eq 0) { return "mid" }
    $max = ($nums | Measure-Object -Maximum).Maximum
    if ($max -le 100000) { return "cheap" } elseif ($max -le 300000) { return "mid" } elseif ($max -le 600000) { return "high" } else { return "premium" }
}
function Get-ShortPrice($price) {
    $nums = [regex]::Matches($price, '\d{1,3}(?:\.\d{3})+') | ForEach-Object { [double]($_.Value -replace '\.', '') }
    if ($nums.Count -ge 2) { $lo = if ($nums[0] -ge 1000) {"$([int]($nums[0]/1000))k"} else {"$($nums[0])k"}; $hi = if ($nums[1] -ge 1000) {"$([int]($nums[1]/1000))k"} else {"$($nums[1])k"}; return "$lo - $hi" }
    elseif ($nums.Count -eq 1) { return if ($nums[0] -ge 1000) {"$([int]($nums[0]/1000))k"} else {"$($nums[0])k"} }
    return "Lien he"
}
function Get-HoursCat($hours) {
    if ($hours -match '24/24' -or $hours -match '00:00') { return "ngay" }
    $m = [regex]::Match($hours, '(\d{1,2}):(\d{2})')
    if ($m.Success) { $h = [int]$m.Groups[1].Value; if ($h -lt 11) { return "sang" } elseif ($h -lt 14) { return "trua" } else { return "toi" } }
    return "ngay"
}
function Clean-Addr($addr) { return ($addr -replace '^\.\s*','' -replace '^\s*,\s*','' -replace '^\s+','').Trim() }

$districts = $restaurants | Select-Object -ExpandProperty District | Sort-Object -Unique

# === 1. KHAMPHA.HTML ===
Write-Host "Generating khampha.html..."

$sbCards = New-Object System.Text.StringBuilder
foreach ($r in $restaurants) {
    $budget = Get-Budget $r.Price
    $hoursCat = Get-HoursCat $r.Hours
    $shortPrice = Get-ShortPrice $r.Price
    $descShort = $r.Description
    if ($descShort.Length -gt 100) { $descShort = $descShort.Substring(0,100) + "..." }
    $nameLower = $r.Name.ToLower()
    [void]$sbCards.AppendLine("        <article class='card' data-district='$($r.District)' data-type='$($r.Type)' data-budget='$budget' data-rating='$($r.Rating)' data-hours='$hoursCat' data-name='$nameLower'>")
    [void]$sbCards.AppendLine("          <div class='card-img-wrap'><img src='https://images.pexels.com/photos/$($r.ImgId)/pexels-photo-$($r.ImgId).jpeg?auto=compress&cs=tinysrgb&w=800' alt='$($r.Name)' class='card-img' loading='lazy' /></div>")
    [void]$sbCards.AppendLine("          <div class='card-body'>")
    [void]$sbCards.AppendLine("            <div class='card-meta-top'><span class='badge badge-district'>$($r.District)</span><span class='badge badge-type'>$($r.Type)</span></div>")
    [void]$sbCards.AppendLine("            <h3 class='card-title'><a href='quan-$($r.Num).html'>$($r.Name)</a></h3>")
    [void]$sbCards.AppendLine("            <p class='card-desc'>$descShort</p>")
    [void]$sbCards.AppendLine("            <div class='card-footer'><span class='price'>$shortPrice</span><span class='stars'>★ $($r.Rating)</span></div>")
    [void]$sbCards.AppendLine("          </div>")
    [void]$sbCards.AppendLine("        </article>")
    [void]$sbCards.AppendLine("")
}
$cardsHtml = $sbCards.ToString()

$distOpts = ""
foreach ($d in $districts) { $distOpts += "          <option value='$d'>$d</option>" + "`n" }

$khamphaHtml = @'
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>How To Food Like A Saigonese | Khám phá</title>
  <link rel="stylesheet" href="css/style.css" />
</head>
<body>
  <nav class="navbar">
    <div class="container">
      <a href="index.html" class="nav-logo">How To Food Like A Saigonese</a>
      <button class="nav-hamburger" id="hamburgerBtn" aria-label="Mở menu" aria-expanded="false"><span></span><span></span><span></span></button>
      <ul class="nav-links" id="navLinks">
        <li><a href="index.html">Trang chủ</a></li>
        <li><a href="khampha.html" class="active">Khám phá</a></li>
        <li><a href="bando.html">Bản đồ</a></li>
        <li><a href="goiy.html">Gợi ý</a></li>
      </ul>
    </div>
  </nav>
  <div class="page-hero">
    <div class="page-hero-bg" style="background-image:url('https://images.pexels.com/photos/1537635/pexels-photo-1537635.jpeg?auto=compress&cs=tinysrgb&w=1400');"></div>
    <div class="page-hero-content"><h1>Khám phá ẩm thực TP.HCM</h1><p>Dùng bộ lọc bên trái để tìm đúng quán ăn phù hợp với bạn</p></div>
  </div>
  <div class="khampha-wrapper">
    <aside class="filter-sidebar">
      <div class="filter-sidebar-title"><span>🎛 Bộ lọc</span><button class="filter-reset-btn" id="resetBtn" onclick="resetFilters()">Đặt lại</button></div>
      <div class="filter-group"><label class="filter-group-label" for="fsSearch">Tìm kiếm</label><input type="text" id="fsSearch" placeholder="Tên quán, món ăn..." /></div>
      <div class="filter-divider"></div>
      <div class="filter-group"><label class="filter-group-label" for="fsDistrict">Khu vực</label><select id="fsDistrict"><option value="">Tất cả quận</option>
'@ + $distOpts + @'
        </select></div>
      <div class="filter-group"><label class="filter-group-label" for="fsType">Loại quán</label><select id="fsType"><option value="">Tất cả loại quán</option><option value="Món Việt">Món Việt</option><option value="Món Hàn">Món Hàn</option><option value="Món Nhật">Món Nhật</option><option value="Món Âu">Món Âu</option><option value="Món Thái">Món Thái</option><option value="Món Ấn">Món Ấn</option><option value="Món Hoa">Món Hoa</option><option value="Pizza">Pizza</option><option value="Món Mỹ">Món Mỹ</option><option value="Món Chay">Món Chay</option><option value="Hải sản">Hải sản</option><option value="Món khác">Món khác</option></select></div>
      <div class="filter-group"><label class="filter-group-label" for="fsBudget">Mức giá</label><select id="fsBudget"><option value="">Tất cả mức giá</option><option value="cheap">Dưới 100.000đ</option><option value="mid">100.000 - 300.000đ</option><option value="high">300.000 - 600.000đ</option><option value="premium">Trên 600.000đ</option></select></div>
      <div class="filter-group"><label class="filter-group-label" for="fsRating">Đánh giá</label><select id="fsRating"><option value="">Tất cả đánh giá</option><option value="4.5">★★★★★ 4.5 trở lên</option><option value="4.0">★★★★☆ 4.0 trở lên</option></select></div>
      <div class="filter-group"><label class="filter-group-label" for="fsHours">Giờ mở cửa</label><select id="fsHours"><option value="">Tất cả giờ</option><option value="sang">Buổi sáng (trước 11h)</option><option value="trua">Buổi trưa (11h - 14h)</option><option value="toi">Buổi tối (sau 17h)</option><option value="ngay">Cả ngày</option></select></div>
    </aside>
    <div class="khampha-cards-area">
      <div class="khampha-result-bar"><span class="khampha-result-count" id="resultCount">Đang hiển thị tất cả quán</span></div>
      <div class="khampha-cards-grid" id="cardsGrid">
'@ + $cardsHtml + @'
      </div>
      <div class="empty-state hidden" id="emptyState"><div class="empty-state-icon">🍽</div><p>Không tìm thấy quán phù hợp. Thử thay đổi bộ lọc nhé!</p></div>
    </div>
  </div>
  <footer class="footer"><p>© 2025 How To Food Like A Saigonese | Made with ❤️ bởi Nhóm 4 — Lớp 10.1</p></footer>
  <script>
    (function(){var b=document.getElementById('hamburgerBtn'),l=document.getElementById('navLinks');b.addEventListener('click',function(){var o=l.classList.toggle('open');b.setAttribute('aria-expanded',o);b.classList.toggle('active',o);});})();
    var cards=Array.from(document.querySelectorAll('#cardsGrid .card')),emptyState=document.getElementById('emptyState'),resultCount=document.getElementById('resultCount');
    var fsSearch=document.getElementById('fsSearch'),fsDistrict=document.getElementById('fsDistrict'),fsType=document.getElementById('fsType'),fsBudget=document.getElementById('fsBudget'),fsRating=document.getElementById('fsRating'),fsHours=document.getElementById('fsHours');
    function applyFilters(){var q=fsSearch.value.toLowerCase().trim(),district=fsDistrict.value,type=fsType.value,budget=fsBudget.value,rating=parseFloat(fsRating.value)||0,hours=fsHours.value,shown=0;
      cards.forEach(function(c){var ok=(!q||c.dataset.name.includes(q))&&(!district||c.dataset.district===district)&&(!type||c.dataset.type===type)&&(!budget||c.dataset.budget===budget)&&(!rating||parseFloat(c.dataset.rating)>=rating)&&(!hours||c.dataset.hours===hours||c.dataset.hours==='ngay');
      c.classList.toggle('hidden',!ok);if(ok)shown++;});
      emptyState.classList.toggle('hidden',shown>0);
      resultCount.textContent=shown===cards.length?'Đang hiển thị tất cả quán':'Tìm thấy '+shown+' quán phù hợp';}
    function resetFilters(){[fsSearch,fsDistrict,fsType,fsBudget,fsRating,fsHours].forEach(function(el){el.value='';});applyFilters();}
    [fsSearch,fsDistrict,fsType,fsBudget,fsRating,fsHours].forEach(function(el){el.addEventListener('change',applyFilters);el.addEventListener('input',applyFilters);});
  </script>
</body>
</html>
'@

[System.IO.File]::WriteAllText("$baseDir\khampha.html", $khamphaHtml, (New-Object System.Text.UTF8Encoding($true)))
Write-Host "  -> khampha.html: 6 filters + $($restaurants.Count) cards"

# === 2. BANDO.HTML ===
Write-Host "Generating bando.html..."

$sbData = New-Object System.Text.StringBuilder
foreach ($r in $restaurants) {
    $safeName = $r.Name -replace "'", "\\'"
    [void]$sbData.AppendLine("      { id:$($r.Num), name:'$safeName', lat:$($r.Lat), lng:$($r.Lng), district:'$($r.District)', food:'$($r.Type)', rating:$($r.Rating), e:'$($r.Emoji)' },")
}
$dataEntries = $sbData.ToString()

$bandoHtml = @'
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>How To Food Like A Saigonese | Bản đồ</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin="" />
  <link rel="stylesheet" href="css/style.css" />
  <style>
    html { height: 100%; }
    body { height: 100%; display: flex; flex-direction: column; overflow: hidden; animation: none; }
    .map-viewport { display: flex; flex: 1; min-height: 0; overflow: hidden; }
    .map-sidebar { width: 300px; flex-shrink: 0; display: flex; flex-direction: column; overflow: hidden; background: #fff; border-right: 1px solid #e8e0da; box-shadow: 2px 0 12px rgba(0,0,0,.05); z-index: 10; }
    .sidebar-hd { padding: 1.1rem 1.2rem 0.9rem; border-bottom: 1px solid #f0ede8; flex-shrink: 0; }
    .sidebar-hd h2 { font-size: 0.975rem; font-weight: 700; color: #1a1a1a; margin-bottom: 0.8rem; display: flex; align-items: center; gap: 0.4rem; }
    .sidebar-badge { font-size: 0.68rem; font-weight: 700; background: #cf3b1b; color: #fff; padding: 2px 8px; border-radius: 99px; }
    .btn-loc { display: flex; align-items: center; justify-content: center; gap: 0.4rem; width: 100%; padding: 0.55rem; background: rgba(207,59,27,.07); color: #cf3b1b; border: 1.5px solid rgba(207,59,27,.25); border-radius: 8px; font-size: 0.85rem; font-weight: 600; cursor: pointer; transition: all .2s; }
    .btn-loc:hover { background: rgba(207,59,27,.14); border-color: #cf3b1b; }
    .sidebar-list { flex: 1; overflow-y: auto; padding: 0.45rem 0.55rem; }
    .sidebar-list::-webkit-scrollbar { width: 4px; }
    .sidebar-list::-webkit-scrollbar-thumb { background: #ddd; border-radius: 2px; }
    .s-item { display: flex; align-items: center; gap: 0.65rem; padding: 0.6rem 0.7rem; border-radius: 9px; cursor: pointer; border: 1.5px solid transparent; transition: all .18s; margin-bottom: 2px; }
    .s-item:hover, .s-item.active { background: rgba(207,59,27,.05); border-color: rgba(207,59,27,.2); }
    .s-emoji { width: 32px; height: 32px; border-radius: 50%; background: rgba(207,59,27,.1); display: flex; align-items: center; justify-content: center; font-size: 0.95rem; flex-shrink: 0; }
    .s-info { flex: 1; min-width: 0; }
    .s-name { font-size: 0.825rem; font-weight: 700; color: #1a1a1a; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .s-sub { font-size: 0.73rem; color: #888; }
    .s-star { color: #e0a318; font-weight: 700; }
    .sidebar-ft { padding: 0.6rem 1.1rem; font-size: 0.76rem; color: #bbb; border-top: 1px solid #f0ede8; font-weight: 600; background: #fafaf9; flex-shrink: 0; }
    #map { flex: 1; min-width: 0; min-height: 0; z-index: 1; }
    .map-footer { background: #1a1a1a; color: #555; text-align: center; font-size: 0.78rem; padding: 0.65rem; flex-shrink: 0; z-index: 2; }
    .leaflet-popup-content-wrapper { border-radius: 10px !important; box-shadow: 0 4px 20px rgba(0,0,0,.18) !important; padding: 0 !important; }
    .leaflet-popup-content { margin: 0 !important; }
    .popup-box { padding: 14px 16px; min-width: 190px; max-width: 240px; }
    .popup-name { font-size: .95rem; font-weight: 700; color: #1a1a1a; margin-bottom: 6px; }
    .popup-row  { font-size: .82rem; color: #666; margin-bottom: 3px; }
    .popup-star { color: #e0a318; font-weight: 700; }
    .popup-btn  { display: inline-block; margin-top: 10px; color: #cf3b1b; font-size: .875rem; font-weight: 700; border: 1.5px solid #cf3b1b; padding: 5px 14px; border-radius: 6px; text-decoration: none; }
    .popup-btn:hover { background: #cf3b1b; color: #fff; }
    @media (max-width: 768px) { html, body { height: auto; overflow: auto; } .map-viewport { flex-direction: column; height: auto; } .map-sidebar { width: 100%; height: auto; max-height: 200px; } #map { height: 400px; } }
  </style>
</head>
<body>
  <nav class="navbar" style="flex-shrink:0;">
    <div class="container">
      <a href="index.html" class="nav-logo">How To Food Like A Saigonese</a>
      <button class="nav-hamburger" id="hamburgerBtn" aria-label="Mở menu" aria-expanded="false"><span></span><span></span><span></span></button>
      <ul class="nav-links" id="navLinks">
        <li><a href="index.html">Trang chủ</a></li>
        <li><a href="khampha.html">Khám phá</a></li>
        <li><a href="bando.html" class="active">Bản đồ</a></li>
        <li><a href="goiy.html">Gợi ý</a></li>
      </ul>
    </div>
  </nav>
  <div class="map-viewport">
    <aside class="map-sidebar">
      <div class="sidebar-hd">
        <h2>🗺 Bản đồ quán ăn <span class="sidebar-badge" id="cntBadge">—</span></h2>
        <button class="btn-loc" id="locBtn">📍 Vị trí của tôi</button>
      </div>
      <div class="sidebar-list" id="sList"></div>
      <div class="sidebar-ft" id="sFt">Đang tải…</div>
    </aside>
    <div id="map"></div>
  </div>
  <footer class="map-footer">© 2025 How To Food Like A Saigonese | Made with ❤️ bởi Nhóm 4 — Lớp 10.1</footer>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
  <script>
    var data = [
'@ + $dataEntries + @'
    ];
    var map = L.map('map', { zoomControl: true }).setView([10.7769, 106.7009], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors', maxZoom: 19 }).addTo(map);
    function icon(emoji) { return L.divIcon({ className: '', html: '<div style="position:relative;width:38px;height:44px;"><div style="background:#cf3b1b;width:38px;height:38px;border-radius:50% 50% 50% 0;transform:rotate(-45deg);border:3px solid #fff;box-shadow:0 3px 10px rgba(0,0,0,.4);display:flex;align-items:center;justify-content:center;"><span style="transform:rotate(45deg);font-size:16px;line-height:1;">' + emoji + '</span></div></div>', iconSize: [38, 44], iconAnchor: [19, 44], popupAnchor: [0, -46] }); }
    var markers = {};
    data.forEach(function (r) {
      var m = L.marker([r.lat, r.lng], { icon: icon(r.e) }).addTo(map);
      m.bindPopup('<div class="popup-box"><div class="popup-name">' + r.e + ' ' + r.name + '</div><div class="popup-row">📍 ' + r.district + '</div><div class="popup-row">🍽 ' + r.food + '</div><div class="popup-row popup-star">⭐ ' + r.rating + ' / 5</div><a href="quan-' + r.id + '.html" class="popup-btn">Xem chi tiết →</a></div>', { maxWidth: 260 });
      markers[r.id] = m;
    });
    var sList = document.getElementById('sList'), sFt = document.getElementById('sFt'), cntBdg = document.getElementById('cntBadge');
    function buildList() {
      sList.innerHTML = ''; var shown = 0;
      data.forEach(function (r) {
        shown++;
        var el = document.createElement('div'); el.className = 's-item';
        el.innerHTML = '<div class="s-emoji">' + r.e + '</div><div class="s-info"><div class="s-name">' + r.name + '</div><div class="s-sub">📍 ' + r.district + ' · <span class="s-star">★ ' + r.rating + '</span></div></div>';
        el.addEventListener('click', function () { document.querySelectorAll('.s-item').forEach(function (x) { x.classList.remove('active'); }); el.classList.add('active'); map.setView([r.lat, r.lng], 16, { animate: true }); markers[r.id].openPopup(); });
        sList.appendChild(el);
      });
      cntBdg.textContent = shown + ' quán'; sFt.textContent = 'Hiển thị ' + shown + ' quán trên bản đồ';
    }
    buildList();
    var uMarker = null, uCircle = null;
    document.getElementById('locBtn').addEventListener('click', function () {
      if (!navigator.geolocation) { alert('Trình duyệt không hỗ trợ định vị.'); return; }
      navigator.geolocation.getCurrentPosition(function (p) {
        var lt = p.coords.latitude, ln = p.coords.longitude, acc = p.coords.accuracy;
        if (uMarker) map.removeLayer(uMarker); if (uCircle) map.removeLayer(uCircle);
        uMarker = L.circleMarker([lt, ln], { radius: 9, color: '#fff', fillColor: '#1976d2', fillOpacity: 1, weight: 3 }).addTo(map).bindPopup('<strong>📍 Vị trí của bạn</strong>').openPopup();
        uCircle = L.circle([lt, ln], { radius: acc, color: '#1976d2', fillColor: '#1976d2', fillOpacity: .1, weight: 1 }).addTo(map);
        map.setView([lt, ln], 15, { animate: true });
      }, function (e) { alert('Không lấy được vị trí: ' + e.message); }, { enableHighAccuracy: true, timeout: 8000 });
    });
    (function () { var b = document.getElementById('hamburgerBtn'), l = document.getElementById('navLinks'); b.addEventListener('click', function () { var o = l.classList.toggle('open'); b.setAttribute('aria-expanded', o); b.classList.toggle('active', o); }); })();
    setTimeout(function () { map.invalidateSize(true); }, 300);
    window.addEventListener('resize', function () { map.invalidateSize(); });
  </script>
</body>
</html>
'@

[System.IO.File]::WriteAllText("$baseDir\bando.html", $bandoHtml, (New-Object System.Text.UTF8Encoding($true)))
Write-Host "  -> bando.html: $($restaurants.Count) markers, no area filter"

# === 3. INDEX.HTML ===
Write-Host "Updating index.html..."
$indexHtml = [System.IO.File]::ReadAllText("$baseDir\index.html", [System.Text.Encoding]::UTF8)
$distCount = $districts.Count
$indexHtml = $indexHtml -replace '150\+', '100'
$indexHtml = $indexHtml -replace '<span class="stat-number">24</span>', "<span class=`"stat-number`">$distCount</span>"

# Update the 3 cards
$first3 = $restaurants[0..2]
$sbIdx = New-Object System.Text.StringBuilder
for ($i = 0; $i -lt 3; $i++) {
    $r = $first3[$i]
    $sp = Get-ShortPrice $r.Price
    $ds = $r.Description; if ($ds.Length -gt 100) { $ds = $ds.Substring(0,100) + "..." }
    [void]$sbIdx.AppendLine("        <article class=`"card`">")
    [void]$sbIdx.AppendLine("          <div class=`"card-img-wrap`">")
    [void]$sbIdx.AppendLine("            <img src=`"https://images.pexels.com/photos/$($r.ImgId)/pexels-photo-$($r.ImgId).jpeg?auto=compress&cs=tinysrgb&w=600`" alt=`"$($r.Name)`" class=`"card-img`" loading=`"lazy`" />")
    [void]$sbIdx.AppendLine("          </div>")
    [void]$sbIdx.AppendLine("          <div class=`"card-body`">")
    [void]$sbIdx.AppendLine("            <div class=`"card-meta-top`"><span class=`"badge badge-district`">$($r.District)</span><span class=`"badge badge-type`">$($r.Type)</span></div>")
    [void]$sbIdx.AppendLine("            <h3 class=`"card-title`"><a href=`"quan-$($r.Num).html`">$($r.Name)</a></h3>")
    [void]$sbIdx.AppendLine("            <p class=`"card-desc`">$ds</p>")
    [void]$sbIdx.AppendLine("            <div class=`"card-footer`"><span class=`"price`">$sp</span><span class=`"stars`">★ $($r.Rating)</span></div>")
    [void]$sbIdx.AppendLine("          </div>")
    [void]$sbIdx.AppendLine("        </article>")
}
$newCardsHtml = $sbIdx.ToString()

# Replace cards section using regex
$pattern = '(?s)<div class="cards-grid">.*?</div>\s*<div class="section-cta">'
$indexHtml = [regex]::Replace($indexHtml, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) return '<div class="cards-grid">' + "`n" + $newCardsHtml + '      </div>' + "`n      " + '<div class="section-cta">' })

[System.IO.File]::WriteAllText("$baseDir\index.html", $indexHtml, (New-Object System.Text.UTF8Encoding($true)))
Write-Host "  -> index.html: 100 quan, $distCount districts"

# === 4. GOIY.HTML ===
Write-Host "Updating goiy.html..."
$goiyHtml = [System.IO.File]::ReadAllText("$baseDir\goiy.html", [System.Text.Encoding]::UTF8)

# Build new type options
$typeOpts = "-- Chọn loại --"
$types = @("Món Việt","Món Hàn","Món Nhật","Món Âu","Món Thái","Món Ấn","Món Hoa","Pizza","Món Mỹ","Món Chay","Hải sản","Món khác","Khác")
foreach ($t in $types) { $typeOpts += "</option><option>$t" }

# Build new district options
$distOpts2 = "-- Chọn quận --"
foreach ($d in $districts) { $distOpts2 += "</option><option>$d" }

# Replace storeType options
$goiyHtml = [regex]::Replace($goiyHtml, '(?s)<select id="storeType"[^>]*>.*?</select>', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) return '<select id="storeType" class="form-input" style="appearance:auto;"><option value="">' + $typeOpts + '</option></select>' })

# Replace storeDistrict options
$goiyHtml = [regex]::Replace($goiyHtml, '(?s)<select id="storeDistrict"[^>]*>.*?</select>', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) return '<select id="storeDistrict" class="form-input" style="appearance:auto;"><option value="">' + $distOpts2 + '</option></select>' })

[System.IO.File]::WriteAllText("$baseDir\goiy.html", $goiyHtml, (New-Object System.Text.UTF8Encoding($true)))
Write-Host "  -> goiy.html: dropdowns updated"

Write-Host ""
Write-Host "=== ALL MAIN PAGES UPDATED ==="
Write-Host "  khampha.html: 6 filters + $($restaurants.Count) cards"
Write-Host "  bando.html: $($restaurants.Count) markers, no area filter"
Write-Host "  index.html: 100 quan, $distCount districts"
Write-Host "  goiy.html: updated dropdowns"
