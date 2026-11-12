"use strict";
const sql = require("mssql");
require("dotenv").config();
const config = {
    user: "userroot",
    password: "password",
    server: "localhost",
    database: "dbnegocio",
    options: {
        trustServerCertificate: true
    }
};

async function testConnexionDB()
{
        try
        {
            const pool = await sql.connect(config);
            console.log("¡Conexión exitosa!");
            await pool.close();
        }catch(err){
            console.log("Error de conexión:", err.message);
        }
}

//testConnexionDB();

async function ConnexionDBMostrar()
{
    try
    {
        const pool = await sql.connect(config);
        console.log("¡Conexión exitosa!");
        const resultado = await pool.request().query("SELECT nombre FROM localidad");

        console.log(resultado.recordset);       // array de objetos
        console.table(resultado.recordset);     // en formato tabla

        await pool.close();
    }
    catch(err){
            console.log("Error de conexión:", err.message);
    }
}
//ConnexionDBMostrar();
async function DBMostrarlocalidad()
{
    app.use(express.static("public"));

app.get("/localidades", async (req, res) => {
    try {
        const pool = await sql.connect(config);
        const resultado = await pool.request()
            .query("SELECT nombre FROM localidades ORDER BY nombre");
        res.json(resultado.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});
}
document.addEventListener("DOMContentLoaded", () => {
    const select = document.getElementById("inputFiltroLocalidad");
    select.addEventListener("change", FiltroLocalidad);
});