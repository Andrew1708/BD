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

