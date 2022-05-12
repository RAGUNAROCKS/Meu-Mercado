import mysql from 'mysql';

//Conexão com o Banco de dados
const db = mysql.createPool({
    host:"localhost",
    user:"root",
    password:"654321",
    database: "meu_mercado"
});

export default db;