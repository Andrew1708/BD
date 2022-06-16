create or replace function update_loan() 
returns varchar(80) as $res$
declare varchar
begin
	select tin, count(*)
    from responsavel_por
	group by tin
	
	return res;
end;
$$ language plpgsql;