-- Criação do banco de dados
CREATE DATABASE FabricaEletronicosDB;
USE FabricaEletronicosDB;

-- Tabela de Funcionários
CREATE TABLE Funcionarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    data_admissao DATE NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefone VARCHAR(20),
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Fornecedores
CREATE TABLE Fornecedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    endereco VARCHAR(200),
    cidade VARCHAR(100),
    estado CHAR(2),
    cep VARCHAR(10),
    telefone VARCHAR(20),
    email VARCHAR(100),
    pessoa_contato VARCHAR(100),
    data_cadastro DATE NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Categorias de Produtos
CREATE TABLE CategoriasProdutos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT
);

-- Tabela de Produtos
CREATE TABLE Produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco_custo DECIMAL(10,2) NOT NULL,
    preco_venda DECIMAL(10,2) NOT NULL,
    categoria_id INT,
    unidade_medida VARCHAR(10) NOT NULL,
    data_cadastro DATE NOT NULL,
    FOREIGN KEY (categoria_id) REFERENCES CategoriasProdutos(id)
);

-- Tabela de Estoque
CREATE TABLE Estoque (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 0,
    quantidade_minima INT DEFAULT 5,
    quantidade_maxima INT,
    localizacao VARCHAR(50),
    ultima_atualizacao DATETIME NOT NULL,
    FOREIGN KEY (produto_id) REFERENCES Produtos(id)
);

-- Tabela de Produtos por Fornecedor
CREATE TABLE ProdutosFornecedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT NOT NULL,
    fornecedor_id INT NOT NULL,
    prazo_entrega_dias INT,
    preco_fornecedor DECIMAL(10,2),
    codigo_produto_fornecedor VARCHAR(50),
    principal BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (produto_id) REFERENCES Produtos(id),
    FOREIGN KEY (fornecedor_id) REFERENCES Fornecedores(id),
    UNIQUE KEY (produto_id, fornecedor_id)
);

-- Tabela de Clientes
CREATE TABLE Clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('PF', 'PJ') NOT NULL,
    nome VARCHAR(100) NOT NULL,
    cpf_cnpj VARCHAR(18) UNIQUE NOT NULL,
    endereco VARCHAR(200),
    cidade VARCHAR(100),
    estado CHAR(2),
    cep VARCHAR(10),
    telefone VARCHAR(20),
    email VARCHAR(100),
    data_cadastro DATE NOT NULL,
    limite_credito DECIMAL(15,2) DEFAULT 0,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Pedidos
CREATE TABLE Pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    funcionario_id INT NOT NULL,
    data_pedido DATETIME NOT NULL,
    data_entrega_prevista DATE,
    data_entrega_real DATE,
    status ENUM('pendente', 'confirmado', 'em_producao', 'em_transporte', 'entregue', 'cancelado') NOT NULL DEFAULT 'pendente',
    forma_pagamento ENUM('a_vista', 'prazo_30', 'prazo_60', 'prazo_90') NOT NULL,
    observacoes TEXT,
    valor_total DECIMAL(15,2),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(id),
    FOREIGN KEY (funcionario_id) REFERENCES Funcionarios(id)
);

-- Tabela de Itens de Pedido
CREATE TABLE ItensPedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    desconto DECIMAL(5,2) DEFAULT 0,
    subtotal DECIMAL(15,2) GENERATED ALWAYS AS ((quantidade * preco_unitario) * (1 - desconto/100)) STORED,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(id),
    FOREIGN KEY (produto_id) REFERENCES Produtos(id)
);

-- Tabela de Histórico de Pedidos
CREATE TABLE HistoricoPedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    data_registro DATETIME NOT NULL,
    status_anterior ENUM('pendente', 'confirmado', 'em_producao', 'em_transporte', 'entregue', 'cancelado'),
    status_novo ENUM('pendente', 'confirmado', 'em_producao', 'em_transporte', 'entregue', 'cancelado') NOT NULL,
    funcionario_id INT,
    observacoes TEXT,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(id),
    FOREIGN KEY (funcionario_id) REFERENCES Funcionarios(id)
);

-- Tabela de Compras (para reposição de estoque)
CREATE TABLE Compras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fornecedor_id INT NOT NULL,
    funcionario_id INT NOT NULL,
    data_compra DATETIME NOT NULL,
    data_entrega_prevista DATE,
    data_entrega_real DATE,
    status ENUM('pendente', 'confirmada', 'parcial', 'finalizada', 'cancelada') NOT NULL DEFAULT 'pendente',
    valor_total DECIMAL(15,2),
    observacoes TEXT,
    FOREIGN KEY (fornecedor_id) REFERENCES Fornecedores(id),
    FOREIGN KEY (funcionario_id) REFERENCES Funcionarios(id)
);

-- Tabela de Itens de Compra
CREATE TABLE ItensCompra (
    id INT AUTO_INCREMENT PRIMARY KEY,
    compra_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(15,2) GENERATED ALWAYS AS (quantidade * preco_unitario) STORED,
    quantidade_recebida INT DEFAULT 0,
    FOREIGN KEY (compra_id) REFERENCES Compras(id),
    FOREIGN KEY (produto_id) REFERENCES Produtos(id)
);

-- Tabela de Movimentação de Estoque
CREATE TABLE MovimentacaoEstoque (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT NOT NULL,
    tipo_movimentacao ENUM('entrada', 'saida', 'ajuste', 'producao') NOT NULL,
    quantidade INT NOT NULL,
    data_movimentacao DATETIME NOT NULL,
    documento_referencia VARCHAR(50),
    id_referencia INT,  -- ID do pedido, compra, etc
    estoque_anterior INT NOT NULL,
    estoque_atual INT NOT NULL,
    funcionario_id INT,
    observacoes TEXT,
    FOREIGN KEY (produto_id) REFERENCES Produtos(id),
    FOREIGN KEY (funcionario_id) REFERENCES Funcionarios(id)
);

