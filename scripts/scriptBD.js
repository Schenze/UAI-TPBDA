import {getConnection,mssql} from "./SQLconnect.js";

const getTableFrom = async (localidad) => {
    try{
        const pool = await getConnection();
        const resultado = await pool.request().query(`SELECT * FROM ${localidad}`);
        //console.table(resultado.recordset);
        resultado.recordset.forEach(fila => {// loop for
        console.log(fila.nombre);
        });
        await pool.close();
    }catch(error){
        console.error(error);
    }

}
getTableFrom();