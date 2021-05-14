
-- zloz zamowienie
CREATE OR REPLACE FUNCTION zloz_zamowienie(klient INTEGER, wycieczka INTEGER, klasa_zam INTEGER, platnosc VARCHAR(100)) RETURNS TEXT AS $$
DECLARE
	oferta INTEGER;
	znajdz_wycieczka INTEGER;
	znajdz_klient INTEGER;
	znajdz_klasa INTEGER;
	cena DECIMAL(10,2);
BEGIN
	SELECT wycieczka_id INTO znajdz_wycieczka FROM wycieczki WHERE wycieczka_id=wycieczka;
	SELECT uczestnik_id INTO znajdz_klient FROM uczestnicy WHERE uczestnik_id=klient;
	SELECT klasa INTO znajdz_klasa FROM klasy_ofert WHERE klasa=klasa_zam;
	IF (znajdz_wycieczka IS NULL) THEN
		RAISE EXCEPTION 'Nie istnieje wycieczka o takim numerze.';
	ELSIF (znajdz_klient IS NULL) THEN
		RAISE EXCEPTION 'Nie istnieje klient o takim numerze.';
	ELSIF (znajdz_klasa IS NULL) THEN
		RAISE EXCEPTION 'Niepoprawny numer klasy.';
	END IF;
	INSERT INTO zamowienia(klient_id,wycieczka_id,wartosc_zamowienia,klasa_oferty,sposob_platnosci) 
		VALUES (klient,wycieczka,0,klasa_zam,platnosc);
	RETURN 'Pomyslnie zlozono zamowienie.';
END;
$$ LANGUAGE 'plpgsql';


--edycja zamowienia
CREATE OR REPLACE FUNCTION edytuj_zamowienie(id_zam INTEGER, klasa_nowa INTEGER, platnosc_nowa VARCHAR(100)) RETURNS TEXT AS $$
DECLARE
	znajdz_zam INTEGER;
	cena DECIMAL(10,2);
	oferta INTEGER;
	znajdz_klasa INTEGER;
	id_wyc INTEGER;
	osoby_nowe INTEGER;
BEGIN
	SELECT klasa INTO znajdz_klasa FROM klasy_ofert WHERE klasa=klasa_nowa;
	SELECT count(zamowienie_id) INTO znajdz_zam FROM zamowienia WHERE zamowienie_id=id_zam;
	IF (znajdz_klasa IS NULL) THEN
		RAISE EXCEPTION 'Niepoprawny numer klasy.';
	ELSIF (znajdz_zam=0) THEN
		RAISE EXCEPTION 'Nie istnieje zamowienie o tym numerze.';
	END IF;
	SELECT count(u.uczestnik_id) INTO osoby_nowe FROM uczestnicy_w_zamowieniu u WHERE u.zamowienie_id=id_zam;
	SELECT wycieczka_id INTO id_wyc FROM zamowienia WHERE zamowienie_id=id_zam;
	SELECT oferta_id INTO oferta FROM wycieczki WHERE wycieczka_id=id_wyc;
	SELECT cena_podstawowa INTO cena FROM oferty WHERE oferta_id=oferta;
	SELECT mnoznik*cena*osoby_nowe INTO cena FROM klasy_ofert WHERE klasa=klasa_nowa;
	UPDATE zamowienia SET klasa_oferty=klasa_nowa,sposob_platnosci=platnosc_nowa,wartosc_zamowienia=cena WHERE zamowienie_id=id_zam;
	RETURN 'Pomyslnie zmodyfikowano zamowienie';
END;
$$ LANGUAGE 'plpgsql';


--usun zamowienie
CREATE OR REPLACE FUNCTION anuluj_zamowienie(id_zam INTEGER) RETURNS TEXT AS $$
DECLARE
	znajdz_zam INTEGER;
