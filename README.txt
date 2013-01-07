Fisicaro Simone 755547

All'inizio la stringa data in input viene convertita in una lista di caratteri.

I predicati usati per convertire la stringa sono stati presi da quelli standard 
di Prolog, i predicati sono:

- string_to_atom/2
- atom_chars/2

questi due predicati vencono usati alla fine per programma per convertire le
varie liste che sono i risultati in stringhe.

Il Parser analizza una lista data in input ricorsivamente, carattere per 
carattere, fin quando non arriva, o alla fine e quindi si svuota la lista, o 
incontra un errore e quindi la string non viene riconosciuta, la selezione del
percorso da seguire viene fatta mediante l'eventuale fallimento di alcuni 
predicati accopiati con dei cut.

Il programma si divide sostanzialmente in tre parti:

- nella prima controlla la presenza di eventuali scheme particolari(mailto, news, ...),
  se sono presenti gestisce i semplici casi che ne conseguono, se non fossero
  presenti, allora si controlla che lo scheme è uno scheme valido.
- se ci troviamo in uno scheme generico e la stringa inizia con '//' allora 
  controllo il caso con authorithy facendo i relativi controlli.
- se la stringa non inizia con '//' allora mi trovo nell'ultimo caso rimanente,
  quello senza authorithy, i controlli di questo riportano alla parte finale 
  del controllo di authorithy.

Alla fine il predicato do_result/2 trasforma i singoli risultati da liste a stringhe, 
questo solo nel caso le stringhe non siano vuote.  
