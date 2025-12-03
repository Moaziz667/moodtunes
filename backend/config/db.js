const mongoose = require('mongoose');
const connection = mongoose.createConnection( process.env.MONGODB_URI || 'mongodb://mongo:27017/TaskToDo').on('open' ,()=>{
    console.log("MongoDb Connected");
}).on('error',()=>{
    console.log("MongoDb Connection Error");
});
module.exports = connection;