// KEY CODE SNIPPETS FOR IMAGE DELETION FEATURE

// 1. UNIFIED IMAGE DELETION FUNCTION (productRoute.js)
const deleteImage = async (imageUrl) => {
  if (!imageUrl) return { success: false, message: 'No image URL provided' };

  // Try S3 first if it's an S3 URL
  if (imageUrl.includes('amazonaws.com') && isS3Configured) {
    const s3Result = await deleteImageFromS3(imageUrl);
    if (s3Result.success) {
      return s3Result;
    }
  }

  // Try local deletion if it's a local URL
  if (imageUrl.startsWith('/uploads/')) {
    return await deleteLocalImage(imageUrl);
  }

  console.log(`Image URL doesn't match any deletion pattern: ${imageUrl}`);
  return { success: false, message: 'Image URL format not recognized for deletion' };
};

// 2. PRODUCT DELETION WITH IMAGE CLEANUP (productRoute.js)
router.delete('/:id', isAuth, isAdmin, async (req, res) => {
  try {
    // First, find the product to get the image URL
    const productToDelete = await Product.findById(req.params.id);

    if (!productToDelete) {
      return res.status(404).send({ message: 'Product Not Found.' });
    }

    // Store image URL before deletion
    const imageUrl = productToDelete.image;

    // Delete the product from database first
    const deletedProduct = await Product.findByIdAndDelete(req.params.id);

    if (deletedProduct) {
      // Delete associated image from storage (S3 or local)
      if (imageUrl && !imageUrl.startsWith('/images/')) { // Don't delete default images
        const imageDeleteResult = await deleteImage(imageUrl);

        if (imageDeleteResult.success) {
          res.send({
            message: 'Product and associated image deleted successfully',
            imageResult: imageDeleteResult.message,
          });
        } else {
          res.send({
            message: 'Product deleted, but failed to delete image',
            imageError: imageDeleteResult.message,
          });
        }
      } else {
        res.send({ message: 'Product deleted (no custom image to remove)' });
      }
    }
  } catch (error) {
    console.error('Error in product deletion:', error);
    res.status(500).send({ message: 'Error in Deletion: ' + error.message });
  }
});

// 3. PRODUCT UPDATE WITH OLD IMAGE CLEANUP (productRoute.js)  
router.put('/:id', isAuth, isAdmin, async (req, res) => {
  const productId = req.params.id;
  const product = await Product.findById(productId);
  if (product) {
    // Store old image URL for potential deletion
    const oldImageUrl = product.image;
    const newImageUrl = req.body.image;

    // Update product fields
    product.name = req.body.name;
    product.price = req.body.price;
    product.image = req.body.image;
    // ... other fields ...

    const updatedProduct = await product.save();

    if (updatedProduct) {
      // Delete old image from storage if image was changed and not a default image
      if (oldImageUrl && newImageUrl && oldImageUrl !== newImageUrl && !oldImageUrl.startsWith('/images/')) {
        const deleteResult = await deleteImage(oldImageUrl);
        console.log('Old image deletion result:', deleteResult);
      }

      return res.status(200).send({ 
        message: 'Product Updated', 
        data: updatedProduct 
      });
    }
  }
  return res.status(500).send({ message: ' Error in Updating Product.' });
});

// 4. S3 IMAGE DELETION (productRoute.js)
const deleteImageFromS3 = async (imageUrl) => {
  if (!imageUrl || !isS3Configured) return { success: false, message: 'S3 not configured' };

  try {
    const s3Key = extractS3KeyFromUrl(imageUrl);

    if (!s3Key) {
      return { success: false, message: 'Unable to extract S3 key from URL' };
    }

    const command = new DeleteObjectCommand({
      Bucket: config.bucketName,
      Key: s3Key,
    });

    await s3Client.send(command);
    console.log(`Successfully deleted image from S3: ${s3Key}`);
    return { success: true, message: 'Image deleted from S3' };
  } catch (error) {
    console.error('Error deleting image from S3:', error);
    return { success: false, message: error.message };
  }
};

// 5. LOCAL FILE DELETION (productRoute.js)
const deleteLocalImage = async (imageUrl) => {
  if (!imageUrl) return { success: false, message: 'No image URL provided' };

  try {
    if (imageUrl.startsWith('/uploads/')) {
      const filePath = path.join(process.cwd(), imageUrl);
      
      if (fs.existsSync(filePath)) {
        await fs.promises.unlink(filePath);
        console.log(`Successfully deleted local image: ${filePath}`);
        return { success: true, message: 'Local image deleted successfully' };
      } else {
        return { success: false, message: 'Local image file not found' };
      }
    }
    
    return { success: false, message: 'Not a local image URL' };
  } catch (error) {
    console.error('Error deleting local image:', error);
    return { success: false, message: error.message };
  }
};
