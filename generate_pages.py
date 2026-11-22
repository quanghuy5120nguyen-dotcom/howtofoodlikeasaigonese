#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generator script: parses restaurant-data.txt and creates all 100 quan-N.html files.
Modifications applied vs original template:
  - Removed "Anh" tab (button + content)
  - Removed "Quan tuong tu" section
  - Removed prev/next nav
  - Removed dish images (only name + price)
  - Changed "Loai mon" to "Loai quan"
"""

import re, json, random, os

# ══════════════════════════════════════════════════════════════
# CONSTANTS
# ══════════════════════════════════════════════════════════════

NAMES = [
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
]

# Known restaurant types sorted by length (longest first) for matching
KNOWN_TYPES = [
    "Ẩm thực Địa Trung Hải / Mỹ La-tinh","Ẩm thực Âu (Tráng miệng & Không gian Cafe)",
    "Ẩm thực Pháp / Âu (Burger)","Ẩm thực Tây Bán Cầu (Âu / Mỹ)",
    "Ẩm thực Đài Loan / Á Hiện Đại","Ẩm thực Nhật Bản / Âu",
    "Ẩm thực Trung Hoa (Quảng Đông)","Ẩm thực Nam Bộ (Việt Nam)",
    "Món Việt / Hủ tiếu Nam Vang","Món Barbecue, đồ nướng",
    "Thức ăn đường phố / Bánh mì","Món Địa Trung Hải / Tapas",
    "Món Bắc truyền thống","Den Long - Home Cooked Vietnamese Restaurant",
    "Món Huế / Bún bò","Món Hàn / Mì cay","Món Việt / Lẩu bò",
    "Món Việt / Bánh canh","Món Việt / Đồ nhậu","Món Việt gia đình",
    "Món Việt truyền thống","Quán ốc / Món Việt","Món Âu / Fine Dining",
    "Món Âu - Á / Ven sông","Hải sản / Món Âu - Á","Món Nga/Ukraine",
    "Ẩm thực Hàn Quốc","Ẩm thực Việt Nam","Ẩm thực Trung Hoa",
    "Ẩm thực Nhật Bản","Ẩm thực Pháp / Âu","Ẩm thực Thái Lan",
    "Ẩm thực Ý (Âu)","Ẩm thực Ấn Độ","Ẩm thực Chay",
    "Nhật Bản, hải sản, omakase","Hải sản, Trung Hoa, Nhật Bản",
    "Món Mexico, hải sản","Món Mỹ / BBQ","Bánh burger",
    "Món Châu Á","Món Á / Lẩu Nấm","Pháp, fine dining",
    "Trung Hoa, Quảng Đông","Thái Lan, Isan","Món Việt, hotpot",
    "Việt Nam, có món chay","Món hải sản",
    "Món Việt","Món Âu","Món Hàn","Món Nhật","Món Chay","Pizza","Món pizza",
    "Thái Lan","Ấn Độ","Nhật Bản","Món Hoa",
]

TYPE_MAP = {
    "Món Việt":"Món Việt","Ẩm thực Việt Nam":"Món Việt","Ẩm thực Nam Bộ (Việt Nam)":"Món Việt",
    "Món Việt truyền thống":"Món Việt","Món Việt gia đình":"Món Việt","Món Việt / Đồ nhậu":"Món Việt",
    "Món Việt / Bánh canh":"Món Việt","Món Huế / Bún bò":"Món Việt","Món Bắc truyền thống":"Món Việt",
    "Món Việt / Lẩu bò":"Món Việt","Món Việt / Hủ tiếu Nam Vang":"Món Việt",
    "Thức ăn đường phố / Bánh mì":"Món Việt","Quán ốc / Món Việt":"Món Việt",
    "Việt Nam, có món chay":"Món Việt","Món Việt, hotpot":"Món Việt",
    "Món Hàn":"Món Hàn","Ẩm thực Hàn Quốc":"Món Hàn","Món Hàn / Mì cay":"Món Hàn",
    "Món Nhật":"Món Nhật","Ẩm thực Nhật Bản":"Món Nhật","Ẩm thực Nhật Bản / Âu":"Món Nhật",
    "Nhật Bản, hải sản, omakase":"Món Nhật","Nhật Bản":"Món Nhật",
    "Món Âu":"Món Âu","Ẩm thực Ý (Âu)":"Món Âu","Ẩm thực Pháp / Âu":"Món Âu",
    "Ẩm thực Pháp / Âu (Burger)":"Món Âu","Ẩm thực Âu (Tráng miệng & Không gian Cafe)":"Món Âu",
    "Món Âu / Fine Dining":"Món Âu","Món Âu - Á / Ven sông":"Món Âu",
    "Món Địa Trung Hải / Tapas":"Món Âu","Pháp, fine dining":"Món Âu",
    "Ẩm thực Tây Bán Cầu (Âu / Mỹ)":"Món Âu","Ẩm thực Địa Trung Hải / Mỹ La-tinh":"Món Âu",
    "Ẩm thực Thái Lan":"Món Thái","Thái Lan":"Món Thái","Thái Lan, Isan":"Món Thái",
    "Ẩm thực Ấn Độ":"Món Ấn","Ấn Độ":"Món Ấn",
    "Ẩm thực Trung Hoa (Quảng Đông)":"Món Hoa","Ẩm thực Trung Hoa":"Món Hoa",
    "Món Hoa / Mì gia":"Món Hoa","Trung Hoa, Quảng Đông":"Món Hoa",
    "Ẩm thực Đài Loan / Á Hiện Đại":"Món Hoa","Hải sản, Trung Hoa, Nhật Bản":"Hải sản",
    "Pizza":"Pizza","Món pizza":"Pizza",
    "Món Mỹ / BBQ":"Món Mỹ","Món Barbecue, đồ nướng":"Món Mỹ","Bánh burger":"Món Mỹ",
    "Món Chay":"Món Chay","Ẩm thực Chay":"Món Chay",
    "Hải sản / Món Âu - Á":"Hải sản","Món hải sản":"Hải sản",
    "Món Nga/Ukraine":"Món khác","Món Mexico, hải sản":"Món khác",
    "Món Châu Á":"Món khác","Món Á / Lẩu Nấm":"Món khác",
}

EMOJI_MAP = {"Món Việt":"🍜","Món Hàn":"🍖","Món Nhật":"🍣","Món Âu":"🍝",
    "Món Thái":"🥘","Món Ấn":"🍛","Món Hoa":"🥟","Pizza":"🍕",
    "Món Mỹ":"🍔","Món Chay":"🥗","Hải sản":"🦐","Món khác":"🌍"}

PEXELS_IMG = {"Món Việt":"1775043","Món Hàn":"7187423","Món Nhật":"2098086",
    "Món Âu":"1640777","Món Thái":"8472992","Món Ấn":"1560694",
    "Món Hoa":"1683809","Pizza":"7083528","Món Mỹ":"1633578",
    "Món Chay":"1640777","Hải sản":"699953","Món khác":"1640777"}

DISTRICT_COORDS = {
    "Quận 1":(10.7769,106.7009),"Quận 3":(10.7798,106.6900),
    "Quận 5":(10.7520,106.6610),"Quận 10":(10.7708,106.6720),
    "Bình Thạnh":(10.8000,106.7100),"Phú Nhuận":(10.8000,106.6700),
    "Gò Vấp":(10.8400,106.6500),"Thủ Đức":(10.8500,106.7300),
    "Quận 2":(10.8000,106.7400),"Quận 12":(10.8600,106.6400),
    "Quận 4":(10.7580,106.7020),"Quận 7":(10.7300,106.7210),
    "Tân Bình":(10.8000,106.6500),"Bình Tân":(10.7800,106.6200),
}

VN_FIRST_NAMES = ["Thanh","Minh","Phương","Hùng","Nam","Lan","Hoa","Quang","Đức","Trang",
    "Khoa","Nhi","An","Bình","Dung","Hà","Long","Mai","Ngọc","Sơn","Tâm","Vân","Hiền","Đạt"]
VN_LAST_NAMES = ["Nguyễn","Trần","Lê","Phạm","Hoàng","Phan","Vũ","Đặng","Bùi","Đỗ",
    "Hồ","Ngô","Dương","Lý","Trương","Lâm","Đinh","Đoàn","Võ","Cao"]
VN_REVIEW_TEMPLATES = [
    "Quán ngon, không gian ấm cúng, mình sẽ quay lại lần sau.",
    "Món ăn đậm vị, phục vụ nhiệt tình, giá hợp lý cho chất lượng.",
    "Địa điểm lý tưởng cho buổi hẹn hò hoặc tụ họp bạn bè.",
    "Thực đơn đa dạng, mỗi món đều được chăm chút tỉ mỉ.",
    "Nước dùng đậm đà, nguyên liệu tươi, đáng đồng tiền bát cơm.",
    "Không gian đẹp, đồ ăn ngon, nhưng cuối tuần hơi đông.",
    "Mình mê nhất món招牌 ở đây, lần nào ghé Sài Gòn cũng phải đến.",
    "Giá hơi cao nhưng xứng đáng với trải nghiệm ẩm thực.",
]

# ══════════════════════════════════════════════════════════════
# PARSING
# ══════════════════════════════════════════════════════════════

def extract_district(address):
    """Extract district name from address string."""
    for d in ["Quận 12","Quận 1","Quận 2","Quận 3","Quận 4","Quận 5","Quận 6",
              "Quận 7","Quận 8","Quận 9","Quận 10","Quận 11",
              "Bình Thạnh","Phú Nhuận","Gò Vấp","Tân Bình","Tân Phú","Bình Tân","Thủ Đức"]:
        if d in address:
            return d
    # Try Q.N pattern
    m = re.search(r'Q\.?\s*(\d+)', address)
    if m:
        return "Quận " + m.group(1)
    return "Quận 1"  # default

def standardize_type(raw_type):
    """Map raw restaurant type to standardized category."""
    if raw_type in TYPE_MAP:
        return TYPE_MAP[raw_type]
    # Try partial match
    for k, v in TYPE_MAP.items():
        if k in raw_type or raw_type in k:
            return v
    return "Món khác"

def parse_dishes(dishes_str):
    """Parse dishes string into list of (name, price) tuples."""
    dishes = []
    parts = dishes_str.strip().split(';')
    for part in parts:
        part = part.strip()
        if not part:
            continue
        # Split on last colon to separate name and price
        idx = part.rfind(':')
        if idx > 0:
            name = part[:idx].strip()
            price = part[idx+1:].strip()
        else:
            # Try to find price pattern
            pm = re.search(r'(\d[\d.,]*\s*(?:đ|VNĐ|k|k VNĐ))', part)
            if pm:
                name = part[:pm.start()].strip().rstrip('-–')
                price = part[pm.start():].strip()
            else:
                name = part
                price = ""
        # Clean price
        price = price.strip()
        if not price:
            price = "Liên hệ"
        dishes.append((name, price))
    return dishes[:6]  # max 6 dishes

def parse_restaurant(num, name, line):
    """Parse a single restaurant line into structured data."""
    # Remove number prefix
    rest = re.sub(r'^\d+\s+', '', line.strip())
    # Remove name from the start
    if rest.startswith(name):
        rest = rest[len(name):].strip()
    else:
        # Try to find name in rest
        idx = rest.find(name)
        if idx >= 0:
            rest = rest[idx + len(name):].strip()

    # Find price pattern: digits.digits - digits.digits with optional đ/VNĐ
    price_patterns = [
        r'(\d{1,3}(?:\.\d{3})*\s*[–\-]\s*\d{1,3}(?:\.\d{3})*\s*(?:đ|VNĐ)?\s*/?\s*(?:người|phần)?)',
        r'(\d{1,3}(?:\.\d{3})*\s*[–\-]\s*\d{1,3}(?:\.\d{3})*\s*(?:đ|VNĐ)?)',
        r'(\d{1,3}\.?\d{3}\s*[–\-]\s*\d{1,3}\.?\d{3})',
    ]
    price_match = None
    price_str = ""
    price_end = 0
    for pat in price_patterns:
        m = re.search(pat, rest)
        if m:
            price_match = m
            price_str = m.group(1).strip()
            price_end = m.end()
            break

    if not price_match:
        price_str = "Liên hệ"
        price_end = 0

    # Description = everything before price
    description = rest[:price_match.start()].strip() if price_match else rest[:200].strip()

    # After price: address + type + hours + dishes
    after_price = rest[price_end:].strip() if price_match else ""

    # Find type in after_price
    type_str = ""
    type_end = 0
    for kt in KNOWN_TYPES:
        idx = after_price.find(kt)
        if idx >= 0:
            type_str = kt
            type_end = idx + len(kt)
            break

    # Address = between price and type
    address = after_price[:after_price.find(type_str)].strip() if type_str else after_price[:200].strip()
    # Clean address
    address = address.strip(' .,')

    # After type: hours + dishes
    after_type = after_price[type_end:].strip() if type_str else ""

    # Find hours pattern
    hours_str = ""
    hours_end = 0
    hours_patterns = [
        r'(\d{1,2}:\d{2}\s*[–\-]\s*\d{1,2}:\d{2}\s*(?:\([^)]*\))?)',
        r'(Sáng:\s*\d{1,2}:\d{2}\s*[–\-]\s*\d{1,2}:\d{2})',
        r'(Tối:\s*\d{1,2}:\d{2}\s*[–\-]\s*\d{1,2}:\d{2})',
        r'(Mở cửa 24/24)',
        r'(Hằng ngày\s*\d{1,2}:\d{2}[–\-]\d{1,2}:\d{2})',
        r'(Hằng ngày\s*\d{1,2}:\d{2}\s*[–\-]\s*\d{1,2}:\d{2})',
        r'(\d{1,2}:\d{2}\s*[–\-]\s*\d{1,2}:\d{2})',
        r'(\d{1,2}:\d{2}\s*[–\-]\s*\d{1,2}:\d{2}\s*\([^)]*\))',
    ]
    # Try to find all hour segments and combine
    all_hours = []
    for pat in hours_patterns:
        for m in re.finditer(pat, after_type):
            all_hours.append((m.start(), m.end(), m.group(1)))

    if all_hours:
        all_hours.sort()
        hours_str = "; ".join(h[2] for h in all_hours)
        hours_end = all_hours[-1][1]
    else:
        # Try to find any time-like pattern
        m = re.search(r'(\d{1,2}:\d{2})', after_type)
        if m:
            hours_str = after_type[:after_type.find('Bánh') if 'Bánh' in after_type else 50].strip()
            hours_end = m.end()
        else:
            hours_str = "Liên hệ"
            hours_end = 0

    # Dishes = everything after hours
    dishes_str = after_type[hours_end:].strip() if hours_end else after_type.strip()
    # Clean dishes string - remove leading non-dish text
    # Remove common prefixes
    for prefix in ["Bánh","Phở","Cơm","Bún","Mì","Gỏi","Cà","Canh","Súp","Set","Combo",
                   "Nem","Chả","Cua","Tôm","Gà","Bò","Heo","Vịt","Lẩu","Pizza","Spaghetti",
                   "Há","Xíu","Mì ","Cơm ","Bún ","Bánh ","Phở ","Gỏi ","Ramen","Ramen ",
                   "Kimbap","Tokbokki","Gà ","Thịt","Dẻ","Canh","Bít","Cá ","Nước","Sashimi",
                   "Omakase","Cơm ","Bánh ","Mì ","Pad","Xôi","Hủ","Gỏi","Salad","Bánh",
                   "Phở","Tháp","Mực","Trà","Cà","Bánh","Cơm","Mì","Bún","Gà","Bò",
                   "Cua","Tôm","Nem","Chả","Set","Combo","Kimbap","Tokbokki","Ramen",
                   "Phở","Bánh","Cơm","Bún","Mì","Gỏi","Cà","Canh","Súp","Salad",
                   "Nấm","Nước","Xôi","Hủ","Há","Xíu","Maki","Sashimi","Omakase",
                   "Duck","Grilled","Seasonal","Long","Phở","Bít","Thăn","Sườn","Cơm",
                   "Bánh","Trà","Cà","Tháp","Mực","Cơm","Mì","Pad","Xôi","Hủ",
                   "Bánh","Phở","Bún","Gỏi","Salad","Nấm","Bít","Cá","Tôm","Gà","Bò",
                   "Vịt","Cua","Nem","Chả","Set","Combo","Gimbap","Kimbap","Tokbokki",
                   "Ramen","Mì","Cơm","Bánh","Phở","Bún","Canh","Súp","Xôi","Hủ",
                   "Gỏi","Salad","Há","Xíu","Maki","Sashimi","Omakase","Duck","Grilled",
                   "Seasonal","Long","Thăn","Sườn","Trà","Cà","Tháp","Mực","Pad",
                   "Nước","Bít","Cá","Tôm","Gà","Bò","Vịt","Cua","Nem","Chả","Set","Combo",
                   "Baby","Roasted","Khai","Salad","Món","Tráng","Kem","Bánh"]:
        if dishes_str.startswith(prefix):
            break

    dishes = parse_dishes(dishes_str)

    # Extract district
    district = extract_district(address) if address else "Quận 1"

    # Standardize type
    std_type = standardize_type(type_str) if type_str else "Món khác"
    emoji = EMOJI_MAP.get(std_type, "🍽")

    # Generate rating
    random.seed(num * 42)
    base_rating = round(random.uniform(4.0, 4.9), 1)
    if "1.500" in price_str or "2.000" in price_str or "3.500" in price_str or "1.000" in price_str:
        base_rating = round(random.uniform(4.5, 4.9), 1)
    elif "500.000" in price_str or "800.000" in price_str:
        base_rating = round(random.uniform(4.4, 4.8), 1)
    review_count = random.randint(48, 235)

    # Sub-ratings
    sub_ratings = {
        "Đồ ăn": round(min(5.0, base_rating + random.uniform(0, 0.3)), 1),
        "Không gian": round(max(3.5, base_rating - random.uniform(0.3, 0.8)), 1),
        "Phục vụ": round(max(3.5, base_rating - random.uniform(0.1, 0.5)), 1),
        "Giá cả": round(max(3.5, base_rating - random.uniform(0, 0.4)), 1),
    }

    # Coordinates
    base_lat, base_lng = DISTRICT_COORDS.get(district, (10.7769, 106.7009))
    lat = base_lat + random.uniform(-0.005, 0.005)
    lng = base_lng + random.uniform(-0.005, 0.005)

    # Pexels image
    img_id = PEXELS_IMG.get(std_type, "1640777")

    return {
        "num": num,
        "name": name,
        "description": description,
        "price": price_str,
        "address": address if address else "Liên hệ",
        "type_raw": type_str,
        "type": std_type,
        "emoji": emoji,
        "district": district,
        "hours": hours_str,
        "dishes": dishes,
        "rating": base_rating,
        "review_count": review_count,
        "sub_ratings": sub_ratings,
        "lat": round(lat, 4),
        "lng": round(lng, 4),
        "img_id": img_id,
    }

def read_and_parse():
    """Read the data file and parse all restaurants."""
    with open(os.path.join(os.path.dirname(__file__), "restaurant-data.txt"), "r", encoding="utf-8") as f:
        content = f.read()

    lines = content.strip().split("\n")
    # Skip header lines
    restaurants = []
    current = ""
    for line in lines:
        line = line.strip()
        if not line:
            continue
        m = re.match(r'^(\d+)\s+(.*)', line)
        if m and 1 <= int(m.group(1)) <= 100:
            if current:
                restaurants.append(current)
            current = line
        elif current:
            current += " " + line
    if current:
        restaurants.append(current)

    parsed = []
    for r in restaurants:
        m = re.match(r'^(\d+)\s+(.*)', r)
        if not m:
            continue
        num = int(m.group(1))
        if num < 1 or num > 100:
            continue
        name = NAMES[num - 1] if num <= len(NAMES) else ""
        parsed.append(parse_restaurant(num, name, r))

    return parsed

# ══════════════════════════════════════════════════════════════
# HTML GENERATION
# ══════════════════════════════════════════════════════════════

def split_description(desc, num_paragraphs=2):
    """Split description into multiple paragraphs."""
    if not desc:
        return ["Nội dung đang được cập nhật."]
    sentences = re.split(r'(?<=[.!?])\s+', desc)
    if len(sentences) <= 2:
        return [desc]
    mid = len(sentences) // num_paragraphs
    paras = []
    for i in range(num_paragraphs):
        start = i * mid
        end = (i + 1) * mid if i < num_paragraphs - 1 else len(sentences)
        paras.append(" ".join(sentences[start:end]))
    return paras

def generate_dish_cards(dishes):
    """Generate HTML for dish cards (no images, only name and price)."""
    if not dishes:
        return '<p style="color:#999;">Thông tin món ăn đang được cập nhật.</p>'
    cards = []
    for name, price in dishes:
        cards.append(f'''        <div class="dish-card">
            <div class="dish-info"><div class="dish-name">{name}</div><div class="dish-price">{price}</div></div>
          </div>''')
    return "\n".join(cards)

def generate_rating_bars(sub_ratings):
    """Generate HTML for rating bars."""
    bars = []
    labels = {"Đồ ăn": "Đồ ăn", "Không gian": "Không gian", "Phục vụ": "Phục vụ", "Giá cả": "Giá cả"}
    for key in ["Đồ ăn", "Không gian", "Phục vụ", "Giá cả"]:
        val = sub_ratings[key]
        pct = int(val / 5.0 * 100)
        bars.append(f'''            <div class="rating-bar-row"><span class="rating-bar-label">{labels[key]}</span><div class="rating-bar-track"><div class="rating-bar-fill" style="width:{pct}%"></div></div><span class="rating-bar-value">{val}</span></div>''')
    return "\n".join(bars)

def generate_review_cards(num, rating):
    """Generate 2-3 review cards."""
    random.seed(num * 100)
    reviews = []
    num_reviews = random.randint(2, 3)
    for i in range(num_reviews):
        ln = random.choice(VN_LAST_NAMES)
        fn = random.choice(VN_FIRST_NAMES)
        full_name = f"{ln} {fn}"
        initials = fn[0]
        stars_count = 5 if rating >= 4.5 else (4 if random.random() > 0.3 else 5)
        stars = "★" * stars_count + "☆" * (5 - stars_count)
        month = random.randint(1, 10)
        day = random.randint(1, 28)
        date_str = f"{day:02d}/{month:02d}/2025"
        review_text = random.choice(VN_REVIEW_TEMPLATES)
        reviews.append(f'''        <div class="review-card">
          <div class="review-header"><div class="review-avatar">{initials}</div><div><div class="review-name">{full_name}</div><div class="review-date">{date_str}</div></div></div>
          <div class="review-stars">{stars}</div>
          <p class="review-text">{review_text}</p>
        </div>''')
    return "\n".join(reviews)

def generate_html(r):
    """Generate complete HTML for a restaurant page."""
    num = r["num"]
    name = r["name"]
    desc_paras = split_description(r["description"])
    description_html = "\n".join(
        f'        <p style="color:#555;line-height:1.8;margin-bottom:1rem;">{p}</p>' for p in desc_paras
    )
    dish_cards = generate_dish_cards(r["dishes"])
    rating_bars = generate_rating_bars(r["sub_ratings"])
    review_cards = generate_review_cards(num, r["rating"])
    stars_display = "★" * int(r["rating"]) + "☆" * (5 - int(r["rating"]))

    # Escape for JS
    js_name = name.replace("'", "\\'").replace('"', '&quot;')
    js_addr = r["address"].replace("'", "\\'").replace('"', '&quot;')

    html = f'''<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{name} | How To Food Like A Saigonese</title>
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

  <!-- HERO -->
  <div class="subpage-hero">
    <img src="https://images.pexels.com/photos/{r['img_id']}/pexels-photo-{r['img_id']}.jpeg?auto=compress&cs=tinysrgb&w=1400" alt="{name}" class="subpage-hero-img" onerror="this.src='https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1400'" />
    <div class="subpage-hero-overlay"></div>
    <div class="subpage-hero-content">
      <div class="subpage-badges">
        <span class="subpage-badge">{r['emoji']} {r['type']}</span>
        <span class="subpage-badge">📍 {r['district']}</span>
        <span class="subpage-badge">⭐ {r['rating']} / 5</span>
      </div>
      <h1>{name}</h1>
    </div>
  </div>

  <!-- BREADCRUMB -->
  <div class="container">
    <nav class="breadcrumb">
      <a href="index.html">Trang chủ</a><span>›</span>
      <a href="khampha.html">Khám phá</a><span>›</span>
      {name}
    </nav>
  </div>

  <!-- TABS -->
  <div class="tabs-wrapper">
    <div class="tabs-inner">
      <button class="tab-btn active" onclick="switchTab('cauchyen',this)">Câu chuyện</button>
      <button class="tab-btn" onclick="switchTab('mon',this)">Món nổi bật</button>
      <button class="tab-btn" onclick="switchTab('danhgia',this)">Đánh giá</button>
      <button class="tab-btn" onclick="switchTab('vitri',this)">Vị trí</button>
    </div>
  </div>

  <!-- CONTENT -->
  <div class="subpage-layout">
    <main>
      <!-- Tab: Câu chuyện -->
      <div class="tab-content active" id="tab-cauchyen">
        <h2 style="font-size:1.4rem;font-weight:800;margin-bottom:1rem;">Câu chuyện quán</h2>
{description_html}
        <div style="margin-top:1.5rem;padding:1.2rem;background:#faf9f7;border-radius:10px;border:1px solid #f0ede8;">
          <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:.75rem;font-size:.875rem;">
            <div><span style="color:#aaa;font-size:.75rem;text-transform:uppercase;letter-spacing:.04em;">Giờ mở cửa</span><br><strong>{r['hours']}</strong></div>
            <div><span style="color:#aaa;font-size:.75rem;text-transform:uppercase;letter-spacing:.04em;">Địa chỉ</span><br><strong>{r['address']}</strong></div>
            <div><span style="color:#aaa;font-size:.75rem;text-transform:uppercase;letter-spacing:.04em;">Mức giá</span><br><strong>{r['price']}</strong></div>
            <div><span style="color:#aaa;font-size:.75rem;text-transform:uppercase;letter-spacing:.04em;">Loại quán</span><br><strong>{r['type']}</strong></div>
          </div>
        </div>
      </div>

      <!-- Tab: Món nổi bật -->
      <div class="tab-content" id="tab-mon">
        <h2 style="font-size:1.4rem;font-weight:800;margin-bottom:1rem;">Món nổi bật</h2>
        <div class="dishes-grid">
{dish_cards}
        </div>
      </div>

      <!-- Tab: Đánh giá -->
      <div class="tab-content" id="tab-danhgia">
        <h2 style="font-size:1.4rem;font-weight:800;margin-bottom:1rem;">Đánh giá từ thực khách</h2>
        <div class="rating-overview">
          <div style="text-align:center;">
            <div class="rating-big">{r['rating']}</div>
            <div style="color:#e0a318;font-size:1.2rem;">{stars_display}</div>
            <div style="font-size:.78rem;color:#aaa;margin-top:4px;">{r['review_count']} đánh giá</div>
          </div>
          <div class="rating-bars">
{rating_bars}
          </div>
        </div>
{review_cards}
      </div>

      <!-- Tab: Vị trí -->
      <div class="tab-content" id="tab-vitri">
        <h2 style="font-size:1.4rem;font-weight:800;margin-bottom:.5rem;">Vị trí quán</h2>
        <p style="color:#666;margin-bottom:.5rem;">📍 {r['address']}</p>
        <div id="minimap" class="mini-map"></div>
        <div style="margin-top:1rem;">
          <a href="bando.html" class="btn btn-outline-dark btn-sm">🗺 Xem trên bản đồ tổng</a>
        </div>
      </div>
    </main>

    <!-- SIDEBAR -->
    <aside>
      <div class="info-card">
        <h3>Thông tin quán</h3>
        <div class="info-row"><div class="info-row-icon">📍</div><div class="info-row-content"><div class="info-row-label">Địa chỉ</div><div class="info-row-value">{r['address']}</div></div></div>
        <div class="info-row"><div class="info-row-icon">🕐</div><div class="info-row-content"><div class="info-row-label">Giờ mở cửa</div><div class="info-row-value">{r['hours']}</div></div></div>
        <div class="info-row"><div class="info-row-icon">💰</div><div class="info-row-content"><div class="info-row-label">Mức giá</div><div class="info-row-value">{r['price']}</div></div></div>
        <div class="info-row"><div class="info-row-icon">⭐</div><div class="info-row-content"><div class="info-row-label">Đánh giá</div><div class="info-row-value">{r['rating']} / 5 ({r['review_count']} đánh giá)</div></div></div>
        <div class="info-row"><div class="info-row-icon">🍽</div><div class="info-row-content"><div class="info-row-label">Loại quán</div><div class="info-row-value">{r['type']}</div></div></div>
        <a href="bando.html" class="btn-map-full" style="display:block;text-align:center;padding:.7rem;background:linear-gradient(135deg,#e8722a,#cf3b1b);color:#fff;border-radius:10px;font-size:.88rem;font-weight:700;margin-top:1rem;text-decoration:none;">🗺 Xem trên bản đồ</a>
      </div>
    </aside>
  </div>

  <footer class="footer"><p>© 2025 How To Food Like A Saigonese | Made with ❤️ bởi Nhóm 4 — Lớp 10.1</p></footer>

  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
  <script>
    // Nav
    (function(){{var b=document.getElementById('hamburgerBtn'),l=document.getElementById('navLinks');b.addEventListener('click',function(){{var o=l.classList.toggle('open');b.setAttribute('aria-expanded',o);b.classList.toggle('active',o);}});}})();
    // Tabs
    function switchTab(id,btn){{
      document.querySelectorAll('.tab-content').forEach(function(t){{t.classList.remove('active');}});
      document.querySelectorAll('.tab-btn').forEach(function(b){{b.classList.remove('active');}});
      document.getElementById('tab-'+id).classList.add('active');
      btn.classList.add('active');
      if(id==='vitri' && !window._minimap{num}){{
        window._minimap{num}=true;
        var m=L.map('minimap').setView([{r['lat']},{r['lng']}],16);
        L.tileLayer('https://{{s}}.tile.openstreetmap.org/{{z}}/{{x}}/{{y}}.png',{{attribution:'© OpenStreetMap',maxZoom:19}}).addTo(m);
        L.marker([{r['lat']},{r['lng']}]).addTo(m).bindPopup('<strong>{js_name}</strong><br>{js_addr}').openPopup();
        setTimeout(function(){{m.invalidateSize();}},100);
      }}
    }}
  </script>
</body>
</html>
'''
    return html

# ══════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))

    print("Parsing restaurant data...")
    restaurants = read_and_parse()
    print(f"Parsed {len(restaurants)} restaurants")

    # Save JSON
    json_path = os.path.join(base_dir, "restaurants.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(restaurants, f, ensure_ascii=False, indent=2)
    print(f"Saved restaurants.json with {len(restaurants)} entries")

    # Generate HTML files
    print("Generating HTML files...")
    for r in restaurants:
        html = generate_html(r)
        filepath = os.path.join(base_dir, f"quan-{r['num']}.html")
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(html)
    print(f"Generated {len(restaurants)} HTML files (quan-1.html to quan-{restaurants[-1]['num']}.html)")

    # Summary
    print("\n=== SUMMARY ===")
    print(f"Total restaurants: {len(restaurants)}")
    types = {}
    for r in restaurants:
        types[r["type"]] = types.get(r["type"], 0) + 1
    print("Type distribution:")
    for t, c in sorted(types.items(), key=lambda x: -x[1]):
        print(f"  {t}: {c}")
    print("\nSample (first 3):")
    for r in restaurants[:3]:
        print(f"  #{r['num']}: {r['name']} | {r['type']} | {r['district']} | {r['price']}")
    print("\nSample (last 3):")
    for r in restaurants[-3:]:
        print(f"  #{r['num']}: {r['name']} | {r['type']} | {r['district']} | {r['price']}")

if __name__ == "__main__":
    main()