-- Tabela de Produção
CREATE TABLE Producao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT NOT NULL,
    quantidade_planejada INT NOT NULL,
    quantidade_produzida INT DEFAULT 0,
    data_inicio DATE NOT NULL,
    data_fim_prevista DATE NOT NULL,
    data_fim_real DATE,
    status ENUM('planejada', 'em_andamento', 'finalizada', 'cancelada') DEFAULT 'planejada',
    funcionario_responsavel_id INT,
    observacoes TEXT,
    FOREIGN KEY (produto_id) REFERENCES Produtos(id),
    FOREIGN KEY (funcionario_responsavel_id) REFERENCES Funcionarios(id)
);

-- Tabela de Materiais Utilizados na Produção
CREATE TABLE MateriaisProducao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producao_id INT NOT NULL,
    material_id INT NOT NULL,  -- Referência a um produto usado como matéria-prima
    quantidade INT NOT NULL,
    FOREIGN KEY (producao_id) REFERENCES Producao(id),
    FOREIGN KEY (material_id) REFERENCES Produtos(id)
);

-- ============================================================
-- VIEWS
-- ============================================================

-- View para visualizar estoque detalhado com informações do produto
CREATE VIEW View_EstoqueDetalhado AS
SELECT
    e.id AS estoque_id,
    p.id AS produto_id,
    p.codigo AS codigo_produto,
    p.nome AS nome_produto,
    c.nome AS categoria,
    e.quantidade,
    e.quantidade_minima,
    e.quantidade_maxima,
    p.preco_custo,
    p.preco_venda,
    (p.preco_venda * e.quantidade) AS valor_total_estoque,
    CASE
        WHEN e.quantidade <= e.quantidade_minima THEN 'CRÍTICO'
        WHEN e.quantidade <= (e.quantidade_minima * 1.5) THEN 'BAIXO'
        WHEN e.quantidade >= e.quantidade_maxima THEN 'EXCESSO'
        ELSE 'NORMAL'
    END AS status_estoque,
    e.localizacao,
    e.ultima_atualizacao
FROM
    Estoque e
JOIN
    Produtos p ON e.produto_id = p.id
LEFT JOIN
    CategoriasProdutos c ON p.categoria_id = c.id;

-- View para pedidos pendentes de confirmação
CREATE VIEW View_PedidosPendentes AS
SELECT
    p.id AS pedido_id,
    p.data_pedido,
    c.nome AS cliente,
    c.id AS cliente_id,
    f.nome AS vendedor,
    p.valor_total,
    p.status,
    DATEDIFF(p.data_entrega_prevista, CURDATE()) AS dias_ate_entrega,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM ItensPedido ip 
            JOIN Estoque e ON ip.produto_id = e.produto_id
            WHERE ip.pedido_id = p.id AND ip.quantidade > e.quantidade
        ) THEN 'FALTA ESTOQUE'
        ELSE 'DISPONÍVEL'
    END AS status_estoque
FROM
    Pedidos p
JOIN
    Clientes c ON p.cliente_id = c.id
JOIN
    Funcionarios f ON p.funcionario_id = f.id
WHERE
    p.status = 'pendente';

-- View para produtos com estoque crítico
CREATE VIEW View_EstoqueCritico AS
SELECT
    p.id AS produto_id,
    p.codigo,
    p.nome,
    e.quantidade,
    e.quantidade_minima,
    (e.quantidade_minima - e.quantidade) AS quantidade_necessaria,
    f.id AS fornecedor_principal_id,
    f.nome AS fornecedor_principal,
    pf.prazo_entrega_dias
FROM
    Estoque e
JOIN
    Produtos p ON e.produto_id = p.id
LEFT JOIN
    ProdutosFornecedores pf ON p.id = pf.produto_id AND pf.principal = TRUE
LEFT JOIN
    Fornecedores f ON pf.fornecedor_id = f.id
WHERE
    e.quantidade <= e.quantidade_minima
ORDER BY
    (e.quantidade / e.quantidade_minima) ASC;

-- View para análise de pedidos por cliente
CREATE VIEW View_PedidosPorCliente AS
SELECT
    c.id AS cliente_id,
    c.nome AS cliente,
    COUNT(p.id) AS total_pedidos,
    SUM(p.valor_total) AS valor_total_pedidos,
    MAX(p.data_pedido) AS ultimo_pedido,
    DATEDIFF(CURDATE(), MAX(p.data_pedido)) AS dias_desde_ultimo_pedido,
    COUNT(CASE WHEN p.status = 'cancelado' THEN 1 END) AS pedidos_cancelados,
    ROUND((COUNT(CASE WHEN p.status = 'cancelado' THEN 1 END) / COUNT(p.id)) * 100, 2) AS percentual_cancelamentos
FROM
    Clientes c
LEFT JOIN
    Pedidos p ON c.id = p.cliente_id
GROUP BY
    c.id, c.nome
ORDER BY
    valor_total_pedidos DESC;

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