BEGIN
	SELECT count(zamowienie_id) INTO znajdz_zam FROM zamowienia WHERE zamowienie_id=id_zam;
	IF (znajdz_zam=0) THEN
		RAISE EXCEPTION 'Nie istnieje zamowienie o takim numerze ';
	END IF;
	DELETE FROM zamowienia WHERE zamowienie_id=id_zam;
	DELETE FROM uczestnicy_w_zamowieniu WHERE zamowienie_id=id_zam;
	RETURN 'Pomyslnie anulowano zamowienie';
END;
$$ LANGUAGE 'plpgsql';


--usun przewodnika z wycieczki
CREATE OR REPLACE FUNCTION usun_przewodnika(id_przewodnika INTEGER, id_wycieczki INTEGER) RETURNS TEXT AS $$
DECLARE
	znajdz_przew INTEGER;
	wycieczka INTEGER;
	przewodnik INTEGER;
BEGIN
	SELECT wycieczka_id INTO wycieczka FROM wycieczki WHERE wycieczka_id=id_wycieczki;
	SELECT przewodnik_id INTO przewodnik FROM przewodnicy WHERE przewodnik_id=id_przewodnika;
	IF (wycieczka IS NULL) THEN
		RAISE EXCEPTION 'Nie istnieje wycieczka o takim numerze.';
	ELSIF (przewodnik IS NULL) THEN
		RAISE EXCEPTION 'Nie istnieje przewodnik o takim numerze.';
	END IF;
	SELECT count(przewodnik_id) INTO znajdz_przew FROM przewodnictwa WHERE wycieczka_id=id_wycieczki AND przewodnik_id=id_przewodnika;
	IF (znajdz_przew=0) THEN
		RAISE EXCEPTION 'Przewodnik ten nie jest przypisany do tej wycieczki.';
	END IF;
	DELETE FROM przewodnictwa WHERE przewodnik_id=id_przewodnika;
	RETURN 'Pomyslnie usunieto przewodnika z wycieczki.';
END;
$$ LANGUAGE 'plpgsql';


--dodaj przewodnika do wycieczki
CREATE OR REPLACE FUNCTION dodaj_przewodnika(id_przewodnika INTEGER, id_wycieczki INTEGER) RETURNS TEXT AS $$
DECLARE
	wycieczka INTEGER;
	aktywnosc BOOLEAN;
	przewodnik INTEGER;
BEGIN
	SELECT wycieczka_id INTO wycieczka FROM wycieczki WHERE wycieczka_id=id_wycieczki;
	SELECT przewodnik_id INTO przewodnik FROM przewodnicy WHERE przewodnik_id=id_przewodnika;
	SELECT aktywny INTO aktywnosc FROM przewodnicy WHERE przewodnik_id=id_przewodnika;
	IF (wycieczka IS NULL) THEN
		RAISE EXCEPTION 'Nie istnieje wycieczka o takim numerze.';
	ELSIF (przewodnik IS NULL) THEN
		RAISE EXCEPTION 'Nie istnieje przewodnik o takim numerze.';
	ELSIF (NOT aktywnosc) THEN
		RAISE EXCEPTION 'Przewodnik o tym numerze juz u nas nie pracuje.';
	END IF;
	INSERT INTO przewodnictwa VALUES(id_przewodnika,id_wycieczki);
	RETURN 'Pomyslnie dodano przewodnika do wycieczki';
END;
$$ LANGUAGE 'plpgsql';


--dodaj klienta do bazy
CREATE OR REPLACE FUNCTION dodaj_klienta(imie_nowe VARCHAR(100), nazwisko_nowe VARCHAR(100), kraj VARCHAR(100), miasto_nowe VARCHAR(100), ulica_nowa VARCHAR(100), dom VARCHAR(100), kod VARCHAR(6), telefon VARCHAR(20), urodzony DATE, pesel_nowy VARCHAR(11) DEFAULT NULL) RETURNS TEXT AS $$
DECLARE 
	klient INTEGER;
