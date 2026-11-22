# fix_broken.ps1 — Sửa 30 quán bị parse sai bằng dữ liệu hardcode chính xác
$ErrorActionPreference = 'Stop'
$baseDir = $PSScriptRoot
$utf8bom = New-Object System.Text.UTF8Encoding($true)

# Dữ liệu đúng cho từng quán bị lỗi: [addr, hours, price, type, emoji, dishes[]]
# dishes là mảng "tên: giá"
$correct = @{
  22 = @{ addr='200/25 Lê Thánh Tôn, khu vực Bến Thành'; hours='Sáng: 10:00–14:00; Tối: 17:00–22:00'; price='200.000 – 300.000đ/người'; type='Pizza'; emoji='🍕'; dishes=@('Mì ý thủ công bò hầm: 210.000đ','Cá hồi nướng áp chảo sốt bơ chanh: 290.000đ','Salad Burrata & cà rốt nướng: 190.000đ','Bánh tiramisu truyền thống: 95.000đ') }
  55 = @{ addr='32 Nguyễn Hữu Cầu, Phường Tân Định, Quận 1, TP.HCM'; hours='16:00 – 23:30'; price='100.000 – 200.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Gà nướng mắm nhĩ: 220.000đ','Lẩu cá kèo lá giang: 180.000đ','Sụn gà rang muối: 95.000đ','Bắp bò ngâm mắm: 120.000đ') }
  56 = @{ addr='39 Ngô Đức Kế, Phường Bến Nghé, Quận 1, TP.HCM'; hours='07:00 – 22:30'; price='200.000 – 400.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Thịt luộc cà phua mắm tôm: 120.000đ','Canh cua rau đay: 90.000đ','Chả cá Lã Vọng: 180.000đ','Nem cua bể: 110.000đ') }
  57 = @{ addr='130/2 Ngô Đức Kế, Phường Bến Nghé, Quận 1, TP.HCM'; hours='11:00 – 22:00'; price='100.000 – 250.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Thịt kho tiêu trong niêu đất: 95.000đ','Đậu hũ nhồi thịt sốt cà chua: 85.000đ','Canh khổ qua dồn thịt: 80.000đ','Mực xào chua ngọt: 130.000đ') }
  58 = @{ addr='38 Nguyễn Ư Dĩ, Phường Thảo Điền, TP. Thủ Đức, TP.HCM'; hours='08:00 – 00:00'; price='500.000 – 1.500.000đ/người'; type='Món Âu'; emoji='🍝'; dishes=@('Cá hồi áp chảo sốt bơ chanh: 480.000đ','Bò Úc nướng sốt vang đỏ: 750.000đ','Mì Ý hải sản sốt cà chua tươi: 350.000đ','Bánh ngọt tráng miệng: 160.000đ') }
  59 = @{ addr='8 Bis Công Trường Quốc Tế, Phường 6, Quận 3, TP.HCM'; hours='16:00 – 01:00 sáng hôm sau'; price='200.000 – 450.000đ/người'; type='Món Âu'; emoji='🍝'; dishes=@('Mực chiên giòn kiểu Hy Lạp: 170.000đ','Bánh mì dẹt nướng phô mai: 140.000đ','Xiên thịt cừu nướng thảo mộc: 210.000đ','Khoai tây nướng sốt tỏi: 90.000đ') }
  60 = @{ addr='91 Nguyễn Thái Sơn, Phường 4, Quận Gò Vấp, TP.HCM'; hours='07:00 – 22:00'; price='50.000 – 120.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Bánh canh ghẹ nguyên con: 110.000đ','Bánh canh tôm thịt đặc biệt: 75.000đ','Chả cá thác lác chiên: 45.000đ','Quẩy giòn: 15.000đ') }
  61 = @{ addr='3 Hồ Xuân Hương, Phường Võ Thị Sáu, Quận 3, TP.HCM'; hours='10:00 – 22:00'; price='150.000 – 300.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Phần chả cá Lã Vọng đặc biệt: 160.000đ/người','Lòng cá xào thì là: 120.000đ','Canh đầu cá nấu dọc mùng: 110.000đ','Chả cá viên chiên: 80.000đ') }
  62 = @{ addr='11 Tô Hiến Thành, Phường 13, Quận 10, TP.HCM'; hours='09:00 – 22:00'; price='50.000 – 100.000đ/người'; type='Món Hàn'; emoji='🍖'; dishes=@('Mì cay bò hải sản: 75.000đ','Kimbap truyền thống: 55.000đ','Tokbokki phô mai: 65.000đ','Gà rán sốt cay: 80.000đ') }
  63 = @{ addr='56 Nguyễn Văn Đậu, Phường 6, Quận Bình Thạnh, TP.HCM'; hours='15:00 – 23:00'; price='150.000 – 250.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Lẩu bò thập cẩm: 200.000đ','Bắp bò nhúng dấm: 180.000đ','Đuôi bò hầm sả: 150.000đ','Gân bò xào sa tế: 110.000đ') }
  64 = @{ addr='26 Lê Thị Riêng, Phường Bến Thành, Quận 1, TP.HCM'; hours='06:00 – 21:00'; price='50.000 – 75.000đ/phần'; type='Món Việt'; emoji='🍜'; dishes=@('Bánh mì đặc biệt thập cẩm: 68.000đ','Bánh mì bơ pate thêm chả: 65.000đ','Pate gan heo hũ: 85.000đ/hũ') }
  66 = @{ addr='35A Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1, TP.HCM'; hours='10:00 – 22:00'; price='350.000 – 600.000đ/người'; type='Hải sản'; emoji='🦐'; dishes=@('Nấm Gan Bò Mỹ: 185.000đ/phần','Thịt bò Wagyu nhúng lẩu: 420.000đ','Nước lẩu bổ dưỡng Ashima: 150.000đ','Nem nấm hải sản: 120.000đ') }
  67 = @{ addr='34 Nguyễn Huy Tự, Phường Đa Kao, Quận 1, TP.HCM'; hours='Mở cửa 24/24'; price='50.000 – 85.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Hủ tiếu Nam Vang khô đặc biệt: 75.000đ','Hủ tiếu nước xí quách: 70.000đ','Mì tôm mực: 70.000đ','Xí quách thêm: 40.000đ') }
  68 = @{ addr='170 Trần Quang Khải, Phường Tân Định, Quận 1, TP.HCM'; hours='08:30 – 21:30'; price='150.000 – 300.000đ/người'; type='Món Chay'; emoji='🥗'; dishes=@('Cơm hấp lá sen: 110.000đ','Lẩu nấm Tib: 280.000đ','Bánh cuốn chay Huế: 75.000đ','Vịt quay chay sốt nấm: 135.000đ') }
  69 = @{ addr='207 Nguyễn Trãi, Phường Nguyễn Cư Trinh, Quận 1, TP.HCM'; hours='06:00 – 22:30'; price='60.000 – 100.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Bún bò đặc biệt đầy đủ: 85.000đ','Bún bò nạm gân chả: 70.000đ','Bánh bèo chén Huế: 50.000đ/khay','Bánh nít ram: 50.000đ') }
  70 = @{ addr='114 Ký Con, Phường Nguyễn Thái Bình, Quận 1, TP.HCM'; hours='06:00–13:00 & 16:00–21:00'; price='50.000 – 90.000đ/người'; type='Món Hoa'; emoji='🥟'; dishes=@('Mì khô xá xíu sườn kho: 75.000đ','Mì hoành thánh tôm tươi: 65.000đ','Hủ tiếu mì thập cẩm: 70.000đ','Hoành thánh chiên: 50.000đ') }
  71 = @{ addr='48A Nguyễn Bỉnh Khiêm, Phường Tân Định, TP.HCM'; hours='Hằng ngày 10:30–21:30'; price='200.000 – 300.000đ/người'; type='Món khác'; emoji='🌍'; dishes=@('Thịt heo xiên nướng (pork shashlyk): 195.000đ','Bò hầm kiểu Nga (beef goulash): 167.000đ','Gà xiên nướng (chicken shashlyk): 144.000đ','Súp củ dền Borscht: 64.000đ') }
  72 = @{ addr='178/1 Pasteur, Phường Sài Gòn, TP.HCM'; hours='Hằng ngày 18:00–01:00'; price='200.000 – 400.000đ/người'; type='Pizza'; emoji='🍕'; dishes=@('Pizza bò lá lốt: 220.000đ','Pizza hải sản: 250.000đ','Cánh gà chiên giòn: 150.000đ','Khoai tây chiên sốt nấm truffle: 120.000đ') }
  73 = @{ addr='2 Lê Văn Miến, Phường An Khánh, TP.HCM'; hours='T2: 17:30–22:00; T4–T7: 17:30–23:00; CN: 17:30–22:00'; price='300.000 – 600.000đ/người'; type='Món khác'; emoji='🌍'; dishes=@('Phở bò tartare: 240.000đ','Thai grilled okra: 160.000đ','Duck tacos (2 pieces): 210.000đ','Grilled octopus: 340.000đ') }
  74 = @{ addr='252 Lý Tự Trọng, Phường Bến Thành, TP.HCM'; hours='Hằng ngày 10:00–00:00'; price='150.000 – 200.000đ/người'; type='Món Mỹ'; emoji='🍔'; dishes=@('Beef Burger (bò Úc, bacon, cheddar): 175.000đ','Truffle Beef Burger (bò sốt truffle và nấm): 185.000đ','Duck Confit Burger (vịt confit, cheddar): 180.000đ','Chicken Burger (gà chiên giòn, coleslaw): 145.000đ') }
  75 = @{ addr='35 Lý Tự Trọng, Phường Sài Gòn, TP.HCM'; hours='Hằng ngày 10:00–21:30'; price='100.000 – 200.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Gỏi mít non thịt luộc: 85.000đ','Bánh bèo chén: 12.000đ/chén','Nước đậu rang truyền thống: 35.000đ') }
  76 = @{ addr='28 Đường Linh Đông, Hiệp Bình, TP.HCM'; hours='Hằng ngày 15:00–00:00'; price='100.000 – 200.000đ/người'; type='Món Mỹ'; emoji='🍔'; dishes=@('Ba chỉ bò nướng: 89.000đ','Ba chỉ heo nướng: 79.000đ','Chân gà nướng: 59.000đ','Bạch tuộc nướng: 129.000đ') }
  77 = @{ addr='27/27 Huỳnh Tịnh Của, Phường Xuân Hòa, TP.HCM'; hours='10:30–15:00, 17:00–21:00 (thứ Hai có thể nghỉ)'; price='200.000 – 300.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Trứng chiên ngải cứu: 65.000đ','Ngọn su su xào tỏi: 75.000đ','Cá rô phi chiên giòn: 150.000đ','Ba chỉ kho: 120.000đ') }
  78 = @{ addr='68/3 Nguyễn Thái Bình, TP.HCM'; hours='Hằng ngày 10:00–23:00'; price='100.000 – 250.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Cà phê trứng: 55.000đ','Cà phê chồn: 90.000đ','Thịt trâu gác bếp: 150.000đ','Gà nướng kiểu vùng cao: 180.000đ') }
  79 = @{ addr='206 Pasteur, Phường Xuân Hòa, TP.HCM'; hours='Hằng ngày 10:00–22:00'; price='100.000 – 200.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Cơm chiên bò Wagyu: 180.000đ','Bò Wagyu nướng: 250.000đ','Cánh gà chiên: 100.000đ','Gỏi bò: 120.000đ') }
  80 = @{ addr='5/5 Nguyễn Siêu, Phường Sài Gòn, TP.HCM'; hours='06:00–22:00'; price='100.000 – 200.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Gỏi cuốn: 40.000đ/phần','Bánh mì Việt Nam: 35.000đ','Cơm món Việt: 65.000đ','Cà phê sữa đá: 30.000đ') }
  81 = @{ addr='150/39 Nguyễn Trãi, Phường Bến Thành, TP.HCM'; hours='08:30–14:00, 16:00–22:00'; price='100.000 – 200.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Chả ốc: 90.000đ','Ốc xào me: 100.000đ','Gỏi ốc: 100.000đ','Lẩu ốc: 200.000đ/nồi') }
  82 = @{ addr='36/3 Lê Lợi, Phường Sài Gòn, TP.HCM'; hours='10:00–21:00'; price='50.000 – 100.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Bún đậu hũ nước tương: 45.000đ','Bún ba rọi sốt cay: 65.000đ','Bún thịt nướng: 55.000đ','Đậu hũ nhà làm sốt tiêu: 60.000đ') }
  83 = @{ addr='39 Nguyễn Thị Diệu, Phường Võ Thị Sáu, Quận 3, TP.HCM'; hours='T3–CN: 17:00–23:00 (nghỉ T2)'; price='300.000 – 400.000đ/người'; type='Món Âu'; emoji='🍝'; dishes=@('Gà nướng: 180.000đ','Sườn ăn kèm cơm chiên: 220.000đ','Bạch tuộc nướng xiên: 180.000đ','Bánh croquette: 100.000đ') }
  84 = @{ addr='178/180D Hai Bà Trưng, Phường Tân Định, TP.HCM'; hours='T3–CN: 17:30–23:00 (nghỉ T2)'; price='500.000 – 1.000.000đ/người'; type='Món Âu'; emoji='🍝'; dishes=@('Khai vị theo mùa: 180.000đ','Salad hải sản: 250.000đ','Món chính thịt bò: 450.000đ','Tráng miệng chocolate: 150.000đ') }
  92 = @{ addr='41 Bùi Thị Xuân, khu vực Bến Thành, TP.HCM'; hours='Khoảng 10:00–22:30'; price='150.000 – 300.000đ/người'; type='Món Ấn'; emoji='🍛'; dishes=@('Cà ri gà: 140.000–200.000đ','Gà Tandoori: 180.000–280.000đ','Cơm Biryani: 120.000–180.000đ','Bánh naan: 35.000–60.000đ') }
  93 = @{ addr='14 Ngô Quang Huy, khu vực An Khánh, TP.HCM'; hours='Trưa: T5–CN; Tối: T3–CN'; price='1.500.000 – 3.500.000đ/người'; type='Món Âu'; emoji='🍝'; dishes=@('Thăn nội bò Black Angus: 1.990.000đ','Sườn cừu New Zealand: 1.990.000đ','Thăn nội bò Wagyu A5+: 3.090.000đ','Bánh táo Apple Tart: 490.000đ') }
  94 = @{ addr='Tầng 1, Renaissance Riverside Hotel, 8–15 Tôn Đức Thắng, TP.HCM'; hours='11:30–14:30 & 18:00–22:00'; price='500.000 – 1.000.000đ/người'; type='Món Hoa'; emoji='🥟'; dishes=@('Gà Quý Phi: 288.000đ++','Bánh bao mực than tre: 188.000đ++','Món cua sốt trứng cua: 288.000đ++','Dimsum gọi món: giá tùy món') }
  95 = @{ addr='57–59 Phù Đổng Thiên Vương, khu vực Quận 5, TP.HCM'; hours='7:00–14:00 & 17:00–21:00'; price='100.000 – 250.000đ/người'; type='Món Hoa'; emoji='🥟'; dishes=@('Há cảo tôm: 50.000–80.000đ/phần','Xíu mại: 45.000–70.000đ/phần','Bánh bao kim sa: 35.000–55.000đ/phần','Mì xào hải sản: 100.000–160.000đ') }
  96 = @{ addr='232 Nguyễn Đình Chiểu, TP.HCM'; hours='11:00–14:00 & 17:00–22:00'; price='200.000 – 400.000đ/người'; type='Món Nhật'; emoji='🍣'; dishes=@('Tôm chiên xù sốt tartar: 165.000đ','Tempura tôm và rau củ: 159.000đ','Bạch tuộc chiên giòn: 120.000đ','Đậu phụ chiên sốt nấm: 75.000đ') }
  97 = @{ addr='40 Thảo Điền, khu vực An Khánh, TP.HCM'; hours='7:00–20:00 hằng ngày'; price='50.000 – 100.000đ/người'; type='Món Nhật'; emoji='🍣'; dishes=@('Cơm nắm cá hồi nướng: 45.000đ','Cơm nắm mơ muối: 45.000đ','Cơm nắm cá ngừ mayonnaise: 45.000đ','Cơm nắm tôm tempura: 60.000đ') }
  98 = @{ addr='257 Lý Tự Trọng, khu vực Bến Thành, TP.HCM'; hours='Khoảng 10:00–23:30'; price='150.000 – 300.000đ/người'; type='Món Việt'; emoji='🍜'; dishes=@('Phở bò: 139.000đ','Vịt quay: 219.000đ','Bò lúc lắc kiểu Việt: 195.000đ','Phở xào hải sản: 171.000đ') }
  99 = @{ addr='261–263 An Dương Vương, khu vực Chợ Quán, TP.HCM'; hours='10:00–24:00'; price='300.000 – 800.000đ/người'; type='Hải sản'; emoji='🦐'; dishes=@('Bụng cá hồi: 300.000đ','Cá ngừ vây xanh Nhật Bản: 750.000đ','Cá hồi nigiri: 120.000đ/2 miếng','Cơm chiên tỏi: 250.000đ') }
 100 = @{ addr='38 Thái Văn Lung, khu vực trung tâm TP.HCM'; hours='Khoảng 11:00–14:00 & 18:00–22:00'; price='800.000 – 2.000.000đ/người'; type='Món Nhật'; emoji='🍣'; dishes=@('Cá theo mùa nướng kiểu Nhật: 200.000–400.000đ','Sashimi tổng hợp: 300.000–600.000đ','Hải sản nướng: 250.000–500.000đ','Set omakase: 1.000.000–2.000.000đ') }
}

