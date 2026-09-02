drop table if exists empresas_ramo ;
drop table if exists zona_transportes ;
drop table if exists estabelecimentos_transportes ;
drop table if exists estabelecimentos_produtos ;
drop table if exists alunos ;
drop table if exists utilizador ;
drop table if exists formador ;
drop table if exists administrativo ;
drop table if exists estagio ;
drop table if exists avaliacao_anual_estabelecimento ;
drop table if exists curso ;
drop table if exists turma ;
drop table if exists vagas ;
drop table if exists empresas ;
drop table if exists estabelecimentos ;
drop table if exists ramo ;
drop table if exists zona ;
drop table if exists transporte ;
drop table if exists produtos ;
drop table if exists responsavel ;
drop table if exists ano_letivo ;
 
create table empresas_ramo
(
   empresas_empresas_ID_   integer   not null,
   ramo_ramo_ID_   integer   not null,
 
   constraint PK_empresas_ramo primary key (empresas_empresas_ID_, ramo_ramo_ID_)
);
 
create table zona_transportes
(
   zona_zona_ID_   integer   not null,
   transporte_transporte_ID_   integer   not null,
 
   constraint PK_zona_transportes primary key (zona_zona_ID_, transporte_transporte_ID_)
);
 
create table estabelecimentos_transportes
(
   estabelecimentos_empresas_empresas_ID_   integer   not null,
   estabelecimentos_estabelecimentos_ID_   integer   not null,
   transporte_transporte_ID_   integer   not null,
 
   constraint PK_estabelecimentos_transportes primary key (estabelecimentos_empresas_empresas_ID_, estabelecimentos_estabelecimentos_ID_, transporte_transporte_ID_)
);
 
create table estabelecimentos_produtos
(
   estabelecimentos_empresas_empresas_ID_   integer   not null,
   estabelecimentos_estabelecimentos_ID_   integer   not null,
   produtos_produtos_ID_   integer   not null,
 
   constraint PK_estabelecimentos_produtos primary key (estabelecimentos_empresas_empresas_ID_, estabelecimentos_estabelecimentos_ID_, produtos_produtos_ID_)
);
 
create table alunos
(
   utilizador_utilizador_ID   integer   not null,
   administrativo_utilizador_utilizador_ID   integer   not null,
   turma_turma_ID   integer   not null,
   numero   Integer   null,
   observacoes   text   null,
 
   constraint PK_alunos primary key (utilizador_utilizador_ID)
);
 
create table utilizador
(
   utilizador_ID   integer   not null,
   nome   text   null,
   login   text   null,
   password   text   null,
 
   constraint PK_utilizador primary key (utilizador_ID)
);
 
create table formador
(
   utilizador_utilizador_ID   integer   not null,
   numero   Integer   null,
   disciplina   text   null,
 
   constraint PK_formador primary key (utilizador_utilizador_ID)
);
 
create table administrativo
(
   utilizador_utilizador_ID   integer   not null,
 
   constraint PK_administrativo primary key (utilizador_utilizador_ID)
);
 
create table estagio
(
   alunos_utilizador_utilizador_ID   integer   not null,
   formador_utilizador_utilizador_ID   integer   not null,
   estabelecimentos_empresas_empresas_ID   integer   not null,
   estabelecimentos_estabelecimentos_ID   integer   not null,
   responsavel_estabelecimentos_empresas_empresas_ID   integer   not null,
   responsavel_estabelecimentos_estabelecimentos_ID   integer   not null,
   responsavel_responsavel_ID   integer   not null,
   estagio_ID   integer   not null,
   data_inicio   text   null,
   data_fim   text   null,
   nota_dada_empresa   Integer   null,
   nota_dada_escola   Integer   null,
   nota_relatorio   Integer   null,
   nota_procura   Integer   null,
   nota_final   Integer   null,
   nota_dada_pelo_aluno   Integer   null,
 
   constraint PK_estagio primary key (estagio_ID)
);
 
create table avaliacao_anual_estabelecimento
(
   estabelecimentos_empresas_empresas_ID   integer   not null,
   estabelecimentos_estabelecimentos_ID   integer   not null,
   ano_letivo_ano_letivo_ID   integer   not null,
   avaliacao_anual_estabelecimento_ID   integer   not null,
   media_avaliacoes   Integer   null,
 
   constraint PK_avaliacao_anual_estabelecimento primary key (avaliacao_anual_estabelecimento_ID)
);
 
create table curso
(
   curso_ID   integer   not null,
   designacao   text   null,
   codigo   Integer   null,
 
   constraint PK_curso primary key (curso_ID)
);
 
create table turma
(
   curso_curso_ID   integer   not null,
   ano_letivo_ano_letivo_ID   integer   not null,
   turma_ID   integer   not null,
   sigla   text   null,
 
   constraint PK_turma primary key (turma_ID)
);
 
create table vagas
(
   empresas_empresas_ID   integer   not null,
   ano_letivo_ano_letivo_ID   integer   not null,
   vagas_ID   integer   not null,
   n_vagas   Integer   null,
   vagas_cheias   bit   null,
 
   constraint PK_vagas primary key (empresas_empresas_ID, vagas_ID)
);
 
