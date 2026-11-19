const selProv = document.getElementById("inputFiltroProvincia");
const selLoc = document.getElementById("inputFiltroLocalidad");
const inputMinimo = document.getElementById("inputMinimoStock");
const contador = document.querySelector(".stockVehiculos");
const listaNombre = document.querySelector(".vehiculoNombre").parentElement;
const listaChasis = document.querySelector(".vehiculoChasis").parentElement;
const listaMotor = document.querySelector(".vehiculoTipoMotor").parentElement;

let localidades = [];

async function pedir(url) {
    const r = await fetch(url);
    if (!r.ok) throw new Error("Error " + r.status);
    return r.json();
}

function llenarSelect(select, filas, campoId) {
    select.length = 1; // deja solo la opción "-"
    for (const f of filas) {
        const option = document.createElement("option");
        option.value = f[campoId];
        option.textContent = f.nombre;
        select.appendChild(option);
    }
}

function agregarItem(ul, texto) {
    const li = document.createElement("li");
    li.textContent = texto;
    ul.appendChild(li);
}

async function cargarStock() {
    const params = new URLSearchParams();
    if (selProv.value !== "todo") params.set("id_provincia", selProv.value);
    if (selLoc.value !== "todo") params.set("id_localidad", selLoc.value);

    const vehiculos = await pedir("/stock?" + params);

    listaNombre.innerHTML = "";
    listaChasis.innerHTML = "";
    listaMotor.innerHTML = "";

    for (const v of vehiculos) {
        agregarItem(listaNombre, v.modelo);
        agregarItem(listaChasis, v.chasis);
        agregarItem(listaMotor, v.motor);
    }

    contador.textContent = vehiculos.length;

    const minimo = Number(inputMinimo.value);
    contador.style.color = (inputMinimo.value !== "" && vehiculos.length < minimo) ? "red" : "";
}

async function iniciar() {
    const provincias = await pedir("/datos/provincia?columnas=id_provincia,nombre");
    localidades = await pedir("/datos/localidad?columnas=id_localidad,id_provincia,nombre");

    llenarSelect(selProv, provincias, "id_provincia");
    llenarSelect(selLoc, localidades, "id_localidad");
    await cargarStock();
}

selProv.addEventListener("change", () => {
    const filtradas = selProv.value === "todo"
        ? localidades
        : localidades.filter(l => l.id_provincia == selProv.value);
    llenarSelect(selLoc, filtradas, "id_localidad");
    cargarStock();
});

selLoc.addEventListener("change", cargarStock);
inputMinimo.addEventListener("input", cargarStock);

iniciar().catch(console.error);