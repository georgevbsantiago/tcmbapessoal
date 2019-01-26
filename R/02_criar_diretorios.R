#' @title Função que cria os diretório do Web Scraping
#'
#' @param nome_scraping Nome do Web Scraping e do seu diretório raiz
#'
#' @export

criar_diretorios <- function(nome_scraping) {


    dir_raiz_atual <- getwd()
    
    dir_raiz_verificador <- file.path(dir_raiz_atual, "bd_sqlite")
    
    if (dir.exists(dir_raiz_verificador) == TRUE) {

        return(print("O diretório Raiz foi definido com sucesso!"))
        
    } else {
        
            dir_raiz_ws <- file.path(getwd(), nome_scraping)
        
            dir.create(dir_raiz_ws)
        
            setwd(dir_raiz_ws)
            
            subdir_bd_sqlite <- file.path(dir_raiz_ws, "bd_sqlite")
            subdir_resposta_scraping_html <- file.path(dir_raiz_ws, "resposta_scraping_html")
            subdir_dados_exportados <- file.path(dir_raiz_ws, "dados_exportados")
            subdir_backup <- file.path(dir_raiz_ws, "backup")
            
            if (dir.exists(subdir_bd_sqlite) == FALSE) {
                dir.create(subdir_bd_sqlite)
            }
                
            if (dir.exists(subdir_resposta_scraping_html) == FALSE) {
                dir.create(subdir_resposta_scraping_html)
            }
            
            if (dir.exists(subdir_dados_exportados) == FALSE) {
                dir.create(subdir_dados_exportados)
            }
            
            if (dir.exists(subdir_backup) == FALSE) {
                dir.create(subdir_backup)
            }
            
            print("As pastas foram criadas com sucesso no diretório raiz")
        
    }       


}
