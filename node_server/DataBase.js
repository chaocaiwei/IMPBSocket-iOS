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
    connection.query('INSERT INTO `users` (`user_name`, `pwd`, `token`, `socket_id`) VALUES (' +  username + pwd + token  + ');', function (error, results, fields) {
        if (error) throw error;
        console.log('The solution is: ', results[0].solution);
    });
}

exports.insertLoginInfo = function (username,pwd,token) {
    connection.query('INSERT INTO `users` (`user_name`, `pwd`, `token`, `socket_id`) VALUES (' +  username + pwd + token  + ');', function (error, results, fields) {
        if (error) throw error;
        console.log('The solution is: ', results[0].solution);
    });
}

exports.connect = function () {
    connection.connect();
}

