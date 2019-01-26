#' @title Função que cria as Tabelas do Banco de Dados
#' 
#' @param sgbd Define o Sistema de Banco de Dados a ser utilizado. Por padrão, é definido como sqlite
#'
#' @export

criar_tabelas_bd <- function(sgbd = "sqlite") {


    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_dcalendario") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(sgbd), "CREATE TABLE tabela_dcalendario (
                                                            id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                            data TEXT,
                                                            ano TEXT,
                                                            mes TEXT
                                                            );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    }



    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_tcm_dmunicipios") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(sgbd), "CREATE TABLE tabela_tcm_dmunicipios (
                                                            id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                            cod_municipio INT,
                                                            nm_municipio TEXT,
                                                            log_create TEXT
                                                            );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    }


    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_tcm_dmunicipios_entidades") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(sgbd), "CREATE TABLE tabela_tcm_dmunicipios_entidades (
                                                            id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                            cod_municipio INT,
                                                            nm_municipio TEXT,
                                                            cod_entidade INT,
                                                            nm_entidade TEXT,
                                                            log_create TEXT
                                                            );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    }



    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_requisicoes") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(sgbd), "CREATE TABLE tabela_requisicoes (
                                                            id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                            data TEXT,
                                                            ano TEXT,
                                                            mes TEXT,
                                                            cod_municipio INT,
                                                            nm_municipio TEXT,
                                                            cod_entidade INT,
                                                            nm_entidade TEXT,
                                                            status_request_html TEXT,
                                                            log_request_html TEXT,
                                                            nm_arq_html TEXT,
                                                            hash_arq_html TEXT,
                                                            status_tratamento_arq_csv TEXT,
                                                            log_tratamento_arq_csv TEXT,
                                                            nm_arq_csv TEXT
                                                            );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    }



    if (DBI::dbExistsTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_log") == FALSE) {

        DBI::dbExecute(tcmbapessoal::connect_sgbd(sgbd), "CREATE TABLE tabela_log (
                                                            id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                          	data_time TEXT,
                                                          	nm_log_erro TEXT,
                                                          	entrada_result TEXT,
                                                          	entrada_error TEXT,
                                                          	foreign_key TEXT,
                                                          	cod_entidade TEXT,
                                                          	nm_entidade TEXT,
                                                          	ano TEXT,
                                                          	mes TEXT,
                                                          	outros TEXT,
                                                          	sgbd TEXT
                                                            );"
        )

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    }
    
    print("As tabelas foram criadas no Banco de Dados com Sucesso!")


}
