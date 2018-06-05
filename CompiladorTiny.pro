%------------------- BNF DA LINGUAGEM TINY -----------------------------%

% <program> ::= program <cmd-list>
% <cmd-list> ::= <cmd> | <cmd> <cmd-list>
% <cmd> ::= (<assign> | <output> | <if> | <while>) ;
% <assign> ::= id = <int-expr>
% <output> ::= output <int-expr>
% <if> ::= if <bool-expr> then <cmd-list> | else <cmd-list> done | <empty> done
% <while> ::= while <bool-expr> do <cmd-list> done 
% <bool-expr> ::= false | true | <int-term> <rel_op> <int-term> | not <bool-expr>
% <int-expr> ::= <int-term> <arith_op> <int-term> | <int-term> <empty>
% <int-term> ::= id | const | read 
% <rel_op> ::= == | != | < | > | <= | >=
% <arith_op> ::= + | - | * | /

%-------------------FATOS-----------------------------------------------%

espaco(" ").
espaco("\n").
espaco("\t").

delimitadorS("+").
delimitadorS("-").
delimitadorS("*").
delimitadorS("/").
delimitadorS("=").
delimitadorS(";").

p_programa(["program"|O],O).
p_output(["output"|O],O).
p_if(["if"|O],O).
p_then(["then"|O],O).
p_else(["else"|O],O).
p_done(["done"|O],O).
p_while(["while"|O],O).
p_do(["do"|O],O).
p_false(["false"|O],O).
p_true(["true"|O],O).
p_not(["not"|O],O).
p_read(["read"|O],O).

a_adicao(["+"|O],O).
a_subtracao(["-"|O],O).
a_multiplicacao(["*"|O],O).
a_divisao(["/"|O],O).

r_igual(["=="|O],O).
r_diferente(["!="|O],O).
r_menor(["<"|O],O).
r_maior([">"|O],O).
r_menor_igual(["<="|O],O).
r_maior_igual([">="|O],O).

s_igual(["="|O],O).
s_ponto([";"|O],O).

digito(["0","1","2","3","4","5","6","7","8","9"]).
alfabeto(["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p",
          "q","r","s","t","u","v","w","x","y","z"]).

%-------------------- funcoes uteis ----------------------------%

token(S,0,"" ,[]).
token(S,0,Token,[Token]).
token(S,T,"" ,L):- sub_string(Sub1,S,0,1),
                   espaco(Sub1),
                   T1 is T - 1,
                   sub_string(Sub2,S,1,T1 ),
                   token(Sub2,T1,"",L).
token(S,T,Token,[Token|L]):- sub_string(Sub1,S,0,1),
                             espaco(Sub1),
                             T1 is T - 1,
                             sub_string(Sub2,S,1,T1),
                             token(Sub2,T1,"",L).
token(S,T,"" ,[Sub1|L]):- sub_string(Sub1,S,0,1),
                          delimitadorS(Sub1),
                          T1 is T - 1,
                          sub_string(Sub2,S,1,T1),
                          token(Sub2,T1,"",L).
token(S,T,Token,[Token,Sub1|L]):- sub_string(Sub1,S,0,1),
                                  delimitadorS(Sub1),
                                  T1 is T - 1,
                                  sub_string(Sub2,S,1,T1), 
                                  token(Sub2,T1,"",L).
token(S,T,Token,L):- sub_string(Sub1,S,0,1),
                     T1 is T - 1,
                     Token1 is Token + Sub1,
                     sub_string(Sub2,S,1,T1),
                     token(Sub2,T1,Token1,L).

%?- token("3 + 5",5,"",L), write(L), nl.

concatenacao([],L2,L2).
concatenacao(L1,[],L1).
concatenacao([H|T],L2,[H|L]):- concatenacao(T,L2,L).
 
%?- concatenacao([a,b],[d,c],L),write(L).

lerLinha(File,[]):- feof(File).
lerLinha(File,L):- Line is readln(File),
                   token(Line,str_length(Line),"",L1),
                   lerLinha(File,L2),
                   concatenacao(L1,L2,L).

%?- File is open("lixo.txt", "r"), lerLinha(File,L), write(L), close(File).

token_lista(S,0,[]).
token_lista(S,T,[Sub1|L]):- sub_string(Sub1,S,0,1),
                            T1 is T - 1,
                            sub_string(Sub2,S,1,T1),
                            token_lista(Sub2,T1,L).

%?- token_lista("lixo",4,L), write(L), nl.

membro(X,[X]).
membro(X,[X|T]).
membro(X,[H|T]):- membro(X,T).

%?- membro(a,[b,c,a]).
%?- membro(d,[b,c,a]).

avalia([H]):- alfabeto(A), membro(H,A).
avalia([H|T]):- alfabeto(A), membro(H,A), avalia(T).
%?- avalia(["a","b","c"]).


t_digito([H]):- digito(L), membro(H,L).
t_digito([H|T]):- digito(L), membro(H,L), t_digito(T).

%?- t_digito(["2","3"]).

%---------------------- funcoes do compilador ------------------------%

id([H|T],T):- token_lista(H,str_length(H),L),
              avalia(L).
%id(_,[]):- write("erro1: o identificador e formado so por letras minusculas"),nl.
%?- id(["bruno"]).

constante([H|T],T):- token_lista(H,str_length(H),L),
                     t_digito(L).
%constante(_,[]):- write("erro2: a constante e formada so por digitos numuricos"),nl.
%?- constante(["1542063"]).


compilador(L,O):- p_programa(L,O1), cmd_list(O1,O).

cmd_list(I,O):- cmd(I,O1), cmd_list(O1,O).
cmd_list(I,O):- cmd(I,O).

cmd(I,O):- assign(I,O1), s_ponto(O1,O).
cmd(I,O):- output(I,O1), s_ponto(O1,O).
cmd(I,O):- if(I,O1), s_ponto(O1,O).
cmd(I,O):- while(I,O1), s_ponto(O1,O).

assign(I,O):- id(I,O1), s_igual(O1,O2), int_expr(O2,O).

output(I,O):- p_output(I,O1), int_expr(O1,O).

if(I,O):- p_if(I,O1),
          bool_expr(O1,O2),
          p_then(O2,O3),
          cmd_list(O3,O).
if(I,O):- p_else(I,O1), 
          cmd_list(O1,O2),
          p_done(O2,O).
if(I,O):- p_done(I,O).

while(I,O):- p_while(I,O1),
             bool_expr(O1,O2),
             p_do(O2,O3),
             cmd_list(O3,O4),
             p_done(O4,O).

bool_expr(I,O):- p_false(I,O).
bool_expr(I,O):- p_true(I,O).
bool_expr(I,O):- int_term(I,O1), rel_op(O1,O2), int_term(O2,O).
bool_expr(I,O):- p_not(I,O1), bool_expr(O1,O).

int_expr(I,O):- int_term(I,O1),
                arith_op(O1,O2),
                int_term(O2,O).
int_expr(I,O):- int_term(I,O).

int_term(I,O):- id(I,O);
                constante(I,O);
                p_read(I,O).

rel_op(I,O):- r_igual(I,O);
              r_diferente(I,O);
              r_menor(I,O);
              r_maior(I,O);
              r_menor_igual(I,O);
              r_maior_igual(I,O).

arith_op(I,O):- a_adicao(I,O);
                a_subtracao(I,O);
                a_multiplicacao(I,O);
                a_divisao(I,O).

?- File is open("teste.txt","r"), lerLinha(File,L),
   compilador(L,O), write(O),nl, close(File).