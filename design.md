# Thiết kế: Gần tôi, đang mở cửa

Thiết kế bám `.kiro/steering/product.md` và `requirements.md`. Trang mới đứng riêng để không viết lại 100 thẻ trong `khampha.html` và không đụng mảng quán nhúng trong `bando.html`.

## Tệp sẽ thêm hoặc sửa

| Tệp | Việc |
| --- | --- |
| `gantoi.html` | Trang tính năng. Cùng navbar, hero, footer với Khám phá |
| `js/restaurants-data.js` | `var RESTAURANTS = [ ... ]` sinh từ `restaurants.json` |
| `js/hours.js` | Hàm thuần: đọc chuỗi giờ, trả về mở / đóng / chưa rõ |
| `js/geo.js` | Hàm thuần: Haversine và chuỗi khoảng cách |
| `js/gan-toi.js` | Nối DOM, GPS và hai hàm trên |
| `js/test-gan-toi.html` | Trang kiểm tra hàm thuần, không có trong menu |
| `css/style.css` | Thêm khối cuối file, class bắt đầu bằng `gt-` |
| `index.html`, `khampha.html`, `bando.html`, `goiy.html` | Thêm một mục menu. Trang chủ thêm một `nav-card` |

`quan-*.html`, `restaurants.json`, logic lọc Khám phá và script bản đồ giữ nguyên.

Thứ tự script trên `gantoi.html`: `restaurants-data.js`, `hours.js`, `geo.js`, `gan-toi.js`.

## Dữ liệu đưa vào trang

Mỗi phần tử của `RESTAURANTS`:

```javascript
{
  num: 1,
  name: "Bếp mẹ ỉn",
  district: "Quận 1",
  type: "Món Việt",
  rating: 4.6,
  price: "150.000 – 300.000đ/người",
  hours: "10:30 - 22:30",
  lat: 10.7791,
  lng: 106.701,
  emoji: "🍜",
  description: "…tối đa 120 ký tự…",
  image: "hinhanhquan/quan-1.jpg"
}
```

Cách sinh file, chạy một lần bằng PowerShell tại thư mục gốc website: đọc `restaurants.json`, với mỗi `Num` tìm đúng một file `hinhanhquan/quan-{Num}.*`, cắt `Description` ở 120 ký tự không cắt giữa chừng nếu còn dấu cách trước đó, ghi UTF-8 vào `js/restaurants-data.js`. Sau khi sinh, đếm 100 phần tử và 100 đường ảnh tồn tại. Không sửa JSON gốc.

Trang Khám phá vẫn dùng `data-hours` (`sang` / `trua` / `toi` / `ngay`). Trang mới không đọc các nhãn đó. Giờ xét mở cửa là chuỗi `Hours`.

## Xét đang mở

`hours.js` xuất hai hàm:

```javascript
function parseHours(text) { /* ... */ }
function isOpenAt(text, now) { /* ... */ }
```

`parseHours` trả về một trong hai dạng:

- `{ kind: "unknown" }`
- `{ kind: "ok", days: [0,1,2,3,4,5,6], ranges: [{ start: 630, end: 1350 }] }`

`start` và `end` là số phút từ 00:00. `days` là các thứ quán mở. Không có cụm thứ thì `days` là cả tuần.

Các bước của `parseHours`:

1. Chuẩn hóa: trim, đổi `–` và `—` thành `-`, gộp khoảng trắng.
2. Nếu sau chuẩn hóa mà rỗng hoặc bằng `liên hệ` (không phân biệt hoa thường) thì `unknown`.
3. Nếu khớp `Thứ <tên> - Thứ <tên>: <phần giờ>` thì lấy `days` từ thứ bắt đầu đến thứ kết thúc, tính cả hai đầu. Bảng tên: Chủ Nhật 0, Hai 1, Ba 2, Tư 3, Năm 4, Sáu 5, Bảy 6. Tên viết đủ «Thứ Hai» … «Thứ Bảy» và «Chủ Nhật». Nếu số thứ bắt đầu lớn hơn số thứ kết thúc, dải đi tiếp qua Chủ Nhật rồi đến thứ kết thúc.
4. Cắt phần giờ bằng `;`. Mỗi mảnh phải khớp `H:MM - H:MM` hoặc `HH:MM - HH:MM`. Giờ từ 0 đến 23, phút từ 0 đến 59. Sai một mảnh thì cả chuỗi là `unknown`.
5. Với mỗi khung, `end` bằng `00:00` được lưu thành 1440 (24:00). Mọi khung khác giữ số phút thật. Dữ liệu hiện có không có ca mở xuyên đêm kiểu 18:00–02:00; gặp `end` khác 0 mà `end` nhỏ hơn `start` thì trả `unknown` thay vì đoán.

