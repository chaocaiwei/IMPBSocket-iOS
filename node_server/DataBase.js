/**
 * Created by jztech-weichaocai on 2018/3/27.
 */

var logger     = require("./log").logger("DataBase")
var mysql      = require('mysql');
var connection = mysql.createConnection({
    host     : 'localhost',
    user     : 'root',
    password : '298136',
    database : 'defult'
});

exports.latestUserId = function (handle) {
    connection.query('SELECT * FROM `users` WHERE user_id = (SELECT MAX(user_id) FROM `users`);', function (error, results, fields) {
        if (error) print(error);
        console.log('The solution is: ', results[0].solution);
        var id = results[0].user_id;
        handle(id);
        logger.error(err)
    });
}

exports.insertLoginInfo = function (username,pwd,token,completion) {
    // (`user_name`, `pwd`, `token`)

    var user = {
        "user_name" :username,
        "pwd":pwd,
        "token" : token
    }

    connection.query('INSERT INTO users set ?  ',user, function (error, results, fields) {
        logger.error(err)
        if (completion) {
            completion(error)
        }
    });
}


exports.userById   = function (uid,completion) {
    connection.query("SELECT * FROM users WHERE user_id =?",[uid],function (err,rows) {
        logger.error(err)
        completion(rows,err);
    })
}

exports.userWithName = function (name,completion) {
    connection.query("SELECT * FROM users WHERE user_name = ? ",[name],function (err,rows) {
        logger.error(err)
        if (completion){
            completion(rows,err);
        }
    })
}

exports.updateUser = function (user) {
    connection.query("UPDATE users set ? where user_id =?",[user,user.user_id],function (err,rows) {
        if(err){
            logger.error(err)
        }
    })
}

exports.connect = function () {
    connection.connect();
}