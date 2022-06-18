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
from retalhista r
where not exists (
	select nome
	from categoria_simples
	EXCEPT
	select nome_cat
	from responsavel_por
	where nome = nome_cat 
	);

(select tin, nome_cat 
from responsavel_por

) as table
natural join 
retalhista;


SELECT DISTINCT	customer_name
FROM	depositor	DP
WHERE NOT EXISTS(
	SELECT	branch_name
	FROM	branch
	SELECT	branch_name
	FROM	(account	A
		JOIN	depositor	D
			ON	A.account_number	=	d.account_number)	AC
	WHERE	AC.customer_name	=	x
	EXCEPT



/* ex3 
Quais os produtos (ean) que nunca foram repostos?*/
select ean from produto
where ean not in 
	(select ean
	from evento_reposicao);




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
