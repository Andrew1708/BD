create or replace function ex1() 
returns res varchar(80) 
as 
begin
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
		) as table 
		natural join
		retalhista;

	return res;
end;
$$ language plpgsql;

create or replace function ex3() 
returns res numeric(23)
as 
begin
	select ean from evento_reposicao 
	where ean not in (select ean
    from produto);

	return res;
end;
$$ language plpgsql;