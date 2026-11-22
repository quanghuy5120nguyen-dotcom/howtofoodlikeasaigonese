# Yêu cầu: Gần tôi, đang mở cửa

## Bối cảnh

Website hiện tại gồm 100 trang quán ăn tại TP.HCM với các trang Khám phá (lọc tĩnh), Bản đồ (Leaflet), Gợi ý (form), và trang chủ. Spec này chỉ thêm một cách tìm quán: lấy vị trí GPS của người dùng, giữ quán trong bán kính đã chọn, và chỉ giữ quán đang mở theo giờ máy tại thời điểm bấm lọc.

Người dùng chính là người đam mê ẩm thực và du khách muốn tìm quán ở TP.HCM. Nhóm 5 học sinh làm trong 3 tuần. Giữ HTML/CSS/JS thuần và giao diện đang dùng (Be Vietnam Pro, `#cf3b1b`, `#faf9f7`, thẻ `.card`, navbar, hero, footer).

## Ngoài phạm vi

Nhóm để nguyên các việc sau:

- Lọc theo tên, quận, loại món, giá, số sao và buổi trên `khampha.html`.
- Bản đồ Leaflet, ô tìm tên và chấm «Vị trí của tôi» trên `bando.html`.
- Form gợi ý, 100 trang `quan-*.html`, câu chữ chân trang.
- Tài khoản, chỉ đường, yêu thích, đặt bàn, đánh giá mới, thông báo, lưu vị trí, gọi API giờ bên ngoài.
- Bán kính tự nhập, lọc thêm trên trang mới, tự cập nhật danh sách mỗi phút.

---

## Yêu cầu 1 — Có lối vào trang mới

**Câu chuyện người dùng:** Là người đang mở website, tôi muốn thấy «Gần tôi» ở menu và trang chủ, để vào đúng tính năng mà không phải đoán đường dẫn.

**Tiêu chí chấp nhận:**

1.1. WHEN người dùng mở `index.html`, `khampha.html`, `bando.html`, `goiy.html` hoặc `gantoi.html`, THEN menu có mục «Gần tôi» trỏ tới `gantoi.html`, cùng kiểu chữ và khoảng cách với các mục hiện có.
1.2. WHEN trang đang mở là `gantoi.html`, THEN mục «Gần tôi» có class `active`. Các trang kia không gắn `active` cho mục này.
1.3. WHEN người dùng mở trang chủ, THEN khối «Khám phá theo cách của bạn» có thêm một `nav-card` «Gần tôi, đang mở cửa», mô tả một câu: lọc quán theo vị trí GPS và giờ mở cửa hiện tại, bấm vào thì tới `gantoi.html`.
1.4. WHEN so sánh 100 file `quan-*.html` với bản trước khi làm tính năng, THEN nội dung các file đó giữ nguyên, kể cả menu.

---

## Yêu cầu 2 — Dữ liệu quán sẵn sàng cho tính năng mới

**Câu chuyện người dùng:** Là nhà phát triển, tôi muốn có một file dữ liệu tập trung đủ các trường cần thiết để trang mới không phụ thuộc vào mảng quán đang nhúng sẵn trong `bando.html` hay `khampha.html`.

**Tiêu chí chấp nhận:**

2.1. WHEN tải `js/restaurants-data.js`, THEN có biến toàn cục `RESTAURANTS` là mảng 100 phần tử, mỗi phần tử có đủ các trường: `num`, `name`, `district`, `type`, `rating`, `price`, `hours`, `lat`, `lng`, `emoji`, `description`, `image`.
2.2. WHEN kiểm trường `image` của từng phần tử, THEN đường dẫn trỏ tới đúng file tồn tại trong `hinhanhquan/`, đúng phần mở rộng (`.jpg`, `.jpeg`, `.webp` hoặc `.png`).
2.3. WHEN kiểm trường `description`, THEN mỗi chuỗi không dài quá 120 ký tự và không bị cắt giữa từ.
2.4. WHEN sinh file, THEN không sửa `restaurants.json` gốc. Script sinh file chạy một lần bằng PowerShell.

---

## Yêu cầu 3 — Trạng thái giao diện rõ ràng

