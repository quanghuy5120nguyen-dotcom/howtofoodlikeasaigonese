# Generator: parses restaurant-data.txt and creates all 100 quan-N.html files
# Modifications vs original template:
#   - Removed "Anh" tab (button + content)
#   - Removed "Quan tuong tu" section
#   - Removed prev/next nav
#   - Removed dish images (only name + price)
#   - Changed "Loai mon" to "Loai quan"

$ErrorActionPreference = "Stop"
$baseDir = $PSScriptRoot

# ══════════════════════════════════════════════════════════════
# RESTAURANT NAMES (indexed 0-99 for restaurants 1-100)
# ══════════════════════════════════════════════════════════════
$Names = @(
    "Bếp mẹ ỉn","De Tham Restaurant","Hoa Túc","Phở Việt Nam","Cocotte",
    "Phin Saigon Vietnamese Food & Coffee","Vietnam House Restaurant","Hanoi Corner",
    "MANA Station – Tiệm Ăn Món Việt","Hanuri Korean Fast Food","Hankki Deli Cao Thắng",
    "Clover Korean House Food","DOOBOO Korean Kitchen","Korea House – Quán Ăn Hàn Quốc",
    "Bặp Đến Đây (밥덴데이)","The Olive Steakhouse","Ciao Bella","CHIIK Steak & Pasta",
    "B3 Steakhouse","Pizza Chất","Pizza 4P's","Amano Local Eatery","Oliver's Pizza",
    "Sushi 79 – Hồ Xuân Hương","Shoday Ramen","Fast Sushi","Yuzu Omakase",
    "Italiani's Pizza","Cơm Niêu Sài Gòn","San Fu Lou","Bori Korean BBQ","Pendolasco",
    "Le Corto","Quán Bụi","Bếp Nhà Lục Tỉnh","Dim Tu Tac","Baozi","Nook Korean Bistro",
    "Bros BBQ","Miwaku Premium","Robata An Yokocho","El Gaucho Argentinian Steakhouse",
    "Marcel Gourmet Burger","TukTuk Thai Bistro","Cà Bót Thai Cuisine","Baba's Kitchen",
    "Sol Kitchen & Bar","Maison Marou Flagship","Propaganda Bistro",
    "Secret Garden - Cơm Niêm Việt Nam","Ụt Ụt - The Ox Not Burger",
    "Hum Vegetarian, Café & Restaurant","Crab Shack","Shri Restaurant & Lounge",
    "Quán Lủi","Mặn Mòi","Den Long - Home Cooked Vietnamese Restaurant","The Deck Saigon",
    "Octobar","Bánh Canh Ghẹ Ngọc Hương","Chả Cá Lã Vọng Hà Nội","Mì Cay Sasin",
    "Lẩu Bò Tươi Sài Gòn","Bánh Mì Huỳnh Hoa","Quán Ốc Đào","Lẩu Nấm Ashima",
    "Hủ Tiếu Nam Vang Thành Đạt","Nhà Hàng Chay Tib","Bún Bò Huế Đông Ba",
    "Mì Cạch Ký (Mì Khô Thượng Hải)","CCCP Saigon","House of Merlin","OKRA FoodBar",
    "SOLOBOX","Xóm Chợ Cũ","Tiệm Nướng Tàu Lửa","Đào Liễu",
    "An House Craft Beer & Egg Coffee","Nhà Anh","Quán Ân Điển","Con Ốc Quán",
    "Quán Bấc","Fluid Saigon","Blanc. Restaurant","ÚNU Art inspired Eatery & Bar",
    "Lạc Thái","Tien Tien Thai Cuisine","Somtam ZAAP","Tandoor Indian Restaurant",
    "Namaste India","Halen's Indian Curry","Natraj Indian Cuisine Restaurant",
    "La Villa French Restaurant","Kabin – Saigon","Shan Dimsum",
    "Indigo Japanese Restaurant","Onigiriya En","Hai's Restaurant","Nhà hàng Bê Vàng",
    "Yakiuo Ishikawa Saigon"
)

