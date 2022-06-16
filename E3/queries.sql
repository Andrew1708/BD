create or replace function ex1() 
returns $res$ varchar(80) 
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