import mssql from "mssql";


const config = {
    user: "userroot",
    password: "password",
    server: "localhost",
    database: "dbnegocio",
    options: {
        trustServerCertificate: true
    }
};

export async function getConnection()
{
        try
        {
            return await mssql.connect(config);
        }catch(error){
            console.log("Error de conexión:");
            console.log(error);
        }
};

export{mssql};