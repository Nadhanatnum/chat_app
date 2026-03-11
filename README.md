# chat_app

# chat_app

# Chat App

แอปพลิเคชันแชทที่พัฒนาด้วย Flutter SDK และ Firebase โดยเน้นการสร้างระบบยืนยันตัวตน (Authentication) ที่มีความปลอดภัย สวยงาม และรองรับการทำงานแบบ Multi-platform (Android, iOS, Web)



## Key Features

### ระบบยืนยันตัวตน (Authentication)
- **Email & Password:** ระบบสมัครสมาชิกและเข้าสู่ระบบมาตรฐานผ่าน Firebase Auth
- **Social Login:** รองรับการเข้าสู่ระบบด้วย **Google** และ **Microsoft** (OAuth) 
- **Auto-Sync Firestore:** ระบบจะสร้างเอกสารผู้ใช้ (User Document) ใน Cloud Firestore โดยอัตโนมัติเมื่อมีการสมัครสมาชิกใหม่

### การออกแบบและประสบการณ์ผู้ใช้ (UI/UX)
- **Custom Theme:** ออกแบบในสไตล์ **Purple Dark Mode** โดยใช้ Gradient และ Glassmorphism
- **Animations:** ใช้ `AnimationController` สำหรับเอฟเฟกต์ **Fade-in** เมื่อเปิดหน้าจอเข้าใช้งาน
- **Image Picker:** รองรับการเลือกรูปโปรไฟล์ (Profile Picture) และจัดการข้อมูลแบบ Base64/URL
- **Validation:** ระบบตรวจสอบความถูกต้องของฟอร์ม (Form Validation) แบบ Real-time

### รองรับหลายแพลตฟอร์ม
- โค้ดมีการแยก Logic ระหว่าง **Mobile** และ **Web** (ใช้ `kIsWeb`) เพื่อให้รองรับการทำ Social Sign-in บน Browser ได้อย่างสมบูรณ์

## Tech Stack

| Component | Technology |
|---|---|
| **Frontend** | Flutter SDK (Dart) |
| **Backend** | Firebase Authentication, Cloud Firestore |
| **State Management** | StatefulWidget & Logic-driven UI |
| **Packages** | `firebase_auth`, `cloud_firestore`, `google_sign_in` |

