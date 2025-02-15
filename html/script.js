// Recebe mensagens do client
window.addEventListener('message', function (event) {

    var data = event.data;
    if (data.action === "showUI") {
        showFarmMenu(data.routes,data.coords);
    } else if (data.action === "hideUI") {

        hideFarmMenu();
    }
});



$(document).keyup((event)=>{
    if(event.key ==='Escape'){

        sendDataToClient('closeCurrentNUI',null)

    }
})



function showFarmMenu(routes,coords) {

    var menu = document.getElementById("farmMenu");
    var routeList = document.getElementById("routeList");
    routeList.innerHTML = "";

    // Ordena as chaves das rotas
    var sortedKeys = Object.keys(routes).sort();

    // Adiciona os itens ordenados ao menu
    sortedKeys.forEach(function (key) {
        var li = document.createElement("li");
        li.textContent = key;
        li.onclick = function () {
            selectRoute({key,coords});
        };
        routeList.appendChild(li);
    });

    menu.style.display = "block";
   

}


function hideFarmMenu() {

    var menu = document.getElementById("farmMenu");
    menu.style.display = "none";

}

function selectRoute(routeName) {

    sendDataToClient("selectRoute",routeName)
}

document.getElementById("closeBtn").addEventListener("click", function () {
    sendDataToClient('closeCurrentNUI',null)
});





function sendDataToClient(url,data){

    let current_data 
    if(data){
        current_data = data
    } else{
        current_data = 'ok'
    }

    let config = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(current_data)
    }
    fetch(`https://${GetParentResourceName()}/${url}`, config)
    .then(() =>{
        console.log("Mensagem enviada ao client.lua");
    }).catch(error => {
        console.log('Error: ',error);
        
    })

}
