#!/bin/bash

echo "🔧 Instocks Client App - Network Setup Helper"
echo "=============================================="
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    IP=$(ipconfig getifaddr en0)
    if [ -z "$IP" ]; then
        echo "⚠️  Not connected to WiFi (en0). Trying ethernet (en1)..."
        IP=$(ipconfig getifaddr en1)
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    IP=$(hostname -I | awk '{print $1}')
else
    echo "❌ Unsupported OS. Please find your IP manually."
    exit 1
fi

if [ -z "$IP" ]; then
    echo "❌ Could not detect IP address. Please check your network connection."
    exit 1
fi

echo "✅ Your local IP address: $IP"
echo ""
echo "📋 Setup Instructions:"
echo "===================="
echo ""
echo "1️⃣  Start your Laravel backend:"
echo "   cd /path/to/your/backend"
echo "   php artisan serve --host=0.0.0.0 --port=8000"
echo ""
echo "2️⃣  Run the Flutter app on your real device:"
echo "   flutter run --dart-define=API_BASE_URL=http://$IP:8000/api"
echo ""
echo "3️⃣  Or update your .env file with:"
echo "   API_BASE_URL=http://$IP:8000/api"
echo "   Then run: flutter clean && flutter run"
echo ""
echo "⚠️  Important:"
echo "   - Ensure your phone and computer are on the SAME WiFi network"
echo "   - Your firewall must allow connections on port 8000"
echo "   - Test by visiting http://$IP:8000 in your phone's browser"
echo ""
echo "🔥 Quick Test Command (copy this):"
echo "================================================"
echo "flutter run --dart-define=API_BASE_URL=http://$IP:8000/api"
echo "================================================"