-- Procedure para criar pedido com verificação de estoque
DELIMITER //
CREATE PROCEDURE CriarPedido(
    IN p_cliente_id INT,
    IN p_funcionario_id INT,
    IN p_data_entrega_prevista DATE,
    IN p_forma_pagamento VARCHAR(10),
    IN p_observacoes TEXT,
    OUT p_pedido_id INT,
    OUT p_msg VARCHAR(255)
)
BEGIN
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_pedido_id = 0;
        SET p_msg = 'Erro ao criar pedido. Operação cancelada.';
    END;
    
    START TRANSACTION;
    
    -- Verifica se o cliente existe e está ativo
    IF NOT EXISTS (SELECT 1 FROM Clientes WHERE id = p_cliente_id AND ativo = TRUE) THEN
        SET p_msg = 'Cliente não encontrado ou inativo';
        SET p_pedido_id = 0;
        ROLLBACK;
    ELSE
        -- Cria o pedido
        INSERT INTO Pedidos (
            cliente_id, 
            funcionario_id, 
            data_pedido, 
            data_entrega_prevista, 
            forma_pagamento, 
            observacoes, 
            status, 
            valor_total
        )
        VALUES (
            p_cliente_id, 
            p_funcionario_id, 
            NOW(), 
            p_data_entrega_prevista, 
            p_forma_pagamento, 
            p_observacoes, 
            'pendente', 
            0
        );
        
        SET p_pedido_id = LAST_INSERT_ID();
        
        -- Cria registro no histórico
        INSERT INTO HistoricoPedidos (
            pedido_id, 
            data_registro, 
            status_anterior, 
            status_novo, 
            funcionario_id, 
            observacoes
        )
        VALUES (
            p_pedido_id, 
            NOW(), 
            NULL, 
            'pendente', 
            p_funcionario_id, 
            'Pedido criado'
        );
        
        SET p_msg = 'Pedido criado com sucesso';
        COMMIT;
    END IF;
END //
DELIMITER ;

-- Procedure para adicionar item ao pedido com verificação de estoque
DELIMITER //
CREATE PROCEDURE AdicionarItemPedido(
    IN p_pedido_id INT,
    IN p_produto_id INT,
    IN p_quantidade INT,
    IN p_preco_unitario DECIMAL(10,2),
    IN p_desconto DECIMAL(5,2),
    OUT p_msg VARCHAR(255)
)
BEGIN
    DECLARE v_estoque INT;
    DECLARE v_status_pedido VARCHAR(20);
    DECLARE v_subtotal DECIMAL(15,2);
    DECLARE v_valor_total_atual DECIMAL(15,2);
    
    -- Verifica status do pedido
    SELECT status INTO v_status_pedido FROM Pedidos WHERE id = p_pedido_id;
    
    IF v_status_pedido != 'pendente' THEN
        SET p_msg = 'Só é possível adicionar itens a pedidos pendentes';
    ELSE
        -- Verifica estoque disponível
        SELECT quantidade INTO v_estoque FROM Estoque WHERE produto_id = p_produto_id;
        
        IF v_estoque < p_quantidade THEN
            SET p_msg = CONCAT('Estoque insuficiente. Disponível: ', v_estoque);
        ELSE
            -- Calcula subtotal
            SET v_subtotal = p_quantidade * p_preco_unitario * (1 - p_desconto/100);
            
            -- Adiciona item ao pedido
            INSERT INTO ItensPedido (
                pedido_id, 
                produto_id, 
                quantidade, 
                preco_unitario, 
                desconto
            )
            VALUES (
                p_pedido_id, 
                p_produto_id, 
                p_quantidade, 
                p_preco_unitario, 
                p_desconto
            );
            
            -- Atualiza valor total do pedido
            SELECT IFNULL(valor_total, 0) INTO v_valor_total_atual FROM Pedidos WHERE id = p_pedido_id;
            
            UPDATE Pedidos 
            SET valor_total = v_valor_total_atual + v_subtotal
            WHERE id = p_pedido_id;
            
            SET p_msg = 'Item adicionado com sucesso';
        END IF;
    END IF;
END //
DELIMITER ;

