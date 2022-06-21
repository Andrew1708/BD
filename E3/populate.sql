/* 
scp populate.sql ist199077@sigma.tecnico.ulisboa.pt:~ 
ssh ist199077@sigma.tecnico.ulisboa.pt
psql -h db.tecnico.ulisboa.pt -U ist199077
 \i populate.sql*/


drop table if exists categoria cascade;
drop table if exists categoria_simples cascade;
drop table if exists super_categoria cascade;
drop table if exists tem_outra cascade;
drop table if exists produto cascade;
drop table if exists tem_categoria cascade;
drop table if exists ivm cascade;
drop table if exists ponto_de_retalho cascade;
drop table if exists instalada_em cascade;
drop table if exists prateleira cascade;
drop table if exists planograma cascade;
drop table if exists retalhista cascade;
drop table if exists responsavel_por cascade;
drop table if exists evento_reposicao cascade;


create table categoria (
	nome varchar(80) not null unique,
	constraint pk_categoria primary key(nome)
);

create table categoria_simples (
	nome varchar(80) not null unique,
    constraint pk_categoria_simples primary key(nome),
	constraint fk_categoria_nome foreign key(nome) references categoria(nome) on delete cascade
);

create table super_categoria (
	nome varchar(80) not null unique,
    constraint pk_super_categoria primary key(nome),
	constraint fk_categoria_nome foreign key(nome) references categoria(nome) on delete cascade 
);

create table tem_outra (
    categoria varchar(80) not null,
	super_categoria varchar(80) not null,
    constraint pk_tem_outra primary key(categoria),
	constraint fk_tem_outra_sup_cat_nome foreign key(super_categoria) references super_categoria(nome) on delete cascade,
	constraint fk_tem_outra_cat_nome foreign key(categoria) references categoria(nome) on delete cascade,
    check (categoria != super_categoria)
);

create table produto (
	ean numeric(13) not null unique,
    cat varchar(80) not null,
    descr varchar(80) not null,
    constraint pk_produto primary key(ean),
    constraint fk_produto foreign key(cat) references categoria(nome) on delete cascade
);--verificar se ean existe em tem categoria

create table tem_categoria (
	ean numeric(13) not null,
	nome varchar(80) not null,
  	constraint fk_tem_categoria_ean foreign key(ean) references produto(ean) on delete cascade,
	constraint fk_tem_categoria_nome foreign key(nome) references categoria(nome) on delete cascade
);

create table ivm (
	num_serie numeric(12) not null,
	fabricante varchar(80) not null,
    constraint pk_ivm primary key(num_serie, fabricante)
);

create table ponto_de_retalho (
  	nome varchar(80) not null unique,
	distrito varchar(80) not null,
	concelho varchar(80) not null,
	constraint pk_ponto_de_retalho primary key(nome)
);

create table instalada_em (
	num_serie numeric(12) not null,
	fabricante varchar(80) not null,
	local varchar(80) not null,
    constraint pk_instalada_em primary key(num_serie, fabricante),
	constraint fk_instalada_em_num_serie_e_fabricante foreign key(num_serie, fabricante) references ivm(num_serie, fabricante) on delete cascade,
	constraint fk_instalada_em_local foreign key(local) references ponto_de_retalho(nome) on delete cascade
);

create table prateleira (
  	nro numeric(10) not null,
    num_serie numeric(12) not null,
    fabricante varchar(80) not null,
    altura real not null,
    nome varchar(80) not null,
    constraint pk_prateleira primary key(nro, num_serie, fabricante),
    constraint fk_prateleira_num_serie_e_fabricante foreign key(num_serie, fabricante) references ivm(num_serie, fabricante) on delete cascade,
    constraint fk_prateleira_local foreign key(nome) references categoria(nome) on delete cascade
);

create table planograma (
  	ean numeric(13) not null,
    nro numeric(10) not null,
    num_serie numeric(12) not null,
    fabricante varchar(80) not null,
    faces smallint not null,
    unidades numeric(10) not null,
    loc varchar(80) not null,
    constraint pk_planograma primary key(ean, nro, num_serie, fabricante), 
    constraint fk_planograma_ean foreign key(ean) references produto(ean) on delete cascade,
    constraint fk_planograma_nro_e_num_serie_e_fabricante foreign key(nro, num_serie, fabricante) references prateleira(nro, num_serie, fabricante) on delete cascade
);

create table retalhista (
	tin numeric(9) not null,
    nome varchar(80) not null unique,
    constraint pk_retalhista primary key(tin)
);

