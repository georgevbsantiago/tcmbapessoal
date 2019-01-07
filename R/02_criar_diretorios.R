#' @title Função que cria os diretório do Web Scraping
#'
#' @description Os diretórios do Web Scraping são criados no diretório de trabalho escolhido pelo usuário
#'
#' @export

criar_diretorios <- function(nome_scraping) {

    # Cria as pastas dos diretórios que serão utilizados;

    dir_principal <- file.path(getwd(), nome_scraping)

    if (dir.exists(dir_principal) == FALSE) {
        dir.create(dir_principal)
    }

    setwd(dir_principal)


    subdir_bd_sqlite <- file.path(dir_principal, "bd_sqlite")
    subdir_resposta_scraping_html <- file.path(dir_principal, "resposta_scraping_html")
    subdir_dados_exportados <- file.path(dir_principal, "dados_exportados")
    subdir_backup <- file.path(dir_principal, "backup")

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


    print("As pastas foram criadas com sucesso no diretório")


}
