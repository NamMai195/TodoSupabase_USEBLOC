# Ứng Dụng Quản Lý Công Việc với Flutter & Supabase

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)

## 📝 Giới thiệu

Ứng dụng quản lý công việc được xây dựng bằng Flutter và Supabase, giúp người dùng tổ chức và theo dõi công việc một cách hiệu quả. Với giao diện người dùng trực quan và khả năng đồng bộ hóa thời gian thực, ứng dụng mang lại trải nghiệm mượt mà trên mọi thiết bị.

## ✨ Tính năng nổi bật

- 📋 **Quản lý công việc**
  - Thêm công việc mới với tiêu đề và mô tả
  - Chỉnh sửa thông tin công việc
  - Xóa công việc không cần thiết
  - Đánh dấu công việc đã hoàn thành
  
- 🔐 **Bảo mật người dùng**
  - Đăng ký tài khoản mới
  - Đăng nhập bằng email/mật khẩu
  - Khôi phục mật khẩu
  - Quản lý thông tin cá nhân

- 🔄 **Đồng bộ hóa**
  - Tự động đồng bộ dữ liệu giữa các thiết bị
  - Hoạt động offline với đồng bộ tự động khi có mạng
  - Thông báo thời gian thực khi có cập nhật

## 🛠️ Công nghệ sử dụng

- **Frontend**: Flutter SDK
- **Backend**: Supabase
- **Database**: PostgreSQL
- **Authentication**: Supabase Auth
- **State Management**: Bloc Pattern

## 📁 Cấu trúc thư mục

```
lib/
├── bloc/               # Quản lý state với Bloc pattern
├── env/               # Cấu hình môi trường
├── models/            # Models dữ liệu
├── presentation/      # Giao diện người dùng
└── main.dart          # Điểm khởi đầu ứng dụng
```

## 🚀 Hướng dẫn cài đặt

1. **Yêu cầu hệ thống**
   - Flutter (phiên bản mới nhất)
   - Dart SDK
   - IDE (VS Code hoặc Android Studio)

2. **Cài đặt dự án**
   ```bash
   # Clone dự án
   git clone https://github.com/your-username/flutter_todo_supabase.git

   # Di chuyển vào thư mục dự án
   cd flutter_todo_supabase

   # Cài đặt dependencies
   flutter pub get
   ```

3. **Cấu hình Supabase**
   - Tạo file `.env` trong thư mục gốc
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Chạy ứng dụng**
   ```bash
   flutter run
   ```

## 📱 Nền tảng hỗ trợ

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ Linux
- ✅ macOS