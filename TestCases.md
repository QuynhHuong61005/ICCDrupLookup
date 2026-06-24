# Kịch bản Kiểm thử Hệ thống (System Test Cases) & UAT

Tài liệu này bao gồm các trường hợp kiểm thử (Test Cases) cơ bản để phục vụ cho quá trình kiểm tra chức năng hệ thống và quá trình UAT (User Acceptance Testing) với bác sĩ.

## 1. Tìm kiếm và tra cứu thuốc (IC-16, IC-17)

| ID | Tên Test Case | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC_DRUG_01 | Tìm kiếm thuốc bằng tên thương mại | 1. Vào màn hình Tra cứu Thuốc<br>2. Nhập "Panadol" vào ô tìm kiếm | Danh sách hiển thị các loại thuốc có chữ "Panadol" trong tên thương mại (VD: Panadol Extra). | [ ] |
| TC_DRUG_02 | Tìm kiếm thuốc bằng tên hoạt chất | 1. Vào màn hình Tra cứu Thuốc<br>2. Nhập "Paracetamol" vào ô tìm kiếm | Danh sách hiển thị tất cả các thuốc có chứa hoạt chất "Paracetamol". | [ ] |
| TC_DRUG_03 | Lọc thuốc theo hoạt chất | 1. Tại màn hình Tra cứu Thuốc<br>2. Bấm vào dropdown chọn "Paracetamol" | Danh sách chỉ hiển thị những thuốc có đúng hoạt chất "Paracetamol", kết hợp điều kiện từ khóa tìm kiếm (nếu có). | [ ] |
| TC_DRUG_04 | Xem chi tiết thông tin thuốc | 1. Bấm vào một thẻ thuốc bất kỳ trong danh sách (vd: Panadol) | Chuyển sang màn hình Chi tiết Thuốc, hiển thị đầy đủ Chỉ định, Chống chỉ định, Tác dụng phụ, v.v. | [ ] |

## 2. Tìm kiếm và tra cứu mã ICD-10 (IC-13, IC-14, IC-15)

| ID | Tên Test Case | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC_ICD_01 | Tìm kiếm ICD-10 bằng mã | 1. Vào màn hình Tra cứu ICD<br>2. Nhập "J06" vào ô tìm kiếm | Hiển thị mã ICD J06 (Viêm đường hô hấp cấp tính...). | [ ] |
| TC_ICD_02 | Tìm kiếm ICD-10 bằng tên bệnh | 1. Nhập từ khóa "viêm" vào ô tìm kiếm | Danh sách hiển thị các bệnh lý có chứa chữ "viêm". | [ ] |
| TC_ICD_03 | Lọc ICD-10 theo nhóm bệnh | 1. Chọn nhóm bệnh "Diseases of the respiratory system" từ dropdown | Danh sách chỉ hiển thị các bệnh lý thuộc nhóm Hô hấp. | [ ] |
| TC_ICD_04 | Xem chi tiết mã ICD-10 | 1. Chọn một mã ICD trong danh sách kết quả | Hiển thị thông tin mã, tên bệnh, triệu chứng liên quan, và các thuốc gợi ý cho bệnh đó. | [ ] |

## 3. Xem trạng thái BHYT của thuốc (IC-18)

| ID | Tên Test Case | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC_BHYT_01 | Hiển thị trạng thái BHYT ở màn hình Chi tiết Thuốc | 1. Tra cứu và vào xem chi tiết một loại thuốc (vd: Aspirin)<br>2. Cuộn xuống mục "BHYT Coverage & Supported Indications" | Hiển thị danh sách các bệnh (ICD) mà thuốc này được chỉ định, kèm theo cờ BHYT (BHYT Covered màu xanh, hoặc Non-BHYT màu vàng) và liều lượng. | [ ] |
| TC_BHYT_02 | Hiển thị thuốc gợi ý ở màn hình Chi tiết Bệnh | 1. Tra cứu một mã bệnh (vd: I10) và xem chi tiết<br>2. Xem danh sách "Standard Suggested Drugs" | Hiển thị thuốc Aspirin kèm theo nhãn "BHYT Covered" rõ ràng. | [ ] |

## 4. Kiểm tra Tương tác thuốc (Drug Interactions)

| ID | Tên Test Case | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC_INT_01 | Phân tích tương tác giữa 2 thuốc độc lập | 1. Trong Prescription / CDSS, thêm Aspirin và Ibuprofen vào danh sách<br>2. Nhấn "Phân tích tương tác" | Cảnh báo mức độ MODERATE, mô tả nguy cơ giảm hiệu quả bảo vệ tim mạch và yêu cầu giãn cách giờ uống thuốc. | [ ] |
| TC_INT_02 | Phân tích tương tác nguy hiểm (SEVERE) | 1. Thêm Aspirin và Warfarin vào danh sách<br>2. Nhấn "Phân tích tương tác" | Cảnh báo mức độ SEVERE màu đỏ: nguy cơ xuất huyết tiêu hóa, yêu cầu theo dõi sát chỉ số INR. | [ ] |

## 5. UI/UX & Responsive (IC-80, IC-81)

| ID | Tên Test Case | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC_UI_01 | Chuyển đổi Dark Mode | 1. Vào màn hình Settings<br>2. Bật công tắc "Dark Mode" | Giao diện chuyển sang tông màu tối, chữ dễ đọc, tương phản đúng theo chuẩn. | [ ] |
| TC_UI_02 | Kiểm tra trên màn hình Tablet/Desktop | 1. Mở ứng dụng trên trình duyệt máy tính, kéo giãn cửa sổ | Cấu trúc Navigation thay đổi linh hoạt (Bottom Navigation -> Navigation Rail -> Drawer) tuỳ độ rộng màn hình. Giao diện GridView tự căn chỉnh số lượng cột hiển thị. | [ ] |

*(Tài liệu này có thể tiếp tục được bổ sung thêm bởi QA/Tester trong quá trình kiểm thử)*
