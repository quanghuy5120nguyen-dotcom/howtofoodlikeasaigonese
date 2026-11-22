# Việc làm: Gần tôi, đang mở cửa

Mỗi mục là một buổi (khoảng 2–3 giờ). Làm đúng `requirements.md` và `design.md`. Năm người có thể chia tuần 1 theo ghi chú «Người»; tuần 2–3 làm nối tiếp vì trang thật cần hàm thuần đã xong.

Quy ước đánh dấu: `- [ ]` chưa xong, `- [x]` đã xong và đã đối chiếu tiêu chí ghi ở cuối mục.

---

## Tuần 1 — Dữ liệu và hàm thuần

- [ ] 1. Lập bảng giờ thật trên 100 quán
  - **Thanh Mai.** Đọc `restaurants.json`, đếm bốn nhóm: một khung giờ, hai khung ngăn bởi `;`, có «Thứ … – Thứ …», và `Liên hệ`.
  - Ghi số đếm vào đầu file sẽ thành `js/hours.js` (có thể tạo file chỉ với comment ở buổi này).
  - _Yêu cầu: 2.4, 5.5_

- [ ] 2. Sinh `js/restaurants-data.js`
  - **Hoàng Mai.** Viết một script PowerShell chạy một lần tại thư mục website, đọc `restaurants.json`, tìm `hinhanhquan/quan-{Num}.*`, cắt mô tả tối đa 120 ký tự không cắt giữa từ, ghi biến `RESTAURANTS` đúng các trường trong `design.md`.
  - Mở file bằng trình duyệt qua một trang HTML tạm: `console.log` ra 100 phần tử và không có trường `image` rỗng.
  - Không sửa `restaurants.json`.
  - _Yêu cầu: 2.1, 2.2, 2.3, 2.4_

- [ ] 3. Parse một khung giờ và mốc mở / đóng
  - **Quỳnh Như.** Trong `js/hours.js`, chuẩn hóa dấu gạch, parse `H:MM - H:MM`, coi `00:00` là phút 1440.
  - `isOpenAt` nhận `now`. Đúng phút mở thì `open`, đúng phút đóng thì `closed`.
  - Tự kiểm năm ca đầu của bảng trong `design.md` (khung đơn và ca nửa đêm).
  - _Yêu cầu: 5.1, 5.2, 5.6_

- [ ] 4. Parse hai khung trong cùng ngày
  - **Quỳnh Như.** Cắt bằng `;`. Sai một mảnh thì cả chuỗi `unknown`.
  - Tự kiểm hai ca `11:00–14:00; 18:00–22:00` lúc 15:00 và 19:00.
  - _Yêu cầu: 5.3, 5.6_

- [ ] 5. Parse thứ trong tuần và chuỗi không dùng được
  - **Quỳnh Như.** Nhận `Thứ A - Thứ B:` với đủ bảy tên trong `design.md`, kể cả dải đi vòng qua Chủ Nhật.
  - `Liên hệ`, chuỗi rỗng và chữ không đúng mẫu trả `unknown`.
  - Tự kiểm ca Thứ Hai / Thứ Ba của chuỗi `Thứ Ba – Chủ Nhật: 17:30 – 23:00`, ca Chủ Nhật của `Thứ Bảy - Thứ Hai: 10:00 - 12:00`, và `Liên hệ`.
  - _Yêu cầu: 5.4, 5.5, 5.6_

- [ ] 6. Tính và ghi khoảng cách
  - **Quang Huy.** `js/geo.js`: `distanceKm` với R = 6371, `formatDistance` theo mét hoặc một chữ số thập phân kèm «km».
  - Tự kiểm vị trí `10.7769, 106.7009` tới quán 1 (< 1 km) và quán 60 (> 5 km).
  - _Yêu cầu: 4.1, 4.4, 4.6_

- [ ] 7. Trang test gom các ca của hàm thuần
  - **Quang Huy**, sau mục 3–6. Tạo `js/test-gan-toi.html`, nạp `hours.js` và `geo.js`, in từng ca ĐÚNG/SAI và một dòng tổng.
  - Buổi xong khi mọi ca trong `design.md` đều ĐÚNG trên trình duyệt.
  - Không thêm link tới trang này ở menu.
  - _Yêu cầu: 4.6, 5.6_

---

## Tuần 2 — Trang và bộ lọc

- [ ] 8. Khung `gantoi.html` và lối vào
  - **Chiêu An.** Dựng navbar, hero (dùng `hinhanhquan/header-khampha.jpg`), footer giống trang Khám phá, kèm hamburger.
  - Thêm mục «Gần tôi» vào menu của `index.html`, `khampha.html`, `bando.html`, `goiy.html` và `gantoi.html`. Chỉ `gantoi.html` đặt `active`.
  - Thêm một `nav-card` «Gần tôi, đang mở cửa» vào khối «Khám phá theo cách của bạn» trên trang chủ.
  - Không sửa file `quan-*.html`.
  - _Yêu cầu: 1.1, 1.2, 1.3, 1.4, 7.4_

