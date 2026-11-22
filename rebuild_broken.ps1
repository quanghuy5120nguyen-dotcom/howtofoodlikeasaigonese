# rebuild_broken.ps1
# Tái tạo hoàn toàn 39 trang bị lỗi từ template sạch + dữ liệu hardcode chính xác
$ErrorActionPreference = 'Stop'
$bd  = $PSScriptRoot
$bom = New-Object System.Text.UTF8Encoding($true)

# ── Dữ liệu đúng 39 quán ────────────────────────────────────
$D = @{
 22  = @{name='Amano Local Eatery';       desc='Amano Local Eatery kết hợp phong cách pizza Napoli với những biến tấu sáng tạo mang dấu ấn địa phương. Từ pasta thủ công đến pizza với topping mới lạ, thực đơn tạo nên cuộc gặp gỡ thú vị giữa tinh thần ẩm thực Ý và khẩu vị Việt.'; hours='Sáng: 10:00–14:00; Tối: 17:00–22:00'; addr='200/25 Lê Thánh Tôn, khu vực Bến Thành'; price='200.000 – 300.000đ/người'; type='Pizza'; emoji='🍕'; district='Quận 1'; rating=4.4; rc=223; lat=10.781; lng=106.7059; imgId='7083528'; dishes=@('Mì ý thủ công bò hầm: 210.000đ','Cá hồi nướng áp chảo sốt bơ chanh: 290.000đ','Salad Burrata & cà rốt nướng: 190.000đ','Bánh tiramisu truyền thống: 95.000đ')}
 55  = @{name='Quán Lủi';                 desc='Quán ăn bình dân mang phong cách hoài cổ, chuyên phục vụ các món nhậu và món ăn gia đình đậm chất miền Nam. Không gian giản dị, gần gũi với bàn ghế tre và ánh đèn vàng ấm áp.'; hours='16:00 – 23:30'; addr='32 Nguyễn Hữu Cầu, Phường Tân Định, Quận 1'; price='100.000 – 200.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 1'; rating=4.5; rc=163; lat=10.7811; lng=106.6992; imgId='1775043'; dishes=@('Gà nướng mắm nhĩ: 220.000đ','Lẩu cá kèo lá giang: 180.000đ','Sụn gà rang muối: 95.000đ','Bắp bò ngâm mắm: 120.000đ')}
 56  = @{name='Mặn Mòi';                  desc='Nhà hàng tái hiện hương vị mâm cơm truyền thống ba miền Việt Nam trong không gian mang hơi thở hiện đại kết hợp truyền thống. Các món ăn được chế biến chăm chút, giữ nguyên nét đặc trưng quê hương.'; hours='07:00 – 22:30'; addr='39 Ngô Đức Kế, Phường Bến Nghé, Quận 1'; price='200.000 – 400.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 1'; rating=4.4; rc=98; lat=10.7793; lng=106.6999; imgId='1775043'; dishes=@('Thịt luộc cà phua mắm tôm: 120.000đ','Canh cua rau đay: 90.000đ','Chả cá Lã Vọng: 180.000đ','Nem cua bể: 110.000đ')}
 57  = @{name='Den Long - Home Cooked Vietnamese Restaurant'; desc='Nằm trong một con hẻm nhỏ yên tĩnh, quán mang lại cảm giác ấm cúng như đang dùng bữa tại nhà với những món ăn gia đình Việt Nam truyền thống được nấu rất khéo léo.'; hours='11:00 – 22:00'; addr='130/2 Ngô Đức Kế, Phường Bến Nghé, Quận 1'; price='100.000 – 250.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 1'; rating=4.4; rc=112; lat=10.7774; lng=106.7006; imgId='1775043'; dishes=@('Thịt kho tiêu trong niêu đất: 95.000đ','Đậu hũ nhồi thịt sốt cà chua: 85.000đ','Canh khổ qua dồn thịt: 80.000đ','Mực xào chua ngọt: 130.000đ')}
 58  = @{name='The Deck Saigon';           desc='Nhà hàng ven sông sang trọng nằm tại khu Thảo Điền, sở hữu không gian mở lãng mạn hướng thẳng ra sông Sài Gòn. Đây là địa điểm lý tưởng để ngắm hoàng hôn và thưởng thức ẩm thực cao cấp.'; hours='08:00 – 00:00'; addr='38 Nguyễn Ư Dĩ, Phường Thảo Điền, TP. Thủ Đức'; price='500.000 – 1.500.000đ/người'; type='Món Âu'; emoji='🍝'; district='Quận 2'; rating=4.3; rc=87; lat=10.8; lng=106.7375; imgId='1640777'; dishes=@('Cá hồi áp chảo sốt bơ chanh: 480.000đ','Bò Úc nướng sốt vang đỏ: 750.000đ','Mì Ý hải sản sốt cà chua tươi: 350.000đ','Bánh ngọt tráng miệng: 160.000đ')}
 59  = @{name='Octobar';                   desc='Quán ăn kết hợp lounge phong cách Địa Trung Hải đầy màu sắc và cá tính. Quán phục vụ các món tapas nhỏ gọn, độc đáo cùng nhiều loại cocktail sáng tạo.'; hours='16:00 – 01:00 sáng hôm sau'; addr='8 Bis Công Trường Quốc Tế, Phường 6, Quận 3'; price='200.000 – 450.000đ/người'; type='Món Âu'; emoji='🍝'; district='Quận 3'; rating=4.3; rc=74; lat=10.7738; lng=106.687; imgId='1640777'; dishes=@('Mực chiên giòn kiểu Hy Lạp: 170.000đ','Bánh mì dẹt nướng phô mai: 140.000đ','Xiên thịt cừu nướng thảo mộc: 210.000đ','Khoai tây nướng sốt tỏi: 90.000đ')}
 60  = @{name='Bánh Canh Ghẹ Ngọc Hương'; desc='Quán ăn chuyên món bánh canh ghẹ nổi tiếng với nước dùng sánh mịn, thơm đậm vị ngọt từ hải sản tươi. Ghẹ chắc thịt, được làm sạch và chuẩn bị kỹ lưỡng mỗi ngày.'; hours='07:00 – 22:00'; addr='91 Nguyễn Thái Sơn, Phường 4, Quận Gò Vấp'; price='50.000 – 120.000đ/người'; type='Món Việt'; emoji='🍜'; district='Gò Vấp'; rating=4.2; rc=156; lat=10.839; lng=106.653; imgId='1775043'; dishes=@('Bánh canh ghẹ nguyên con: 110.000đ','Bánh canh tôm thịt đặc biệt: 75.000đ','Chả cá thác lác chiên: 45.000đ','Quẩy giòn: 15.000đ')}
 61  = @{name='Chả Cá Lã Vọng Hà Nội';    desc='Quán chuyên phục vụ đặc sản chả cá Lã Vọng trứ danh đất Bắc ngay giữa lòng Sài Gòn. Miếng cá lăng tẩm nghệ nướng thơm lứt ăn kèm bún, rau thơm, đậu phộng và mắm tôm đậm đà.'; hours='10:00 – 22:00'; addr='3 Hồ Xuân Hương, Phường Võ Thị Sáu, Quận 3'; price='150.000 – 300.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 3'; rating=4.2; rc=91; lat=10.7802; lng=106.6875; imgId='1775043'; dishes=@('Phần chả cá Lã Vọng đặc biệt: 160.000đ/người','Lòng cá xào thì là: 120.000đ','Canh đầu cá nấu dọc mùng: 110.000đ','Chả cá viên chiên: 80.000đ')}
 62  = @{name='Mì Cay Sasin';             desc='Thương hiệu mì cay 7 cấp độ quen thuộc của giới trẻ, mang đến không gian năng động, trẻ trung và các món ăn đậm đà phong cách Hàn Quốc.'; hours='09:00 – 22:00'; addr='11 Tô Hiến Thành, Phường 13, Quận 10'; price='50.000 – 100.000đ/người'; type='Món Hàn'; emoji='🍖'; district='Quận 10'; rating=4.1; rc=204; lat=10.7708; lng=106.672; imgId='7187423'; dishes=@('Mì cay bò hải sản: 75.000đ','Kimbap truyền thống: 55.000đ','Tokbokki phô mai: 65.000đ','Gà rán sốt cay: 80.000đ')}
 63  = @{name='Lẩu Bò Tươi Sài Gòn';     desc='Quán lẩu bò quen thuộc với không gian bình dân, rộng rãi và thoáng mát. Nước dùng hầm từ xương bò và thuốc bắc ngọt thanh, ăn kèm thịt bò tươi mềm và các loại rau nhúng đa dạng.'; hours='15:00 – 23:00'; addr='56 Nguyễn Văn Đậu, Phường 6, Quận Bình Thạnh'; price='150.000 – 250.000đ/người'; type='Món Việt'; emoji='🍜'; district='Bình Thạnh'; rating=4.1; rc=118; lat=10.8002; lng=106.7058; imgId='1775043'; dishes=@('Lẩu bò thập cẩm: 200.000đ','Bắp bò nhúng dấm: 180.000đ','Đuôi bò hầm sả: 150.000đ','Gân bò xào sa tế: 110.000đ')}
 64  = @{name='Bánh Mì Huỳnh Hoa';        desc='Tiệm bánh mì nổi tiếng bậc nhất Sài Gòn với chiếc bánh mì "siêu nhân" ngập tràn các loại chả lụa, thịt nguội, bơ béo ngậy và pate thơm lừng đặc trưng.'; hours='06:00 – 21:00'; addr='26 Lê Thị Riêng, Phường Bến Thành, Quận 1'; price='50.000 – 75.000đ/phần'; type='Món Việt'; emoji='🍜'; district='Quận 1'; rating=4.0; rc=312; lat=10.7747; lng=106.7056; imgId='1775043'; dishes=@('Bánh mì đặc biệt thập cẩm: 68.000đ','Bánh mì bơ pate thêm chả: 65.000đ','Pate gan heo hũ: 85.000đ/hũ')}
 66  = @{name='Lẩu Nấm Ashima';           desc='Chuỗi nhà hàng lẩu nấm thiên nhiên cao cấp. Không gian thiết kế đậm chất Á Đông ấm cúng, sang trọng, chuyên phục vụ các loại nấm quý hiếm cùng nước lèo bổ dưỡng.'; hours='10:00 – 22:00'; addr='35A Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1'; price='350.000 – 600.000đ/người'; type='Hải sản'; emoji='🦐'; district='Quận 1'; rating=4.8; rc=145; lat=10.7812; lng=106.697; imgId='699953'; dishes=@('Nấm Gan Bò Mỹ: 185.000đ/phần','Thịt bò Wagyu nhúng lẩu: 420.000đ','Nước lẩu bổ dưỡng Ashima: 150.000đ','Nem nấm hải sản: 120.000đ')}
 67  = @{name='Hủ Tiếu Nam Vang Thành Đạt'; desc='Thương hiệu hủ tiếu Nam Vang bán xuyên đêm cực nổi tiếng ở Sài Gòn. Tô hủ tiếu trộn sốt đậm đà, nước súp trong vắt ngọt thanh từ xương tủy hầm nhiều giờ.'; hours='Mở cửa 24/24'; addr='34 Nguyễn Huy Tự, Phường Đa Kao, Quận 1'; price='50.000 – 85.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 1'; rating=4.7; rc=228; lat=10.7793; lng=106.6977; imgId='1775043'; dishes=@('Hủ tiếu Nam Vang khô đặc biệt: 75.000đ','Hủ tiếu nước xí quách: 70.000đ','Mì tôm mực: 70.000đ','Xí quách thêm: 40.000đ')}
 68  = @{name='Nhà Hàng Chay Tib';        desc='Nhà hàng chay mang phong cách hoài cổ, thanh lịch với không gian mang đậm dấu ấn Huế cổ kính. Món ăn thanh nhẹ, trình bày đẹp mắt và chuẩn vị.'; hours='08:30 – 21:30'; addr='170 Trần Quang Khải, Phường Tân Định, Quận 1'; price='150.000 – 300.000đ/người'; type='Món Chay'; emoji='🥗'; district='Quận 1'; rating=4.7; rc=96; lat=10.7867; lng=106.7005; imgId='1640777'; dishes=@('Cơm hấp lá sen: 110.000đ','Lẩu nấm Tib: 280.000đ','Bánh cuốn chay Huế: 75.000đ','Vịt quay chay sốt nấm: 135.000đ')}
 69  = @{name='Bún Bò Huế Đông Ba';       desc='Quán bún bò lâu đời chuẩn hương vị xứ Huế giữa trung tâm Quận 1. Nước dùng trong nhưng thơm lừng mùi mắm ruốc sả, giò heo ninh mềm và chả quết dai giòn.'; hours='06:00 – 22:30'; addr='207 Nguyễn Trãi, Phường Nguyễn Cư Trinh, Quận 1'; price='60.000 – 100.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 1'; rating=4.6; rc=183; lat=10.7756; lng=106.6991; imgId='1775043'; dishes=@('Bún bò đặc biệt đầy đủ: 85.000đ','Bún bò nạm gân chả: 70.000đ','Bánh bèo chén Huế: 50.000đ/khay','Bánh nít ram: 50.000đ')}
 70  = @{name='Mì Cạch Ký (Mì Khô Thượng Hải)'; desc='Quán mì gia truyền phong cách Chợ Lớn. Sợi mì trứng tự làm dai ngon đặc trưng, trộn cùng sốt đậm đà, ăn kèm xá xíu mềm thơm và tô nước lèo sườn kho đậm vị.'; hours='06:00–13:00 & 16:00–21:00'; addr='114 Ký Con, Phường Nguyễn Thái Bình, Quận 1'; price='50.000 – 90.000đ/người'; type='Món Hoa'; emoji='🥟'; district='Quận 1'; rating=4.6; rc=134; lat=10.7738; lng=106.6998; imgId='1683809'; dishes=@('Mì khô xá xíu sườn kho: 75.000đ','Mì hoành thánh tôm tươi: 65.000đ','Hủ tiếu mì thập cẩm: 70.000đ','Hoành thánh chiên: 50.000đ')}
 71  = @{name='CCCP Saigon';              desc='Nhà hàng chuyên món Nga và Đông Âu, có không gian hoài cổ gợi nhớ những ngôi nhà thời Liên Xô. Thực đơn gồm súp, thịt nướng và các món ăn truyền thống.'; hours='Hằng ngày 10:30–21:30'; addr='48A Nguyễn Bỉnh Khiêm, Phường Tân Định, Quận 1'; price='200.000 – 300.000đ/người'; type='Món khác'; emoji='🌍'; district='Quận 1'; rating=4.5; rc=67; lat=10.7867; lng=106.7005; imgId='1640777'; dishes=@('Thịt heo xiên nướng (pork shashlyk): 195.000đ','Bò hầm kiểu Nga (beef goulash): 167.000đ','Gà xiên nướng (chicken shashlyk): 144.000đ','Súp củ dền Borscht: 64.000đ')}
 72  = @{name='House of Merlin';          desc='Quán cocktail và đồ ăn được thiết kế theo phong cách steampunk, lấy cảm hứng từ máy móc và công nghiệp thế kỷ XIX. Không gian huyền bí kết hợp với nhạc jazz và các loại pizza sáng tạo.'; hours='Hằng ngày 18:00–01:00'; addr='178/1 Pasteur, Phường Sài Gòn, Quận 1'; price='200.000 – 400.000đ/người'; type='Pizza'; emoji='🍕'; district='Quận 1'; rating=4.5; rc=89; lat=10.7802; lng=106.7013; imgId='7083528'; dishes=@('Pizza bò lá lốt: 220.000đ','Pizza hải sản: 250.000đ','Cánh gà chiên giòn: 150.000đ','Khoai tây chiên sốt nấm truffle: 120.000đ')}
 73  = @{name='OKRA FoodBar';             desc='Nhà hàng phục vụ món ăn sáng tạo kết hợp nhiều nền ẩm thực quốc tế. Quán chú trọng nguyên liệu địa phương, cách chế biến mới lạ và không gian ấm cúng.'; hours='T2: 17:30–22:00; T4–T7: 17:30–23:00; CN: 17:30–22:00'; addr='2 Lê Văn Miến, Phường An Khánh, TP. Thủ Đức'; price='300.000 – 600.000đ/người'; type='Món khác'; emoji='🌍'; district='Quận 2'; rating=4.4; rc=58; lat=10.8002; lng=106.7379; imgId='1640777'; dishes=@('Phở bò tartare: 240.000đ','Thai grilled okra: 160.000đ','Duck tacos (2 miếng): 210.000đ','Grilled octopus: 340.000đ')}
 74  = @{name='SOLOBOX';                  desc='Nhà hàng có cách phục vụ độc đáo, trong đó món ăn được chuyển đến khách qua hệ thống giống máy bán hàng tự động. Thực đơn gồm burger, pizza, mì Ý và các món phương Tây.'; hours='Hằng ngày 10:00–00:00'; addr='252 Lý Tự Trọng, Phường Bến Thành, Quận 1'; price='150.000 – 200.000đ/người'; type='Món Mỹ'; emoji='🍔'; district='Quận 1'; rating=4.4; rc=143; lat=10.7766; lng=106.7027; imgId='1633578'; dishes=@('Beef Burger (bò Úc, bacon, cheddar): 175.000đ','Truffle Beef Burger (bò sốt truffle và nấm): 185.000đ','Duck Confit Burger (vịt confit, cheddar): 180.000đ','Chicken Burger (gà chiên giòn, coleslaw): 145.000đ')}
 75  = @{name='Xóm Chợ Cũ';              desc='Nhà hàng mang hương vị ẩm thực miền Trung, đặc biệt là các món đặc sản Quảng Ngãi. Không gian gần gũi, phù hợp với những người muốn thưởng thức món Việt truyền thống.'; hours='Hằng ngày 10:00–21:30'; addr='35 Lý Tự Trọng, Phường Sài Gòn, Quận 1'; price='100.000 – 200.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 1'; rating=4.3; rc=77; lat=10.7747; lng=106.7034; imgId='1775043'; dishes=@('Gỏi mít non thịt luộc: 85.000đ','Bánh bèo chén: 12.000đ/chén','Nước đậu rang truyền thống: 35.000đ')}
 76  = @{name='Tiệm Nướng Tàu Lửa';      desc='Quán nướng và lẩu có chủ đề tàu hỏa, nằm gần đường ray. Thực khách có thể tự nướng thịt bằng than và trải nghiệm ngắm tàu chạy ngang qua.'; hours='Hằng ngày 15:00–00:00'; addr='28 Đường Linh Đông, Hiệp Bình, TP. Thủ Đức'; price='100.000 – 200.000đ/người'; type='Món Mỹ'; emoji='🍔'; district='Thủ Đức'; rating=4.3; rc=201; lat=10.8165; lng=106.7219; imgId='1633578'; dishes=@('Ba chỉ bò nướng: 89.000đ','Ba chỉ heo nướng: 79.000đ','Chân gà nướng: 59.000đ','Bạch tuộc nướng: 129.000đ')}
 77  = @{name='Đào Liễu';                 desc='Quán ăn Việt Nam nhỏ nằm trong hẻm, nổi bật với không gian mang cảm giác như dùng bữa tại nhà. Quán hướng đến những món ăn gia đình được chế biến cẩn thận.'; hours='10:30–15:00 & 17:00–21:00 (nghỉ thứ Hai)'; addr='27/27 Huỳnh Tịnh Của, Phường Võ Thị Sáu, Quận 3'; price='200.000 – 300.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 3'; rating=4.2; rc=64; lat=10.7811; lng=106.7048; imgId='1775043'; dishes=@('Trứng chiên ngải cứu: 65.000đ','Ngọn su su xào tỏi: 75.000đ','Cá rô phi chiên giòn: 150.000đ','Ba chỉ kho: 120.000đ')}
 78  = @{name='An House Craft Beer & Egg Coffee'; desc='Quán kết hợp ẩm thực Việt Nam với cà phê trứng và đồ uống thủ công. Nơi đây nổi bật nhờ những món đặc sản vùng miền tương đối độc đáo.'; hours='Hằng ngày 10:00–23:00'; addr='68/3 Nguyễn Thái Bình, Quận 1'; price='100.000 – 250.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 1'; rating=4.2; rc=88; lat=10.7753; lng=106.6998; imgId='1775043'; dishes=@('Cà phê trứng: 55.000đ','Cà phê chồn: 90.000đ','Thịt trâu gác bếp: 150.000đ','Gà nướng kiểu vùng cao: 180.000đ')}
 79  = @{name='Nhà Anh';                  desc='Nhà hàng chuyên các món cơm nhà Việt Nam với hương vị thân thuộc. Không gian ấm cúng và thực đơn kết hợp món ăn gia đình với một số lựa chọn thịt bò cao cấp.'; hours='Hằng ngày 10:00–22:00'; addr='206 Pasteur, Phường Võ Thị Sáu, Quận 3'; price='100.000 – 200.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 3'; rating=4.1; rc=52; lat=10.779; lng=106.701; imgId='1775043'; dishes=@('Cơm chiên bò Wagyu: 180.000đ','Bò Wagyu nướng: 250.000đ','Cánh gà chiên: 100.000đ','Gỏi bò: 120.000đ')}
 80  = @{name='Quán Ân Điển';             desc='Quán ăn Việt Nam nhỏ, nằm trong hẻm ở khu vực trung tâm thành phố. Nơi đây tạo cảm giác bình dị, thân thiện và được biết đến với các món ăn quen thuộc cùng cà phê sữa.'; hours='06:00–22:00'; addr='5/5 Nguyễn Siêu, Phường Bến Nghé, Quận 1'; price='100.000 – 200.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 1'; rating=4.1; rc=69; lat=10.7757; lng=106.6969; imgId='1775043'; dishes=@('Gỏi cuốn: 40.000đ/phần','Bánh mì Việt Nam: 35.000đ','Cơm món Việt: 65.000đ','Cà phê sữa đá: 30.000đ')}
 81  = @{name='Con Ốc Quán';              desc='Quán chuyên các món ốc và lẩu mang phong cách ẩm thực Việt Nam, đặc biệt là những món có vị chua cay. Đây là lựa chọn phù hợp cho những người thích khám phá các món ốc truyền thống.'; hours='08:30–14:00 & 16:00–22:00'; addr='150/39 Nguyễn Trãi, Phường Bến Thành, Quận 1'; price='100.000 – 200.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 1'; rating=4.0; rc=107; lat=10.7738; lng=106.6976; imgId='1775043'; dishes=@('Chả ốc: 90.000đ','Ốc xào me: 100.000đ','Gỏi ốc: 100.000đ','Lẩu ốc: 200.000đ/nồi')}
 82  = @{name='Quán Bấc';                 desc='Quán ăn Việt Nam quy mô nhỏ, nằm trong hẻm và hướng đến các bữa ăn giản dị với mức giá bình dân. Không gian không quá cầu kỳ, phù hợp với thực khách yêu thích món ăn gia đình.'; hours='10:00–21:00'; addr='36/3 Lê Lợi, Phường Bến Thành, Quận 1'; price='50.000 – 100.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 1'; rating=4.9; rc=83; lat=10.772; lng=106.6983; imgId='1775043'; dishes=@('Bún đậu hũ nước tương: 45.000đ','Bún ba rọi sốt cay: 65.000đ','Bún thịt nướng: 55.000đ','Đậu hũ nhà làm sốt tiêu: 60.000đ')}
 83  = @{name='Fluid Saigon';             desc='Nhà hàng theo phong cách ẩm thực kết hợp hiện đại, phục vụ các món nhỏ để thực khách chia sẻ. Quán gây chú ý nhờ cách kết hợp hương vị bất ngờ và không gian phù hợp cho những buổi gặp gỡ.'; hours='Thứ Ba–Chủ nhật: 17:00–23:00 (nghỉ thứ Hai)'; addr='39 Nguyễn Thị Diệu, Phường Võ Thị Sáu, Quận 3'; price='300.000 – 400.000đ/người'; type='Món Âu'; emoji='🍝'; district='Quận 3'; rating=4.8; rc=72; lat=10.7791; lng=106.6876; imgId='1640777'; dishes=@('Gà nướng: 180.000đ','Sườn ăn kèm cơm chiên: 220.000đ','Bạch tuộc nướng xiên: 180.000đ','Bánh croquette: 100.000đ')}
 84  = @{name='Blanc. Restaurant';        desc='Nhà hàng ẩm thực kết hợp cao cấp, nổi bật với trải nghiệm giao tiếp bằng ngôn ngữ ký hiệu cùng đội ngũ nhân viên khiếm thính hoặc khó nghe. Không gian yên tĩnh và cách phục vụ độc đáo giúp nhà hàng trở nên khác biệt.'; hours='Thứ Ba–Chủ nhật: 17:30–23:00 (nghỉ thứ Hai)'; addr='178/180D Hai Bà Trưng, Phường Tân Định, Quận 1'; price='500.000 – 1.000.000đ/người'; type='Món Âu'; emoji='🍝'; district='Quận 1'; rating=4.8; rc=94; lat=10.7867; lng=106.7005; imgId='1640777'; dishes=@('Khai vị theo mùa: 180.000đ','Salad hải sản: 250.000đ','Món chính thịt bò: 450.000đ','Tráng miệng chocolate: 150.000đ')}
 92  = @{name='Natraj Indian Cuisine Restaurant'; desc='Nhà hàng chuyên món Bắc và Nam Ấn Độ, có các món cà ri, cơm gia vị, bánh dosa và những món nướng truyền thống.'; hours='Khoảng 10:00–22:30'; addr='41 Bùi Thị Xuân, khu vực Bến Thành, Quận 1'; price='150.000 – 300.000đ/người'; type='Món Ấn'; emoji='🍛'; district='Quận 1'; rating=4.3; rc=61; lat=10.773; lng=106.7019; imgId='1560694'; dishes=@('Cà ri gà: 140.000–200.000đ','Gà Tandoori: 180.000–280.000đ','Cơm Biryani: 120.000–180.000đ','Bánh naan: 35.000–60.000đ')}
 93  = @{name='La Villa French Restaurant'; desc='Nhà hàng Pháp cao cấp trong không gian biệt thự, nổi bật với kỹ thuật chế biến tinh tế, nguyên liệu cao cấp và thực đơn theo mùa.'; hours='Trưa: Thứ Năm–Chủ nhật; Tối: Thứ Ba–Chủ nhật'; addr='14 Ngô Quang Huy, khu vực An Khánh, TP. Thủ Đức'; price='1.500.000 – 3.500.000đ/người'; type='Món Âu'; emoji='🍝'; district='Quận 2'; rating=4.9; rc=78; lat=10.7973; lng=106.7388; imgId='1640777'; dishes=@('Thăn nội bò Black Angus: 1.990.000đ','Sườn cừu New Zealand: 1.990.000đ','Thăn nội bò Wagyu A5+: 3.090.000đ','Bánh táo Apple Tart: 490.000đ')}
 94  = @{name='Kabin – Saigon';           desc='Nhà hàng Quảng Đông trong khách sạn, nổi bật với dimsum thủ công, món quay và các món ăn truyền thống được trình bày theo phong cách cao cấp.'; hours='11:30–14:30 & 18:00–22:00'; addr='Tầng 1, Renaissance Riverside Hotel, 8–15 Tôn Đức Thắng, Quận 1'; price='500.000 – 1.000.000đ/người'; type='Món Hoa'; emoji='🥟'; district='Quận 1'; rating=4.6; rc=113; lat=10.773; lng=106.7025; imgId='1683809'; dishes=@('Gà Quý Phi: 288.000đ++','Bánh bao mực than tre: 188.000đ++','Món cua sốt trứng cua: 288.000đ++','Dimsum gọi món: giá tùy món')}
 95  = @{name='Shan Dimsum';              desc='Quán chuyên dimsum kiểu Hong Kong và các món xào Trung Hoa, phù hợp cho bữa sáng, bữa trưa hoặc bữa tối nhẹ.'; hours='7:00–14:00 & 17:00–21:00'; addr='57–59 Phù Đổng Thiên Vương, khu vực Quận 5'; price='100.000 – 250.000đ/người'; type='Món Hoa'; emoji='🥟'; district='Quận 5'; rating=4.2; rc=158; lat=10.7535; lng=106.6576; imgId='1683809'; dishes=@('Há cảo tôm: 50.000–80.000đ/phần','Xíu mại: 45.000–70.000đ/phần','Bánh bao kim sa: 35.000–55.000đ/phần','Mì xào hải sản: 100.000–160.000đ')}
 96  = @{name='Indigo Japanese Restaurant'; desc='Nhà hàng Nhật phục vụ sushi, sashimi, tempura và các món cơm, mì; có không gian phù hợp cho nhóm nhỏ và bữa ăn gia đình.'; hours='11:00–14:00 & 17:00–22:00'; addr='232 Nguyễn Đình Chiểu, Quận 3'; price='200.000 – 400.000đ/người'; type='Món Nhật'; emoji='🍣'; district='Quận 3'; rating=4.1; rc=86; lat=10.7791; lng=106.686; imgId='2098086'; dishes=@('Tôm chiên xù sốt tartar: 165.000đ','Tempura tôm và rau củ: 159.000đ','Bạch tuộc chiên giòn: 120.000đ','Đậu phụ chiên sốt nấm: 75.000đ')}
 97  = @{name='Onigiriya En';             desc='Tiệm chuyên cơm nắm Nhật Bản, phục vụ các loại nhân truyền thống và biến tấu phù hợp khẩu vị Việt Nam; thích hợp cho bữa ăn nhanh.'; hours='7:00–20:00 hằng ngày'; addr='40 Thảo Điền, khu vực An Khánh, TP. Thủ Đức'; price='50.000 – 100.000đ/người'; type='Món Nhật'; emoji='🍣'; district='Quận 2'; rating=4.1; rc=48; lat=10.7985; lng=106.7388; imgId='2098086'; dishes=@('Cơm nắm cá hồi nướng: 45.000đ','Cơm nắm mơ muối: 45.000đ','Cơm nắm cá ngừ mayonnaise: 45.000đ','Cơm nắm tôm tempura: 60.000đ')}
 98  = @{name="Hai's Restaurant";         desc='Nhà hàng Việt Nam phục vụ các món truyền thống, món cuốn, phở và các lựa chọn chay; thực đơn có cả đồ uống và món tráng miệng.'; hours='Khoảng 10:00–23:30'; addr='257 Lý Tự Trọng, khu vực Bến Thành, Quận 1'; price='150.000 – 300.000đ/người'; type='Món Việt'; emoji='🍜'; district='Quận 1'; rating=4.0; rc=92; lat=10.773; lng=106.6997; imgId='1775043'; dishes=@('Phở bò: 139.000đ','Vịt quay: 219.000đ','Bò lúc lắc kiểu Việt: 195.000đ','Phở xào hải sản: 171.000đ')}
 99  = @{name='Nhà hàng Bê Vàng';         desc='Nhà hàng quy mô lớn chuyên hải sản tươi sống, món Hoa, món Nhật, lẩu và các món thịt nướng, thích hợp cho nhóm đông và tiệc gia đình.'; hours='10:00–24:00'; addr='261–263 An Dương Vương, khu vực Chợ Quán, Quận 5'; price='300.000 – 800.000đ/người'; type='Hải sản'; emoji='🦐'; district='Quận 5'; rating=4.7; rc=176; lat=10.7558; lng=106.6617; imgId='699953'; dishes=@('Bụng cá hồi: 300.000đ','Cá ngừ vây xanh Nhật Bản: 750.000đ','Cá hồi nigiri: 120.000đ/2 miếng','Cơm chiên tỏi: 250.000đ')}
100  = @{name='Yakiuo Ishikawa Saigon';    desc='Nhà hàng Nhật có phong cách nướng hải sản kết hợp omakase, tập trung vào cá và hải sản thay cho mô hình nướng thịt thông thường.'; hours='Khoảng 11:00–14:00 & 18:00–22:00'; addr='38 Thái Văn Lung, khu vực trung tâm, Quận 1'; price='800.000 – 2.000.000đ/người'; type='Món Nhật'; emoji='🍣'; district='Quận 1'; rating=4.6; rc=55; lat=10.7771; lng=106.7018; imgId='2098086'; dishes=@('Cá theo mùa nướng kiểu Nhật: 200.000–400.000đ','Sashimi tổng hợp: 300.000–600.000đ','Hải sản nướng: 250.000–500.000đ','Set omakase: 1.000.000–2.000.000đ')}
}

