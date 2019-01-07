#' @title Função que executa o Web Scraping
#'
#' @description Executa o Web Scraping das Páginas que tem a Folha de pessoal dos Municípios no site do TCM-ba
#' 
#' @param repetir É definido como "NAO" por padrão, mas pode ser atribuído SIM
#' para realizar o Web Scraping de páginas que retornaram erro ou que ainda não foram informados pelos
#' municípios ao TCM-Ba
#'
#' @importFrom magrittr %>%
#'
#' @export

executar_scraping_html_folhapessoal <- function(repetir = "NAO") {


  #-----------------------------------------------------------------------------
  #!!! Excluir essa rotina IF após tornar o código agnóstico em relação ao BD
  if(file.exists(file.path("bd_sqlite",
                           "bd_tcm_folha_pessoal_municipios.db")) == FALSE) {

    return(message(paste("Banco de Dados NÃO Localizado no diretório:",
                       file.path(getwd(), "bd_sqlite"))))

  }

  #-----------------------------------------------------------------------------


  if(repetir == "NAO") {

    tb_requisicoes <- DBI::dbReadTable(tcmbapessoal::connect_sgbd(), "tabela_requisicoes") %>%
      tibble::as.tibble() %>%
      dplyr::filter(status_request_html == "N") %>%
      dplyr::arrange(dplyr::desc(data), cod_entidade)

    DBI::dbDisconnect(tcmbapessoal::connect_sgbd())


  } else {

    tb_requisicoes <- DBI::dbReadTable(tcmbapessoal::connect_sgbd(), "tabela_requisicoes") %>%
      tibble::as.tibble() %>%
      dplyr::filter(status_request_html == "N" | status_request_html == "R") %>%
      dplyr::arrange(dplyr::desc(data), cod_entidade)

    DBI::dbDisconnect(tcmbapessoal::connect_sgbd())


  }

    print("Iniciando Web Scraping dos arquivos HTML das Despesas")

    print(paste( "Total de Resquisições:", nrow(tb_requisicoes)))


    purrr::pwalk(tb_requisicoes, scraping_html_folhapessoal)


    message("O Web Scraping dos arquivos HTML das Despesas foi concluído")

}


######################################################################################