# Type standardization map
$TypeMap = @{
    "Món Việt"="Món Việt";"Ẩm thực Việt Nam"="Món Việt";"Ẩm thực Nam Bộ (Việt Nam)"="Món Việt"
    "Món Việt truyền thống"="Món Việt";"Món Việt gia đình"="Món Việt";"Món Việt / Đồ nhậu"="Món Việt"
    "Món Việt / Bánh canh"="Món Việt";"Món Huế / Bún bò"="Món Việt";"Món Bắc truyền thống"="Món Việt"
    "Món Việt / Lẩu bò"="Món Việt";"Món Việt / Hủ tiếu Nam Vang"="Món Việt"
    "Thức ăn đường phố / Bánh mì"="Món Việt";"Quán ốc / Món Việt"="Món Việt"
    "Việt Nam, có món chay"="Món Việt";"Món Việt, hotpot"="Món Việt"
    "Món Hàn"="Món Hàn";"Ẩm thực Hàn Quốc"="Món Hàn";"Món Hàn / Mì cay"="Món Hàn"
    "Món Nhật"="Món Nhật";"Ẩm thực Nhật Bản"="Món Nhật";"Ẩm thực Nhật Bản / Âu"="Món Nhật"
    "Nhật Bản, hải sản, omakase"="Món Nhật";"Nhật Bản"="Món Nhật"
    "Món Âu"="Món Âu";"Ẩm thực Ý (Âu)"="Món Âu";"Ẩm thực Pháp / Âu"="Món Âu"
    "Ẩm thực Pháp / Âu (Burger)"="Món Âu";"Ẩm thực Âu (Tráng miệng & Không gian Cafe)"="Món Âu"
    "Món Âu / Fine Dining"="Món Âu";"Món Âu - Á / Ven sông"="Món Âu"
    "Món Địa Trung Hải / Tapas"="Món Âu";"Pháp, fine dining"="Món Âu"
    "Ẩm thực Tây Bán Cầu (Âu / Mỹ)"="Món Âu";"Ẩm thực Địa Trung Hải / Mỹ La-tinh"="Món Âu"
    "Ẩm thực Thái Lan"="Món Thái";"Thái Lan"="Món Thái";"Thái Lan, Isan"="Món Thái"
    "Ẩm thực Ấn Độ"="Món Ấn";"Ấn Độ"="Món Ấn"
    "Ẩm thực Trung Hoa (Quảng Đông)"="Món Hoa";"Ẩm thực Trung Hoa"="Món Hoa"
    "Món Hoa / Mì gia"="Món Hoa";"Trung Hoa, Quảng Đông"="Món Hoa"
    "Ẩm thực Đài Loan / Á Hiện Đại"="Món Hoa";"Hải sản, Trung Hoa, Nhật Bản"="Hải sản"
    "Pizza"="Pizza";"Món pizza"="Pizza"
    "Món Mỹ / BBQ"="Món Mỹ";"Món Barbecue, đồ nướng"="Món Mỹ";"Bánh burger"="Món Mỹ"
    "Món Chay"="Món Chay";"Ẩm thực Chay"="Món Chay"
    "Hải sản / Món Âu - Á"="Hải sản";"Món hải sản"="Hải sản"
    "Món Nga/Ukraine"="Món khác";"Món Mexico, hải sản"="Món khác"
    "Món Châu Á"="Món khác";"Món Á / Lẩu Nấm"="Món khác"
}

$EmojiMap = @{"Món Việt"="🍜";"Món Hàn"="🍖";"Món Nhật"="🍣";"Món Âu"="🍝";"Món Thái"="🥘";"Món Ấn"="🍛";"Món Hoa"="🥟";"Pizza"="🍕";"Món Mỹ"="🍔";"Món Chay"="🥗";"Hải sản"="🦐";"Món khác"="🌍"}

$PexelsImg = @{"Món Việt"="1775043";"Món Hàn"="7187423";"Món Nhật"="2098086";"Món Âu"="1640777";"Món Thái"="8472992";"Món Ấn"="1560694";"Món Hoa"="1683809";"Pizza"="7083528";"Món Mỹ"="1633578";"Món Chay"="1640777";"Hải sản"="699953";"Món khác"="1640777"}

$DistrictCoords = @{
    "Quận 1"=@(10.7769,106.7009);"Quận 3"=@(10.7798,106.6900);"Quận 5"=@(10.7520,106.6610)
    "Quận 10"=@(10.7708,106.6720);"Bình Thạnh"=@(10.8000,106.7100);"Phú Nhuận"=@(10.8000,106.6700)
    "Gò Vấp"=@(10.8400,106.6500);"Thủ Đức"=@(10.8500,106.7300);"Quận 2"=@(10.8000,106.7400)
    "Quận 12"=@(10.8600,106.6400);"Quận 4"=@(10.7580,106.7020);"Quận 7"=@(10.7300,106.7210)
    "Tân Bình"=@(10.8000,106.6500)
}