- [ ] 9. Thanh điều khiển và câu trạng thái
  - **Chiêu An.** Thêm `.gt-controls` ở cuối `css/style.css`: nút «Dùng vị trí của tôi», `<select id="gtRadius">` ba option 1/3/5 km (mặc định 3), chỗ trống cho nút «Làm mới», dòng `.gt-status`.
  - Viết các câu trạng thái tiếng Việt cho `idle`, `loading`, `denied`, `unsupported`, `ready` và danh sách rỗng theo đúng câu ở `design.md`.
  - Buổi này được dùng chữ tĩnh để chốt câu, chưa cần GPS.
  - _Yêu cầu: 3.1, 3.2, 3.3, 3.5, 4.2_

- [ ] 10. Vẽ thẻ từ mảng đã lọc sẵn
  - **Chiêu An.** Hàm nhận một mảng 2–3 quán giả, vẽ `.card` với ảnh, badge quận, badge loại, tên link `quan-{num}.html`, mô tả, giá, sao, nhãn «Đang mở», khoảng cách, chuỗi giờ.
  - Dùng class `.card` có sẵn. CSS mới chỉ thêm `.gt-distance` và nhãn mở cửa.
  - _Yêu cầu: 6.2, 6.3_

- [ ] 11. Nối GPS, bán kính và giờ mở
  - **Thanh Mai**, sau mục 2, 7 và 10. `js/gan-toi.js` giữ trạng thái trong `design.md`.
  - Vừa mở trang: không gọi geolocation, không có thẻ.
  - Bấm nút chính: một lần `getCurrentPosition`, khóa nút khi đang chờ, timeout 8000 ms.
  - Lọc `km <= radiusKm` và `state === "open"`, sắp xếp gần hơn trước, hòa thì `rating` cao hơn trước.
  - Đổi select khi đã có vị trí thì vẽ lại, không hỏi GPS lại.
  - «Làm mới» xin vị trí mới và `new Date()` mới.
  - Không lưu tọa độ ra storage.
  - _Yêu cầu: 3.1, 3.2, 3.3, 3.4, 3.6, 4.3, 4.5, 6.1, 6.4, 6.5_

- [ ] 12. Thông báo lỗi quyền và danh sách rỗng
  - **Hoàng Mai.** Từ chối quyền, timeout, và trình duyệt không có geolocation: đúng câu tiếng Việt, số thẻ bằng 0.
  - Khi lọc ra 0 quán ở mức 1 km và 3 km, `.empty-state` gợi ý tăng bán kính. Ở mức 5 km, câu nói trong 5 km không có quán đang mở.
  - Dòng đếm khi có kết quả đúng mẫu «Tìm thấy N quán đang mở trong bán kính X km».
  - _Yêu cầu: 3.5, 6.4, 6.6_

---

## Tuần 3 — Hoàn thiện trên trình duyệt

- [ ] 13. Co màn hình nhỏ
  - **Quang Huy.** Tại chiều rộng 768px, thanh `.gt-controls` xếp dọc, nút và select rộng đầy khung, menu hamburger mở và đóng được, thẻ không tràn ngang.
  - Đối chiếu màu `#cf3b1b`, nền `#faf9f7`, font Be Vietnam Pro với `khampha.html`.
  - _Yêu cầu: 1.3, 6.2_

- [ ] 14. Chạy lại trang test sau khi nối giao diện
  - **Quỳnh Như & Quang Huy.** Mở `js/test-gan-toi.html`, xác nhận vẫn tất cả ĐÚNG sau các sửa ở tuần 2.
  - Sửa lệch trong `hours.js` hoặc `geo.js` nếu có, rồi chạy lại đến khi hết SAI.
  - _Yêu cầu: 4.6, 5.6_

- [ ] 15. Demo trên localhost và soát trang cũ
  - Cả nhóm. Mở site bằng server tĩnh (Live Server), không dùng `file://` cho bước GPS.
  - Đi một lượt: chưa bấm nút → cho phép vị trí → đổi 1 → 3 → 5 km → bấm «Làm mới» → từ chối quyền → bấm một tên quán ra đúng trang chi tiết.
  - Với tọa độ giả lập `10.7769, 106.7009` (gọi tạm từ console rồi xóa trước khi nộp): quán `Liên hệ` không nằm trong kết quả, quán 60 không nằm trong mức 5 km.
  - Mở Khám phá, lọc Quận 1, thấy thẻ Quận 1. Mở Bản đồ, thấy 100 marker, ô tìm kiếm và nút vị trí vẫn hoạt động.
  - Xóa mọi `console.log` và mọi tọa độ giả lập còn trong `gan-toi.js` trước khi nộp.
  - _Yêu cầu: 6.1, 6.2, 7.1, 7.2, 7.3, 7.4_

---

## Việc cố ý không xếp buổi

- Sửa 100 trang `quan-*.html` để thêm menu «Gần tôi» (xem yêu cầu 1.4).
- Lọc «đang mở» trên Khám phá hoặc trên Bản đồ.
- Thêm chỉ đường, bán kính tự gõ, tài khoản, hoặc thư viện mới.