BEGIN
	SELECT wyszukaj_klienta(imie_nowe, nazwisko_nowe, kraj, miasto_nowe, ulica_nowa, dom , kod, telefon , urodzony, pesel_nowy) INTO klient;
	IF (klient IS NOT NULL) THEN
		RAISE EXCEPTION 'Klient istnieje juz w bazie';
	END IF;
	INSERT INTO uczestnicy(imie,nazwisko,kraj_zamieszkania,miasto,kod_pocztowy,ulica,numer_domu,data_urodzenia,pesel,nr_telefonu) 
		VALUES(imie_nowe,nazwisko_nowe,kraj,miasto_nowe,kod,ulica_nowa,dom,urodzony,pesel_nowy,telefon);
	RETURN 'Pomyslnie dodano klienta.';
END;
$$ LANGUAGE 'plpgsql';


--znajdz klienta po danych 
CREATE OR REPLACE FUNCTION wyszukaj_klienta(imie_nowe VARCHAR(100), nazwisko_nowe VARCHAR(100), kraj VARCHAR(100), miasto_nowe VARCHAR(100), ulica_nowa VARCHAR(100), dom VARCHAR(100), kod VARCHAR(6), telefon VARCHAR(20), urodzony DATE, pesel_nowy VARCHAR(11) DEFAULT NULL) RETURNS INTEGER AS $$
DECLARE
	klient INTEGER;
BEGIN
	IF (pesel_nowy IS NOT NULL) THEN
		SELECT uczestnik_id INTO klient FROM uczestnicy 
			WHERE (imie=imie_nowe AND nazwisko=nazwisko_nowe AND kraj_zamieszkania=kraj 
				AND miasto=miasto_nowe AND ulica=ulica_nowa AND numer_domu=dom AND kod_pocztowy=kod 
				AND pesel=pesel_nowy AND nr_telefonu=telefon AND data_urodzenia=urodzony);
	ELSE
		SELECT uczestnik_id INTO klient FROM uczestnicy 
			WHERE (imie=imie_nowe AND nazwisko=nazwisko_nowe AND kraj_zamieszkania=kraj 
				AND miasto=miasto_nowe AND ulica=ulica_nowa AND numer_domu=dom AND kod_pocztowy=kod 
				AND pesel IS NULL AND nr_telefonu=telefon AND data_urodzenia=urodzony);
	END IF;
	RETURN klient;
END;
$$ LANGUAGE 'plpgsql';


--modyfikuj uczestnika 
CREATE OR REPLACE FUNCTION edytuj_klienta(id INTEGER, imie_nowe VARCHAR(100), nazwisko_nowe VARCHAR(100), kraj VARCHAR(100), miasto_nowe VARCHAR(100), ulica_nowa VARCHAR(100), dom VARCHAR(100), kod VARCHAR(6), telefon VARCHAR(20), urodzony DATE, pesel_nowy VARCHAR(100) DEFAULT NULL) RETURNS TEXT AS $$
BEGIN
	IF ((SELECT uczestnik_id FROM uczestnicy WHERE uczestnik_id=id) IS NULL) THEN
		RAISE EXCEPTION 'Nie istnieje taki uczestnik.';
	END IF;
	UPDATE uczestnicy SET imie=imie_nowe,nazwisko=nazwisko_nowe,kraj_zamieszkania=kraj,miasto=miasto_nowe,kod_pocztowy=kod,ulica=ulica_nowa,numer_domu=dom,data_urodzenia=urodzony,pesel=pesel_nowy,nr_telefonu=telefon WHERE uczestnik_id=id;
	RETURN 'Pomyslnie zmodyfikowano dane o uczestniku.';
END;
$$ LANGUAGE 'plpgsql';


--modyfikuj wycieczkę
CREATE OR REPLACE FUNCTION modyfikuj_wycieczke(id INTEGER, poczatek DATE) RETURNS TEXT AS $$
DECLARE
	oferta INTEGER;
	trwanie INTEGER;