# Known types sorted by length descending (for matching longest first)
$KnownTypes = @(
    "Ẩm thực Địa Trung Hải / Mỹ La-tinh","Ẩm thực Âu (Tráng miệng & Không gian Cafe)",
    "Ẩm thực Pháp / Âu (Burger)","Ẩm thực Tây Bán Cầu (Âu / Mỹ)",
    "Ẩm thực Đài Loan / Á Hiện Đại","Ẩm thực Nhật Bản / Âu",
    "Ẩm thực Trung Hoa (Quảng Đông)","Ẩm thực Nam Bộ (Việt Nam)",
    "Món Việt / Hủ tiếu Nam Vang","Món Barbecue, đồ nướng",
    "Thức ăn đường phố / Bánh mì","Món Địa Trung Hải / Tapas",
    "Món Bắc truyền thống","Món Huế / Bún bò","Món Hàn / Mì cay",
    "Món Việt / Lẩu bò","Món Việt / Bánh canh","Món Việt / Đồ nhậu",
    "Món Việt gia đình","Món Việt truyền thống","Quán ốc / Món Việt",
    "Món Âu / Fine Dining","Món Âu - Á / Ven sông","Hải sản / Món Âu - Á",
    "Món Nga/Ukraine","Ẩm thực Hàn Quốc","Ẩm thực Việt Nam",
    "Ẩm thực Trung Hoa","Ẩm thực Nhật Bản","Ẩm thực Pháp / Âu",
    "Ẩm thực Thái Lan","Ẩm thực Ý (Âu)","Ẩm thực Ấn Độ","Ẩm thực Chay",
    "Nhật Bản, hải sản, omakase","Hải sản, Trung Hoa, Nhật Bản",
    "Món Mexico, hải sản","Món Mỹ / BBQ","Bánh burger","Món Châu Á",
    "Món Á / Lẩu Nấm","Pháp, fine dining","Trung Hoa, Quảng Đông",
    "Thái Lan, Isan","Món Việt, hotpot","Việt Nam, có món chay",
    "Món hải sản","Món Việt","Món Âu","Món Hàn","Món Nhật","Món Chay","Pizza","Món pizza","Thái Lan","Ấn Độ","Nhật Bản","Món Hoa"
) | Sort-Object {-$_.Length} | Select-Object -Unique

# ══════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ══════════════════════════════════════════════════════════════

function Get-StdType($raw) {
    if ($TypeMap.ContainsKey($raw)) { return $TypeMap[$raw] }
    foreach ($k in $TypeMap.Keys) {
        if ($raw -like "*$k*" -or $k -like "*$raw*") { return $TypeMap[$k] }
    }
    return "Món khác"
}

function Get-District($addr) {
    $districts = @("Quận 12","Quận 1","Quận 2","Quận 3","Quận 4","Quận 5","Quận 6","Quận 7","Quận 8","Quận 9","Quận 10","Quận 11","Bình Thạnh","Phú Nhuận","Gò Vấp","Tân Bình","Tân Phú","Bình Tân","Thủ Đức")
    foreach ($d in $districts) { if ($addr -match [regex]::Escape($d)) { return $d } }
    $m = [regex]::Match($addr, 'Q\.?\s*(\d+)')
    if ($m.Success) { return "Quận $($m.Groups[1].Value)" }
    return "Quận 1"
}

function Get-Random($seed, $min, $max) {
    $rng = New-Object System.Random($seed)
    return $rng.NextDouble() * ($max - $min) + $min
}

function Parse-Dishes($dishesStr) {
    $dishes = @()
    $parts = $dishesStr.Trim() -split ';'
    foreach ($part in $parts) {
        $part = $part.Trim()
        if (-not $part) { continue }
        $idx = $part.LastIndexOf(':')
        if ($idx -gt 0) {
            $name = $part.Substring(0, $idx).Trim()
            $price = $part.Substring($idx + 1).Trim()
        } else {
            $pm = [regex]::Match($part, '(\d[\d.,]*\s*(?:đ|VNĐ|k))')
            if ($pm.Success) {
                $name = $part.Substring(0, $pm.Index).Trim().TrimEnd('-','–')
                $price = $part.Substring($pm.Index).Trim()
            } else {
                $name = $part; $price = "Liên hệ"
            }
        }
        if (-not $price) { $price = "Liên hệ" }
        $dishes += ,@{Name=$name; Price=$price}
    }
    return $dishes[0..([Math]::Min(5, $dishes.Count - 1))]
}

