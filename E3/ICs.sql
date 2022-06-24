-- RI - 1

drop trigger if exists RI1 on tem_outra;  -- garante que não existe um trigger com o mesmo nome associado a tabela

create or replace function tem_outra_trigger() returns trigger as $$ -- cria função

begin
    if categoria == super_categoria then 
        raise exception 'As Categorias não podem estar contidas dentro de si próprias';
    end if;

    WITH RECURSIVE cats AS(
                 SELECT categoria
                 FROM tem_outra
                 WHERE super_categoria = new.super_categoria
                 UNION
                    SELECT t.categoria
                    FROM tem_outra t
                    INNER JOIN cats c on c.categoria = t.super_categoria
                )
    select categoria, super_categoria
    from cats
    where categoria = super_categoria;

    if found then 
        raise exception 'Existe circularidade de categorias';
    end if;
    return NEW;
    
end;
$$ language plpgsql;

create trigger RI1 before insert on tem_outra 
for each row execute procedure tem_outra_trigger();


-- RI - 4
drop trigger if exists RI4 on evento_reposicao;

create or replace function verifica_unidades() returns trigger as $$
-- variável que contem as unidades especificadas no planograma
declare unidades_planograma numeric(10);

begin
    -- vamos buscar essas unidades à tabela do planograma
    select unidades into unidades_planograma 
    from planograma
    where new.ean = ean and new.nro = nro and new.num_serie = num_serie and new.fabricante = fabricante; 
    -- pk de planograma

    if new.unidades > unidades_planograma then
        raise exception 'O número de unidades repostas num Evento de Reposição
                            não pode exceder o número de unidades especificado no Planograma';
    end if;
    return new;

end;
$$ language plpgsql;

create trigger RI4 before insert on evento_reposicao
for each row execute procedure verifica_unidades();

-- RI - 5
drop trigger if exists RI5 on evento_reposicao;

create or replace function verifica_produto() returns trigger as $$

begin
    -- vai buscar a categoria do produto a repor
    perform cat
    from produto
    where ean = new.ean and cat 
    in(
    -- tabela com as categorias da prateleira
        select nome
        from prateleira
        where new.nro = nro and new.num_serie = num_serie and new.fabricante = fabricante
        );

    if not found then
        raise exception 'Um Produto só pode ser reposto numa Prateleira que 
                            apresente (pelo menos) uma das Categorias desse produto';
    end if;
    return new;

end;
$$ language plpgsql;

create trigger RI5 before insert on evento_reposicao
for each row execute procedure verifica_produto();