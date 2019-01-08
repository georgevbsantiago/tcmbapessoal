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

###################################################################################

#' @title Função utilizadas no Web Scraping
#'
#'
#' @export

valor_monetario <- function (x) {

    x <- as.character(x)

    readr::parse_number(x, locale = readr::locale(grouping_mark = ".",
                                           decimal_mark = ","))

}

###################################################################################

#' @title Função utilizadas no Web Scraping
#'
#'
#' @export

url_tcm <- function () {

    url_tcm <-  "http://www.tcm.ba.gov.br/portal-da-cidadania/pessoal/"

}

###################################################################################

#' @title Função utilizadas no Web Scraping
#'
#'
#' @export

url_tcm_entidades_ws <- function(){

    url_tcm_entidades_ws <- "http://www.tcm.ba.gov.br/Webservice/index.php/entidades?cdMunicipio="

}

###################################################################################

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


###################################################################################


#' @title Função utilizadas no Web Scraping
#' 
#' @param x Transforma valores Ex: c("R$ 10.000,89", "R$ 123,75") em 10000.89 e 123.75
#' 
#' @export
valor_monetario2 <- function(x) {
        x %>% 
        stringr::str_remove("R\\$") %>% 
        stringr::str_remove(".") %>% 
        stringr::str_replace_all(",", "\\.") %>% 
        as.numeric()
}

###################################################################################


#' @title Função para gravar erro da execução do código
#' 
#' @param log_request Valor gerado pela função log_data_hora()
#' @param nm_log_erro Nome do erro atribuído pelo desenvolvedor;
#' @param entrada Resultado após execução da função envolvida pela função purrr::safely
#' @param id Número do ID no Banco de Dados;
#' @param cod_entidade Código da Entidade Municipal do Web Scraping;
#' @param nm_entidade Nome da Entidade Municipal do Web Scraping;
#' @param ano Ano de referência da Entidade Municipal;
#' @param mes Mês de referência da Entidade Municipal;
#' @param outros Outras informações adicionadas pelo Desenvolvedor;
#' @param sgbd Nome do Banco de Dados usado na execução do Código
#' 
#' @export

gravar_erro <- function(log_request, nm_log_erro = "", entrada = "",
                        id = "", cod_entidade = "", nm_entidade = "",
                        ano = "", mes = "", outros = "", sgbd) {
    
                tb_error <- tibble::tibble(
                    data_time = log_request,
                    nm_log_erro = nm_log_erro,
                    entrada_result = entrada$result,
                    entrada_error = entrada$error,
                    foreign_key = id,
                    cod_entidade = cod_entidade,
                    nm_entidade = nm_entidade,
                    ano = ano,
                    mes = mes,
                    outros = outros
                )
    
    write_sqlite <- purrr::safely(DBI::dbWriteTable)
    
    
    result_sql <- write_sqlite(tcmbapessoal::connect_sgbd(sgbd), "tabela_log",
                               tb_error, append = TRUE)
    
    DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))
    
    
    while(is.null(result_sql$result) == TRUE) {
        
        print("Banco de Dados bloqueado - Tentando conectar novamente...")
        
        
        result_sql <- write_sqlite(tcmbapessoal::connect_sgbd(sgbd), "tabela_log",
                                   tb_error, append = TRUE)
        
        DBI::dbDisconnect(tcmbapessoal::connect_sgbd(sgbd))
        
    }
    
}

###################################################################################
