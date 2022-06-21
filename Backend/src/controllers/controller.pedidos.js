import { Router } from "express";
import db from '../config/database.js';

const controllerPedidos = Router();

controllerPedidos.get("/pedidos", function(request, response){
    let ssql = "select p.id_pedido, p.id_usuario, p.id_mercado, p.dt_pedido, "
    ssql += "p.vl_subtotal, p.vl_entrega, p.vl_total, p.endereco, p.bairro, "
    ssql += "p.cidade, p.uf, p.cep, m.nome, count(*) as qtd_itens "
    ssql += "from pedido p ";
    ssql += "join pedido_item i on (i.id_pedido = p.id_pedido) ";
    ssql += "join mercado m on (m.id_mercado = p.id_mercado) ";
    ssql += "where p.id_usuario = ? ";
    ssql += "group by p.id_pedido, p.id_usuario, p.id_mercado, p.dt_pedido, "
    ssql += "p.vl_subtotal, p.vl_entrega, p.vl_total, p.endereco, p.bairro, "
    ssql += "p.cidade, p.uf, p.cep, m.nome "
    ssql += "order by p.id_pedido desc"

    db.query(ssql, [request.query.id_usuario], function(err, result){
        if(err){
            return response.status(500).send(err);
        }else{
            return response.status(result.length > 0 ? 200 : 404).json(result);
        }
    });
});

controllerPedidos.get("/pedidos/:id_pedido", function(request, response){
    let ssql = "select p.*, m.nome as nome_mercado, m.endereco as endereco_mercado";
    ssql += " from pedido p";
    ssql += " join mercado m on (m.id_mercado = p.id_mercado)"
    ssql += " where p.id_pedido = ?";

    db.query(ssql, [request.params.id_pedido], function(err, result){
        if(err){
            return response.status(500).send(err);
        }else{
            let id_pedido = result[0].id_pedido;
            let jsonPedido = result[0];

            ssql = "select i.id_item, i.id_produto, i.qtd, i.vl_unitario, i.vl_total, p.descricao, p.url_foto";
            ssql += " from pedido_item i";
            ssql += " join produto p on (p.id_produto = i.id_produto)";
            ssql += " where i.id_pedido = ?";

            db.query(ssql, [id_pedido], function(err, result){
                if(err){
                    return response.status(500).send(err);
                }else{
                    jsonPedido["itens"] = result;
                    return response.status(200).json(jsonPedido);    
                }
            })

            
        }
    });
});

controllerPedidos.post("/pedidos", function(request, response){
    db.getConnection(function(err, conn){
        const {id_mercado, id_usuario, vl_subtotal, vl_entrega,
               vl_total, endereco, bairro, cidade, uf, cep} = request.body;
        conn.beginTransaction(function(err){
            let ssql = "insert into pedido (id_mercado, id_usuario, dt_pedido, vl_subtotal,";
            ssql += " vl_entrega, vl_total, endereco, bairro, cidade, uf, cep)";
            ssql += "values(?, ?, current_timestamp(), ?, ?, ?, ?, ?, ?, ?, ?)";
            
            conn.query(ssql, [id_mercado, id_usuario, vl_subtotal, vl_entrega,vl_total,
                       endereco, bairro, cidade, uf, cep], function(err, result){
                if(err){
                    conn.rollback();
                    return response.status(500).send(err);
                }else{
                    let id_pedido = result.insertId;
                    let values = [];

                    //itens do carrinho...
                    request.body.itens.map(function(item){
                       values.push([id_pedido, item.id_produto, item.qtd,
                                    item.vl_unitario, item.vl_total]); 
                    });

                    let ssql = "insert into pedido_item(id_pedido, id_produto, qtd, vl_unitario, vl_total)";
                    ssql += "values ?";

                    conn.query(ssql, [values], function(err, result){
                        conn.release();
                        if(err){
                            conn.rollback();
                            return response.status(500).send(err);
                        }else{
                            conn.commit();
                            return response.status(201).json({id_pedido});
                        }
                    });  
                }
            });
        });
    });
    

    
});

export default controllerPedidos;