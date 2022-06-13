####Os arquivos carregados aqui são os arquivos tratados previamente tanto em R quanto em excel
#A fonte original dos dados pode ser vista nas referências do relatório em pdf

#############Carregamento dos dados iniciais e manipulações finais##########

library(tidyverse)
library(RPostgres)

personagens_total <- read.csv2("Personagens_geral.csv")
colnames(personagens_total) <- c("Id_personagem","Nome-Raw","Sexo","índole","mes_aparicao","ano_aparicao",
                                "Nome","Alcunha","Nome_edit","Nome_grupo")
personagem <- select(personagens_total,c("Id_personagem","Nome","Sexo","Nome_edit","Nome_grupo"))
grupo_principal <- read_csv2("Grupos_herois.csv")
filme_solo <- read_csv2("Filmes_herois.csv") 
editora <- read.csv2("Editora.csv")
editora$Id_personagem[31] = "/wiki/Batman_(Bruce_Wayne)"
editora$Id_personagem[32] = "/wiki/Superman_(Clark_Kent)"

###############Montagem das tabelas de heroi e vilao #####################

heroi <- filter(personagens_total,índole == "Good Characters") %>%
         select(,c("Id_personagem","Alcunha","mes_aparicao","ano_aparicao"))

vilao <- filter(personagens_total,índole == "Bad Characters") %>%
  select(,c("Id_personagem","Alcunha","mes_aparicao","ano_aparicao"))


########### Inserção de dados no Banco de dados ##################

con <- dbConnect(Postgres(),
                 user = "postgres",
                 password = "senha123",
                 host = "localhost",
                 port = 5432,
                 dbname = "personagens_quadrinhos")


##Inserção dos dados na tabela editora
editoradb <- list(c(editora$Nome_edit),
                  c(editora$Id_personagem),
                  c(editora$Ano_fundação)
)

