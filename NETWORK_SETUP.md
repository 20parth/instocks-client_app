# Instocks Client App - Network Configuration Guide

## 🚨 Error: "Failed host lookup: 'api-portfolio.instocks.net'"

This error occurs when running on a **real device** because the device cannot access the backend API. The emulator works because it can access localhost, but real devices need different configuration.

## 🔧 Solutions

### **Solution 1: Use Local IP Address (For Development)**

When your backend is running on your computer:

#### Step 1: Find Your Computer's IP Address

**On Mac:**
```bash
ipconfig getifaddr en0
# Output example: 192.168.1.100
```

**On Linux:**
```bash
hostname -I
# Output example: 192.168.1.100
```

**On Windows:**
```bash
ipconfig
# Look for "IPv4 Address" under your active network adapter
# Example: 192.168.1.100
```

#### Step 2: Update Your Backend to Allow External Connections

**For Laravel (your backend):**

Edit `your-backend-project/.env`:
```env
APP_URL=http://192.168.1.100:8000
```

Then restart your Laravel server to listen on all interfaces:
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

#### Step 3: Run Flutter App with Your IP

```bash
# Replace 192.168.1.100 with YOUR computer's actual IP
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000/api
```

**IMPORTANT**: 
- Both your computer and phone must be on the **same WiFi network**
- Your firewall must allow connections on port 8000

---

### **Solution 2: Use ngrok (Public Tunnel - Easy)**

If you want a public URL that works anywhere:

#### Step 1: Install ngrok
```bash
# Mac
brew install ngrok

# Or download from https://ngrok.com/download
```

#### Step 2: Start Your Backend
```bash
php artisan serve
# Backend running on http://127.0.0.1:8000
```

#### Step 3: Create Tunnel
```bash
ngrok http 8000
```

This will output something like:
```
Forwarding https://abc123.ngrok.io -> http://localhost:8000
```

#### Step 4: Run Flutter App
```bash
flutter run --dart-define=API_BASE_URL=https://abc123.ngrok.io/api
```

**Advantages:**
- Works on any network (WiFi, cellular, etc.)
- HTTPS by default
- No firewall issues

**Disadvantages:**
- Free tier has session limits
- URL changes each time you restart ngrok

---

### **Solution 3: Update .env File (Quick Fix)**

Edit `.env` file with your local IP:

```env
API_BASE_URL=http://192.168.1.100:8000/api
```

Then run without `--dart-define`:
```bash
flutter clean
flutter run
```

**Note:** Remember to change this back before production builds!

---

### **Solution 4: Production Server (If Backend is Deployed)**

If `api-portfolio.instocks.net` is supposed to be a real server but isn't set up yet:

1. **Deploy your Laravel backend** to a hosting provider
2. **Set up DNS** to point `api-portfolio.instocks.net` to your server
3. **Configure SSL** certificate for HTTPS
4. Then use:
```bash
flutter run --dart-define=API_BASE_URL=https://api-portfolio.instocks.net/api
```

---

## 🎯 Recommended Development Workflow

### **For Daily Development:**

1. **Find your local IP once:**
```bash
ipconfig getifaddr en0  # Mac
# Example output: 192.168.1.100
```

2. **Start backend with host binding:**
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

3. **Run Flutter app:**
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000/api
```

### **For Testing on Multiple Devices:**

Use **ngrok** to avoid IP address issues:

```bash
# Terminal 1: Start backend
php artisan serve

# Terminal 2: Start ngrok
ngrok http 8000

# Terminal 3: Run Flutter (use ngrok URL)
flutter run --dart-define=API_BASE_URL=https://YOUR-NGROK-URL.ngrok.io/api
```

---

## 🐛 Troubleshooting

### Device Can't Connect to Local IP

1. **Check same WiFi:**
```bash
# On your phone: Settings > WiFi > Check network name
# On your computer: Should be on same network
```

2. **Test connection:**
```bash
# On phone browser, visit: http://192.168.1.100:8000
# Should see Laravel welcome page or API response
```

3. **Check firewall:**
```bash
# Mac - Allow port 8000
System Preferences > Security & Privacy > Firewall > Firewall Options
Add "php" or "artisan" to allowed apps

# Or temporarily disable firewall for testing
```

### Backend CORS Errors

If you get CORS errors after fixing the connection, update your Laravel backend:

**File: `config/cors.php`**
```php
'allowed_origins' => ['*'],  // Or specific origins
'allowed_origins_patterns' => [],
'allowed_headers' => ['*'],
'allowed_methods' => ['*'],
```

Then:
```bash
php artisan config:cache
```

---

## 📱 Quick Reference Commands

### Testing on Real Device (Same WiFi)
```bash
# 1. Find IP
ipconfig getifaddr en0

# 2. Start backend
php artisan serve --host=0.0.0.0 --port=8000

# 3. Run app (replace IP)
flutter run --dart-define=API_BASE_URL=http://YOUR-IP:8000/api
```

### Testing with ngrok
```bash
# 1. Start backend
php artisan serve

# 2. Start ngrok
ngrok http 8000

# 3. Copy ngrok URL and run app
flutter run --dart-define=API_BASE_URL=https://YOUR-NGROK-URL.ngrok.io/api
```

### Emulator (Works with localhost)
```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api
```

---

## 🎨 Android Emulator Special Case

Android emulator uses `10.0.2.2` to access host machine's `localhost`:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

---

## 🚀 For Production

Once backend is deployed:

```bash
# Build production app
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://your-actual-domain.com/api
```

Remember to update `.env` file back to production URL before building!

---

## ✅ Current Status

Your `.env` file currently has:
```
API_BASE_URL=https://api-portfolio.instocks.net/api
```

This domain doesn't exist or isn't accessible, which is why you're getting the error.

**Action Required:**
1. Either use local IP (Solution 1)
2. Or use ngrok (Solution 2)
3. Or deploy backend and set up DNS (Solution 4)
