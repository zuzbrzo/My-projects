require(randomNames)
require(stringi)
require(stringr)
require(maps)
require(dplyr)
require(lubridate)  
require(DescTools)
require("RPostgres")


set.seed(1)
con <- dbConnect(RPostgres::Postgres(), dbname = "projekt_bazy_test",
                 host = "localhost", port = 5432, 
                 user = "studentka", pass = "tajnehaslo")



data("world.cities")
#klienci: imie, nazwisko, kraj, data urodzenia, ulica, nr domu, miasto, kod pocztowy, pesel, nr telefonu
n_klientow <- 300

make_months <-function(m){
  if (str_length(as.character(m)) == 1){m = paste("0", m, sep = "")}
  else m = as.character(m)
  m
}

random_date <- function(n) {
  years <- sample(1900:2020, n, replace = TRUE)
  dates <- sample(seq(as.Date("2021/01/01"), as.Date("2021/12/31"),by = "day"),n)
  months <- month(dates)
  months <- sapply(months, make_months)
  days <- day(dates)
  paste(years,months,days,sep='-')
}


pesel_generator_z_daty <- function(wiersz){
  data <- wiersz["data"]
  kraj <- wiersz["kraj"]
  if (kraj=="Polska"){
    years <- str_sub(strsplit(data, "[-]")[[1]][1], 3,4)
    months <- strsplit(data, "[-]")[[1]][2]
    days <-  strsplit(data, "[-]")[[1]][3]
    rest <- stri_rand_strings(1, 5, pattern = "[0-9]") # patrzymy tyko zeby zgadzala sie liczba znakow, nie bawimy sie w sumy kontrolne
    return(paste(sprintf("%02d", as.integer(years)), sprintf("%02d", as.integer(months)), sprintf("%02d", as.integer(days)), rest, sep=''))
  }
  else{return(NA)}
}

apply(data.frame("kraj" = c("Polska", "Niemcy"), "data" = random_date(2)),1, pesel_generator_z_daty)


niemieckie_miasta <- world.cities[world.cities[2]=="Germany",][,1]
niemieckie_ulice <- c("Ackerstrasse","Bernauerstrasse","Frankfurter Allee","Invalidenstrasse","Silvio Meier Strasse","Legiendamm Allee","Mozartstrasse")
polskie_miasta <- world.cities[world.cities[2]=="Poland",][,1]
polskie_ulice <- c("Miodowa","Krakowska","Legionowa","Szkolna","Graniczna","Pokorna","Rycerska","Piwna","Boczna","Cicha")
francuskie_miasta <- world.cities[world.cities[2]=="France",][,1]
francuskie_ulice <- c("Avenue Victor Hugo","Avenue Montaigne","Rue de Rivoli","Passages Couverts","Boulevard de Clichy","Avenue de Lopera","Rue de la Paix")
adresy <- data.frame("kraj" = sample(c("Polska", "Niemcy", "Francja"), n_klientow, replace = TRUE),"miasto"=rep(NA,n_klientow),"kod_pocztowy"=rep(NA,n_klientow),"ulica"=rep(NA,n_klientow),"nr_domu"=rep(NA,n_klientow))
losuj_adres_dla_kraju <- function(wiersz) {
  kraj <- wiersz[1]
  if (kraj=="Polska"){
    wiersz[2] = sample(polskie_miasta,1)
    wiersz[3] = paste(sample(10:99,1),"-",sample(100:999,1),sep="")
    wiersz[4] = sample(polskie_ulice,1)
    wiersz[5] = sample(1:199,1)
  }
  else if(kraj=="Francja"){
    wiersz[2] = sample(francuskie_miasta,1)
    wiersz[3] = sample(10000:99999,1)
    wiersz[4] = sample(francuskie_ulice,1)
    wiersz[5] = sample(1:199,1)
  }
  else if(kraj=="Niemcy"){
    wiersz[2] = sample(niemieckie_miasta,1)
    wiersz[3] = sample(10000:99999,1)
    wiersz[4] = sample(niemieckie_ulice,1)
    wiersz[5] = sample(1:199,1)
  }
  return(wiersz)
}

