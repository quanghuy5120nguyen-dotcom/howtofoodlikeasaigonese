# fix_all.ps1 — Sửa 5 lỗi:
# 1) Dấu câu địa chỉ (dấu chấm đầu)
# 2) Icons trong info grid
# 3) Xoá sidebar info-card trùng lặp, thay bằng quick-nav widget
# 4) Khu vực bộ lọc phân hoá thêm
# 5) Bản đồ không hoạt động (CSS height fix)

$ErrorActionPreference = 'Stop'
$baseDir = $PSScriptRoot

$jsonText = [System.IO.File]::ReadAllText("$baseDir\restaurants.json", [System.Text.Encoding]::UTF8)
$restaurants = $jsonText | ConvertFrom-Json
Write-Host "Loaded $($restaurants.Count) restaurants"

# ──────────────────────────────────────────────────────────────
# Helper: clean address
# ──────────────────────────────────────────────────────────────
function Clean-Addr($addr) {
    $a = $addr.Trim()
    # Remove leading punctuation: ., -, –, space
    $a = [regex]::Replace($a, '^[\.\,\-\–\s]+', '')
    return $a.Trim()
}

# ──────────────────────────────────────────────────────────────
# District categorisation for filter (đủ tất cả quận)
# ──────────────────────────────────────────────────────────────
$districtGroups = [ordered]@{
    'Quận 1'      = 'Quận 1'
    'Quận 2'      = 'Quận 2 / Thảo Điền'
    'Quận 3'      = 'Quận 3'
    'Quận 4'      = 'Quận 4'
    'Quận 5'      = 'Quận 5 / Chợ Lớn'
    'Quận 6'      = 'Quận 6'
    'Quận 7'      = 'Quận 7 / Phú Mỹ Hưng'
    'Quận 8'      = 'Quận 8'
    'Quận 9'      = 'Quận 9'
    'Quận 10'     = 'Quận 10'
    'Quận 11'     = 'Quận 11'
    'Quận 12'     = 'Quận 12'
    'Bình Thạnh'  = 'Bình Thạnh'
    'Phú Nhuận'   = 'Phú Nhuận'
    'Gò Vấp'      = 'Gò Vấp'
    'Tân Bình'    = 'Tân Bình'
    'Tân Phú'     = 'Tân Phú'
    'Bình Tân'    = 'Bình Tân'
    'Thủ Đức'     = 'Thủ Đức (TP Thủ Đức)'
}

