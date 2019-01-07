#' @title Função que cria o Banco de Dados
#' 
#'
#'
#'@export
#'

criar_bd <- function(bd = "sqlite") {
 
    
    if(bd == "sqlite") {
    
        if(file.exists(file.path("bd_sqlite",
                                 "bd_tcm_folha_pessoal_municipios.db")) == FALSE) {
            
            
            conexao_segura_sqlite <- purrr::safely(DBI::dbConnect)
            
            sqlite_bd <- conexao_segura_sqlite(RSQLite::SQLite(),
                                               dbname = file.path("bd_sqlite",
                                                                  "bd_tcm_folha_pessoal_municipios.db"))
            
            DBI::dbDisconnect(tcmbapessoal::connect_sgbd())
    
            
        }
            
            if(length(sqlite_bd$result) == 0) {
                
                message("### Ocorreu um erro durante a criação do Bando de Dados no SQLite!")
                message("### Verifique se o diretório foi criado corretamente ou se você tem permissão para criar o SQLite no diretório!")
            
        
        }
       
    }
    
    
    #if(bd == "mysql") {}
    
    
}


##################################################################################


#' @title Função que cria a conexão com o Banco de Dados
#' 
#'
#'
#'@export

connect_sgbd <- function(bd = "sqlite") {
    
    
    if(bd != "sqlite" | bd != "mysql") {
        
        
        message("Selecione o SQLite ou o MySql para conectar ao Banco de Dados")
        
        
    }
    
    
    if(bd == "sqlite") {
        
    
        conexao_segura_sqlite <- purrr::safely(DBI::dbConnect)
    
        sqlite_bd <- conexao_segura_sqlite(RSQLite::SQLite(),
                                           dbname = file.path("bd_sqlite",
                                                              "bd_tcm_folha_pessoal_municipios.db"))
    
        while(length(sqlite_bd$result) == 0) {
    
            print("Banco de Dados bloqueado - Tentando conectar novamente...")
    
            tb_request <- tibble::tibble(
                data = tcmbapessoal::log_data_hora(),
                log_erro = "BD Bloqueado",
                time = "",
                foreign_key = "",
                nm_entidade = ""
            )
    
            DBI::dbWriteTable(tcmbapessoal::connect_sgbd(), "tabela_log", tb_request, append = TRUE)
    
            DBI::dbDisconnect(tcmbapessoal::connect_sgbd())
            
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