adresy <- t(apply(adresy,1,losuj_adres_dla_kraju))
klienci_rand <- data.frame("imie" = randomNames(n_klientow, ethnicity = 5, which.names = "first"),
                           "nazwisko" = randomNames(n_klientow, ethnicity = 5, which.names = "last"),
                           "data" = random_date(n_klientow),
                           "kraj" = adresy[,"kraj"],
                           "ulica" = adresy[,"ulica"],
                           "nr_domu" = adresy[,"nr_domu"],
                           "miasto" = adresy[,"miasto"],
                           "kod_pocztowy" = adresy[,"kod_pocztowy"],
                           "nr_telefonu" = stri_rand_strings(n_klientow, 9, pattern = "[0-9]"))

klienci_rand <- cbind( klienci_rand, "pesel" = apply(klienci_rand, 1, pesel_generator_z_daty))



klienci_df <- dbGetQuery(con, "SELECT * FROM uczestnicy;")
uczestnik_to_sql <- function(uczestnik){
  if (!is.na(uczestnik[10])){
  paste0("INSERT INTO uczestnicy (imie, nazwisko, data_urodzenia, kraj_zamieszkania, ulica, numer_domu, miasto, kod_pocztowy, nr_telefonu, PESEL) VALUES ('",
         str_replace_all(uczestnik[1], "'", "''"), "', '", str_replace_all(uczestnik[2], "'", "''"), "', '", str_replace_all(uczestnik[3], "'", "''"), "', '", str_replace_all(uczestnik[4], "'", "''"), "', '", str_replace_all(uczestnik[5], "'", "''"), "', '",
         str_replace_all(uczestnik[6], "'", "''"), "', '", str_replace_all(uczestnik[7], "'", "''"), "', '", str_replace_all(uczestnik[8], "'", "''"), "', '", str_replace_all(uczestnik[9], "'", "''"), "', '", str_replace_all(uczestnik[10], "'", "''"), "');")
  }
  else {
    paste0("INSERT INTO uczestnicy (imie, nazwisko, data_urodzenia, kraj_zamieszkania, ulica, numer_domu, miasto, kod_pocztowy, nr_telefonu) VALUES ('",
           str_replace_all(uczestnik[1], "'", "''"), "', '", str_replace_all(uczestnik[2], "'", "''"), "', '", str_replace_all(uczestnik[3], "'", "''"), "', '", str_replace_all(uczestnik[4], "'", "''"), "', '", str_replace_all(uczestnik[5], "'", "''"), "', '",
           str_replace_all(uczestnik[6], "'", "''"), "', '", str_replace_all(uczestnik[7], "'", "''"), "', '", str_replace_all(uczestnik[8], "'", "''"), "', '", str_replace_all(uczestnik[9], "'", "''"), "');")
    
    
  }
}
# uczestnik_to_sql(klienci_rand[62,])
uczestnicy_sql <- apply(klienci_rand, 1, uczestnik_to_sql)
# uczestnicy_sql[62]
write.table(uczestnicy_sql, file = "uczestnicy_rand.sql", quote = FALSE, row.names = FALSE, col.names = FALSE)

klienci_df <- dbGetQuery(con, "SELECT * FROM uczestnicy;")
# przewodnicy 

set.seed(1)
n_przewodnikow <- 30
przewodnicy_rand <- data.frame("imie" = randomNames(n_przewodnikow, ethnicity = 5, which.names = "first"),
                               "nazwisko" = randomNames(n_przewodnikow, ethnicity = 5, which.names = "last"),
                               "nr_telefonu" = stri_rand_strings(n_przewodnikow, 9, pattern = "[0-9]"))
emaile <- apply(przewodnicy_rand, 1, function(x){
  mail <- paste(str_to_lower(str_replace_all(x["imie"], " ", "_")), ".",
                str_to_lower(str_replace_all(x["nazwisko"], " ", "_")),
                "@biuro_bazy.com", sep = "")})
przewodnicy_rand <- cbind(przewodnicy_rand, emaile)