function Parse-Restaurant($num, $name, $line) {
    $rest = $line.Trim() -replace '^\d+\s+', ''
    if ($rest.StartsWith($name)) {
        $rest = $rest.Substring($name.Length).Trim()
    } else {
        $idx = $rest.IndexOf($name)
        if ($idx -ge 0) { $rest = $rest.Substring($idx + $name.Length).Trim() }
    }

    # Find price
    $pricePattern = '(\d{1,3}(?:\.\d{3})*\s*[–\-]\s*\d{1,3}(?:\.\d{3})*\s*(?:đ|VNĐ)?\s*/?\s*(?:người|phần)?)'
    $pm = [regex]::Match($rest, $pricePattern)
    $priceStr = ""; $priceEnd = 0
    if ($pm.Success) { $priceStr = $pm.Value.Trim(); $priceEnd = $pm.Index + $pm.Length }
    else { $priceStr = "Liên hệ" }

    $description = if ($pm.Success) { $rest.Substring(0, $pm.Index).Trim() } else { $rest.Substring(0, [Math]::Min(200, $rest.Length)).Trim() }

    $afterPrice = if ($priceEnd -gt 0) { $rest.Substring($priceEnd).Trim() } else { "" }

    # Find type
    $typeStr = ""; $typeEnd = 0
    foreach ($kt in $KnownTypes) {
        $idx = $afterPrice.IndexOf($kt)
        if ($idx -ge 0) { $typeStr = $kt; $typeEnd = $idx + $kt.Length; break }
    }

    $address = if ($typeStr) { $afterPrice.Substring(0, $afterPrice.IndexOf($typeStr)).Trim().TrimEnd('.',' ',',') } else { $afterPrice.Substring(0, [Math]::Min(200, $afterPrice.Length)).Trim() }

    $afterType = if ($typeEnd -gt 0) { $afterPrice.Substring($typeEnd).Trim() } else { "" }

    # Find hours - look for time patterns
    $hoursStr = ""; $hoursEnd = 0
    $hourMatches = [regex]::Matches($afterType, '(\d{1,2}:\d{2}\s*[–\-]\s*\d{1,2}:\d{2}(?:\s*\([^)]*\))?)')
    if ($hourMatches.Count -gt 0) {
        $hoursList = @()
        $lastEnd = 0
        foreach ($hm in $hourMatches) {
            $hoursList += $hm.Value.Trim()
            $lastEnd = $hm.Index + $hm.Length
        }
        $hoursStr = $hoursList -join "; "
        $hoursEnd = $lastEnd
    } else {
        if ($afterType -match '24/24') { $hoursStr = "Mở cửa 24/24"; $hoursEnd = $afterType.IndexOf('24/24') + 4 }
        else { $hoursStr = "Liên hệ"; $hoursEnd = 0 }
    }

    # Dishes = everything after hours
    $dishesStr = if ($hoursEnd -gt 0) { $afterType.Substring($hoursEnd).Trim() } else { $afterType.Trim() }
    $dishes = Parse-Dishes $dishesStr

    $district = Get-District $address
    $stdType = Get-StdType $typeStr
    if (-not $stdType) { $stdType = "Món khác" }
    $emoji = if ($EmojiMap.ContainsKey($stdType)) { $EmojiMap[$stdType] } else { "🍽" }

    # Rating generation
    $rng = [System.Random]::new($num * 42)
    $baseRating = [Math]::Round($rng.NextDouble() * 0.9 + 4.0, 1)
    if ($priceStr -match '1\.500|2\.000|3\.500|1\.000') { $baseRating = [Math]::Round($rng.NextDouble() * 0.4 + 4.5, 1) }
    elseif ($priceStr -match '500\.000|800\.000') { $baseRating = [Math]::Round($rng.NextDouble() * 0.4 + 4.4, 1) }
    $reviewCount = $rng.Next(48, 236)

    $subRatings = @{
        "Đồ ăn" = [Math]::Round([Math]::Min(5.0, $baseRating + $rng.NextDouble() * 0.3), 1)
        "Không gian" = [Math]::Round([Math]::Max(3.5, $baseRating - $rng.NextDouble() * 0.8), 1)
        "Phục vụ" = [Math]::Round([Math]::Max(3.5, $baseRating - $rng.NextDouble() * 0.5), 1)
        "Giá cả" = [Math]::Round([Math]::Max(3.5, $baseRating - $rng.NextDouble() * 0.4), 1)
    }

    # Coordinates
    $coords = if ($DistrictCoords.ContainsKey($district)) { $DistrictCoords[$district] } else { @(10.7769, 106.7009) }
    $lat = [Math]::Round($coords[0] + ($rng.NextDouble() - 0.5) * 0.01, 4)
    $lng = [Math]::Round($coords[1] + ($rng.NextDouble() - 0.5) * 0.01, 4)

    $imgId = if ($PexelsImg.ContainsKey($stdType)) { $PexelsImg[$stdType] } else { "1640777" }

    return @{
        Num=$num; Name=$name; Description=$description; Price=$priceStr
        Address=$(if ($address) { $address } else { "Liên hệ" })
        TypeRaw=$typeStr; Type=$stdType; Emoji=$emoji; District=$district
        Hours=$hoursStr; Dishes=$dishes; Rating=$baseRating; ReviewCount=$reviewCount
        SubRatings=$subRatings; Lat=$lat; Lng=$lng; ImgId=$imgId
    }
}