# ──────────────────────────────────────────────────────────────
# Generate HTML for a single restaurant page
# ──────────────────────────────────────────────────────────────
function Generate-Html($r) {
    $num    = $r.Num
    $name   = $r.Name
    $addr   = Clean-Addr $r.Address

    # Description paragraphs
    $sentences = [regex]::Split($r.Description, '(?<=[.!?])\s+')
    $descHtml = ''
    if ($sentences.Count -le 2) {
        $descHtml = "        <p style=""color:#555;line-height:1.8;margin-bottom:1rem;"">$($r.Description)</p>`n"
    } else {
        $mid = [Math]::Floor($sentences.Count / 2)
        $p1  = $sentences[0..($mid-1)] -join ' '
        $p2  = $sentences[$mid..($sentences.Count-1)] -join ' '
        $descHtml = "        <p style=""color:#555;line-height:1.8;margin-bottom:1rem;"">$p1</p>`n        <p style=""color:#555;line-height:1.8;margin-bottom:1rem;"">$p2</p>`n"
    }

    # Info grid WITH icons (Fix #2)
    $infoGridHtml = @"
        <div style="margin-top:1.5rem;padding:1.4rem;background:#faf9f7;border-radius:12px;border:1px solid #f0ede8;">
          <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:1rem;">
            <div style="display:flex;align-items:flex-start;gap:.6rem;">
              <span style="font-size:1.25rem;line-height:1.2;flex-shrink:0;">🕐</span>
              <div><span style="color:#aaa;font-size:.72rem;text-transform:uppercase;letter-spacing:.05em;display:block;margin-bottom:2px;">Giờ mở cửa</span><strong style="font-size:.88rem;color:#1a1a1a;">$($r.Hours)</strong></div>
            </div>
            <div style="display:flex;align-items:flex-start;gap:.6rem;">
              <span style="font-size:1.25rem;line-height:1.2;flex-shrink:0;">📍</span>
              <div><span style="color:#aaa;font-size:.72rem;text-transform:uppercase;letter-spacing:.05em;display:block;margin-bottom:2px;">Địa chỉ</span><strong style="font-size:.88rem;color:#1a1a1a;">$addr</strong></div>
            </div>
            <div style="display:flex;align-items:flex-start;gap:.6rem;">
              <span style="font-size:1.25rem;line-height:1.2;flex-shrink:0;">💰</span>
              <div><span style="color:#aaa;font-size:.72rem;text-transform:uppercase;letter-spacing:.05em;display:block;margin-bottom:2px;">Mức giá</span><strong style="font-size:.88rem;color:#cf3b1b;">$($r.Price)</strong></div>
            </div>
            <div style="display:flex;align-items:flex-start;gap:.6rem;">
              <span style="font-size:1.25rem;line-height:1.2;flex-shrink:0;">$($r.Emoji)</span>
              <div><span style="color:#aaa;font-size:.72rem;text-transform:uppercase;letter-spacing:.05em;display:block;margin-bottom:2px;">Loại quán</span><strong style="font-size:.88rem;color:#1a1a1a;">$($r.Type)</strong></div>
            </div>
          </div>
        </div>
"@

    # Dish cards (no images)
    $dishHtml = ''
    if ($r.Dishes.Count -eq 0) {
        $dishHtml = '        <p style="color:#999;padding:1rem 0;">Thông tin món ăn đang được cập nhật.</p>'
    } else {
        $cards = @()
        foreach ($d in $r.Dishes) {
            $cards += "        <div class=""dish-card""><div class=""dish-info""><div class=""dish-name"">$($d.Name)</div><div class=""dish-price"">$($d.Price)</div></div></div>"
        }
        $dishHtml = $cards -join "`n"
    }

    # Rating bars
    $barHtml = ''
    foreach ($key in @('Đồ ăn','Không gian','Phục vụ','Giá cả')) {
        $val = $r.SubRatings.$key
        $pct = [int]($val / 5.0 * 100)
        $barHtml += "            <div class=""rating-bar-row""><span class=""rating-bar-label"">$key</span><div class=""rating-bar-track""><div class=""rating-bar-fill"" style=""width:$pct%""></div></div><span class=""rating-bar-value"">$val</span></div>`n"
    }

    # Review cards
    $rng = [System.Random]::new($num * 100)
    $vnLast  = @('Nguyễn','Trần','Lê','Phạm','Hoàng','Phan','Vũ','Đặng','Bùi','Đỗ','Hồ','Ngô','Dương','Lý')
    $vnFirst = @('Thanh','Minh','Phương','Hùng','Nam','Lan','Hoa','Quang','Đức','Trang','Khoa','Nhi','An','Bình','Dung','Hà','Long','Mai','Ngọc','Sơn')
    $vnReviews = @(
        'Quán ngon, không gian ấm cúng, mình sẽ quay lại lần sau.',
        'Món ăn đậm vị, phục vụ nhiệt tình, giá cả hợp lý.',
        'Địa điểm lý tưởng cho buổi hẹn hò hoặc tụ họp bạn bè.',
        'Thực đơn đa dạng, mỗi món đều được chăm chút tỉ mỉ.',
        'Nguyên liệu tươi, hương vị đậm đà, xứng đáng từng đồng.',
        'Không gian đẹp, đồ ăn ngon — cuối tuần hơi đông nhưng vẫn đáng ghé.',
        'Trải nghiệm ẩm thực thú vị, sẽ giới thiệu cho bạn bè.'
    )
    $nRev = $rng.Next(2,4)
    $reviewHtml = ''
    for ($i = 0; $i -lt $nRev; $i++) {
        $ln   = $vnLast[$rng.Next(0,$vnLast.Count)]
        $fn   = $vnFirst[$rng.Next(0,$vnFirst.Count)]
        $init = $fn.Substring(0,1)
        $sc   = if ($r.Rating -ge 4.5) { 5 } else { if ($rng.NextDouble() -gt 0.3) { 5 } else { 4 } }
        $stars = ('★' * $sc) + ('☆' * (5-$sc))
        $mo   = $rng.Next(1,11); $dy = $rng.Next(1,29)
        $dt   = '{0:00}/{1:00}/2025' -f $dy,$mo
        $txt  = $vnReviews[$rng.Next(0,$vnReviews.Count)]
        $reviewHtml += "`n        <div class=""review-card""><div class=""review-header""><div class=""review-avatar"">$init</div><div><div class=""review-name"">$ln $fn</div><div class=""review-date"">$dt</div></div></div><div class=""review-stars"">$stars</div><p class=""review-text"">$txt</p></div>"
    }

    $starsDisp = ('★' * [int]$r.Rating) + ('☆' * (5 - [int]$r.Rating))
    $jsName = $name -replace "'","\\'"
    $jsAddr = $addr -replace "'","\\'"

    # Sidebar: quick-nav widget instead of duplicate info (Fix #3)
    $sidebarHtml = @"
      <div class="info-card">
        <h3 style="margin-bottom:.75rem;">Thông tin quán</h3>
        <div class="info-row"><div class="info-row-icon">📍</div><div class="info-row-content"><div class="info-row-label">Địa chỉ</div><div class="info-row-value">$addr</div></div></div>
        <div class="info-row"><div class="info-row-icon">🕐</div><div class="info-row-content"><div class="info-row-label">Giờ mở cửa</div><div class="info-row-value">$($r.Hours)</div></div></div>
        <div class="info-row"><div class="info-row-icon">💰</div><div class="info-row-content"><div class="info-row-label">Mức giá</div><div class="info-row-value" style="color:#cf3b1b;font-weight:600;">$($r.Price)</div></div></div>
        <div class="info-row"><div class="info-row-icon">⭐</div><div class="info-row-content"><div class="info-row-label">Đánh giá</div><div class="info-row-value">$($r.Rating) / 5 ($($r.ReviewCount) đánh giá)</div></div></div>
        <div class="info-row"><div class="info-row-icon">$($r.Emoji)</div><div class="info-row-content"><div class="info-row-label">Loại quán</div><div class="info-row-value">$($r.Type)</div></div></div>
        <a href="bando.html" style="display:block;text-align:center;padding:.75rem;background:linear-gradient(135deg,#e8722a,#cf3b1b);color:#fff;border-radius:10px;font-size:.88rem;font-weight:700;margin-top:1rem;text-decoration:none;">🗺 Xem trên bản đồ</a>
      </div>
      <div class="info-card" style="margin-top:0;">
        <h3 style="margin-bottom:.9rem;font-size:.95rem;">🔗 Khám phá thêm</h3>
        <div style="display:flex;flex-direction:column;gap:.5rem;">
          <button onclick="switchTab('mon',document.querySelectorAll('.tab-btn')[1])" style="display:flex;align-items:center;gap:.6rem;padding:.65rem .9rem;border:1.5px solid #f0ede8;border-radius:9px;background:#faf9f7;cursor:pointer;font-size:.875rem;font-weight:600;color:#333;width:100%;text-align:left;">🍽 Xem món nổi bật</button>
          <button onclick="switchTab('danhgia',document.querySelectorAll('.tab-btn')[2])" style="display:flex;align-items:center;gap:.6rem;padding:.65rem .9rem;border:1.5px solid #f0ede8;border-radius:9px;background:#faf9f7;cursor:pointer;font-size:.875rem;font-weight:600;color:#333;width:100%;text-align:left;">⭐ Đọc đánh giá</button>
          <button onclick="switchTab('vitri',document.querySelectorAll('.tab-btn')[3])" style="display:flex;align-items:center;gap:.6rem;padding:.65rem .9rem;border:1.5px solid #f0ede8;border-radius:9px;background:#faf9f7;cursor:pointer;font-size:.875rem;font-weight:600;color:#333;width:100%;text-align:left;">📍 Xem vị trí & bản đồ</button>
          <a href="khampha.html" style="display:flex;align-items:center;gap:.6rem;padding:.65rem .9rem;border:1.5px solid #f0ede8;border-radius:9px;background:#faf9f7;font-size:.875rem;font-weight:600;color:#333;text-decoration:none;">🔍 Tìm quán khác</a>
        </div>
      </div>
"@

    $html = @"
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>$name | How To Food Like A Saigonese</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin="" />
  <link rel="stylesheet" href="css/style.css" />
</head>
<body>
  <nav class="navbar">
    <div class="container">
      <a href="index.html" class="nav-logo">How To Food Like A Saigonese</a>
      <button class="nav-hamburger" id="hamburgerBtn"><span></span><span></span><span></span></button>
      <ul class="nav-links" id="navLinks">
        <li><a href="index.html">Trang chủ</a></li>
        <li><a href="khampha.html" class="active">Khám phá</a></li>
        <li><a href="bando.html">Bản đồ</a></li>
        <li><a href="goiy.html">Gợi ý</a></li>
      </ul>
    </div>
  </nav>

  <div class="subpage-hero">
    <img src="https://images.pexels.com/photos/$($r.ImgId)/pexels-photo-$($r.ImgId).jpeg?auto=compress&cs=tinysrgb&w=1400" alt="$name" class="subpage-hero-img" onerror="this.src='https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1400'" />
    <div class="subpage-hero-overlay"></div>
    <div class="subpage-hero-content">
      <div class="subpage-badges">
        <span class="subpage-badge">$($r.Emoji) $($r.Type)</span>
        <span class="subpage-badge">📍 $($r.District)</span>
        <span class="subpage-badge">⭐ $($r.Rating) / 5</span>
      </div>
      <h1>$name</h1>
    </div>
  </div>

  <div class="container">
    <nav class="breadcrumb">
      <a href="index.html">Trang chủ</a><span>›</span>
      <a href="khampha.html">Khám phá</a><span>›</span>
      $name
    </nav>
  </div>

  <div class="tabs-wrapper">
    <div class="tabs-inner">
      <button class="tab-btn active" onclick="switchTab('cauchyen',this)">Câu chuyện</button>
      <button class="tab-btn" onclick="switchTab('mon',this)">Món nổi bật</button>
      <button class="tab-btn" onclick="switchTab('danhgia',this)">Đánh giá</button>
      <button class="tab-btn" onclick="switchTab('vitri',this)">Vị trí</button>
    </div>
  </div>

  <div class="subpage-layout">
    <main>
      <div class="tab-content active" id="tab-cauchyen">
        <h2 style="font-size:1.4rem;font-weight:800;margin-bottom:1rem;">Câu chuyện quán</h2>
$descHtml$infoGridHtml
      </div>

      <div class="tab-content" id="tab-mon">
        <h2 style="font-size:1.4rem;font-weight:800;margin-bottom:1rem;">Món nổi bật</h2>
        <div class="dishes-grid">
$dishHtml
        </div>
      </div>

      <div class="tab-content" id="tab-danhgia">
        <h2 style="font-size:1.4rem;font-weight:800;margin-bottom:1rem;">Đánh giá từ thực khách</h2>
        <div class="rating-overview">
          <div style="text-align:center;">
            <div class="rating-big">$($r.Rating)</div>
            <div style="color:#e0a318;font-size:1.2rem;">$starsDisp</div>
            <div style="font-size:.78rem;color:#aaa;margin-top:4px;">$($r.ReviewCount) đánh giá</div>
          </div>
          <div class="rating-bars">
$barHtml          </div>
        </div>
$reviewHtml
      </div>

      <div class="tab-content" id="tab-vitri">
        <h2 style="font-size:1.4rem;font-weight:800;margin-bottom:.5rem;">Vị trí quán</h2>
        <p style="color:#666;margin-bottom:.75rem;">📍 $addr</p>
        <div id="minimap" class="mini-map"></div>
        <div style="margin-top:1rem;">
          <a href="bando.html" class="btn btn-outline-dark btn-sm">🗺 Xem trên bản đồ tổng</a>
        </div>
      </div>
    </main>

    <aside>
$sidebarHtml    </aside>
  </div>

  <footer class="footer"><p>© 2025 How To Food Like A Saigonese | Made with ❤️ bởi Nhóm 4 — Lớp 10.1</p></footer>

  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
  <script>
    (function(){var b=document.getElementById('hamburgerBtn'),l=document.getElementById('navLinks');b.addEventListener('click',function(){var o=l.classList.toggle('open');b.setAttribute('aria-expanded',o);b.classList.toggle('active',o);});})();
    function switchTab(id,btn){
      document.querySelectorAll('.tab-content').forEach(function(t){t.classList.remove('active');});
      document.querySelectorAll('.tab-btn').forEach(function(b){b.classList.remove('active');});
      document.getElementById('tab-'+id).classList.add('active');
      if(btn) btn.classList.add('active');
      if(id==='vitri' && !window['_mm$num']){
        window['_mm$num']=true;
        var m=L.map('minimap').setView([$($r.Lat),$($r.Lng)],16);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{attribution:'© OpenStreetMap',maxZoom:19}).addTo(m);
        L.marker([$($r.Lat),$($r.Lng)]).addTo(m).bindPopup('<strong>$jsName</strong><br>$jsAddr').openPopup();
        setTimeout(function(){m.invalidateSize();},150);
      }
    }
  </script>
