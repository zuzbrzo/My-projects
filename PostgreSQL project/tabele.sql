-- DROP TABLE uczestnicy CASCADE;
-- DROP TABLE przewodnicy CASCADE;
-- DROP TABLE wycieczki CASCADE;
-- DROP TABLE oferty CASCADE;
-- DROP TABLE tagi CASCADE;
-- DROP TABLE tagi_ofert CASCADE;
-- DROP TABLE atrakcje CASCADE;
-- DROP TABLE atrakcje_w_ofercie CASCADE;
-- DROP TABLE uczestnicy_w_zamowieniu CASCADE;
-- DROP TABLE klasy_ofert CASCADE;
-- DROP TABLE zamowienia CASCADE;
-- DROP TABLE przewodnictwa CASCADE;



CREATE TABLE uczestnicy(
				uczestnik_id 		SERIAL,
				imie 				VARCHAR(100),
				nazwisko 			VARCHAR(100),
				kraj_zamieszkania 	VARCHAR(100),
				miasto 				VARCHAR(100),
				kod_pocztowy 		VARCHAR(6),
				ulica 				VARCHAR(100),
				numer_domu 			VARCHAR(100),
				data_urodzenia 		DATE,
				PESEL 				VARCHAR(11),
				nr_telefonu 		VARCHAR(20)
);

CREATE TABLE przewodnicy(
				przewodnik_id 	 	SERIAL,
				imie 	 			VARCHAR(100),
				nazwisko 	  		VARCHAR(100),
				adres_email 	 	VARCHAR(200),
				nr_telefonu  		VARCHAR(20),
				aktywny 			BOOLEAN --nowe
);

CREATE TABLE wycieczki(
				wycieczka_id 		SERIAL,
				liczba_uczestnikow 	INTEGER,
				data_rozpoczecia 	DATE,
				data_zakonczenia 	DATE,
				oferta_id 			INTEGER
);

CREATE TABLE oferty(
				oferta_id 		  	SERIAL,
				miejsce_wyjazdu  	VARCHAR(100),
				limit_uczestnikow  	INTEGER,
				dlugosc_wyjazdu  	INTEGER,
				cena_podstawowa  	DECIMAL(10,2),
				opis_oferty 	 	TEXT,
				zdjecie	 		 	bytea
);

CREATE TABLE tagi(
				tag	 		VARCHAR(100),
				opis 		 		TEXT
);

CREATE TABLE tagi_ofert(
				tag		 			VARCHAR(100),
				oferta_id 	 		INTEGER
);

CREATE TABLE atrakcje(
				atrakcja 			VARCHAR(250),
				czy_dla_dzieci 		BOOLEAN,
				opis_atrakcji   	TEXT
);

CREATE TABLE atrakcje_w_ofercie(
				oferta_id 			INTEGER,
				atrakcja 			VARCHAR(250)
);

CREATE TABLE przewodnictwa(
				przewodnik_id 		INTEGER,
				wycieczka_id 		INTEGER
);

CREATE TABLE zamowienia(
				zamowienie_id 		SERIAL,
				klient_id 			INTEGER,
				wycieczka_id 		INTEGER,
				wartosc_zamowienia 	DECIMAL(10,2),
				klasa_oferty 		INTEGER,
				sposob_platnosci 	VARCHAR(100)
);

CREATE TABLE klasy_ofert(
				klasa 				INTEGER,
				mnoznik 			DECIMAL(10,2),
				opis_slowny 		TEXT
);

CREATE TABLE uczestnicy_w_zamowieniu(
				uczestnik_id 		INTEGER,
				zamowienie_id 		INTEGER
);