przewodnicy_df <- dbGetQuery(con, "SELECT * FROM przewodnicy;")
przewodnik_to_sql <- function(przewodnik){
    paste0("INSERT INTO przewodnicy (imie, nazwisko, adres_email, nr_telefonu, aktywny) VALUES ('",
           str_replace_all(przewodnik[1], "'", "''"), "', '",
           str_replace_all(przewodnik[2], "'", "''"), "', '",
           str_replace_all(przewodnik[4], "'", "''"), "', '",
           str_replace_all(przewodnik[3], "'", "''"), "', TRUE);")
 
}

przewodnik_to_sql(przewodnicy_rand[3,])
przewodnicy_sql <- apply(przewodnicy_rand, 1, przewodnik_to_sql)
write.table(przewodnicy_sql, file = "przewodnicy_rand.sql", quote = FALSE, row.names = FALSE, col.names = FALSE)

przewodnicy_df <- dbGetQuery(con, "SELECT * FROM przewodnicy;")


#oferty
set.seed(2021)
n_ofert <- 20
world.cities %>%
  filter( pop > 3000000) -> cities

oferty_rand <- data.frame("miejsce_wyjazdu" = sample(cities[["name"]], n_ofert,replace = TRUE),
                          
                          "limit_uczestnikow" = sample(10:35, n_ofert, replace = TRUE),
                          "dlugosc" = sample(3:14, n_ofert, replace = TRUE))
oferty_rand %>% 
  mutate("cena" = sample(400:1200, n_ofert) * dlugosc) -> oferty_rand
templatka_opisu <- c("Wspanialy wyjazd do city! Niewiarygodne przezycia gwarantowane. Zrelaksuj sie az liczba_dni dni. W ramach wyjazdu wiele niesamowitych atrakcji.")

oferty_rand %>%
  mutate("opis" =  str_replace(templatka_opisu, "city", as.character(miejsce_wyjazdu) )) %>%
  mutate(opis = str_replace(opis, "liczba_dni", as.character(dlugosc))) -> oferty_rand

oferty_rand %>%
  mutate("oferta_id" = 1:n_ofert) -> oferty_rand

oferta_to_sql <- function(oferta){
  paste0("INSERT INTO oferty (miejsce_wyjazdu, limit_uczestnikow, dlugosc_wyjazdu, cena_podstawowa, opis_oferty) VALUES ('",
         str_replace_all(oferta[1], "'", "''"), "', '",
         str_replace_all(oferta[2], "'", "''"), "', '",
         str_replace_all(oferta[3], "'", "''"), "', '",
         str_replace_all(oferta[4], "'", "''"), "', '",
         str_replace_all(oferta[5], "'", "''"), "');")
  
}

# oferta_to_sql(oferty_rand[3,])
oferty_sql <- apply(oferty_rand, 1, oferta_to_sql)
write.table(oferty_sql, file = "oferty_rand.sql", quote = FALSE, row.names = FALSE, col.names = FALSE)

oferty_df <- dbGetQuery(con, "SELECT * FROM oferty;")



# wycieczki
set.seed(2021)
n_wycieczek <- 60
wycieczki_rand <- data.frame("oferta_id" = sample(oferty_df$oferta_id,n_wycieczek, replace = TRUE))
wycieczki_rand %>%
  left_join( oferty_rand[,c("oferta_id", "dlugosc")], by = "oferta_id")%>%
  mutate("data_rozpoczecia" = sample(seq(as.Date("2020/01/01"), as.Date("2021/12/31"),by = "day"), n_wycieczek, replace = TRUE)) %>%
  mutate("data_zakonczenia" = data_rozpoczecia + dlugosc) %>%
  select(!c(dlugosc)) -> wycieczki_rand


wycieczka_to_sql <- function(wycieczka){
  paste0("INSERT INTO wycieczki (oferta_id, data_rozpoczecia, data_zakonczenia, liczba_uczestnikow) VALUES ('",
         wycieczka[1], "', '",
         wycieczka[2], "', '",
         wycieczka[3], "', 0 );")
}

