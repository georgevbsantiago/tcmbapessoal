#' @title Função que executa o backup
#'
#' @description Função que executa o backup do Banco de Dados
#' e dos arquivos CSV para o DropBox
#'
#' @export

executar_backup_bd_dropbox <- function(backup = "NAO") {
    
    
    if(!backup %in% c("SIM", "NAO")) {
        
        stop("Digite SIM ou NAO para o argumento 'backup' da função")
        
        
    }
    
    # Define o padrão do nome a ser utilizado para identificar o BK dos arquivos;
    sufixo <- log_data_hora() %>%
        stringr::str_replace_all("[:]", "-") %>%
        stringr::str_replace_all("[ ]", "_")
    
    bd_sqlite <- file.path("bd_sqlite", "bd_tcm_folha_pessoal_municipios.db")
    
    nome_arquivo_zip <- file.path("backup",
                                  paste0("bk_bd_tcm_folha_pessoal_municipios_", sufixo, ".zip"))
    
    zip::zip(nome_arquivo_zip, bd_sqlite,
             recurse = FALSE, compression_level = 9)
    
    print("Arquivo de Backup do BD gerado com sucesso!")
    
    # Grava a hora e data da requisição para ser incluída no arquivo HMTL e no BD
    log_request <- log_data_hora()
    
   
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
    
    dir_arquivo_dropbox <- "web_scraping_tcmba_pessoal/backup_bd"
    
    if(rdrop2::drop_exists(dir_arquivo_dropbox,
                           dtoken = token_dropbox) == FALSE) {
        
        rdrop2::drop_create(dir_arquivo_dropbox,
                            dtoken = token_dropbox)
    }
    
    
    print("Iniciando o UPLOAD do arquivo de backup do BD para o DropBox...")
    
    rdrop2::drop_upload(nome_arquivo_zip,
                        path = dir_arquivo_dropbox,
                        dtoken = token_dropbox)
    
    print("Backup do Banco de Dados (.zip) exportado com sucesso para o DropBox!")
    
    # Para realizar o download direto do arquivo, é preciso
    # Alterar o p número (ano final do URL) do 'dl' de 0 para 1
    # De: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bk_arquivos_csv.zip?dl=0
    # Para: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bk_arquivos_csv.zip?dl=1

    
}

###########################################################################################

#' @title Função que executa o backup dos dados
#'
#'
#'
#' @export

executar_backup_csv_dropbox <- function(backup = "NAO") {
    
    if(!backup %in% c("SIM", "NAO")) {
        
        stop("Digite SIM ou NAO para o argumento 'backup' da função")
        
        
    }
    

    nome_arquivo_zip <- file.path("backup", "bk_arquivos_csv.zip")
    
    lista_arquivos_csv <- file.path("dados_exportados", dir("dados_exportados"))
    
    message(paste("Compressão de", length(lista_arquivos_csv),
                  "arquivos CSV. Esse processo pode levar alguns minutos"))
    
    zip::zip(nome_arquivo_zip, lista_arquivos_csv,
             recurse = FALSE, compression_level = 9)
    
    print("Arquivo 'bk_arquivos_csv.zip' gerado com sucesso!")
    
    # Grava a hora e data da requisição para ser incluída no arquivo HMTL e no BD
    log_request <- log_data_hora()
    
    
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
    
    print("Backup do Banco de Dados (.zip) exportado com sucesso para o DropBox!")
    
    # Para realizar o download direto do arquivo, é preciso
    # Alterar o p número (ano final do URL) do 'dl' de 0 para 1
    # De: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bk_arquivos_csv.zip?dl=0
    # Para: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bk_arquivos_csv.zip?dl=1

}

###########################################################################################

#' @title Função que executa o backup dos dados
#'
#'
#'
#' @export

executar_backup_html_dropbox <- function(backup = "NAO") {
    
    if(!backup %in% c("SIM", "NAO")) {
        
        stop("Digite SIM ou NAO para o argumento 'backup' da função")
        
        
    }
    
    
    nome_arquivo_html_zip <- file.path("backup", "bk_arquivos_html.zip")
    
    lista_arquivos_html <- file.path("resposta_scraping_html", dir("resposta_scraping_html"))
    
    message(paste("Compressão de", length(lista_arquivos_html),
                  "arquivos HTML. Esse processo pode levar alguns minutos"))
    
    zip::zip(nome_arquivo_html_zip, lista_arquivos_html,
             recurse = FALSE, compression_level = 9)
    
    print("Arquivo 'bk_arquivos_csv.zip' gerado com sucesso!")
    
    # Grava a hora e data da requisição para ser incluída no arquivo HMTL e no BD
    log_request <- log_data_hora()
    
    
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
    
    dir_arquivo_dropbox <- "web_scraping_tcmba_pessoal/arquivos_html"
    
    if(rdrop2::drop_exists(dir_arquivo_dropbox,
                           dtoken = token_dropbox) == FALSE) {
        
        rdrop2::drop_create(dir_arquivo_dropbox,
                            dtoken = token_dropbox)
        
    }
    
    
    print("Iniciando o UPLOAD do arquivo 'bk_arquivos_csv.zip' para o DropBox...")
    
    rdrop2::drop_upload(nome_arquivo_html_zip,
                        path = dir_arquivo_dropbox,
                        mode = "overwrite",
                        dtoken = token_dropbox)
    
    print("Backup do Banco de Dados (.zip) exportado com sucesso para o DropBox!")
    
    # Para realizar o download direto do arquivo, é preciso
    # Alterar o p número (ano final do URL) do 'dl' de 0 para 1
    # De: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bk_arquivos_csv.zip?dl=0
    # Para: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bk_arquivos_csv.zip?dl=1
    
}