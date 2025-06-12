import express from 'express';
import multer from 'multer';
import multerS3 from 'multer-s3';
import aws from 'aws-sdk';
import config from '../config.js';
import { isAuth } from '../util.js';

const router = express.Router();

// Validate AWS configuration
if (!config.accessKeyId || !config.secretAccessKey || !config.bucketName) {
  console.error('AWS configuration is missing. Please check your environment variables.');
}

// Configure AWS
aws.config.update({
  accessKeyId: config.accessKeyId,
  secretAccessKey: config.secretAccessKey,
  region: config.region
});

// Create S3 instance
const s3 = new aws.S3();

// Test S3 connection
const testS3Connection = async () => {
  try {
    await s3.headBucket({ Bucket: config.bucketName }).promise();
    console.log('✅ S3 bucket connection successful');
  } catch (error) {
    console.error('❌ S3 bucket connection failed:', error.message);
  }
};

testS3Connection();

// Configure multer-s3 storage
const storageS3 = multerS3({
  s3: s3,
  bucket: config.bucketName,
  acl: 'public-read',
  contentType: multerS3.AUTO_CONTENT_TYPE,
  key: function (req, file, cb) {
    const fileName = `products/${Date.now()}-${file.originalname}`;
    cb(null, fileName);
  }
});

// Set up multer with S3 storage
const uploadS3 = multer({ 
  storage: storageS3,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});

// Local storage (fallback)
const storage = multer.diskStorage({
  destination(req, file, cb) {
    cb(null, 'uploads/');
  },
  filename(req, file, cb) {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ 
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});

// Routes
router.post('/', isAuth, (req, res) => {
  upload.single('image')(req, res, (err) => {
    if (err) {
      return res.status(400).json({ 
        message: 'Upload failed', 
        error: err.message 
      });
    }
    
    if (!req.file) {
      return res.status(400).json({ 
        message: 'No file uploaded' 
      });
    }
    
    res.json({ 
      message: 'Image uploaded successfully',
      image: `/${req.file.path}` 
    });
  });
});

router.post('/s3', isAuth, (req, res) => {
  // Check if AWS is properly configured
  if (!config.accessKeyId || !config.secretAccessKey || !config.bucketName) {
    return res.status(500).json({
      message: 'AWS S3 is not properly configured'
    });
  }

  uploadS3.single('image')(req, res, (err) => {
    if (err) {
      console.error('S3 Upload Error:', err);
      return res.status(400).json({ 
        message: 'S3 upload failed', 
        error: err.message 
      });
    }
    
    if (!req.file) {
      return res.status(400).json({ 
        message: 'No file uploaded' 
      });
    }
    
    res.json({
      message: 'Image uploaded successfully to S3',
      image: req.file.location
    });
  });
});

export default router;