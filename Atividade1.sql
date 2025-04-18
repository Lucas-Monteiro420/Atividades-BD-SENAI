create database sistemaAcademico;
use sistemaAcademico;
create table CURSO(
    CODCURSO char(3) not null,
    NOME char(30),
    MENSALIDADE decimal(6,2),
    primary key(CODCURSO)
);
create table ALUNO(
    RA char(9) not null primary key,
    RG char(9) not null,
    NOME char(30),
    CODCURSO char(3),
    foreign key (CODCURSO) references CURSO (CODCURSO)
);
create table DISCIPLINA(
    CodDisc char(5) not null,
    Nome char(30),
    CodCurso char(3),
    NroCreditos int,
    primary key (CodDisc),
    foreign key (CodCurso) references CURSO(codcurso)
);
create table BOLETIM(
    Ra char(9) not null,
    CodDisc char(5) not null,
    Nota decimal(5,2),
    primary key (Ra, CodDisc),
    foreign key (Ra) references ALUNO (Ra),
    foreign key (CodDisc) references DISCIPLINA (CodDisc)
);
insert into 
    CURSO (CODCURSO, NOME, MENSALIDADE)
    values 
    ('AS','ANALISE DE SISTEMAS',1000.00),
    ('CC','CIENCIA DA COMPUTAÇÃO',950.00),
    ('SI','SISTEMAS DE INFORMACAO',800.00);

insert into ALUNO (RA,RG,NOME,CODCURSO)
    values 
    ('123','12345','BIANCA MARIA PEDROSA','AS'),
    ('212','21234','TATIANE CITTON','AS'),
    ('221','22145','ALEXANDRE PEDROSA','CC'),
    ('231','23144','ALEXANDRE MONTEIRO','CC'),
    ('321','32111','MARCIA RIBEIRO','CC'),
    ('661','66123','JUSSARA MARANDOLA','SI'),
    ('765','76512','WALTER RODRIGUES','SI');
    
insert into DISCIPLINA values
('BD','BANCO DE DADOS','CC',4),
('BDA','BANCO DE DADOS AVANCADOS','CC',6),
('BDOO','BANCO DE DADOS O OBJETOS','SI',4),
('BDS','SISTEMAS DE BANCO DE DADOS','AS', 4),
('DBD','DESENVOLVIMENTO BANCO DE DADOS','SI',6),
('IBD','INTRODUC AO A BANCO DE DADOS','AS',2);

insert into BOLETIM values 
('123','BDS',10),
('212','IBD',7.5),
('231','BD',9),
('231','BDA',9.6),
('661','DBD',8),
('765','DBD',6);

select*from BOLETIM;
