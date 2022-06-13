-- Criação do Banco de Dados foi feita com o seguinte comando:
-- CREATE database personagens_quadrinhos

-- Criação das tabelas presentes no Banco de Dados

CREATE TABLE personagem (
	id_personagem VARCHAR(50) NOT NULL,
	nome VARCHAR(80),
	sexo VARCHAR(6),
	nome_edit VARCHAR(20),
	nome_grupo VARCHAR(50),
	CONSTRAINT personagem_pk PRIMARY KEY (id_personagem),
	CONSTRAINT sexo_check CHECK (sexo in ('Masc','Fem','Fluido')),
	CONSTRAINT editora_check CHECK (nome_edit in ('Marvel Comics','DC Comics'))
);

CREATE TABLE heroi(
	id_personagem VARCHAR(50) NOT NULL,
	alcunha_h VARCHAR(50),
	mes_aparicao VARCHAR(50),
	ano_aparicao INT,
	CONSTRAINT heroi_pk PRIMARY KEY (id_personagem)
);

CREATE TABLE vilao(
	id_personagem VARCHAR(50) NOT NULL,
	alcunha_v VARCHAR(50),
	mes_aparicao VARCHAR(20),
	ano_aparicao INT,
	CONSTRAINT vilao_pk PRIMARY KEY (id_personagem)
);

CREATE TABLE grupo_principal(
	nome_grupo VARCHAR(100),
	id_personagem VARCHAR(50) NOT NULL,
	hq_estreia VARCHAR(100),
	ano_estreia INT,
	CONSTRAINT grupo_pk PRIMARY KEY (nome_grupo,id_personagem)
);

CREATE TABLE editora (
	nome_edit VARCHAR(15) NOT NULL,
	id_personagem VARCHAR(50) NOT NULL,
	ano_fundacao INT,
	CONSTRAINT editora_pk PRIMARY KEY (nome_edit,id_personagem)
);

CREATE TABLE filme_solo(
	nome_filme VARCHAR(100) NOT NULL,
	ano_lancamento INT,
	bilheteria INT,
	metascore SMALLINT,
	id_personagem VARCHAR(50),
	CONSTRAINT filme_pk PRIMARY KEY (nome_filme),
	CONSTRAINT meta_check CHECK (metascore > 0 AND metascore <= 100)
);

/* Definição das chaves estrangeiras */
ALTER TABLE personagem ADD CONSTRAINT nome_edit_fk FOREIGN KEY (nome_edit,id_personagem)
	REFERENCES editora(nome_edit,id_personagem) ON DELETE CASCADE;
	
ALTER TABLE personagem ADD CONSTRAINT nome_grupo_fk FOREIGN KEY (nome_grupo,id_personagem)
	REFERENCES grupo_principal(nome_grupo,id_personagem) ON DELETE CASCADE;
		
ALTER TABLE filme_solo ADD CONSTRAINT personagem_filme_fk FOREIGN KEY (id_personagem)
	REFERENCES personagem(id_personagem) ON DELETE CASCADE;
	
	