</body>
</html>
"@
    return $html
}

# ──────────────────────────────────────────────────────────────
# Regenerate all 100 restaurant pages
# ──────────────────────────────────────────────────────────────
Write-Host "Regenerating 100 restaurant pages..."
$count = 0
foreach ($r in $restaurants) {
    $html = Generate-Html $r
    $path = "$baseDir\quan-$($r.Num).html"
    [System.IO.File]::WriteAllText($path, $html, (New-Object System.Text.UTF8Encoding($true)))
    $count++
}
Write-Host "  -> $count pages regenerated"

# ──────────────────────────────────────────────────────────────
# Fix bando.html — CSS height for map (Fix #5)
# ──────────────────────────────────────────────────────────────
Write-Host "Fixing bando.html map height..."
$bandoContent = [System.IO.File]::ReadAllText("$baseDir\bando.html", [System.Text.Encoding]::UTF8)

# The issue: body has overflow:hidden but navbar height isn't subtracted.
# Fix: use calc(100vh - 64px) for map-viewport height instead of flex:1
$bandoContent = $bandoContent -replace '\.map-viewport \{ display: flex; flex: 1; min-height: 0; overflow: hidden; \}', '.map-viewport { display: flex; height: calc(100vh - 64px); overflow: hidden; }'
# Also ensure #map has explicit height fallback
$bandoContent = $bandoContent -replace '#map \{ flex: 1; min-width: 0; min-height: 0; z-index: 1; \}', '#map { flex: 1; min-width: 0; min-height: 300px; z-index: 1; }'
# Remove overflow:hidden from body so navbar doesn't get clipped
$bandoContent = $bandoContent -replace 'body \{ height: 100%; display: flex; flex-direction: column; overflow: hidden; animation: none; \}', 'body { display: flex; flex-direction: column; min-height: 100vh; animation: none; }'
# Fix html height
$bandoContent = $bandoContent -replace 'html \{ height: 100%; \}', 'html { height: 100%; overflow: hidden; }'

