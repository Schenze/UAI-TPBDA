"use strict";
console.log("javascript inicializado");
async function loginAcceder()
{
	  const usuario = document.getElementById('inputLogin').value;
      const password = document.getElementById('inputPassword').value;
      const mensaje = document.getElementById('advertencia');
	  const hashtexto = await calcularMD5(password);
	  console.log(password,"antes");
	  console.log(hashtexto,"despues");
	  
	  if (usuario === 'admin' && hashtexto === '8cb2237d0679ca88db6464eac60da96345513964') {
        mensaje.textContent = 'Login exitoso';
        mensaje.style.color = 'green';
		console.log("good login! :)");
		cambiarPagina();
      } else {
        mensaje.textContent = 'Usuario o contrasenia incorrectos';
        mensaje.style.color = 'purple';
		console.log("bad login:(");
      }
	//calcularMD5("12345").then(hash => console.log(hash)); //8cb2237d0679ca88db6464eac60da96345513964 12345
	//BORRAR LOS CONSOLE.LOGS
}
async function calcularMD5(text) {
  const encoder = new TextEncoder();
  const data = encoder.encode(text);
  const hashBuffer = await crypto.subtle.digest('SHA-1', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  return hashHex;
}

function cambiarPagina()
{
	const mensaje = document.getElementById('advertencia');
	mensaje.textContent = "Login exitoso, entrando...";
	window.location.href="index.html";
}
document.querySelector("#inputIngresar").addEventListener("click",loginAcceder)