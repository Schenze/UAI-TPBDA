import {getConnection,mssql} from "./scripts/SQLconnect.js";
import express from "express";
const funcExpress = express();
funcExpress.use(express.static("."));

funcExpress.get("/stock", async (req, res) => {
    try {
        const pool = await getConnection();
        const request = pool.request();

        let consulta = `
            SELECT v.id_vehiculo, v.chasis,
                   m.nombre         AS modelo,
                   tm.descripcion   AS motor,
                   s.nombre         AS sucursal
            FROM vehiculo v
            JOIN modelo m       ON v.id_modelo = m.id_modelo
            JOIN tipo_motor tm  ON m.id_tipo_motor = tm.id_tipo_motor
            JOIN sucursal s     ON v.id_sucursal = s.id_sucursal
            JOIN localidad l    ON s.id_localidad = l.id_localidad
            WHERE v.fecha_egreso IS NULL`;

        if (req.query.id_provincia) {
            const id = Number(req.query.id_provincia);
            if (!Number.isInteger(id)) return res.status(400).json({ error: "id_provincia inválido" });
            request.input("id_provincia", mssql.Int, id);
            consulta += " AND l.id_provincia = @id_provincia";
        }
        if (req.query.id_localidad) {
            const id = Number(req.query.id_localidad);
            if (!Number.isInteger(id)) return res.status(400).json({ error: "id_localidad inválido" });
            request.input("id_localidad", mssql.Int, id);
            consulta += " AND l.id_localidad = @id_localidad";
        }

        const resultado = await request.query(consulta + " ORDER BY s.nombre, m.nombre");
        res.json(resultado.recordset);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

funcExpress.listen(3000, () => console.log("http://localhost:3000"));