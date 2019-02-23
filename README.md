# O Projeto

O pacote `tcmbapessoal` é uma das ferramentas utilizadas no projeto de "Transparência das Contas Públicas", desenvolvido e executado pelo Observatório Social do Brasil - Município de Santo Antônio de Jesus - Estado da Bahia.

## Sobre a proposta e o objetivo do pacote

O objetivo do pacote `tcmbapessoal` é obter/capturar os dados da Folha de Pessoal dos Municípios da Bahia, custodiados e disponibilizados publicamente no site do Tribunal de Contas dos Municípios do Estado da Bahia (TCM-Ba - [link do TCM-Ba](http://www.tcm.ba.gov.br/portal-da-cidadania/pessoal/). Para tanto, foi aplicado uma técnica denominada "Web Scraping" para 'capturar' os dados no formato de arquivo eletrônico HTML e, após o seu tratamento e modelagem, consolidar todos os dados num formato *legível por máquina* que permita a sua utilização em ferramentas de análise de dados como Excel, Power Bi, Qlik, Tableau, RStudio... dentre outras.

Todo o esforço empregado no desenvolvimento desta ferramenta tem como motivação o propósito de tornar o conteúdo das Contas Públicas mais acessíveis ao cidadão, ao capturar dados e, em seguida, aplicar técnicas de visualização que permitam a qualquer pessoa obter respostas a partir de perguntas simples como, por exemplo: Qual são os servidores do ente municipal (prefeitura, câmara e entidades da adm. indireta)? Quais servidores têm as maiores remunerações na Folha de Pessoal do ente municipal (prefeitura, câmara e entidades da adm. indireta)? Qual é o ranking de remuneração dos prefeitos? Qual a proporção entre cargo efetivo, comissionado, servidores temporários... ao comparar a Folha de Pessoal dos entes municipais (prefeitura, câmara e entidades da adm. indireta)?

Além disso, parte do esforço empregado no desenvolvimento desta ferramenta é motivado pelo fato de que o TCM-Ba ainda não disponibiliza os dados municipais custodiados no formato de Dados Abertos (apesar de ter um excelente Portal de Transparência dos Dados Municipais). Na oportunidade, cabe esclarecer que há uma diferença substancial (de propósito e de finalidade jurídica) entre *Portal de Transparência* e *Portal de Dados Abertos*. Enquanto o Portal de Transparência visa disponibilizar o acesso de informações com foco em dados _legíveis por Humanos_, o Portal de Dados Abertos visa disponibilizar dados _legíveis por máquinas_  (computadores) que facilitarão a produção de conteúdo e conhecimento (relatórios, gráficos, grafos...) para Humanos. Ou seja, embora Portal de Transparência e Portal de Dados Abertos tenham como objetivo maximizar a Transparência dos dados Governamentais, são ferramentas complementares e, por isso, não se confundem. Além disso, numa perspectiva jurídica, cabe pontuar que o Portal de Transparência, assim como o Portal de Dados Abertos, tem fundamento jurídico específicos na Constituição Federal de 1988, na Lei de Responsabilidade Fiscal (Lei n.° 101/2000) e na Lei de Acesso à Informação (Lei n.º 12.527/2011), logo, é dever/obrigação dos entes públicos implementarem as duas funcionalidades para concretizar ao máximo o princípio da publicidade.

Nesse contexto, entretanto, cabe informar que após interlocução do Observatório Social do Brasil - Município de Santo Antônio de Jesus com o TCM-Ba (por meio de ofício e eventos institucionais) foi sinalizado que o desenvolvimento de um Portal de Dados Abertos, haja vista a sua relevância para a Sociedade.

Com isso, o TCM-Ba, assim como outros Entes Governamentais e Tribunais de Contas do Brasil, consolidam a sua postura de parceria e colaboração com o exercício do Controle Social da Administração Pública. Nesse contexto, assim que o site de Portal de Dados Abertos do TCM-Ba for lançado, o desenvolvimento do presente pacote se tornará desnecessário. Até lá, o seu desenvolvimento será extremamente necessário para viabilizar maior transparência e acesso das despesas dos municípios do Estado da Bahia.

## Propósito do Web Scraping para o OS-SAJ

Ao fim da execução do "Web Scraping", são gerados arquivos ".csv" com os dados da Folha de Pessoal coletados e tratados dos municípios do estado da Bahia.

No caso do Observatório Social de Santo Antônio de Jesus, esses dados serão utilizados para alimentar o [Painel de Monitoramento da Folha de Pessoal dos Municípios do Estado da Bahia](https://goo.gl/4zHpZp). Contudo, disponibilizaremos a base de dados por meio do link para que qualquer interessado possa realizar suas próprias análises.


## Etapas e Estratégias do Web Scraping

Como citado no material disponibilizado pelo do [Curso-R](https://www.curso-r.com/material/webscraping/), há 4 (quatro) tipos de "macro 'desafios' de Web Scraping" que exigem estratégias e técnicas distintas, a saber:

* Uma busca e uma paginação;
* Uma busca e muitas paginações;
* Muitas buscas e uma paginação por busca;
* Muitas buscas e muitas paginações por busca.

Os dois primeiros "macro desafios de Web Scraping" são os mais "fáceis", não exigindo maiores técnicas ou estratégias, especificamente no controle das requisição das páginas HTML. Já os dois últimos, podem representar grandes desafios no desenvolvimento do "Web Scraping", em especial no controle das requisição das páginas HTML, a depender, por exemplo: _i)_ do volume (quantidade) de requisições a serem realizadas; _ii)_ de como o Servidor requisitado se comporta com o crescente número de requisições; _iii)_ das estratégias de controle a serem adotadas para não obter dados duplicados ou "esquecer" de raspar determinadas páginas; _iv)_ da infraestrutura que será utilizada para executar o Web Scraping... dentre outros desafios enfrentados a depender do caso concreto.

