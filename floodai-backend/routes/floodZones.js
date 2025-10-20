const express = require('express');
const router = express.Router();

// Get all flood zones
router.get('/', async (req, res) => {
  try {
    const conn = await req.pool.getConnection();
    const [rows] = await conn.execute('SELECT * FROM flood_zones');
    conn.release();

    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get flood zones near user location (within radius)
router.get('/nearby', async (req, res) => {
  try {
    const { latitude, longitude, radius = 5 } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude and longitude required' });
    }

    const conn = await req.pool.getConnection();
    const [rows] = await conn.execute(
      `SELECT *, 
        (6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) 
        AS distance 
       FROM flood_zones 
       HAVING distance < ? 
       ORDER BY distance`,
      [latitude, longitude, latitude, radius]
    );
    conn.release();

    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get flood zone by ID
router.get('/:id', async (req, res) => {
  try {
    const conn = await req.pool.getConnection();
    const [rows] = await conn.execute('SELECT * FROM flood_zones WHERE id = ?', [req.params.id]);
    conn.release();

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Flood zone not found' });
    }

    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get flood risk prediction (mock for now)
router.post('/predict-risk', async (req, res) => {
  try {
    const { latitude, longitude } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude and longitude required' });
    }

    // Mock prediction - replace with real ML model later
    const riskScore = Math.random() * 100;
    let riskLevel = 'Low';
    if (riskScore > 66) riskLevel = 'High';
    else if (riskScore > 33) riskLevel = 'Moderate';

    res.json({
      latitude,
      longitude,
      riskLevel,
      riskScore: Math.round(riskScore),
      prediction: `${riskScore > 50 ? 'High' : 'Low'} flood risk in this area`,
      factors: ['Rainfall', 'River Level', 'Soil Moisture', 'Topography'],
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;