#' @title Função que cria a conexão com o Banco de Dados
#' 
#'
#'
#'@export

connect_sgbd <- function() {

    # Cria a conexão com o SQLite, assim como o arquivo 'bd_tcm_gastos_municipais.db', caso ele não exista;

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

        sqlite_bd <- conexao_segura_sqlite(RSQLite::SQLite(),
                                           dbname = file.path("bd_sqlite",
                                                              "bd_tcm_folha_pessoal_municipios.db"))

    }

    return(sqlite_bd$result)

}

###################################################################
