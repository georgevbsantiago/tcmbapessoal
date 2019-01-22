#' @title Função que gera a Tabela de Requisições "tabela_paginas_links" no Banco de Dados
#'
#' @param sgbd Define o Sistema de Banco de Dados a ser utilizado. Por padrão, é definido como sqlite
#'
#' @importFrom magrittr %>%
#'
#' @export
#'

criar_tb_requisicoes_pessoal <- function(sgbd = "sqlite") {


    tb_dcalendario <- DBI::dbReadTable(tcmbapessoal::connect_sgbd(sgbd),
                                       "tabela_dcalendario") %>%
                      tibble::as_tibble() %>%
                      dplyr::select("data", "ano", "mes")

    DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    tb_municipios_entidades <- DBI::dbReadTable(tcmbapessoal::connect_sgbd(sgbd),
                                                "tabela_tcm_dmunicipios_entidades") %>%
                               tibble::as_tibble() %>%
                               dplyr::select(-log_create)

    DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    tb_requisicao_novos <- merge.data.frame(tb_dcalendario, tb_municipios_entidades) %>%
                           tibble::as_tibble() %>%
                           dplyr::mutate(status_request_html = "N",
                                         log_request_html = "",
                                         nm_arq_html = "",
                                         hash_arq_html = "",
                                         status_tratamento_arq_csv = "",
                                         log_tratamento_arq_csv = "",
                                         nm_arq_csv = "")

    DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))


    tb_municipios_alvos_anteriores <- DBI::dbReadTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_requisicoes") %>%
                                      tibble::as_tibble()

    DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    tb_municipios_alvos_atualizada <- tb_requisicao_novos %>%
        # o sinal ! antes de cod_municipio é um
        # operador lógico para excluir os dados da coluna (Lei de De Morgan)
        dplyr::filter(!tb_requisicao_novos$data %in% tb_municipios_alvos_anteriores$data)


    DBI::dbWriteTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_requisicoes",
                      tb_municipios_alvos_atualizada, append = TRUE)


    DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))


    print("Tabela 'tabela_requisicoes' gerada com sucesso!")


}
