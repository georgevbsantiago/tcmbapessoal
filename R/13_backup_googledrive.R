#' @title Função que executa o backup
#'
#' @description Função que executa o backup do Banco de Dados
#' e dos arquivos CSV para o Google Drive
#' 
#' @param backup É definido como "NAO" como padrão. Mas pode ser marcado como "SIM"
#' para realizar o Backup do Banco de Dados e dos arquivos CSV.
#' 
#' @export

executar_backup_bd_googledrive <- function(backup = "NAO") {

    
    if( backup == "NAO") {

        break()
    }

    # Define o padrão do nome a ser utilizado para identificar o BK dos arquivos;
    sufixo <- log_data_hora() %>%
        stringr::str_replace_all("[:]", "-") %>%
        stringr::str_replace_all("[ ]", "_")

    bd_sqlite <- file.path(getwd(), "bd_sqlite", "bd_tcm_folha_pessoal_municipios.db")

    nome_arquivo_zip <- file.path(getwd(), "backup",
                                 paste0("bk_bd_tcm_folha_pessoal_municipios_",sufixo, ".zip"))

    zip::zip(nome_arquivo_zip, bd_sqlite,
             recurse = FALSE, compression_level = 1)
    
    print("Arquivo de Backup do BD gerado com sucesso!")

    # Grava a hora e data da requisição para ser incluída no arquivo HMTL e no BD
    log_request <- log_data_hora()


    # ---------------------------------------------------------------------------
    ####### O Google Drive pode ser acessado com um token ou criando uma chave API

    ##### ACESSO VIA TOKEN
    #### Rotina obrigatória para obter o TOKEN de acesso ao Google Drive
    ## Ativa a Autenticação por Token
    #googledrive::drive_auth_config(active = TRUE)

    ## Reseta tokens antigos
    #token_googledrive  <-  googledrive::drive_auth(reset = TRUE)

    ## Autorizar o código que será gerado no navegador no RStudio
    ## O Código será algo assim: "4/ygBe2KEuh3Ma5HExEjYmocO3__WjKLoKG-pCg_w79-KxPLAirr51dvL"
    ## Copiar e colar o código no console

    ## Armazenar o token em um arquivo .rds
    #saveRDS(token_googledrive, "token_googledrive.rds")

    ## Carrega o token armazenado no arquivo .rds criado na pasta raiz
    #googledrive::drive_auth(oauth_token = "token_googledrive.rds")

    #googledrive::drive_token()
    #googledrive::drive_about()
    #googledrive::drive_user()

    # ---------------------------------------------------------------------------

    ##### ACESSO VIA CHAVE API

    #api_key_googledrive

    #googledrive::drive_auth_config(active = FALSE, api_key = api_key_googledrive)

    #googledrive::drive_api_key()
    #googledrive::drive_about()
    #googledrive::drive_user()

    # ---------------------------------------------------------------------------
    
    if(file.exists("token_googledrive.rds") == FALSE) {
        
        message("Realize o processo de autenticação do Google Drive ",
        "e salve o TOKEN no arquivo 'token_googledrive.rds' na pasta raiz do Web Scraping")
        
    }
    
    print("Iniciando processo de Autenticação do Token no Google Drive!")

    # Autenticar com Token ou API KEY
    googledrive::drive_auth(oauth_token = "token_googledrive.rds")

    tcmbapessoal::criar_diretorio_googledrive()

    # O nome do diretório pode ser real (obs: sempre colocar um / ao final). Ou
    # Ou o caminho do ID que representativo da URL da pasta do Google Drive

        nm_arquivo_googledrive <- paste0("web_scraping_tcmba_pessoal/backup_bd/",
                                     "bk_bd_tcm_folha_pessoal_municipios_",
                                     sufixo,
                                     ".zip")

    print("Iniciando o UPLOAD do arquivo de backup do BD para o Google Drive...")

    googledrive::drive_upload(nome_arquivo_zip,
                              nm_arquivo_googledrive)

    print("Backup do Banco de Dados (.zip) exportado com sucesso para o Google Drive!")

    # Para realizar o download direto do arquivo, é preciso identificar o ID do arquivo com a função 'googledrive::drive_get'
    # Em seguida, é só digitar o ID nessa estrutura de URL, no lugar de '[FILE_ID]':
    # Google Doc: https://docs.google.com/uc?id=[FILE_ID]&export=download
    # Exemplo: https://docs.google.com/uc?id=10krc_-8-q2OdauSen5IPF6T6ORAWw5CO&export=download
    # Fonte: https://techathlon.com/download-shared-files-google-drive/

}

###########################################################################################

#' @title Função que executa o backup dos dados
#'
#' @param backup É definido como "NAO" como padrão. Mas pode ser marcado como "SIM"
#' para realizar o Backup do Banco de Dados e dos arquivos CSV.
#'
#' @export

