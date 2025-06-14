#!/bin/bash

# ========================================================
# populate-products.sh
# ========================================================
# This script adds sample products to the MongoDB database
# in your Kubernetes deployment.
#
# Use this script when:
# 1. First deploying the application
# 2. After resetting the database
# 3. If products are missing in the UI
#
# Maintainer: DevOps Team
# Last Updated: June 13, 2025
# ========================================================

echo "🔍 Setting up direct access to add products to MongoDB..."

# Get a backend pod name
BACKEND_POD=$(kubectl get pods -n ecommerce -l app=backend -o jsonpath='{.items[0].metadata.name}')

if [ -z "$BACKEND_POD" ]; then
    echo "❌ No backend pods found!"
    exit 1
fi

echo "✅ Using backend pod: $BACKEND_POD"

# Create a data.js file with sample products
cat <<EOF > temp-products.js
const mongoose = require('mongoose');

// Define product schema
const reviewSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    rating: { type: Number, default: 0 },
    comment: { type: String, required: true },
  },
  {
    timestamps: true,
  }
);

const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  image: { type: String, required: true },
  brand: { type: String, required: true },
  price: { type: Number, default: 0, required: true },
  category: { type: String, required: true },
  countInStock: { type: Number, default: 0, required: true },
  description: { type: String, required: true },
  rating: { type: Number, default: 0, required: true },
  numReviews: { type: Number, default: 0, required: true },
  reviews: [reviewSchema],
});

const Product = mongoose.model('Product', productSchema);

// Sample products
const sampleProducts = [
  {
    name: 'Nike Slim Shirt',
    image: '/images/p1.jpg',
    brand: 'Nike',
    price: 120,
    category: 'Shirts',
    countInStock: 10,
    description: 'High quality product',
    rating: 4.5,
    numReviews: 10,
  },
  {
    name: 'Adidas Fit Shirt',
    image: '/images/p2.jpg',
    brand: 'Adidas',
    price: 100,
    category: 'Shirts',
    countInStock: 20,
    description: 'High quality product',
    rating: 4.0,
    numReviews: 10,
  },
  {
    name: 'Lacoste Free Shirt',
    image: '/images/p3.jpg',
    brand: 'Lacoste',
    price: 220,
    category: 'Shirts',
    countInStock: 0,
    description: 'High quality product',
    rating: 4.8,
    numReviews: 17,
  },
  {
    name: 'Nike Slim Pant',
    image: '/images/d1.jpg',
    brand: 'Nike',
    price: 78,
    category: 'Pants',
    countInStock: 15,
    description: 'High quality product',
    rating: 4.5,
    numReviews: 14,
  },
  {
    name: 'Puma Slim Pant',
    image: '/images/d2.jpg',
    brand: 'Puma',
    price: 65,
    category: 'Pants',
    countInStock: 5,
    description: 'High quality product',
    rating: 4.5,
    numReviews: 10,
  },
  {
    name: 'Adidas Fit Pant',
    image: '/images/d3.jpg',
    brand: 'Adidas',
    price: 139,
    category: 'Pants',
    countInStock: 12,
    description: 'High quality product',
    rating: 4.5,
    numReviews: 15,
  },
];

// Connect to MongoDB and seed data
async function seedProducts() {
  try {
    // Connect to MongoDB
    await mongoose.connect('mongodb://admin:password@mongodb-service:27017/amazona?authSource=admin', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log('Connected to MongoDB');
    
    // Clear existing products
    await Product.deleteMany({});
    console.log('Products cleared');
    
    // Insert sample products
    const createdProducts = await Product.insertMany(sampleProducts);
    console.log('Products added:', createdProducts.length);
    
    console.log('Data import completed successfully');
    mongoose.disconnect();
  } catch (error) {
    console.error('Error seeding products:', error.message);
  }
}

seedProducts();
EOF

# Copy the script to the pod
echo "📦 Copying products script to pod..."
kubectl cp temp-products.js ecommerce/$BACKEND_POD:/app/temp-products.js

# Execute the script in the pod
echo "🚀 Running script to populate products..."
kubectl exec -n ecommerce $BACKEND_POD -- node /app/temp-products.js

# Clean up
rm temp-products.js

# Get access information
NODE_IP=$(kubectl get nodes -o wide | grep -v NAME | awk '{print $7}' | head -1)
INGRESS_HOST=$(kubectl get ingress -n ecommerce ecommerce-ingress -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
INGRESS_IP=$(kubectl get ingress -n ecommerce ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)

echo "✅ Product population process completed."
echo ""
echo "📱 Access your application with products:"
echo ""
echo "1. Backend API (NodePort):"
echo "   http://$NODE_IP:30500/api/products"
echo ""
echo "2. Frontend application (when ingress is configured):"
echo "   http://$INGRESS_IP"
echo "   https://$INGRESS_HOST (with DNS configured)"
echo ""
echo "To update or add more products, edit this script and run it again."