create table responsavel_por (
  	nome_cat varchar(80) not null,
    tin numeric(9) not null,
    num_serie numeric(12) not null,
    fabricante varchar(80) not null,
    constraint pk_responsavel_por primary key(nome_cat, num_serie, fabricante), 
    constraint fk_responsavel_por_num_serie_e_fabricante foreign key(num_serie, fabricante) references ivm(num_serie, fabricante) on delete cascade,
    constraint fk_responsavel_por_tin foreign key(tin) references retalhista(tin) on delete cascade,
    constraint fk_responsavel_por_nome_cat foreign key(nome_cat) references categoria(nome) on delete cascade
);

create table evento_reposicao (
  	ean numeric(13) not null,
    nro numeric(10) not null,
    num_serie numeric(12) not null,
    fabricante varchar(80) not null,
    instante timestamp not null,
    unidades numeric(8) not null,
    tin numeric(9) not null,
    constraint pk_evento_reposicao primary key(ean, nro, num_serie, fabricante, instante),
    constraint fk_evento_reposicao_ean_e_nro_e_num_serie_e_fabricante foreign key(ean, nro, num_serie, fabricante) references planograma(ean, nro, num_serie, fabricante) on delete cascade,
    constraint fk_evento_reposicao_tin foreign key(tin) references retalhista(tin) on delete cascade
);

-- SCRIPT
insert into categoria 
values 
('Comidas'),
('Bebidas'), 
('Águas'),
('Sumos'),
('Refrigerantes'),
('Sopas'),
('Sandes'),
('Baguetes'),
('Sobremesas'),
('Iogurtes'),
('Gelatina'),
('Bolos'),
('Chocolates');

insert into categoria_simples
values
('Águas'),
('Sumos'),
('Refrigerantes'),
('Sopas'),
('Sandes'),
('Baguetes'),
('Iogurtes'),
('Gelatina'),
('Bolos'),
('Chocolates');

insert into super_categoria
values
('Bebidas'),
('Comidas'), 
('Sobremesas');  

insert into tem_outra
values
('Águas', 'Bebidas'),
('Sumos', 'Bebidas'),
('Refrigerantes', 'Bebidas'),
('Sopas', 'Comidas'),
('Sandes', 'Comidas'),
('Iogurtes', 'Sobremesas'),
('Gelatina', 'Sobremesas'),
('Bolos', 'Sobremesas');

insert into produto
values
(1000000000001, 'Águas', 'Fastio'),
(1000000000002, 'Águas', 'Luso'),
(1000000000003, 'Sumos', 'Compal'),
(1000000000004, 'Sumos', 'Joy'),
(1000000000005, 'Refrigerantes', 'Coca-Cola'),
(1000000000006, 'Refrigerantes', 'Iced Tea'),
(1000000000011, 'Refrigerantes', 'Sumol'),
(1000000000012, 'Sopas', 'Caldo Verde'),
(1000000000013, 'Sandes', 'Atum'),
(1000000000021, 'Sandes', 'Frango'),
(1000000000022, 'Iogurtes', 'Mimosa'),
(1000000000023, 'Gelatina', 'Royal'),
(1000000000031, 'Bolos', 'Waffle'),
(1000000000032, 'Bolos', 'Mil-folhas'),
(1000000000033, 'Chocolates', 'Twix'),
(1000000000034, 'Chocolates', 'Mars'),
(1000000000035, 'Chocolates', 'Milka');

insert into tem_categoria
values
(1000000000001, 'Águas'),
(1000000000002, 'Águas'),
(1000000000003, 'Sumos'),
(1000000000004, 'Sumos'),
(1000000000005, 'Refrigerantes'),
(1000000000006, 'Refrigerantes'),
(1000000000011, 'Refrigerantes'),
(1000000000012, 'Sopas'),
(1000000000013, 'Sandes'),
(1000000000021, 'Sandes'),
(1000000000022, 'Iogurtes'),
(1000000000023, 'Gelatina'),
(1000000000031, 'Bolos'),
(1000000000032, 'Bolos'),
(1000000000033, 'Chocolates'),
(1000000000034, 'Chocolates'),
(1000000000035, 'Chocolates');

insert into ivm
values
(1001, 'SmartUI'),
(1111, 'IVM LDA'),
(1001, 'Fuji');

insert into ponto_de_retalho
values
('Worten', 'Lisboa', 'Sintra'),
('TagusPark', 'Lisboa', 'Oeiras'),
('Clerigos', 'Porto', 'Porto');

insert into instalada_em
values
(1001, 'SmartUI', 'Worten'),
(1111, 'IVM LDA', 'TagusPark'),
(1001, 'Fuji', 'Clerigos');

