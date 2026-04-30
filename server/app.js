const express = require('express');
const path = require('path');
const app = express();

app.use(express.json());
app.use(express.static(path.join(__dirname, '../client')));

app.use('/api/menu',    require('./routes/menu'));
app.use('/api/table',   require('./routes/table'));
app.use('/api/invoice', require('./routes/invoice'));
app.use('/api/staff',   require('./routes/staff'));

app.listen(3000, () => {
    console.log('Server đang chạy tại http://localhost:3000');
});