--trigger ktory rzuca wyjatkiem jesli chcemy zlozyc/zmodyfikowac zamowienie na wycieczke 
--tak ze przekroczylibysmy maksa liczby osob
DROP FUNCTION limit_osob CASCADE;
CREATE FUNCTION limit_osob() RETURNS TRIGGER AS $$
DECLARE
	limit_osob INTEGER;
BEGIN
	SELECT limit_uczestnikow INTO limit_osob FROM oferty WHERE oferta_id=NEW.oferta_id;
	IF  (NEW.liczba_uczestnikow>limit_osob) THEN
		RAISE EXCEPTION 'Brak miejsc na wycieczce.';
	ELSE
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER sprawdz_limit_osob_wycieczki BEFORE UPDATE OR INSERT ON wycieczki
	FOR EACH ROW EXECUTE PROCEDURE limit_osob();


--trigger ktory update'uje liczbe uczestnikow na wycieczce po dodaniu/usunieciu/edycji uczestnictwa
DROP FUNCTION aktualizacja_liczby_uczestnikow CASCADE;
CREATE FUNCTION aktualizacja_liczby_uczestnikow() RETURNS TRIGGER AS $$
DECLARE
	stara_liczba INTEGER;
	nowa_liczba INTEGER;
	wycieczka INTEGER;
	zamowienie INTEGER;
BEGIN
	SELECT count(OLD.uczestnik_id) INTO stara_liczba;
	SELECT count(NEW.uczestnik_id) INTO nowa_liczba;
	SELECT z.wycieczka_id INTO wycieczka FROM zamowienia z WHERE z.zamowienie_id=NEW.zamowienie_id;
	IF (stara_liczba IS NULL) THEN
	stara_liczba := 0;
	ELSIF (nowa_liczba IS NULL) THEN
	nowa_liczba := 0;
	SELECT z.wycieczka_id INTO wycieczka FROM zamowienia z WHERE z.zamowienie_id=OLD.zamowienie_id;
	END IF;
	UPDATE wycieczki SET liczba_uczestnikow=liczba_uczestnikow+nowa_liczba-stara_liczba WHERE wycieczka_id=wycieczka;
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER aktualizacja_liczby_uczestnikow AFTER INSERT OR DELETE ON uczestnicy_w_zamowieniu
	FOR EACH ROW EXECUTE PROCEDURE aktualizacja_liczby_uczestnikow();


--nie mozna edytowac starych zamowień i wycieczek
DROP FUNCTION zostaw_stare CASCADE;
CREATE FUNCTION zostaw_stare() RETURNS TRIGGER AS $$
DECLARE
	koniec DATE;
BEGIN
	SELECT data_zakonczenia INTO koniec FROM wycieczki WHERE wycieczka_id=NEW.wycieczka_id;
	IF (NEW.wycieczka_id IS NULL) THEN
		SELECT data_zakonczenia INTO koniec FROM wycieczki WHERE wycieczka_id=OLD.wycieczka_id;
	END IF;
	IF (OLD.wycieczka_id IS NULL AND NEW.wycieczka_id IS NULL) THEN
		SELECT NEW.data_zakonczenia INTO koniec;
	END IF;
	IF (koniec<current_date) THEN
		RAISE EXCEPTION 'Nie wolno edytowac wycieczek ktore juz sie odbyly, ani zamowien zwiazanych z nimi.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER zostaw_stare_zamowienia_tr BEFORE INSERT OR UPDATE OR DELETE ON zamowienia
	FOR EACH ROW EXECUTE PROCEDURE zostaw_stare();
CREATE TRIGGER zostaw_stare_wycieczki_tr BEFORE INSERT OR UPDATE OR DELETE ON wycieczki
	FOR EACH ROW EXECUTE PROCEDURE zostaw_stare();


--spr data zakonczenia odpowiednio po rozpoczeciu
DROP FUNCTION spr_date CASCADE;
CREATE FUNCTION spr_date() RETURNS TRIGGER AS $$
DECLARE
	oferta INTEGER;
	trwanie INTEGER;
BEGIN
	SELECT dlugosc_wyjazdu INTO trwanie FROM oferty WHERE oferta_id=NEW.oferta_id;
	IF (NEW.data_zakonczenia-NEW.data_rozpoczecia!=trwanie) THEN
		RAISE EXCEPTION 'Daty wycieczki nie zgadzaja sie z dlugoscia trwania oferty';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER spr_date_tr BEFORE UPDATE OR INSERT ON wycieczki 
	FOR EACH ROW EXECUTE PROCEDURE spr_date();


--spr kod pocztowy
DROP FUNCTION spr_kod_pocztowy CASCADE;
CREATE FUNCTION spr_kod_pocztowy() RETURNS TRIGGER AS $$
BEGIN
	IF (NEW.kraj_zamieszkania = 'Polska' AND NEW.kod_pocztowy SIMILAR TO '[0-9]{2}-[0-9]{3}') THEN
		RETURN NEW;
	ELSIF (NEW.kraj_zamieszkania IN ('Francja','Niemcy') AND NEW.kod_pocztowy SIMILAR TO '[0-9]{5}') THEN
		RETURN NEW;
	ELSE
		RAISE EXCEPTION 'Niepoprawny kod pocztowy dla tego kraju.';
	END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER spr_kod_pocztowy_tr BEFORE INSERT OR UPDATE ON uczestnicy
	FOR EACH ROW EXECUTE PROCEDURE spr_kod_pocztowy();


