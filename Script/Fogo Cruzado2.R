# Instalando o pacote crossfire

if (!require("devtools")) install.packages("devtools")
devtools::install_github("library(crossfire)
voltdatalab/crossfire")

Sys.setenv(R_REMOTES_STANDALONE="true")
remotes::install_github("voltdatalab/crossfire")


library(crossfire)
library(ggplot2)
library(geobr)
library(esquisse)
library(dplyr)
library(ggspatial)
library(ggimage)
library(ggthemes)
library(sf)
library(tidyverse)

# Baixando os dados do Instituto Fogo Cruzado
# Para acessar o API, é necessário fazer o login
# Por motivos de privacidade, o login foi omitido
# neste código

# Extraindo os dados do API Fogo Cruzado

data <- get_fogocruzado()

# Transformando os dados em formato data frame

data <- as.data.frame(data)

# Pegando os dados do estado do RJ no pacte geobr
mapa_RJ <- read_state(code_state = 33)

# Pegando os dados dos municípios do RJ

municipios_RJ <- read_municipality(code_muni = 33, year = 2018)

# Plotando o mapa do Rj com os municípios
municipios_RJ %>% 
  ggplot()+
  geom_sf(aes(fill=code_muni))


# Queremos juntar os dados dos pacotes geobr e crossfire
# para visualizarmos graficamente os dados de mortes 
# acumuladas por municípios

# Manipulando os dados geobr e crossfire

# Renomenado a coluna da base da dados do fogo cruzado 
# para juntar com os dados geobr (mapa dos mun?cipios do RJ)

data <- as.data.frame(data) %>% rename(code_muni = cod_ibge_cidade) 

# Para usar a função full_join, precisamos que os datasets
# tenham a mesma coluna. Por isso, vamos renomear a coluna
# do dataset do geobr que contém os mesmos dados shapefile
# do dataset crossfire. Ademais, precisamos mudar a classe
# do conteúdo desta doluna.

data <- as.data.frame(data) %>% 
  rename(code_muni = cod_ibge_cidade) %>% 
  mutate(code_muni = as.numeric(code_muni))

# Mudando a classe da coluna code_muni para num?rico
data <- data %>% mutate(code_muni = as.numeric(code_muni))

# Checando se a classe da coluna code_muni mudou
class(data$code_muni)

# Visualizando os dados geobr dos municípios do RJ
View(municipios_RJ)

# Calculando o número de mortes acumuladas por municípios

mortes_acumuladas <- data %>%
  group_by(code_muni) %>%
  summarise(sum(qtd_morto_civil_ocorrencia))

# Juntando os dados de mortes acumulados e o mapa dos munic?pios do RJ
juntos <- full_join(municipios_RJ, mortes_acumuladas, by = "code_muni")

# Vendo os dados agrpupados de mapa e mortes acumuladas
View(juntos)

# Criando uma nova coluna na base de dados juntos
juntos$categoria <- cut(juntos$mortes_acumuladas, breaks = c(0,5,15,50,100,Inf),
                        labels = c("1 a 5", "6 a 15", "16 a 50", "51 a 100", "Mais de 100"))


# Renomeando a coluna de mortes acumuladas se necessário
juntos <- juntos %>% rename(mortes_acumuladas = `sum(qtd_morto_civil_ocorrencia)`)



ggplot(juntos) + 
  geom_sf(aes(fill=categoria)) +
  scale_fill_manual(values = c('#F3D4D2','#E9A8A2', '#E9635A', '#C41617', '#6A0002'))+
  annotation_scale(location = "br", height = unit(0.2,"cm"))+
  annotation_north_arrow(location = "tl", 
                         style = north_arrow_nautical,
                         height = unit(1.5, "cm"),
                         width = unit(1.5, "cm")) +
  labs(title = "Mortes por Arma de Fogo",
       subtitle = "Fonte: Instituto Fogo Cruzado",
       fill = "",
       x = NULL,
       y = NULL)+
  theme_bw()

# Salvando o gráfico em formato .png

meu.plot_crossfire = ggplot(juntos) + 
  geom_sf(aes(fill=categoria)) +
  scale_fill_manual(values = c('#F3D4D2','#E9A8A2', '#E9635A', '#C41617', '#6A0002'))+
  annotation_scale(location = "br", height = unit(0.2,"cm"))+
  annotation_north_arrow(location = "tl", 
                         style = north_arrow_nautical,
                         height = unit(1.5, "cm"),
                         width = unit(1.5, "cm")) +
  labs(title = "Mortes por Arma de Fogo",
       subtitle = "Fonte: Instituto Fogo Cruzado",
       fill = "",
       x = NULL,
       y = NULL)+
  theme_bw()

ggsave(plot = meu.plot_crossfire, filename = "map_crossfire.png",
       dpi = 400,
       width = 5,
       height = 5)
