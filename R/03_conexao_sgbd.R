#' @title Função que cria o Banco de Dados
#' 
#'
#'
#'@export
#'

criar_bd <- function(sgbd = "sqlite") {
 
    
    if(sgbd == "sqlite") {
    
        if(file.exists(file.path("bd_sqlite",
                                 "bd_tcm_folha_pessoal_municipios.db")) == FALSE) {
            
            
            conexao_segura_sqlite <- purrr::safely(DBI::dbConnect)
            
            sqlite_bd <- conexao_segura_sqlite(RSQLite::SQLite(),
                                               dbname = file.path("bd_sqlite",
                                                                  "bd_tcm_folha_pessoal_municipios.db"))
            
            DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))
    
            
        }
            
            if(is.null(sqlite_bd$result)) {
                
                stop("### Ocorreu um erro durante a criação do Bando de Dados no SQLite!",
                     "### Verifique se o diretório foi criado corretamente ou se você tem permissão para criar o SQLite no diretório!")
            
        
            }
        
        print("Banco de Dados do SQLite criado com Sucesso!")
       
    }
    
    
    #if(sgbd == "mysql") {}
    
    
}


##################################################################################


#' @title Função que cria a conexão com o Banco de Dados
#' 
#'
#'
#'@export

connect_sgbd <- function(sgbd = "sqlite") {
    
    
    if(sgbd == "sqlite") {
        
    
        conexao_segura_sqlite <- purrr::safely(DBI::dbConnect)
    
        sqlite_bd <- conexao_segura_sqlite(RSQLite::SQLite(),
                                           dbname = file.path("bd_sqlite",
                                                              "bd_tcm_folha_pessoal_municipios.db"))
    
        while(length(sqlite_bd$result) == 0) {
    
            print("Banco de Dados bloqueado - Tentando conectar novamente...")
            
            log_request <- tcmbapessoal::log_data_hora()
            
            tibble::tibble(log_request,
                            nm_log_erro = "Erro ao acesso o SQLite",
                            sgbd = "sqlite") %>%
             readr::write_delim(file.path("bd_sqlite",
                                          "log_sgbd.csv"),
                                delim = ";", append = TRUE)
            
            # Tentar novamente a conexão com o BD
            sqlite_bd <- conexao_segura_sqlite(RSQLite::SQLite(),
                                               dbname = file.path("bd_sqlite",
                                                                  "bd_tcm_folha_pessoal_municipios.db"))
    
        }

    return(sqlite_bd$result)
    
    
}
    
    
    #if(bd == "mysqlite") {}
    
    
    

}

###################################################################