**Câu chuyện người dùng:** Là người dùng lần đầu vào trang, tôi muốn biết trang đang chờ tôi làm gì, đang xử lý, hay có lỗi, thay vì nhìn màn hình trắng không hiểu.

**Tiêu chí chấp nhận:**

3.1. WHEN trang vừa tải xong (`idle`), THEN danh sách quán ẩn, nút chính hiện «Dùng vị trí của tôi», chưa có nút «Làm mới», chưa có hộp hỏi quyền trình duyệt.
3.2. WHEN người dùng bấm nút chính, THEN nút bị khóa (`disabled`), dòng trạng thái hiện «Đang lấy vị trí…», và trang gọi `getCurrentPosition` với `enableHighAccuracy: true`, `timeout: 8000`.
3.3. WHEN lấy vị trí thành công (`ready`), THEN nút «Dùng vị trí của tôi» mở khóa, nút «Làm mới» xuất hiện, danh sách quán được vẽ.
3.4. WHEN người dùng bấm «Làm mới», THEN trang xin vị trí mới (`getCurrentPosition` lần hai) và dùng `new Date()` mới để tính giờ mở cửa.
3.5. WHEN người dùng từ chối quyền, hết timeout, hoặc trình duyệt không có `navigator.geolocation`, THEN dòng trạng thái hiện đúng câu tiếng Việt tương ứng (xem câu cụ thể ở `design.md`), danh sách quán trống.
3.6. WHEN đã ở trạng thái `ready` và người dùng đổi bán kính, THEN trang vẽ lại từ tọa độ và `at` đang giữ, không gọi `getCurrentPosition` lần nữa.

---

## Yêu cầu 4 — Giữ quán trong bán kính

**Câu chuyện người dùng:** Là người đang đứng ở một điểm, tôi muốn chỉ thấy quán đủ gần để đi, và biết mỗi quán cách bao nhiêu.

**Tiêu chí chấp nhận:**

4.1. WHEN tính khoảng cách giữa hai tọa độ, THEN dùng công thức Haversine với bán kính Trái Đất 6371 km.
4.2. WHEN trang mới mở phần chọn bán kính, THEN có đúng ba mức 1 km, 3 km và 5 km, mức đang chọn là 3 km.
4.3. WHEN đã có vị trí người dùng, THEN một quán được xét tiếp khi khoảng cách từ người dùng tới `lat`/`lng` của quán nhỏ hơn hoặc bằng mức đang chọn.
4.4. WHEN hiển thị khoảng cách dưới 1 km, THEN ghi theo mét, làm tròn đến hàng đơn vị. WHEN khoảng cách từ 1 km trở lên, THEN ghi một chữ số thập phân kèm «km».
4.5. WHEN danh sách có nhiều quán, THEN quán gần hơn đứng trước. WHEN hai quán cách đều nhau, THEN quán có `rating` cao hơn đứng trước.
4.6. WHEN vị trí giả lập là `10.7769, 106.7009`, THEN khoảng cách tới Bếp mẹ ỉn (`10.7791, 106.701`, quán số 1) nhỏ hơn 1 km, và khoảng cách tới Bánh Canh Ghẹ Ngọc Hương (`10.839, 106.653`, quán số 60) lớn hơn 5 km.

---

## Yêu cầu 5 — Biết quán có đang mở hay không

**Câu chuyện người dùng:** Là người muốn ăn ngay, tôi muốn quán đã đóng hoặc chưa rõ giờ biến khỏi danh sách «đang mở cửa».

Hàm xét giờ nhận thời điểm `now` do người gọi truyền vào. Trang thật truyền `new Date()` lúc bấm lọc hoặc «Làm mới». Ca kiểm thử truyền giờ cố định.

**Tiêu chí chấp nhận:**

