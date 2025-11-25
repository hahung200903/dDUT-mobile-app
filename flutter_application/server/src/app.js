import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import studentRouter from './routes/student.route.js';

const app = express();
const port = Number(process.env.PORT || 8080);

// Middleware
app.use(cors({ origin: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// Log request
app.use((req, res, next) => {
    console.log(new Date().toISOString(), `[${req.method}] ${req.url}`);
    next();
});

// Routes
app.get('/health', (req, res) => res.json({ ok: true }));
app.use('/api', studentRouter);

// Start server
app.listen(port, () => {
    console.log(`Server started at http://localhost:${port}`);
});