BEGIN
	IF (poczatek<current_date) THEN
		RAISE EXCEPTION 'Nie mozna ustawic przeszlej daty wyjazdu.';
	END IF;
	SELECT oferta_id INTO oferta FROM wycieczki WHERE wycieczka_id=id;
	SELECT dlugosc_wyjazdu INTO trwanie FROM oferty WHERE oferta_id=oferta;
	UPDATE wycieczki SET data_rozpoczecia=poczatek, data_zakonczenia=poczatek+trwanie WHERE wycieczka_id=id;
	RETURN 'Pomyslnie zmieniono date wycieczki';
END;
$$ LANGUAGE 'plpgsql';


--przedstaw cene
CREATE OR REPLACE FUNCTION przedstaw_cene(wycieczka INTEGER, klasa_zam INTEGER, osoby INTEGER) RETURNS DECIMAL(10,2) AS $$
DECLARE
	oferta INTEGER;
	cena DECIMAL(10,2);
BEGIN
	SELECT oferta_id INTO oferta FROM wycieczki WHERE wycieczka_id=wycieczka;
	SELECT cena_podstawowa INTO cena FROM oferty WHERE oferta_id=oferta;
	SELECT mnoznik*cena INTO cena FROM klasy_ofert WHERE klasa=klasa_zam;
	RETURN cena*osoby;
END;
$$ LANGUAGE 'plpgsql';


--zatrudnij przewodnika
CREATE OR REPLACE FUNCTION zatrudnij(imie_nowe VARCHAR(100), nazwisko_nowe VARCHAR(100), telefon VARCHAR(20), znam BOOLEAN DEFAULT FALSE) RETURNS TEXT AS $$
DECLARE
	znajdz INTEGER;
	aktywny_czy BOOLEAN;
BEGIN
	SELECT przewodnik_id INTO znajdz FROM przewodnicy WHERE imie=imie_nowe AND nazwisko=nazwisko_nowe AND nr_telefonu=telefon;
	SELECT aktywny INTO aktywny_czy FROM przewodnicy WHERE imie=imie_nowe AND nazwisko=nazwisko_nowe AND nr_telefonu=telefon;
	IF (znajdz IS NOT NULL AND NOT znam AND NOT aktywny_czy) THEN
		RAISE EXCEPTION 'Uwaga! Ten przewodnik kiedys u nas pracowal.';
	ELSIF (znajdz IS NOT NULL AND NOT znam) THEN
		RAISE EXCEPTION 'Ten przewodnik juz u nas pracuje.';
	ELSIF (znajdz IS NOT NULL AND znam) THEN
		UPDATE przewodnicy SET aktywny=TRUE WHERE przewodnik_id=znajdz;
	ELSE
		INSERT INTO przewodnicy(imie,nazwisko,adres_email,nr_telefonu,aktywny) 
			VALUES(imie_nowe,nazwisko_nowe,imie_nowe||nazwisko_nowe||'@biuro_bazy.com',telefon,TRUE);
	END IF;
	RETURN 'Pomyslnie zatrudniono przewodnika.';
END;
$$ LANGUAGE 'plpgsql';


--zwolnij przewodnika
CREATE OR REPLACE FUNCTION zwolnij(id INTEGER) RETURNS TEXT AS $$
DECLARE
	znajdz INTEGER;
BEGIN
	SELECT przewodnik_id INTO znajdz FROM przewodnictwa JOIN wycieczki ON wycieczki.wycieczka_id=przewodnictwa.wycieczka_id WHERE data_zakonczenia>=current_date AND przewodnik_id=id;
	IF (znajdz IS NOT NULL) THEN	
		RAISE EXCEPTION 'Nie mozna zwolnic przewodnika jesli jest przypisany do przyszlej/trwajacej wycieczki.';
	ELSIF ((SELECT przewodnik_id FROM przewodnicy WHERE przewodnik_id=id) IS NULL) THEN
		RAISE EXCEPTION 'Pracownik o tym numerze nie istnieje.';
	END IF;
	UPDATE przewodnicy SET aktywny=FALSE WHERE przewodnik_id=id;
	RETURN 'Pomyslnie zwolniono przewodnika.';
