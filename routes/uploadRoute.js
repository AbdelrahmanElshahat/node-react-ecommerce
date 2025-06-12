import express from 'express';
import multer from 'multer';
import multerS3 from 'multer-s3';
import aws from 'aws-sdk';
import config from '../config.js';

const router = express.Router();

// Configure AWS
aws.config.update({
  accessKeyId: config.accessKeyId,
  secretAccessKey: config.secretAccessKey,
  region: 'eu-north-1',
});

const s3 = new aws.S3();

// S3 storage configuration
const storageS3 = multerS3({
  s3,
  bucket: 'amazona',
  acl: 'public-read',
  contentType: multerS3.AUTO_CONTENT_TYPE,
  key(req, file, cb) {
    cb(null, `${Date.now().toString()}-${file.originalname}`);
  },
});

const uploadS3 = multer({ storage: storageS3 });

// S3 upload route
router.post('/s3', uploadS3.single('image'), (req, res) => {
  res.send(req.file.location);
});

export default router;