function Generate-Html($r) {
    $num = $r.Num
    $name = $r.Name

    # Split description into 2 paragraphs
    $sentences = [regex]::Split($r.Description, '(?<=[.!?])\s+')
    $descHtml = ""
    if ($sentences.Count -le 2) {
        $descHtml = "        <p style=""color:#555;line-height:1.8;margin-bottom:1rem;"">$($r.Description)</p>`n"
    } else {
        $mid = [Math]::Floor($sentences.Count / 2)
        $p1 = $sentences[0..($mid-1)] -join " "
        $p2 = $sentences[$mid..($sentences.Count-1)] -join " "
        $descHtml = "        <p style=""color:#555;line-height:1.8;margin-bottom:1rem;"">$p1</p>`n        <p style=""color:#555;line-height:1.8;margin-bottom:1rem;"">$p2</p>`n"
    }

    # Dish cards (no images)
    $dishHtml = ""
    if ($r.Dishes.Count -eq 0) {
        $dishHtml = '        <p style="color:#999;">Thông tin món ăn đang được cập nhật.</p>'
    } else {
        $dishCards = @()
        foreach ($d in $r.Dishes) {
            $dishCards += "        <div class=""dish-card"">`n            <div class=""dish-info""><div class=""dish-name"">$($d.Name)</div><div class=""dish-price"">$($d.Price)</div></div>`n          </div>"
        }
        $dishHtml = $dishCards -join "`n"
    }

    # Rating bars
    $barHtml = ""
    foreach ($key in @("Đồ ăn","Không gian","Phục vụ","Giá cả")) {
        $val = $r.SubRatings[$key]
        $pct = [int]($val / 5.0 * 100)
        $barHtml += "            <div class=""rating-bar-row""><span class=""rating-bar-label"">$key</span><div class=""rating-bar-track""><div class=""rating-bar-fill"" style=""width:$pct%""></div></div><span class=""rating-bar-value"">$val</span></div>`n"
    }

    # Review cards
    $rng2 = [System.Random]::new($num * 100)
    $vnLast = @("Nguyễn","Trần","Lê","Phạm","Hoàng","Phan","Vũ","Đặng","Bùi","Đỗ","Hồ","Ngô","Dương","Lý")
    $vnFirst = @("Thanh","Minh","Phương","Hùng","Nam","Lan","Hoa","Quang","Đức","Trang","Khoa","Nhi","An","Bình","Dung","Hà","Long","Mai","Ngọc","Sơn")
    $vnReviews = @(
        "Quán ngon, không gian ấm cúng, mình sẽ quay lại lần sau.",
        "Món ăn đậm vị, phục vụ nhiệt tình, giá hợp lý cho chất lượng.",
        "Địa điểm lý tưởng cho buổi hẹn hò hoặc tụ họp bạn bè.",
        "Thực đơn đa dạng, mỗi món đều được chăm chút tỉ mỉ.",
        "Nước dùng đậm đà, nguyên liệu tươi, đáng đồng tiền bát cơm.",
        "Không gian đẹp, đồ ăn ngon, nhưng cuối tuần hơi đông.",
        "Giá hơi cao nhưng xứng đáng với trải nghiệm ẩm thực."
    )
    $numReviews = $rng2.Next(2, 4)
    $reviewHtml = ""
    for ($i = 0; $i -lt $numReviews; $i++) {
        $ln = $vnLast[$rng2.Next(0, $vnLast.Count)]
        $fn = $vnFirst[$rng2.Next(0, $vnFirst.Count)]
        $fullName = "$ln $fn"
        $initials = $fn.Substring(0, 1)
        $starCount = if ($r.Rating -ge 4.5) { 5 } else { if ($rng2.NextDouble() -gt 0.3) { 5 } else { 4 } }
        $stars = ("★" * $starCount) + ("☆" * (5 - $starCount))
        $month = $rng2.Next(1, 11)
        $day = $rng2.Next(1, 29)
        $dateStr = "{0:00}/{1:00}/2025" -f $day, $month
        $revText = $vnReviews[$rng2.Next(0, $vnReviews.Count)]
        $reviewHtml += "`n        <div class=""review-card"">`n          <div class=""review-header""><div class=""review-avatar"">$initials</div><div><div class=""review-name"">$fullName</div><div class=""review-date"">$dateStr</div></div></div>`n          <div class=""review-stars"">$stars</div>`n          <p class=""review-text"">$revText</p>`n        </div>"
    }

    $starsDisplay = ("★" * [int]$r.Rating) + ("☆" * (5 - [int]$r.Rating))
    $jsName = $name -replace "'", "\'" -replace '"', '&quot;'
    $jsAddr = $r.Address -replace "'", "\'" -replace '"', '&quot;'

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
$descHtml        <div style="margin-top:1.5rem;padding:1.2rem;background:#faf9f7;border-radius:10px;border:1px solid #f0ede8;">
          <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:.75rem;font-size:.875rem;">
            <div><span style="color:#aaa;font-size:.75rem;text-transform:uppercase;letter-spacing:.04em;">Giờ mở cửa</span><br><strong>$($r.Hours)</strong></div>
            <div><span style="color:#aaa;font-size:.75rem;text-transform:uppercase;letter-spacing:.04em;">Địa chỉ</span><br><strong>$($r.Address)</strong></div>
            <div><span style="color:#aaa;font-size:.75rem;text-transform:uppercase;letter-spacing:.04em;">Mức giá</span><br><strong>$($r.Price)</strong></div>
            <div><span style="color:#aaa;font-size:.75rem;text-transform:uppercase;letter-spacing:.04em;">Loại quán</span><br><strong>$($r.Type)</strong></div>
          </div>
        </div>
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
            <div style="color:#e0a318;font-size:1.2rem;">$starsDisplay</div>
            <div style="font-size:.78rem;color:#aaa;margin-top:4px;">$($r.ReviewCount) đánh giá</div>
          </div>
          <div class="rating-bars">
$barHtml          </div>
        </div>
$reviewHtml
      </div>

      <div class="tab-content" id="tab-vitri">
        <h2 style="font-size:1.4rem;font-weight:800;margin-bottom:.5rem;">Vị trí quán</h2>
        <p style="color:#666;margin-bottom:.5rem;">📍 $($r.Address)</p>
        <div id="minimap" class="mini-map"></div>
        <div style="margin-top:1rem;">
          <a href="bando.html" class="btn btn-outline-dark btn-sm">🗺 Xem trên bản đồ tổng</a>
        </div>
      </div>
    </main>

    <aside>
      <div class="info-card">
        <h3>Thông tin quán</h3>
        <div class="info-row"><div class="info-row-icon">📍</div><div class="info-row-content"><div class="info-row-label">Địa chỉ</div><div class="info-row-value">$($r.Address)</div></div></div>
        <div class="info-row"><div class="info-row-icon">🕐</div><div class="info-row-content"><div class="info-row-label">Giờ mở cửa</div><div class="info-row-value">$($r.Hours)</div></div></div>
        <div class="info-row"><div class="info-row-icon">💰</div><div class="info-row-content"><div class="info-row-label">Mức giá</div><div class="info-row-value">$($r.Price)</div></div></div>
        <div class="info-row"><div class="info-row-icon">⭐</div><div class="info-row-content"><div class="info-row-label">Đánh giá</div><div class="info-row-value">$($r.Rating) / 5 ($($r.ReviewCount) đánh giá)</div></div></div>
        <div class="info-row"><div class="info-row-icon">🍽</div><div class="info-row-content"><div class="info-row-label">Loại quán</div><div class="info-row-value">$($r.Type)</div></div></div>
        <a href="bando.html" class="btn-map-full" style="display:block;text-align:center;padding:.7rem;background:linear-gradient(135deg,#e8722a,#cf3b1b);color:#fff;border-radius:10px;font-size:.88rem;font-weight:700;margin-top:1rem;text-decoration:none;">🗺 Xem trên bản đồ</a>
      </div>
    </aside>
  </div>

  <footer class="footer"><p>© 2025 How To Food Like A Saigonese | Made with ❤️ bởi Nhóm 4 — Lớp 10.1</p></footer>

  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
  <script>
    (function(){var b=document.getElementById('hamburgerBtn'),l=document.getElementById('navLinks');b.addEventListener('click',function(){var o=l.classList.toggle('open');b.setAttribute('aria-expanded',o);b.classList.toggle('active',o);});})();
    function switchTab(id,btn){
      document.querySelectorAll('.tab-content').forEach(function(t){t.classList.remove('active');});
      document.querySelectorAll('.tab-btn').forEach(function(b){b.classList.remove('active');});
      document.getElementById('tab-'+id).classList.add('active');
      btn.classList.add('active');
      if(id==='vitri' && !window['_minimap$num']){
        window['_minimap$num']=true;
        var m=L.map('minimap').setView([$($r.Lat),$($r.Lng)],16);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{attribution:'© OpenStreetMap',maxZoom:19}).addTo(m);
        L.marker([$($r.Lat),$($r.Lng)]).addTo(m).bindPopup('<strong>$jsName</strong><br>$jsAddr').openPopup();
        setTimeout(function(){m.invalidateSize();},100);
      }
    }
  </script>