-- Procedure para confirmar pedido e reduzir estoque
DELIMITER //
CREATE PROCEDURE ConfirmarPedido(
    IN p_pedido_id INT,
    IN p_funcionario_id INT,
    OUT p_msg VARCHAR(255)
)
BEGIN
    DECLARE v_produto_id INT;
    DECLARE v_quantidade INT;
    DECLARE v_estoque_atual INT;
    DECLARE v_cliente_id INT;
    DECLARE v_status VARCHAR(20);
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_estoque_insuficiente BOOLEAN DEFAULT FALSE;
    DECLARE v_produto_sem_estoque VARCHAR(100) DEFAULT '';
    
    -- Cursor para itens do pedido
    DECLARE c_itens CURSOR FOR
        SELECT ip.produto_id, ip.quantidade, e.quantidade
        FROM ItensPedido ip
        JOIN Estoque e ON ip.produto_id = e.produto_id
        WHERE ip.pedido_id = p_pedido_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    
    -- Verificações iniciais
    SELECT status, cliente_id INTO v_status, v_cliente_id 
    FROM Pedidos 
    WHERE id = p_pedido_id;
    
    IF v_status IS NULL THEN
        SET p_msg = 'Pedido não encontrado';
    ELSEIF v_status != 'pendente' THEN
        SET p_msg = CONCAT('Pedido não pode ser confirmado. Status atual: ', v_status);
    ELSE
        -- Verifica estoque para todos os itens
        OPEN c_itens;
        
        check_itens: LOOP
            FETCH c_itens INTO v_produto_id, v_quantidade, v_estoque_atual;
            
            IF v_finished = 1 THEN
                LEAVE check_itens;
            END IF;
            
            IF v_estoque_atual < v_quantidade THEN
                SET v_estoque_insuficiente = TRUE;
                
                -- Obter nome do produto
                SELECT CONCAT(nome, ' (disponível: ', v_estoque_atual, ')') 
                INTO v_produto_sem_estoque 
                FROM Produtos 
                WHERE id = v_produto_id;
                
                LEAVE check_itens;
            END IF;
        END LOOP;
        
        CLOSE c_itens;
        
        -- Se estoque insuficiente, retorna mensagem
        IF v_estoque_insuficiente THEN
            SET p_msg = CONCAT('Estoque insuficiente para o produto: ', v_produto_sem_estoque);
        ELSE
            -- Tudo ok, inicia transação para confirmar pedido
            START TRANSACTION;
            
            -- Atualiza status do pedido
            UPDATE Pedidos
            SET status = 'confirmado'
            WHERE id = p_pedido_id;
            
            -- Registra histórico
            INSERT INTO HistoricoPedidos (
                pedido_id, 
                data_registro, 
                status_anterior, 
                status_novo, 
                funcionario_id, 
                observacoes
            )
            VALUES (
                p_pedido_id, 
                NOW(), 
                'pendente', 
                'confirmado', 
                p_funcionario_id, 
                'Pedido confirmado e estoque reservado'
            );
            
            -- Reduz estoque para cada item
            SET v_finished = 0;
            OPEN c_itens;
            
            update_estoque: LOOP
                FETCH c_itens INTO v_produto_id, v_quantidade, v_estoque_atual;
                
                IF v_finished = 1 THEN
                    LEAVE update_estoque;
                END IF;
                
                -- Registra movimentação de estoque
                INSERT INTO MovimentacaoEstoque (
                    produto_id, 
                    tipo_movimentacao, 
                    quantidade, 
                    data_movimentacao, 
                    documento_referencia, 
                    id_referencia, 
                    estoque_anterior, 
                    estoque_atual, 
                    funcionario_id, 
                    observacoes
                )
                VALUES (
                    v_produto_id, 
                    'saida', 
                    v_quantidade, 
                    NOW(), 
                    'PEDIDO', 
                    p_pedido_id, 
                    v_estoque_atual, 
                    v_estoque_atual - v_quantidade, 
                    p_funcionario_id, 
                    'Saída para atender pedido'
                );
                
                -- Atualiza estoque
                UPDATE Estoque
                SET quantidade = quantidade - v_quantidade,
                    ultima_atualizacao = NOW()
                WHERE produto_id = v_produto_id;
            END LOOP;
            
            CLOSE c_itens;
            
            COMMIT;
            SET p_msg = 'Pedido confirmado com sucesso';
        END IF;
    END IF;
END //
DELIMITER ;

-- Procedure para verificar produtos com baixo estoque
DELIMITER //
CREATE PROCEDURE VerificarBaixoEstoque(
    OUT p_encontrados INT
)
BEGIN
    SELECT COUNT(*) INTO p_encontrados
    FROM Estoque e
    WHERE e.quantidade <= e.quantidade_minima;
    
    SELECT
        p.id,
        p.codigo,
        p.nome,
        e.quantidade AS estoque_atual,
        e.quantidade_minima,
        (e.quantidade_minima - e.quantidade) AS quantidade_necessaria,
        CASE
            WHEN f.id IS NOT NULL THEN f.nome
            ELSE 'Sem fornecedor'
        END AS fornecedor_principal,
        IFNULL(pf.prazo_entrega_dias, 0) AS prazo_entrega_dias
    FROM
        Estoque e
    JOIN
        Produtos p ON e.produto_id = p.id
    LEFT JOIN
        ProdutosFornecedores pf ON p.id = pf.produto_id AND pf.principal = TRUE
    LEFT JOIN
        Fornecedores f ON pf.fornecedor_id = f.id
    WHERE
        e.quantidade <= e.quantidade_minima
    ORDER BY
        (e.quantidade / e.quantidade_minima) ASC;
END //
DELIMITER ;

