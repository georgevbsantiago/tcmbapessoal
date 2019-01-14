#' @title Função que cria as Tabelas do Banco de Dados
#' 
#' 
#'
#'@export

criar_tabelas_bd <- function(sgbd = "sqlite") {


    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_dcalendario") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(sgbd), "CREATE TABLE tabela_dcalendario (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    data TEXT NOT NULL,
                                                    ano TEXT NOT NULL,
                                                    mes TEXT NOT NULL
                                                    );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    }



    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_tcm_dmunicipios") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(sgbd), "CREATE TABLE tabela_tcm_dmunicipios (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    cod_municipio INT NOT NULL,
                                                    nm_municipio TEXT NOT NULL,
                                                    log_create TEXT NOT NULL
                                                    );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    }


    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_tcm_dmunicipios_entidades") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(sgbd), "CREATE TABLE tabela_tcm_dmunicipios_entidades (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    cod_municipio INT NOT NULL,
                                                    nm_municipio TEXT NOT NULL,
                                                    cod_entidade INT NOT NULL,
                                                    nm_entidade TEXT NOT NULL,
                                                    log_create TEXT NOT NULL
                                                    );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    }



    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_requisicoes") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(sgbd), "CREATE TABLE tabela_requisicoes (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    data TEXT NOT NULL,
                                                    ano TEXT NOT NULL,
                                                    mes TEXT NOT NULL,
                                                    cod_municipio INT NOT NULL,
                                                    nm_municipio TEXT NOT NULL,
                                                    cod_entidade INT NOT NULL,
                                                    nm_entidade TEXT NOT NULL,
                                                    status_request_html TEXT NOT NULL,
                                                    log_request_html TEXT NOT NULL,
                                                    nm_arq_html TEXT NOT NULL,
                                                    hash_arq_html TEXT NOT NULL,
                                                    status_tratamento_arq_csv TEXT NOT NULL,
                                                    log_tratamento_arq_csv TEXT NOT NULL,
                                                    nm_arq_csv TEXT NOT NULL
                                                    );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    }



    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_log") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(sgbd), "CREATE TABLE tabela_log (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                  	data_time TEXT NOT NULL,
                                                  	nm_log_erro TEXT NOT NULL,
                                                  	entrada_result TEXT NOT NULL,
                                                  	entrada_error TEXT NOT NULL,
                                                  	foreign_key TEXT NOT NULL,
                                                  	cod_entidade TEXT NOT NULL,
                                                  	nm_entidade TEXT NOT NULL,
                                                  	ano TEXT NOT NULL,
                                                  	mes TEXT NOT NULL,
                                                  	outros TEXT NOT NULL
                                                    );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    }


}
