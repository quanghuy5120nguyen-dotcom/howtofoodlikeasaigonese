# How To Food Like A Saigonese

## Sản phẩm hiện tại

Website tĩnh giới thiệu 100 quán ăn ở TP.HCM. Người xem đọc giới thiệu, lọc danh sách, xem vị trí trên bản đồ và gửi gợi ý quán. Không có tài khoản, máy chủ riêng hay cơ sở dữ liệu.

Người làm hiện ghi ở chân trang: Nhóm 4 — Lớp 10.1. Tính năng mới trong spec `gan-toi-dang-mo-cua` do nhóm 5 học sinh làm trong 3 tuần.

## Người dùng

- Người đam mê ẩm thực đang ở TP.HCM, muốn chọn quán để đi ngay.
- Du khách muốn tìm hiểu quán ăn Sài Gòn trước khi đến hoặc khi đang đứng trên phố.

## Trang đang có

| Trang | Việc trang đang làm |
| --- | --- |
| `index.html` | Giới thiệu, số liệu, ba thẻ dẫn tới Khám phá, Bản đồ, Gợi ý |
| `khampha.html` | 100 thẻ quán gắn sẵn trong HTML. Lọc trên trình duyệt theo tên, quận, loại món, mức giá, số sao, và buổi (sáng / trưa / tối / cả ngày) |
| `bando.html` | Bản đồ Leaflet + OpenStreetMap, danh sách quán, ô tìm tên, nút «Vị trí của tôi» chỉ thả một chấm xanh |
| `goiy.html` | Form 4 bước gửi gợi ý quán, xử lý trên trình duyệt |
| `quan-1.html` … `quan-100.html` | Chi tiết một quán: câu chuyện, món, điểm, giờ, địa chỉ, bản đồ nhỏ |

Menu chung: Trang chủ, Khám phá, Bản đồ, Gợi ý. Menu mobile dùng nút hamburger.

## Dữ liệu

`restaurants.json` có đúng 100 quán. Mỗi quán có `Num`, `Name`, `District`, `Type`, `Rating`, `Price`, `Hours`, `Lat`, `Lng`, `Address`, `Description`, `Emoji`, `Dishes`. Cả 100 quán đều có tọa độ.

Chuỗi `Hours` không cùng một kiểu:

- 57 quán: một khung giờ trong ngày, ví dụ `10:30 - 22:30`. Dấu gạch có thể là `-`, `–` hoặc `—`.
- 8 quán: hai khung, ngăn bởi `;`, ví dụ `11:00–14:00; 18:00–22:00`.
- 2 quán: kèm thứ, ví dụ `Thứ Ba – Chủ Nhật: 17:30 – 23:00`.
- 33 quán: đúng chữ `Liên hệ`.
- 1 quán đóng lúc nửa đêm, ví dụ `11:30 – 00:00`.

Trang Khám phá không đọc chuỗi này khi lọc. Thuộc tính `data-hours` trên thẻ chỉ là `sang`, `trua`, `toi` hoặc `ngay`. Trang Bản đồ nhúng mảng rút gọn (tên, tọa độ, quận, loại, sao, emoji) và không có giờ.

Ảnh nằm ở `hinhanhquan/`, tên `quan-{số}` với đuôi `.jpg`, `.jpeg` hoặc `.webp`.

## Giao diện và công nghệ

- HTML, CSS, JavaScript thuần. Không framework, không bundler.
- Font Be Vietnam Pro. Nền `#faf9f7`. Chữ `#1a1a1a`. Màu nhấn `#cf3b1b`. Sao `#e0a318`.
- Thành phần dùng lại: `.navbar`, `.page-hero`, `.card`, `.badge`, `.btn-primary`, `.footer`, `.empty-state`.
- Bản đồ: Leaflet 1.9.4 từ unpkg, nền OpenStreetMap.
- Trang mở được bằng file HTML. Định vị GPS trên nhiều trình duyệt chỉ chạy khi trang được mở qua `http://localhost` hoặc HTTPS.

## Việc trang chưa làm

Nút vị trí trên bản đồ không lọc quán theo khoảng cách. Bộ lọc giờ trên Khám phá không so với đồng hồ lúc người dùng đang xem. Chưa có trang nào trả lời cùng lúc «quán nào đang mở và nằm gần tôi».