No caso do "Web Scraping" em apreço, estaremos enfrentado o Web Scraping de razoável desafio técnico *Muitas buscas e uma paginação por busca*, pelo menos do ponto de vista da arquitetura de execução do código.

A título de exemplo, obter a Folha de Pessoal das cerca de 900 Unidades Jurisdicionadas do TCM-Ba (entidades da administração municipal direta e indireta) que prestam contas, referente ao exercício de 2018, chegamos ao número aproximado de 10.800 requisições ao site do TCM-Ba! A partir desta informação, ao considerar que o tempo médio de cada requisição gira em torno de 4 segundos, o Web Scraping demorará cerca de 12 horas para obter todos os dados.

Por outro lado, caso o TCM-Ba adote o Portal de Dados Abertos, obter esse volume de informação demore somente alguns minutos, pois exigirá apenas alguns clicks do usuários para obter os dados tratados e no formato adequado para utilização em ferramentas de análise como o Excel, Power Bi, Qlik, Tableau, RStudio... dentre outras.


## Estrutura do Código em Linguagem R do Web Scraping

Numa perspectiva de arquitetura das etapas e de organização dos arquivos .R, as funções para execução do código foram divididas em 17 arquivos .R, a saber:

`01_executar_web_scraping.R` - É o 'orquestrador' de toda a execução do código. É este arquivo que contém a função que executará as funções numa ordem lógica e predefinida para obter o resultado final, ou seja: Os dados da Folha de Pessoal dos municípios disponíveis em um formato legível por máquina.

`02_criar_diretorios.R` - Cria a estrutura de diretórios na pasta de trabalho (Work Directory) definida pelo usuário.

`03_criar_ws_id.R` - Cria uma arquivo .rds com metadados do Web Scraping. Além disso, serve para identificar a pasta de trabalho (Work Directory) do Web Scraping.

`04_connect_sgbd.R` - Cria a conexão para o Sistema Gerenciador do Banco de Dados e, também, por padrão, cria o arquivo do Banco de Dados do SQLite.

`05_criar_tabelas_bd.R` -  Cria as tabelas no Banco de Dados.

`06_criar_tb_dcalendario.R` - Cria a tabela 'tabela_dcalendario' no BD  (uma tabela dimensão, numa perspectiva do conceito de Business Intelligence - BI), para ser utilizada tanto na confecção das tabelas de requisição, como para construir e manter a tabela a ser utilizada no BI (Power BI a Microsoft) que utilizados no painel de análise.

`07_criar_tb_dmunicipios.R` - Cria a tabela 'tabela_tcm_dmunicipios' no BD (uma tabela dimensão, numa perspectiva do conceito de Business Intelligence - BI), para ser utilizada tanto na confecção das tabelas de requisição, como para construir e manter a tabela a ser utilizada no BI (Power BI a Microsoft) que utilizados no painel de análise.

`08_criar_tb_dmunicipios_entidades.R` - Cria a tabela 'tabela_tcm_dmunicipios_entidades' (uma tabela dimensão, numa perspectiva do conceito de Business Intelligence - BI), para ser utilizada tanto na confecção das tabelas de requisição, como para construir e manter a tabela a ser utilizada no BI (Power BI a Microsoft) que utilizados no painel de análise.

