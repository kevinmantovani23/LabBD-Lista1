CREATE DATABASE transporte

USE transporte

CREATE TABLE motorista (
	codigo				INT		NOT NULL,
	nome				VARCHAR(40) NOT NULL,
	naturalidade		VARCHAR(40) NOT NULL,
	PRIMARY KEY (codigo)
)

CREATE TABLE onibus (
	placa		CHAR(7)		NOT NULL,
	marca		VARCHAR(15) NOT NULL,
	ano			INT			NOT NULL,
	descricao	VARCHAR(20) NOT NULL,
	PRIMARY KEY (placa)
)

CREATE TABLE viagem (
	codigo		INT			NOT NULL,
	onibus		CHAR(7)		NOT NULL,
	motorista	INT			NOT NULL,
	hora_saida	INT			NOT NULL CHECK(hora_saida >=0),
	hora_chegada INT		NOT NULL CHECK(hora_chegada >=0),
	partida		VARCHAR(40) NOT NULL,
	destino		VARCHAR(40)	NOT NULL,
	FOREIGN KEY (onibus) REFERENCES onibus(placa),
	FOREIGN KEY (motorista) REFERENCES motorista(codigo),
	PRIMARY KEY (codigo)
)

--1) Criar um Union das tabelas Motorista e ônibus, com as colunas ID (Código e Placa) e Nome (Nome e Marca)			
SELECT CAST(codigo AS VARCHAR(5)) as ID, nome
FROM motorista 
UNION 
SELECT placa as ID, marca as nome
FROM onibus

--2) Criar uma View (Chamada v_motorista_onibus) do Union acima															
CREATE VIEW v_motorista_onibus
AS
SELECT CAST(codigo AS VARCHAR(5)) as ID, nome
FROM motorista 
UNION 
SELECT placa as ID, marca as nome
FROM onibus

--3) Criar uma View (Chamada v_descricao_onibus) que mostre o Código da Viagem, o Nome do motorista, a placa do ônibus (Formato XXX-0000), a Marca do ônibus, o Ano do ônibus e a descrição do onibus	
CREATE VIEW v_descricao_onibus
AS
SELECT via.codigo, mot.nome, SUBSTRING(oni.placa,1, 3) + '-' + SUBSTRING(oni.placa, 4, 7) as placa, oni.marca, oni.ano, oni.descricao
FROM viagem via, motorista mot, onibus oni
WHERE via.onibus = oni.placa AND
	  via.motorista = mot.codigo 

--4) Criar uma View (Chamada v_descricao_viagem) que mostre o Código da viagem, a placa do ônibus(Formato XXX-0000), a Hora da Saída da viagem (Formato HH:00),
--   a Hora da Chegada da viagem (Formato HH:00), partida e destino		
CREATE VIEW v_descicao_viagem
AS
SELECT via.codigo, SUBSTRING(oni.placa,1, 3) + '-' + SUBSTRING(oni.placa, 4, 7) as placa, CAST(via.hora_saida AS VARCHAR(2)) + ':00' as hora_saida, 
		CAST(via.hora_chegada AS VARCHAR(2)) + ':00'as hora_chegada, via.partida, via.destino
FROM viagem via, onibus oni
WHERE via.onibus = oni.placa