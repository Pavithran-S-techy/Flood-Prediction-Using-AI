const express = require('express');
const router = express.Router();

// Use the pool already attached to req
router.get('/', async (req, res) => {
  try {
    const conn = await req.pool.getConnection();
    const [rows] = await conn.execute('SELECT * FROM shelters');
    conn.release();
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/nearby', async (req, res) => {
  try {
    const { latitude, longitude, radius = 10 } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude and longitude required' });
    }

    const conn = await req.pool.getConnection();
    const [rows] = await conn.execute(
      `SELECT *, 
        (6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) 
        AS distance 
       FROM shelters 
       HAVING distance < ? 
       ORDER BY distance 
       LIMIT 10`,
      [latitude, longitude, latitude, radius]
    );
    conn.release();

    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const conn = await req.pool.getConnection();
    const [rows] = await conn.execute('SELECT * FROM shelters WHERE id = ?', [req.params.id]);
    conn.release();

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Shelter not found' });
    }

    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