`isOpenAt(text, now)`:

- `unknown` → `{ state: "unknown" }`.
- `now.getDay()` không nằm trong `days` → `{ state: "closed" }`.
- Phút hiện tại `h * 60 + m` thỏa `start <= phút < end` của một khung → `{ state: "open" }`.
- Ngược lại → `{ state: "closed" }`.

Ca cố định mà trang test phải in ĐÚNG:

| Chuỗi | Thời điểm | Kết quả |
| --- | --- | --- |
| `10:30 - 22:30` | 15:00 cùng ngày | open |
| `10:30 - 22:30` | 10:30 | open |
| `10:30 - 22:30` | 22:30 | closed |
| `11:30 – 00:00` | 23:00 | open |
| `11:30 – 00:00` | 00:30 | closed |
| `11:00–14:00; 18:00–22:00` | 15:00 | closed |
| `11:00–14:00; 18:00–22:00` | 19:00 | open |
| `Thứ Ba – Chủ Nhật: 17:30 – 23:00` | Thứ Hai 18:00 | closed |
| `Thứ Ba – Chủ Nhật: 17:30 – 23:00` | Thứ Ba 18:00 | open |
| `Thứ Bảy - Thứ Hai: 10:00 - 12:00` | Chủ Nhật 11:00 | open |
| `Liên hệ` | bất kỳ | unknown |
| `cả ngày` | bất kỳ | unknown |

Dòng «Thứ Bảy - Thứ Hai» chỉ dùng trên trang test để khóa luật đi vòng tuần. Dữ liệu thật không có chuỗi này.

## Khoảng cách

`geo.js`:

```javascript
function distanceKm(lat1, lng1, lat2, lng2) { /* Haversine, R = 6371 */ }
function formatDistance(km) { /* < 1 → "850 m"; còn lại → "1.2 km" */ }
```

`formatDistance` dùng dấu chấm cho số thập phân, làm tròn mét bằng `Math.round`. Trang test dùng vị trí `10.7769, 106.7009`:

- tới quán 1 (`10.7791, 106.701`) cho số km `< 1`;
- tới quán 60 (`10.839, 106.653`) cho số km `> 5`.

Sai lệch cho phép khi so một cặp tự tính tay: 50 mét. Không cần thư viện bản đồ.

## Trạng thái và câu trạng thái

Trạng thái trong `gan-toi.js`, không ghi ra đĩa:

```javascript
{
  status: "idle", // idle | loading | ready | denied | unsupported
  lat: null,
  lng: null,
  radiusKm: 3,
  at: null        // Date lúc lọc thành công
}
```

Câu hiển thị trong `.gt-status` cho từng trạng thái:

| Trạng thái | Câu |
| --- | --- |
| `idle` | _(trống — hướng dẫn ngắn ở hero)_ |
| `loading` | «Đang lấy vị trí…» |
| `ready` | «Đang hiển thị quán trong bán kính X km» |
| `denied` | «Không lấy được vị trí. Hãy cho phép định vị trên trình duyệt rồi bấm lại.» |
| `unsupported` | «Trình duyệt của bạn không hỗ trợ định vị.» |

Empty state khi `ready` nhưng không có quán:

- Mức 1 km hoặc 3 km: «Không có quán đang mở trong X km. Thử tăng bán kính nhé!»
- Mức 5 km: «Trong 5 km hiện không có quán đang mở.»

Hàm vẽ:

```javascript
RESTAURANTS
  .map(function (q) {
    return {
      q: q,
      km: distanceKm(lat, lng, q.lat, q.lng),
      open: isOpenAt(q.hours, at)
    };
  })
  .filter(function (row) {
    return row.km <= radiusKm && row.open.state === "open";
  })
  .sort(function (a, b) {
    if (a.km !== b.km) return a.km - b.km;
    return b.q.rating - a.q.rating;
  });
```

## Bố cục

