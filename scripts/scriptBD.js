import { getConnection, mssql } from "./SQLconnect.js";

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