dbExecute(con, "INSERT INTO editora(Nome_edit,Id_personagem,Ano_fundacao)
          VALUES
          ($1, $2, $3)",param = editoradb)


##Inserção dos dados na tabela grupo_principal
grupodb <- list(c(grupo_principal$Nome_grupo),
                c(grupo_principal$Id_personagem),
                c(grupo_principal$hq_estreia),
                c(grupo_principal$ano_estreia))

dbExecute(con, "INSERT INTO grupo_principal(Nome_grupo,Id_personagem,hq_estreia,ano_estreia)
          VALUES
          ($1, $2, $3, $4)",param = grupodb)


##Inserção dos dados na personagem
personagemdb <- list(c(personagem$Id_personagem),
                     c(personagem$Nome),
                     c(personagem$Sexo),
                     c(personagem$Nome_edit),
                     c(personagem$Nome_grupo))

dbExecute(con, "INSERT INTO personagem(Id_personagem,Nome,Sexo,Nome_edit,Nome_grupo)
          VALUES
          ($1, $2, $3, $4, $5)",param = personagemdb)


##Inserção dos dados na tabela heroi
heroidb <- list(c(heroi$Id_personagem),
                c(heroi$Alcunha),
                c(heroi$mes_aparicao),
                c(heroi$ano_aparicao))


dbExecute(con, "INSERT INTO heroi(Id_personagem,alcunha_h,mes_aparicao,ano_aparicao)
          VALUES
          ($1, $2, $3, $4)",param = heroidb)


##Inserção dos dados na tabela vilao
vilaodb <- list(c(vilao$Id_personagem),
                c(vilao$Alcunha),
                c(vilao$mes_aparicao),
                c(vilao$ano_aparicao))


dbExecute(con, "INSERT INTO vilao(Id_personagem,alcunha_v,mes_aparicao,ano_aparicao)
          VALUES
          ($1, $2, $3, $4)",param = vilaodb)


##Inserção dos dados na tabela filme_solo
filmedb <- list(c(filme_solo$Nome_filme),
                c(filme_solo$Metascore),
                c(filme_solo$Ano_lancamento),
                c(filme_solo$Bilheteria),
                c(filme_solo$Id_personagem))

dbExecute(con, "INSERT INTO filme_solo(Nome_filme,Metascore,Ano_lancamento,Bilheteria,Id_personagem)
          VALUES
          ($1, $2, $3, $4, $5)",param = filmedb)


############## Consultas feitas na base de dados e visualizações #############################

### Listar todos os personagens pertencentes a Marvel Comics - Visualização em tabela no tibble correspondente
personagens_marvel <- as_tibble(dbGetQuery(con,
                                           "SELECT * FROM personagem
                                           WHERE nome_edit = 'Marvel Comics'"))


#Listar todos os personagens que não possuem filme solo - Visualização em tabela no tibble correspondente
sem_filme <- as_tibble(dbGetQuery(con,
                                  "SELECT nome,nome_filme FROM personagem as p LEFT JOIN filme_solo as f ON
                                  p.id_personagem = f.id_personagem
                                  WHERE nome_filme IS NULL"))


#Trazer todos os nomes de herois e vilões - Visualização em tabela no tibble correspondente
herois_viloes <- as_tibble(dbGetQuery(con,
                                  "SELECT alcunha_h FROM heroi
                                  UNION
                                  SELECT alcunha_v FROM vilao ORDER BY alcunha_h ASC"))


#Mostrar todos os personagens que participaram de todos os filmes - Visualização em tabela no tibble correspondente
todos_filmes_personagens <- as_tibble(dbGetQuery(con,
                                                 "SELECT nome FROM personagem
                                                  WHERE  NOT EXISTS
                                                  ((SELECT DISTINCT nome_filme FROM filme_solo)
                                                  EXCEPT
                                                  (SELECT nome_filme FROM filme_solo
                                                  WHERE personagem.id_personagem = filme_solo.id_personagem))"))


#Retornar quantos personagens de cada sexo existem por editora e organizar o resultado de forma ascendente
sexo_personagens <- as_tibble(dbGetQuery(con,
                                        "SELECT sexo,COUNT(sexo) as total,nome_edit as editora FROM personagem
                                        GROUP BY sexo,editora
                                        ORDER BY COUNT(sexo) ASC"))

grafico_sexo_personagens <- ggplot(data = sexo_personagens) +
                            geom_col(position = position_dodge(),mapping = aes(x = sexo, y = as.numeric(total),
                            fill = editora)) +
                            labs(x = "Sexo", y = "Total", title = "Personagens de cada sexo por editora",
                                 fill = "") +
                            theme(axis.title = element_text(size = 12, face = "bold"),
                                  plot.title = element_text(face="bold"))
                            
                                  
                           
                            
########## Consultas e visualizações extras ############################

###Número de personagens por editora - visualização em gráfico de colunas
personagem_por_editora <- as_tibble(dbGetQuery(con,
                                         "SELECT nome_edit,COUNT(nome) as total FROM personagem GROUP BY nome_edit"))

grafico_person_editora <- ggplot(data = personagem_por_editora) +
                          geom_col(position = position_dodge(),mapping = aes(x = as.character(nome_edit), y = as.numeric(total),
                          fill = nome_edit)) +
                          labs(x = "Editora", y = "Número de personagens", title = "Personagens por editora",
                          fill = "") +
                          theme(axis.title = element_text(size = 10, face = "bold"),
                          plot.title = element_text(face="bold"),
                          legend.position = "none")
                          


####Bilheteria por ano de lançamento dos filmes - visualização em gráfico de linhas
bilheteria_ano <- as_tibble(dbGetQuery(con,
                                       "SELECT ano_lancamento as ano, SUM(bilheteria) as bilheteria FROM filme_solo
                                       GROUP BY ano_lancamento
                                       ORDER BY ano_lancamento ASC"))

grafico_bilheteria <- ggplot(data= bilheteria_ano, aes(x= as.factor(ano), y= as.numeric(bilheteria), group=1)) +
                      geom_line()+
                      geom_point() +
                      labs(x="Ano",y="Bilheteria") +
                      ggtitle("Bilheteria dos filmes ao longo dos anos") +
                      theme(axis.title = element_text(size = 10, face = "bold"),
                            plot.title = element_text(face="bold"))
                         

####Quantidade de herois surgidos a cada mês, independente do ano - visualização em histograma
herois_meses <- as_tibble(dbGetQuery(con,
                                       "SELECT COUNT(alcunha_h) as herois,mes_aparicao FROM heroi
                                       GROUP BY mes_aparicao
                                       ORDER BY herois ASC"))

grafico_meses_herois <- ggplot(data = herois_meses) +
                      geom_col(position = position_dodge(),mapping = aes(x = mes_aparicao,
                      y = as.numeric(herois),fill = mes_aparicao)) +
                      labs(x = "Meses", y = "Número de herois", title = "Quantidade de heróis surgidos a cada mês",
                      fill = "") +
                      theme(axis.title = element_text(size = 10, face = "bold"),
                            plot.title = element_text(face="bold"),
                            legend.position = "none")



