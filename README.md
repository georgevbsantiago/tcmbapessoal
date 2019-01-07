# Pacote tcmbapessoal
Web Scraping para coletar a Folha de Pessoal dos Municípios (BA) armazenados no site do TCM-Ba.

# Sobre a proposta e objetivo do Web Scraping

O presente Web Scraping tem o objetivo de obter os dados da Folha de Pessoal dos Municípios da Bahia, por meio do site do Tribunal de Contas dos Municípios do Estado da Bahia (TCM-Ba), visto que os dados ainda não são disponibilizados no formato de Dados Abertos, conforme impõe a Lei de Acesso à Informação (art. 8º, §3°, III, da LAI). Em vista disso, foi necessário produzir um Web Scraping para obter os dados disponibilizados no site do TCM-Ba em formato HTML (Ver [link do TCM-Ba](http://www.tcm.ba.gov.br/portal-da-cidadania/pessoal/)) de forma sistêmica e automatizada, reduzindo significativamente o tempo que se levaria para obter os dados caso as consultas fossem feitas manualmente.


## Sobre o Código do Web Scraping em Linguagem R

O código do *Web Scraping - Folha de Pessoal dos Municípios da Bahia via TCM-Ba* apesar de estar operacional, ainda faltam implementações (as quais serão mais detalhadas abaixo).

O código foi desenvolvido para ambiente **Windows 10**, com a versão *3.5.1* do R. Apesar do código ter sido desenvolvido para funcionar em **Linux**, ainda não foram realizados testes.


## Etapas e Estratégias do Web Scraping

Para realizar com sucesso o presente Web Scraping, foi preciso mapear as etapas que serão pecorridas pelo Web Scraping, as quais podem ser sintetizadas da seguinte forma:

1° - Realizar uma requisição POST no [link do TCM-Ba](http://www.tcm.ba.gov.br/portal-da-cidadania/pessoal/) por meio da qual é possível consultar manualmente a folha de pessoal dos municípios do Estado da Bahia;
2° - Após realizada a requisição POST com os dados do Município, Entidade e Ano, procedemos a coleta dos dados da tabela que contém os dados da Folha de Pessoal, na qual são registradas informações sobre Nome do Servidor Público; N° matrícula; Tipo Servidor; Cargo; Salário Base; Salário Vantagens e Salário Gratificação. Ainda nessa etapa, precisamos incluir algumas informações adicionais para faciliar o armanezamento e futura análise dos dados, a exemplo das seguintes colunas: Ano, Mês, Código do Município, Nome do Município, Código da Entidade e Nome da Entidade.
3º - Obtido os dados, realizamos o seu tratamento, com o objetivo de auxiliar as futuras análises dos dados. Nessa fase, todas as letras foram transformadas em maiúsculas e retirado a acentuação das palavras.

Como estratégia na obtenção dos dados, optamos por armazenar os arquivos HTML das requisições, com vista a poder reproduzir a etapa de tratamento e limpeza dos dados, caso fosse necessário, visto o número de requisições que seriam realizas (cerca de 30.000).

## Estrutura do Código em Linguagem R do Web Scraping

Pré-Scraping Principal:
1 - Criar Diretório, Banco de Dados e Tabelas do BD;
2 - Obter o Código e Nome dos Municípios no site do TCM-Ba e Criar uma Tabela com esses dados;
3 - Obter o Código e Nome das Entidades Municipais (Prefeitura, Câmara de Vereadores...) no Web Service do TCM-Ba e, por fim, consolidar todos os dados (código e nomes) dos Municípios e Entidades Municipais em uma só Tabela
4 - Gerar uma Tabela de Requisições para relizar as consultar no site do TCM-Ba via método POST;

Scraping:
5 - Scraping dos Dados de cada entidade municipal em determinado ano e mês;

Tratamento dos Dados:
6 - Data Wrangling (tratamento) dos dados obtidos via Web Scraping do site do TCM-Ba;

Upload para o Google Drive:
7 - Upload dos arquivos (CSV) para o Google Drive para diponibilização do BD ao público:


# BUGS e Melhorias

1º - Resolver o problema do progressivo consumo de memória durante o tratamento dos arquivos HTML para CSV;

2º - Criar um arquivo .R para armazenar todas as hipóteses de rotinas de erro

3º - Tornar o código agnóstico de Banco de Dados relacional

4º - Agregar possíveis insights aplicados no pacote RCrawler

5º - Aprimorar elementos da Documentação

Outras Melhorias:
!!!Criar um loop seguro para a função salvar_html de erros ao salvar o artquivo hmtl por ser muito grande (maior que 260 caracteres) ou por ter um conteúdo vazio

!!! Tentar desenvolver um contador para visualizar o progresso do Web Scraping

!!! Criar uma regra para criação do Banco de Dados e Outra para Conexão do Banco de Dados

!!! Analisar a vantagem de regisrar o caminho do diretório principal em uma tabela do Banco de Dados,
Assim como outras informações como o nome do Web Scraping. Data de Criação, Escopo... dentre outros metadados

!!! Verificar o comportamento da função readr::parse_number que está na função valor_nometario em utils:
> readr::parse_number("R$ 321.200,35", locale = readr::locale(grouping_mark = ".", decimal_mark = ","))
[1] 321200.3
> readr::parse_number("R$ 31.200,35", locale = readr::locale(grouping_mark = ".", decimal_mark = ","))
[1] 31200.35
> readr::parse_number("R$ 3.312.200,35", locale = readr::locale(grouping_mark = ".", decimal_mark = ","))
[1] 3312200