wycieczki_sql <- apply(wycieczki_rand, 1, wycieczka_to_sql)
write.table(wycieczki_sql, file = "wycieczki_rand.sql", quote = FALSE, row.names = FALSE, col.names = FALSE)

wycieczki_df <- dbGetQuery(con, "SELECT * FROM wycieczki;")







# tagi
set.seed(2021)

tagi_rand <- data.frame("nazwa_tagu" = c("duze miasto", "plaza", "kasyna", "morze", "hotel", "gory", "autokar", "samolot", "widoki"))
tagi_rand %>% 
  mutate("opis" = str_replace("To jest bardzo ladny opis tego o tutaj tagu - tag_holder", "tag_holder", nazwa_tagu)) -> tagi_rand

tag_to_sql <- function(tag){
  paste0("INSERT INTO tagi (tag, opis) VALUES ('",
         tag[1], "', '",
         tag[2], "' );")
}

tagi_sql <- apply(tagi_rand, 1, tag_to_sql)
write.table(tagi_sql, file = "tagi_rand.sql", quote = FALSE, row.names = FALSE, col.names = FALSE)

tagi_df <- dbGetQuery(con, "SELECT * FROM tagi;")



# atrakcje 
set.seed(2021)

atrakcje_rand <- data.frame("atrakcja" = c("kino", "teatr", "muzeum", "basen", "kregle", "dyskoteka",
                                                 "bar", "zoo", "lot balonem", "zwiedzanie", "sesja zdjeciowa"))
atrakcje_rand%>%
  mutate("opis_atrakcji" = str_replace("W ramach wyjazdu - placeholder", "placeholder", atrakcja)) %>%
  mutate("czy_dla_dzieci" = c(T,T,T,T,T, F, F, F, T, T, T)) -> atrakcje_rand

atrakcja_to_sql <- function(atrakcja){
  paste0("INSERT INTO atrakcje (atrakcja,czy_dla_dzieci ,opis_atrakcji) VALUES ('",
         atrakcja[1], "', ",
         atrakcja[3], ", '",
         atrakcja[2], "' );")
}

atrakcje_sql <- apply(atrakcje_rand, 1, atrakcja_to_sql)
write.table(atrakcje_sql, file = "atrakcje_rand.sql", quote = FALSE, row.names = FALSE, col.names = FALSE)

atrakcje_df <- dbGetQuery(con, "SELECT * FROM atrakcje;")




#losowanie tagów do ofert
set.seed(2021)

n_otagowan <- 100

#potem bedzie sciagniete z tabeli, na razie 1:nrow(tagi_rand) i 1:nrow(oferty_rand)
tag <- tagi_df$tag
id_ofert <- oferty_df$oferta_id

tagi_ofert <- data.frame("tag" = sample(tag, n_otagowan, replace = TRUE),
                         "oferta_id" = sample(id_ofert, n_otagowan, replace = TRUE))
tagi_ofert_rand <- tagi_ofert %>% 
  distinct(`tag`, `oferta_id`)

tagi_ofert_to_sql <- function(tag_ofert){
  paste0("INSERT INTO tagi_ofert (tag, oferta_id) VALUES ('",
         tag_ofert[1], "', ",
         tag_ofert[2], ");")
}

tagi_ofert_sql <- apply(tagi_ofert_rand, 1, tagi_ofert_to_sql)
write.table(tagi_ofert_sql, file = "tagi_ofert_rand.sql", quote = FALSE, row.names = FALSE, col.names = FALSE)

tagi_ofert_df <- dbGetQuery(con, "SELECT * FROM tagi_ofert;")



# losowanie atrakcji wycieczek
set.seed(2021)

n_atrakcji_w_ofercie <- 100
#potem bedzie sciagniete z tabeli, na razie 1:nrow(atrakcje_rand) i 1:nrow(oferty_rand)
atrakcja <- atrakcje_df$atrakcja
id_ofert <- oferty_df$oferta_id

atrakcje_ofert <- data.frame("atrakcja" = sample(atrakcja, n_atrakcji_w_ofercie, replace = TRUE),
                         "oferta_id" = sample(id_ofert, n_atrakcji_w_ofercie, replace = TRUE))
