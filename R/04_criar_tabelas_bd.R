#' @title Função que cria as tabelas do Banco de Dados no SQLite
#'
#'@export

criar_tabelas_bd <- function() {


    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(), "tabela_dcalendario") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(), "CREATE TABLE tabela_dcalendario (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    data TEXT NOT NULL,
                                                    ano TEXT NOT NULL,
                                                    mes TEXT NOT NULL
                                                    );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd())

    }



    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(), "tabela_tcm_dmunicipios") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(), "CREATE TABLE tabela_tcm_dmunicipios (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    cod_municipio INT NOT NULL,
                                                    nm_municipio TEXT NOT NULL,
                                                    log_create TEXT NOT NULL
                                                    );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd())

    }


    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(), "tabela_tcm_dmunicipios_entidades") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(), "CREATE TABLE tabela_tcm_dmunicipios_entidades (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    cod_municipio INT NOT NULL,
                                                    nm_municipio TEXT NOT NULL,
                                                    cod_entidade INT NOT NULL,
                                                    nm_entidade TEXT NOT NULL,
                                                    log_create TEXT NOT NULL
                                                    );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd())

    }



    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(), "tabela_requisicoes") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(), "CREATE TABLE tabela_requisicoes (
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

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd())

    }



    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(), "tabela_log") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(), "CREATE TABLE tabela_log (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                  	data TEXT NOT NULL,
                                                  	log_erro TEXT NOT NULL,
                                                  	time TEXT NOT NULL,
                                                  	foreign_key	TEXT NOT NULL,
                                                  	nm_entidade	TEXT NOT NULL
                                                    );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd())

    }


}
