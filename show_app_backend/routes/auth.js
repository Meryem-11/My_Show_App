const express = require('express');
const router = express.Router();
const db = require('../database');

// Route pour la connexion
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log('Login attempt for email:', email);

    // Vérifier si l'utilisateur existe et si le mot de passe correspond
    const user = await db.getAsync('SELECT * FROM users WHERE email = ? AND password = ?', [email, password]);
    console.log('User found:', user ? 'Yes' : 'No');

    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Return a token in the response
    res.json({ 
      message: 'Login successful',
      token: 'dummy-token-' + user.id // Simple token for now
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Error during login', error: error.message });
  }
});

module.exports = router; 