create table empresas
(
   administrativo_utilizador_utilizador_ID   integer   not null,
   empresas_ID   integer   not null,
   firma   text   null,
   contribuinte   Integer   null,
   morada   text   null,
   localidade   text   null,
   codigo_postal   text   null,
   telefone   Integer   null,
   email   text   null,
   website   text   null,
   observacoes   text   null,
 
   constraint PK_empresas primary key (empresas_ID)
);
 
create table estabelecimentos
(
   administrativo_utilizador_utilizador_ID   integer   not null,
   empresas_empresas_ID   integer   not null,
   zona_zona_ID   integer   not null,
   estabelecimentos_ID   integer   not null,
   nome   text   null,
   tipo_estabelecimento   text   null,
   morada   text   null,
   localidade   text   null,
   codigo_postal   text   null,
   telefone   Integer   null,
   email   text   null,
   foto   text   null,
   horario   text   null,
   data_fundacao   text   null,
   ja_aceitou_estagiarios   bit   null,
   observacoes   text   null,
 
   constraint PK_estabelecimentos primary key (empresas_empresas_ID, estabelecimentos_ID)
);
 
create table ramo
(
   administrativo_utilizador_utilizador_ID   integer   not null,
   ramo_ID   integer   not null,
   CAE   text   null,
   descricao   text   null,
 
   constraint PK_ramo primary key (ramo_ID)
);
 
create table zona
(
   zona_ID   integer   not null,
   localidade   text   null,
   mapa   text   null,
   designacao   text   null,
 
   constraint PK_zona primary key (zona_ID)
);
 
create table transporte
(
   transporte_ID   integer   not null,
   meio_transporte   text   null,
   linha   text   null,
   observacoes   text   null,
 
   constraint PK_transporte primary key (transporte_ID)
);
 
create table produtos
(
   produtos_ID   integer   not null,
   nome   text   null,
   marca   text   null,
   tipo_produto   text   null,
 
   constraint PK_produtos primary key (produtos_ID)
);
 
create table responsavel
(
   estabelecimentos_empresas_empresas_ID   integer   not null,
   estabelecimentos_estabelecimentos_ID   integer   not null,
   responsavel_ID   integer   not null,
   nome   text   null,
   titulo   text   null,
   cargo   text   null,
   telefone   Integer   null,
   email   text   null,
   telemovel   Integer   null,
   observacoes   text   null,
 
   constraint PK_responsavel primary key (estabelecimentos_empresas_empresas_ID, estabelecimentos_estabelecimentos_ID, responsavel_ID)
);
 
create table ano_letivo
(
   ano_letivo_ID   integer   not null,
   ano   Integer   null,
 
   constraint PK_ano_letivo primary key (ano_letivo_ID)
);
 
alter table empresas_ramo
   add constraint FK_empresas_empresas_ramo_ramo_ foreign key (empresas_empresas_ID_)
   references empresas(empresas_ID)
   on delete cascade
   on update cascade
; 
alter table empresas_ramo
   add constraint FK_ramo_empresas_ramo_empresas_ foreign key (ramo_ramo_ID_)
   references ramo(ramo_ID)
   on delete cascade
   on update cascade
;
 
alter table zona_transportes
   add constraint FK_zona_zona_transportes_transporte_ foreign key (zona_zona_ID_)
   references zona(zona_ID)
   on delete cascade
   on update cascade
; 
alter table zona_transportes
   add constraint FK_transporte_zona_transportes_zona_ foreign key (transporte_transporte_ID_)
   references transporte(transporte_ID)
   on delete cascade
   on update cascade
;
 
alter table estabelecimentos_transportes
   add constraint FK_estabelecimentos_estabelecimentos_transportes_transporte_ foreign key (estabelecimentos_empresas_empresas_ID_, estabelecimentos_estabelecimentos_ID_)
   references estabelecimentos(empresas_empresas_ID, estabelecimentos_ID)
   on delete cascade
   on update cascade
; 
alter table estabelecimentos_transportes
   add constraint FK_transporte_estabelecimentos_transportes_estabelecimentos_ foreign key (transporte_transporte_ID_)
   references transporte(transporte_ID)
   on delete cascade
   on update cascade
;
 
alter table estabelecimentos_produtos
   add constraint FK_estabelecimentos_estabelecimentos_produtos_produtos_ foreign key (estabelecimentos_empresas_empresas_ID_, estabelecimentos_estabelecimentos_ID_)
   references estabelecimentos(empresas_empresas_ID, estabelecimentos_ID)
   on delete cascade
   on update cascade
; 
alter table estabelecimentos_produtos
   add constraint FK_produtos_estabelecimentos_produtos_estabelecimentos_ foreign key (produtos_produtos_ID_)
   references produtos(produtos_ID)
   on delete cascade
   on update cascade
;
 
alter table alunos
   add constraint FK_alunos_utilizador foreign key (utilizador_utilizador_ID)
   references utilizador(utilizador_ID)
   on delete cascade
   on update cascade