END;
$$ LANGUAGE 'plpgsql';


--dodaj wycieczke
CREATE OR REPLACE FUNCTION dodaj_wycieczke(oferta INTEGER, poczatek DATE) RETURNS TEXT AS $$
DECLARE
	trwanie INTEGER;
BEGIN
	SELECT dlugosc_wyjazdu INTO trwanie FROM oferty WHERE oferta_id=oferta;
	INSERT INTO wycieczki(oferta_id,data_rozpoczecia,data_zakonczenia,liczba_uczestnikow) VALUES(oferta,poczatek,poczatek+trwanie,0);
	RETURN 'Pomyslnie utworzono nowa wycieczke.';
END;
$$ LANGUAGE 'plpgsql';


-- sprawdz zblizajace sie wycieczki
CREATE OR REPLACE FUNCTION zblizajace_sie_wycieczki(dni INTEGER) 
RETURNS TABLE ( wycieczka_id 		INTEGER,
				miejsce_wyjazdu  	VARCHAR(100),
				liczba_uczestnikow 	INTEGER,
				limit_uczestnikow  	INTEGER,
				data_rozpoczecia 	DATE,
				data_zakonczenia 	DATE,
				dlugosc_wyjazdu  	INTEGER,
				cena_podstawowa  	DECIMAL(10,2)
) AS $$
BEGIN
	RETURN QUERY
	SELECT w.wycieczka_id,
			o.miejsce_wyjazdu,
			w.liczba_uczestnikow,
			o.limit_uczestnikow,
			w.data_rozpoczecia ,
			w.data_zakonczenia,
			o.dlugosc_wyjazdu,
			o.cena_podstawowa
	FROM oferty o
		JOIN wycieczki w
			ON (w.oferta_id = o.oferta_id)
	WHERE w.data_rozpoczecia BETWEEN CURRENT_DATE AND CURRENT_DATE + dni
	ORDER BY data_rozpoczecia ASC;
END;
$$ LANGUAGE 'plpgsql';


--szukanie ofert z atrakcjami (wersja 'lub')
CREATE OR REPLACE FUNCTION oferty_z_atrakcjami(VARIADIC szukane_atrakcje TEXT[]) 
RETURNS TABLE(
oferta_id 			INTEGER,
				miejsce_wyjazdu  	VARCHAR,
				limit_uczestnikow  	INTEGER,
				dlugosc_wyjazdu  	INTEGER,
				cena_podstawowa  	DECIMAL,
				atrakcje			 TEXT[]
) AS $$
BEGIN
	RETURN QUERY
SELECT 	o.oferta_id,
			o.miejsce_wyjazdu,
			o.limit_uczestnikow,
			o.dlugosc_wyjazdu,
			o.cena_podstawowa,
			array_agg(a.atrakcja)::TEXT[]	
	FROM oferty o 
		JOIN atrakcje_w_ofercie ao
			ON (ao.oferta_id = o.oferta_id)
		JOIN atrakcje a
			ON (a.atrakcja = ao.atrakcja)
	WHERE o.oferta_id IN (SELECT 	o.oferta_id
						FROM oferty o 
							JOIN atrakcje_w_ofercie ao
								ON (ao.oferta_id = o.oferta_id)
							JOIN atrakcje a
								ON (a.atrakcja = ao.atrakcja)
						WHERE a.atrakcja LIKE ANY(szukane_atrakcje))
	GROUP BY (o.oferta_id, o.miejsce_wyjazdu, o.limit_uczestnikow, o.dlugosc_wyjazdu, o.cena_podstawowa);
