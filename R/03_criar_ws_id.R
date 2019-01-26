#' @title Função que cria o ID do Web Scraping
#'
#' @param nome_scraping Nome do Web Scraping
#' @param sgbd Nome do SGBD usado pelo Banco de Dados
#'
#' @export

criar_ws_id <- function(nome_scraping, sgbd) {
    

        ws_id <- list(nome = paste0("id_ws_", nome_scraping),
                      file_id = paste0("ws_id", nome_scraping, ".rds"),
                      dir_wd = getwd(),
                      dir_ws = dir(),
                      sgbd_ws = sgbd,
                      data_time_create = tcmbapessoal::log_data_hora()
                      )

        saveRDS(object = ws_id,
                file = paste0("ws_id", nome_scraping, ".rds"))
        

        print("A identidade do Web Scraping foi definida com Sucesso!")
    
}