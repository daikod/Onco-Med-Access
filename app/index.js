const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');
const bcrypt = require('bcryptjs');

const app = express();
app.use(express.json());

app.set('view engine', 'ejs');
app.set('views', __dirname + '/views');
app.use(express.urlencoded({ extended: true })); // For parsing form data

const PORT = process.env.PORT || 3000;

// --- Database and Redis Configuration ---
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const redisClient = redis.createClient({
  url: process.env.REDIS_URL
});

redisClient.on('error', (err) => console.log('Redis Client Error', err));

(async () => {
  try {
    await redisClient.connect();
    console.log('Connected to Redis successfully.');
  } catch (err) {
    console.error('Could not connect to Redis:', err);
  }
})();


// --- Health Check Endpoint ---
app.get('/health', async (req, res) => {
  try {
    const dbStatus = await pool.query('SELECT NOW()');
    const redisStatus = await redisClient.ping();
    res.status(200).json({
      status: 'UP',
      database: 'Connected',
      redis: redisStatus === 'PONG' ? 'Connected' : 'Disconnected',
    });
  } catch (e) {
    res.status(503).json({
      status: 'DOWN',
      error: e.message,
    });
  }
});

// --- API Routes ---

// Simple home page
app.get('/', (req, res) => {
  res.send('<h1>Oncology Medicines Access Management System</h1><p>API is running.</p>');
});

// Get all medicines
app.get('/api/medicines', async (req, res, next) => {
    try {
        // Example: Try to get from cache first
        const cachedMedicines = await redisClient.get('medicines');
        if (cachedMedicines) {
            return res.json(JSON.parse(cachedMedicines));
        }

        // If not in cache, query the database
        const { rows } = await pool.query('SELECT * FROM medicines'); // Assumes a 'medicines' table
        
        // Cache the result for 1 hour (3600 seconds)
        await redisClient.set('medicines', JSON.stringify(rows), {
          EX: 3600,
        });

        res.json(rows);
    } catch (err) {
        next(err);
    }
});

// Get all patients
app.get('/api/patients', async (req, res, next) => {
    try {
        const { rows } = await pool.query('SELECT * FROM patients'); // Assumes a 'patients' table
        res.json(rows);
    } catch (err) {
        next(err);
    }
});

// Registration Form Route
app.get('/register', (req, res) => {
  res.render('register', { message: null });
});

// Handle Registration
app.post('/register', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.render('register', { message: 'Please enter both username and password.' });
  }

  try {
    // Check if user already exists
    const userExists = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
    if (userExists.rows.length > 0) {
      return res.render('register', { message: 'Username already exists. Please choose a different one.' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10); // 10 salt rounds

    // Save user to database
    await pool.query('INSERT INTO users (username, password) VALUES ($1, $2)', [username, hashedPassword]);

    res.send('Registration successful! You can now log in.'); // Or redirect to a login page
  } catch (err) {
    console.error('Registration error:', err);
    res.render('register', { message: 'An error occurred during registration. Please try again.' });
  }
});


// --- Error Handling Middleware ---
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});


// --- Server Startup ---
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log('Connected to database and Redis (pending successful connection).');
  console.log('To test, navigate to:');
  console.log(`  - http://localhost:${PORT}/health`);
  console.log(`  - http://localhost:${PORT}/api/medicines`);
  console.log(`  - http://localhost:${PORT}/api/patients`);
});