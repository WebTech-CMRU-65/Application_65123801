# 🎯 คู่มือฟีเจอร์โปรไฟล์ผู้ใช้ (User Profile Feature)

## 📋 ฟีเจอร์ที่เพิ่มเข้ามา

### ✨ ความสามารถหลัก
1. **ดูข้อมูลโปรไฟล์** - แสดงข้อมูลส่วนตัวของผู้ใช้
2. **แก้ไขข้อมูล** - แก้ไขชื่อ, อีเมล, และเบอร์โทร
3. **จัดการรูปภาพโปรไฟล์**
   - อัปโหลดรูปภาพจากแกลเลอรี
   - ลบรูปภาพโปรไฟล์
4. **ลบข้อมูลโปรไฟล์** - ลบข้อมูลทั้งหมด (ไม่รวมบัญชี)

### 🎨 UI/UX ที่สวยงาม
- Gradient background สีม่วง-ชมพู
- รูปภาพโปรไฟล์แบบวงกลมพร้อม border สวยงาม
- Animation และ Shadow effects
- Validation แบบ real-time
- SnackBar แจ้งเตือนสถานะการทำงาน
- Responsive design

## 📁 ไฟล์ที่สร้างใหม่

1. **lib/user_profile.dart** - Model สำหรับข้อมูลโปรไฟล์
2. **lib/profile_service.dart** - Service จัดการข้อมูลกับ Firebase
3. **lib/profile_page.dart** - หน้า UI โปรไฟล์ผู้ใช้

## 🔧 ไฟล์ที่แก้ไข

1. **pubspec.yaml** - เพิ่ม dependencies:
   - `firebase_storage: ^12.3.8`
   - `image_picker: ^1.1.2`

2. **lib/main.dart** - เพิ่ม route `/profile`

3. **lib/home_page.dart** - เพิ่มปุ่มไปหน้าโปรไฟล์

## ⚙️ การตั้งค่าที่จำเป็น

### 1. Firebase Storage Rules

ไปที่ Firebase Console > Storage > Rules และตั้งค่าดังนี้:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_photos/{userId}.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 2. Android Permissions

เพิ่มใน `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <!-- อนุญาตให้เข้าถึงแกลเลอรี -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    
    <!-- อนุญาตให้ใช้อินเทอร์เน็ต -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application ...>
    ...
    </application>
</manifest>
```

### 3. iOS Permissions

เพิ่มใน `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>ต้องการเข้าถึงแกลเลอรีเพื่อเลือกรูปโปรไฟล์</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>ต้องการบันทึกรูปภาพลงในแกลเลอรี</string>
```

## 🚀 วิธีใช้งาน

### 1. เข้าสู่หน้าโปรไฟล์
- กดปุ่ม **โปรไฟล์** (ไอคอนรูปคน) ที่ AppBar ในหน้า Home

### 2. แก้ไขข้อมูล
1. กดปุ่ม **"แก้ไขข้อมูล"**
2. กรอกข้อมูล: ชื่อ, อีเมล, เบอร์โทร
3. กดปุ่ม **"บันทึก"**

### 3. จัดการรูปภาพโปรไฟล์
1. กดปุ่มไอคอนกล้องที่มุมรูปโปรไฟล์
2. เลือก **"เลือกรูปภาพ"** เพื่ออัปโหลดใหม่
3. หรือเลือก **"ลบรูปภาพ"** เพื่อลบรูปปัจจุบัน

### 4. ลบข้อมูลโปรไฟล์
1. กดปุ่ม **"ลบข้อมูลโปรไฟล์"**
2. ยืนยันการลบ
3. ข้อมูลทั้งหมดจะถูกลบ แต่บัญชียังคงอยู่

## 🎯 Validation Rules

- **ชื่อ**: จำเป็นต้องกรอก (เมื่ออยู่ในโหมดแก้ไข)
- **อีเมล**: ต้องเป็นรูปแบบอีเมลที่ถูกต้อง (ถ้ากรอก)
- **เบอร์โทร**: ต้องเป็นตัวเลข 9-10 หลัก (ถ้ากรอก)
- **รูปภาพ**: ขนาดสูงสุด 512x512 pixels, คุณภาพ 75%

## 🗄️ โครงสร้างข้อมูลใน Firestore

```
users/{userId}/
  - displayName: string
  - email: string
  - phoneNumber: string
  - photoUrl: string
  - createdAt: timestamp
  - updatedAt: timestamp
```

## 🔐 Security Features

1. **Authentication Required** - ต้องเข้าสู่ระบบก่อนใช้งาน
2. **User Isolation** - ผู้ใช้แก้ไขได้เฉพาะข้อมูลของตัวเอง
3. **Storage Security** - รูปภาพถูกจัดเก็บแบบ private
4. **Input Validation** - ตรวจสอบข้อมูลก่อนบันทึก

## 📱 รันแอพพลิเคชัน

```bash
# ติดตั้ง dependencies
flutter pub get

# รันบน Android
flutter run

# รันบน iOS
flutter run

# รันบน Web (ต้องตั้งค่า CORS ใน Firebase Storage)
flutter run -d chrome
```

## 🐛 Troubleshooting

### ปัญหา: อัปโหลดรูปไม่ได้
**แก้ไข**: ตรวจสอบ Firebase Storage Rules และ permissions บน Android/iOS

### ปัญหา: ไม่สามารถเลือกรูปได้
**แก้ไข**: ตรวจสอบ permissions ใน AndroidManifest.xml และ Info.plist

### ปัญหา: ข้อมูลไม่อัปเดต
**แก้ไข**: ตรวจสอบ Firestore Rules ว่าอนุญาตให้ user อ่าน/เขียนข้อมูลได้

## 🎉 คุณสมบัติเด่น

- ✅ Real-time updates ด้วย Firestore Streams
- ✅ Image optimization (รีไซส์และบีบอัดอัตโนมัติ)
- ✅ Error handling ที่ครอบคลุม
- ✅ Loading states ที่ชัดเจน
- ✅ Confirmation dialogs สำหรับการลบข้อมูล
- ✅ Beautiful gradient UI
- ✅ Form validation
- ✅ Responsive design

## 📞 การใช้งานใน Code

```dart
// ใช้ ProfileService
final profileService = ProfileService();

// อัปเดตโปรไฟล์
await profileService.updateProfile(
  uid: userId,
  displayName: 'ชื่อใหม่',
  email: 'email@example.com',
  phoneNumber: '0812345678',
);

// อัปโหลดรูปภาพ
final photoUrl = await profileService.uploadProfilePhoto(userId);

// ลบรูปภาพ
await profileService.deleteProfilePhoto(userId);

// ลบข้อมูลทั้งหมด
await profileService.deleteProfileData(userId);
```

---

🎊 **ฟีเจอร์โปรไฟล์ผู้ใช้พร้อมใช้งานแล้ว!** 🎊