atrakcje_ofert_rand <- atrakcje_ofert %>% 
  distinct(`atrakcja`, `oferta_id`)

atrakcje_ofert_to_sql <- function(atrakcja_ofert){
  paste0("INSERT INTO atrakcje_w_ofercie (atrakcja, oferta_id) VALUES ('",
         atrakcja_ofert[1], "', ",
         atrakcja_ofert[2], ");")
}

atrakcje_w_ofercie_sql <- apply(atrakcje_ofert_rand, 1, atrakcje_ofert_to_sql)
write.table(atrakcje_w_ofercie_sql, file = "atrakcje_w_ofercie_rand.sql", quote = FALSE, row.names = FALSE, col.names = FALSE)

atrakcje_w_ofercie_df <- dbGetQuery(con, "SELECT * FROM atrakcje_w_ofercie;")



#klasy ofert
set.seed(2021)

klasy_ofert <- data.frame("klasa" = c(3,2,1),"mnoznik" = c(1, 1.5, 2),
                          "opis" = c("standardowa oferta",
                                     "dostep do nielimitowanych przekasek, pierwszenstwo w wyborze pokoju",
                                     "klasa VIP, pokoje VIP, trasport VIP"))
klasy_ofert_to_sql <- function(klasa){
  paste0("INSERT INTO klasy_ofert(klasa, mnoznik, opis_slowny) VALUES (", klasa[1], ",", klasa[2], ",'", klasa[3], "');")
}

klasy_ofert_sql <- apply(klasy_ofert, 1, klasy_ofert_to_sql)
write.table(klasy_ofert_sql, file = "klasy_ofert_rand.sql", quote = FALSE, row.names = FALSE, col.names = FALSE)

klasy_ofert_df <- dbGetQuery(con, "SELECT * FROM klasy_ofert;")



# przewodnictwa
set.seed(2021)


generator_przewodnictw <- function(wycieczki,n_przewodnictw,przewodnicy){
  n_wycieczek<-wycieczki$wycieczka_id
  n_przewodnikow<-przewodnicy$przewodnik_id
  
  przewodnictwa_rand <- data.frame("wycieczka_id" = sample(n_wycieczek, n_przewodnictw, replace = TRUE),
                           "przewodnik_id" = sample(n_przewodnikow, n_przewodnictw, replace = TRUE))
  przewodnictwa_rand %>% 
    distinct(`wycieczka_id`, `przewodnik_id`) -> przewodnictwa_rand
  przewodnictwa_rand %>%
    left_join(wycieczki[,c("wycieczka_id", "data_rozpoczecia", "data_zakonczenia")], by = "wycieczka_id") -> przewodnictwa_rand_daty

  tymczasowe_przewodnictwa<-przewodnictwa_rand_daty
  for(i in unique(tymczasowe_przewodnictwa[,"przewodnik_id"])){
    przewodnictwo<-tymczasowe_przewodnictwa[tymczasowe_przewodnictwa[,"przewodnik_id"]==i,]
    przewodnictwo<-przewodnictwo[order(przewodnictwo[,"data_rozpoczecia"],decreasing = FALSE),]
    ilosc_dat<-length(przewodnictwo[[1]])
    if(ilosc_dat<2){next}
    for (k in 1:(ilosc_dat-1)){
      if(przewodnictwo[k+1,"data_rozpoczecia"]<=przewodnictwo[k,"data_zakonczenia"]){
        zle_id <- przewodnictwo[k, "wycieczka_id"]
        tymczasowe_przewodnictwa <- tymczasowe_przewodnictwa["wycieczka_id"!=zle_id,]
      }
    }
  }
  przewodnictwa <- data.frame("przewodnik_id" = tymczasowe_przewodnictwa[,"przewodnik_id"],
                         "wycieczka_id" = tymczasowe_przewodnictwa[,"wycieczka_id"]
                         )
  return(przewodnictwa)
}
przewodnictwa_rand <-generator_przewodnictw(wycieczki_df,200,przewodnicy_df)

