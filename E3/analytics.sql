
/* 6.1 */

SELECT dia_semana, concelho, SUM (unidade) AS total
FROM vendas
--where ano-mes-dia_semana between date1 and date2
GROUP BY 
GROUPING SETS ( (dia_semana), (concelho), () ) ;


/* 6.2 */

SELECT concelho, cat, dia_semana, SUM (unidade) AS total
FROM vendas
WHERE distrito = 'Lisboa'
GROUP BY 
GROUPING SETS ( (concelho), (cat), (dia_semana), () ) ;