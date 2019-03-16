#' @title Função que exporta os arquivos CSV para o DropBox, com o objetivo
#' conectar com o Power BI
#' 
#' @description 
#' Obs: É preciso configurar o token do DropBox para a função funcionar.
#' Saiba como gerar o seu Token em: [linked phrase](https://github.com/karthik/rdrop2)
#' 
#' @param exportar_nuvem É definido como "NAO" como padrão. Mas pode ser marcado como "SIM"
#' para realizar a Exportação do arquivo .zip (com diversos CSVs) para o DropBox.
#'
#' @export

exportar_csv_zip_dropbox <- function(exportar_nuvem = "NAO") {
  
  if(!exportar_nuvem %in% c("SIM", "NAO")) {
    
    stop("Digite SIM ou NAO para o argumento 'exportar_nuvem' da função")
    
  }
  
  
  if(exportar_nuvem == "NAO") {
    
    stop("Não realizado a exportação para o DropBox, conforme determinado pelo usuário")
    
  }
  
  
      nome_arquivo_zip <- file.path("backup", "bk_arquivos_csv.zip")
      
      lista_arquivos_csv <- file.path("dados_exportados", dir("dados_exportados"))
      
      message(paste("Compressão de", length(lista_arquivos_csv),
                    "arquivos CSV. Esse processo pode levar alguns minutos"))
      
      zip::zip(nome_arquivo_zip, lista_arquivos_csv,
               recurse = FALSE, compression_level = 9)
      
      print("Arquivo 'bk_arquivos_csv.zip' gerado com sucesso!")
  
  # ---------------------------------------------------------------------------
  ####### O DropBox pode ser acessado com um token ou criando uma chave API
  
  # Saiba como gerar o seu Token em: https://github.com/karthik/rdrop2
  
  
  if(file.exists("token_dropbox.rds") == FALSE) {
    
    stop("Realize o processo de autenticação do DropBox ",
         "e salve o TOKEN no arquivo 'token_dropbox.rds' na pasta raiz do Web Scraping.",
         "Veja as instruções no arquivo '11_backup_dropbox.R deste pacote")
  }
  
  
      token_dropbox <- readRDS("token_dropbox.rds")
      
      print("Iniciando processo de Autenticação do Token no DropBox!")
      
      dir_arquivo_dropbox <- "web_scraping_tcmba_pessoal/arquivos_csv"
  
  if(rdrop2::drop_exists(dir_arquivo_dropbox,
                         dtoken = token_dropbox) == FALSE) {
    
    rdrop2::drop_create(dir_arquivo_dropbox,
                        dtoken = token_dropbox)
  }
  
  
      print("Iniciando o UPLOAD do arquivo 'bk_arquivos_csv.zip' para o DropBox...")
      
      rdrop2::drop_upload(nome_arquivo_zip,
                          path = dir_arquivo_dropbox,
                          mode = "overwrite",
                          dtoken = token_dropbox)
      
      print("Backup dos Arquivos (.zip) exportado com sucesso para o DropBox!")
  
  # Para realizar o download direto do arquivo, é preciso
  # Alterar o p número (ano final do URL) do 'dl' de 0 para 1
  # De: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bk_arquivos_csv.zip?dl=0
  # Para: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bk_arquivos_csv.zip?dl=1
  
}


###########################################################################################



#' @title Função que exporta os arquivos CSV único para o DropBox, com o objetivo
#' conectar com o Power BI
#'
#' @description 
#' Obs: É preciso configurar o token do DropBox para a função funcionar.
#' Saiba como gerar o seu Token em: [linked phrase](https://github.com/karthik/rdrop2)
#'
#' @param exportar_nuvem É definido como "NAO" como padrão. Mas pode ser marcado como "SIM"
#' para realizar a Exportação do arquivo CSV para o DropBox.
#' 
#' @importFrom R.utils gzip
#'
#' @export

