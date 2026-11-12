"use strict";
const sql = require("mssql");

const config = {
    user: "userroot",
    password: "password",
    server: "localhost",
    database: "dbnegocio",
    options: {
        trustServerCertificate: true
    }
};

async function getConnection()
{
        try
        {
            return await mssql.connect(config);
        }catch(error){
            console.log("Error de conexión:");
            console.log(error);
        }
}

const getLocalidad = async () => {
    try{
        const pool = await getConnection();
        const resultado = await pool.request().query("SELECT id_localidad, id_provincia, nombre FROM localidad");
        console.table(resultado.recordset);
        await pool.close();
    }catch(error){
        console.error(error);
    }
}
getLocalidad();