import { Router } from "express";
import db from '../config/database.js';

const controllerCategorias = Router();

controllerCategorias.get("/categorias", function(request, response){
    let filtro = [];
    let ssql = "select * from mercado where id_mercado > 0"

    if(request.query.busca){
        ssql += " and nome = ?";
        filtro.push(request.query.busca);
    }
    if(request.query.ind_entrega){
        ssql += " and ind_entrega = ?";
        filtro.push(request.query.ind_entrega);
    }
    if(request.query.ind_retira){
        ssql += " and ind_retira = ?";
        filtro.push(request.query.ind_retira);
    }

    db.query(ssql, filtro, function(err, result){
        if(err){
            return response.status(500).send(err);
        }else{
            return response.status(result.length > 0 ? 200 : 404).json(result);
        }
    });
});

export default controllerCategorias;