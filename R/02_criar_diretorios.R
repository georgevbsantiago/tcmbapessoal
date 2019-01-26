#' @title Função que cria os diretório do Web Scraping
#'
#'
#' @export

criar_diretorios <- function() {
    
    
        dir.create("bd_sqlite")
        
        dir.create("resposta_scraping_html")
    
        dir.create("dados_exportados")
        
        dir.create("backup")
        
        print("As pastas foram criadas com sucesso no diretório raiz")

}
