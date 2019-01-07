#' @title Função que gera a tabela "tabela_tcm_dmunicipios" no Banco de Dados
#'
#'
#'
#'@importFrom magrittr %>%
#'
#'
#'@export

criar_tb_dmunicipios <- function(sgbd = "sqlite") {


    print("Iniciando Web Scraping dos códigos e nomes dos Municípios utilziados pelo TCM-Ba")

    # Executa o scraping que captura os códigos e nomes dos municípios
    tb_tcm_dmunicipios <- scraping_tcm_municipios()


    DBI::dbWriteTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_tcm_dmunicipios", tb_tcm_dmunicipios, overwrite = TRUE)

    DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))


    print("A tabela `tabela_tcm_dmunicipios` foi criado com sucesso no BD")


}


######################################################################################


scraping_tcm_municipios <- function() {

    # Scraping do código e nome dos municípios, e por meio do qual será feio o scraping
    url_tcm <- tcmbapessoal::url_tcm()


    list_tcm_municipios <- httr::GET(url_tcm) %>%
        xml2::read_html() %>%
        rvest::html_nodes("#municipios > option")

    cod_municipio <- list_tcm_municipios %>%
        rvest::html_attr("value")

    nm_municipio <- list_tcm_municipios %>%
        rvest::html_text() %>%
        stringr::str_replace(., "[*/º]", "") %>%
        stringr::str_trim()

    tabela_tcm_dmunicipios <- tibble::tibble(cod_municipio = cod_municipio,
                                             nm_municipio = nm_municipio,
                                             log_create = tcmbapessoal::log_data_hora()) %>%
                              dplyr::filter(cod_municipio != "")

    return(tabela_tcm_dmunicipios)


}

######################################################################################
