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

app.get("/usuarios", function(request, response){
    let ssql = "select * from usuario"
    db.query(ssql, function(err, result){
        if(err){
            return response.status(500).send(err);
        }else{
            return response.status(200).json(result);
        }
    });
});

app.get("/usuarios/:id", function(request, response){
    let ssql = "select * from usuario where id_usuario = ?"
    db.query(ssql, [request.params.id], function(err, result){
        if(err){
            return response.status(500).send(err);
        }else{
            return response.status(result.length > 0 ? 200 : 404).json(result[0]);
        }
    });
});

app.post("/usuarios/login", function(request, response){
    const body = request.body;
    let ssql = "select id_usuario, nome, email, endereco, bairro, cidade, uf, cep, ";
    ssql += " date_format(dt_cadastro, '%d/%m/%y %H:%i:%s') as dt_cadastro"
    ssql += " from usuario where email=? and senha=?";
    db.query(ssql, [body.email, body.senha], function(err, result){
        if(err){
            return response.status(500).send(err);
        }else{
            return response.status(result.length > 0 ? 200 : 401).json(result[0]);
        }
    });
});


app.listen(3000, function(){
    console.log('Servidor no ar...');
});