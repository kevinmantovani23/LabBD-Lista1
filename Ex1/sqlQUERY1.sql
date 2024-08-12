CREATE DATABASE faculdade

USE faculdade

CREATE TABLE aluno (
	ra			INT		 NOT NULL,
	nome		VARCHAR(100)	NOT NULL,
	idade		INT		NOT NULL	CHECK (idade > 0),
	PRIMARY KEY (ra)
)

CREATE TABLE disciplina (
	codigo		INT			 NOT NULL,
	nome		VARCHAR(80)	 NOT NULL,
	carga_horaria	INT		CHECK (carga_horaria >= 32),
	PRIMARY KEY (codigo)
)

CREATE TABLE curso (
	codigo		INT		NOT NULL,
	nome		VARCHAR(50) NOT NULL,
	area		VARCHAR(100),
	PRIMARY KEY (codigo)
)

CREATE TABLE titulacao (
	codigo		INT		NOT NULL,
	titulo		VARCHAR(40) NOT NULL,
	PRIMARY KEY (codigo)
)

CREATE TABLE professor (
	registro		INT		NOT NULL,
	nome		   VARCHAR(100) NOT NULL,
	titulacao		INT,
	FOREIGN KEY (titulacao) REFERENCES titulacao(codigo),
	PRIMARY KEY (registro)
)

CREATE TABLE disciplina_professor (
	disciplinaCodigo	INT		NOT NULL,
	professorRegistro	INT		NOT NULL,
	FOREIGN KEY (disciplinaCodigo) REFERENCES disciplina(codigo),
	FOREIGN KEY (professorRegistro) REFERENCES professor(registro),
	PRIMARY KEY (disciplinaCodigo, professorRegistro)
)

CREATE TABLE curso_disciplina (
	cursoCodigo			INT	NOT NULL,
	disciplinaCodigo	INT	NOT NULL,
	FOREIGN KEY (disciplinaCodigo) REFERENCES disciplina(codigo),
	FOREIGN KEY (cursoCodigo) REFERENCES curso(codigo),
	PRIMARY KEY (disciplinaCodigo, cursoCodigo)
)

CREATE TABLE aluno_disciplina (
	alunoRA				INT NOT NULL,
	disciplinaCodigo	INT	NOT NULL,
	FOREIGN KEY (disciplinaCodigo) REFERENCES disciplina(codigo),
	FOREIGN KEY (alunoRA) REFERENCES aluno(ra),
	PRIMARY KEY (disciplinaCodigo, alunoRA)
)

--Item 1: Fazer uma pesquisa que permita gerar as listas de chamadas, com RA e nome por disciplina

CREATE VIEW viewChamada
AS
	SELECT al.ra, al.nome as nomeAluno, dis.nome as nomeDisciplina
	FROM aluno al, disciplina dis, aluno_disciplina ald
	WHERE al.ra = ald.alunoRA AND
		  dis.codigo = ald.disciplinaCodigo

SELECT * FROM viewChamada
--Item 2: Fazer uma pesquisa que liste o nome das disciplinas e o nome dos professores que as ministram	

CREATE VIEW viewProfDisc
AS
	SELECT dis.nome as nomeDisciplina, prof.nome as nomeProfessor
	FROM disciplina dis, professor prof, disciplina_professor dprof
	WHERE dis.codigo = dprof.disciplinaCodigo AND
		  prof.registro = dprof.professorRegistro

SELECT * FROM viewProfDisc

--Item 3: Fazer uma pesquisa que , dado o nome de uma disciplina, retorne o nome do curso

CREATE VIEW viewNomeCurso
AS
	SELECT cur.nome as nomeCurso, disc.nome as nomeDisciplina
	FROM curso cur, disciplina disc, curso_disciplina cud
	WHERE cur.codigo = cud.cursoCodigo AND
		  disc.codigo = cud.disciplinaCodigo
		  
SELECT nomeCurso
FROM viewNomeCurso
WHERE nomeDisciplina = ' '

--Item 4: Fazer uma pesquisa que , dado o nome de uma disciplina, retorne sua área

CREATE VIEW viewArea
AS
	SELECT cur.area as areaCurso, disc.nome as nomeDisciplina
	FROM curso cur, disciplina disc, curso_disciplina cud
	WHERE cur.codigo = cud.cursoCodigo AND
		  disc.codigo = cud.disciplinaCodigo	

SELECT areaCurso 
FROM viewArea
WHERE nomeDisciplina = ' '

--Item 5: Fazer uma pesquisa que , dado o nome de uma disciplina, retorne o título do professor que a ministra

CREATE VIEW viewProfMinistra
AS
	SELECT titu.titulo, disc.nome as nomeDisciplina
	FROM titulacao titu, professor prof, disciplina disc, disciplina_professor dprof
	WHERE dprof.professorRegistro = prof.registro AND
		  disc.codigo = dprof.disciplinaCodigo AND
		  titu.codigo = prof.titulacao

SELECT titulo
FROM viewProfMinistra
WHERE nomeDisciplina = ' '

--Item 6: Fazer uma pesquisa que retorne o nome da disciplina e quantos alunos estão matriculados em cada uma delas

CREATE VIEW viewQtdAlunoDisc
AS
	SELECT disc.nome as nomeDisciplina, COUNT(aludisc.alunoRA) as quantidadeAlunos
	FROM disciplina disc, aluno_disciplina aludisc
	WHERE disc.codigo = aludisc.disciplinaCodigo
	GROUP BY disc.nome

SELECT * FROM viewQtdAlunoDisc

--Item 7: Fazer uma pesquisa que, dado o nome de uma disciplina, retorne o nome do professor.  Só deve retornar de disciplinas que tenham, no mínimo, 5 alunos matriculados

SELECT vpd.nomeProfessor
FROM viewProfDisc vpd, disciplina disc
WHERE disc.nome = vpd.nomeDisciplina AND
	  disc.nome = ' ' AND
	  disc.codigo IN
	  (
		SELECT disc.codigo
		FROM disciplina disc, aluno_disciplina aldisc
		WHERE disc.codigo = aldisc.disciplinaCodigo
		GROUP BY disc.codigo
		HAVING COUNT(aldisc.alunoRA) >= 5
	  )

--Item 8: Fazer uma pesquisa que retorne o nome do curso e a quatidade de professores cadastrados que ministram aula nele. A coluna de ve se chamar quantidade

CREATE VIEW viewQtdProf
AS
	SELECT cur.nome as nomeCurso, COUNT(DISTINCT vpd.nomeProfessor) as quantidade 
	FROM curso cur, viewProfDisc vpd, curso_disciplina curdi, disciplina disc
	WHERE cur.codigo = curdi.cursoCodigo AND
		  disc.codigo = curdi.disciplinaCodigo AND
		  vpd.nomeDisciplina = disc.nome
	GROUP BY cur.nome

SELECT * FROM viewQtdProf