scraping_html_folhapessoal <- function(id, data, ano, mes, cod_municipio, nm_municipio,
                                   cod_entidade, nm_entidade, status_request_html,
                                   log_request_htm, nm_arq_html, hash_arq_html,
                                   status_tratamento_arq_csv, log_tratamento_arq_csv,
                                   nm_tratamento_arq_csv, ...) {

    subdir_resposta_html_mun <- file.path("resposta_scraping_html",
                                          tcmbapessoal::limpar_nome(nm_municipio))

    subdir_resposta_html_entidade <- file.path("resposta_scraping_html",
                                               tcmbapessoal::limpar_nome(nm_municipio),
                                               tcmbapessoal::limpar_nome(nm_entidade))

    if (dir.exists(subdir_resposta_html_mun) == FALSE) {
        dir.create(subdir_resposta_html_mun)
    }

    if (dir.exists(subdir_resposta_html_entidade) == FALSE) {
        dir.create(subdir_resposta_html_entidade)
    }


    parametros <- list(municipios = cod_municipio,
                       txtEntidade = nm_entidade,
                       entidades = cod_entidade,
                       ano = ano,
                       mes = mes,
                       tipoRegime = "",
                       cdFuncao = "",
                       pesquisar = "Pesquisar")


    scraping_html_purrr <- purrr::safely(httr::POST)

    scraping_html <- scraping_html_purrr(tcmbapessoal::url_tcm(),
                                         body = parametros,
                                         encode = 'form',
                                         httr::timeout(35))

    log_request <- tcmbapessoal::log_data_hora()


    # Verifica houve timeout. Se sim, esperar 20 segundos e tentar novamente.
    if (length(scraping_html$result) == 0) {

        message("#### Erro: 'Timeout' da Primeira tentativa para: ",
                nm_entidade, " ano: ", ano, " mês:", mes, " ####")

        tb_request <- tibble::tibble(
            data = data,
            log_erro = "timeout - primeira tentativa",
            time = log_request,
            foreign_key = id,
            nm_entidade = nm_entidade
        )

        DBI::dbWriteTable(tcmbapessoal::connect_sgbd(), "tabela_log", tb_request, append = TRUE)

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd())


        message("#### Iniciando Segunda tentativa para: ",
                nm_entidade, " ano: ", ano, " mês:", mes, " ####")

        # Pausa antes da segunad tentativa
        Sys.sleep(10)


        # Segunda tentativa. Se houver timeout novamente, pular para a próxima requisição.
        scraping_html <- scraping_html_purrr(tcmbapessoal::url_tcm(),
                                             body = parametros,
                                             encode = 'form',
                                             httr::timeout(75))

        log_request <- tcmbapessoal::log_data_hora()


        if (length(scraping_html$result) == 0) {

            tb_request <- tibble::tibble(
                data = data,
                log_erro = "timeout - primeira tentativa",
                time = log_request,
                foreign_key = id,
                nm_entidade = nm_entidade
            )


            DBI::dbWriteTable(tcmbapessoal::connect_sgbd(), "tabela_log", tb_request, append = TRUE)

            DBI::dbDisconnect(tcmbapessoal::connect_sgbd())


            # Parar a iteração e pular para a próxima requisição
            return(message("#### Erro: 'Timeout' da Segunda tentativa para: ",
                           nm_entidade, " ano: ", ano, " mês:", mes, " ####"))


        }

    }


    # Verifica se há erro de querisição 404. Se sim, grava o erro numa tabela de log no BD.
    if (scraping_html$result$status_code == 404) {


        tb_request <- tibble::tibble(
            data = data,
            log_erro = "erro - 404",
            time = log_request,
            foreign_key = id,
            nm_entidade = nm_entidade
        )

        DBI::dbWriteTable(tcmbapessoal::connect_sgbd(), "tabela_log", tb_request, append = TRUE)

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd())


        # Parar a iteração e pular para a próxima requisição.
        return(message("#### Erro 404 de Requisição para: ",
                       nm_entidade, " ano: ", ano, " mês:", mes, " ####"))


    }


    nm_arq_html <- file.path(subdir_resposta_html_entidade,
                             paste0(ano,
                                    "-",
                                    mes,
                                    "-",
                                    cod_entidade,
                                    "-",
                                    stringr::str_sub(
                                      tcmbapessoal::limpar_nome(nm_entidade),
                                      end = 60),
                                    ".html"))


    salvar_html <- xml2::read_html(scraping_html$result) %>%
                   rvest::html_node("#formConsulta") %>%
                   xml2::write_html(nm_arq_html)

    hash_arq_html <- digest::sha1(nm_arq_html)


    detectar_tabela <- xml2::read_html(scraping_html$result) %>%
                       rvest::html_node("#tabelaConsulta") %>%
                       is.na()

    update_sqlite <- purrr::safely(DBI::dbExecute)

    if (detectar_tabela == FALSE) {

       result_sql <- update_sqlite(tcmbapessoal::connect_sgbd(), 'UPDATE tabela_requisicoes
                                                        SET status_request_html = "S",
                                                            log_request_html = :log_request,
                                                            nm_arq_html = :nm_arq_html,
                                                            hash_arq_html = :hash_arq_html,
                                                            status_tratamento_arq_csv = "N"
                                                        WHERE id = :id
                                                                    ;',
                                       params = list(log_request = as.character(log_request),
                                                     nm_arq_html = as.character(nm_arq_html),
                                                     hash_arq_html = as.character(hash_arq_html),
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
                                                        SET status_request_html = "S",
                                                            log_request_html = :log_request,
                                                            nm_arq_html = :nm_arq_html,
                                                            hash_arq_html = :hash_arq_html,
                                                            status_tratamento_arq_csv = "N"
                                                        WHERE id = :id
                                                                    ;',
                          params = list(log_request = as.character(log_request),
                                        nm_arq_html = as.character(nm_arq_html),
                                        hash_arq_html = as.character(hash_arq_html),
                                        id = as.character(id)))

          DBI::dbDisconnect(tcmbapessoal::connect_sgbd())

        }


        print(paste("Scraping - (ID:", id, ") | -", ano, "-", mes, "-",
                    tcmbapessoal::limpar_nome(nm_entidade), "-", "OK"))


    } else {

      result_sql <- update_sqlite(tcmbapessoal::connect_sgbd(), 'UPDATE tabela_requisicoes
                                                        SET status_request_html = "R",
                                                            log_request_html = :log_request,
                                                            nm_arq_html = :nm_arq_html,
                                                            hash_arq_html = :hash_arq_html
                                                        WHERE id = :id
                                                                    ;',
                      params = list(log_request = as.character(log_request),
                                    nm_arq_html = as.character(nm_arq_html),
                                    hash_arq_html = as.character(hash_arq_html),
                                    id = as.character(id)))

      DBI::dbDisconnect(tcmbapessoal::connect_sgbd())


        while(length(result_sql$result) == 0) {

            print("Banco de Dados bloqueado - Tentando conectar novamente...")

          result_sql <- update_sqlite(tcmbapessoal::connect_sgbd(), 'UPDATE tabela_requisicoes
                                                        SET status_request_html = "R",
                                                            log_request_html = :log_request,
                                                            nm_arq_html = :nm_arq_html,
                                                            hash_arq_html = :hash_arq_html
                                                        WHERE id = :id
                                                                    ;',
                          params = list(log_request = as.character(log_request),
                                        nm_arq_html = as.character(nm_arq_html),
                                        hash_arq_html = as.character(hash_arq_html),
                                        id = as.character(id)))

          DBI::dbDisconnect(tcmbapessoal::connect_sgbd())

        }

      message(paste("Scraping - (ID:", id, ") | -", ano, "-", mes, "-",
                    tcmbapessoal::limpar_nome(nm_entidade), "-", "NAO INFORMADO"))

    }
}
