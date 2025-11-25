import express from 'express';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import * as studentController from '../controllers/student.controller.js';

const router = express.Router();

router.get('/results', authMiddleware, studentController.getResults);
router.get('/stats', authMiddleware, studentController.getStats);

export default router;