-- Procedure para criar ordem de compra para reposição de estoque
DELIMITER //
CREATE PROCEDURE CriarOrdemCompraReposicao(
    IN p_funcionario_id INT,
    OUT p_compra_id INT,
    OUT p_msg VARCHAR(255)
)
BEGIN
    DECLARE v_fornecedor_id INT;
    DECLARE v_total_valor DECIMAL(15,2) DEFAULT 0;
    DECLARE v_produto_id INT;
    DECLARE v_quantidade_atual INT;
    DECLARE v_quantidade_minima INT;
    DECLARE v_quantidade_maxima INT;
    DECLARE v_quantidade_compra INT;
    DECLARE v_preco_fornecedor DECIMAL(10,2);
    DECLARE v_subtotal DECIMAL(15,2);
    DECLARE v_finished INT DEFAULT 0;
    
    -- Cursor para itens com estoque baixo
    DECLARE c_produtos CURSOR FOR
        SELECT 
            e.produto_id,
            e.quantidade,
            e.quantidade_minima,
            e.quantidade_maxima,
            pf.fornecedor_id,
            pf.preco_fornecedor
        FROM 
            Estoque e
        JOIN 
            ProdutosFornecedores pf ON e.produto_id = pf.produto_id AND pf.principal = TRUE
        WHERE 
            e.quantidade <= e.quantidade_minima
        ORDER BY 
            pf.fornecedor_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    
    START TRANSACTION;
    
    OPEN c_produtos;
    
    -- Variáveis para controlar fornecedor atual
    SET v_fornecedor_id = 0;
    SET p_compra_id = 0;
    
    compra_loop: LOOP
        FETCH c_produtos INTO v_produto_id, v_quantidade_atual, v_quantidade_minima, 
                             v_quantidade_maxima, v_fornecedor_id, v_preco_fornecedor;
        
        IF v_finished = 1 THEN
            -- Finaliza última compra
            IF p_compra_id > 0 THEN
                UPDATE Compras SET valor_total = v_total_valor WHERE id = p_compra_id;
            END IF;
            
            LEAVE compra_loop;
        END IF;
        
        -- Se for um novo fornecedor, cria nova ordem de compra
        IF p_compra_id = 0 OR v_fornecedor_id != (SELECT fornecedor_id FROM Compras WHERE id = p_compra_id) THEN
            -- Finaliza compra anterior se existir
            IF p_compra_id > 0 THEN
                UPDATE Compras SET valor_total = v_total_valor WHERE id = p_compra_id;
            END IF;
            
            -- Inicia nova compra
            INSERT INTO Compras (
                fornecedor_id,
                funcionario_id,
                data_compra,
                data_entrega_prevista,
                status,
                observacoes
            )
            VALUES (
                v_fornecedor_id,
                p_funcionario_id,
                NOW(),
                DATE_ADD(CURDATE(), INTERVAL 7 DAY),
                'pendente',
                'Ordem de compra automática para reposição de estoque'
            );
            
            SET p_compra_id = LAST_INSERT_ID();
            SET v_total_valor = 0;
        END IF;
        
        -- Calcula quantidade a comprar (para chegar ao estoque máximo)
        IF v_quantidade_maxima IS NULL OR v_quantidade_maxima = 0 THEN
            SET v_quantidade_compra = v_quantidade_minima * 2 - v_quantidade_atual;
        ELSE
            SET v_quantidade_compra = v_quantidade_maxima - v_quantidade_atual;
        END IF;
        
        -- Garante quantidade mínima de 1
        IF v_quantidade_compra < 1 THEN
            SET v_quantidade_compra = 1;
        END IF;
        
        -- Calcula subtotal
        SET v_subtotal = v_quantidade_compra * v_preco_fornecedor;
        SET v_total_valor = v_total_valor + v_subtotal;
        
        -- Adiciona item à compra
        INSERT INTO ItensCompra (
            compra_id,
            produto_id,
            quantidade,
            preco_unitario
        )
        VALUES (
            p_compra_id,
            v_produto_id,
            v_quantidade_compra,
            v_preco_fornecedor
        );
    END LOOP;
    
    CLOSE c_produtos;
    
    IF p_compra_id > 0 THEN
        SET p_msg = 'Ordem de compra criada com sucesso';
        COMMIT;
    ELSE
        SET p_msg = 'Nenhum produto precisando de reposição encontrado';
        ROLLBACK;
    END IF;
END //
DELIMITER ;

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Trigger para impedir exclusão de produtos com estoque
DELIMITER //
CREATE TRIGGER Trigger_ImpedirExclusaoProdutosComEstoque
BEFORE DELETE ON Produtos
FOR EACH ROW
BEGIN
    DECLARE v_quantidade INT;
    DECLARE v_referencias INT;
    
    -- Verifica se produto tem estoque
    SELECT quantidade INTO v_quantidade FROM Estoque WHERE produto_id = OLD.id;
    
    -- Verifica se produto está em pedidos ou compras
    SELECT 
        COUNT(*) INTO v_referencias
    FROM (
        SELECT produto_id FROM ItensPedido WHERE produto_id = OLD.id
        UNION
        SELECT produto_id FROM ItensCompra WHERE produto_id = OLD.id
        UNION
        SELECT produto_id FROM Producao WHERE produto_id = OLD.id
        UNION
        SELECT material_id FROM MateriaisProducao WHERE material_id = OLD.id
    ) AS refs;
    
    IF v_quantidade > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível excluir produto com estoque. Ajuste o estoque para zero primeiro.';
    END IF;
    
    IF v_referencias > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível excluir produto referenciado em pedidos, compras ou produção.';
    END IF;
END //
DELIMITER ;

-- Trigger para atualizar estoque após recebimento de compra (continuação)
DELIMITER //
CREATE TRIGGER Trigger_AtualizarEstoqueAposRecebimento
AFTER UPDATE ON ItensCompra
FOR EACH ROW
BEGIN
    DECLARE v_estoque_anterior INT;
    DECLARE v_estoque_id INT;
    DECLARE v_compra_status VARCHAR(20);
    DECLARE v_funcionario_id INT;
    
    -- Só executa se a quantidade recebida foi alterada
    IF OLD.quantidade_recebida != NEW.quantidade_recebida THEN
        -- Obtém dados necessários
        SELECT status, funcionario_id INTO v_compra_status, v_funcionario_id 
        FROM Compras 
        WHERE id = NEW.compra_id;
        
        SELECT id, quantidade INTO v_estoque_id, v_estoque_anterior 
        FROM Estoque 
        WHERE produto_id = NEW.produto_id;
        
        -- Se não existe entrada no estoque, cria uma
        IF v_estoque_id IS NULL THEN
            INSERT INTO Estoque (
                produto_id, 
                quantidade, 
                quantidade_minima, 
                ultima_atualizacao
            )
            VALUES (
                NEW.produto_id, 
                NEW.quantidade_recebida - OLD.quantidade_recebida, 
                5, 
                NOW()
            );
            
            SET v_estoque_anterior = 0;
        ELSE
            -- Atualiza estoque existente
            UPDATE Estoque
            SET 
                quantidade = quantidade + (NEW.quantidade_recebida - OLD.quantidade_recebida),
                ultima_atualizacao = NOW()
            WHERE produto_id = NEW.produto_id;
        END IF;
        
        -- Registra movimentação
        INSERT INTO MovimentacaoEstoque (
            produto_id, 
            tipo_movimentacao, 
            quantidade, 
            data_movimentacao, 
            documento_referencia, 
            id_referencia, 
            estoque_anterior, 
            estoque_atual, 
            funcionario_id, 
            observacoes
        )
        VALUES (
            NEW.produto_id, 
            'entrada', 
            NEW.quantidade_recebida - OLD.quantidade_recebida, 
            NOW(), 
            'COMPRA', 
            NEW.compra_id, 
            v_estoque_anterior, 
            v_estoque_anterior + (NEW.quantidade_recebida - OLD.quantidade_recebida), 
            v_funcionario_id, 
            'Entrada por recebimento de compra'
        );
        
        -- Atualiza status da compra se necessário
        IF v_compra_status = 'pendente' THEN
            UPDATE Compras SET status = 'parcial' WHERE id = NEW.compra_id;
        END IF;
        
        -- Verifica se todos os itens foram recebidos completamente
        IF NOT EXISTS (
            SELECT 1 
            FROM ItensCompra 
            WHERE compra_id = NEW.compra_id AND quantidade > quantidade_recebida
        ) THEN
            UPDATE Compras SET status = 'finalizada', data_entrega_real = NOW() WHERE id = NEW.compra_id;
        END IF;
    END IF;
