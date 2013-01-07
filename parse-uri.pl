%Fisicaro Simone 755547
parsed_uri(URIString, URI) :-

	URI = uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment),

	string_to_atom(URIString, URIAtom),
	atom_chars(URIAtom, URIChars),

	scheme(URIChars, Scheme1, Userinfo1, Host1, Port1, Path1, Query1, Fragment1),

	do_result(Scheme1, Scheme),
	do_result(Userinfo1, Userinfo),
	do_result(Host1, Host),
	do_result(Port1, Port),
	do_result(Path1, Path),
	do_result(Query1, Query),
	do_result(Fragment1, Fragment).

%Questo predicato viene usato per convertire la lista di caratteri nella string che viene data come output, nel caso la lista sia vuota non viene convertita.
do_result([], []) :- !.
do_result(List, Result) :- atom_chars(List1, List), string_to_atom(Result, List1).

%INIZIO CONTROLLO SCHEME

%Controllo se lo scheme è uguale a 'mailto', in quel caso passo al controllo specifico 'scheme_mailto'.
scheme([C1, C2, C3, C4, C5, C6, C7|Cs], [C1, C2, C3, C4, C5, C6], Userinfo, Host, [], [], [], []) :- C1=='m', C2=='a', C3=='i', C4=='l', C5=='t', C6=='o', C7==':', !, scheme_mailto(Cs, Userinfo, Host).
%Controllo se lo scheme è uguale a 'news', in quel caso passo al controllo specifico 'scheme_news'.
scheme([C1, C2, C3, C4, C5|Cs], [C1, C2, C3, C4], [], Host, [], [], [], []) :- C1=='n', C2=='e', C3=='w', C4=='s', C5==':', !, scheme_news(Cs, Host).
%Controllo se lo scheme è uguale a 'tel', in quel caso passo al controllo specifico 'scheme_tel_fax'.
scheme([C1, C2, C3, C4|Cs], [C1, C2, C3], Userinfo, [], [], [], [], []) :- C1=='t', C2=='e', C3=='l', C4==':', !, scheme_tel_fax(Cs, Userinfo).
%Controllo se lo scheme è uguale a 'fax', in quel caso passo al controllo specifico 'scheme_tel_fax'.
scheme([C1, C2, C3, C4|Cs], [C1, C2, C3], Userinfo, [], [], [], [], []) :- C1=='f', C2=='a', C3=='x', C4==':', !, scheme_tel_fax(Cs, Userinfo).
%Se non mi trovo nel caso di uno scheme specifico controllo che lo scheme sia un id valido e passo al controllo scheme_2.
scheme(Cs, Scheme, Userinfo, Host, Port, Path, Query, Fragment) :- id(Cs, Cs1, Scheme), scheme_2(Cs1, Userinfo, Host, Port, Path, Query, Fragment).
%Controllo che sia presente il ':' dopo lo scheme.
scheme_2([C|Cs], Userinfo, Host, Port, Path, Query, Fragment) :- C==':', scheme_3(Cs, Userinfo, Host, Port, Path, Query, Fragment).
%Se dopo il ':' ci sono due '/' allora mi trovo nel primo caso, 'caso_1', quello con autority.
scheme_3([C1, C2| Cs], Userinfo, Host, Port, Path, Query, Fragment) :- C1=='/', C2=='/', !, caso_1(Cs, Userinfo, Host, Port, Path, Query, Fragment).
%Altrimenti, se fallisce quello con authorithy, controllo se mi trovo nel caso rimanente, 'caso_2'.
scheme_3(Cs, Userinfo, Host, Port, Path, Query, Fragment) :- Userinfo=[], Host=[], Port=[], caso_2(Cs, Path, Query, Fragment).

