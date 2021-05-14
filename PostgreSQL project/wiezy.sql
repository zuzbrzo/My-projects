-- klasy_ofert
ALTER TABLE klasy_ofert ADD CHECK (mnoznik > 0);

ALTER TABLE klasy_ofert ADD PRIMARY KEY (klasa);

-- uczestnicy uczestnik_id 		SERIAL,
				-- imie 				VARCHAR(100),
				-- nazwisko 			VARCHAR(100),
				-- kraj_zamieszkania 	VARCHAR(100),
				-- miasto 				VARCHAR(100),
				-- kod_pocztowy 		VARCHAR(6),
				-- ulica 				VARCHAR(100)
				-- numer_domu 			VARCHAR(100),
				-- data_urodzenia		DATE
				-- PESEL 				VARCHAR(11),
				-- nr_telefonu			VARCHAR(20))
ALTER TABLE uczestnicy ADD CHECK (PESEL SIMILAR TO '[0-9]{11}');

ALTER TABLE uczestnicy ADD CHECK (kraj_zamieszkania IN ('Polska', 'Francja', 'Niemcy' ));

ALTER TABLE uczestnicy ADD CHECK (data_urodzenia <= CURRENT_DATE);

ALTER TABLE uczestnicy ALTER COLUMN imie SET NOT NULL;

ALTER TABLE uczestnicy ALTER COLUMN nazwisko SET NOT NULL;

ALTER TABLE uczestnicy ALTER COLUMN kraj_zamieszkania SET NOT NULL;

ALTER TABLE uczestnicy ALTER COLUMN miasto SET NOT NULL;

ALTER TABLE uczestnicy ALTER COLUMN numer_domu SET NOT NULL;

ALTER TABLE uczestnicy ALTER COLUMN nr_telefonu SET NOT NULL;

ALTER TABLE uczestnicy ADD PRIMARY KEY (uczestnik_id);

ALTER TABLE uczestnicy ADD CHECK (nr_telefonu SIMILAR TO '[0-9+-]{1,}');

-- zamowienia (zamowienie_id 		SERIAL,
				-- klient_id 			INTEGER,
				-- wycieczka_id 		INTEGER,
				-- liczba_osob 		INTEGER,
				-- wartosc_zamowienia 	DECIMAL(10,2),
				-- klasa_oferty 		INTEGER,
				-- sposob_platnosci 	VARCHAR(100))

ALTER TABLE zamowienia ALTER COLUMN wartosc_zamowienia SET NOT NULL;

ALTER TABLE zamowienia ALTER COLUMN klasa_oferty SET NOT NULL;

ALTER TABLE zamowienia ALTER COLUMN sposob_platnosci SET NOT NULL;

ALTER TABLE zamowienia ALTER COLUMN wycieczka_id SET NOT NULL;

ALTER TABLE zamowienia ALTER COLUMN klient_id SET NOT NULL;

ALTER TABLE zamowienia ADD PRIMARY KEY (zamowienie_id);

ALTER TABLE zamowienia ADD CHECK (sposob_platnosci IN ('karta','gotowka','przelew internetowy','przelew tradycyjny','paypal','voucher'));

-- przewodnicy (przewodnik_id 		SERIAL
				-- imie 				VARCHAR(100),
				-- nazwisko 			VARCHAR(100),
				-- adres_email 		VARCHAR(200),
				-- nr_telefonu 		VARCHAR(20))

ALTER TABLE przewodnicy ALTER COLUMN imie SET NOT NULL;

ALTER TABLE przewodnicy ALTER COLUMN nazwisko SET NOT NULL;

ALTER TABLE przewodnicy ALTER COLUMN adres_email SET NOT NULL;

ALTER TABLE przewodnicy ALTER COLUMN nr_telefonu SET NOT NULL;

ALTER TABLE przewodnicy ADD PRIMARY KEY (przewodnik_id);

ALTER TABLE przewodnicy ADD CHECK (nr_telefonu SIMILAR TO “[0-9+.-]{1,}”);

ALTER TABLE przewodnicy ADD CHECK (adres_email LIKE '%_@biuro_bazy.com');

-- wycieczki (wycieczka_id 		SERIAL,
				-- liczba_uczestnikow 	INTEGER,
				-- data_rozpoczecia 	DATE,
				-- data_zakonczenia 	DATE,
				-- oferta_id 			INTEGER)

ALTER TABLE wycieczki ALTER COLUMN liczba_uczestnikow SET NOT NULL;

ALTER TABLE wycieczki ALTER COLUMN data_rozpoczecia SET NOT NULL;

ALTER TABLE wycieczki ALTER COLUMN data_zakonczenia SET NOT NULL;

ALTER TABLE wycieczki ALTER COLUMN oferta_id SET NOT NULL;

ALTER TABLE wycieczki ADD CHECK (data_zakonczenia >= data_rozpoczecia);

ALTER TABLE wycieczki ADD CHECK (liczba_uczestnikow >= 0);

ALTER TABLE wycieczki ADD PRIMARY KEY (wycieczka_id);


-- oferty      	  (oferta_id 			SERIAL,
				-- miejsce_wyjazdu 		VARCHAR(100),
				-- limit_uczestnikow 	INTEGER,
				-- dlugosc_wyjazdu 		INTEGER,
				-- cena_podstawowa 		DECIMAL(10,2),
				-- opis_oferty 			TEXT,
				-- zdjecie				TEXT)

ALTER TABLE oferty ALTER COLUMN miejsce_wyjazdu SET NOT NULL;

ALTER TABLE oferty ALTER COLUMN limit_uczestnikow SET NOT NULL;

ALTER TABLE oferty ALTER COLUMN dlugosc_wyjazdu SET NOT NULL;

ALTER TABLE oferty ALTER COLUMN cena_podstawowa SET NOT NULL;

ALTER TABLE oferty ALTER COLUMN opis_oferty SET NOT NULL;

ALTER TABLE oferty ADD CHECK (dlugosc_wyjazdu >= 0);

ALTER TABLE oferty ADD CHECK (limit_uczestnikow > 0);

ALTER TABLE oferty ADD CHECK (cena_podstawowa > 0);

ALTER TABLE oferty ADD PRIMARY KEY (oferta_id);

-- tagi

ALTER TABLE tagi ADD PRIMARY KEY (tag);

-- tagi_ofert

ALTER TABLE tagi_ofert ADD PRIMARY KEY (oferta_id, tag);

-- przewodnictwa

ALTER TABLE przewodnictwa ADD PRIMARY KEY (przewodnik_id, wycieczka_id);

-- atrakcje

ALTER TABLE atrakcje ADD PRIMARY KEY (atrakcja);

-- atrakcje_w_ofercie

ALTER TABLE atrakcje_w_ofercie ADD PRIMARY KEY (oferta_id, atrakcja);

-- uczestnicy_w_zamowieniu

ALTER TABLE uczestnicy_w_zamowieniu ADD PRIMARY KEY (zamowienie_id, uczestnik_id);