5.1. WHEN chuỗi giờ là một khung `giờ:phút` tới `giờ:phút`, THEN trang chấp nhận dấu `-`, `–`, `—` và khoảng trắng thừa. Phút mở cửa tính là đang mở. Đúng phút đóng cửa tính là đã đóng.
5.2. WHEN giờ đóng là `00:00`, THEN hiểu là 24:00 cùng ngày. Ví dụ `11:30 – 00:00` mở lúc 23:00 và đóng lúc 00:30.
5.3. WHEN chuỗi có nhiều khung ngăn bởi `;`, THEN quán đang mở nếu `now` nằm trong ít nhất một khung. Ví dụ `11:00–14:00; 18:00–22:00` đóng lúc 15:00 và mở lúc 19:00.
5.4. WHEN chuỗi có dạng `Thứ A – Thứ B: khung giờ`, THEN quán chỉ mở trong các thứ từ A đến B, tính cả hai đầu, theo `getDay()` của `now` (Chủ Nhật = 0, Thứ Hai = 1, …, Thứ Bảy = 6). Ví dụ `Thứ Ba – Chủ Nhật: 17:30 – 23:00` đóng vào Thứ Hai lúc 18:00 và mở vào Thứ Ba lúc 18:00. Nếu chỉ số thứ bắt đầu lớn hơn thứ kết thúc, dải thứ đi vòng qua Chủ Nhật.
5.5. WHEN chuỗi là `Liên hệ`, rỗng, hoặc không đúng các mẫu ở 5.1–5.4, THEN kết quả là «chưa rõ», và quán đó không có mặt trong danh sách đang mở.
5.6. WHEN chạy các ca ở 5.1–5.5 với `now` cố định, THEN mỗi ca cho đúng mở, đóng hoặc chưa rõ, không phụ thuộc đồng hồ máy lúc chạy test.

---

## Yêu cầu 6 — Danh sách là giao của hai điều kiện

**Câu chuyện người dùng:** Là người vừa đói vừa đang trên đường, tôi muốn một danh sách chỉ gồm quán vừa gần vừa đang mở, trình bày giống các thẻ quán sẵn có.

**Tiêu chí chấp nhận:**

6.1. WHEN đã có vị trí, THEN mỗi quán trong danh sách thỏa cùng lúc tiêu chí 4.3 và đang mở theo yêu cầu 5. Quán «chưa rõ» không xuất hiện.
6.2. WHEN vẽ một quán, THEN thẻ dùng class `card` đang có: ảnh, badge quận, badge loại món, tên là liên kết tới `quan-{num}.html`, mô tả, giá, số sao.
6.3. WHEN vẽ một quán đã lọt lọc, THEN thẻ có thêm nhãn «Đang mở», khoảng cách theo 4.4, và nguyên văn chuỗi `hours`.
6.4. WHEN có kết quả, THEN dòng đếm đọc «Tìm thấy N quán đang mở trong bán kính X km», với N và X đúng mức vừa tính.
6.5. WHEN người dùng đổi bán kính sau khi đã có vị trí, THEN trang tính lại trên tọa độ đang giữ, không hỏi GPS lần nữa.
6.6. WHEN không quán nào thỏa, THEN vùng thẻ trống và có khối `.empty-state` tiếng Việt. Nếu mức đang chọn là 1 km hoặc 3 km, câu chữ gợi ý chọn mức lớn hơn. Nếu đang là 5 km, câu chữ nói trong 5 km không có quán đang mở.

---

## Yêu cầu 7 — Trang cũ vẫn dùng được

**Câu chuyện người dùng:** Là người đang dùng Khám phá hoặc Bản đồ, tôi muốn các trang đó vẫn hoạt động sau khi có mục menu mới.

**Tiêu chí chấp nhận:**

7.1. WHEN mở Khám phá và chọn một bộ lọc cũ (quận, loại, giá, sao hoặc buổi), THEN số thẻ hiện ra vẫn theo đúng luật lọc sẵn có trong `khampha.html`.
7.2. WHEN mở Bản đồ, THEN 100 marker vẫn hiện, ô tìm tên vẫn lọc danh sách, nút «Vị trí của tôi» vẫn thả chấm xanh như trước.
7.3. WHEN xem mã trang mới, THEN không thêm thư viện CSS/JS mới. Leaflet không được nhúng vào `gantoi.html`.
7.4. WHEN đếm việc làm trong 3 tuần, THEN diff chỉ gồm lối vào ở yêu cầu 1, file dữ liệu và script của tính năng, phần CSS mới có tiền tố `gt-`, và `gantoi.html`.
