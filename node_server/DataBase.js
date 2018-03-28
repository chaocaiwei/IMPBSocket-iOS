/**
 * Created by jztech-weichaocai on 2018/3/27.
 */


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
        if (completion) {
            completion(error)
        }
    });
}

exports.userWithName = function (name,completion) {
    connection.query("SELECT * FROM users WHERE user_name = ? ",[name],function (err,rows) {
        if (completion){
            completion(rows,err);
        }
    })
}

exports.updateUser = function (user) {
    connection.query("UPDATE t_user set ? where user_id =?",[user,user.user_id],function (err,rows) {
        next();
    })
}

exports.connect = function () {
    connection.connect();
}