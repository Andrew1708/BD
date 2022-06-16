create or replace function update_loan() 
returns varchar(80) as $res$

begin
	select nome
    from responsavel_por
	
	return res;
end;
$$ language plpgsql;