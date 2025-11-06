--Test Trigger 3
--Inserta nuevo picking
INSERT INTO Picking (id_detalle_pedido, id_operario, resultado_validacion) VALUES
(7,4,'PENDIENTE');
--obtener el picking id del insert previo y hacer update a OK para disparar el trigger
update picking set resultado_validacion = 'OK' where id_picking = 12

--validar que se creo el nuevo despacho
select * from despacho

--Test trigger 2
--Cantidad solicitada mayor a 500, se bloquea 1 solo insert
select * from lote
select * from pedido
select * from Estado_Pedido

INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad_solicitada, unidad_medida) VALUES
(9,2,30000, 'cancelado por stock'),
(12,2,10, 'test stock pass')

--cantidad solicitada menor a 500, se hacen los insert sin problemas
INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad_solicitada, unidad_medida) VALUES
(6,1,10,'Testmohamulti'),
(6,2,15, NULL)

select * from pedido
select * from detalle_pedido