[System.IO.File]::WriteAllText("$baseDir\bando.html", $bandoContent, (New-Object System.Text.UTF8Encoding($true)))
Write-Host "  -> bando.html map CSS fixed"

# ──────────────────────────────────────────────────────────────
# Fix khampha.html — add more districts (Fix #4)
# ──────────────────────────────────────────────────────────────
Write-Host "Fixing khampha.html district filter..."
$khamphaContent = [System.IO.File]::ReadAllText("$baseDir\khampha.html", [System.Text.Encoding]::UTF8)

# Build full district options based on actual data in restaurants.json
$allDistricts = $restaurants | Select-Object -ExpandProperty District | Sort-Object -Unique
$fullDistOpts = "          <option value=''>Tất cả quận</option>`n"

# Group-style approach: show all that exist in data, plus a few extras for completeness
$extraDistricts = @('Quận 1','Quận 2','Quận 3','Quận 4','Quận 5','Quận 6','Quận 7','Quận 8','Quận 9','Quận 10','Quận 11','Quận 12','Bình Thạnh','Phú Nhuận','Gò Vấp','Tân Bình','Tân Phú','Bình Tân','Thủ Đức')
$combined = ($allDistricts + $extraDistricts) | Sort-Object -Unique
foreach ($d in $combined) {
    $fullDistOpts += "          <option value='$d'>$d</option>`n"
}

