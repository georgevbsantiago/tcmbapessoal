#' @title Função que executa do Data Wrangling
#'
#' @description Função que realiza a extração de dados da Folha de Pessoal do arquivo html
#' 
#' @param sgbd Define o Sistema de Banco de Dados a ser utilizado. Por padrão, é definido como sqlite
#'
#' @export
#'


executar_data_wrangling_html_pessoal <- function(sgbd = "sqlite") {


    tb_requisicoes <- DBI::dbReadTable(tcmbapessoal::connect_sgbd(sgbd), "tabela_requisicoes") %>%
        tibble::as_tibble() %>%
        dplyr::filter(status_tratamento_arq_csv == "N")

    DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

    print("Iniciando o tratamento dos arquivos HTML")
    
    #Variável alocada no ambiente global (com: '<<-') para servir de contador durante o tratamento
    n_arq_tratado <<- 1L
    
    #Variável alocada no ambiente global (com: '<<-') para ser utilizado no contador durante o tratamento
    total_arq_html <<- nrow(tb_requisicoes)

    print(paste( "Total de Resquisições:", total_arq_html))


    if (total_arq_html == 0) {

        message("Todos os Arquivos HTML das Folhas de Pessoal já foram tratados")

    } else {


        purrr::pwalk(tb_requisicoes, data_wrangling_html_pessoal, sgbd)

        # Substituir futuramente por furrr::future_pwalk que já está disponível no github
        
        # future::plan(strategy = future::multisession)
        # furrr::future_pwalk(tb_requisicoes, data_wrangling_html_pessoal, sgbd, .progress = TRUE)

        message("Todos os Arquivos HTML das Folhas de Pessoal foram tratados!!!")

    }
    
    # Rotina para remove as variáveis alocadas no ambiente global
    rm(n_arq_tratado, total_arq_html, envir = globalenv())


}


######################################################################################


data_wrangling_html_pessoal <- function(id, data, ano, mes,  cod_municipio, nm_municipio,
                                         cod_entidade, nm_entidade, status_request_html,
                                        log_request_html, nm_arq_html, hash_arq_html,
                                        status_tratamento_arq_csv, log_tratamento_arq_csv,
                                        nm_arq_csv, sgbd, ...) {

    subdir_dados_exportados <- "dados_exportados"

    pegar_dados_html <- XML::htmlParse(nm_arq_html, encoding = "UTF-8") %>%
                        XML::readHTMLTable(stringsAsFactors = FALSE, which = 2) %>% 
                        tibble::as_tibble(.name_repair = ~make.names(.)) %>% 
                        tidyr::fill(-X, .direction = "down") %>% 
                        dplyr::filter(X != "") %>% 
                        tidyr::separate(X, sep = ":", into = c(NA, "data_admissao"))
    
    
    # Rotina para verificar se a tabela tem a coluna '13º Salário' ou não.
    verificar_colunas <- pegar_dados_html %>%
                         names() %>%
                         stringr::str_detect("13") %>%
                         any()
        
    
    if( verificar_colunas == TRUE ) {

        data_wrangling <- pegar_dados_html %>%
            tibble::as_tibble(.name_repair = ~c("data_admissao",
                                                "nome",
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
            tibble::as_tibble(.name_repair = ~c("data_admissao",
                                                "nome",
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
                      data_admissao, tipo_servidor, cargo, salario_base,
                      salario_vantagens, salario_gratificacao,
                      decimo_terceiro, carga_horaria, area_atuacao) %>%
        dplyr::mutate(data_admissao = lubridate::dmy(data_admissao, 
                                                     quiet = TRUE)) %>%
        dplyr::mutate(data_admissao = tidyr::replace_na(data_admissao,
                                                        "1900-01-01")) %>% 
        dplyr::mutate_at(c("nm_municipio", "nm_entidade", "nome",
                           "tipo_servidor", "cargo", "area_atuacao"),
                         ~stringr::str_to_upper(.)) %>%
        dplyr::mutate_at(c("salario_base", "salario_vantagens",
                           "salario_gratificacao", "decimo_terceiro"),
                         ~tcmbapessoal::valor_monetario(.)) %>%
        dplyr::mutate_at(c("salario_base", "salario_vantagens",
                           "salario_gratificacao", "decimo_terceiro"),
                         ~stringr::str_replace(., "[.]", ",")) %>%
        dplyr::mutate_all(~stringr::str_trim(.)) %>%
        dplyr::mutate_all(~stringi::stri_trans_general(., "latin-ascii"))


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


        result_sql <- update_sqlite(tcmbapessoal::connect_sgbd(sgbd), 'UPDATE tabela_requisicoes
                                                        SET status_tratamento_arq_csv = "S",
                                                            log_tratamento_arq_csv = :log_tratamento_arq_csv,
                                                            nm_arq_csv = :nm_arq_csv
                                                        WHERE id = :id
                                                                    ;',
                                    params = list(log_tratamento_arq_csv = as.character(log_tratamento_arq_csv),
                                                  nm_arq_csv = as.character(nm_arq_csv),
                                                  id = as.character(id)))

        DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))


        while(is.null(result_sql$result) == TRUE) {

            result_sql <- update_sqlite(tcmbapessoal::connect_sgbd(sgbd), 'UPDATE tabela_requisicoes
                                                        SET status_tratamento_arq_csv = "S",
                                                            log_tratamento_arq_csv = :log_tratamento_arq_csv,
                                                            nm_arq_csv = :nm_arq_csv
                                                        WHERE id = :id
                                                                    ;',
                                        params = list(log_tratamento_arq_csv = as.character(log_tratamento_arq_csv),
                                                      nm_arq_csv = as.character(nm_arq_csv),
                                                      id = as.character(id)))

            DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))

        }


        print(paste("Arquivo HTML Tratado - (ID:", id, ") | -", ano, "-", mes, "-",
                    tcmbapessoal::limpar_nome(nm_entidade), "-",
              paste0(n_arq_tratado,"/",total_arq_html)))
        
        # n_arq_tratado e total_arq_html são variáveis alocadas no ambiente global
        # para ser usada como contador das requisições. Não é a melhor prática no
        # paradgima da programação funcional, mas o propósito foi alcançado
        
        n_arq_tratado <<- n_arq_tratado + 1

}