`09_criar_tb_requisicoes.R` - Cria a tabela 'tabela_requisicoes' no BD que controlará as requisições.

`10_scraping_html_folhapessoal.R` - Realiza a execução do "Web Scraping" responsável por obter as páginas com os dados da Folha de Pessoal.

`11_data_wrangling_html.R` - Transmuta os dados do arquivo HTML para o formato 'Tidy Data' e armazena em arquivos CSV, com vista a possibilitar a importação dos dados para qualquer software de análise de dados. 

`12_backup_arquivos.R` -  Realiza o Backup dos dados.

`13_exportar_dropbox.R` - Exporta os dados tratados para o DropBox com o objetivo de alimentar a ferramenta de BI ou disponibilizar os dados à Sociedade.

`14_utils.R` - Arquivo que contém diversas funções confeccionadas para utilizar durante a execução do Web Scraping.


## Outros objetivos/propósitos técnicos do Web Scraping

1 - Empregar um comportamento de Web Scraping, em vez de Web Crawler.

2 - Tornar o Web Scraping autônomo e que não pare devido a exceções após ser executado.

3 - Tornar o Web Scraping executável por aplições de automação/tarefas como Cron do Linux.

4 - Tornar o Web Scraping agnóstico de Sistema de Banco de Dados Relacional (pelo menos, aceite o SQLite e MySQL).

5 - Tornar o Web Scraping reprodutível em um ambiente RStuido implantado via Docker

6 - Exportar o resultado do Scraping para um repositório público (ex: DropBox) para que qualquer pessoa possa baixar os dados.

7 - Desenvolver um ChatBot no Telegram para sinalizar ao mantenedor do Web Scraping quando ele inicia e termina, ou quando ocorre um erro que interrompe a execução. (em desenvolvimento)


# Comunidade e Colaboração

