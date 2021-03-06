#' @title Função que gera a tabela 'dCalendario' com a relação de meses e ano para o Web Scraping;
#' 
#' @param sgbd Define o Sistema de Banco de Dados a ser utilizado. Por padrão, é definido como sqlite
#' 
#' @param ano_inicio Define o ano de início do Web Scraping
#'
#' @importFrom magrittr %>%
#'
#' @export

criar_tb_dcalendario <- function(ano_inicio, sgbd = "sqlite"){

    tb_dcalendario <- purrr::map_dfr(ano_inicio, func_dcalendario)
    
    DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))
    

    DBI::dbWriteTable(tcmbapessoal::connect_sgbd(sgbd),
                      "tabela_dcalendario",
                      tb_dcalendario,
                      overwrite = TRUE)

    print("A tabela `tabela_dcalendario` foi criada com sucesso no BD")

    DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))


}

######################################################################################

func_dcalendario <- function(ano_inicio) {


    # Cria a tabela com a relação de meses e ano para o Web Scraping;
    tb_calendario <- tibble::tibble(data = seq(lubridate::ymd(paste0(ano_inicio, "-01-01")),
                                               (lubridate::today() - lubridate::day(lubridate::today()) + 1 - months(2)),
                                               by = "month"),
                                    ano = lubridate::year(data),
                                    mes = lubridate::month(data),
                                    log_create = tcmbapessoal::log_data_hora()) %>%
                     dplyr::mutate(data = as.character(data),
                                   ano = as.character(ano),
                                   mes = as.character(mes))
    # A coluna 'data', 'ano' e 'mês' foram transformados em 'character'
    # para ser registrada no SQLite como TEXT, já que ele não suporta o formato DATE;

    return(tb_calendario)

}
