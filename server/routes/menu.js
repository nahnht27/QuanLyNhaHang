const express = require('express');
const router = express.Router();
const { getAllMenu, getAvailableMenu } = require('../controllers/menuController');

router.get('/', getAllMenu);
router.get('/available', getAvailableMenu);

module.exports = router;