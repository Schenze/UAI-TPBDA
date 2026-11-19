fetch("/datos/provincia?columnas=id_provincia,nombre")
    .then(r => {
        if (!r.ok) throw new Error("Error " + r.status);
        return r.json();
    })
    .then(provincias => {
        const select = document.getElementById("inputFiltroProvincia");
        for (const p of provincias) {
            const option = document.createElement("option");
            option.textContent = p.nombre;
            option.value = p.id_provincia;
            select.appendChild(option);
        }
    })
    .catch(console.error);

fetch("/datos/localidad?columnas=id_localidad,id_provincia,nombre")
    .then(r => {
        if (!r.ok) throw new Error("Error " + r.status);
        return r.json();
    })
    .then(localidades => {
        const select = document.getElementById("inputFiltroLocalidad");
        for (const l of localidades) {
            const option = document.createElement("option");
            option.textContent = l.nombre;
            option.value = l.id_localidad;
            select.appendChild(option);
        }
    })
    .catch(console.error);