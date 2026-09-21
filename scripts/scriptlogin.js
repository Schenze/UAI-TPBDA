"use strict";
console.log("javascript inicializado");
function loginAcceder()
{
	document.getElementById('inputIngresar').addEventListener('click', function(e) {
     e.preventDefault();
	  const usuario = document.getElementById('inputLogin').value;
      const password = document.getElementById('inputPassword').value;
      const mensaje = document.getElementById('advertencia');
	  console.log("valores preparados!!");
	  
	  if (usuario === 'admin' && password === '1234') {
        mensaje.textContent = 'Login exitoso';
        mensaje.style.color = 'green';
		console.log("good login! :)");
      } else {
        mensaje.textContent = 'Usuario o contraseña incorrectos';
        mensaje.style.color = 'red';
		console.log("bad login:(");
      }
    });
	  
	}