przewodnictwo_to_sql <- function(przewodnictwo){
  paste0("INSERT INTO przewodnictwa (przewodnik_id, wycieczka_id) VALUES (",
         przewodnictwo[1], ", ",
         przewodnictwo[2], " );")
}

przewodnictwa_sql <- apply(przewodnictwa_rand, 1, przewodnictwo_to_sql)
write.table(przewodnictwa_sql, file = "przewodnictwa_rand.sql", quote = FALSE, row.names = FALSE, col.names = FALSE)

przewodnictwa_df <- dbGetQuery(con, "SELECT * FROM przewodnictwa;")



# save(klienci_df, przewodnictwa_df, przewodnicy_df, oferty_df, oferty_df, wycieczki_df, file =  "C:\\Users\\Magda\\Desktop\\dane_do_testow.Rdata")

# zamowienia: klient_id, wycieczka_id, liczba_osob, klasa_oferty, sposob_platnosci

n_zamowien <- 250
# tymczasowo, potem trzeba zaciagnac z bazy

# id_wycieczki <- wycieczki_df$wycieczka_id
# trwanie<-as.integer(unlist(wycieczki_df["data_zakonczenia"]-wycieczki_df["data_rozpoczecia"]))
# limit<-   (wycieczki_df %>%
#   left_join( oferty_df[,c("oferta_id","limit_uczestnikow")], by = "oferta_id"))$limit_uczestnikow
# platnosci<-c("gotowka","karta","przelew_internetowy","przelew_tradycyjny","paypal","voucher")

# tymczasowo, potem trzeba zaciagnac z bazy
# id_wycieczki <- 1:n_wycieczek
# trwanie<-as.integer(unlist(wycieczki_rand["data_zakonczenia"]-wycieczki_rand["data_rozpoczecia"]))
# limit<-wycieczki_rand["limit_uczestnikow"]
# wycieczki<-wycieczki_rand
set.seed(2021)
n_zamowien<-250
generator_zamowien <- function( n_zamowien){
  platnosci<-c("gotowka","karta","przelew internetowy","przelew tradycyjny","paypal","voucher")

  wycieczki <- (wycieczki_df %>%
                  left_join( oferty_df[,c("oferta_id","limit_uczestnikow")], by = "oferta_id"))
  id_wycieczki <- 1:n_wycieczek
  limit <- wycieczki["limit_uczestnikow"]
  klienci <- sample(1:n_klientow,n_zamowien,replace = TRUE)
  wyjazdy <- sample(1:n_wycieczek,n_zamowien,replace=TRUE)
  liczba <- sample(1:5,n_zamowien,replace=TRUE) # liczba ludzi w jednym zamowieniu
  
  limity_wyjazdow<-limit[wyjazdy,]
  poczatek_wyjazdu<-wycieczki[,"data_rozpoczecia"][wyjazdy]
  koniec_wyjazdu<-wycieczki[,"data_zakonczenia"][wyjazdy]
  
  tymczasowe_zamowienia<-data.frame(klienci=klienci,wyjazdy=wyjazdy,liczba_osob=liczba,limity=limity_wyjazdow,poczatek=poczatek_wyjazdu,koniec=koniec_wyjazdu, tymczasowe_id = 1:n_zamowien)
  for(i in 1:n_zamowien){
    if (tymczasowe_zamowienia[[3]][i]<=tymczasowe_zamowienia[[4]][i]){
      tymczasowe_zamowienia[[4]][i]=tymczasowe_zamowienia[[4]][i]-tymczasowe_zamowienia[[3]][i]
    }else if(tymczasowe_zamowienia[[3]][i]>tymczasowe_zamowienia[[4]][i] & tymczasowe_zamowienia[[4]]>0){
      tymczasowe_zamowienia[[3]][i]=tymczasowe_zamowienia[[4]]
    }else{
      tymczasowe_zamowienia=tymczasowe_zamowienia[-c(i),] # uznalam ?e latwiej niz sie bawic b?dzie po prostu usunac te kilka zam?wie? co nie b?d? pasowac, nadal powinno zosta? sporo zamowien
    }
  }
  for(i in unique(klienci)){
    zamowienie<-tymczasowe_zamowienia[tymczasowe_zamowienia[["klienci"]]==i,]
    daty<-zamowienie[c(5:7)]
    daty <- daty[order(daty[[1]],decreasing = FALSE),]
    ilosc_dat<-length(daty[[1]])
    if(ilosc_dat<2){next}else{
      for (k in 1:(ilosc_dat-1)){
        if(daty[k,2]<=daty[k+1,2]){
          zle_id <- daty[k, "tymczasowe_id"]
          tymczasowe_zamowienia <- tymczasowe_zamowienia["tymczasowe_id"!=zle_id,]
        }
      }
    }
  }
  zamowienia <- data.frame("klient" = klienci,
                           "wycieczka" = wyjazdy,
                           "liczba_osob" = liczba,
                           "klasa" = sample(1:3,n_zamowien,replace=TRUE),
                           "platnosc" = sample(platnosci,n_zamowien,replace=TRUE)
  )
  return(zamowienia)
}