END;
$$ LANGUAGE 'plpgsql';

-- szukanie ofert z atrakcjami (wersja 'wszystkie') 
CREATE OR REPLACE FUNCTION oferty_ze_wszystkimi_atrakcjami(VARIADIC szukane_atrakcje TEXT[]) 
RETURNS TABLE(
oferta_id 			INTEGER,
				miejsce_wyjazdu  	VARCHAR,
				limit_uczestnikow  	INTEGER,
				dlugosc_wyjazdu  	INTEGER,
				cena_podstawowa  	DECIMAL,
				atrakcje			 TEXT[]
) AS $$
BEGIN
	RETURN QUERY
	
	
SELECT 	o.oferta_id,
			o.miejsce_wyjazdu,
			o.limit_uczestnikow,
			o.dlugosc_wyjazdu,
			o.cena_podstawowa,
			array_agg(a.atrakcja)::TEXT[]	
	FROM oferty o 
		JOIN atrakcje_w_ofercie ao
			ON (ao.oferta_id = o.oferta_id)
		JOIN atrakcje a
			ON (a.atrakcja = ao.atrakcja)
	GROUP BY (o.oferta_id, o.miejsce_wyjazdu, o.limit_uczestnikow, o.dlugosc_wyjazdu, o.cena_podstawowa)
	HAVING array_agg(a.atrakcja)::TEXT[] @> szukane_atrakcje;
END;
$$ LANGUAGE 'plpgsql';


--szukanie ofert z tagami (wersja 'lub')
CREATE OR REPLACE FUNCTION oferty_z_tagami(VARIADIC szukane_tagi TEXT[]) 
RETURNS TABLE(
oferta_id 			INTEGER,
				miejsce_wyjazdu  	VARCHAR,
				limit_uczestnikow  	INTEGER,
				dlugosc_wyjazdu  	INTEGER,
				cena_podstawowa  	DECIMAL,
				tagi			 	TEXT[]
) AS $$
BEGIN
	RETURN QUERY
SELECT 	o.oferta_id,
			o.miejsce_wyjazdu,
			o.limit_uczestnikow,
			o.dlugosc_wyjazdu,
			o.cena_podstawowa,
			array_agg(t.tag)::TEXT[]	
	FROM oferty o 
		JOIN tagi_ofert t_o
			ON (t_o.oferta_id = o.oferta_id)
		JOIN tagi t
			ON (t.tag = t_o.tag)
	WHERE o.oferta_id IN (SELECT 	o.oferta_id
						FROM oferty o 
							JOIN tagi_ofert t_o
								ON (t_o.oferta_id = o.oferta_id)
							JOIN tagi t
								ON (t.tag = t_o.tag)
						WHERE t.tag LIKE ANY(szukane_tagi))
	GROUP BY (o.oferta_id, o.miejsce_wyjazdu, o.limit_uczestnikow, o.dlugosc_wyjazdu, o.cena_podstawowa);
END;
$$ LANGUAGE 'plpgsql';

-- szukanie ofert z tagami (wersja 'wszystkie')

CREATE OR REPLACE FUNCTION oferty_ze_wszystkimi_tagami(VARIADIC szukane_tagi TEXT[]) 
RETURNS TABLE(
oferta_id 			INTEGER,
				miejsce_wyjazdu  	VARCHAR,
				limit_uczestnikow  	INTEGER,
				dlugosc_wyjazdu  	INTEGER,
				cena_podstawowa  	DECIMAL,
				tagi			 TEXT[]
) AS $$
BEGIN
	RETURN QUERY
	
	
SELECT 	o.oferta_id,
			o.miejsce_wyjazdu,
			o.limit_uczestnikow,
			o.dlugosc_wyjazdu,
			o.cena_podstawowa,
			array_agg(t.tag)::TEXT[]	
	FROM oferty o 
		JOIN tagi_ofert t_o
			ON (t_o.oferta_id = o.oferta_id)
		JOIN tagi t
			ON (t.tag = t_o.tag)
	GROUP BY (o.oferta_id, o.miejsce_wyjazdu, o.limit_uczestnikow, o.dlugosc_wyjazdu, o.cena_podstawowa)
	HAVING array_agg(t.tag)::TEXT[] @> szukane_tagi;
