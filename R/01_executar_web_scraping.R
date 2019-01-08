#' @title Função que executa o Web Scraping
#'
#' @description Essa função foi desenvolvida para executar todas as etapas do Web Scraping
#' 
#' @param ano Exercíico (ano) que ser pretende obter
#' @param nome_scraping Nome do Diretório que será criado para alocar o Web Scraping
#' @param repetir É definido "NAO" como padrão. Mas pode ser marcado como "SIM",
#' caso deseje repetir as consulta do Web Scraping que falharam ou que não foram
#' identificadas resposta do ente municipal
#' @param backup É definido como "NAO" como padrão. Mas pode ser marcado como "SIM"
#' para realizar o Backup do Banco de Dados e dos arquivos CSV para o Google Drive.
#' É preciso configurar o token Google Drive antes de executar
#' @param sgbd Define qual é o Banco de Dados a ser utilizado.
#' Por padrão, é definido o SQLite
#'
#' @export

executar_web_scraping <- function(ano, nome_scraping, sgbd = "sqlite",
                                  repetir = "NAO", backup = "NAO") {

  # Para desenvolver esse script, é necessário pensar em, pelo menos, 2 Hipótese de execução:
  # Se o Web Scraping está executando pela primeira vez ou se é uma continuação;


  # Rotina para verificar se o preenchimento da variável "ano" está correto
  anos_alvos <- as.numeric(ano)
  nome_scraping <- as.character(nome_scraping)
  sgbd <- as.character(sgbd)
  repetir <- as.character(repetir)
  backup <- as.character(backup)

            if(length(anos_alvos) > 1){

              return(print("Informe apenas um valor: O ano de início para realizar o Web Scraping."))

            }

            anos_validos <- c(2016, 2017, 2018)

            if(!anos_alvos %in% anos_validos){

              return(print("Informe um dos seguintes anos: 2016, 2017 ou 2018"))

            }

            if(nome_scraping == "") {

              return(print("Defina uma nome para o Scraping"))
            }

            if(stringr::str_detect(nome_scraping, "[*//={}]") == TRUE) {

              return(print("Não utilize os caracteres inválidos no nome do Scraping "))
            }
            
            if(sgbd != "sqlite" | sgbd != "mysql") {
              
              
              return(message("Selecione o SQLite ou o MySql para conectar ao Banco de Dados"))
              
              
            }

    # Rotina para verificar se o Web Scraping está executando pela primeira vez, ou se é uma continuação.
    if (file.exists(file.path("bd_sqlite", "bd_tcm_folha_pessoal_municipios.db")) == FALSE) {

    # Função que cria as pastas dos arquivos
      tcmbapessoal::criar_diretorios(nome_scraping)
      
    # Função que cria o Banco de Dados
      tcmbapessoal::criar_bd(sgbd)

    # Função que cria 4 tabelas que serão armazenadas no SQLite.
      tcmbapessoal::criar_tabelas_bd(sgbd)

    # Função que cria a tabela dCalendario
      tcmbapessoal::criar_tb_dcalendario(anos_alvos, sgbd)

    # Função que faz o Web Scraping do código e nome dos Municípios
      tcmbapessoal::criar_tb_dmunicipios(sgbd)

    # Função que faz o Web Scraping (via Web Service) do código e nome das Entidades e, ao fim, cria a tabela.
      tcmbapessoal::criar_tb_dmunicipios_entidades(sgbd)

    # Função que cria a tabela das requisições
      tcmbapessoal::criar_tb_requisicoes_pessoal(sgbd)

    # Função cria a tabela de requisições e faz o Web Scraping das páginas HTML que contêm
    # os dados da Folha de Pessoal. #OBS: O tempo de resposta do TCM está entre 10 a 30 segundos
      tcmbapessoal::executar_scraping_html_folhapessoal(repetir, sgbd)

    # Função que faz o parser dos HTMLs das depesas e o Data Wrangling dos HTMLs
      # Faz o pré-processamento dos dados obtidos do HTML, aplicando o conceito Tidy Data
      # Por fim, cria uma arquivos CSV para a pasta dados_exportados.
      tcmbapessoal::executar_data_wrangling_html_pessoal(sgbd)

            # O conceito Tidy Data de Hadley Wickham tem por objetivo arrumar os dados
            # para que eles sejam utilizados em softwares de estatísticas ou
            # de Business Intelligence sem a necessidade de realizar
            # mais transformações nos dados.

            # O Conceito está resumido nestas três regras:
            # - Cada variável deve ter sua própria coluna.
            # - Cada observação deve ter sua própria linha.
            # - Cada valor deve ter sua própria célula.

            #(http://r4ds.had.co.nz/tidy-data.html)

    # Função que faz o Backup dos Banco de Dados para o Google Drive
      tcmbapessoal::executar_backup_bd_googledrive(backup)

    # Função que faz o Backup dos Arquivos CSV para o Google Drive
      tcmbapessoal::executar_backup_csv_googledrive(backup)


    } else {


      # Função que cria a tabela dCalendario
      tcmbapessoal::criar_tb_dcalendario(anos_alvos, sgbd)
      
      # Função que faz o Web Scraping do código e nome dos Municípios
      tcmbapessoal::criar_tb_dmunicipios(sgbd)
      
      # Função que faz o Web Scraping (via Web Service) do código e nome das Entidades e, ao fim, cria a tabela.
      tcmbapessoal::criar_tb_dmunicipios_entidades(sgbd)
      
      # Função que cria a tabela das requisições
      tcmbapessoal::criar_tb_requisicoes_pessoal(sgbd)
      
      # Função cria a tabela de requisições e faz o Web Scraping das páginas HTML que contêm
      # os dados da Folha de Pessoal. #OBS: O tempo de resposta do TCM está entre 10 a 30 segundos
      tcmbapessoal::executar_scraping_html_folhapessoal(repetir, sgbd)
      
      # Função que faz o parser dos HTMLs das depesas e o Data Wrangling dos HTMLs
      # Faz o pré-processamento dos dados obtidos do HTML, aplicando o conceito Tidy Data
      # Por fim, cria uma arquivos CSV para a pasta dados_exportados.
      tcmbapessoal::executar_data_wrangling_html_pessoal(sgbd)

              # O conceito Tidy Data de Hadley Wickham tem por objetivo arrumar os dados
              # para que eles sejam utilizados em softwares de estatísticas ou
              # de Business Intelligence sem a necessidade de realizar
              # mais transformações nos dados.

              # O Conceito está resumido nestas três regras:
              # - Cada variável deve ter sua própria coluna.
              # - Cada observação deve ter sua própria linha.
              # - Cada valor deve ter sua própria célula.

              #(http://r4ds.had.co.nz/tidy-data.html)

      # Função que faz o Backup dos Banco de Dados para o Google Drive
      tcmbapessoal::executar_backup_bd_googledrive(backup)

      # Função que faz o Backup dos Arquivos CSV para o Google Drive
      tcmbapessoal::executar_backup_csv_googledrive(backup)


    }

            print("## Web Scraping finalizado com sucesso! ###")

}
