#' @title Função que gera a tabela com a relação de meses e ano para o Web Scraping;
#'
#'
#' @importFrom magrittr %>%
#'
#' @export

criar_tb_dcalendario <- function(anos_alvos){

    tb_dcalendario <- purrr::map_dfr(anos_alvos, tb_anos_alvos) %>%
                      tibble::as.tibble()

    DBI::dbWriteTable(connect_sgbd(), "tabela_dcalendario", tb_dcalendario, overwrite = TRUE)

    print("A tabela `tabela_dcalendario` foi criada com sucesso no BD")

    DBI::dbDisconnect(connect_sgbd())


}

######################################################################################

tb_anos_alvos <- function(anos_alvos) {


    # Cria a tabela com a relação de meses e ano para o Web Scraping;
    tb_calendario <- tibble::tibble(data = seq(lubridate::ymd(paste0(anos_alvos,"-01-01")),
                                               (lubridate::today() - lubridate::day(lubridate::today()) + 1 - months(2)),
                                               by = "month"),
                                    ano = lubridate::year(data),
                                    mes = lubridate::month(data),
                                    log_create = tcmbapessoal::log_data_hora()) %>%
                     dplyr::mutate(data = as.character(data),
                      # A coluna 'data', 'ano' e 'mês' foram transformados em 'character'
                      # para ser registrada no SQLite como TEXT, já que ele não suporta o formato DATE;
                                   ano = as.character(ano),
                                   mes = as.character(mes))

    return(tb_calendario)

}