END //
DELIMITER ;

-- Trigger para calcular valor total de pedido
DELIMITER //
CREATE TRIGGER Trigger_CalcularValorTotalPedido
AFTER INSERT ON ItensPedido
FOR EACH ROW
BEGIN
    DECLARE v_valor_total DECIMAL(15,2);
    
    -- Calcula total do pedido
    SELECT SUM(subtotal) INTO v_valor_total
    FROM ItensPedido
    WHERE pedido_id = NEW.pedido_id;
    
    -- Atualiza pedido
    UPDATE Pedidos SET valor_total = v_valor_total WHERE id = NEW.pedido_id;
END //
DELIMITER ;

-- Trigger para atualizar estoque após cancelamento de pedido
DELIMITER //
CREATE TRIGGER Trigger_AtualizarEstoqueAposCancelamentoPedido
AFTER UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    DECLARE v_produto_id INT;
    DECLARE v_quantidade INT;
    DECLARE v_estoque_anterior INT;
    DECLARE v_funcionario_id INT;
    DECLARE v_finished INT DEFAULT 0;
    
    -- Cursor para itens do pedido
    DECLARE c_itens CURSOR FOR
        SELECT produto_id, quantidade
        FROM ItensPedido
        WHERE pedido_id = NEW.id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    
    -- Só executa se o status mudou para cancelado
    IF OLD.status != 'cancelado' AND NEW.status = 'cancelado' THEN
        SET v_funcionario_id = NEW.funcionario_id;
        
        -- Insere registro no histórico
        INSERT INTO HistoricoPedidos (
            pedido_id, 
            data_registro, 
            status_anterior, 
            status_novo, 
            funcionario_id, 
            observacoes
        )
        VALUES (
            NEW.id, 
            NOW(), 
            OLD.status, 
            NEW.status, 
            v_funcionario_id, 
            'Pedido cancelado'
        );
        
        -- Devolve itens ao estoque se o pedido já tinha sido confirmado
        IF OLD.status IN ('confirmado', 'em_producao') THEN
            OPEN c_itens;
            
            itens_loop: LOOP
                FETCH c_itens INTO v_produto_id, v_quantidade;
                
                IF v_finished = 1 THEN
                    LEAVE itens_loop;
                END IF;
                
                -- Obtém estoque atual
                SELECT quantidade INTO v_estoque_anterior
                FROM Estoque
                WHERE produto_id = v_produto_id;
                
                -- Atualiza estoque
                UPDATE Estoque
                SET 
                    quantidade = quantidade + v_quantidade,
                    ultima_atualizacao = NOW()
                WHERE produto_id = v_produto_id;
                
                -- Registra movimentação
                INSERT INTO MovimentacaoEstoque (
                    produto_id, 
                    tipo_movimentacao, 
                    quantidade, 
                    data_movimentacao, 
                    documento_referencia, 
                    id_referencia, 
                    estoque_anterior, 
                    estoque_atual, 
                    funcionario_id, 
                    observacoes
                )
                VALUES (
                    v_produto_id, 
                    'entrada', 
                    v_quantidade, 
                    NOW(), 
                    'PEDIDO_CANCELADO', 
                    NEW.id, 
                    v_estoque_anterior, 
                    v_estoque_anterior + v_quantidade, 
                    v_funcionario_id, 
                    'Devolução ao estoque por cancelamento de pedido'
                );
            END LOOP;
            
            CLOSE c_itens;
        END IF;
    END IF;