</body>
</html>
"@

    return $html
}

# ══════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════

Write-Host "Parsing restaurant data..."
$content = Get-Content "$baseDir\restaurant-data.txt" -Raw -Encoding UTF8
$lines = $content.Trim() -split "`n"

$restaurants = @()
$current = ""
foreach ($line in $lines) {
    $line = $line.Trim()
    if (-not $line) { continue }
    if ($line -match '^(\d+)\s+' -and [int]$matches[1] -ge 1 -and [int]$matches[1] -le 100) {
        if ($current) { $restaurants += $current }
        $current = $line
    } elseif ($current) {
        $current += " " + $line
    }
}
if ($current) { $restaurants += $current }

Write-Host "Found $($restaurants.Count) restaurant entries"

$parsed = @()
foreach ($r in $restaurants) {
    if ($r -match '^(\d+)\s+') {
        $num = [int]$matches[1]
        if ($num -lt 1 -or $num -gt 100) { continue }
        $name = if ($num -le $Names.Count) { $Names[$num - 1] } else { "" }
        $parsed += Parse-Restaurant $num $name $r
    }
}

Write-Host "Parsed $($parsed.Count) restaurants"

# Save JSON
$jsonData = $parsed | ConvertTo-Json -Depth 5
$jsonData | Out-File "$baseDir\restaurants.json" -Encoding UTF8
Write-Host "Saved restaurants.json"

# Generate HTML files
Write-Host "Generating HTML files..."
foreach ($r in $parsed) {
    $html = Generate-Html $r
    $filepath = "$baseDir\quan-$($r.Num).html"
    $html | Out-File $filepath -Encoding UTF8
}

Write-Host "Generated $($parsed.Count) HTML files"

# Summary
Write-Host ""
Write-Host "=== SUMMARY ==="
Write-Host "Total restaurants: $($parsed.Count)"
$types = $parsed | Group-Object Type | Sort-Object Count -Descending
Write-Host "Type distribution:"
foreach ($t in $types) { Write-Host "  $($t.Name): $($t.Count)" }
Write-Host ""
Write-Host "First 3:"
foreach ($r in $parsed[0..2]) { Write-Host "  #$($r.Num): $($r.Name) | $($r.Type) | $($r.District) | $($r.Price)" }
Write-Host "Last 3:"
foreach ($r in $parsed[($parsed.Count-3)..($parsed.Count-1)]) { Write-Host "  #$($r.Num): $($r.Name) | $($r.Type) | $($r.District) | $($r.Price)" }
