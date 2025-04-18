CREATE DATABASE EmpresaX;
USE EmpresaX;

CREATE TABLE departamento (
    iddep INT(5) NOT NULL,  
    nome CHAR(30),
    localizacao CHAR(60),
    PRIMARY KEY (iddep)
);

CREATE TABLE funcionarios (
    idfun INT NOT NULL,
    nome CHAR(30),
    cargo CHAR(20),
    salario DECIMAL(10,2),
    dataContratacao DATE,
    departamento INT,
    PRIMARY KEY (idfun),
    FOREIGN KEY (departamento) REFERENCES departamento(iddep)
);

INSERT INTO departamento VALUES
(111, 'Filosofia', '2° andar'),
(112, 'Análise de Processos', '1° andar'),
(113, 'Contabilidade', '3° andar');

INSERT INTO funcionarios VALUES (001, 'Lucas Monteiro', 'Filósofo', 5000.00, '2021-03-01', 111);
INSERT INTO funcionarios VALUES (002, 'Kris Lourrany', 'Analista de Processos', 10000.00, '2021-02-01', 112);
INSERT INTO funcionarios VALUES (003, 'Cóquis Ácaros', 'Contadora', 3500.00, '2021-03-05', 113);

SELECT * FROM departamento;
SELECT * FROM funcionarios;
SHOW DATABASES;
SHOW TABLES;