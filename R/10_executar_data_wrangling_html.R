#' @title Função que realiza a extração de dados da Folha de Pessoal do arquivo html
#'
#' @description ...
#'
#' @export
#'


executar_data_wrangling_html_pessoal <- function() {

    #-----------------------------------------------------------------------------
    #!!! Excluir essa rotina IF após tornar o código agnóstico em relação ao BD
    if(file.exists(file.path("bd_sqlite",
                             "bd_tcm_folha_pessoal_municipios.db")) == FALSE) {

        return(message(paste("Banco de Dados NÃO Localizado no diretório:",
                             file.path(getwd(), "bd_sqlite"))))

    }

    #-----------------------------------------------------------------------------


    tb_requisicoes <- DBI::dbReadTable(tcmbapessoal::connect_sgbd(), "tabela_requisicoes") %>%
        tibble::as.tibble() %>%
        dplyr::filter(status_tratamento_arq_csv == "N")

    DBI::dbDisconnect(tcmbapessoal::connect_sgbd())

    print("Iniciando o tratamento dos arquivos HTML")

    print(paste( "Total de Resquisições:", nrow(tb_requisicoes)))


    if (nrow(tb_requisicoes) == 0) {

        message("Todos os Arquivos HTML das Folhas de Pessoal já foram tratados")

    } else {


        purrr::pwalk(tb_requisicoes, data_wrangling_html_pessoal)

        # future::plan(multisession)
        #
        # furrr::future_pmap(tb_requisicoes, data_wrangling_html_pessoal, .progress = TRUE)

        # abjutils::pvec()

        message("Todos os Arquivos HTML das Folhas de Pessoal foram tratados!!!")

    }


}


######################################################################################


data_wrangling_html_pessoal <- function(id, data, ano, mes,  cod_municipio, nm_municipio,
                                         cod_entidade, nm_entidade, status_request_html,
                                        log_request_html, nm_arq_html, hash_arq_html,
                                        status_tratamento_arq_csv, log_tratamento_arq_csv,
                                        nm_arq_csv, ...) {

    subdir_dados_exportados <- file.path(getwd(), "dados_exportados")

    pegar_dados_html <- XML::htmlParse(nm_arq_html, encoding = "UTF-8") %>%
                         XML::readHTMLTable(stringsAsFactors = FALSE) %>%
                         .[[2]]

    if (is.vector(pegar_dados_html$"13Âº SalÃ¡rio") == TRUE){

        data_wrangling <- pegar_dados_html %>%
            tibble::as.tibble() %>%
            purrr::set_names(c("nome",
                               "matricula",
                               "tipo_servidor",
                               "cargo",
                               "salario_base",
                               "salario_vantagens",
                               "salario_gratificacao",
                               "decimo_terceiro",
                               "carga_horaria",
                               "area_atuacao"))



    } else {


        data_wrangling <- pegar_dados_html %>%
            tibble::as.tibble() %>%
            purrr::set_names(c("nome",
                               "matricula",
                               "tipo_servidor",
                               "cargo",
                               "salario_base",
                               "salario_vantagens",
                               "salario_gratificacao",
                               "carga_horaria",
                               "area_atuacao")) %>%
            dplyr::mutate(decimo_terceiro = "0")
    }

    data_wrangling <- data_wrangling %>%
        dplyr::mutate(data = data,
                      ano = ano,
                      mes = mes,
                      cod_municipio = cod_municipio,
                      nm_municipio = nm_municipio,
                      cod_entidade = cod_entidade,
                      nm_entidade = nm_entidade) %>%
        dplyr::select(data, ano, mes, cod_municipio, nm_municipio,
                      cod_entidade, nm_entidade, nome, matricula,
                      tipo_servidor, cargo, salario_base,
                      salario_vantagens, salario_gratificacao,
                      decimo_terceiro, carga_horaria, area_atuacao) %>%
        dplyr::mutate_at(dplyr::vars(nm_municipio, nm_entidade, nome,
                                     tipo_servidor, cargo, area_atuacao),
                         ~stringr::str_to_upper(.)) %>%
        dplyr::mutate_at(dplyr::vars(salario_base, salario_vantagens,
                                     salario_gratificacao, decimo_terceiro),
                         ~tcmbapessoal::valor_monetario(.)) %>%
        dplyr::mutate_at(dplyr::vars(salario_base, salario_vantagens,
                                     salario_gratificacao, decimo_terceiro),
                         ~stringr::str_replace(., "[.]", ",")) %>%
        dplyr::mutate_all(stringr::str_trim) %>%
        dplyr::mutate_all(dplyr::funs(stringi::stri_trans_general(., "latin-ascii")))


    log_tratamento_arq_csv <- tcmbapessoal::log_data_hora()


    nm_arq_csv <- file.path(subdir_dados_exportados,
                             paste0(ano,
                                    "-",
                                    mes,
                                    "-",
                                    cod_municipio,
                                    "-",
                                    cod_entidade,
                                    "-",
                                    stringr::str_sub(
                                        tcmbapessoal::limpar_nome(nm_entidade),
                                        end = 50),
                                    ".csv"))


    readr::write_delim(data_wrangling, nm_arq_csv, delim = ";")


    update_sqlite <- purrr::safely(DBI::dbExecute)


        result_sql <- update_sqlite(tcmbapessoal::connect_sgbd(), 'UPDATE tabela_requisicoes
                                                        SET status_tratamento_arq_csv = "S",
                                                            log_tratamento_arq_csv = :log_tratamento_arq_csv,
                                                            nm_arq_csv = :nm_arq_csv
                                                        WHERE id = :id
                                                                    ;',
                                    params = list(log_tratamento_arq_csv = as.character(log_tratamento_arq_csv),
                                                  nm_arq_csv = as.character(nm_arq_csv),
                                                  id = as.character(id)))

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd())


        while(length(result_sql$result) == 0) {

            print("Banco de Dados bloqueado - Tentando conectar novamente...")

            # tb_request <- tibble::tibble(
            #     data = tcmbapessoal::log_data_hora(),
            #     log_erro = "BD Bloqueado",
            #     time = "",
            #     foreign_key = "",
            #     nm_entidade = ""
            # )
            #
            # DBI::dbWriteTable(tcmbapessoal::connect_sgbd(), "tabela_log", tb_request, append = TRUE)
            #
            # DBI::dbDisconnect(tcmbapessoal::connect_sgbd())

            result_sql <- update_sqlite(tcmbapessoal::connect_sgbd(), 'UPDATE tabela_requisicoes
                                                        SET status_tratamento_arq_csv = "S",
                                                            log_tratamento_arq_csv = :log_tratamento_arq_csv,
                                                            nm_arq_csv = :nm_arq_csv
                                                        WHERE id = :id
                                                                    ;',
                                        params = list(log_tratamento_arq_csv = as.character(log_tratamento_arq_csv),
                                                      nm_arq_csv = as.character(nm_arq_csv),
                                                      id = as.character(id)))

            DBI::dbDisconnect(tcmbapessoal::connect_sgbd())

        }


        print(paste("Arquivo HTML Tratado - (ID:", id, ") | -", ano, "-", mes, "-",
                    tcmbapessoal::limpar_nome(nm_entidade)))

        # Liberar memória
        # Há uma leve perda de performance
        rm(list = ls())
        gc(reset = TRUE)



}
