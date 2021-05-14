library("RPostgres")

# con <- dbConnect(RPostgres::Postgres(), dbname = "projekt_bazy_test",
#                  host = "localhost", port = 5432, 
#                  user = "Magda", pass = "tajnehaslo")

con <- dbConnect(RPostgres::Postgres(), dbname = "projekt_bazy_test",
                 host = "localhost", port = 5432, 
                 user = "studentka", pass = "tajnehaslo")
