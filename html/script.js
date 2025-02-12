// Recebe mensagens do client
window.addEventListener('message', function (event) {

    var data = event.data;
    if (data.action === "showUI") {
        showFarmMenu(data.routes);
    } else if (data.action === "hideUI") {

        hideFarmMenu();
    }
});



$(document).keyup((event)=>{
    if(event.key ==='Escape'){

        sendDataToClient('closeCurrentNUI',null)

    }
})


// function showFarmMenu(routes) {

//     var menu = document.getElementById("farmMenu");
//     var routeList = document.getElementById("routeList");
//     routeList.innerHTML = "";

    
//     for (var key in routes) {
//         if (routes.hasOwnProperty(key)) {

//             var li = document.createElement("li");
//             li.textContent = key;
//             li.onclick = function () {
//                 var selectedRoute = this.textContent;
//                 selectRoute(selectedRoute);
//             };
//             routeList.appendChild(li);

//         }
//     }
//     menu.style.display = "block";
// }

function showFarmMenu(routes) {
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
            selectRoute(key);
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
    fetch(`https://${GetParentResourceName()}/selectRoute`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ routeName: routeName })
    }).then(resp => resp.json()).then(resp => {
        console.log(resp);
    });
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
