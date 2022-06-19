/* ex1 
Qual o nome do retalhista (ou retalhistas) responsáveis pela reposição do maior número de categorias*/
select nome
from
	(select tin, count(*)
	from responsavel_por
	group by tin
	having count(*) >= all(
		select count(*)
		from responsavel_por
		group by tin
		) 
	) as st
	natural join
	retalhista;


/* ex2 
Qual o nome do ou dos retalhistas que são responsáveis por todas as categorias simples
dividir os retalhistas e as suas categorias por uma tabela com todas as categorias simples*/

select nome
from retalhista
where tin in(
    select distinct tin 
    from responsavel_por as sx
    -- devolve o tin no responsavel_por que não está na tabela seguinte
    where NOT EXISTS ( 
        -- tabela com todas as categorias simples
        (select p.nome 
        from categoria_simples as p )
        EXCEPT
        -- devolve uma tabela com as categorias que tem um responsável "agrupadas" pelo tin  
        (select sp.nome_cat 
        from  responsavel_por as sp 
        where sp.tin = sx.tin) 
        -- ao fazermos o except é como se da tabela anterior removessemos o agrupamento de todas
        -- as categorias simples (o nr de vezes que este aparece)
        )
    );

/* ex3 
Quais os produtos (ean) que nunca foram repostos?*/
select ean from produto
where ean not in 
	(select ean
	from evento_reposicao);

/* ex4 
Quais os produtos (ean) que foram repostos sempre pelo mesmo retalhista?
*/
select ean
from evento_reposicao
group by ean -- agrupamos os eans repetidos 
having count(distinct tin) = 1; -- só os representamos se apenas tiverem associados a apenas 1 tin, ou seja,
                                -- a contagem dos tins diferentes seja igual a 1


/* 7.1
Utilizamos um hash index no nome da categoria pelo facto de na consulta estar especificado o nome da categoria como 'Frutos',
realizando a procura dos tins depois de ser obtido o Retalhista com categoria de 'Frutos, realizando a procura de forma mais rápida.*/
drop index cat_idx

create index cat_idx on responsavel_por using hash(nome_cat)

SELECT DISTINCT R.nome
FROM retalhista R, responsavel_por P
WHERE R.tin = P.tin and P. nome_cat = 'Frutos'

/* 7.2
Utilizamos um index bi-tree como critério a descrição começar com a letra A porque assim descobre rapidamente os produtos
com uma descrição com esse critério visto que já é conhecido, e evitamos usar um index hash visto que várias descrições podem
começar com 'A' e ordenar alfabeticamente é mais rápido com uma binary tree. Depois de descobrir o produto rapidamente, irá comparar os nomes das categorias.*/
drop index des_idx

create index des_idx on produto(descr)

SELECT T.nome, count(T.ean)
FROM produto P, tem_categoria T
WHERE p.cat = T.nome and P.desc like 'A%'
GROUP BY T.nome
