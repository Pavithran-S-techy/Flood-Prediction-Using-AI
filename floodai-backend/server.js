const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const mysql = require('mysql2/promise');

dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// MySQL Connection Pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'floodai',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// Test Database Connection
pool.getConnection().then((conn) => {
  console.log('✅ Database connected');
  conn.release();
}).catch((err) => {
  console.error('❌ Database connection failed:', err.message);
});

// Make pool available to routes
app.use((req, res, next) => {
  req.pool = pool;
  next();
});

// Routes
app.use('/api/users', require('./routes/users'));
app.use('/api/flood-zones', require('./routes/floodZones'));
app.use('/api/shelters', require('./routes/shelters'));
app.use('/api/weather', require('./routes/weather'));

// Health Check
app.get('/health', (req, res) => {
  res.json({ status: 'FloodAi Backend is running' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 FloodAi Backend running on http://localhost:${PORT}`);
});