END;
$$ LANGUAGE 'plpgsql';

--- tworzenie zamowienia na podstwie danych uczestnikow i klienta
-- przyjmuje iles stringow ktore mozna przerobic na krotki z danymi klienta w postaci '{"imie", "nazwisko","kraj", "miasto", "kod_pocztowy", "ulica", "numer_domu", "rrrr-mm-dd", "pesel"/NULL,"telefon"}'

CREATE OR REPLACE FUNCTION dodaj_zamowienie_z_klientami(wycieczka INTEGER, klasa_zam INTEGER, platnosc VARCHAR(100), VARIADIC uczestnicy_do_zamowienia TEXT[]) RETURNS TEXT AS $$
DECLARE
	oferta_limit INTEGER;
	liczba_ludzi INTEGER;
	znajdz_wycieczka INTEGER;
	znajdz_klasa INTEGER;
	liczba_uczestnikow INTEGER;
	dane_uczestnika TEXT[];
	imie_uczestnika TEXT;
	nazwisko_uczestnika TEXT;
	kraj_uczestnika  TEXT;
	miasto_uczestnika TEXT;
	data_uczestnika DATE;
	kod_pocztowy_uczestnika TEXT;
	numer_domu_uczestnika TEXT;
	telefon_uczestnika TEXT;
	pesel_uczestnika TEXT;
	ulica_uczestnika TEXT;
	nowy_uczestnik_id INTEGER;
	nowy_klient_id INTEGER;
	zlozone_zamowienie_id INTEGER;
	
	