# Hàm tạo dish cards HTML
function Make-Dishes($dishes) {
    if (-not $dishes -or $dishes.Count -eq 0) {
        return '        <p class="sp-empty">Thông tin đang được cập nhật.</p>'
    }
    $cards = @()
    foreach ($d in $dishes) {
        $colonIdx = $d.LastIndexOf(':')
        if ($colonIdx -gt 0) {
            $dname  = $d.Substring(0, $colonIdx).Trim()
            $dprice = $d.Substring($colonIdx + 1).Trim()
        } else {
            $dname  = $d.Trim()
            $dprice = 'Liên hệ'
        }
        $cards += "          <div class=`"dish-card`"><div class=`"dish-info`"><div class=`"dish-name`">$dname</div><div class=`"dish-price`">$dprice</div></div></div>"
    }
    return $cards -join "`n"
}

# Hàm patch một trang HTML
function Patch-Page($num, $d) {
    $file = "$baseDir\quan-$num.html"
    if (-not (Test-Path $file)) { Write-Warning "File not found: $file"; return }

    $html = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

    # 1. Sửa sp-chips (địa chỉ, giờ, giá, loại quán)
    $newChips = @"
        <div class="sp-chips">
          <span class="sp-chip"><span class="sp-chip-icon">🕐</span><span class="sp-chip-lbl">Giờ mở cửa</span><span class="sp-chip-val">$($d.hours)</span></span>
          <span class="sp-chip"><span class="sp-chip-icon">📍</span><span class="sp-chip-lbl">Địa chỉ</span><span class="sp-chip-val">$($d.addr)</span></span>
          <span class="sp-chip"><span class="sp-chip-icon">💰</span><span class="sp-chip-lbl">Mức giá</span><span class="sp-chip-val sp-price">$($d.price)</span></span>
          <span class="sp-chip"><span class="sp-chip-icon">$($d.emoji)</span><span class="sp-chip-lbl">Loại quán</span><span class="sp-chip-val">$($d.type)</span></span>
        </div>
"@
    $html = [regex]::Replace($html, '(?s)<div class="sp-chips">.*?</div>\s*</section>', "$newChips    </section>")

    # 2. Sửa dishes-grid
    $dishCards = Make-Dishes $d.dishes
    $newDishGrid = @"
      <div class="dishes-grid">
$dishCards
      </div>
"@
    $html = [regex]::Replace($html, '(?s)<div class="dishes-grid">.*?</div>\s*</section>', "$newDishGrid    </section>")

    # 3. Sửa địa chỉ trong phần Vị trí
    $html = [regex]::Replace($html, '(?s)(<section class="sp-section" id="sec-vitri">.*?<p style="color:#666;margin-bottom:\.5rem;">).*?(</p>)', "`$1$($d.addr)`$2")

    [System.IO.File]::WriteAllText($file, $html, $utf8bom)
    Write-Host "  Patched quan-$num.html"
}

# Áp dụng
$keys = $correct.Keys | Sort-Object
Write-Host "Patching $($keys.Count) broken pages..."
foreach ($num in $keys) {
    Patch-Page $num $correct[$num]
}

Write-Host ""
Write-Host "=== VERIFY spot checks ==="
foreach ($n in @(55, 66, 74, 92, 100)) {
    $f = [System.IO.File]::ReadAllText("$baseDir\quan-$n.html", [System.Text.Encoding]::UTF8)
    $hasGoodAddr = $f -match 'sp-chip-val' -and -not ($f -match 'sp-chip-val">:')
    $hasDishes   = $f -match 'dish-name'
    Write-Host "  quan-$n.html: good-addr=$hasGoodAddr | has-dishes=$hasDishes"
}
Write-Host "Done!"
