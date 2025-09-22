# Netlify Deployment Guide for Classy Admin Panel

## Prerequisites

1. **Netlify Account**: Sign up at [netlify.com](https://netlify.com) if you don't have one
2. **GitHub Repository**: Your code should be in a GitHub repository
3. **Node.js**: Version 18 or higher (Netlify will use this automatically)

## Deployment Methods

### Method 1: Deploy from GitHub (Recommended)

1. **Connect Repository**:
   - Go to [Netlify Dashboard](https://app.netlify.com)
   - Click "New site from Git"
   - Choose "GitHub" and authorize Netlify
   - Select your repository

2. **Configure Build Settings**:
   - **Base directory**: `Apps/Admin`
   - **Build command**: `npm run build`
   - **Publish directory**: `dist`
   - **Node version**: `18`

3. **Environment Variables**:
   - Go to Site settings → Environment variables
   - Add the following variables:
     ```
     VITE_FIREBASE_API_KEY=AIzaSyASmUafz431YLkL6d1tNL9qv5cuHC1TkDw
     VITE_FIREBASE_AUTH_DOMAIN=classyapp-unified-backend.firebaseapp.com
     VITE_FIREBASE_PROJECT_ID=classyapp-unified-backend
     VITE_FIREBASE_STORAGE_BUCKET=classyapp-unified-backend.firebasestorage.app
     VITE_FIREBASE_MESSAGING_SENDER_ID=156854442550
     VITE_FIREBASE_APP_ID=1:156854442550:web:classyapp-unified-backend
     ```

4. **Deploy**:
   - Click "Deploy site"
   - Netlify will automatically build and deploy your admin panel

### Method 2: Manual Deploy via Netlify CLI

1. **Install Netlify CLI**:
   ```bash
   npm install -g netlify-cli
   ```

2. **Login to Netlify**:
   ```bash
   netlify login
   ```

3. **Build the Project**:
   ```bash
   cd Apps/Admin
   npm install
   npm run build
   ```

4. **Deploy**:
   ```bash
   netlify deploy --prod --dir=dist
   ```

### Method 3: Drag and Drop Deploy

1. **Build the Project**:
   ```bash
   cd Apps/Admin
   npm install
   npm run build
   ```

2. **Deploy**:
   - Go to [Netlify Dashboard](https://app.netlify.com)
   - Drag and drop the `dist` folder to the deploy area

## Post-Deployment Configuration

### 1. Custom Domain (Optional)
- Go to Site settings → Domain management
- Add your custom domain
- Configure DNS settings as instructed

### 2. HTTPS Certificate
- Netlify automatically provides HTTPS certificates
- Your site will be available at `https://your-site-name.netlify.app`

### 3. Firebase Security Rules
Ensure your Firebase security rules allow access from your Netlify domain:

```javascript
// In Firebase Console → Firestore → Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Add your admin panel domain to allowed origins
    match /{document=**} {
      allow read, write: if request.auth != null && 
        request.auth.token.admin == true;
    }
  }
}
```

## Environment Variables Reference

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `VITE_FIREBASE_API_KEY` | Firebase API Key | `AIzaSyASmUafz431YLkL6d1tNL9qv5cuHC1TkDw` |
| `VITE_FIREBASE_AUTH_DOMAIN` | Firebase Auth Domain | `classyapp-unified-backend.firebaseapp.com` |
| `VITE_FIREBASE_PROJECT_ID` | Firebase Project ID | `classyapp-unified-backend` |
| `VITE_FIREBASE_STORAGE_BUCKET` | Firebase Storage Bucket | `classyapp-unified-backend.firebasestorage.app` |
| `VITE_FIREBASE_MESSAGING_SENDER_ID` | Firebase Messaging Sender ID | `156854442550` |
| `VITE_FIREBASE_APP_ID` | Firebase App ID | `1:156854442550:web:classyapp-unified-backend` |

## Troubleshooting

### Build Failures
- Check that all dependencies are in `package.json`
- Ensure Node.js version is 18 or higher
- Check build logs in Netlify dashboard

### Firebase Connection Issues
- Verify environment variables are set correctly
- Check Firebase project settings
- Ensure Firebase project is active

### Routing Issues
- The `netlify.toml` file includes redirect rules for SPA routing
- All routes should redirect to `index.html` for client-side routing

### Performance Optimization
- The build is optimized with code splitting
- Static assets are cached for 1 year
- Source maps are disabled for production

## Security Considerations

1. **Environment Variables**: Never commit sensitive keys to your repository
2. **Firebase Rules**: Ensure proper authentication and authorization rules
3. **HTTPS**: Always use HTTPS in production
4. **Admin Access**: Implement proper admin authentication

## Monitoring and Analytics

- Netlify provides built-in analytics
- Monitor build times and site performance
- Set up error tracking if needed

## Continuous Deployment

Once connected to GitHub:
- Every push to the main branch triggers a new deployment
- Pull requests can be previewed with deploy previews
- Rollback to previous deployments if needed

## Support

- [Netlify Documentation](https://docs.netlify.com/)
- [Vite Documentation](https://vitejs.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