END //
DELIMITER ;

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- Função para calcular valor total do estoque
DELIMITER //
CREATE FUNCTION CalcularValorEstoque()
RETURNS DECIMAL(15,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(15,2);
    
    SELECT SUM(p.preco_custo * e.quantidade)
    INTO total
    FROM Produtos p
    JOIN Estoque e ON p.id = e.produto_id;
    
    RETURN IFNULL(total, 0.00);
END //
DELIMITER ;


-- Função para verificar se produto tem estoque suficiente
DELIMITER //
CREATE FUNCTION VerificarEstoqueSuficiente(
    p_produto_id INT,
    p_quantidade INT
) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_disponivel INT;
    DECLARE v_resultado BOOLEAN;
    
    SELECT quantidade INTO v_disponivel
    FROM Estoque
    WHERE produto_id = p_produto_id;
    
    IF v_disponivel IS NULL THEN
        SET v_resultado = FALSE;
    ELSEIF v_disponivel >= p_quantidade THEN
        SET v_resultado = TRUE;
    ELSE
        SET v_resultado = FALSE;
    END IF;
    
    RETURN v_resultado;
END //
DELIMITER ;

-- Função para calcular valor do pedido
DELIMITER //
CREATE FUNCTION CalcularValorPedido(
    p_pedido_id INT
)
RETURNS DECIMAL(15,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(15,2);
    
    SELECT SUM(subtotal)
    INTO total
    FROM ItensPedido
    WHERE pedido_id = p_pedido_id;
    
    RETURN IFNULL(total, 0.00);
END //
DELIMITER ;

-- ============================================================
-- DADOS DE TESTE
-- ============================================================

-- Inserir categorias de produtos
INSERT INTO CategoriasProdutos (nome, descricao)
VALUES 
('Capacitores', 'Componentes para armazenamento de energia elétrica'),
('Resistores', 'Componentes de resistência elétrica'),
('Circuitos Integrados', 'Chips e microcontroladores'),
('Diodos', 'Componentes semicondutores'),
('Transistores', 'Componentes para amplificação e comutação'),
('Conectores', 'Materiais para conexão elétrica');

SELECT*FROM CategoriasProdutos;

-- Inserir funcionários
INSERT INTO Funcionarios (nome, cargo, data_admissao, email, telefone)
VALUES
('Ana Souza', 'Gerente de Produção', '2022-03-15', 'ana.souza@fabrica.com.br', '(19) 98765-4321'),
('Carlos Lima', 'Supervisor de Estoque', '2022-05-10', 'carlos.lima@fabrica.com.br', '(19) 98765-1234'),
('Mariana Costa', 'Vendedora', '2023-01-20', 'mariana.costa@fabrica.com.br', '(19) 98765-5678'),
('Ricardo Oliveira', 'Técnico de Produção', '2023-02-15', 'ricardo.oliveira@fabrica.com.br', '(19) 98765-8765'),
('Juliana Santos', 'Assistente Administrativo', '2023-04-05', 'juliana.santos@fabrica.com.br', '(19) 98765-9876');

SELECT*FROM Funcionarios;

-- Inserir fornecedores
INSERT INTO Fornecedores (nome, cnpj, endereco, cidade, estado, cep, telefone, email, pessoa_contato, data_cadastro)
VALUES
('Eletrônicos Brasil Ltda', '12.345.678/0001-90', 'Av. das Indústrias, 1500', 'São Paulo', 'SP', '01310-200', '(11) 3333-4444', 'contato@eletronicosbrasilltda.com.br', 'Fernando Silva', '2022-01-10'),
('Compo Tech S.A.', '23.456.789/0001-12', 'Rua dos Componentes, 350', 'Campinas', 'SP', '13083-970', '(19) 3333-5555', 'vendas@compotech.com.br', 'Roberta Mendes', '2022-02-15'),
('Micro Parts Importadora', '34.567.890/0001-23', 'Rodovia Anhanguera, Km 104', 'Campinas', 'SP', '13089-560', '(19) 3333-6666', 'contato@microparts.com.br', 'Paulo Ferreira', '2022-03-20'),
('Global Electronics Inc.', '45.678.901/0001-34', 'Av. Brigadeiro Faria Lima, 3900', 'São Paulo', 'SP', '04538-132', '(11) 3333-7777', 'brazil@globalelectronics.com', 'Amanda Rocha', '2022-04-05'),
('Tech Components Ltda', '56.789.012/0001-45', 'Rua dos Circuitos, 789', 'Jundiaí', 'SP', '13214-150', '(11) 3333-8888', 'vendas@techcomponents.com.br', 'Lucas Gomes', '2022-05-12');

SELECT*FROM Fornecedores;

-- Inserir produtos
INSERT INTO Produtos (codigo, nome, descricao, preco_custo, preco_venda, categoria_id, unidade_medida, data_cadastro)
VALUES
('CAP-100', 'Capacitor Cerâmico 100pF', 'Capacitor cerâmico de 100pF com tolerância de 10%', 0.15, 0.30, 1, 'UN', '2022-06-01'),
('CAP-220', 'Capacitor Eletrolítico 220μF', 'Capacitor eletrolítico de 220μF/25V', 0.30, 0.60, 1, 'UN', '2022-06-01'),
('RES-10K', 'Resistor 10K 1/4W', 'Resistor de filme de carbono 10K ohms 1/4W', 0.05, 0.15, 2, 'UN', '2022-06-02'),
('CI-555', 'CI Temporizador 555', 'Circuito integrado temporizador 555', 1.20, 2.50, 3, 'UN', '2022-06-03'),
('CI-ATMEGA', 'Microcontrolador ATmega328', 'Microcontrolador ATmega328P-PU DIP-28', 10.50, 18.90, 3, 'UN', '2022-06-03'),
('DIODO-1N4007', 'Diodo 1N4007', 'Diodo retificador 1N4007 1000V 1A', 0.10, 0.25, 4, 'UN', '2022-06-04'),
('TRANS-BC547', 'Transistor BC547', 'Transistor NPN BC547 45V 100mA', 0.20, 0.40, 5, 'UN', '2022-06-05'),
('CONN-USB', 'Conector USB-B', 'Conector USB tipo B fêmea para PCB', 0.80, 1.50, 6, 'UN', '2022-06-06'),
('CI-ESP32', 'Módulo ESP32', 'Módulo ESP32 com WiFi e Bluetooth', 20.00, 35.00, 3, 'UN', '2022-06-07'),
('DISP-LCD16X2', 'Display LCD 16x2', 'Display LCD 16x2 com backlight azul', 8.50, 15.00, 3, 'UN', '2022-06-08');

SELECT*FROM Produtos;

-- Inserir estoque inicial
INSERT INTO Estoque (produto_id, quantidade, quantidade_minima, quantidade_maxima, localizacao, ultima_atualizacao)
VALUES
(1, 500, 100, 1000, 'Prateleira A1', NOW()),
(2, 300, 100, 500, 'Prateleira A2', NOW()),
(3, 1000, 200, 2000, 'Prateleira B1', NOW()),
(4, 150, 50, 300, 'Prateleira C1', NOW()),
(5, 50, 20, 100, 'Prateleira C2', NOW()),
(6, 800, 200, 1500, 'Prateleira D1', NOW()),
(7, 600, 150, 1000, 'Prateleira D2', NOW()),
(8, 200, 50, 400, 'Prateleira E1', NOW()),
(9, 30, 10, 50, 'Prateleira C3', NOW()),
(10, 40, 15, 80, 'Prateleira C4', NOW());

SELECT*FROM Estoque;

-- Associar produtos a fornecedores
INSERT INTO ProdutosFornecedores (produto_id, fornecedor_id, prazo_entrega_dias, preco_fornecedor, codigo_produto_fornecedor, principal)
VALUES
(1, 2, 5, 0.12, 'CP-100C', TRUE),
(1, 3, 7, 0.14, 'CAP-CER-100', FALSE),
(2, 2, 5, 0.25, 'CE-220U', TRUE),
(3, 3, 5, 0.04, 'R-10K-025', TRUE),
(4, 4, 10, 1.00, 'NE555', TRUE),
(5, 4, 15, 9.50, 'ATMEGA328P-PU', TRUE),
(5, 1, 20, 10.00, 'ATMG328', FALSE),
(6, 3, 5, 0.08, 'D-1N4007', TRUE),
(7, 3, 5, 0.15, 'T-BC547', TRUE),
(8, 1, 7, 0.70, 'CN-USB-B', TRUE),
(9, 4, 15, 18.00, 'ESP32-DEV', TRUE),
(10, 1, 10, 7.50, 'LCD16X2-BL', TRUE);

SELECT*FROM ProdutosFornecedores;

-- Inserir clientes
INSERT INTO Clientes (tipo, nome, cpf_cnpj, endereco, cidade, estado, cep, telefone, email, data_cadastro, limite_credito)
VALUES
('PJ', 'Eletrônica Paulista Ltda', '78.901.234/0001-56', 'Rua Augusta, 1200', 'São Paulo', 'SP', '01304-001', '(11) 3333-9999', 'compras@eletronicapaulista.com.br', '2022-07-01', 5000.00),
('PJ', 'TechMaster Automação S.A.', '89.012.345/0001-67', 'Av. Moema, 500', 'São Paulo', 'SP', '04077-020', '(11) 3333-1010', 'compras@techmaster.com.br', '2022-07-10', 10000.00),
('PJ', 'Automação Industrial RB Ltda', '90.123.456/0001-78', 'Rua das Fábricas, 300', 'Campinas', 'SP', '13054-000', '(19) 3333-2020', 'contato@automaçãorb.com.br', '2022-07-15', 8000.00),
('PJ', 'Robotech Sistemas Ltda', '01.234.567/0001-89', 'Rod. Dom Pedro I, Km 129', 'Campinas', 'SP', '13086-902', '(19) 3333-3030', 'compras@robotech.com.br', '2022-07-20', 15000.00),
('PF', 'João Carlos Silva', '123.456.789-00', 'Rua Coronel Quirino, 1500', 'Campinas', 'SP', '13025-002', '(19) 98888-4040', 'joao.silva@email.com', '2022-07-25', 2000.00);

SELECT*FROM Clientes;

-- Criar alguns pedidos
CALL CriarPedido(1, 3, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'a_vista', 'Pedido urgente', @pedido_id, @msg);
CALL AdicionarItemPedido(@pedido_id, 4, 10, 2.50, 0, @msg);
CALL AdicionarItemPedido(@pedido_id, 6, 100, 0.25, 0, @msg);
CALL AdicionarItemPedido(@pedido_id, 3, 200, 0.15, 0, @msg);

CALL CriarPedido(2, 3, DATE_ADD(CURDATE(), INTERVAL 15 DAY), 'prazo_30', 'Pedido mensal', @pedido_id, @msg);
CALL AdicionarItemPedido(@pedido_id, 5, 5, 18.90, 0, @msg);
CALL AdicionarItemPedido(@pedido_id, 8, 20, 1.50, 0, @msg);
CALL AdicionarItemPedido(@pedido_id, 9, 3, 35.00, 5, @msg);

CALL CriarPedido(3, 3, DATE_ADD(CURDATE(), INTERVAL 10 DAY), 'prazo_30', 'Pedido para projeto', @pedido_id, @msg);
CALL AdicionarItemPedido(@pedido_id, 10, 5, 15.00, 0, @msg);
CALL AdicionarItemPedido(@pedido_id, 7, 50, 0.40, 0, @msg);

-- Confirmar um pedido (que atualizará estoque)
CALL ConfirmarPedido(1, 3, @msg);

-- Criar uma ordem de compra para reposição
CALL CriarOrdemCompraReposicao(2, @compra_id, @msg);

-- Simular recebimento parcial de uma compra
UPDATE ItensCompra SET quantidade_recebida = quantidade WHERE compra_id = @compra_id AND produto_id = 5;