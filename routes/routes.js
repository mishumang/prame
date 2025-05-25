// routes/userRoutes.js
const { sendOTP, verifyOTP, registerWithPhone } = require("../controllers/authContoller");
const { updateProgress, getProgress } = require("../controllers/progressController");
const { 
  register, 
  login, 
  getProfile, 
  googleSignIn,
  updateProfile,
  uploadProfileImage
} = require("../controllers/user.contoller");

const router = require("express").Router();

const multer = require("multer");
const path = require("path");

// Configure multer storage for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, req.params.userId + "-" + Date.now() + ext);
  }
});
const upload = multer({ storage: storage });

router
  .post("/register", register)
  .post("/login", login)
  .post("/google-signin", googleSignIn)
  .get("/profile/:userId", getProfile)
  .post("/update/:userId", updateProfile)
  .post("/upload/:userId", upload.single("image"), uploadProfileImage)
  .post("/updateProgress", updateProgress)
  .get("/progress/:uid", getProgress)
  .post("/send-otp", sendOTP)
  .post("/verify-otp", verifyOTP)
  .post("/registerPhone", registerWithPhone);

module.exports = router;