%Casi specifici per gli scheme: mailto - news - tel - fax.
scheme_mailto(Cs, Userinfo, Host) :- id(Cs, Cs1, Userinfo), scheme_mailto_2(Cs1, Host).
scheme_mailto_2([], []) :- !.
scheme_mailto_2([C|Cs], Host) :- C=='@', host(Cs, [], Host).
scheme_news(Cs, Host) :- host(Cs, [], Host).
scheme_tel_fax(Cs, Userinfo) :- id(Cs, [], Userinfo).

%FINE CONTROLLO SCHEME.

%INIZIO CASO CON AUTHORITHY
%Controllo caso_1, quando è presente l'authorithy.
%Caso_1 si divide in due predicati, il primo controlla che ci sia la userinfo, nel caso non sia presente fallisce e passa il controllo a quello senza userinfo.
caso_1(Cs, Userinfo, Host, Port, Path, Query, Fragment) :- id(Cs, Cs1, Userinfo), caso_userinfo(Cs1, Host, Port, Path, Query, Fragment), !.
caso_1(Cs, [], Host, Port, Path, Query, Fragment) :- caso_nouserinfo(Cs, Host, Port, Path, Query, Fragment).

%Se è presente la '@' allora ci troviamo nel caso con userinfo e prosegue a controllare l'host.
caso_userinfo([C|Cs], Host, Port, Path, Query, Fragment) :- C=='@', !, caso_nouserinfo(Cs, Host, Port, Path, Query, Fragment).

%Il primo predicato caso_nouserinfo controlla che sia presente l'host.
caso_nouserinfo(Cs, Host, Port, Path, Query, Fragment) :- host(Cs, Cs1, Host), !, caso_nouserinfo_2(Cs1, Port, Path, Query, Fragment).
%In questo predicato viene controllato che sia presente port, precenuta da ':'.
caso_nouserinfo_2([C|Cs], Port, Path, Query, Fragment) :- C==':', !, port(Cs, Cs1, Port), caso_nouserinfo_3(Cs1, Path, Query, Fragment).
%Nel caso non sia presente port si passa a caso_nouserinfo_3.
caso_nouserinfo_2(Cs, [], Path, Query, Fragment) :- caso_nouserinfo_3(Cs, Path, Query, Fragment).

%Se è presente '/', si controlla path, query e fragment(non obbligatori), altrimenti non può esserci niente.
caso_nouserinfo_3([], [], [], []) :- !.
caso_nouserinfo_3([C|Cs], Path, Query, Fragment) :- C=='/', !, path(Cs, Path, Query, Fragment).
%FINE CASO CON AUTHORITHY

%INIZIO CASO SENZA AUTHORITHY
%Nel caso il caso_1 fallisca, il controllo passa al caso_2, la presenza di '/', path, query e fragment non è obbligatoria.
caso_2([C|Cs], Path, Query, Fragment) :- C=='/', !, path(Cs, Path, Query, Fragment).
caso_2(Cs, Path, Query, Fragment) :- path(Cs, Path, Query, Fragment).
%FINE CASO SENZA AUTHORITHY

%Un path è la concatenazione di almeno un id con altri id, divisi da un '/', se c'è un '/' deve esserci per forza un id dopo, se c'è un '?' si passa al controllo query, altrimenti si passa al fragment e la query rimarrà vuota.
path(Cs, Path, Query, Fragment) :- id(Cs, Cs1, Path1), !, path_2(Cs1, Path2, Query, Fragment), merge_list(Path1, Path2, Path).
path(Cs, Path, Query, Fragment) :- Path=[], query(Cs, Query, Fragment).
path_2([C|Cs], Path, Query, Fragment) :- C=='/', id(Cs, Cs1, Path1), !, path_2(Cs1, Path2, Query, Fragment), merge_list([C|Path1], Path2, Path).
path_2(Cs, [], Query, Fragment) :- query(Cs, Query, Fragment), !.

