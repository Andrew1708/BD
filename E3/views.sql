drop view if exists vendas;

create view vendas(ean, cat, ano, trimestre, mes, dia_semana, distrito, concelho, unidade) as
select ean, 
       cat,
       extract(year from instante) as ano, 
       extract(quarter from instante) as trimestre,
       extract(month from instante) as mes,
       extract(dow from instante) as dia_semana, 
       distrito,
       concelho,
       unidades
from (evento_reposicao natural join produto natural join instalada_em) t 
       -- como os atributos tem nomes diferentes nas tabelas nao podemos fazer apenas natural join
       join ponto_de_retalho pr on t.local = pr.nome;