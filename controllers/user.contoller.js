const User = require('../models/User');

exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;
    
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "User already registered." });
    }
    
    const userID = Date.now();
    
    const newUser = new User({
      userName: name,
      email,
      pwd: password,
      userID
    });
    await newUser.save();
    
    return res.status(201).json({ message: "Registration successful." });
  } catch (error) {
    return res.status(500).json({ message: "Server error during registration." });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User not found." });
    }
    
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials." });
    }

    return res.status(200).json({ message: "Login successful.", userId: user.userID.toString() });
  } catch (error) {
    return res.status(500).json({ message: "Server error during login." });
  }
};

exports.getProfile = async (req, res) => {
  try {
    const userId = Number(req.params.userId);
    
    const user = await User.findOne({ userID: userId });
    
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    return res.status(200).json({
      userID: user.userID,
      name: user.userName,
      email: user.email,
      createdAt: user.createdAt
    });
  } catch (error) {
    return res.status(500).json({ message: 'Server error while fetching user profile.' });
  }
};

exports.logout = async (req, res) => {
  req.session.destroy(err => {
    if (err) {
      return res.status(500).json({ message: "Logout failed." });
    }
    res.clearCookie("connect.sid");
    res.status(200).json({ message: "Logout successful." });
  });
};


const { OAuth2Client } = require('google-auth-library');

const GOOGLE_CLIENT_ID = 'YOUR_GOOGLE_CLIENT_ID';
const client = new OAuth2Client(GOOGLE_CLIENT_ID);

exports.googleSignIn = async (req, res) => {
  const { idToken, accessToken } = req.body;

  if (!idToken || !accessToken) {
    return res.status(400).json({ error: 'Missing idToken or accessToken' });
  }

  try {
    const ticket = await client.verifyIdToken({
      idToken: idToken,
      audience: GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    const email = payload.email;
    const userName = payload.name;

    let user = await User.findOne({ email });
    if (!user) {
      const count = await User.countDocuments();
      user = new User({
        userName,
        email,
        pwd: '',
        userID: count + 1,
      });
      await user.save();
    }

    return res.status(200).json({ message: 'User signed in successfully', user });
  } catch (error) {
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const userId = Number(req.params.userId);
    const { name, email, phone } = req.body;
    
    const updateData = {};
    if (name !== undefined) updateData.userName = name;
    if (email !== undefined) updateData.email = email;
    if (phone !== undefined) updateData.phone = phone;
    // if (profileImageUrl !== undefined) updateData.profileImageUrl = profileImageUrl;
    
    const user = await User.findOneAndUpdate({ userID: userId }, updateData, { new: true });
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }
    
    return res.status(200).json({
      userID: user.userID,
      name: user.userName,
      email: user.email,
      phone: user.phone,
      // profileImageUrl: user.profileImageUrl,
      createdAt: user.createdAt
    });
  } catch (error) {
    return res.status(500).json({ message: 'Server error while updating user profile.' });
  }
};

exports.uploadProfileImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded.' });
    }
    // Construct the image URL; adjust as needed for your deployment.
    const imageUrl = req.protocol + '://' + req.get('host') + '/uploads/' + req.file.filename;
    return res.status(200).json({ imageUrl });
  } catch (error) {
    return res.status(500).json({ message: 'Server error while uploading profile image.' });
  }
};