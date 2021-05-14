-- tagi_ofert

ALTER TABLE tagi_ofert ADD CONSTRAINT tagi_ofert_oferta FOREIGN KEY (oferta_id)
	REFERENCES oferty(oferta_id) ON DELETE RESTRICT ON UPDATE CASCADE;
	
ALTER TABLE tagi_ofert ADD CONSTRAINT tagi_ofert_tag FOREIGN KEY (tag)
	REFERENCES tagi(tag) ON DELETE RESTRICT ON UPDATE CASCADE;


-- przewodnictwa	
ALTER TABLE przewodnictwa ADD CONSTRAINT przewodnictwa_przewodnik FOREIGN KEY (przewodnik_id)
	REFERENCES przewodnicy(przewodnik_id) ON DELETE RESTRICT ON UPDATE CASCADE;
	
ALTER TABLE przewodnictwa ADD CONSTRAINT przewodnictwa_wycieczka FOREIGN KEY (wycieczka_id)
	REFERENCES wycieczki(wycieczka_id) ON DELETE RESTRICT ON UPDATE CASCADE;


-- atrakcje_w_ofercie
	
ALTER TABLE atrakcje_w_ofercie ADD CONSTRAINT atrakcje_w_ofercie_oferta FOREIGN KEY (oferta_id)
	REFERENCES oferty(oferta_id) ON DELETE RESTRICT ON UPDATE CASCADE;
	
ALTER TABLE atrakcje_w_ofercie ADD CONSTRAINT atrakcje_w_ofercie_atrakcja FOREIGN KEY (atrakcja)
	REFERENCES atrakcje(atrakcja) ON DELETE RESTRICT ON UPDATE CASCADE;
	

-- zamowienia
	
ALTER TABLE zamowienia ADD FOREIGN KEY (klient_id) 
	REFERENCES uczestnicy(uczestnik_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE zamowienia ADD FOREIGN KEY (wycieczka_id) 
	REFERENCES wycieczki(wycieczka_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE zamowienia ADD FOREIGN KEY (klasa_oferty) 
	REFERENCES klasy_ofert(klasa) ON UPDATE CASCADE ON DELETE RESTRICT;


--wycieczki 

ALTER TABLE wycieczki ADD FOREIGN KEY (oferta_id) 
	REFERENCES oferty(oferta_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


-- uczestnicy_w_zamowieniu

ALTER TABLE uczestnicy_w_zamowieniu ADD FOREIGN KEY (uczestnik_id)
	REFERENCES uczestnicy(uczestnik_id) ON UPDATE CASCADE ON DELETE RESTRICT;
	
ALTER TABLE uczestnicy_w_zamowieniu ADD FOREIGN KEY (zamowienie_id)
	REFERENCES zamowienia(zamowienie_id) ON UPDATE CASCADE ON DELETE CASCADE;
	