const app = require('./app');
const db = require('./config/db')
//const UserModel = require('./model/user.model')
const port = 3000;

app.get('/',(req,res)=>{
    res.send("hey aziz, how are you?")
});

app.listen(port, () => {
    console.log(`Server Listening on Port http://0.0.0.0:${port}`);
});
