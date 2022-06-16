-- RI - 1

drop trigger if exists tem_outra_trigger on tem_outra;  -- garante que não existe um trigger com o mesmo nome associado a tabela

create or replace function tem_outra_trigger() return as $$ -- cria função

begin
    if new.categoria == new.super_categoria then 
        raise exception 'As Categorias não podem estar contidas dentro de si próprias' 
    end if;
    return new;

end;
$$ language plpgsql

create trigger tem_outra_trigger before insert on tem_outra -- associa trigger a tabela
for each row execute procedure tem_outra_trigger();


-- RI - 4
drop trigger if exists verifica_unidades on evento_reposicao;

create or replace function verifica_unidades() return as $$
-- variável que contem as unidades especificadas no planograma
declare unidades_planograma numeric(10) 

begin
    -- vamos buscar essas unidades à tabela do planograma
    select unidades into unidades_planograma 
    from planograma
    where new.ean = ean and new.nro = nro and new.num_serie = num_serie and new.fabricante = fabricante 
    -- pk de planograma

    if new.unidades > unidades_planograma then
        raise exception 'O número de unidades repostas num Evento de Reposição
                            não pode exceder o número de unidades especificado no Planograma'
    end if;
    return new;

end;
$$ language plpgsql

create trigger verifica_unidades before insert on evento_reposicao
for each row execute procedure verifica_unidades();

-- RI - 5
drop trigger if exists verifica_produto on evento_reposicao;

create or replace function verifica_produto() return as $$

declare categoria_prod varchar(80)

begin
    -- vai buscar a categoria do produto a repor
    select cat into categoria_prod
    from produto
    where ean = new.ean
    -- tabela com as categorias da prateleira
    (select nome
    from prateleira
    where new.nro = nro and new.num_serie = num_serie and new.fabricante = fabricante)
    as categorias_prateleira -- É PRECISO DECLARAR??

    if categoria_prod not in categorias_prateleira then
        raise exception 'Um Produto só pode ser reposto numa Prateleira que 
                            apresente (pelo menos) uma das Categorias desse produto'
    end if;
    return new;

end;
$$ language plpgsql

create trigger verifica_produto before insert on evento_reposicao
for each row execute procedure verifica_produto();