BEGIN
	SELECT array_upper(uczestnicy_do_zamowienia, 1) INTO liczba_uczestnikow;
	SELECT wycieczka_id INTO znajdz_wycieczka FROM wycieczki WHERE wycieczka_id=wycieczka;SELECT o.limit_uczestnikow FROM oferty o JOIN wycieczki w ON (w.oferta_id = o.oferta_id) INTO oferta_limit;
	SELECT w.liczba_uczestnikow FROM wycieczki w WHERE w.wycieczka_id = znajdz_wycieczka INTO liczba_ludzi;
	IF (liczba_ludzi IS NULL) THEN
		liczba_ludzi := 0;
	END IF;
	IF (oferta_limit < (liczba_ludzi + liczba_uczestnikow)) THEN
		RAISE EXCEPTION 'Nie ma juz tyle wolnych miejsc na tej wycieczce!';
	END IF;
	SELECT klasa INTO znajdz_klasa FROM klasy_ofert WHERE klasa=klasa_zam;
	IF (znajdz_wycieczka IS NULL) THEN
		RAISE EXCEPTION 'Nie istnieje wycieczka o takim numerze.';
	ELSIF (znajdz_klasa IS NULL) THEN
		RAISE EXCEPTION 'Niepoprawny numer klasy.';
	END IF;
	
	-- szukamy i dodajemy klienta do bazy jesli go nie ma
	dane_uczestnika := uczestnicy_do_zamowienia[1]::TEXT[];
	imie_uczestnika := dane_uczestnika[1];
	nazwisko_uczestnika := dane_uczestnika[2];
	kraj_uczestnika  := dane_uczestnika[3];
	miasto_uczestnika := dane_uczestnika[4];
	kod_pocztowy_uczestnika := dane_uczestnika[5]::VARCHAR(6);
	ulica_uczestnika := dane_uczestnika[6];
	numer_domu_uczestnika := dane_uczestnika[7];
	data_uczestnika := dane_uczestnika[8]::DATE;
	pesel_uczestnika := dane_uczestnika[9];
	telefon_uczestnika := dane_uczestnika[10];
	
	SELECT wyszukaj_klienta(imie_uczestnika, nazwisko_uczestnika, kraj_uczestnika, miasto_uczestnika,
	ulica_uczestnika, numer_domu_uczestnika, kod_pocztowy_uczestnika, telefon_uczestnika , data_uczestnika, pesel_uczestnika) INTO nowy_klient_id;
	IF (nowy_klient_id IS NULL) THEN 
	PERFORM dodaj_klienta(imie_uczestnika, nazwisko_uczestnika, kraj_uczestnika, miasto_uczestnika, ulica_uczestnika, numer_domu_uczestnika, kod_pocztowy_uczestnika, telefon_uczestnika, data_uczestnika, pesel_uczestnika);
	SELECT wyszukaj_klienta(imie_uczestnika, nazwisko_uczestnika, kraj_uczestnika, miasto_uczestnika, ulica_uczestnika, numer_domu_uczestnika, kod_pocztowy_uczestnika, telefon_uczestnika , data_uczestnika, pesel_uczestnika) INTO nowy_klient_id;
	END IF;

	-- tworzymy nowe puste zamowienie 	
	PERFORM zloz_zamowienie(nowy_klient_id, wycieczka, klasa_zam, platnosc);
	
	SELECT max(zamowienie_id) FROM zamowienia WHERE klient_id = nowy_klient_id INTO zlozone_zamowienie_id;
	
	IF (liczba_uczestnikow > 1) THEN
	FOR i in 2 .. liczba_uczestnikow LOOP
    dane_uczestnika := uczestnicy_do_zamowienia[i]::TEXT[];
	imie_uczestnika := dane_uczestnika[1];
	nazwisko_uczestnika := dane_uczestnika[2];
	kraj_uczestnika  := dane_uczestnika[3];
	miasto_uczestnika := dane_uczestnika[4];
	kod_pocztowy_uczestnika := dane_uczestnika[5];
	ulica_uczestnika := dane_uczestnika[6];
	numer_domu_uczestnika := dane_uczestnika[7];
	data_uczestnika := dane_uczestnika[8]::DATE;
	pesel_uczestnika := dane_uczestnika[9];
	telefon_uczestnika := dane_uczestnika[10];
	
	SELECT wyszukaj_klienta(imie_uczestnika, nazwisko_uczestnika, kraj_uczestnika, miasto_uczestnika,ulica_uczestnika, numer_domu_uczestnika, kod_pocztowy_uczestnika, telefon_uczestnika , data_uczestnika, pesel_uczestnika) INTO nowy_uczestnik_id;
	IF (nowy_uczestnik_id IS NULL) THEN
	PERFORM dodaj_klienta(imie_uczestnika, nazwisko_uczestnika, kraj_uczestnika, miasto_uczestnika, ulica_uczestnika, numer_domu_uczestnika, kod_pocztowy_uczestnika, telefon_uczestnika, data_uczestnika, pesel_uczestnika);
	SELECT wyszukaj_klienta(imie_uczestnika::VARCHAR(100), nazwisko_uczestnika::VARCHAR(100), kraj_uczestnika::VARCHAR(100), miasto_uczestnika::VARCHAR(100), ulica_uczestnika::VARCHAR(100), numer_domu_uczestnika::VARCHAR(100), kod_pocztowy_uczestnika::VARCHAR(6), telefon_uczestnika::VARCHAR(20) , data_uczestnika::DATE, pesel_uczestnika::VARCHAR(11)) INTO nowy_uczestnik_id;
	END IF;
	
	INSERT INTO uczestnicy_w_zamowieniu(zamowienie_id, uczestnik_id) VALUES (zlozone_zamowienie_id, nowy_uczestnik_id);

  END LOOP;
	END IF;
	RETURN 'Pomyslnie zlozono zamowienie.';
END;
$$ LANGUAGE 'plpgsql';