# ── Hàm tạo dish cards HTML ──────────────────────────────────
function Make-DishCards($dishes) {
    $cards = @()
    foreach ($d in $dishes) {
        $ci = $d.LastIndexOf(':')
        if ($ci -gt 0) { $dn = $d.Substring(0,$ci).Trim(); $dp = $d.Substring($ci+1).Trim() }
        else { $dn = $d; $dp = 'Liên hệ' }
        $cards += "          <div class=`"dish-card`"><div class=`"dish-info`"><div class=`"dish-name`">$dn</div><div class=`"dish-price`">$dp</div></div></div>"
    }
    return $cards -join "`n"
}

# ── Hàm tạo rating bars ──────────────────────────────────────
function Make-Bars($r) {
    $rng = [System.Random]::new([int]($r.rating * 100))
    $fa = [Math]::Min(5.0,[Math]::Round($r.rating + $rng.NextDouble()*0.3, 1))
    $fk = [Math]::Max(3.5,[Math]::Round($r.rating - $rng.NextDouble()*0.8, 1))
    $fp = [Math]::Max(3.5,[Math]::Round($r.rating - $rng.NextDouble()*0.5, 1))
    $fg = [Math]::Max(3.5,[Math]::Round($r.rating - $rng.NextDouble()*0.4, 1))
    $bars = @()
    foreach ($kv in @(@("Đồ ăn",$fa),@("Không gian",$fk),@("Phục vụ",$fp),@("Giá cả",$fg))) {
        $pct = [int]($kv[1] / 5.0 * 100)
        $bars += "            <div class=`"rating-bar-row`"><span class=`"rating-bar-label`">$($kv[0])</span><div class=`"rating-bar-track`"><div class=`"rating-bar-fill`" style=`"width:$pct%`"></div></div><span class=`"rating-bar-value`">$($kv[1])</span></div>"
    }
    return $bars -join "`n"
}

# ── Hàm tạo review cards ─────────────────────────────────────
function Make-Reviews($num, $rating) {
    $rng = [System.Random]::new($num * 100)
    $lns = @('Nguyễn','Trần','Lê','Phạm','Hoàng','Phan','Vũ','Đặng','Bùi','Đỗ','Hồ','Ngô')
    $fns = @('Thanh','Minh','Phương','Hùng','Nam','Lan','Hoa','Quang','Đức','Trang','Khoa','Nhi','An','Bình')
    $txts = @('Quán ngon, không gian ấm cúng, mình sẽ quay lại lần sau.','Món ăn đậm vị, phục vụ nhiệt tình, giá cả hợp lý.','Địa điểm lý tưởng cho buổi hẹn hò hoặc tụ họp bạn bè.','Thực đơn đa dạng, mỗi món đều được chăm chút tỉ mỉ.','Nguyên liệu tươi, hương vị đậm đà, xứng đáng từng đồng.','Không gian đẹp, đồ ăn ngon — cuối tuần hơi đông nhưng vẫn đáng ghé.','Trải nghiệm ẩm thực thú vị, sẽ giới thiệu cho bạn bè.')
    $nR = $rng.Next(2,4)
    $reviews = @()
    for ($i=0; $i -lt $nR; $i++) {
        $ln = $lns[$rng.Next(0,$lns.Count)]; $fn = $fns[$rng.Next(0,$fns.Count)]
        $sc = if ($rating -ge 4.5){5} else { if ($rng.NextDouble() -gt 0.3){5} else {4} }
        $st = ('★'*$sc)+('☆'*(5-$sc))
        $mo=$rng.Next(1,11); $dy=$rng.Next(1,29)
        $dt='{0:00}/{1:00}/2025' -f $dy,$mo
        $tx=$txts[$rng.Next(0,$txts.Count)]
        $reviews += "        <div class=`"review-card`"><div class=`"review-header`"><div class=`"review-avatar`">$($fn.Substring(0,1))</div><div><div class=`"review-name`">$ln $fn</div><div class=`"review-date`">$dt</div></div></div><div class=`"review-stars`">$st</div><p class=`"review-text`">$tx</p></div>"
    }
    return $reviews -join "`n"
}

# ── Hàm tạo toàn bộ HTML cho 1 trang ────────────────────────
function Make-Html($num, $r) {
    $starsDisp = ('★'*[int]$r.rating)+('☆'*(5-[int]$r.rating))
    $dishCards = Make-DishCards $r.dishes
    $bars      = Make-Bars $r
    $reviews   = Make-Reviews $num $r.rating
    $jsName    = $r.name -replace "'","\'" -replace '"','&quot;'
    $jsAddr    = $r.addr -replace "'","\'" -replace '"','&quot;'

    return @"
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>$($r.name) | How To Food Like A Saigonese</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>
  <link rel="stylesheet" href="css/style.css"/>
  <style>
    .sp-body{max-width:860px;margin:0 auto;padding:2rem 1.5rem 4rem;}
    .sp-section{margin-bottom:2.5rem;}
    .sp-section-title{font-size:1.15rem;font-weight:800;color:#1a1a1a;margin-bottom:1rem;padding-bottom:.5rem;border-bottom:2px solid #f0ede8;display:flex;align-items:center;gap:.45rem;}
    .sp-desc{color:#555;line-height:1.85;margin-bottom:.75rem;font-size:.975rem;}
    .sp-empty{color:#aaa;font-size:.9rem;padding:.5rem 0;}
    .sp-chips{display:grid;grid-template-columns:repeat(2,1fr);gap:.75rem;margin-top:1.25rem;}
    @media(max-width:560px){.sp-chips{grid-template-columns:1fr;}}
    .sp-chip{display:flex;align-items:flex-start;gap:.65rem;padding:.85rem 1rem;background:#faf9f7;border:1.5px solid #f0ede8;border-radius:10px;}
    .sp-chip-icon{font-size:1.3rem;line-height:1;flex-shrink:0;margin-top:1px;}
    .sp-chip-lbl{font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.05em;color:#aaa;display:block;margin-bottom:2px;}
    .sp-chip-val{font-size:.88rem;font-weight:600;color:#1a1a1a;display:block;line-height:1.4;}
    .sp-chip-val.sp-price{color:#cf3b1b;}
    .sp-map-btn{display:inline-flex;align-items:center;gap:.5rem;margin-top:.75rem;padding:.6rem 1.2rem;background:linear-gradient(135deg,#e8722a,#cf3b1b);color:#fff;border-radius:9px;font-size:.875rem;font-weight:700;text-decoration:none;}
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
    <img src="https://images.pexels.com/photos/$($r.imgId)/pexels-photo-$($r.imgId).jpeg?auto=compress&cs=tinysrgb&w=1400" alt="$($r.name)" class="subpage-hero-img" onerror="this.src='https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1400'"/>
    <div class="subpage-hero-overlay"></div>
    <div class="subpage-hero-content">
      <div class="subpage-badges">
        <span class="subpage-badge">$($r.emoji) $($r.type)</span>
        <span class="subpage-badge">📍 $($r.district)</span>
        <span class="subpage-badge">⭐ $($r.rating) / 5</span>
      </div>
      <h1>$($r.name)</h1>
    </div>
  </div>

  <div class="container">
    <nav class="breadcrumb">
      <a href="index.html">Trang chủ</a><span>›</span>
      <a href="khampha.html">Khám phá</a><span>›</span>
      $($r.name)
    </nav>
  </div>

  <div class="sp-body">

    <section class="sp-section" id="sec-cauchyen">
      <h2 class="sp-section-title">📖 Câu chuyện quán</h2>
      <p class="sp-desc">$($r.desc)</p>
      <div class="sp-chips">
        <span class="sp-chip"><span class="sp-chip-icon">🕐</span><span class="sp-chip-lbl">Giờ mở cửa</span><span class="sp-chip-val">$($r.hours)</span></span>
        <span class="sp-chip"><span class="sp-chip-icon">📍</span><span class="sp-chip-lbl">Địa chỉ</span><span class="sp-chip-val">$($r.addr)</span></span>
        <span class="sp-chip"><span class="sp-chip-icon">💰</span><span class="sp-chip-lbl">Mức giá</span><span class="sp-chip-val sp-price">$($r.price)</span></span>
        <span class="sp-chip"><span class="sp-chip-icon">$($r.emoji)</span><span class="sp-chip-lbl">Loại quán</span><span class="sp-chip-val">$($r.type)</span></span>
      </div>
    </section>

    <section class="sp-section" id="sec-mon">
      <h2 class="sp-section-title">🍽 Món nổi bật</h2>
      <div class="dishes-grid">
$dishCards
      </div>
    </section>

    <section class="sp-section" id="sec-danhgia">
      <h2 class="sp-section-title">⭐ Đánh giá từ thực khách</h2>
      <div class="rating-overview">
        <div style="text-align:center;">
          <div class="rating-big">$($r.rating)</div>
          <div style="color:#e0a318;font-size:1.2rem;">$starsDisp</div>
          <div style="font-size:.78rem;color:#aaa;margin-top:4px;">$($r.rc) đánh giá</div>
        </div>
        <div class="rating-bars">
$bars
        </div>
      </div>
$reviews
    </section>

    <section class="sp-section" id="sec-vitri">
      <h2 class="sp-section-title">📍 Vị trí quán</h2>
      <p style="color:#666;margin-bottom:.5rem;">$($r.addr)</p>
      <div id="minimap" class="sp-minimap"></div>
      <a href="bando.html" class="sp-map-btn" style="margin-top:.9rem;">🗺 Xem trên bản đồ tổng</a>
    </section>

  </div>

  <footer class="footer"><p>© 2025 How To Food Like A Saigonese | Made with ❤️ bởi Nhóm 4 — Lớp 10.1</p></footer>

  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
  <script>
    (function(){var b=document.getElementById('hamburgerBtn'),l=document.getElementById('navLinks');b.addEventListener('click',function(){var o=l.classList.toggle('open');b.setAttribute('aria-expanded',o);b.classList.toggle('active',o);});})();
    (function(){
      var done=false;
      function initMap(){
        if(done)return; done=true;
        var m=L.map('minimap',{scrollWheelZoom:false}).setView([$($r.lat),$($r.lng)],16);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{attribution:'© OpenStreetMap',maxZoom:19}).addTo(m);
        L.marker([$($r.lat),$($r.lng)]).addTo(m).bindPopup('<strong>$jsName</strong><br>$jsAddr').openPopup();
        setTimeout(function(){m.invalidateSize();},200);
      }
      if('IntersectionObserver' in window){
        var obs=new IntersectionObserver(function(e){if(e[0].isIntersecting){initMap();obs.disconnect();}},{threshold:0.1});
        obs.observe(document.getElementById('minimap'));
      } else { initMap(); }
    })();
  </script>
</body>
</html>
"@
}

# ── Build tất cả ─────────────────────────────────────────────
Write-Host "Rebuilding $($D.Count) pages from scratch..."
foreach ($num in ($D.Keys | Sort-Object)) {
    $html = Make-Html $num $D[$num]
    [System.IO.File]::WriteAllText("$bd\quan-$num.html", $html, $bom)
    Write-Host "  quan-$num.html — $($D[$num].name)"
}

Write-Host ""
Write-Host "=== VERIFY ==="
foreach ($n in @(55,66,74,84,100)) {
    $f = [System.IO.File]::ReadAllText("$bd\quan-$n.html",[System.Text.Encoding]::UTF8)
    $ok1 = $f -match 'sp-chip-val">(?!:)' # không bắt đầu bằng ':'
    $ok2 = $f -match 'dish-name'
    $ok3 = $f -match 'sec-vitri'
    $ok4 = -not ($f -match '\$1[3-9]\d')   # không có $132...
    Write-Host "  quan-$n.html: chips-ok=$ok1 | dishes=$ok2 | vitri-ok=$ok3 | no-junk=$ok4"
}
Write-Host "Done!"
