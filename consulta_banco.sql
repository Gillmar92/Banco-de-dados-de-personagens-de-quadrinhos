-- Listar todos os personagens pertencentes a Marvel Comics
SELECT * FROM personagem
WHERE nome_edit = 'Marvel Comics' 

-- Listar todos os personagens que não possuem filme solo
SELECT nome,nome_filme FROM personagem as p LEFT JOIN filme_solo as f ON
p.id_personagem = f.id_personagem
WHERE nome_filme IS NULL

-- Trazer todos os nomes de herois e vilões
SELECT alcunha FROM heroi
UNION
SELECT alcunha FROM vilao ORDER BY alcunha ASC

-- Mostrar todos os personagens que participaram de todos os filmes
SELECT nome FROM personagem
WHERE NOT EXISTS
((SELECT DISTINCT nome_filme FROM filme_solo)
EXCEPT
(SELECT nome_filme FROM filme_solo
WHERE personagem.id_personagem = filme_solo.id_personagem))

-- Retornar quantos personagens de cada sexo existem por editora e organizar o resultado de forma ascendente
SELECT sexo,COUNT(sexo),nome_edit FROM personagem GROUP BY sexo,nome_edit
ORDER BY COUNT(sexo) ASC 
