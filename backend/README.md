Nội dung Prompt: "Tôi muốn cập nhật chức năng Đăng ký và Đăng nhập cho dự án NHPCalendar. Hãy thực hiện các thay đổi sau:

1. Database (SQL Server):

Cập nhật bảng Users: Thêm cột Email (NVARCHAR(255), UNIQUE, NOT NULL).

Đảm bảo khi chạy script tạo bảng, cột này luôn bắt buộc.

2. Backend (Node.js):

API Đăng ký: Cập nhật để nhận thêm trường email từ request body. Kiểm tra định dạng email hợp lệ và kiểm tra xem email đã tồn tại trong hệ thống chưa trước khi lưu.

Cấu hình Nodemailer: Viết module gửi mail bằng Gmail (sử dụng App Password).

API Đăng nhập: Khi user đăng nhập đúng mật khẩu, Backend sẽ tự động tạo mã OTP 6 số, lưu vào DB và gửi mã này vào Email mà người dùng đã đăng ký trước đó. Trả về một trạng thái (status) yêu cầu xác thực OTP.

3. Frontend (Flutter):

Màn hình Đăng ký: Thêm một TextFormField để người dùng nhập Email. Có validation đảm bảo người dùng nhập đúng định dạng @gmail.com.

Màn hình Đăng nhập: Sau khi bấm 'Login', nếu nhận được phản hồi yêu cầu OTP, chuyển sang màn hình nhập mã xác thực.

Màn hình OTP: Hiển thị dòng chữ 'Mã xác thực đã được gửi đến email: [email của user]'.

Hãy cung cấp cho tôi:

Code API Đăng ký mới (Node.js).

Code màn hình Đăng ký có thêm trường Email (Flutter).

Logic gửi mail OTP sau khi Login thành công."