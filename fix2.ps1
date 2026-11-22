# fix2.ps1
# 1) Subpage: xoá hoàn toàn <aside>, layout full-width
# 2) 4 tab -> 1 trang scroll liên tục (sections)
# 3) bando.html: sửa triệt để CSS + JS bản đồ

$ErrorActionPreference = 'Stop'
$baseDir = $PSScriptRoot
$utf8bom  = New-Object System.Text.UTF8Encoding($true)

$jsonText     = [System.IO.File]::ReadAllText("$baseDir\restaurants.json", [System.Text.Encoding]::UTF8)
$restaurants  = $jsonText | ConvertFrom-Json
Write-Host "Loaded $($restaurants.Count) restaurants"

# ── helpers ──────────────────────────────────────────────────
function Clean-Addr($a) { return ([regex]::Replace($a.Trim(),'^[\.\,\-\–\s]+','')).Trim() }

# ── Generate one restaurant page ─────────────────────────────
function Make-Page($r) {
    $num   = $r.Num
    $name  = $r.Name
    $addr  = Clean-Addr $r.Address

    # Description paragraphs
    $sents = [regex]::Split($r.Description, '(?<=[.!?])\s+')
    if ($sents.Count -le 2) {
        $descHtml = "        <p class=""sp-desc"">$($r.Description)</p>"
    } else {
        $mid  = [Math]::Floor($sents.Count / 2)
        $p1   = $sents[0..($mid-1)] -join ' '
        $p2   = $sents[$mid..($sents.Count-1)] -join ' '
        $descHtml = "        <p class=""sp-desc"">$p1</p>`n        <p class=""sp-desc"">$p2</p>"
    }

    # Info chips (inline pill row)
    $infoChips = @"
        <div class="sp-chips">
          <span class="sp-chip"><span class="sp-chip-icon">🕐</span><span class="sp-chip-lbl">Giờ mở cửa</span><span class="sp-chip-val">$($r.Hours)</span></span>
          <span class="sp-chip"><span class="sp-chip-icon">📍</span><span class="sp-chip-lbl">Địa chỉ</span><span class="sp-chip-val">$addr</span></span>
          <span class="sp-chip"><span class="sp-chip-icon">💰</span><span class="sp-chip-lbl">Mức giá</span><span class="sp-chip-val sp-price">$($r.Price)</span></span>
          <span class="sp-chip"><span class="sp-chip-icon">$($r.Emoji)</span><span class="sp-chip-lbl">Loại quán</span><span class="sp-chip-val">$($r.Type)</span></span>
        </div>
"@

    # Dish cards
    if ($r.Dishes.Count -eq 0) {
        $dishHtml = '<p class="sp-empty">Thông tin đang được cập nhật.</p>'
    } else {
        $cards = $r.Dishes | ForEach-Object {
            "          <div class=""dish-card""><div class=""dish-info""><div class=""dish-name"">$($_.Name)</div><div class=""dish-price"">$($_.Price)</div></div></div>"
        }
        $dishHtml = $cards -join "`n"
    }

    # Rating bars
    $barHtml = ''
    foreach ($k in @('Đồ ăn','Không gian','Phục vụ','Giá cả')) {
        $v   = $r.SubRatings.$k
        $pct = [int]($v / 5.0 * 100)
        $barHtml += "            <div class=""rating-bar-row""><span class=""rating-bar-label"">$k</span><div class=""rating-bar-track""><div class=""rating-bar-fill"" style=""width:$pct%""></div></div><span class=""rating-bar-value"">$v</span></div>`n"
    }

    # Reviews
    $rng  = [System.Random]::new($num * 100)
    $lns  = @('Nguyễn','Trần','Lê','Phạm','Hoàng','Phan','Vũ','Đặng','Bùi','Đỗ','Hồ','Ngô','Dương','Lý')
    $fns  = @('Thanh','Minh','Phương','Hùng','Nam','Lan','Hoa','Quang','Đức','Trang','Khoa','Nhi','An','Bình','Dung','Hà','Long','Mai','Ngọc','Sơn')
    $txts = @('Quán ngon, không gian ấm cúng, mình sẽ quay lại lần sau.','Món ăn đậm vị, phục vụ nhiệt tình, giá cả hợp lý.','Địa điểm lý tưởng cho buổi hẹn hò hoặc tụ họp bạn bè.','Thực đơn đa dạng, mỗi món đều được chăm chút tỉ mỉ.','Nguyên liệu tươi, hương vị đậm đà, xứng đáng từng đồng.','Không gian đẹp, đồ ăn ngon — cuối tuần hơi đông nhưng vẫn đáng ghé.','Trải nghiệm ẩm thực thú vị, sẽ giới thiệu cho bạn bè.')
    $nRev = $rng.Next(2,4)
    $revHtml = ''
    for ($i=0; $i -lt $nRev; $i++) {
        $ln=$lns[$rng.Next(0,$lns.Count)]; $fn=$fns[$rng.Next(0,$fns.Count)]
        $sc = if ($r.Rating -ge 4.5){5} else {if ($rng.NextDouble() -gt 0.3){5} else {4}}
        $st = ('★'*$sc)+('☆'*(5-$sc))
        $mo=$rng.Next(1,11); $dy=$rng.Next(1,29)
        $dt='{0:00}/{1:00}/2025' -f $dy,$mo
        $tx=$txts[$rng.Next(0,$txts.Count)]
        $revHtml += "`n        <div class=""review-card""><div class=""review-header""><div class=""review-avatar"">$($fn.Substring(0,1))</div><div><div class=""review-name"">$ln $fn</div><div class=""review-date"">$dt</div></div></div><div class=""review-stars"">$st</div><p class=""review-text"">$tx</p></div>"
    }

    $starsDisp = ('★'*[int]$r.Rating)+('☆'*(5-[int]$r.Rating))
    $jsName = $name -replace "'","\\'"
    $jsAddr = $addr -replace "'","\\'"

    # ── HTML ──────────────────────────────────────────────────
    return @"
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>$name | How To Food Like A Saigonese</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>
  <link rel="stylesheet" href="css/style.css"/>
  <style>
    /* ── subpage one-page layout ── */
    .sp-body{max-width:860px;margin:0 auto;padding:2rem 1.5rem 4rem;}
    .sp-section{margin-bottom:2.5rem;}
    .sp-section-title{font-size:1.15rem;font-weight:800;color:#1a1a1a;margin-bottom:1rem;padding-bottom:.5rem;border-bottom:2px solid #f0ede8;display:flex;align-items:center;gap:.45rem;}
    .sp-desc{color:#555;line-height:1.85;margin-bottom:.75rem;font-size:.975rem;}
    .sp-empty{color:#aaa;font-size:.9rem;padding:.5rem 0;}
    /* chips */
    .sp-chips{display:grid;grid-template-columns:repeat(2,1fr);gap:.75rem;margin-top:1.25rem;}
    @media(max-width:560px){.sp-chips{grid-template-columns:1fr;}}
    .sp-chip{display:flex;align-items:flex-start;gap:.65rem;padding:.85rem 1rem;background:#faf9f7;border:1.5px solid #f0ede8;border-radius:10px;}
    .sp-chip-icon{font-size:1.3rem;line-height:1;flex-shrink:0;margin-top:1px;}
    .sp-chip-lbl{font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.05em;color:#aaa;display:block;margin-bottom:2px;}
    .sp-chip-val{font-size:.88rem;font-weight:600;color:#1a1a1a;display:block;line-height:1.4;}
    .sp-chip-val.sp-price{color:#cf3b1b;}
    /* map CTA button */
    .sp-map-btn{display:inline-flex;align-items:center;gap:.5rem;margin-top:.75rem;padding:.6rem 1.2rem;background:linear-gradient(135deg,#e8722a,#cf3b1b);color:#fff;border-radius:9px;font-size:.875rem;font-weight:700;text-decoration:none;}
    /* minimap */
    .sp-minimap{width:100%;height:320px;border-radius:12px;overflow:hidden;border:1.5px solid #e8e0da;margin-top:.75rem;}
  </style>
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
    <img src="https://images.pexels.com/photos/$($r.ImgId)/pexels-photo-$($r.ImgId).jpeg?auto=compress&cs=tinysrgb&w=1400" alt="$name" class="subpage-hero-img" onerror="this.src='https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1400'"/>
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

  <div class="sp-body">

    <!-- 1. Câu chuyện + info chips -->
    <section class="sp-section" id="sec-cauchyen">
      <h2 class="sp-section-title">📖 Câu chuyện quán</h2>
$descHtml
$infoChips    </section>

    <!-- 2. Món nổi bật -->
    <section class="sp-section" id="sec-mon">
      <h2 class="sp-section-title">🍽 Món nổi bật</h2>
      <div class="dishes-grid">
$dishHtml
      </div>
    </section>

    <!-- 3. Đánh giá -->
    <section class="sp-section" id="sec-danhgia">
      <h2 class="sp-section-title">⭐ Đánh giá từ thực khách</h2>
      <div class="rating-overview">
        <div style="text-align:center;">
          <div class="rating-big">$($r.Rating)</div>
          <div style="color:#e0a318;font-size:1.2rem;">$starsDisp</div>
          <div style="font-size:.78rem;color:#aaa;margin-top:4px;">$($r.ReviewCount) đánh giá</div>
        </div>
        <div class="rating-bars">
$barHtml        </div>
      </div>
$revHtml
    </section>

    <!-- 4. Vị trí -->
    <section class="sp-section" id="sec-vitri">
      <h2 class="sp-section-title">📍 Vị trí quán</h2>
      <p style="color:#666;margin-bottom:.5rem;">$addr</p>
      <div id="minimap" class="sp-minimap"></div>
      <a href="bando.html" class="sp-map-btn" style="margin-top:.9rem;">🗺 Xem trên bản đồ tổng</a>
    </section>

  </div><!-- end sp-body -->

  <footer class="footer"><p>© 2025 How To Food Like A Saigonese | Made with ❤️ bởi Nhóm 4 — Lớp 10.1</p></footer>

  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
  <script>
    // Nav toggle
    (function(){
      var b=document.getElementById('hamburgerBtn'),l=document.getElementById('navLinks');
      b.addEventListener('click',function(){var o=l.classList.toggle('open');b.setAttribute('aria-expanded',o);b.classList.toggle('active',o);});
    })();
    // Minimap — init on IntersectionObserver so it renders correctly
    (function(){
      var done=false;
      function initMap(){
        if(done)return; done=true;
        var m=L.map('minimap',{scrollWheelZoom:false}).setView([$($r.Lat),$($r.Lng)],16);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{attribution:'© OpenStreetMap',maxZoom:19}).addTo(m);
        L.marker([$($r.Lat),$($r.Lng)]).addTo(m).bindPopup('<strong>$jsName</strong><br>$jsAddr').openPopup();
        setTimeout(function(){m.invalidateSize();},200);
      }
      if('IntersectionObserver' in window){
        var obs=new IntersectionObserver(function(entries){if(entries[0].isIntersecting){initMap();obs.disconnect();}},{threshold:0.1});
        obs.observe(document.getElementById('minimap'));
      } else { initMap(); }
    })();
  </script>
</body>
</html>
"@
}

# ── Regenerate all 100 pages ─────────────────────────────────
Write-Host "Regenerating 100 subpages (no sidebar, one-page scroll)..."
foreach ($r in $restaurants) {
    $html = Make-Page $r
    [System.IO.File]::WriteAllText("$baseDir\quan-$($r.Num).html", $html, $utf8bom)
}
Write-Host "  -> Done"

# ── Fix bando.html completely ─────────────────────────────────
Write-Host "Rewriting bando.html map fix..."

$bandoRaw = [System.IO.File]::ReadAllText("$baseDir\bando.html", [System.Text.Encoding]::UTF8)

# The root cause: body is flex-column, navbar is 64px, footer is ~36px.
# map-viewport needs calc(100vh - 64px - 36px). But the safest fix:
# use position:fixed for map-viewport with top/bottom offsets.
# Strategy: rewrite only the <style> block (lines 8-41) keeping the data/JS intact.

# Replace the entire <style> block inside <head>
$oldStyle = [regex]::Match($bandoRaw, '(?s)<style>.*?</style>').Value
$newStyle = @'
<style>
    /* bando page — full-viewport map */
    *, *::before, *::after { box-sizing: border-box; }
    html, body { margin: 0; padding: 0; height: 100%; }
    body { display: flex; flex-direction: column; overflow: hidden; animation: none; }

    .map-viewport {
      display: flex;
      flex: 1;
      min-height: 0;          /* critical flex shrink */
      overflow: hidden;
    }

    /* ── Left sidebar ── */
    .map-sidebar {
      width: 300px;
      flex-shrink: 0;
      display: flex;
      flex-direction: column;
      overflow: hidden;
      background: #fff;
      border-right: 1px solid #e8e0da;
      box-shadow: 2px 0 12px rgba(0,0,0,.05);
      z-index: 10;
    }
    .sidebar-hd { padding: 1.1rem 1.2rem 0.9rem; border-bottom: 1px solid #f0ede8; flex-shrink: 0; }
    .sidebar-hd h2 { font-size: .975rem; font-weight: 700; color: #1a1a1a; margin-bottom: .8rem; display: flex; align-items: center; gap: .4rem; }
    .sidebar-badge { font-size: .68rem; font-weight: 700; background: #cf3b1b; color: #fff; padding: 2px 8px; border-radius: 99px; }
    .btn-loc { display: flex; align-items: center; justify-content: center; gap: .4rem; width: 100%; padding: .55rem; background: rgba(207,59,27,.07); color: #cf3b1b; border: 1.5px solid rgba(207,59,27,.25); border-radius: 8px; font-size: .85rem; font-weight: 600; cursor: pointer; transition: all .2s; }
    .btn-loc:hover { background: rgba(207,59,27,.14); border-color: #cf3b1b; }
    .sidebar-list { flex: 1; overflow-y: auto; padding: .45rem .55rem; }
    .sidebar-list::-webkit-scrollbar { width: 4px; }
    .sidebar-list::-webkit-scrollbar-thumb { background: #ddd; border-radius: 2px; }
    .s-item { display: flex; align-items: center; gap: .65rem; padding: .6rem .7rem; border-radius: 9px; cursor: pointer; border: 1.5px solid transparent; transition: all .18s; margin-bottom: 2px; }
    .s-item:hover, .s-item.active { background: rgba(207,59,27,.05); border-color: rgba(207,59,27,.2); }
    .s-emoji { width: 32px; height: 32px; border-radius: 50%; background: rgba(207,59,27,.1); display: flex; align-items: center; justify-content: center; font-size: .95rem; flex-shrink: 0; }
    .s-info { flex: 1; min-width: 0; }
    .s-name { font-size: .825rem; font-weight: 700; color: #1a1a1a; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .s-sub { font-size: .73rem; color: #888; }
    .s-star { color: #e0a318; font-weight: 700; }
    .sidebar-ft { padding: .6rem 1.1rem; font-size: .76rem; color: #bbb; border-top: 1px solid #f0ede8; font-weight: 600; background: #fafaf9; flex-shrink: 0; }

    /* ── Map fills remaining space ── */
    #map { flex: 1; min-width: 0; min-height: 0; }

    /* ── Footer ── */
    .map-footer { background: #1a1a1a; color: #555; text-align: center; font-size: .78rem; padding: .65rem; flex-shrink: 0; z-index: 2; }

    /* ── Popup ── */
    .leaflet-popup-content-wrapper { border-radius: 10px !important; box-shadow: 0 4px 20px rgba(0,0,0,.18) !important; padding: 0 !important; }
    .leaflet-popup-content { margin: 0 !important; }
    .popup-box { padding: 14px 16px; min-width: 190px; max-width: 240px; }
    .popup-name { font-size: .95rem; font-weight: 700; color: #1a1a1a; margin-bottom: 6px; }
    .popup-row { font-size: .82rem; color: #666; margin-bottom: 3px; }
    .popup-star { color: #e0a318; font-weight: 700; }
    .popup-btn { display: inline-block; margin-top: 10px; color: #cf3b1b; font-size: .875rem; font-weight: 700; border: 1.5px solid #cf3b1b; padding: 5px 14px; border-radius: 6px; text-decoration: none; transition: all .2s; }
    .popup-btn:hover { background: #cf3b1b; color: #fff; }

    /* ── Mobile ── */
    @media (max-width: 768px) {
      body { overflow: auto; }
      .map-viewport { flex-direction: column; height: auto; overflow: visible; }
      .map-sidebar { width: 100%; height: auto; max-height: 220px; }
      #map { height: 55vh; min-height: 300px; flex: none; }
    }
  </style>
'@

$bandoRaw = $bandoRaw -replace [regex]::Escape($oldStyle), $newStyle

# Also fix the JS: after buildList(), invalidate map size to ensure tiles load
$bandoRaw = $bandoRaw -replace '(buildList\(\);)', '$1' + "`n    setTimeout(function(){map.invalidateSize(true);},400);"

[System.IO.File]::WriteAllText("$baseDir\bando.html", $bandoRaw, $utf8bom)
Write-Host "  -> bando.html fully rewritten"

# ── Verify ────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== VERIFY ==="
$q1 = [System.IO.File]::ReadAllText("$baseDir\quan-1.html", [System.Text.Encoding]::UTF8)
Write-Host "  No <aside>: $(-not ($q1 -match '<aside'))"
Write-Host "  No tabs: $(-not ($q1 -match 'tab-btn'))"
Write-Host "  Has sp-chips: $($q1 -match 'sp-chips')"
Write-Host "  Has sp-section: $($q1 -match 'sp-section')"
Write-Host "  Has minimap: $($q1 -match 'minimap')"
Write-Host "  IntersectionObserver: $($q1 -match 'IntersectionObserver')"
$bando = [System.IO.File]::ReadAllText("$baseDir\bando.html", [System.Text.Encoding]::UTF8)
Write-Host "  bando flex:1 min-height:0: $($bando -match 'min-height: 0')"
Write-Host "  bando invalidateSize: $($bando -match 'invalidateSize')"
Write-Host ""
Write-Host "All done!"