--spr ze w wycieczce jest tyle osob co trzeba
DROP FUNCTION spr_ilosc_osob CASCADE; 
CREATE FUNCTION spr_ilosc_osob() RETURNS TRIGGER AS $$
DECLARE
	osoby_licz INTEGER;
BEGIN
	SELECT count(uz.uczestnik_id) INTO osoby_licz 
		FROM zamowienia z
		JOIN uczestnicy_w_zamowieniu uz ON z.zamowienie_id=uz.zamowienie_id
		WHERE wycieczka_id=NEW.wycieczka_id;
	IF (osoby_licz IS NULL) THEN
		osoby_licz:=0;
	END IF;
	IF (osoby_licz!=NEW.liczba_uczestnikow) THEN
		RAISE EXCEPTION 'Liczba uczestnikow wycieczki nie zgadza sie z iloscia osob w zamowieniach na te wycieczke.';
	ELSE
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER spr_ilosc_osob_tr BEFORE INSERT OR UPDATE ON wycieczki
	FOR EACH ROW EXECUTE PROCEDURE spr_ilosc_osob();


--spr zeby przewodnik sie nie bilokował
CREATE OR REPLACE FUNCTION przewodnik_w_jednym_miejscu() RETURNS TRIGGER AS $$
DECLARE
BEGIN
	IF (NEW.wycieczka_id IN (SELECT wycieczka_z_kolizja 
								FROM kolidujace_wycieczki_przewodnikow
								WHERE przewodnik_id=NEW.przewodnik_id)) THEN
		RAISE EXCEPTION 'Przewodnik jest w tym czasie zajety.';
	ELSE
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER spr_przewodnik_tr BEFORE INSERT OR UPDATE ON przewodnictwa
	FOR EACH ROW EXECUTE PROCEDURE przewodnik_w_jednym_miejscu();


--spr czy cena odpowiednia
DROP FUNCTION spr_cena CASCADE;
CREATE FUNCTION spr_cena() RETURNS TRIGGER AS $$
DECLARE
	oferta INTEGER;
	cena DECIMAL(10,2);
	liczba_osob INTEGER;
BEGIN
	SELECT oferta_id INTO oferta FROM wycieczki WHERE wycieczka_id=NEW.wycieczka_id;
	SELECT cena_podstawowa INTO cena FROM oferty WHERE oferta_id=oferta;
	SELECT count(uczestnik_id) INTO liczba_osob FROM uczestnicy_w_zamowieniu u WHERE u.zamowienie_id=NEW.zamowienie_id;
	SELECT mnoznik*cena*liczba_osob INTO cena FROM klasy_ofert WHERE klasa=NEW.klasa_oferty;
	IF (NEW.wartosc_zamowienia=cena) THEN
		RETURN NEW;
	ELSE
		RAISE EXCEPTION 'Wartosc zamowienia nie zgadza sie z warunkami zamowienia.';
	END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER spr_cena_tr BEFORE INSERT OR UPDATE ON zamowienia 
	FOR EACH ROW EXECUTE PROCEDURE spr_cena();


--trigger do dodania klienta do uczestnictw jak zlozy zamowienie
DROP FUNCTION dodaj_klienta_do_uczestnictw CASCADE;
CREATE FUNCTION dodaj_klienta_do_uczestnictw() RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO uczestnicy_w_zamowieniu VALUES(NEW.klient_id,NEW.zamowienie_id);
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER dodaj_klienta_do_uczestnictw_tr AFTER INSERT ON zamowienia
	FOR EACH ROW EXECUTE PROCEDURE dodaj_klienta_do_uczestnictw();


--trigger do aktualizacji ceny zamowienia po dodaniu uczestnictwa
DROP FUNCTION aktualizacja_ceny CASCADE;
CREATE FUNCTION aktualizacja_ceny() RETURNS TRIGGER AS $$
DECLARE
	cena DECIMAL(10,2);
BEGIN
	SELECT k.mnoznik*o.cena_podstawowa INTO cena FROM zamowienia z JOIN wycieczki w ON z.wycieczka_id=w.wycieczka_id 
							JOIN oferty o ON o.oferta_id=w.oferta_id
							JOIN klasy_ofert k ON k.klasa=z.klasa_oferty
							WHERE z.zamowienie_id=NEW.zamowienie_id;
	UPDATE zamowienia SET wartosc_zamowienia=wartosc_zamowienia+cena WHERE zamowienia.zamowienie_id=NEW.zamowienie_id;
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER aktualizacja_ceny_tr AFTER INSERT ON uczestnicy_w_zamowieniu
	FOR EACH ROW EXECUTE PROCEDURE aktualizacja_ceny();


--nie wolno aktualizowac uczestnictwa
DROP FUNCTION nie_wolno_update CASCADE;
CREATE FUNCTION nie_wolno_update() RETURNS TRIGGER AS $$
BEGIN
	RAISE EXCEPTION 'Uczestnictwa mozna jedynie usuwac i dodawac.';
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER nie_wolno_update_tr BEFORE UPDATE ON uczestnicy_w_zamowieniu
	FOR EACH ROW EXECUTE PROCEDURE nie_wolno_update();