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

async function LeerLocalidadDB() {
    console.log("dentro de LeerLocalidadDB")
    function filtrarPorLocalidad() {
        console.log("Eligió:", select.value);
    }

    select.addEventListener("change", filtrarPorLocalidad);

    fetch("/localidades")
        .then(r => r.json())
        .then(localidades => {
            localidades.forEach(l => {
                const option = document.createElement("option");
                option.value = l.nombre;
                option.textContent = l.nombre;
                select.appendChild(option);
            });
        })
        .catch(err => console.error("Error al cargar localidades:", err));    
}

document.addEventListener("DOMContentLoaded", () => {
    const select = document.getElementById("inputFiltroLocalidad");
    select.addEventListener("change", inputFiltroLocalidad);
});