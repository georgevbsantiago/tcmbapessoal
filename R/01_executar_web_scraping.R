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
#' @param exportar_nuvem É definido como "NAO" como padrão para realizar
#' Exportar os CSVs para o DropBox com o objetivo de conectar o Power BI
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
#'                                     backup_nuvem = "NAO",
#'                                     exportar_nuvem = "NAO")
#'}
#'
#'
#' @export

executar_web_scraping <- function(anos, nome_scraping, sgbd = "sqlite",
                                  repetir = "SIM", backup_local = "SIM",
                                  backup_nuvem = "NAO",
                                  exportar_nuvem = "NAO") {

  
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

    
    # Rotina para verificar se o Web Scraping está executando pela primeira vez, ou se é uma continuação.
  
  arq_rds_id_ws <- paste0("id_", nome_scraping, ".rds")
  
  if (dir.exists(nome_scraping) == FALSE &
      file.exists(arq_rds_id_ws) == FALSE) {
    
    # Função que cria o diretório com o nome do Web Scraping
    dir.create(nome_scraping)
    
    # Função que define o diretório Raiz
    setwd(nome_scraping)
    
    print("O Diretório principal foi criado com Sucesso!")
    
    # Função que define o Diretório Raiz e crias demais diretórios
    tcmbapessoal::criar_diretorios()
    
    # Função que cria a identidade do Web Scraping
    tcmbapessoal::criar_ws_id(nome_scraping, arq_rds_id_ws, sgbd)
    
    # Função que cria o Banco de Dados
    tcmbapessoal::criar_bd(sgbd)
    
    # Função que cria 5 tabelas no Banco de Dados.
    tcmbapessoal::criar_tabelas_bd(sgbd)
    
  } else {
    
    print("Executado Web Sacraping...")
    
  }
  
  
  if(dir.exists(nome_scraping) == TRUE) {
    
    setwd(nome_scraping)
    
    print("O Diretório Raiz foi definido com Sucesso!")
    
  }
  
  
  if(file.exists(arq_rds_id_ws) == TRUE) {
  
      info_ws <- readRDS(arq_rds_id_ws)
    
      print(paste("Nome do Web Scraping:", info_ws$nome))
      print(paste("Diretório do Web Scraping:", info_ws$dir_wd))
      print(paste("SGBD do Web Scraping:", info_ws$sgbd_ws))
      print(paste("Data de criação do Web Scraping:", info_ws$data_time_create))
      
      # Registrar a data e hora do início da execução do Web Scraping no arquivo RDS
      inicio_exe_ws_data_time(arq_rds_id_ws)
      
      # ---------------------------------------------------------------------------
  

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
      
      # Exportar os CSVs para o Dropbox para conectar ao Power BI
      tcmbapessoal::exportar_csv_dropbox(exportar_nuvem)
      
      
      # ---------------------------------------------------------------------------
      
      
      # Registrar a data e hora do fim da execução do Web Scraping no arquivo RDS
      fim_exe_ws_data_time(arq_rds_id_ws)

      
      print("## Web Scraping finalizado com sucesso! ###")
      
  } else {
    
    stop("Ocorreu algum problema durante a execução do Web Scraping!!!")
    
  }
  

}

