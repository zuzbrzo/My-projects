-- ile razy pojechali na wyjazd
CREATE VIEW  ile_razy_pojechal AS
SELECT u.uczestnik_id, COUNT(u.uczestnik_id) AS ile_razy
FROM uczestnicy u
		JOIN uczestnicy_w_zamowieniu z
			ON (u.uczestnik_id = z.uczestnik_id)
GROUP BY u.uczestnik_id;




-- uczestnicy jezdzączy cześciej niż średnia w ich kraju
CREATE VIEW czesciej_niz_standard AS
SELECT u.uczestnik_id, u.imie, u.nazwisko, u.kraj_zamieszkania, i.ile_razy
FROM uczestnicy u 
	JOIN ile_razy_pojechal i ON (i.uczestnik_id = u.uczestnik_id)
WHERE (CASE 
			WHEN u.kraj_zamieszkania LIKE 'Polska'
				THEN
					(i.ile_razy >= (SELECT AVG(i.ile_razy)
									FROM ile_razy_pojechal i
										JOIN  uczestnicy u 
											ON (i.uczestnik_id = u.uczestnik_id)
									WHERE u.kraj_zamieszkania LIKE 'Polska'
									)						
					)	
		WHEN u.kraj_zamieszkania LIKE 'Niemcy' 
			THEN
				(i.ile_razy >= (SELECT AVG(i.ile_razy)
								FROM ile_razy_pojechal i
									JOIN  uczestnicy u 
										ON (i.uczestnik_id = u.uczestnik_id)
								WHERE u.kraj_zamieszkania LIKE 'Niemcy'
								)
																	
				)
		WHEN u.kraj_zamieszkania LIKE 'Francja' 
			THEN
				(i.ile_razy >= (SELECT AVG(i.ile_razy)
								FROM ile_razy_pojechal i
								JOIN  uczestnicy u 
									ON (i.uczestnik_id = u.uczestnik_id)
								WHERE u.kraj_zamieszkania LIKE 'Francja'
								)
				)
		END 
		);
									
			
drop view if exists stali_klienci;
CREATE VIEW stali_klienci AS
SELECT z.klient_id, MAX(u.imie) AS imie, MAX(u.nazwisko) AS nazwisko, count(*) AS ile_kupil 
FROM uczestnicy u 
	JOIN zamowienia z 
			ON (z.klient_id = u.uczestnik_id)
GROUP BY z.klient_id
HAVING COUNT(*) > 3
ORDER BY count(*);


-- 10 najczęstszych miejsc docelowych wycieczek

CREATE VIEW najczestsze_cele AS
SELECT o.miejsce_wyjazdu, COUNT(o.miejsce_wyjazdu) AS ile_wycieczek
FROM oferty o
	JOIN wycieczki w 
		ON (o.oferta_id = w.oferta_id)
GROUP BY o.miejsce_wyjazdu
ORDER BY COUNT(*) DESC
LIMIT 10;



-- 5 najbardziej popularnych ofert 

CREATE VIEW najwiecej_odwiedzane_cele AS
SELECT o.miejsce_wyjazdu, SUM(w.liczba_uczestnikow) AS ile_osob_odwiedzilo
FROM oferty o
	JOIN wycieczki w 
		ON (o.oferta_id = w.oferta_id)
GROUP BY o.miejsce_wyjazdu
ORDER BY SUM(w.liczba_uczestnikow) DESC
LIMIT 10;





-- 10 przewodnikow z największą liczbą poprowadzonych wycieczek

CREATE VIEW najbardziej_doswiadczeni_przewodnicy AS
SELECT p.przewodnik_id, p.imie, p.nazwisko, COUNT(p.przewodnik_id) AS ile_wycieczek
FROM przewodnicy p
	JOIN przewodnictwa pa
		ON (p.przewodnik_id = pa.przewodnik_id)
GROUP BY (p.przewodnik_id, p.imie, p.nazwisko)
ORDER BY COUNT(p.przewodnik_id) DESC
LIMIT 10;



-- kolidujące wycieczki dla przewodników (id przewodnika - id wycieczki ktorej nie może poprowadzić bo już ma coś w tym terminie)

CREATE VIEW kolidujace_wycieczki_przewodnikow AS
SELECT DISTINCT p.przewodnik_id, w2.wycieczka_id AS wycieczka_z_kolizja
FROM przewodnicy p 
	JOIN przewodnictwa pa
		ON (p.przewodnik_id = pa.przewodnik_id)
	JOIN wycieczki w 
		ON (w.wycieczka_id = pa.wycieczka_id)
	JOIN wycieczki w2
		ON	(((w.data_rozpoczecia <= w2.data_rozpoczecia) 
				AND (w.data_zakonczenia >= w2.data_rozpoczecia)) 
			OR
			((w.data_rozpoczecia <= w2.data_zakonczenia) 
				AND (w.data_zakonczenia >= w2.data_zakonczenia)) 
			OR 
			((w.data_rozpoczecia >= w2.data_rozpoczecia) 
				AND (w.data_zakonczenia <= w2.data_zakonczenia)))
-- EXCEPT 
	-- SELECT DISTINCT p.przewodnik_id, w.wycieczka_id
-- FROM przewodnicy p 
	-- JOIN przewodnictwa pa
		-- ON (p.przewodnik_id = pa.przewodnik_id)
	-- JOIN wycieczki w 
		-- ON (w.wycieczka_id = pa.wycieczka_id)
ORDER BY przewodnik_id ASC;






CREATE VIEW statystyki_ofert AS
SELECT o.oferta_id, o.miejsce_wyjazdu, o.dlugosc_wyjazdu, MIN(date_part('year',age(u.data_urodzenia))) najmlodszy_uczestnik,
		MAX(date_part('year',age(u.data_urodzenia))) AS najstarszy_uczestnik,
		ROUND(AVG(date_part('year',age(u.data_urodzenia)))::DECIMAL(10,3),1) AS sredni_wiek_uczestnika,
		MODE() WITHIN GROUP (ORDER BY kraj_zamieszkania DESC) AS najwiecej_z_kraju
FROM oferty o
	JOIN wycieczki w
		ON (w.oferta_id = o.oferta_id)
	JOIN zamowienia z
		ON (z.wycieczka_id = w.wycieczka_id)
	JOIN uczestnicy_w_zamowieniu uz 
		ON (uz.zamowienie_id = z.zamowienie_id)
	JOIN uczestnicy u
		ON (u.uczestnik_id = uz.uczestnik_id)
GROUP BY (o.oferta_id, o.miejsce_wyjazdu, o.dlugosc_wyjazdu);
