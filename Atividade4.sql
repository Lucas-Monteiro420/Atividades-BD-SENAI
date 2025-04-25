ClienteREATE DATABASE GestaoVendas;
USE GestaoVendas;


CREATE TABLE cliente (
	cliente_id INT PRIMARY KEY AUTO_INCREMENT,
	nome VARCHAR(100),
	cpf CHAR(11),
	email VARCHAR(100),
	telefone VARCHAR(15)
);

CREATE TABLE produto (
	produto_id INT PRIMARY KEY AUTO_INCREMENT,
	nome VARCHAR(100),
	preco DECIMAL(10,2),
	estoque INT
);

CREATE TABLE vendedor (
	vendedor_id INT PRIMARY KEY AUTO_INCREMENT,
	nome VARCHAR(100),
	email VARCHAR(100),
	salario DECIMAL(10,2)
);

CREATE TABLE venda (
	venda_id INT PRIMARY KEY AUTO_INCREMENT,
	cliente_id INT,
	vendedor_id INT,
	data_venda DATE,
	total DECIMAL(10,2),
	FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id),
	FOREIGN KEY (vendedor_id) REFERENCES vendedor(vendedor_id)
);

CREATE TABLE itemvenda (
	item_id INT PRIMARY KEY AUTO_INCREMENT,
	venda_id INT,
	produto_id INT,
	quantidade INT,
	preco_unitario DECIMAL(10,2),
	FOREIGN KEY (venda_id) REFERENCES venda(venda_id),
	FOREIGN KEY (produto_id) REFERENCES produto(produto_id)
);

DELIMITER $$
	CREATE FUNCTION CalcularSalarioAnual(SalarioMensal DECIMAL(10,2))
	RETURNS DECIMAL(10,2)
	DETERMINISTIC
	BEGIN 
	    DECLARE SalarioAnual DECIMAL(10,2);
	    SET SalarioAnual = SalarioMensal * 13;
	    RETURN SalarioAnual;
	END $$
DELIMITER ;

DELIMITER $$
	CREATE PROCEDURE ListarFuncionarios()
	BEGIN
		SELECT
			vendedor_id,
			nome,
			email,
			salario
		FROM
			vendedor
		ORDER BY
			nome;
	END 
DELIMITER ;

DELIMITER $$

CREATE PROCEDURE InserirVendedor(
    IN p_nome VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_salario DECIMAL(10,2)
)
BEGIN
    INSERT INTO vendedor (nome, email, salario)
    VALUES (p_nome, p_email, p_salario);
    
    SELECT CONCAT('Vendedor ', p_nome, ' inserido com sucesso!') AS mensagem;
END //
DELIMITER ;
    

INSERT INTO 
	cliente (nome, cpf, email, telefone)
    VALUES 
	('Kris Lourrany de Souza Lima','70421985773','krislola@gmail.com','31997393176'),
	('Cóquis Ácaros Panetonni','61530749809','coquisfofinha@gmail.com','35997583204'),
	('Cléber Ribeiro Silva','83016492501','cleber420@gmail.com','98997493214'),
	('Vladimir Ilitch Lênin','68325947125','lenin.vladimir@gmail.com','55997384560'),
	('João da Silva','31907418892','joaodasilva@gmail.com','51997401936'),
	('Carlos Marques Mange','42815670283','carlosmarquesdacapital@gmail.com','19997412873');

INSERT INTO 
	produto (nome, preco, estoque)
    VALUES 
	('Processador Intel i3', 299.00, 35),
	('Placa NVIVIDA RTX', 429.00, 20),
	('Hyper X 16GB RAM', 399.00, 25),
	('Monitor Philco 42 polegadas', 999.00, 50),
	('Mouse gamer Python', 99.00, 58);
 
INSERT INTO 
	vendedor (nome, email, salario)
    VALUES 
	('Carlos Marighella', 'carlosmarighela@empresa.com', 4100.00),
	('Carlos Lamarca', 'carloslamarca@empresa.com', 3450.00),
	('Rosa Luxemburgo', 'rosaluxemburgo@empresa.com', 4800.00),
	('Mauricio Grabois','mauriciograbois@empresa.com', 4300.00),
	('George Lucas', 'georgelucas@empresa.com', 9000.00);
    
