# Firebase Setup Guide for CLASSY Admin Panel

## 🔥 **Firebase Permission Issue Fix**

The "Missing or insufficient permissions" error occurs because Firestore security rules are blocking access to the `admin_users` collection. Here's how to fix it:

## **Step 1: Update Firestore Security Rules**

1. **Go to Firebase Console:**
   - Open [Firebase Console](https://console.firebase.google.com/project/classyapp-unified-backend/firestore/rules)
   - Navigate to **Firestore Database** → **Rules**

2. **Replace the existing rules with:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Allow read/write access to admin_users collection for authenticated users
       match /admin_users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Allow read access to admin_users collection for admin users
       match /admin_users/{document=**} {
         allow read: if request.auth != null;
       }
       
       // Allow write access to admin_users collection for initial setup
       match /admin_users/{document=**} {
         allow write: if request.auth != null;
       }
       
       // Allow read/write access to all other collections for authenticated users
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

3. **Click "Publish" to save the rules**

## **Step 2: Alternative - Temporary Open Rules (Development Only)**

If you want to allow all access temporarily for development:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **WARNING:** Only use this for development. Never use open rules in production!

## **Step 3: Test the Setup**

1. **Refresh the admin panel page**
2. **Click "Setup Admin User" button**
3. **Wait for success message**
4. **Try logging in with admin@classy.com / admin123**

## **Step 4: Production Security Rules (Recommended)**

For production, use more restrictive rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admin users can read/write their own data
    match /admin_users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admin users can read all admin users
    match /admin_users/{document=**} {
      allow read: if request.auth != null;
    }
    
    // Only allow writes to admin_users for authenticated users
    match /admin_users/{document=**} {
      allow write: if request.auth != null;
    }
    
    // Other collections - adjust based on your needs
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /orders/{document=**} {
      allow read, write: if request.auth != null;
    }
    
    match /drivers/{document=**} {
      allow read, write: if request.auth != null;
    }
    
    match /vendors/{document=**} {
      allow read, write: if request.auth != null;
    }
    
    match /restaurants/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## **Troubleshooting**

### **Error: "Missing or insufficient permissions"**
- **Cause:** Firestore security rules are blocking access
- **Solution:** Update the security rules as shown above

### **Error: "User not found in admin database"**
- **Cause:** Admin user doesn't exist in Firestore
- **Solution:** Click "Setup Admin User" button after fixing security rules

### **Error: "Firebase Auth user not found"**
- **Cause:** Firebase Auth user doesn't exist
- **Solution:** The setup function will create both Auth user and Firestore document

## **Firebase Project Configuration**

Make sure your Firebase project has:

1. **Authentication enabled** with Email/Password provider
2. **Firestore Database created**
3. **Security rules updated** (as shown above)
4. **Web app registered** with correct configuration

## **Environment Variables**

The admin panel uses these Firebase configuration values:

```env
VITE_FIREBASE_API_KEY=AIzaSyASmUafz431YLkL6d1tNL9qv5cuHC1TkDw
VITE_FIREBASE_AUTH_DOMAIN=classyapp-unified-backend.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=classyapp-unified-backend
VITE_FIREBASE_STORAGE_BUCKET=classyapp-unified-backend.firebasestorage.app
VITE_FIREBASE_MESSAGING_SENDER_ID=156854442550
VITE_FIREBASE_APP_ID=1:156854442550:web:classyapp-unified-backend
```

## **Next Steps After Setup**

1. **Test login** with admin@classy.com / admin123
2. **Create additional admin users** through the admin panel
3. **Set up proper role-based permissions**
4. **Configure production security rules**
5. **Set up monitoring and logging**

## **Support**

If you continue to have issues:

1. Check the browser console for detailed error messages
2. Verify Firebase project configuration
3. Ensure security rules are properly published
4. Check that the Firebase project is active and not suspended

The admin panel should work perfectly once the Firestore security rules are updated!
