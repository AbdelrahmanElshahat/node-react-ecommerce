#!/bin/bash

echo "🔧 Methods to disable ESLint warnings as errors in React builds"
echo "================================================================="

echo ""
echo "✅ Method 1: Environment Variable (Already Applied in Jenkinsfile)"
echo "Set CI=false in Jenkins pipeline environment"
echo ""

echo "✅ Method 2: Create .env file in frontend directory"
echo "Creating .env file to disable CI mode locally..."

cat > /home/elshahat/Documents/project/node-react-ecommerce/frontend/.env << 'EOF'
# Disable treating warnings as errors in CI
CI=false
GENERATE_SOURCEMAP=false
EOF

echo "Created frontend/.env with CI=false"
echo ""

echo "✅ Method 3: Modify package.json build script"
echo "Current build script in package.json:"
grep -A 1 '"build":' /home/elshahat/Documents/project/node-react-ecommerce/frontend/package.json || echo "Build script not found"

echo ""
echo "Alternative build script (if needed):"
echo '"build": "CI=false react-scripts build",'
echo ""

echo "✅ Method 4: ESLint Configuration"
echo "You can also create .eslintrc.json to modify ESLint behavior:"

cat > /home/elshahat/Documents/project/node-react-ecommerce/frontend/.eslintrc.json << 'EOF'
{
  "extends": "react-app",
  "rules": {
    "no-unused-vars": "warn",
    "react-hooks/exhaustive-deps": "warn",
    "jsx-a11y/anchor-is-valid": "warn"
  }
}
EOF

echo "Created frontend/.eslintrc.json with warnings instead of errors"
echo ""

echo "📋 Summary of Changes Applied:"
echo "1. ✅ Added CI=false to Jenkins pipeline globally"
echo "2. ✅ Added CI=false to specific frontend build stages"
echo "3. ✅ Created frontend/.env with CI=false"
echo "4. ✅ Created frontend/.eslintrc.json with warning rules"
echo ""
echo "🚀 Your Jenkins pipeline should now build without treating warnings as errors!"
echo ""
echo "💡 Note: The changes to Jenkinsfile are the most important ones."
echo "   The .env file provides local backup and .eslintrc.json fine-tunes ESLint behavior."
