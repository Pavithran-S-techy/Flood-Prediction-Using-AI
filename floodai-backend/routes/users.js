const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { pool } = require('../server');

// Register
router.post('/register', async (req, res) => {
  try {
    const { email, password, name, phone } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password required' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const conn = await pool.getConnection();
    await conn.execute(
      'INSERT INTO users (email, password, name, phone) VALUES (?, ?, ?, ?)',
      [email, hashedPassword, name, phone]
    );
    conn.release();

    res.json({ message: 'User registered successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password required' });
    }

    const conn = await pool.getConnection();
    const [rows] = await conn.execute('SELECT * FROM users WHERE email = ?', [email]);
    conn.release();

    if (rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = rows[0];
    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET || 'secret', {
      expiresIn: '7d',
    });

    res.json({
      token,
      user: { id: user.id, email: user.email, name: user.name, phone: user.phone },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update location
router.post('/update-location', async (req, res) => {
  try {
    const { userId, latitude, longitude } = req.body;

    if (!userId || latitude === undefined || longitude === undefined) {
      return res.status(400).json({ error: 'userId, latitude, and longitude required' });
    }

    const conn = await pool.getConnection();
    await conn.execute('UPDATE users SET latitude = ?, longitude = ? WHERE id = ?', [
      latitude,
      longitude,
      userId,
    ]);
    conn.release();

    res.json({ message: 'Location updated' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user profile
router.get('/:id', async (req, res) => {
  try {
    const conn = await pool.getConnection();
    const [rows] = await conn.execute('SELECT id, email, name, phone, latitude, longitude FROM users WHERE id = ?', [
      req.params.id,
    ]);
    conn.release();

    if (rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;