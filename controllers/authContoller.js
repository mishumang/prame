const OTP = require('../models/otpModel');
const User = require('../models/User');
const sendSms = require('../utils/smsService');

function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

exports.sendOTP = async (req, res) => {
  try {
    const { phone } = req.body;
    if (!phone) return res.status(400).json({ error: 'Phone number is required' });

    const otpCode = generateOTP();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); 

    // Save (or update) the OTP record
    await OTP.findOneAndUpdate(
      { phone },
      { otp: otpCode, expiresAt },
      { upsert: true, new: true }
    );

    // Send the OTP via SMS
    await sendSms(phone, `Your OTP code is: ${otpCode}`);
    res.json({ success: true, message: 'OTP sent successfully' });
  } catch (error) {
    console.error('Error in sendOTP:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.verifyOTP = async (req, res) => {
  try {
    const { phone, otp } = req.body;
    if (!phone || !otp)
      return res.status(400).json({ error: 'Phone and OTP are required' });

    const record = await OTP.findOne({ phone });
    if (!record) {
      return res.status(400).json({ success: false, message: 'OTP not found' });
    }

    if (record.expiresAt < new Date()) {
      return res.status(400).json({ success: false, message: 'OTP has expired' });
    }

    if (record.otp !== otp) {
      return res.status(400).json({ success: false, message: 'Incorrect OTP' });
    }

    // Optionally, delete the OTP after verification
    await OTP.deleteOne({ phone });

    res.json({ success: true, message: 'OTP verified' });
  } catch (error) {
    console.error('Error in verifyOTP:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.registerWithPhone = async (req, res) => {
    try {
      const { phone, name, password } = req.body;
      if (!phone || !name || !password) {
        return res.status(400).json({ error: 'Phone, name, and password are required' });
      }
  
      // Optionally, check if a user with the phone already exists
      const existingUser = await User.findOne({ phone });
      if (existingUser) {
        return res.status(400).json({ error: 'User already registered with this phone number.' });
      }
  
      // Generate a unique userID (using timestamp as a simple example)
      const userID = Date.now();
  
      // Create and save new user
      const newUser = new User({
        userName: name,
        phone,
        pwd: password,
        userID
      });
      await newUser.save();
  
      res.json({ success: true, message: 'User registered successfully' });
    } catch (error) {
      console.error('Error in registerWithPhone:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  };
  