`gantoi.html` lặp khung của `khampha.html`: navbar, `page-hero` (ảnh `hinhanhquan/header-khampha.jpg` cho cùng họ ảnh), nội dung, footer nguyên câu «© 2025 How To Food Like A Saigonese | Made with ❤️ bởi Nhóm 4 — Lớp 10.1».

Dưới hero là một thanh `.gt-controls` trên nền trắng, bo góc và viền giống sidebar lọc:

- Nút `.btn.btn-primary`: «Dùng vị trí của tôi».
- `<select id="gtRadius">` ba option 1, 3, 5. Nhãn «Bán kính». Option 3 có `selected`.
- Nút chữ `.gt-refresh` chỉ hiện khi `ready`: «Làm mới».
- Đoạn `.gt-status` cho câu trạng thái.

Lưới kết quả dùng lại `.khampha-cards-grid` và `.card`. Phần thêm nằm trong `.card-body`, class `.gt-distance` và `.gt-hours`. Nhãn mở cửa dùng `.badge` cùng màu chữ trắng trên nền `#cf3b1b`, nội dung «Đang mở».

Dòng đếm dùng lại `.khampha-result-count`. Hết quán thì bỏ `hidden` của `.empty-state`.

Trang không nhúng Leaflet. Tên quán trỏ tới trang chi tiết sẵn có. Trang chi tiết vẫn không hiện nhãn «Đang mở»; người dùng đọc giờ ở đó như hiện tại.

## CSS mới

Viết ở cuối `css/style.css`. Chỉ thêm, không đổi rule cũ.

- `.gt-controls`: nền `#fff`, viền `#e8e0da`, bán kính 12px, padding, xếp ngang, gap, `flex-wrap`.
- `.gt-status`: màu `#555`, cỡ khoảng `0.9rem`.
- `.gt-distance`: màu `#cf3b1b`, đậm.
- Dưới 768px: thanh điều khiển xếp dọc, nút và select rộng 100%, giống cách navbar hiện đã gãy ở 768px.

Menu mobile dùng lại script hamburger đang có trên từng trang. `gantoi.html` copy cùng đoạn script đó, không viết menu mới.

## Kiểm thử

`js/test-gan-toi.html` chỉ gồm một trang trắng, nạp `hours.js` và `geo.js`, chạy các ca trong hai bảng trên, in từng dòng «ĐÚNG» hoặc «SAI» và một dòng tổng. Mở bằng trình duyệt. Trang này không vào navbar.

Demo tính năng thật: mở thư mục bằng Live Server hoặc một server tĩnh, vào `http://localhost:.../gantoi.html`. Nhiều trình duyệt chặn GPS khi mở file `file://`.

Kiểm tay sau khi hàm thuần đã ĐÚNG:

- Chưa bấm nút: không có thẻ quán, không có hộp xin quyền.
- Cho phép vị trí lúc đang ở TP.HCM: chỉ quán đang mở trong đúng bán kính, gần hơn đứng trước, nhãn và chuỗi giờ hiện trên thẻ, bấm tên mở đúng `quan-N.html`.
- Đổi 1 km rồi 5 km: số quán đổi, trình duyệt không hỏi quyền lần hai.
- Từ chối quyền: có câu tiếng Việt, không có thẻ.
- Quán `Hours` bằng `Liên hệ` không xuất hiện dù đứng sát vị trí giả lập. Cách giả lập khi demo trong lớp: tạm thời gọi hàm vẽ với tọa độ `10.7769, 106.7009` từ console, rồi bỏ dòng tạm trước khi nộp.
- `khampha.html` lọc «Quận 1» vẫn ra quán Quận 1. `bando.html` vẫn vẽ marker và chấm vị trí.

## Chia việc gợi ý cho 5 người

| Người | Mảng | Tuần nặng |
| --- | --- | --- |
| A | Sinh `restaurants-data.js`, đối chiếu 100 ảnh | Tuần 1 |
| B | `hours.js` và ca giờ | Tuần 1 |
| C | `geo.js`, ca khoảng cách, trang test | Tuần 1 |
| D | `gantoi.html`, menu, thẻ trang chủ, CSS `gt-` | Tuần 1–2 |
| E | `gan-toi.js` nối GPS, lọc, trạng thái rỗng | Tuần 2 |

Tuần 3 cả nhóm chạy trang test, demo trên localhost, sửa lệch, rồi xem lại Khám phá và Bản đồ. Không nhận thêm mục nào ngoài `requirements.md`.