INSERT INTO 
	venda (cliente_id, vendedor_id, data_venda, total)
    VALUES 
	(1, 1, '2025-07-10', 2497.05),
	(2, 2, '2025-08-12', 635.00),
	(3, 4, '2025-10-14', 559.00),
	(4, 3, '2023-09-15', 899.00),
	(5, 5, '2024-04-16', 1199.00),
	(6, 5, '2024-05-02', 99.00);

INSERT INTO 
	venda (cliente_id, vendedor_id, data_venda, total)
    VALUES 
	(1, 1, '2025-07-10', 1495.00),  
	(2, 2, '2025-08-12', 429.00),    
	(3, 4, '2025-10-14', 399.00),    
	(4, 3, '2023-09-15', 999.00),    
	(5, 5, '2024-04-16', 897.00),    
	(6, 5, '2024-05-02', 99.00);     
    
-- Nomes dos cliente cadastrados --
SELECT*FROM cliente;

-- Nomes dos vendedores cadastrados --
SELECT*FROM vendedor;

-- Salário dos vendedores cadastrados --
CREATE VIEW vw_SalariosFuncionarios AS
SELECT
    vendedor_id,
    nome,
    salario AS SalarioMensal,
    CalcularSalarioAnual(salario) AS SalarioAnual
FROM vendedor
ORDER BY
    salario DESC;
    
-- Salário --
SELECT
    vendedor_id,
    nome,
    salario AS SalarioMensal,
    CalcularSalarioAnual(salario) AS SalarioAnual
FROM vendedor;

-- View com lista de funcionários --
CREATE VIEW vw_ListaFuncionarios AS
SELECT
    vendedor_id,
    nome,
    email
FROM
    vendedor
ORDER BY
    nome;
    
SELECT*FROM vw_listafuncionarios;

CALL InserirVendedor('Willian', 'willian@empresa.com', '5000');

-- Nome dos produtos cadastrados -- 
SELECT nome AS nome_produtos FROM produto;

-- Produtos com preço superior a 100--
SELECT nome AS nome_produto FROM produto WHERE preco > 100.00;

-- Quais clientes estão cadastrados no sistema --
SELECT nome AS nome_cliente FROM cliente;

-- Produtos e clientes cadastrados --
SELECT cliente.nome AS nome_cliente, produto.nome AS nome_produto FROM cliente INNER JOIN produto ON cliente.cliente_id = produto.produto_id;

-- Quantos clientes existem na empresa -- 
SELECT COUNT(*) AS QTD_Cliente FROM cliente;

-- Quantos produtos estão cadastrados na empresa -- 
SELECT COUNT(*) AS QTD_Produto FROM produto;

-- Pedidos do ano de 2024 -- 
SELECT data_venda AS data_venda FROM venda WHERE data_venda BETWEEN '2024-01-01' AND '2024-12-31';

-- Valor total das vendas -- 
SELECT COUNT(*) AS total_venda FROM venda;

-- Valor total das vendas feita pelo funcionario 5 -- 
SELECT SUM(total) FROM venda WHERE vendedor_id = 5;

-- Valor total das vendas feita pelo cliente João Silva -- 
SELECT SUM(total) FROM venda WHERE cliente_id = 6;

-- Soma dos pedidos vendas --
SELECT (total) AS total_venda FROM venda;

-- Quantos vendedores ganham mais de 3000 -- 
SELECT nome, salario FROM vendedor WHERE salario > 3000.00;

-- Quantos produtos custam mais que 100 --
SELECT COUNT(*) AS QTD_Produto FROM produto WHERE preco > 100.00;

-- Qual a soma dos valores dos pedidos feitos pelo cliente 2 -- 
SELECT SUM(total) FROM venda WHERE cliente_id = 2;