; 
alter table alunos
   add constraint FK_alunos_noname_administrativo foreign key (administrativo_utilizador_utilizador_ID)
   references administrativo(utilizador_utilizador_ID)
   on delete restrict
   on update cascade
; 
alter table alunos
   add constraint FK_alunos_turma_alunos_turma foreign key (turma_turma_ID)
   references turma(turma_ID)
   on delete restrict
   on update cascade
;
 
 
alter table formador
   add constraint FK_formador_utilizador foreign key (utilizador_utilizador_ID)
   references utilizador(utilizador_ID)
   on delete cascade
   on update cascade
;
 
alter table administrativo
   add constraint FK_administrativo_utilizador foreign key (utilizador_utilizador_ID)
   references utilizador(utilizador_ID)
   on delete cascade
   on update cascade
;
 
alter table estagio
   add constraint FK_estagio_noname_alunos foreign key (alunos_utilizador_utilizador_ID)
   references alunos(utilizador_utilizador_ID)
   on delete restrict
   on update cascade
; 
alter table estagio
   add constraint FK_estagio_noname_formador foreign key (formador_utilizador_utilizador_ID)
   references formador(utilizador_utilizador_ID)
   on delete restrict
   on update cascade
; 
alter table estagio
   add constraint FK_estagio_noname_estabelecimentos foreign key (estabelecimentos_empresas_empresas_ID, estabelecimentos_estabelecimentos_ID)
   references estabelecimentos(empresas_empresas_ID, estabelecimentos_ID)
   on delete restrict
   on update cascade
; 
alter table estagio
   add constraint FK_estagio_noname_responsavel foreign key (responsavel_estabelecimentos_empresas_empresas_ID, responsavel_estabelecimentos_estabelecimentos_ID, responsavel_responsavel_ID)
   references responsavel(estabelecimentos_empresas_empresas_ID, estabelecimentos_estabelecimentos_ID, responsavel_ID)
   on delete restrict
   on update cascade
;
 
alter table avaliacao_anual_estabelecimento
   add constraint FK_avaliacao_anual_estabelecimento_noname_estabelecimentos foreign key (estabelecimentos_empresas_empresas_ID, estabelecimentos_estabelecimentos_ID)
   references estabelecimentos(empresas_empresas_ID, estabelecimentos_ID)
   on delete restrict
   on update cascade
; 
alter table avaliacao_anual_estabelecimento
   add constraint FK_avaliacao_anual_estabelecimento_noname_ano_letivo foreign key (ano_letivo_ano_letivo_ID)
   references ano_letivo(ano_letivo_ID)
   on delete restrict
   on update cascade
;
 
 
alter table turma
   add constraint FK_turma_noname_curso foreign key (curso_curso_ID)
   references curso(curso_ID)
   on delete restrict
   on update cascade
; 
alter table turma
   add constraint FK_turma_noname_ano_letivo foreign key (ano_letivo_ano_letivo_ID)
   references ano_letivo(ano_letivo_ID)
   on delete restrict
   on update cascade
;
 
alter table vagas
   add constraint FK_vagas_empresas_vagas_empresas foreign key (empresas_empresas_ID)
   references empresas(empresas_ID)
   on delete cascade
   on update cascade
; 
alter table vagas
   add constraint FK_vagas_noname_ano_letivo foreign key (ano_letivo_ano_letivo_ID)
   references ano_letivo(ano_letivo_ID)
   on delete restrict
   on update cascade
;
 
alter table empresas
   add constraint FK_empresas_noname_administrativo foreign key (administrativo_utilizador_utilizador_ID)
   references administrativo(utilizador_utilizador_ID)
   on delete restrict
   on update cascade
;
 
alter table estabelecimentos
   add constraint FK_estabelecimentos_noname_administrativo foreign key (administrativo_utilizador_utilizador_ID)
   references administrativo(utilizador_utilizador_ID)
   on delete restrict
   on update cascade
; 
alter table estabelecimentos
   add constraint FK_estabelecimentos_empresas_estabelecimentos_empresas foreign key (empresas_empresas_ID)
   references empresas(empresas_ID)
   on delete cascade
   on update cascade
; 
alter table estabelecimentos
   add constraint FK_estabelecimentos_estabelecimentos_zona_zona foreign key (zona_zona_ID)
   references zona(zona_ID)
   on delete restrict
   on update cascade
;
 
alter table ramo
   add constraint FK_ramo_noname_administrativo foreign key (administrativo_utilizador_utilizador_ID)
   references administrativo(utilizador_utilizador_ID)
   on delete restrict
   on update cascade
;
 
 
 
 
alter table responsavel
   add constraint FK_responsavel_estabelecimentos_repsonsavel_estabelecimentos foreign key (estabelecimentos_empresas_empresas_ID, estabelecimentos_estabelecimentos_ID)
   references estabelecimentos(empresas_empresas_ID, estabelecimentos_ID)
   on delete cascade
   on update cascade
;
 
 