O Observatório Social do Brasil, aqui representado pelo Observatório Social do Município de Santo Antônio de Jesus - Ba, gostaria de agradecer ao apoio da Comunidade R para o desenvolvimento do presente pacote, em especial à comunidade [TidyVerse]("https://www.tidyverse.org/), ao [Curso-R](https://www.curso-r.com/) pela colaboração ativa e material disponibilizado, à comunidade R Brasil (no Telegram), e todos aqueles de disponibilizam ebook sobre a linguagem R [link](https://bookdown.org/), posts e desenvolvem pacotes e soluções de infraestrutura para a linguagem R. Sem o esforço, colaboração, cooperativismo e abnegação de todos, esse trabalho não seria possível.

Ademais, quaisquer sugestões, reclamações ou críticas podem ser realizadas no área `issues` do GitHub.


# BUGS e Melhorias

Sabemos que o código disponibilizado na versão 1.0 pode ser melhorado e otimizado a sua performance. Contudo, até onde testamos, os resultados obtidos mostraram-se consistentes ao objetivo final que é alimentar o 'Painel de Monitoramento das Despesas dos Municípios do Estado da Bahia', que tem o acesso disponibilizado a qualquer pessoa por meio do site do Observatório Social de Santo Antônio de Jesus.

Entretanto, registramos os seguintes tópicos para relatar: Prioridades, Bugs, Melhorias, Implementações, Ajuste na Infraestrutura... do código:

```{r eval=FALSE, include=FALSE}

### MELHORIAS:

# !!!Criar um loop seguro para a função salvar_html de erros ao salvar o artquivo html por ser muito grande (maior que 260 caracteres) ou por ter um conteúdo vazio.


# !!! Revisar a rotina que retorna TRUE ou FALSE na variável 'detectar_tabela' da função 'scraping_html_folhapessoal'
#     verificar se é melhor permanecer com o teste is.na() ou trocar por isTRUE() ou outra função

# !!! Analisar a questão do uso progressivo da memória RAm no Windows (no Linux, isso não ocorre)
#     durante a execução da função 'data_wrangling_html_pessoal'. Foi colocado a rotina (abaixo),
#     mas parece que não surtiu efeito.
#         # Liberar memória
#         # Há uma leve perda de performance
#         rm(list = ls())
#         gc(reset = TRUE)
        
# !!! Verificar se ao predefinir o tipo da coluna da tabela, há ganho de performace 
#     na rotina 'pegar_dados_html' da função 'data_wrangling_html_pessoal'

# !!! Verificar se a rotina de tratamento de erro na função tcmbapessoal::connect_sgbd(sgbd) possibilita
#     acabar com as rotinas de While, já que a função nunca falharia devido a rotina de tcmbapessoal::connect_sgbd(sgbd)
    
# !!!
# Error in (function (classes, fdef, mtable)  : 
#   unable to find an inherited method for function ‘dbWriteTable’ for signature ‘"SQLiteConnection", "character"’
  


```


# Preparando e Executando o pacote `tcmbapessoal`

## Infraestrutura

Caso o usuário deseje executar o  "Web Scraping" do seu computador pessoal, precisará apensas seguir a sugestão de nomenclattura dos arguimentos abaixo:

```{r eval=FALSE, include=FALSE}

# Instalar o pacote:
devtools::install_github("georgevbsantiago/tcmbapessoal")

library(tcmbapessoal)

# Selecionar a pasta de trabalho (Work Directory) que será armazenado os dados coletados pelo 'Web Scraping'.
setwd("/home/rstudio/os_saj_web_scraping")

tcmbapessoal::executar_web_scraping(ano_inicio = 2018,
                                    nome_scraping = "ws_tcmba_pessoal",
                                    sgbd = "sqlite",
                                    repetir = "SIM",
                                    backup_local = "SIM",
                                    backup_nuvem = "NAO",
                                    exportar_nuvem = "NAO")


```


Na hipótese do usuário preferir contratar um servidor numa infraestrutura de nuvem (ex: DigitalOcean, Microsoft Azure, Amazon Web Service), indicamos, a seguir, algumas dicas e condigurações para implementação do RStudio via Docker.

Nesta sugestão de configuração via VPS na DigitalOcean usando Docker, realizamos a instalação do Cointainer do Projeto Rocker [link](https://hub.docker.com/r/rocker/tidyverse) (que agrupa: Compilador R; pacote TidyVerse; e Rstudio). Para obter mais detalhes sobre a configuração de implementação do "droplet" (nomenclatura de 'servidor' na DigitalOcean), indicamos como fonte de consulta o post: ['Run on a remote server'](https://www.andrewheiss.com/blog/2017/04/27/super-basic-practical-guide-to-docker-and-rstudio/) .

As demais configurações sobre o 'Volume' (conceito do Docker que significa a pasta - diretório - compartilhado entre o 'container' Docker e o Host 'servidor') e as configurações de permissão para criação, leitura e escrita do diretório 'os_saj_web_scraping' (nome do diretório de trabalho escolhido pelo OS-SAJ), foram obtidos por meio de consulta no Google. OBS: A configuração de escrita no diretório 'os_saj_web_scraping', que será utilizado como diretório de trabalho do 'Web Scraping', foi necessário, pois caso não seja realizado, o RStudio retorna um erro que informa a impossibilidade de escrever/gravar/modificar os arquivos no diretório selecionado para ser o 'Volume'.

------------------ Pré-Configuração do Container Docker do Rstudio na Digital Ocean ------------------

```{r eval=FALSE, include=FALSE}

#cloud-config
runcmd:

docker run -d -t -p 8787:8787 --name=web_scraping_ossaj -e ROOT=TRUE -e PASSWORD=senhadoUsuario -v /home/rstudio/os_saj_web_scraping:/home/rstudio/os_saj_web_scraping rocker/tidyverse
  
sudo chgrp -R rstudio /home/rstudio/os_saj_web_scraping

sudo chmod -R 770 /home/rstudio/os_saj_web_scraping

```
_________________________________________________________________________________________________________

------------------ Configuração do Container Docker do Rstudio no Shell do Linux ------------------

```{r eval=FALSE, include=FALSE}


# Implantar um container com pasta Volume (3 etapas):

docker run -d -t -p 8787:8787 --name=web_scraping_ossaj -e ROOT=TRUE -e PASSWORD=senhadoUsuario -v /home/rstudio/os_saj_web_scraping:/home/rstudio/os_saj_web_scraping rocker/tidyverse

docker exec -d web_scraping_ossaj sudo chgrp -R rstudio /home/rstudio/os_saj_web_scraping

docker exec -d web_scraping_ossaj sudo chmod -R 770 /home/rstudio/os_saj_web_scraping

```

Após implementar o VPS do RStudio via Docker na DigitalOcean com as diretrizes indicadas acima, será necessário instalar o pacote `tcmbapessoal`por meio do comando: `devtools::install_github("georgevbsantiago/tcmbapessoal")`. Concluída a instalção, basta executar o Web Scraping com o exemplo de código demonstado acima.