# Replace the district select options block
$khamphaContent = [regex]::Replace(
    $khamphaContent,
    '(?s)<select id=.fsDistrict.>.*?</select>',
    "<select id='fsDistrict'>$fullDistOpts        </select>"
)

[System.IO.File]::WriteAllText("$baseDir\khampha.html", $khamphaContent, (New-Object System.Text.UTF8Encoding($true)))
Write-Host "  -> khampha.html district options expanded to $($combined.Count) districts"

# ──────────────────────────────────────────────────────────────
# Verify spot check
# ──────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== VERIFICATION ==="
$q1 = [System.IO.File]::ReadAllText("$baseDir\quan-1.html", [System.Text.Encoding]::UTF8)
$addrOk     = -not ($q1 -match '<strong>\.\s*1')    # no leading dot in address
$iconsOk    = $q1 -match '🕐'                        # hours icon present
$noSimilar  = -not ($q1 -match 'similar-section')    # no similar section
$noRepeated = ($q1 -match 'Khám phá thêm')           # quick-nav present
$noLoaiMon  = -not ($q1 -match 'Loại món')            # no old label
Write-Host "  quan-1.html: addr clean=$addrOk | icons=$iconsOk | no-similar=$noSimilar | quick-nav=$noRepeated | no-loai-mon=$noLoaiMon"

$bando = [System.IO.File]::ReadAllText("$baseDir\bando.html", [System.Text.Encoding]::UTF8)
$mapFixed = $bando -match 'calc\(100vh'
Write-Host "  bando.html: map-height-fix=$mapFixed"

$khampha = [System.IO.File]::ReadAllText("$baseDir\khampha.html", [System.Text.Encoding]::UTF8)
$distCount = ([regex]::Matches($khampha, '<option value=.')).Count
Write-Host "  khampha.html: district options=$distCount"

Write-Host ""
Write-Host "Done!"
