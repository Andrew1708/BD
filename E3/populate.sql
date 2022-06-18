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
	constraint fk_categoria_nome foreign key(nome) references categoria(nome)
);

create table super_categoria (
	nome varchar(80) not null unique,
    constraint pk_super_categoria primary key(nome),
	constraint fk_categoria_nome foreign key(nome) references categoria(nome)
);

create table tem_outra (
	super_categoria varchar(80) not null,
	categoria varchar(80) not null,
    constraint pk_tem_outra primary key(categoria),
	constraint fk_tem_outra_sup_cat_nome foreign key(super_categoria) references super_categoria(nome),
	constraint fk_tem_outra_cat_nome foreign key(categoria) references categoria(nome)
);

create table produto (
	ean numeric(13) not null unique,
    cat varchar(80) not null,
    descr varchar(80) not null,
    constraint pk_produto primary key(ean),
    constraint fk_produto foreign key(cat) references categoria(nome)
);

create table tem_categoria (
	ean numeric(13) not null,
	nome varchar(80) not null,
  	constraint fk_tem_categoria_ean foreign key(ean) references produto(ean),
	constraint fk_tem_categoria_nome foreign key(nome) references categoria(nome)
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
	constraint fk_instalada_em_num_serie_e_fabricante foreign key(num_serie, fabricante) references ivm(num_serie, fabricante),
	constraint fk_instalada_em_local foreign key(local) references ponto_de_retalho(nome)
);

create table prateleira (
  	nro numeric(10) not null,
    num_serie numeric(12) not null,
    fabricante varchar(80) not null,
    altura real not null,
    nome varchar(80) not null,
    constraint pk_prateleira primary key(nro, num_serie, fabricante),
    constraint fk_prateleira_num_serie_e_fabricante foreign key(num_serie, fabricante) references ivm(num_serie, fabricante),
    constraint fk_prateleira_local foreign key(nome) references categoria(nome)
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
    constraint fk_planograma_ean foreign key(ean) references produto(ean),
    constraint fk_planograma_nro_e_num_serie_e_fabricante foreign key(nro, num_serie, fabricante) references prateleira(nro, num_serie, fabricante)
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
    constraint fk_responsavel_por_num_serie_e_fabricante foreign key(num_serie, fabricante) references ivm(num_serie, fabricante),
    constraint fk_responsavel_por_tin foreign key(tin) references retalhista(tin),
    constraint fk_responsavel_por_nome_cat foreign key(nome_cat) references categoria(nome)
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
    constraint fk_evento_reposicao_ean_e_nro_e_num_serie_e_fabricante foreign key(ean, nro, num_serie, fabricante) references planograma(ean, nro, num_serie, fabricante),
    constraint fk_evento_reposicao_tin foreign key(tin) references retalhista(tin)
);

-- SCRIPT
-- Retalhistas
insert into retalhista values(1, 'André');
insert into retalhista values(2, 'Pedro');
insert into retalhista values(3, 'José');
insert into retalhista values(4, 'Manel');
insert into retalhista values(5, 'Guilherme');
insert into retalhista values(6, 'Jessica');
insert into retalhista values(7, 'Monica');
insert into retalhista values(8, 'Joana');

-- IVMs
insert into ivm values(45, 'GALP');
insert into ivm values(12, 'BP');
insert into ivm values(13, 'AUCHAN');
insert into ivm values(27, 'EDP');
insert into ivm values(30, 'PRIO');
insert into ivm values(14, 'WORTEN');

-- Categorias
insert into categoria values('ovos');
insert into categoria values('choco');
insert into categoria values('leite');
insert into categoria values('pao');
insert into categoria values('bolos');
insert into categoria values('sumos');
insert into categoria values('agua');
insert into categoria values('fruta');

-- responsavel_por
insert into responsavel_por values('ovos', 1, 45, 'GALP');
insert into responsavel_por values('choco', 1, 45, 'GALP');
insert into responsavel_por values('leite', 2, 45, 'GALP');
insert into responsavel_por values('pao', 2, 45, 'GALP');
insert into responsavel_por values('bolos', 3, 45, 'GALP');
insert into responsavel_por values('sumos', 5, 12, 'BP');
insert into responsavel_por values('agua', 5, 12, 'BP');
insert into responsavel_por values('ovos', 4, 12, 'BP');


