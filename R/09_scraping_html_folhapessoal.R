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

executar_scraping_html_folhapessoal <- function(repetir = "NAO", sgbd = "sqlite") {


  if(repetir == "NAO") {

    tb_requisicoes <- DBI::dbReadTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_requisicoes") %>%
      tibble::as.tibble() %>%
      dplyr::filter(status_request_html == "N") %>%
      dplyr::arrange(dplyr::desc(data), cod_entidade)

    DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))


  } else {

    tb_requisicoes <- DBI::dbReadTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_requisicoes") %>%
      tibble::as.tibble() %>%
      dplyr::filter(status_request_html == "N" | status_request_html == "R") %>%
      dplyr::arrange(dplyr::desc(data), cod_entidade)

    DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))


  }

    print("Iniciando Web Scraping dos arquivos HTML das Despesas")
    
    #Variável alocada no ambiente global (com: '<<-') para servidir de contador de requisição
    n_requisicao <<- 1L
    
    #Variável alocada no ambiente global (com: '<<-') para ser utilizado no contador de requisição
    total_requisicao <<- nrow(tb_requisicoes)

    print(paste("Total de Resquisições:", total_requisicao))
    


    purrr::pwalk(tb_requisicoes, scraping_html_folhapessoal, sgbd)


    message("O Web Scraping dos arquivos HTML das Despesas foi concluído")
    
    # Rotina para remove as variáveis alocadas no ambiente global
    rm(n_requisicao, total_requisicao, envir = globalenv())

}


######################################################################################


scraping_html_folhapessoal <- function(id, data, ano, mes, cod_municipio, nm_municipio,
                                   cod_entidade, nm_entidade, status_request_html,
                                   log_request_htm, nm_arq_html, hash_arq_html,
                                   status_tratamento_arq_csv, log_tratamento_arq_csv,
                                   nm_tratamento_arq_csv, sgbd = "sqlite", ...) {

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


    #!!! Desenvolver um tratamento melhor para timeout
    
    if (is.null(scraping_html$result) == TRUE) {

        message("#### Erro: 'Timeout' da Primeira tentativa para: ",
                nm_entidade, " ano: ", ano, " mês:", mes, " ####")
        
      tcmbapessoal::gravar_erro(log_request = log_request,
                                nm_log_erro ="timeout - primeira tentativa",
                                entrada = scraping_html,
                                id = id,
                                cod_entidade = cod_entidade,
                                nm_entidade = nm_entidade,
                                ano = ano, 
                                mes = mes,
                                outros = "",
                                sgbd = sgbd
                                )
      
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

        if (is.null(scraping_html$result) == TRUE) {
          
            tcmbapessoal::gravar_erro(log_request = log_request,
                                      nm_log_erro ="timeout - segunda tentativa",
                                      entrada = scraping_html,
                                      id = id,
                                      cod_entidade = cod_entidade,
                                      nm_entidade = nm_entidade,
                                      ano = ano, 
                                      mes = mes,
                                      outros = "",
                                      sgbd = sgbd
                                      )
  
              # Parar a iteração e pular para a próxima requisição
              return(message("#### Erro: 'Timeout' da Segunda tentativa para: ",
                             nm_entidade, " ano: ", ano, " mês:", mes, " ####"))

        }
        

    }


        # Verifica se há erro de querisição 404. Se sim, grava o erro numa tabela de log no BD.
        if (scraping_html$result$status_code == 404) {

            tcmbapessoal::gravar_erro(log_request = log_request,
                                      nm_log_erro ="erro - 404",
                                      entrada = scraping_html,
                                      id = id,
                                      cod_entidade = cod_entidade,
                                      nm_entidade = nm_entidade,
                                      ano = ano, 
                                      mes = mes,
                                      outros = "",
                                      sgbd = sgbd
                                      )
            
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

       result_sql <- update_sqlite(tcmbapessoal::connect_sgbd(sgbd), 'UPDATE tabela_requisicoes
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

       DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))


                  while(is.null(result_sql$result) == TRUE) {
          
                      print("Banco de Dados bloqueado - Tentando conectar novamente...")
          

                      result_sql <- update_sqlite(tcmbapessoal::connect_sgbd(sgbd), 'UPDATE tabela_requisicoes
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
            
                      DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))
          
                  }
       


      print(paste("Scraping - (ID:", id, ") | -", ano, "-", mes, "-",
                  tcmbapessoal::limpar_nome(nm_entidade), "-",
                  paste0(n_requisicao,"/",total_requisicao),
                  "-", "OK"))
      
      # Variável que está no ambiente global e
      n_requisicao <<- n_requisicao + 1


    } else {

          result_sql <- update_sqlite(tcmbapessoal::connect_sgbd(sgbd), 'UPDATE tabela_requisicoes
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
    
          DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))


                  while(is.null(result_sql$result) == TRUE) {
          
                      print("Banco de Dados bloqueado - Tentando conectar novamente...")
          
                      result_sql <- update_sqlite(tcmbapessoal::connect_sgbd(sgbd), 'UPDATE tabela_requisicoes
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
            
                      DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))
          
                  }
          
          
        message(paste("Scraping - (ID:", id, ") | -", ano, "-", mes, "-",
                      tcmbapessoal::limpar_nome(nm_entidade), "-",
                      paste0(n_requisicao,"/",total_requisicao),
                      "-", "NAO INFORMADO"))
        
        n_requisicao <<- n_requisicao + 1

    }
}