%Nel caso sia presente '?' allora viene verificato che sia presente una query, cioé, la concatenazione di qualsiasi carattere diverso da '#', se viene riconosciuto un '#', allora si passerà al controllo per il fragment.
query([C1, C2|Cs], [C2|Query], Fragment) :- C1=='?', C2\='#', !, query_2(Cs, Query, Fragment).
query([C|Cs], [], Fragment) :- C\='?', fragment(Cs, Fragment).
query_2([C|Cs], [C|Query], Fragment) :- C\='#', !, query_2(Cs, Query, Fragment).
query_2(Cs, [], Fragment) :- fragment(Cs, Fragment).

%Nel caso sia presente '#' allora viene verificato che sia presente un fragment, cioé, la concatenazione di qualsiasi carattere, con almeno un carattere.
fragment([], []) :- !.
fragment([C|Cs], Fragment) :- C=='#', fragment_2(Cs, Fragment).
fragment_2([C|Cs], [C|Fragment]) :- fragment_3(Cs, Fragment).
fragment_3([], []) :- !.
fragment_3([C|Cs], [C|Fragment]) :- fragment_3(Cs, Fragment).

%Un id è una stringa che non contiene questi caratteri: / ? # @ : non è riconosciuta la stringa vuota.
id([C|Cs], Cs1, [C|Is]) :- C\='/', C\='?', C\='#', C\='@', C\=':', !, id_2(Cs, Cs1, Is).
id_2([C|Cs], Cs1, [C|Is]) :- C\='/', C\='?', C\='#', C\='@', C\=':', !, id_2(Cs, Cs1, Is).
id_2(Cs, Cs, []).

%Un host è la concatenazione di più host_id, il predicato merge_list è usato per concatenare i vari risultati ricorsivamente.
host(Cs, Cs1, Host) :- indirizzo_ip(Cs, Cs1, Host), !.
host(Cs, Cs1, Host) :- host_id(Cs, Cs2, Host1), !, host_2(Cs2, Cs1, Host2), merge_list(Host1, Host2, Host).
host_2([], [], []) :- !.
host_2([C|Cs], Cs1, Host) :- C=='.', !, host_id(Cs, Cs2, Host1), host_2(Cs2, Cs1, Host2), merge_list([C|Host1], Host2, Host).
host_2(Cs, Cs, []).

%Un host_id è una stringa che non contiene questi caratteri: . / ? # @ : non è riconosciuta la stringa vuota.
host_id([C|Cs], Cs1, [C|Is]) :- C\='.', C\='/', C\='?', C\='#', C\='@', C\=':', !, host_id_2(Cs, Cs1, Is).
host_id_2([], [], []) :- !.
host_id_2([C|Cs], Cs1, [C|Is]) :- C\='.', C\='/', C\='?', C\='#', C\='@', C\=':', !, host_id_2(Cs, Cs1, Is).
host_id_2(Cs, Cs, []).

%Riconosce una porta, cioé, una concatenazione di digit, non è riconosciuta la stringa vuota.
port([C|Cs], Cs1, [C|Port]) :- digit(C), !, port_2(Cs, Cs1, Port).
port_2([C|Cs], Cs1, [C|Port]) :- digit(C), !, port_2(Cs, Cs1, Port).
port_2(Cs, Cs, []).

%Riconosce un indirizzo IP, composto da quattro gruppi di tre digit, divisi da un '.'.
indirizzo_ip([C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15|Cs], Cs, [C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15]) :- digit(C1), digit(C2), digit(C3), C4=='.', digit(C5), digit(C6), digit(C7), C8=='.', digit(C9), digit(C10), digit(C11), C12=='.', digit(C13), digit(C14), digit(C15).

%Riconosce se C è una cifra.
digit(C) :- C=='0'; C=='1'; C=='2'; C=='3'; C=='4'; C=='5'; C=='6'; C=='7'; C=='8'; C=='9'.

%Questi predicati servono a concatenare i risultati dell'host.
merge_list([], [], []) :- !.
merge_list([], Bs, Bs) :- !.
merge_list(As, [], As) :- !.
merge_list([A|As], Bs, [A|Cs]) :- merge_list(As, Bs, Cs).











