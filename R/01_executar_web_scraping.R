#' @title Função que executa o Web Scraping
#'
#' @description Essa função foi desenvolvida para executar todas as etapas do Web Scraping
#' e, então, coletar os dados públicos da Folha de Pessoal dos Municípios do Estado da Bahia
#' custodiados no site do TCM-Ba
#' 
#' @param anos Exercíico (ano) inicial da coleta de dados
#' @param nome_scraping Nome do Diretório que será criado para alocar os dados do Web Scraping
#' @param repetir É definido "SIM" como padrão. Mas pode ser marcado como "NAO",
#' caso não deseje repetir as consulta do Web Scraping que falharam ou que não foram
#' identificadas resposta do ente municipal no dia de execução do Web Scraping
#' @param backup_local É definido como "SIM" como padrão para realizar
#' o Backup do Banco de Dados e dos arquivos HTML e CSV.
#' Mas pode ser marcado como "NAO". 
#' @param backup_nuvem Realiza o Backup dos dados para o DropBox. Como padrão, é definido "NAO".
#' Obs: É preciso configurar o token do DropBox antes de executar
#' (ver instruções na função 'exportar_csv_dropbox').
#' @param sgbd Define qual é o Banco de Dados a ser utilizado.
#' Por padrão, é definido o SQLite.
#' 
#' @examples 
#' \dontrun{
#' tcmbapessoal::executar_web_scraping(ano = 2018,
#'                                     nome_scraping = "ws_tcmba_pessoal",
#'                                     sgbd = "sqlite",
#'                                     repetir = "SIM",
#'                                     backup_local = "SIM",
#'                                     backup_nuvem = "NAO")
#'}
#'
#'
#' @export

executar_web_scraping <- function(anos, nome_scraping, sgbd = "sqlite",
                                  repetir = "SIM", backup_local = "SIM",
                                  backup_nuvem = "NAO") {

  
  # Etapas de padronização dos argumentos preenchidos pelo usuário
  anos <- as.integer(anos)
  nome_scraping <- as.character(nome_scraping)
  sgbd <- stringr::str_to_lower(as.character(sgbd))
  repetir <- stringr::str_to_upper(as.character(repetir))
  backup_local <- stringr::str_to_upper(as.character(backup_local))
  backup_nuvem <- stringr::str_to_upper(as.character(backup_nuvem))

  
  # Etapas de verificação dos argumentos preenchidos pelo usuário
            if(length(anos) > 1){
              
              stop("Informe o ano de início do Web Scraping: 2016, 2017, 2018 ou 2019")
              
            }
      
            if(!anos %in% c(2016, 2017, 2018, 2019)){

              stop("Informe um dos seguintes anos: 2016, 2017, 2018 ou 2019")

            }

                  
            if(nome_scraping == "") {

              stop("Defina uma nome para o Scraping")
            }
                  

            if(stringr::str_detect(nome_scraping, "[*//={}]") == TRUE) {

              stop("Não utilize os caracteres inválidos no nome do Scraping")
            }
            


            if(!sgbd %in% c("sqlite", "mysql")) {

              stop("Digite o SQLite ou o MySql para conectar ao Banco de Dados")
            }


            if(!repetir %in% c("SIM", "NAO")) {

              stop("Digite SIM ou NAO para o argumento 'repetir' da função")
            }


            if(!backup_local %in% c("SIM", "NAO")) {

              stop("Digite SIM ou NAO para o argumento 'backup_local' da função")
            }
  
            if(!backup_nuvem %in% c("SIM", "NAO")) {
              
              stop("Digite SIM ou NAO para o argumento 'backup_nuvem' da função")
            }

    
    # Função que cria as pastas dos arquivos e define o diretório Raiz
    tcmbapessoal::criar_diretorios(nome_scraping)
    

    # Rotina para verificar se o Web Scraping está executando pela primeira vez, ou se é uma continuação.
    # !!! Mudar essa rotina para algo mais genérico que seja aceito no SQLite e no MySQL
    if (file.exists(file.path("bd_sqlite", "bd_tcm_folha_pessoal_municipios.db")) == FALSE) {

          # Função que cria o Banco de Dados
            tcmbapessoal::criar_bd(sgbd)
      
          # Função que cria 5 tabelas no Banco de Dados.
            tcmbapessoal::criar_tabelas_bd(sgbd)
    }
     

      # Função que cria a tabela dCalendario
      tcmbapessoal::criar_tb_dcalendario(anos, sgbd)
      
      # Função que faz o Web Scraping do código e nome dos Municípios
      tcmbapessoal::criar_tb_dmunicipios(sgbd)
      
      # Função que obtém o código e nome das Entidades via Web Service
      tcmbapessoal::criar_tb_dmunicipios_entidades(sgbd)
      
      # Função que cria a tabela das requisições
      tcmbapessoal::criar_tb_requisicoes_pessoal(sgbd)
      
      # Função que faz o Web Scraping das páginas HTML que contêm os dados da Folha de Pessoal.
      # Obs: O tempo de resposta do TCM está entre 10 a 30 segundos
      tcmbapessoal::executar_scraping_html_folhapessoal(repetir, sgbd)
      
      # Função que faz o parser (extração) dos HTMLs e o Data Wrangling dos dados extraídos
      # Faz o pré-processamento dos dados obtidos do HTML, aplicando o conceito Tidy Data
      # Por fim, cria uma arquivos CSV para a pasta dados_exportados.
      tcmbapessoal::executar_data_wrangling_html_pessoal(sgbd)

              # O conceito Tidy Data de Hadley Wickham tem por objetivo arrumar os dados
              # para que eles sejam utilizados em softwares de estatísticas ou
              # de Business Intelligence sem a necessidade de realizar
              # maiores transformações nos dados.

              # O Conceito está resumido nestas três regras:
              # - Cada variável deve ter sua própria coluna.
              # - Cada observação deve ter sua própria linha.
              # - Cada valor deve ter sua própria célula.

              #(http://r4ds.had.co.nz/tidy-data.html)

      # Função que faz o Backup local do Banco de Dados e dos arquivos HTML e CSV.
      # e o Backup em nuvem no DropBox
      tcmbapessoal::executar_backup_arquivos(backup_local, backup_nuvem)

      
      print("## Web Scraping finalizado com sucesso! ###")

}
