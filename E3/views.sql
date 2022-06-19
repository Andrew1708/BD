drop view vendas

create view vendas(ean, cat, ano, trimestre, mes, dia_semana, distrito, concelho, unidade) as
select ean, 
       cat,
       extract(year from timestamp instante) as ano 
       extract(quarter from timestamp instante) as trimestre
       extract(month from timestamp instante) as mes
       extract(dow from timestamp instante) as dia_semana 
       distrito,
       concelho,
       unidades,
from evento_reposicao natural join produtos naturla join instalada_em natural join ponto_de_retalho;