insert into prateleira
values
(1, 1001, 'SmartUI', 55, 'Águas'),
(2, 1001, 'SmartUI', 55, 'Sumos'),
(3, 1001, 'SmartUI', 55, 'Refrigerantes'),
(4, 1001, 'SmartUI', 55, 'Sopas'),
(5, 1001, 'SmartUI', 55, 'Sandes'),
(1, 1111, 'IVM LDA', 60, 'Iogurtes'),
(2, 1111, 'IVM LDA', 45, 'Gelatina'),
(3, 1111, 'IVM LDA', 60, 'Bolos'),
(1, 1001, 'Fuji', 52, 'Chocolates'),
(2, 1001, 'Fuji', 20, 'Águas'),
(3, 1001, 'Fuji', 25, 'Sandes'),
(4, 1001, 'Fuji', 29, 'Chocolates');

insert into planograma
values
(1000000000001, 1, 1001, 'SmartUI', 10, 20 , 'Worten'),
(1000000000002, 1, 1001, 'SmartUI', 10, 20 , 'Worten'),
(1000000000003, 2, 1001, 'SmartUI', 10, 20 , 'Worten'),
(1000000000004, 2, 1001, 'SmartUI', 10, 20 , 'Worten'),
(1000000000005, 3, 1001, 'SmartUI', 10, 20 , 'Worten'),
(1000000000006, 3, 1001, 'SmartUI', 10, 20 , 'Worten'),
(1000000000011, 3, 1001, 'SmartUI', 10, 20 , 'Worten'),
(1000000000012, 4, 1001, 'SmartUI', 10, 20 , 'Worten'),
(1000000000013, 5, 1001, 'SmartUI', 10, 20 , 'Worten'),
(1000000000021, 5, 1001, 'SmartUI', 10, 30 , 'Worten'),
(1000000000022, 1, 1111, 'IVM LDA', 10, 35 , 'TagusPark'),
(1000000000023, 2, 1111, 'IVM LDA', 30, 30 , 'TagusPark'),
(1000000000031, 3, 1111, 'IVM LDA', 45, 45 , 'TagusPark'),
(1000000000032, 3, 1111, 'IVM LDA', 65, 45 , 'TagusPark'),
(1000000000033, 1, 1001, 'Fuji', 15, 45 , 'Clerigos'),
(1000000000034, 1, 1001, 'Fuji', 15, 40 , 'Clerigos'),
(1000000000035, 1, 1001, 'Fuji', 5, 10 , 'Clerigos'),
(1000000000002, 2, 1001, 'Fuji', 5, 10 , 'Clerigos'),
(1000000000013, 3, 1001, 'Fuji', 5, 15 , 'Clerigos'),
(1000000000034, 4, 1001, 'Fuji', 20, 15 , 'Clerigos');

insert into retalhista 
values
(1001, 'André'),
(1002, 'Guilherme'),
(1003, 'João'),
(2001, 'Jessica');

insert into responsavel_por
values
('Águas', 1001, 1001, 'SmartUI'),
('Sumos', 1001, 1001, 'SmartUI'),
('Refrigerantes', 1001, 1001, 'SmartUI'),
('Sopas', 1001, 1001, 'SmartUI'),
('Sandes', 1001, 1001, 'SmartUI'),
('Iogurtes', 1001, 1111, 'IVM LDA'),
('Gelatina', 1001, 1111, 'IVM LDA'),
('Bolos', 1001, 1111, 'IVM LDA'),
('Chocolates', 1001, 1001, 'SmartUI'),
('Águas', 1002, 1001, 'Fuji'),
('Sandes', 1003, 1001, 'Fuji'),
('Baguetes', 1001, 1001, 'SmartUI'),
('Chocolates', 2001, 1001, 'Fuji');

insert into evento_reposicao
values
(1000000000001, 1, 1001, 'SmartUI', '2022-08-17 12:30:00', 10 , 1001),
(1000000000002, 1, 1001, 'SmartUI', '2022-08-17 14:45:00', 10 , 1001),
(1000000000003, 2, 1001, 'SmartUI', '2022-08-17 12:35:00', 10 , 1001),
(1000000000004, 2, 1001, 'SmartUI', '2022-08-17 12:45:00', 10 , 1001),
(1000000000005, 3, 1001, 'SmartUI', '2022-08-17 13:30:00', 10 , 1001),
(1000000000006, 3, 1001, 'SmartUI', '2022-05-17 13:30:00', 20 , 1002),
(1000000000006, 3, 1001, 'SmartUI', '2022-05-17 13:35:00', 20 , 1003),
(1000000000011, 3, 1001, 'SmartUI', '2022-05-17 13:30:00', 20 , 1002),
(1000000000011, 3, 1001, 'SmartUI', '2022-05-17 13:35:00', 20 , 1003),
(1000000000035, 1, 1001, 'Fuji', '2022-05-17 13:30:00', 5 , 2001),
(1000000000035, 1, 1001, 'Fuji', '2022-05-17 13:35:00', 5 , 2001),
(1000000000035, 1, 1001, 'Fuji', '2022-05-17 13:36:00', 5 , 2001);
