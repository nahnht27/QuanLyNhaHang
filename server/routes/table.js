const express = require('express');
const router = express.Router();
const { getAllTables, getEmptyTables } = require('../controllers/tableController');

router.get('/', getAllTables);
router.get('/empty', getEmptyTables);

module.exports = router;