zamowienia_rand<-generator_zamowien(250)

zamowienia_to_SQL <- function(zamowienie){
  paste0("INSERT INTO zamowienia(klient_id, wycieczka_id, wartosc_zamowienia, klasa_oferty, sposob_platnosci) VALUES(",
         zamowienie[1], ",", zamowienie[2],",0,", zamowienie[4], ",'", zamowienie[5], "');" )
}

zamowienia_sql <- apply(zamowienia_rand, 1, zamowienia_to_SQL)
zamowienia_to_SQL(zamowienia_rand[1,])

write.table(zamowienia_sql, file = "zamowienia_rand.sql", quote = FALSE, row.names = FALSE, col.names = FALSE)

zamowienia_df <- dbGetQuery(con, "SELECT * FROM zamowienia;")



zamowienia_z_datami <- left_join(zamowienia_rand, wycieczki_df, on = c("wycieczka" = "wycieczka_id"))




# uczestnictwa

#to tylko na potrzeby testowania
# wycieczki_df<-wycieczki_rand
# wycieczki_df<-cbind(data.frame("wycieczka_id"=1:length(wycieczki_df[,1])),wycieczki_df)
# zamowienia_df<-zamowienia
# zamowienia_df<-cbind(data.frame("zamowienie_id"=1:length(zamowienia_df[,1])),zamowienia_df)

set.seed(2021)
uczestnictwa_rand<-data.frame("zamowienie"=zamowienia_df$zamowienie_id,"uczestnik"=zamowienia_df$klient) # najpierw dodaje uczestnictwa klientow ktorzy kupili wycieczke
daty<-c("2019-12-31","2020-04-30","2020-08-31","2020-12-31","2021-04-30","2021-08-31","2021-12-31")

for (n in 1:(length(daty)-1)){
  wycieczka<-wycieczki_df[wycieczki_df$data_zakonczenia<=daty[n+1] & wycieczki_df$data_rozpoczecia>daty[n],]
  for (w_id in wycieczka$wycieczka_id){
    ludzie<-1:300 
    ludzie<-ludzie[-c(zamowienia_df$klient[zamowienia_df$wycieczka==w_id])]
    nr_zamowienia<-zamowienia_df$zamowienie_id[zamowienia_df$wycieczka==w_id]
    wylosowani<-sample(ludzie,3*length(nr_zamowienia))
    i<-1
    for (nr in nr_zamowienia){
      uczestnictwa_rand<-rbind(uczestnictwa_rand,data.frame("zamowienie"=nr,"uczestnik"=wylosowani[i:(i+2)]))
      i<-i+3
    }
  }
}


uczestnictwa_to_sql <- function(uczestnictwo){
  paste0("INSERT INTO uczestnicy_w_zamowieniu(uczestnik_id, zamowienie_id) VALUES (", uczestnictwo[2], ",", uczestnictwo[1],");")
}

uczestnictwa_sql <- apply(uczestnictwa_rand, 1, uczestnictwa_to_sql)

write.table(uczestnictwa_sql, file = "uczestnictwa_rand.sql", quote = FALSE, row.names = FALSE, col.names = FALSE)


