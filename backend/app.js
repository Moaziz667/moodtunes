const express = require('express');
const bodyParser = require('body-parser'); // Updated to use camelCase for consistency
const cors = require('cors'); // Import the CORS package
const UserRouter = require('./router/user.router'); // Import your user routes
const TaskRouter = require('./router/task.router');
const app = express(); 




// CORS middleware setup
const corsOptions = {
  origin: '*', // Allow all origins; adjust this for production
  optionsSuccessStatus: 200 // For legacy browser support
};

app.use(cors(corsOptions)); // Use the CORS middleware

app.use(bodyParser.json()); // Use body-parser middleware for JSON requests
app.use('/', UserRouter); // Use your user routes
app.use("/",TaskRouter);


module.exports = app; // Export the app for use in your server file
