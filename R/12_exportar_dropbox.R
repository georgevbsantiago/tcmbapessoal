
#' @title Função que exporta os arquivos CSV para o DropBox, com o objetivo
#' conectar com o Power BI
#'
#'
#' @export

exportar_csv_dropbox <- function(backup = "NAO") {

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
#'
#'
#' @export

exportar_csv_unico_dropbox <- function(backup = "NAO") {
    
    if(!backup %in% c("SIM", "NAO")) {
        
        stop("Digite SIM ou NAO para o argumento 'backup' da função")
        
        
    }
    
    
    lista_arquivos_csv <- file.path("dados_exportados", dir("dados_exportados"))
    
    nome_arquivo_csv <- file.path("backup", "bk_arquivos_one.csv")
    
    nome_arquivo_zip <- file.path("backup", "bk_arquivos_one_csv.zip")
    
    
    message(paste("Consolidação de", length(lista_arquivos_csv),
                  "arquivos CSV. Esse processo pode levar alguns minutos"))
    
    # Remove o arquivo CSV consolidado, caso ele já exista.
    file.remove(nome_arquivo_csv)
    
    
    # Definido função anônima para iterar com os arquivos CSV
    purrr::walk(lista_arquivos_csv, function(lista_arquivos_csv) {
        
        arq_csv <- readr::read_delim(lista_arquivos_csv,
                                     delim = ";", col_types = cols(
                                         data = col_character(),
                                         ano = col_character(),
                                         mes = col_character(),
                                         cod_municipio = col_character(),
                                         nm_municipio = col_character(),
                                         cod_entidade = col_character(),
                                         nm_entidade = col_character(),
                                         nome = col_character(),
                                         matricula = col_character(),
                                         tipo_servidor = col_character(),
                                         cargo = col_character(),
                                         salario_base = col_character(),
                                         salario_vantagens = col_character(),
                                         salario_gratificacao = col_character(),
                                         decimo_terceiro = col_character(),
                                         carga_horaria = col_character(),
                                         area_atuacao = col_character()
                                     )
        )
        
        readr::write_delim(arq_csv,
                           nome_arquivo_csv,
                           append = TRUE)
        
    }
    )
    
    message("Consolidação realizada com sucesso!")
    
    zip::zip(nome_arquivo_zip, nome_arquivo_csv,
             compression_level = 9)
    
    
    print("Arquivo 'bk_arquivos_one_csv.zip' gerado com sucesso!")
    
  
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
    
    
    print("Iniciando o UPLOAD do arquivo 'bk_arquivos_one_csv.zip' para o DropBox...")
    
    rdrop2::drop_upload(nome_arquivo_zip,
                        path = dir_arquivo_dropbox,
                        mode = "overwrite",
                        dtoken = token_dropbox)
    
    print("Arquivo 'bk_arquivos_one_csv.zip' exportado com sucesso para o DropBox!")
    
    # Para realizar o download direto do arquivo, é preciso
    # Alterar o p número (ano final do URL) do 'dl' de 0 para 1
    # De: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bk_arquivos_csv.zip?dl=0
    # Para: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bk_arquivos_csv.zip?dl=1
    
}

###########################################################################################

