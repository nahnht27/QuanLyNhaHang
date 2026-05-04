const express = require('express');
const path = require('path');
const app = express();

app.use((req, res, next) => {
  const allowed = [
    'http://127.0.0.1:5500',
    'http://localhost:5500',
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://localhost:3001',
    'http://127.0.0.1:3001'
  ];
  const origin  = req.headers.origin;
  if (allowed.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  }
  if (req.method === 'OPTIONS') return res.sendStatus(204);
  next();
});

app.use(express.json());
app.use(express.static(path.join(__dirname, '../client')));

app.use('/api/menu',    require('./routes/menu'));
app.use('/api/table',   require('./routes/table'));
app.use('/api/invoice', require('./routes/invoice'));
app.use('/api/staff',       require('./routes/staff'));
app.use('/api/reservation', require('./routes/reservation'));

const PORT = Number(process.env.PORT || 3001);
app.listen(PORT, () => {
    console.log(`Server đang chạy tại http://localhost:${PORT}`);
});