exportar_csv_gzip_dropbox <- function(exportar_nuvem = "NAO") {
    
    if(!exportar_nuvem %in% c("SIM", "NAO")) {
        
        stop("Digite SIM ou NAO para o argumento 'exportar_nuvem' da função")
        
    }
  
    if(exportar_nuvem == "NAO") {
      
        stop("Não realizado a exportação do CSV único para o DropBox, conforme determinado pelo usuário")
      
    }
    
    
    lista_arquivos_csv <- file.path("dados_exportados", dir("dados_exportados"))
    
    nome_arquivo_csv <- file.path("backup", "bd_tcm_pessoal.csv")
    
    nome_arquivo_csv_gz <- file.path("backup", "bd_tcm_pessoal.csv.gz")
    

    message(paste("Consolidação de", length(lista_arquivos_csv),
                  "arquivos CSV. Esse processo pode levar alguns minutos"))
    
    # Remove o arquivo CSV consolidado, caso ele já exista.
    file.remove(nome_arquivo_csv, showWarnings = FALSE)
    file.remove(nome_arquivo_csv_gz, showWarnings = FALSE)
    
    
    # Definido função anônima para iterar com os arquivos CSV
    purrr::walk(lista_arquivos_csv, function(lista_arquivos_csv) {
        
           readr::read_delim(lista_arquivos_csv,
                             delim = ";",
                             col_types = readr::cols(
                                                     data = readr::col_character(),
                                                     ano = readr::col_character(),
                                                     mes = readr::col_character(),
                                                     cod_municipio = readr::col_character(),
                                                     nm_municipio = readr::col_character(),
                                                     cod_entidade = readr::col_character(),
                                                     nm_entidade = readr::col_character(),
                                                     nome = readr::col_character(),
                                                     matricula = readr::col_character(),
                                                     tipo_servidor = readr::col_character(),
                                                     cargo = readr::col_character(),
                                                     salario_base = readr::col_character(),
                                                     salario_vantagens = readr::col_character(),
                                                     salario_gratificacao = readr::col_character(),
                                                     decimo_terceiro = readr::col_character(),
                                                     carga_horaria = readr::col_character(),
                                                     area_atuacao = readr::col_character()
                                                     )
                                                     ) %>% 
            readr::write_delim(nome_arquivo_csv_gz,
                               delim = ";",
                               append = TRUE,
                               col_names = FALSE)
      
      # Remove as variáveis da memória. Assim, evita o seu consumo progressivo
      rm(list = ls())
        
    }
    )
    

    print("Consolidação e compactação realizadas com sucesso!")

    
    # ---------------------------------------------------------------------------
    ####### O DropBox pode ser acessado com um token ou criando uma chave API
    
    # Saiba como gerar o seu Token em: https://github.com/karthik/rdrop2
    
    
    if(file.exists("token_dropbox.rds") == FALSE) {
        
        stop("Realize o processo de autenticação do DropBox ",
             "e salve o TOKEN no arquivo 'token_dropbox.rds' na pasta raiz do Web Scraping.",
             "Veja as instruções no arquivo '11_backup_dropbox.R deste pacote")
        
    }
    
    
    token_dropbox <- readRDS("token_dropbox.rds")
    
    print("Iniciando processo de Autenticação do Token no DropBox!")
    
    dir_arquivo_dropbox <- "web_scraping_tcmba_pessoal/arquivos_csv"
    
    if(rdrop2::drop_exists(dir_arquivo_dropbox,
                           dtoken = token_dropbox) == FALSE) {
        
              rdrop2::drop_create(dir_arquivo_dropbox,
                                  dtoken = token_dropbox)
    }
    
    
    print("Iniciando o UPLOAD do arquivo 'bd_tcm_pessoal.csv.gz' para o DropBox...")
    
    rdrop2::drop_upload(nome_arquivo_csv_gz,
                        path = dir_arquivo_dropbox,
                        mode = "overwrite",
                        dtoken = token_dropbox)
    
    print("Arquivo 'bd_tcm_pessoal.csv.gz' exportado com sucesso para o DropBox!")
    
    # Para realizar o download direto do arquivo, é preciso
    # Alterar o p número (ano final do URL) do 'dl' de 0 para 1
    # De: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bd_tcm_pessoal.csv.gz?dl=0
    # Para: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bd_tcm_pessoal.csv.gz?dl=1
    
}

###########################################################################################