executar_backup_csv_googledrive <- function(backup = "NAO") {

    if( backup == "NAO") {

        break()
    }

    nome_arquivo_zip <- file.path("backup", "bk_arquivos_csv.zip")

    lista_arquivos_csv <- file.path("dados_exportados", dir("dados_exportados"))

    message(paste("Compressão de", length(lista_arquivos_csv),
                  "arquivos CSV. Esse processo pode levar alguns minutos"))

    zip::zip(nome_arquivo_zip, lista_arquivos_csv,
             recurse = FALSE, compression_level = 1)

    print("Arquivo 'bk_arquivos_csv.zip' gerado com sucesso!")

    # Grava a hora e data da requisição para ser incluída no arquivo HMTL e no BD
    log_request <- log_data_hora()


    # ---------------------------------------------------------------------------
    ####### O Google Drive pode ser acessado com um token ou criando uma chave API

    ##### ACESSO VIA TOKEN
    #### Rotina obrigatória para obter o TOKEN de acesso ao Google Drive
    ## Ativa a Autenticação por Token
    #googledrive::drive_auth_config(active = TRUE)

    ## Reseta tokens antigos
    #token_googledrive  <-  googledrive::drive_auth(reset = TRUE)

    ## Autorizar o código que será gerado no navegador no RStudio
    ## O Código será algo assim: "4/ygBe2KEuh3Ma5HExEjYmocO3__WjKLoKG-pCg_w79-KxPLAirr51dvL"
    ## Copiar e colar o código no console

    ## Armazenar o token em um arquivo .rds
    #saveRDS(token_googledrive, "token_googledrive.rds")

    ## Carrega o token armazenado no arquivo .rds criado na pasta raiz
    #googledrive::drive_auth(oauth_token = "token_googledrive.rds")

    #googledrive::drive_token()
    #googledrive::drive_about()
    #googledrive::drive_user()

    # ---------------------------------------------------------------------------

    ##### ACESSO VIA CHAVE API

    #api_key_googledrive

    #googledrive::drive_auth_config(active = FALSE, api_key = api_key_googledrive)

    #googledrive::drive_api_key()
    #googledrive::drive_about()
    #googledrive::drive_user()

    # ---------------------------------------------------------------------------
    
    if(file.exists("token_googledrive.rds") == FALSE) {
        
        message("Realize o processo de autenticação do Google Drive ",
                "e salve o TOKEN no arquivo 'token_googledrive.rds' na pasta raiz do Web Scraping")
        
    }
    
    print("Iniciando processo de Autenticação do Token no Google Drive!")
    
    # Autenticar com Token ou API KEY
    googledrive::drive_auth(oauth_token = "token_googledrive.rds")

    tcmbapessoal::criar_diretorio_googledrive()

    # O nome do diretório pode ser real (obs: sempre colocar um / ao final). Ou
    # Ou o caminho do ID que representativo da URL da pasta do Google Drive

    nm_arquivo_googledrive <- "web_scraping_tcmba_pessoal/arquivos_csv/bk_arquivos_csv.zip"

    dir_existe <- googledrive::drive_get(nm_arquivo_googledrive)

    verificador_dir_existe <- nrow(dir_existe)

    if (verificador_dir_existe == 0){

        print("Iniciando o UPLOAD do arquivo 'bk_arquivos_csv.zip' para o Google Drive...")

        googledrive::drive_upload(nome_arquivo_zip,
                                  nm_arquivo_googledrive)

    } else {
        
        print("Iniciando o UPDATE do arquivo 'bk_arquivos_csv.zip' para o Google Drive...")
        
        
        # OBS: Na fução googledrive::drive_update() as variáveis são invertidas
        #em relação à função googledrive::drive_upload(
        googledrive::drive_update(nm_arquivo_googledrive,
                                  nome_arquivo_zip)
        
    }

    print("Arquivos CSV (.zip) exportados com sucesso para o Google Drive!")


    # Para realizar o download direto do arquivo, é preciso identificar o ID do arquivo com a função 'googledrive::drive_get'
    # Em seguida, é só digitar o ID nessa estrutura de URL, no lugar de '[FILE_ID]':
    # Google Doc: https://docs.google.com/uc?id=[FILE_ID]&export=download
    # Exemplo: https://docs.google.com/uc?id=10krc_-8-q2OdauSen5IPF6T6ORAWw5CO&export=download
    # Fonte: https://techathlon.com/download-shared-files-google-drive/
}


###########################################################################################

#' @title Função que executa o backup dos dados
#'
#'
#'
#' @export

criar_diretorio_googledrive <- function() {

    message("Verificando se os Diretórios já existem no Google Drive...")

    dir_existe <- googledrive::drive_get("web_scraping_tcmba_pessoal/")

    verificador_dir_existe <- nrow(dir_existe)

    if (verificador_dir_existe == 0){

        googledrive::drive_mkdir("web_scraping_tcmba_pessoal")
        googledrive::drive_mkdir("backup_bd", parent = "web_scraping_tcmba_pessoal")
        googledrive::drive_mkdir("arquivos_csv", parent = "web_scraping_tcmba_pessoal")

        #!!! Falta criar uma função para tornar o arquivo de acesso público

        message("Diretórios criados com sucesso no Google Drive")

    }


    message("Os Diretórios já existem no Google Drive")

}
