# Quick Start Guide - Frontend Integration

## 🚀 Immediate Steps to Connect Frontend Apps

### 1. Quick API Base URL Update (5 minutes)

#### Customer App
Navigate to `Apps/Customer/Frontend/lib/constants/api.dart` and update:

```dart
static String get baseUrl {
  // Quick change - point to unified backend
  return "http://localhost:8000/api";  // Development
  // return "https://your-domain.com/api";  // Production
}
```

#### Driver App
Navigate to `Apps/Driver/Frontend/lib/constants/api.dart` and update:

```dart
static String get baseUrl {
  // Quick change - point to unified backend
  return "http://localhost:8000/api";  // Development
  // return "https://your-domain.com/api";  // Production
}
```

#### Vendor App
Navigate to `Apps/Vendor/Frontend/lib/constants/api.dart` and update:

```dart
static String get baseUrl {
  // Quick change - point to unified backend
  return "http://localhost:8000/api";  // Development
  // return "https://your-domain.com/api";  // Production
}
```

### 2. Test Connection (2 minutes)

Run any of the apps and check if they can connect to the unified backend:

```bash
# Test Customer App
cd Apps/Customer/Frontend
flutter run

# Test Driver App
cd Apps/Driver/Frontend
flutter run

# Test Vendor App
cd Apps/Vendor/Frontend
flutter run
```

### 3. Verify API Endpoints (3 minutes)

Check if these basic endpoints respond:
- `GET /api/v1/health` - Health check
- `GET /api/v1/auth/status` - Authentication status
- `GET /api/v1/vendors` - Vendor list

## ✅ Success Check

If you see:
- Apps launch without errors
- No "connection refused" messages
- API calls return responses (even if 401/403)

Then the basic connection is working! 🎉

## 🔧 Next Steps

1. **Read the full guide**: `FRONTEND_INTEGRATION_GUIDE.md`
2. **Implement environment configs** for production
3. **Update API services** with proper error handling
4. **Test all app features** with the unified backend

## 🆘 Quick Troubleshooting

**App won't connect?**
- Check if unified backend is running (`php artisan serve`)
- Verify port 8000 is accessible
- Check firewall/antivirus settings

**API errors?**
- Check backend logs in `storage/logs/laravel.log`
- Verify database connection
- Check if migrations are run (`php artisan migrate`)

---

**Need help?** Check the full `FRONTEND_INTEGRATION_GUIDE.md` for detailed instructions.
