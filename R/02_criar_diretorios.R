#' @title Função que cria os diretório do Web Scraping
#'
#' @param nome_scraping Nome do Web Scraping e do seu diretório raiz
#'
#' @export

criar_diretorios <- function() {

    # Cria as pastas dos diretórios que serão utilizados;

    if (dir.exists("bd_sqlite") == FALSE) {
        dir.create("bd_sqlite")
    }

    if (dir.exists("resposta_scraping_html") == FALSE) {
        dir.create("resposta_scraping_html")
    }

    if (dir.exists("dados_exportados") == FALSE) {
        dir.create("dados_exportados")
    }

    if (dir.exists("backup") == FALSE) {
        dir.create("backup")
    }


    print("As pastas foram criadas com sucesso no diretório")


}
