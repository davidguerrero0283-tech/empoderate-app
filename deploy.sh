#!/bin/bash
set -e

echo "🚀 Deploying Empodérate to Firebase..."
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    echo "   Please copy .env.example to .env and configure"
    exit 1
fi

# Load environment variables
source .env

# Determine environment
ENV=${1:-prod}
echo "📝 Environment: $ENV"

# Build Flutter Web
echo "📦 Building Flutter Web..."
flutter build web --release \
    --dart-define=ENV=$ENV \
    --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY_PROD \
    --dart-define=SENTRY_DSN=$SENTRY_DSN

# Build Cloud Functions
echo "⚡ Building Cloud Functions..."
cd functions
npm install
npm run build
cd ..

# Deploy Firestore Rules
echo "🔒 Deploying Firestore Rules..."
firebase deploy --only firestore:rules

# Deploy Cloud Functions
echo "☁️  Deploying Cloud Functions..."
firebase deploy --only functions

# Deploy Hosting
echo "🌐 Deploying Hosting..."
firebase deploy --only hosting

echo ""
echo "✅ Deployment complete!"
echo ""
echo "URLs:"
echo "  App: https://app.empoderate.com"
echo "  Functions: https://us-central1-empoderate-prod.cloudfunctions.net/api"
echo ""
