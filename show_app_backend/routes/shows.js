const express = require('express');
const { body, param, validationResult } = require('express-validator');
const multer = require('multer');
const path = require('path');
const db = require('../database');

const router = express.Router();

// Multer setup for file storage and naming
const storage = multer.diskStorage({
  destination: './uploads/', // Directory where images will be stored
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`); // Store with timestamp to avoid filename conflicts
  }
});

const upload = multer({
  storage,
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png/; // Accept only images
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());

    if (extname) {
      cb(null, true);
    } else {
      cb(new Error('Only images (JPG, PNG) are allowed!'));
    }
  }
});

// Validation middleware for show input
const validateShow = [
  body('title').notEmpty().withMessage('Title is required'),
  body('description').notEmpty().withMessage('Description is required'),
  body('category').isIn(['movie', 'anime', 'serie']).withMessage('Category must be movie, anime, or serie')
];

// POST route to create a new show
router.post('/', upload.single('image'), validateShow, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { title, description, category } = req.body;
    const image = req.file ? `/uploads/${req.file.filename}` : null; // Save the image path relative to the uploads folder

    // Insert the new show into the database
    const result = await db.runAsync(
      'INSERT INTO shows (title, description, category, image) VALUES (?, ?, ?, ?)',
      [title, description, category, image]
    );

    res.status(201).json({
      id: result.lastID,
      title,
      description,
      category,
      image
    });
  } catch (error) {
    console.error('Error creating show:', error);
    res.status(500).json({ message: 'Error creating show' });
  }
});

// GET route to retrieve all shows
router.get('/', async (req, res) => {
  try {
    const shows = await db.allAsync('SELECT * FROM shows ORDER BY title');
    res.json(shows);
  } catch (error) {
    console.error('Error fetching shows:', error);
    res.status(500).json({ message: 'Error fetching shows' });
  }
});

// GET route to retrieve shows by category
router.get('/category/:category', async (req, res) => {
  try {
    const { category } = req.params;
    const shows = await db.allAsync('SELECT * FROM shows WHERE category = ? ORDER BY title', [category]);
    res.json(shows);
  } catch (error) {
    console.error('Error fetching shows by category:', error);
    res.status(500).json({ message: 'Error fetching shows by category' });
  }
});

// GET route to retrieve a specific show by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const show = await db.getAsync('SELECT * FROM shows WHERE id = ?', [id]);
    if (!show) {
      return res.status(404).json({ message: 'Show not found' });
    }
    res.json(show);
  } catch (error) {
    console.error('Error fetching show:', error);
    res.status(500).json({ message: 'Error fetching show' });
  }
});

// PUT route to update an existing show
router.put('/:id', upload.single('image'), validateShow, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { title, description, category } = req.body;
    const image = req.file ? `uploads/${req.file.filename}` : null; // Store the image path correctly
    const id = req.params.id;

    // Update the show in the database
    const result = await db.runAsync(
      'UPDATE shows SET title = ?, description = ?, category = ?, image = COALESCE(?, image) WHERE id = ?',
      [title, description, category, image, id]
    );

    if (result.changes === 0) {
      return res.status(404).json({ message: 'Show not found' });
    }

    res.json({ id, title, description, category, image });
  } catch (error) {
    console.error('Error updating show:', error);
    res.status(500).json({ message: 'Error updating show' });
  }
});

// DELETE route to remove a show
router.delete('/:id', [
  param('id').isInt().withMessage('ID must be an integer')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const result = await db.runAsync('DELETE FROM shows WHERE id = ?', [req.params.id]);
    
    if (result.changes === 0) {
      return res.status(404).json({ message: 'Show not found' });
    }

    res.json({ message: 'Show deleted successfully' });
  } catch (error) {
    console.error('Error deleting show:', error);
    res.status(500).json({ message: 'Error deleting show' });
  }
});

module.exports = router;
