const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;


app.use(helmet());        
app.use(cors());       
app.use(morgan('dev'));   
app.use(express.json()); 


const menuData = [
    { id: 1, name: "Trà sữa Matcha Hermosa", price: 45000, category: "Drink" },
    { id: 2, name: "Cà phê Muối", price: 35000, category: "Drink" },
    { id: 3, name: "Bánh Croissant", price: 25000, category: "Food" },
    { id: 4, name: "Trà đào cam sả", price: 42000, category: "Drink" },
    { id: 5, name: "Cold brew cam", price: 48000, category: "Drink" },
    { id: 6, name: "Matcha latte yến mạch", price: 55000, category: "Drink" },
    { id: 7, name: "Sữa chua uống việt quất", price: 40000, category: "Drink" },
    { id: 8, name: "Bánh tart chanh", price: 45000, category: "Food" },
    { id: 9, name: "Bánh mousse dâu", price: 52000, category: "Food" },
    { id: 10, name: "Bánh Tiramisu", price: 55000, category: "Food" }
];

app.get('/api/v1/menu', (req, res) => {
    res.status(200).json({
        success: true,
        service: "Hermosa-Menu-Service",
        data: menuData
    });
});

app.get('/health', (req, res) => {
    res.status(200).json({ status: "UP", uptime: process.uptime() });
});

app.use((req, res) => {
    res.status(404).json({ message: "Endpoint không tồn tại!" });
});

app.listen(port, () => {
    console.log(`[Hermosa] Menu Service started on port ${port}`);
});