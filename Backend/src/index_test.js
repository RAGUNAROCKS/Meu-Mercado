import express from 'express';
import cors from 'cors';
import mysql from 'mysql';

const app = express();

app.use(express.json());
app.use(cors());

const db = mysql.createPool({
    host:"localhost",
    user:"root",
    password:"654321",
    database: "meu_mercado"
})

/* GET: Retorna dados
   POST: Cadastrar Dados
   PUT: Editar Dados
   PATCH: Editar Dados
   DELETE: Excluir Dados*/


//Querry Params(clientes?ordem=numero&top=100)...
app.get("/clientes", function(request, response){
    console.log(request.query);
    return response.send('Listando somente o cliente ordenados por ' + request.query.ordem + ' e listando apenas ' + request.query.top + ' registros.');
});

//URI Params...
app.get("/clientes/:id", function(request, response){
    return response.send('Listando somente o cliente ' + request.params.id);
});

app.post("/clientes", function(request, response){
    const body = request.body;
    console.log(body);
    return response.send('Novo cliente: ' + body.nome + ' - ' + body.email);
});

app.put("/clientes", function(request, response){
    return response.send('Alterando um cliente com put');
});

app.patch("/clientes", function(request, response){
    return response.send('Alterando um cliente com patch');
});

app.get("/produtos", function(request, response){
    return response.send('Listando todos os produtos...');
});

app.delete("/clientes", function(request, response){
    return response.send('Deletando um cliente');
});

app.listen(3000, function(){
    console.log('Servidor no ar...');
});