"use strict";
let mysql = require("mysql");
let conexion = mysql.createConnection({
    host:"localhost",
    database: "(temp)",// que base de datos
    user: "root", // usuario
    password: "" // contraseña
})