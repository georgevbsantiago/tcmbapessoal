#' @title Função utilizadas no Web Scraping
#'
#'
#' @export


# Função que cria a data e hora local, com timezone do Brasil
# Essa função foi desenvolvida para colocar a informação no formato DATE em formato 'character' no SQLite,
# visto que o SQLite converte data em número.

log_data_hora <- function () {

    format(lubridate::now(), tz ="Brazil/East", usetz = TRUE)

}

###################################################################

#' @title Função utilizadas no Web Scraping
#'
#'
#' @export

valor_monetario <- function (x) {

    x <- as.character(x)

    readr::parse_number(x, locale = readr::locale(grouping_mark = ".",
                                           decimal_mark = ","))

}

###################################################################

#' @title Função utilizadas no Web Scraping
#'
#'
#' @export

url_tcm <- function () {

    url_tcm <-  "http://www.tcm.ba.gov.br/portal-da-cidadania/pessoal/"

}

###################################################################

#' @title Função utilizadas no Web Scraping
#'
#'
#' @export

url_tcm_entidades_ws <- function(){

    url_tcm_entidades_ws <- "http://www.tcm.ba.gov.br/Webservice/index.php/entidades?cdMunicipio="

}

###################################################################

#' @title Função para limpar nomes de caracteres especiais
#'
#'
#' @export

limpar_nome <- function (x) {

resultado <- stringr::str_replace_all(x, "[/]", "") %>%
             stringr::str_replace_all("[*]", "") %>%
             stringr::str_replace_all("[ª]", "") %>%
             stringr::str_replace_all("[º]", "") %>%
             stringr::str_trim() %>%
             stringr::str_to_upper () %>%
             stringi::stri_trans_general(., "latin-ascii")

return(resultado)

}
