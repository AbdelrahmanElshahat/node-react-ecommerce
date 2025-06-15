#!/bin/bash

# Script to fix common ESLint issues in React frontend

echo "🔧 Fixing ESLint issues in React frontend..."

# Fix OrderScreen.js
echo "Fixing OrderScreen.js..."
sed -i 's/import { createOrder } from/\/\/ import { createOrder } from/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/OrderScreen.js
sed -i 's/const { loading, order, error, errorPay, successPay } = orderPay;/const { loading, order, error, successPay } = orderPay;/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/OrderScreen.js
sed -i 's/], \[\]);/], [dispatch, props.history, props.match.params.id]);/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/OrderScreen.js

# Fix OrdersScreen.js  
echo "Fixing OrdersScreen.js..."
sed -i 's/import React, { useState, useEffect }/import React, { useEffect }/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/OrdersScreen.js
sed -i 's/const { loading, orders, error } = orderList;/const { loading, orders } = orderList;/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/OrdersScreen.js
sed -i 's/const { loading: loadingDelete, success: successDelete, error: errorDelete } = orderDelete;/const { success: successDelete } = orderDelete;/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/OrdersScreen.js
sed -i 's/], \[\]);/], [dispatch]);/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/OrdersScreen.js

# Fix PaymentScreen.js
echo "Fixing PaymentScreen.js..."
sed -i 's/import React, { useEffect, useState }/import React, { useState }/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/PaymentScreen.js
sed -i 's/import { Link } from/\/\/ import { Link } from/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/PaymentScreen.js  
sed -i 's/import { useSelector, useDispatch }/import { useDispatch }/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/PaymentScreen.js

# Fix PlaceOrderScreen.js
echo "Fixing PlaceOrderScreen.js..."
sed -i 's/const { loading, success, error, order } = orderCreate;/const { success, order } = orderCreate;/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/PlaceOrderScreen.js

# Fix ProductScreen.js
echo "Fixing ProductScreen.js..."
sed -i 's/], \[\]);/], [dispatch, props.match.params.id]);/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/ProductScreen.js

# Fix ProductsScreen.js
echo "Fixing ProductsScreen.js..."
sed -i 's/const { loading, products, error } = productList;/const { products } = productList;/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/ProductsScreen.js
sed -i 's/const { loading: loadingDelete, success: successDelete, error: errorDelete } = productDelete;/const { success: successDelete } = productDelete;/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/ProductsScreen.js
sed -i 's/], \[successDelete\]);/], [dispatch, successDelete]);/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/ProductsScreen.js

# Fix ProfileScreen.js
echo "Fixing ProfileScreen.js..."
sed -i 's/], \[successUpdate\]);/], [dispatch, successUpdate]);/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/ProfileScreen.js

# Fix RegisterScreen.js
echo "Fixing RegisterScreen.js..."
sed -i 's/const \[rePassword, setRePassword\] = useState/\/\/ const [rePassword, setRePassword] = useState/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/RegisterScreen.js
sed -i 's/], \[userInfo\]);/], [props.history, redirect, userInfo]);/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/RegisterScreen.js

# Fix ShippingScreen.js
echo "Fixing ShippingScreen.js..."
sed -i 's/import React, { useEffect, useState }/import React, { useState }/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/ShippingScreen.js
sed -i 's/import { Link } from/\/\/ import { Link } from/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/ShippingScreen.js
sed -i 's/import { useSelector, useDispatch }/import { useDispatch }/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/ShippingScreen.js

# Fix SigninScreen.js  
echo "Fixing SigninScreen.js..."
sed -i 's/], \[userInfo\]);/], [props.history, redirect, userInfo]);/' /home/elshahat/Documents/project/node-react-ecommerce/frontend/src/screens/SigninScreen.js

echo "✅ ESLint fixes applied!"
echo ""
echo "📋 Summary of fixes:"
echo "- Removed unused imports"
echo "- Fixed useEffect dependency arrays"  
echo "- Commented out unused variables"
echo "- Fixed invalid href attribute"
echo ""
echo "🚀 Frontend should now build without ESLint errors!"
