-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 22-Dez-2025 às 22:53
-- Versão do servidor: 10.4.32-MariaDB
-- versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `estagios_parte2`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `p1_registar_estagio` (IN `p_aluno_id` INT, IN `p_formador_id` INT, IN `p_empresa_id` INT, IN `p_estabelecimento_id` INT, IN `p_data_inicio` DATE, IN `p_data_fim` DATE)   BEGIN
    DECLARE v_aluno_existe INT DEFAULT 0;
    DECLARE v_formador_existe INT DEFAULT 0;
    DECLARE v_estabelecimento_existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_aluno_existe FROM Aluno WHERE utilizador_id = p_aluno_id;
    SELECT COUNT(*) INTO v_formador_existe FROM Formador WHERE utilizador_id = p_formador_id;
    SELECT COUNT(*) INTO v_estabelecimento_existe FROM Estabelecimento WHERE empresa_id = p_empresa_id AND estabelecimento_id = p_estabelecimento_id;
    
    IF v_aluno_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Aluno não existe na base de dados';
    END IF;
    IF v_formador_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Formador não existe na base de dados';
    END IF;
    IF v_estabelecimento_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Estabelecimento não existe na base de dados';
    END IF;
    
    INSERT INTO Estagio (
        aluno_id, formador_id, 
        estabelecimento_empresa_id, estabelecimento_id,
        data_inicio, data_fim,
        nota_escola, nota_relatorio, nota_procura, nota_empresa, classificacao
    ) VALUES (
        p_aluno_id, p_formador_id, p_empresa_id, p_estabelecimento_id,
        p_data_inicio, p_data_fim,
        0, 0, 0, 0, NULL
    );    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p2_next_estagios` (IN `p_numero_dias` INT)   BEGIN
    SELECT 
        u_aluno.nome AS Nome_Aluno,
        u_formador.nome AS Nome_Formador,
        emp.firma AS Nome_Empresa,
        est.nome_comercial AS Nome_Estabelecimento,
        e.data_inicio,
        DATEDIFF(e.data_inicio, CURDATE()) AS Dias_Ate_Inicio
    FROM Estagio e
    INNER JOIN Aluno a ON e.aluno_id = a.utilizador_id
    INNER JOIN Utilizador u_aluno ON a.utilizador_id = u_aluno.utilizador_id
    INNER JOIN Formador f ON e.formador_id = f.utilizador_id
    INNER JOIN Utilizador u_formador ON f.utilizador_id = u_formador.utilizador_id
    INNER JOIN Estabelecimento est ON e.estabelecimento_empresa_id = est.empresa_id 
                                   AND e.estabelecimento_id = est.estabelecimento_id
    INNER JOIN Empresa emp ON est.empresa_id = emp.empresa_id
    WHERE DATEDIFF(e.data_inicio, CURDATE()) BETWEEN 0 AND p_numero_dias
    ORDER BY e.data_inicio ASC;
END$$

--
-- Funções
--
CREATE DEFINER=`root`@`localhost` FUNCTION `f1_calculo_media_estabelecimentos` (`p_empresa_id` INT, `p_estabelecimento_id` INT, `p_ano` INT) RETURNS DECIMAL(10,1) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE v_media DECIMAL(10, 1);
    
    SELECT AVG(e.classificacao) INTO v_media
    FROM Estagio e
    INNER JOIN Aluno a ON e.aluno_id = a.utilizador_id
    INNER JOIN Turma t ON a.turma_id = t.turma_id
    WHERE e.estabelecimento_empresa_id = p_empresa_id
        AND e.estabelecimento_id = p_estabelecimento_id
        AND t.ano = p_ano
        AND e.classificacao IS NOT NULL;
        
    RETURN IFNULL(v_media, 0);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `f2_calculo_nota_final` (`p_peso_empresa` FLOAT, `p_peso_escola` FLOAT, `p_peso_relatorio` FLOAT, `p_peso_procura` FLOAT, `p_empresa_id` INT, `p_estabelecimento_id` INT, `p_aluno_id` INT) RETURNS DECIMAL(10,1) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE v_nota_empresa FLOAT;
    DECLARE v_nota_relatorio FLOAT;
    DECLARE v_nota_escola FLOAT;
    DECLARE v_nota_procura FLOAT;
    DECLARE v_media DECIMAL(10, 2);

    SELECT nota_empresa, nota_relatorio, nota_escola, nota_procura
    INTO v_nota_empresa, v_nota_relatorio, v_nota_escola, v_nota_procura
    FROM Estagio
    WHERE estabelecimento_empresa_id = p_empresa_id
      AND estabelecimento_id = p_estabelecimento_id
      AND aluno_id = p_aluno_id;
      
    IF v_nota_empresa IS NULL OR 
       v_nota_relatorio IS NULL OR 
       v_nota_escola IS NULL OR 
       v_nota_procura IS NULL THEN
        RETURN NULL;
    END IF;

    IF ABS((p_peso_empresa + p_peso_escola + p_peso_relatorio + p_peso_procura) - 1.0) > 0.01 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A soma dos pesos deve ser 1';
    END IF;
        
    SET v_media = (v_nota_empresa * p_peso_empresa) + 
                  (v_nota_relatorio * p_peso_relatorio) + 
                  (v_nota_escola * p_peso_escola) + 
                  (v_nota_procura * p_peso_procura);
                  
    RETURN v_media;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `administrativo`
--

CREATE TABLE `administrativo` (
  `utilizador_id` int(11) NOT NULL,
  `funcao` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `administrativo`
--

INSERT INTO `administrativo` (`utilizador_id`, `funcao`) VALUES
(6, 'Secretariado'),
(7, 'Direção');

-- --------------------------------------------------------

--
-- Estrutura da tabela `aluno`
--

CREATE TABLE `aluno` (
  `turma_id` int(11) NOT NULL,
  `utilizador_id` int(11) NOT NULL,
  `numero` int(11) DEFAULT NULL,
  `observacoes` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `aluno`
--

INSERT INTO `aluno` (`turma_id`, `utilizador_id`, `numero`, `observacoes`) VALUES
(1, 1, 10, NULL),
(1, 2, 11, NULL),
(2, 3, 4, NULL),
(1, 8, 2, NULL),
(3, 9, 2, NULL),
(2, 10, 7, NULL),
(3, 11, 23, NULL),
(7, 12, 13, NULL),
(1, 100, 129850, NULL),
(1, 101, 129851, NULL),
(1, 102, 129852, NULL),
(1, 103, 129853, NULL),
(1, 104, 129854, NULL),
(2, 105, 129857, NULL),
(2, 106, 129858, NULL),
(2, 107, 129859, NULL),
(2, 108, 129860, NULL),
(2, 109, 129861, NULL),
(3, 110, 129862, NULL),
(3, 111, 129863, NULL),
(3, 112, 129864, NULL),
(3, 113, 129865, NULL),
(3, 114, 129866, NULL),
(4, 115, 129867, NULL),
(4, 116, 129868, NULL),
(4, 117, 129869, NULL),
(4, 118, 129870, NULL),
(4, 119, 129871, NULL),
(1, 120, 129855, NULL),
(1, 121, 129856, NULL),
(1, 122, 129872, NULL),
(1, 123, 129873, NULL),
(1, 124, 129874, NULL),
(1, 150, 129900, NULL),
(1, 151, 129901, NULL),
(1, 152, 129902, NULL),
(1, 153, 129903, NULL),
(1, 154, 129904, NULL),
(1, 155, 129905, NULL),
(1, 156, 129906, NULL),
(1, 157, 129907, NULL),
(1, 158, 129908, NULL),
(1, 159, 129909, NULL),
(1, 160, 129910, NULL),
(1, 161, 129911, NULL),
(1, 162, 129912, NULL),
(2, 163, 129913, NULL),
(2, 164, 129914, NULL),
(2, 165, 129915, NULL),
(2, 166, 129916, NULL),
(2, 167, 129917, NULL),
(2, 168, 129918, NULL),
(2, 169, 129919, NULL),
(2, 170, 129920, NULL),
(2, 171, 129921, NULL),
(2, 172, 129922, NULL),
(2, 173, 129923, NULL),
(2, 174, 129924, NULL),
(2, 175, 129925, NULL),
(3, 176, 129926, NULL),
(3, 177, 129927, NULL),
(3, 178, 129928, NULL),
(3, 179, 129929, NULL),
(3, 180, 129930, NULL),
(3, 181, 129930, NULL),
(3, 182, 129932, NULL),
(3, 183, 129933, NULL),
(3, 184, 129934, NULL),
(3, 185, 129935, NULL),
(3, 186, 129936, NULL),
(3, 187, 129937, NULL),
(4, 188, 129938, NULL),
(4, 189, 129939, NULL),
(4, 190, 129940, NULL),
(4, 191, 129941, NULL),
(4, 192, 129942, NULL),
(4, 193, 129943, NULL),
(4, 194, 129944, NULL),
(4, 195, 129945, NULL),
(4, 196, 129946, NULL),
(4, 197, 129947, NULL),
(4, 198, 129948, NULL),
(4, 199, 129949, NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `classificacao`
--

CREATE TABLE `classificacao` (
  `estabelecimento_empresa_id` int(11) NOT NULL,
  `estabelecimento_id` int(11) NOT NULL,
  `classificacao_id` int(11) NOT NULL,
  `ano_letivo` varchar(150) DEFAULT NULL,
  `media` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `classificacao`
--

INSERT INTO `classificacao` (`estabelecimento_empresa_id`, `estabelecimento_id`, `classificacao_id`, `ano_letivo`, `media`) VALUES
(1, 1, 1, '2023/2024', 4.3),
(2, 1, 2, '2023/2024', 4),
(3, 1, 3, '2023/2024', 3.9);

-- --------------------------------------------------------

--
-- Estrutura da tabela `comercializa`
--

CREATE TABLE `comercializa` (
  `estabelecimento_empresa_id` int(11) NOT NULL,
  `estabelecimento_id` int(11) NOT NULL,
  `produto_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `comercializa`
--

INSERT INTO `comercializa` (`estabelecimento_empresa_id`, `estabelecimento_id`, `produto_id`) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3);

-- --------------------------------------------------------

--
-- Estrutura da tabela `curso`
--

CREATE TABLE `curso` (
  `curso_id` int(11) NOT NULL,
  `codigo` varchar(150) DEFAULT NULL,
  `designacao` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `curso`
--

INSERT INTO `curso` (`curso_id`, `codigo`, `designacao`) VALUES
(1, 'INF01', 'Informática'),
(2, 'GEST01', 'Gestão'),
(3, 'CONT01', 'Contabilidade'),
(4, 'MKT01', 'Marketing'),
(5, 'DIR01', 'Direito'),
(6, 'SAU01', 'Saúde'),
(7, 'EDI01', 'Edificações');

-- --------------------------------------------------------

--
-- Estrutura da tabela `disponibilidade`
--

CREATE TABLE `disponibilidade` (
  `empresa_id` int(11) NOT NULL,
  `disponibilidade_id` int(11) NOT NULL,
  `ano` int(11) DEFAULT NULL,
  `num_estagios` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `disponibilidade`
--

INSERT INTO `disponibilidade` (`empresa_id`, `disponibilidade_id`, `ano`, `num_estagios`) VALUES
(1, 1, 2024, 3),
(2, 2, 2024, 2),
(3, 3, 2024, 4);

-- --------------------------------------------------------

--
-- Estrutura da tabela `empresa`
--

CREATE TABLE `empresa` (
  `responsavel_id` int(11) DEFAULT NULL,
  `empresa_id` int(11) NOT NULL,
  `num_contribuinte` char(9) DEFAULT NULL,
  `firma` varchar(150) DEFAULT NULL,
  `morada_sede` varchar(150) DEFAULT NULL,
  `localidade` varchar(150) DEFAULT NULL,
  `codigo_postal` char(8) DEFAULT NULL,
  `telefone` varchar(150) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `website` varchar(150) DEFAULT NULL,
  `tipo_organizacao` varchar(150) DEFAULT NULL,
  `observacoes` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `empresa`
--

INSERT INTO `empresa` (`responsavel_id`, `empresa_id`, `num_contribuinte`, `firma`, `morada_sede`, `localidade`, `codigo_postal`, `telefone`, `email`, `website`, `tipo_organizacao`, `observacoes`) VALUES
(1, 1, '123456789', 'TecSoft', 'Rua A', 'Lisboa', '1000-001', '210000001', 'info@tecsoft.com', NULL, 'Privada', NULL),
(2, 2, '234567890', 'MarketPlus', 'Rua B', 'Porto', '4000-002', '220000002', 'contact@marketplus.com', NULL, 'Privada', NULL),
(3, 3, '345678901', 'ContabPro', 'Rua C', 'Coimbra', '3000-003', '230000003', 'info@contabpro.com', NULL, 'Privada', NULL),
(4, 4, '456789012', 'HealthClinic', 'Rua D', 'Faro', '8000-004', '240000004', 'admin@healthclinic.com', NULL, 'Privada', NULL),
(5, 5, '567890123', 'BuilderCo', 'Rua E', 'Braga', '4700-005', '250000005', 'geral@builderco.com', NULL, 'Privada', NULL),
(6, 6, '678901234', 'LegalServices', 'Rua F', 'Évora', '7000-006', '260000006', 'info@legalservices.com', NULL, 'Privada', NULL),
(7, 7, '789012345', 'CreativeMedia', 'Rua G', 'Aveiro', '3800-007', '270000007', 'contact@creativemedia.com', NULL, 'Privada', NULL),
(NULL, 200, '500123456', 'Microsoft Portugal', 'Av. da República, 50', 'Lisboa', '1050-196', '217 213 000', '', NULL, 'Tecnologia', NULL),
(NULL, 201, '500234567', 'Google Portugal', 'Praça Duque de Saldanha, 1', 'Lisboa', '1050-094', '211 200 000', 'info@google.pt', NULL, 'Tecnologia', NULL),
(NULL, 202, '500345678', 'OutSystems', 'Rua Tierno Galvan, Torre 3', 'Lisboa', '1070-274', '214 819 090', 'info@outsystems.com', NULL, 'Software', NULL),
(NULL, 203, '500456789', 'Farfetch', 'Lionesa Innovation Hub', 'Porto', '4465-671', '220 136 000', 'info@farfetch.com', NULL, 'E-commerce', NULL),
(NULL, 204, '500567890', 'Talkdesk', 'Alameda dos Oceanos', 'Lisboa', '1990-392', '211 451 853', 'info@talkdesk.com', NULL, 'Software', NULL),
(NULL, 205, '500678901', 'Feedzai', 'Av. Duque de Ávila, 23', 'Lisboa', '1000-138', '211 451 830', 'info@feedzai.com', NULL, 'FinTech', NULL),
(NULL, 206, '500789012', 'Deloitte Portugal', 'Av. Eng. Duarte Pacheco, 7', 'Lisboa', '1070-100', '210 427 500', 'info@deloitte.pt', NULL, 'Consultoria', NULL),
(NULL, 207, '500890123', 'EY Portugal', 'Av. da República, 90', 'Lisboa', '1600-206', '217 912 000', 'info@ey.com', NULL, 'Consultoria', NULL),
(NULL, 208, '500901234', 'PwC Portugal', 'Palácio Sottomayor', 'Lisboa', '1069-015', '213 599 000', 'info@pwc.pt', NULL, 'Consultoria', NULL),
(NULL, 209, '501012345', 'Accenture Portugal', 'Lagoas Park, Edifício 10', 'Lisboa', '2740-244', '213 184 300', 'info@accenture.com', NULL, 'Consultoria', NULL),
(NULL, 210, '501123456', 'Caixa Geral de Depósitos', 'Av. João XXI, 63', 'Lisboa', '1000-300', '217 905 000', 'info@cgd.pt', NULL, 'Banca', NULL),
(NULL, 211, '501234567', 'Millennium BCP', 'Av. Prof. Dr. Cavaco Silva, 2', 'Lisboa', '1649-023', '211 131 000', 'info@millenniumbcp.pt', NULL, 'Banca', NULL),
(NULL, 212, '501345678', 'Sonae', 'Lugar do Espido', 'Porto', '4471-909', '229 487 522', 'info@sonae.pt', NULL, 'Retalho', NULL),
(NULL, 213, '501456789', 'EDP', 'Praça Marquês de Pombal, 12', 'Lisboa', '1250-162', '210 012 500', 'info@edp.pt', NULL, 'Energia', NULL),
(NULL, 214, '501567890', 'Galp Energia', 'Rua Tomás da Fonseca', 'Lisboa', '1600-209', '217 240 800', 'info@galp.com', NULL, 'Energia', NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `estabelecimento`
--

CREATE TABLE `estabelecimento` (
  `empresa_id` int(11) NOT NULL,
  `responsavel_id` int(11) NOT NULL,
  `zona_id` int(11) NOT NULL,
  `estabelecimento_id` int(11) NOT NULL,
  `nome_comercial` varchar(150) DEFAULT NULL,
  `morada` varchar(150) DEFAULT NULL,
  `localidade` varchar(150) DEFAULT NULL,
  `codigo_postal` varchar(150) DEFAULT NULL,
  `telefone` varchar(150) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `foto` int(11) DEFAULT NULL,
  `horario_funcionamento` varchar(150) DEFAULT NULL,
  `data_surgimento` date DEFAULT NULL,
  `aceitou_estagiarios` varchar(150) DEFAULT NULL,
  `observacoes` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `estabelecimento`
--

INSERT INTO `estabelecimento` (`empresa_id`, `responsavel_id`, `zona_id`, `estabelecimento_id`, `nome_comercial`, `morada`, `localidade`, `codigo_postal`, `telefone`, `email`, `foto`, `horario_funcionamento`, `data_surgimento`, `aceitou_estagiarios`, `observacoes`) VALUES
(1, 1, 1, 1, 'TecSoft Lisboa', 'Rua A1', 'Lisboa', '1000-001', '210000101', NULL, NULL, NULL, NULL, 'sim', NULL),
(2, 2, 2, 1, 'MarketPlus Porto', 'Rua B1', 'Porto', '4000-002', '220000102', NULL, NULL, NULL, NULL, 'sim', NULL),
(3, 3, 3, 1, 'ContabPro Coimbra', 'Rua C1', 'Coimbra', '3000-003', '230000103', NULL, NULL, NULL, NULL, 'sim', NULL),
(200, 500, 1, 300, 'Microsoft Lisboa - Sede', 'Av. da República, 50', 'Lisboa', '1050-196', '217 213 000', 'lisboa@microsoft.pt', NULL, '09:00-18:00', '2000-01-15', '1', NULL),
(200, 501, 2, 301, 'Microsoft Porto', 'Rua de Ceuta, 118', 'Porto', '4050-190', '220 000 000', 'porto@microsoft.pt', NULL, '09:00-18:00', '2005-03-20', '1', NULL),
(201, 502, 1, 302, 'Google Lisboa', 'Praça Duque de Saldanha, 1', 'Lisboa', '1050-094', '211 200 000', 'lisboa@google.pt', NULL, '09:00-18:00', '2004-06-10', '1', NULL),
(202, 503, 1, 303, 'OutSystems Lisboa - HQ', 'Rua Tierno Galvan, Torre 3', 'Lisboa', '1070-274', '214 819 090', 'hq@outsystems.com', NULL, '09:00-18:00', '2001-02-01', '1', NULL),
(202, 504, 2, 304, 'OutSystems Porto', 'Rua Dr. António Bernardino de Almeida', 'Porto', '4200-072', '220 100 000', 'porto@outsystems.com', NULL, '09:00-18:00', '2010-05-15', '1', NULL),
(203, 505, 2, 305, 'Farfetch Porto - Tech Hub', 'Lionesa Innovation Hub', 'Porto', '4465-671', '220 136 000', 'tech@farfetch.com', NULL, '09:00-19:00', '2007-08-01', '1', NULL),
(204, 506, 1, 306, 'Talkdesk Lisboa', 'Alameda dos Oceanos', 'Lisboa', '1990-392', '211 451 853', 'lisboa@talkdesk.com', NULL, '08:00-20:00', '2011-10-01', '1', NULL),
(205, 507, 1, 307, 'Feedzai Lisboa', 'Av. Duque de Ávila, 23', 'Lisboa', '1000-138', '211 451 830', 'lisboa@feedzai.com', NULL, '09:00-18:00', '2009-03-15', '1', NULL),
(206, 508, 1, 308, 'Deloitte Lisboa', 'Av. Eng. Duarte Pacheco, 7', 'Lisboa', '1070-100', '210 427 500', 'lisboa@deloitte.pt', NULL, '09:00-18:00', '1990-01-01', '1', NULL),
(207, 509, 1, 309, 'EY Lisboa', 'Av. da República, 90', 'Lisboa', '1600-206', '217 912 000', 'lisboa@ey.com', NULL, '09:00-18:00', '1995-05-20', '1', NULL),
(208, 510, 1, 310, 'PwC Lisboa', 'Palácio Sottomayor', 'Lisboa', '1069-015', '213 599 000', 'lisboa@pwc.pt', NULL, '09:00-18:00', '1998-03-10', '1', NULL),
(208, 511, 2, 311, 'PwC Porto', 'Bessa Leite Complex', 'Porto', '4100-134', '223 000 000', 'porto@pwc.pt', NULL, '09:00-18:00', '2002-09-01', '1', NULL),
(209, 512, 1, 312, 'Accenture Lisboa', 'Lagoas Park, Edifício 10', 'Lisboa', '2740-244', '213 184 300', 'lisboa@accenture.com', NULL, '09:00-18:00', '2000-11-15', '1', NULL),
(210, 513, 1, 313, 'CGD Sede', 'Av. João XXI, 63', 'Lisboa', '1000-300', '217 905 000', 'sede@cgd.pt', NULL, '08:30-15:00', '1876-04-10', '1', NULL),
(211, 514, 1, 314, 'Millennium BCP HQ', 'Av. Prof. Dr. Cavaco Silva, 2', 'Lisboa', '1649-023', '211 131 000', 'hq@millenniumbcp.pt', NULL, '08:30-15:00', '1985-06-01', '1', NULL),
(212, 515, 2, 315, 'Sonae MC', 'Lugar do Espido', 'Porto', '4471-909', '229 487 522', 'mc@sonae.pt', NULL, '09:00-18:00', '1959-08-18', '1', NULL),
(213, 516, 1, 316, 'EDP Sede', 'Praça Marquês de Pombal, 12', 'Lisboa', '1250-162', '210 012 500', 'sede@edp.pt', NULL, '09:00-18:00', '1976-05-03', '1', NULL),
(213, 517, 2, 317, 'EDP Porto', 'Rua Dr. António Bernardino de Almeida', 'Porto', '4200-072', '225 000 000', 'porto@edp.pt', NULL, '09:00-18:00', '1980-10-20', '1', NULL),
(214, 518, 1, 318, 'Galp Sede', 'Rua Tomás da Fonseca', 'Lisboa', '1600-209', '217 240 800', 'sede@galp.com', NULL, '09:00-18:00', '1999-04-22', '1', NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `estagio`
--

CREATE TABLE `estagio` (
  `estabelecimento_empresa_id` int(11) NOT NULL,
  `estabelecimento_id` int(11) NOT NULL,
  `aluno_id` int(11) NOT NULL,
  `formador_id` int(11) NOT NULL,
  `data_inicio` date DEFAULT NULL,
  `data_fim` date DEFAULT NULL,
  `nota_empresa` double DEFAULT NULL,
  `nota_escola` double NOT NULL,
  `nota_relatorio` double NOT NULL,
  `nota_procura` double NOT NULL,
  `nota_final` double DEFAULT NULL,
  `classificacao` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `estagio`
--

INSERT INTO `estagio` (`estabelecimento_empresa_id`, `estabelecimento_id`, `aluno_id`, `formador_id`, `data_inicio`, `data_fim`, `nota_empresa`, `nota_escola`, `nota_relatorio`, `nota_procura`, `nota_final`, `classificacao`) VALUES
(1, 1, 1, 4, '2024-02-01', '2024-05-01', 15, 20, 0, 20, 14, 4),
(2, 1, 2, 4, '2024-02-01', '2024-05-01', 12.1, 14, 14.4, 11.1, 13, 5),
(3, 1, 2, 5, '2025-11-02', '2025-11-28', 20, 19, 18, 18, 19, 5),
(3, 1, 3, 5, '2024-02-01', '2024-05-01', 18, 0, 0, 0, 17, 3),
(3, 1, 8, 4, '2025-12-12', '2026-01-01', 12, 13, 9, 0, 10.5, NULL),
(3, 1, 9, 4, '2025-12-15', '2026-12-11', 1, 0, 0, 0, 0.4, NULL),
(200, 300, 100, 4, '2024-09-01', '2025-01-31', 16, 15, 17, 14, 15.7, NULL),
(200, 300, 123, 50, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(200, 301, 105, 51, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(201, 302, 101, 50, '2024-09-01', '2025-01-31', 18, 17, 16, 15, 17, NULL),
(201, 302, 124, 56, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(202, 303, 102, 51, '2024-09-01', '2025-01-31', 15, 14, 15, 13, 14.5, NULL),
(202, 304, 106, 52, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(203, 305, 103, 52, '2024-09-01', '2025-01-31', 17, 16, 18, 16, 16.8, NULL),
(204, 306, 104, 50, '2024-09-01', '2025-01-31', 14, 13, 14, 12, 13.5, NULL),
(205, 307, 107, 50, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(206, 308, 110, 53, '2024-09-01', '2025-01-31', 16, 17, 15, 14, 15.9, NULL),
(206, 308, 119, 54, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(207, 309, 111, 54, '2024-09-01', '2025-01-31', 18, 18, 17, 16, 17.6, NULL),
(207, 309, 120, 53, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(208, 310, 112, 53, '2024-09-01', '2025-01-31', 17, 16, 16, 15, 16.3, NULL),
(208, 311, 108, 54, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(209, 312, 10, 54, '2025-12-01', '2026-01-01', 0, 0, 0, 0, NULL, NULL),
(209, 312, 100, 4, '2025-12-12', '2026-01-12', 0, 0, 0, 0, NULL, NULL),
(209, 312, 113, 55, '2024-09-01', '2025-01-31', 16, 15, 17, 14, 15.7, NULL),
(209, 312, 121, 52, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(209, 312, 150, 4, '2023-12-12', '2027-12-12', 0, 0, 0, 0, NULL, NULL),
(210, 313, 114, 56, '2024-09-01', '2025-01-31', 15, 16, 14, 13, 14.9, NULL),
(210, 313, 122, 51, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(212, 315, 115, 55, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(213, 316, 116, 56, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(213, 317, 117, 57, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL),
(214, 318, 118, 55, '2025-02-01', '2025-06-30', 0, 0, 0, 0, NULL, NULL);

--
-- Acionadores `estagio`
--
DELIMITER $$
CREATE TRIGGER `t1_classificacao_insert` BEFORE INSERT ON `estagio` FOR EACH ROW BEGIN
    IF NEW.classificacao IS NOT NULL AND (NEW.classificacao < 1 OR NEW.classificacao > 5) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A classificacao esta fora do intervalo (1 a 5).';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `t1_classificacao_update` BEFORE UPDATE ON `estagio` FOR EACH ROW BEGIN
    IF NEW.classificacao IS NOT NULL AND (NEW.classificacao < 1 OR NEW.classificacao > 5) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A classificacao esta fora do intervalo (1 a 5).';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `t2_data_fim_data_inicio_insert` BEFORE INSERT ON `estagio` FOR EACH ROW BEGIN
    IF NEW.data_inicio > NEW.data_fim THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: A data de inicio do estagio não pode ser posterior a data de fim.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `t2_data_fim_data_inicio_update` BEFORE UPDATE ON `estagio` FOR EACH ROW BEGIN
    IF NEW.data_inicio > NEW.data_fim THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: A data de inicio do estagio não pode ser posterior a data de fim.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `formador`
--

CREATE TABLE `formador` (
  `utilizador_id` int(11) NOT NULL,
  `num_formador` int(11) DEFAULT NULL,
  `disciplina` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `formador`
--

INSERT INTO `formador` (`utilizador_id`, `num_formador`, `disciplina`) VALUES
(4, 101, 'Programação'),
(5, 102, 'Gestão de Projetos'),
(50, 0, 'Bases de Dados'),
(51, 0, 'Programação'),
(52, 0, 'Redes'),
(53, 0, 'Gestão de Projetos'),
(54, 0, 'Inteligência Artificial'),
(55, 0, 'Marketing Digital'),
(56, 0, 'Design'),
(57, 0, 'Economia');

-- --------------------------------------------------------

--
-- Estrutura da tabela `produto`
--

CREATE TABLE `produto` (
  `produto_id` int(11) NOT NULL,
  `nome_produto` varchar(150) DEFAULT NULL,
  `marca` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `produto`
--

INSERT INTO `produto` (`produto_id`, `nome_produto`, `marca`) VALUES
(1, 'Software Gestão', 'TecSoft'),
(2, 'Serviço Consultoria', 'MarketPlus'),
(3, 'Software Contabilidade', 'ContabPro'),
(4, 'Serviço Clínico', 'HealthClinic'),
(5, 'Material Construção', 'BuilderCo'),
(6, 'Serviço Jurídico', 'LegalServices'),
(7, 'Campanha Publicitária', 'CreativeMedia');

-- --------------------------------------------------------

--
-- Estrutura da tabela `ramo_atividade`
--

CREATE TABLE `ramo_atividade` (
  `ramo_atividade_id` int(11) NOT NULL,
  `codigo_cae` varchar(150) DEFAULT NULL,
  `descricao` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `ramo_atividade`
--

INSERT INTO `ramo_atividade` (`ramo_atividade_id`, `codigo_cae`, `descricao`) VALUES
(1, '6201', 'Programação informática'),
(2, '4711', 'Comércio'),
(3, '6920', 'Contabilidade'),
(4, '8622', 'Clínicas'),
(5, '4120', 'Construção Civil'),
(6, '6910', 'Direito'),
(7, '7311', 'Publicidade');

-- --------------------------------------------------------

--
-- Estrutura da tabela `responsavel`
--

CREATE TABLE `responsavel` (
  `responsavel_id` int(11) NOT NULL,
  `nome` varchar(150) DEFAULT NULL,
  `titulo` varchar(150) DEFAULT NULL,
  `cargo` varchar(150) DEFAULT NULL,
  `telefone_direto` varchar(150) DEFAULT NULL,
  `telemovel` varchar(150) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `observacoes` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `responsavel`
--

INSERT INTO `responsavel` (`responsavel_id`, `nome`, `titulo`, `cargo`, `telefone_direto`, `telemovel`, `email`, `observacoes`) VALUES
(1, 'José Pereira', 'Dr.', 'Gerente Geral', '212345678', '912345678', 'jose@empresa.com', NULL),
(2, 'Rita Costa', 'Eng.', 'Diretora', '212398888', '918888888', 'rita@empresa.com', NULL),
(3, 'Pedro Alves', NULL, 'Supervisor', NULL, '919191919', NULL, NULL),
(4, 'Mariana Ribeiro', 'Dr.', 'Administradora', NULL, NULL, NULL, NULL),
(5, 'Tiago Ramos', NULL, 'Chefe', NULL, NULL, NULL, NULL),
(6, 'Carlos Martins', NULL, 'Gestor', NULL, NULL, NULL, NULL),
(7, 'Sofia Duarte', NULL, 'Responsável', NULL, NULL, NULL, NULL),
(8, 'Carlos Mendes', 'Dr.', 'Diretor de RH', '217 213 001', '912345001', 'carlos.mendes@microsoft.pt', NULL),
(9, 'Rita Santos', 'Dra.', 'HR Manager', '217 213 002', '912345002', 'rita.santos@microsoft.pt', NULL),
(500, 'Carlos Mendes', 'Dr.', 'Diretor de RH', '217 213 001', '912345001', 'carlos.mendes@microsoft.pt', NULL),
(501, 'Rita Santos', 'Dra.', 'HR Manager', '217 213 002', '912345002', 'rita.santos@microsoft.pt', NULL),
(502, 'João Oliveira', 'Eng.', 'People Operations', '211 200 001', '912345003', 'joao.oliveira@google.pt', NULL),
(503, 'Ana Silva', 'Dra.', 'Talent Manager', '214 819 091', '912345004', 'ana.silva@outsystems.com', NULL),
(504, 'Pedro Costa', 'Dr.', 'HR Director', '214 819 092', '912345005', 'pedro.costa@outsystems.com', NULL),
(505, 'Maria Ferreira', 'Eng.', 'People Manager', '220 136 001', '912345006', 'maria.ferreira@farfetch.com', NULL),
(506, 'António Rodrigues', 'Dr.', 'HR Manager', '211 451 854', '912345007', 'antonio.rodrigues@talkdesk.com', NULL),
(507, 'Isabel Sousa', 'Dra.', 'Talent Acquisition', '211 451 831', '912345008', 'isabel.sousa@feedzai.com', NULL),
(508, 'Fernando Alves', 'Dr.', 'Partner', '210 427 501', '912345009', 'fernando.alves@deloitte.pt', NULL),
(509, 'Helena Gomes', 'Dra.', 'Senior Manager', '217 912 001', '912345010', 'helena.gomes@ey.com', NULL),
(510, 'Ricardo Martins', 'Dr.', 'Director', '213 599 001', '912345011', 'ricardo.martins@pwc.pt', NULL),
(511, 'Patrícia Dias', 'Dra.', 'HR Lead', '213 599 002', '912345012', 'patricia.dias@pwc.pt', NULL),
(512, 'Miguel Pinto', 'Dr.', 'Managing Director', '213 184 301', '912345013', 'miguel.pinto@accenture.com', NULL),
(513, 'Sofia Carvalho', 'Dra.', 'Diretora RH', '217 905 001', '912345014', 'sofia.carvalho@cgd.pt', NULL),
(514, 'Bruno Lopes', 'Dr.', 'Gestor RH', '211 131 001', '912345015', 'bruno.lopes@millenniumbcp.pt', NULL),
(515, 'Catarina Ribeiro', 'Dra.', 'Coordenadora RH', '229 487 523', '912345016', 'catarina.ribeiro@sonae.pt', NULL),
(516, 'Diogo Nunes', 'Eng.', 'Diretor RH', '210 012 501', '912345017', 'diogo.nunes@edp.pt', NULL),
(517, 'Beatriz Correia', 'Dra.', 'HR Manager', '225 000 001', '912345018', 'beatriz.correia@edp.pt', NULL),
(518, 'Tiago Moreira', 'Dr.', 'Gestor Recursos Humanos', '217 240 801', '912345019', 'tiago.moreira@galp.pt', NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `serve`
--

CREATE TABLE `serve` (
  `transporte_id` int(11) NOT NULL,
  `zona_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `serve`
--

INSERT INTO `serve` (`transporte_id`, `zona_id`) VALUES
(1, 1),
(2, 2),
(3, 3);

-- --------------------------------------------------------

--
-- Estrutura da tabela `servido`
--

CREATE TABLE `servido` (
  `estabelecimento_empresa_id` int(11) NOT NULL,
  `estabelecimento_id` int(11) NOT NULL,
  `transporte_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `servido`
--

INSERT INTO `servido` (`estabelecimento_empresa_id`, `estabelecimento_id`, `transporte_id`) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3);

-- --------------------------------------------------------

--
-- Estrutura da tabela `trabalha`
--

CREATE TABLE `trabalha` (
  `empresa_id` int(11) NOT NULL,
  `ramo_atividade_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `trabalha`
--

INSERT INTO `trabalha` (`empresa_id`, `ramo_atividade_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7);

-- --------------------------------------------------------

--
-- Estrutura da tabela `transporte`
--

CREATE TABLE `transporte` (
  `transporte_id` int(11) NOT NULL,
  `meio_transporte` varchar(150) DEFAULT NULL,
  `linha` varchar(150) DEFAULT NULL,
  `observacoes` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `transporte`
--

INSERT INTO `transporte` (`transporte_id`, `meio_transporte`, `linha`, `observacoes`) VALUES
(1, 'Autocarro', 'Linha 10', NULL),
(2, 'Metro', 'Linha Azul', NULL),
(3, 'Comboio', 'Linha Norte', NULL),
(4, 'Táxi', 'Linha 2', NULL),
(5, 'Uber', 'Linha Norte', NULL),
(6, 'Carrinha Empresa', NULL, NULL),
(7, 'Elétrico', 'Linha 28', NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `turma`
--

CREATE TABLE `turma` (
  `curso_id` int(11) NOT NULL,
  `turma_id` int(11) NOT NULL,
  `sigla` varchar(150) DEFAULT NULL,
  `ano` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `turma`
--

INSERT INTO `turma` (`curso_id`, `turma_id`, `sigla`, `ano`) VALUES
(1, 1, 'INF-A', 2024),
(1, 2, 'INF-B', 2024),
(2, 3, 'GEST-A', 2024),
(3, 4, 'CONT-A', 2024),
(4, 5, 'MKT-A', 2024),
(5, 6, 'DIR-A', 2024),
(6, 7, 'SAU-A', 2024);

-- --------------------------------------------------------

--
-- Estrutura da tabela `utilizador`
--

CREATE TABLE `utilizador` (
  `utilizador_id` int(11) NOT NULL,
  `login` varchar(150) DEFAULT NULL,
  `password` varchar(150) DEFAULT NULL,
  `nome` varchar(150) DEFAULT NULL,
  `tipo` enum('aluno','formador','administrativo','') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `utilizador`
--

INSERT INTO `utilizador` (`utilizador_id`, `login`, `password`, `nome`, `tipo`) VALUES
(1, 'joao.silva', 'pass123', 'João Silva', 'aluno'),
(2, 'maria.lima', 'pass123', 'Maria Lima', 'aluno'),
(3, 'carlos.sousa', 'pass123', 'Carlos Sousa', 'aluno'),
(4, 'ana.mendes', 'pass123', 'Ana Mendes', 'formador'),
(5, 'ricardo.gomes', 'pass123', 'Ricardo Gomes', 'formador'),
(6, 'helena.alves', 'pass123', 'Helena Alves', 'administrativo'),
(7, 'paulo.rocha', 'pass123', 'Paulo Rocha', 'administrativo'),
(8, 'amoalenda', 'amoalenda', 'Daniel de Matos Masqueiro', 'aluno'),
(9, 'lendaviva', 'quagmire', 'Martim Laranjinha', 'aluno'),
(10, 'frog', 'benfas', 'Gonçalo Gato', 'aluno'),
(11, 'bolo', 'bolotabolotinha', 'Duarte Oliveira', 'aluno'),
(12, 'denise', 'ekazzio', 'Dinis Sousa', 'aluno'),
(50, 'joao.ferreira', 'pass123', 'João Ferreira', 'formador'),
(51, 'maria.oliveira', 'pass123', 'Maria Oliveira', 'formador'),
(52, 'pedro.sousa', 'pass123', 'Pedro Sousa', 'formador'),
(53, 'rita.rodrigues', 'pass123', 'Rita Rodrigues', 'formador'),
(54, 'antonio.silva', 'pass123', 'António Silva', 'formador'),
(55, 'isabel.gomes', 'pass123', 'Isabel Gomes', 'formador'),
(56, 'fernando.martins', 'pass123', 'Fernando Martins', 'formador'),
(57, 'patricia.santos', 'pass123', 'Patrícia Santos', 'formador'),
(100, 'ana.costa', 'pass123', 'Ana Costa', 'aluno'),
(101, 'pedro.santos', 'pass123', 'Pedro Santos', 'aluno'),
(102, 'maria.fernandes', 'pass123', 'Maria Fernandes', 'aluno'),
(103, 'ricardo.alves', 'pass123', 'Ricardo Alves', 'aluno'),
(104, 'sofia.pereira', 'pass123', 'Sofia Pereira', 'aluno'),
(105, 'tiago.rodrigues', 'pass123', 'Tiago Rodrigues', 'aluno'),
(106, 'beatriz.sousa', 'pass123', 'Beatriz Sousa', 'aluno'),
(107, 'miguel.carvalho', 'pass123', 'Miguel Carvalho', 'aluno'),
(108, 'carolina.lopes', 'pass123', 'Carolina Lopes', 'aluno'),
(109, 'andre.gomes', 'pass123', 'André Gomes', 'aluno'),
(110, 'ines.martins', 'pass123', 'Inês Martins', 'aluno'),
(111, 'diogo.ferreira', 'pass123', 'Diogo Ferreira', 'aluno'),
(112, 'catarina.dias', 'pass123', 'Catarina Dias', 'aluno'),
(113, 'bruno.costa', 'pass123', 'Bruno Costa', 'aluno'),
(114, 'sara.oliveira', 'pass123', 'Sara Oliveira', 'aluno'),
(115, 'luis.santos', 'pass123', 'Luís Santos', 'aluno'),
(116, 'patricia.almeida', 'pass123', 'Patrícia Almeida', 'aluno'),
(117, 'rafael.silva', 'pass123', 'Rafael Silva', 'aluno'),
(118, 'joana.pinto', 'pass123', 'Joana Pinto', 'aluno'),
(119, 'vasco.ribeiro', 'pass123', 'Vasco Ribeiro', 'aluno'),
(120, 'mariana.nunes', 'pass123', 'Mariana Nunes', 'aluno'),
(121, 'goncalo.soares', 'pass123', 'Gonçalo Soares', 'aluno'),
(122, 'filipa.correia', 'pass123', 'Filipa Correia', 'aluno'),
(123, 'daniel.moreira', 'pass123', 'Daniel Moreira', 'aluno'),
(124, 'teresa.silva', 'pass123', 'Teresa Silva', 'aluno'),
(150, 'alice.ferreira', 'pass123', 'Alice Ferreira', 'aluno'),
(151, 'bernardo.costa', 'pass123', 'Bernardo Costa', 'aluno'),
(152, 'clara.santos', 'pass123', 'Clara Santos', 'aluno'),
(153, 'david.silva', 'pass123', 'David Silva', 'aluno'),
(154, 'eva.rodrigues', 'pass123', 'Eva Rodrigues', 'aluno'),
(155, 'francisco.alves', 'pass123', 'Francisco Alves', 'aluno'),
(156, 'gabriela.martins', 'pass123', 'Gabriela Martins', 'aluno'),
(157, 'henrique.sousa', 'pass123', 'Henrique Sousa', 'aluno'),
(158, 'iris.gomes', 'pass123', 'Iris Gomes', 'aluno'),
(159, 'jorge.fernandes', 'pass123', 'Jorge Fernandes', 'aluno'),
(160, 'katia.pereira', 'pass123', 'Kátia Pereira', 'aluno'),
(161, 'leonardo.dias', 'pass123', 'Leonardo Dias', 'aluno'),
(162, 'marta.lopes', 'pass123', 'Marta Lopes', 'aluno'),
(163, 'nuno.carvalho', 'pass123', 'Nuno Carvalho', 'aluno'),
(164, 'olivia.pinto', 'pass123', 'Olívia Pinto', 'aluno'),
(165, 'paulo.ribeiro', 'pass123', 'Paulo Ribeiro', 'aluno'),
(166, 'quiteria.nunes', 'pass123', 'Quitéria Nunes', 'aluno'),
(167, 'rodrigo.moreira', 'pass123', 'Rodrigo Moreira', 'aluno'),
(168, 'silvia.correia', 'pass123', 'Sílvia Correia', 'aluno'),
(169, 'tomas.araujo', 'pass123', 'Tomás Araújo', 'aluno'),
(170, 'ursula.vieira', 'pass123', 'Úrsula Vieira', 'aluno'),
(171, 'victor.monteiro', 'pass123', 'Victor Monteiro', 'aluno'),
(172, 'walter.mendes', 'pass123', 'Walter Mendes', 'aluno'),
(173, 'ximena.castro', 'pass123', 'Ximena Castro', 'aluno'),
(174, 'yara.barros', 'pass123', 'Yara Barros', 'aluno'),
(175, 'zacarias.teixeira', 'pass123', 'Zacarias Teixeira', 'aluno'),
(176, 'adriana.campos', 'pass123', 'Adriana Campos', 'aluno'),
(177, 'bruno.machado', 'pass123', 'Bruno Machado', 'aluno'),
(178, 'carla.ramos', 'pass123', 'Carla Ramos', 'aluno'),
(179, 'daniel.azevedo', 'pass123', 'Daniel Azevedo', 'aluno'),
(180, 'elisa.cunha', 'pass123', 'Elisa Cunha', 'aluno'),
(181, 'fabio.moura', 'pass123', 'Fábio Moura', 'aluno'),
(182, 'gloria.baptista', 'pass123', 'Glória Baptista', 'aluno'),
(183, 'hugo.freitas', 'pass123', 'Hugo Freitas', 'aluno'),
(184, 'ines.jesus', 'pass123', 'Inês Jesus', 'aluno'),
(185, 'jaime.coelho', 'pass123', 'Jaime Coelho', 'aluno'),
(186, 'lara.guerreiro', 'pass123', 'Lara Guerreiro', 'aluno'),
(187, 'marco.rocha', 'pass123', 'Marco Rocha', 'aluno'),
(188, 'natalia.cardoso', 'pass123', 'Natália Cardoso', 'aluno'),
(189, 'oscar.melo', 'pass123', 'Óscar Melo', 'aluno'),
(190, 'paula.fonseca', 'pass123', 'Paula Fonseca', 'aluno'),
(191, 'quim.abreu', 'pass123', 'Quim Abreu', 'aluno'),
(192, 'raquel.branco', 'pass123', 'Raquel Branco', 'aluno'),
(193, 'sergio.tavares', 'pass123', 'Sérgio Tavares', 'aluno'),
(194, 'tatiana.henriques', 'pass123', 'Tatiana Henriques', 'aluno'),
(195, 'ulisses.amaral', 'pass123', 'Ulisses Amaral', 'aluno'),
(196, 'vera.xavier', 'pass123', 'Vera Xavier', 'aluno'),
(197, 'william.duarte', 'pass123', 'William Duarte', 'aluno'),
(198, 'yasmin.miranda', 'pass123', 'Yasmin Miranda', 'aluno'),
(199, 'zulmira.varela', 'pass123', 'Zulmira Varela', 'aluno');

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `v1_detalhes_formadores`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `v1_detalhes_formadores` (
`Nome_Formador` varchar(150)
,`Total_Estagios` bigint(21)
,`Media_Formador` double(19,2)
,`Media_Global_Todos` double(19,2)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `v2_media_empresa_curso`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `v2_media_empresa_curso` (
`Nome_Empresa` varchar(150)
,`Nome_Curso` varchar(150)
,`Media_Notas` double(19,2)
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `zona`
--

CREATE TABLE `zona` (
  `zona_id` int(11) NOT NULL,
  `designacao` varchar(150) DEFAULT NULL,
  `localidade` varchar(150) DEFAULT NULL,
  `mapa` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `zona`
--

INSERT INTO `zona` (`zona_id`, `designacao`, `localidade`, `mapa`) VALUES
(1, 'Centro', 'Lisboa', NULL),
(2, 'Norte', 'Porto', NULL),
(3, 'Centro', 'Coimbra', NULL),
(4, 'Sul', 'Faro', NULL),
(5, 'Minho', 'Braga', NULL),
(6, 'Alentejo', 'Évora', NULL),
(7, 'Beira', 'Aveiro', NULL);

-- --------------------------------------------------------

--
-- Estrutura para vista `v1_detalhes_formadores`
--
DROP TABLE IF EXISTS `v1_detalhes_formadores`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v1_detalhes_formadores`  AS SELECT `u`.`nome` AS `Nome_Formador`, count(`e`.`aluno_id`) AS `Total_Estagios`, round(avg(`e`.`nota_final`),2) AS `Media_Formador`, (select round(avg(`estagio`.`nota_final`),2) from `estagio`) AS `Media_Global_Todos` FROM ((`formador` `f` join `utilizador` `u` on(`f`.`utilizador_id` = `u`.`utilizador_id`)) join `estagio` `e` on(`f`.`utilizador_id` = `e`.`formador_id`)) GROUP BY `u`.`nome` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `v2_media_empresa_curso`
--
DROP TABLE IF EXISTS `v2_media_empresa_curso`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v2_media_empresa_curso`  AS SELECT `emp`.`firma` AS `Nome_Empresa`, `c`.`designacao` AS `Nome_Curso`, round(avg(`e`.`nota_final`),2) AS `Media_Notas` FROM (((((`estagio` `e` join `estabelecimento` `est` on(`e`.`estabelecimento_empresa_id` = `est`.`empresa_id` and `e`.`estabelecimento_id` = `est`.`estabelecimento_id`)) join `empresa` `emp` on(`est`.`empresa_id` = `emp`.`empresa_id`)) join `aluno` `a` on(`e`.`aluno_id` = `a`.`utilizador_id`)) join `turma` `t` on(`a`.`turma_id` = `t`.`turma_id`)) join `curso` `c` on(`t`.`curso_id` = `c`.`curso_id`)) GROUP BY `emp`.`firma`, `c`.`designacao` ;

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `administrativo`
--
ALTER TABLE `administrativo`
  ADD PRIMARY KEY (`utilizador_id`);

--
-- Índices para tabela `aluno`
--
ALTER TABLE `aluno`
  ADD PRIMARY KEY (`utilizador_id`),
  ADD KEY `fk_aluno_turma` (`turma_id`);

--
-- Índices para tabela `classificacao`
--
ALTER TABLE `classificacao`
  ADD PRIMARY KEY (`classificacao_id`),
  ADD KEY `fk_classificacao_recebe_estabelecimento` (`estabelecimento_empresa_id`,`estabelecimento_id`);

--
-- Índices para tabela `comercializa`
--
ALTER TABLE `comercializa`
  ADD PRIMARY KEY (`estabelecimento_empresa_id`,`estabelecimento_id`,`produto_id`),
  ADD KEY `fk_produto_comercializa_estabelecimento` (`produto_id`);

--
-- Índices para tabela `curso`
--
ALTER TABLE `curso`
  ADD PRIMARY KEY (`curso_id`);

--
-- Índices para tabela `disponibilidade`
--
ALTER TABLE `disponibilidade`
  ADD PRIMARY KEY (`disponibilidade_id`),
  ADD KEY `fk_disponibilidade_oferece_empresa` (`empresa_id`);

--
-- Índices para tabela `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`empresa_id`),
  ADD KEY `fk_empresa_lidera_responsavel` (`responsavel_id`);

--
-- Índices para tabela `estabelecimento`
--
ALTER TABLE `estabelecimento`
  ADD PRIMARY KEY (`empresa_id`,`estabelecimento_id`),
  ADD KEY `fk_estabelecimento_pertence_responsavel` (`responsavel_id`),
  ADD KEY `fk_estabelecimento_situado_zona` (`zona_id`);

--
-- Índices para tabela `estagio`
--
ALTER TABLE `estagio`
  ADD PRIMARY KEY (`estabelecimento_empresa_id`,`estabelecimento_id`,`aluno_id`),
  ADD KEY `fk_aluno_estagio_estabelecimento` (`aluno_id`),
  ADD KEY `fk_estagio_acompanhado_formador` (`formador_id`);

--
-- Índices para tabela `formador`
--
ALTER TABLE `formador`
  ADD PRIMARY KEY (`utilizador_id`);

--
-- Índices para tabela `produto`
--
ALTER TABLE `produto`
  ADD PRIMARY KEY (`produto_id`);

--
-- Índices para tabela `ramo_atividade`
--
ALTER TABLE `ramo_atividade`
  ADD PRIMARY KEY (`ramo_atividade_id`);

--
-- Índices para tabela `responsavel`
--
ALTER TABLE `responsavel`
  ADD PRIMARY KEY (`responsavel_id`);

--
-- Índices para tabela `serve`
--
ALTER TABLE `serve`
  ADD PRIMARY KEY (`transporte_id`,`zona_id`),
  ADD KEY `fk_zona_serve_transporte` (`zona_id`);

--
-- Índices para tabela `servido`
--
ALTER TABLE `servido`
  ADD PRIMARY KEY (`estabelecimento_empresa_id`,`estabelecimento_id`,`transporte_id`),
  ADD KEY `fk_transporte_servido_estabelecimento` (`transporte_id`);

--
-- Índices para tabela `trabalha`
--
ALTER TABLE `trabalha`
  ADD PRIMARY KEY (`empresa_id`,`ramo_atividade_id`),
  ADD KEY `fk_ramo_atividade_trabalha_empresa` (`ramo_atividade_id`);

--
-- Índices para tabela `transporte`
--
ALTER TABLE `transporte`
  ADD PRIMARY KEY (`transporte_id`);

--
-- Índices para tabela `turma`
--
ALTER TABLE `turma`
  ADD PRIMARY KEY (`turma_id`),
  ADD KEY `fk_turma_tem_curso` (`curso_id`);

--
-- Índices para tabela `utilizador`
--
ALTER TABLE `utilizador`
  ADD PRIMARY KEY (`utilizador_id`);

--
-- Índices para tabela `zona`
--
ALTER TABLE `zona`
  ADD PRIMARY KEY (`zona_id`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `utilizador`
--
ALTER TABLE `utilizador`
  MODIFY `utilizador_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=202;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `administrativo`
--
ALTER TABLE `administrativo`
  ADD CONSTRAINT `fk_administrativo_utilizador` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizador` (`utilizador_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `aluno`
--
ALTER TABLE `aluno`
  ADD CONSTRAINT `fk_aluno_turma` FOREIGN KEY (`turma_id`) REFERENCES `turma` (`turma_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_aluno_utilizador` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizador` (`utilizador_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `classificacao`
--
ALTER TABLE `classificacao`
  ADD CONSTRAINT `fk_classificacao_recebe_estabelecimento` FOREIGN KEY (`estabelecimento_empresa_id`,`estabelecimento_id`) REFERENCES `estabelecimento` (`empresa_id`, `estabelecimento_id`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `comercializa`
--
ALTER TABLE `comercializa`
  ADD CONSTRAINT `fk_estabelecimento_comercializa_produto` FOREIGN KEY (`estabelecimento_empresa_id`,`estabelecimento_id`) REFERENCES `estabelecimento` (`empresa_id`, `estabelecimento_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_produto_comercializa_estabelecimento` FOREIGN KEY (`produto_id`) REFERENCES `produto` (`produto_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `disponibilidade`
--
ALTER TABLE `disponibilidade`
  ADD CONSTRAINT `fk_disponibilidade_oferece_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`empresa_id`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `empresa`
--
ALTER TABLE `empresa`
  ADD CONSTRAINT `fk_empresa_lidera_responsavel` FOREIGN KEY (`responsavel_id`) REFERENCES `responsavel` (`responsavel_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Limitadores para a tabela `estabelecimento`
--
ALTER TABLE `estabelecimento`
  ADD CONSTRAINT `fk_estabelecimento_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`empresa_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_estabelecimento_pertence_responsavel` FOREIGN KEY (`responsavel_id`) REFERENCES `responsavel` (`responsavel_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_estabelecimento_situado_zona` FOREIGN KEY (`zona_id`) REFERENCES `zona` (`zona_id`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `estagio`
--
ALTER TABLE `estagio`
  ADD CONSTRAINT `fk_aluno_estagio_estabelecimento` FOREIGN KEY (`aluno_id`) REFERENCES `aluno` (`utilizador_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_estabelecimento_estagio_aluno` FOREIGN KEY (`estabelecimento_empresa_id`,`estabelecimento_id`) REFERENCES `estabelecimento` (`empresa_id`, `estabelecimento_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_estagio_acompanhado_formador` FOREIGN KEY (`formador_id`) REFERENCES `formador` (`utilizador_id`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `formador`
--
ALTER TABLE `formador`
  ADD CONSTRAINT `fk_formador_utilizador` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizador` (`utilizador_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `serve`
--
ALTER TABLE `serve`
  ADD CONSTRAINT `fk_transporte_serve_zona` FOREIGN KEY (`transporte_id`) REFERENCES `transporte` (`transporte_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_zona_serve_transporte` FOREIGN KEY (`zona_id`) REFERENCES `zona` (`zona_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `servido`
--
ALTER TABLE `servido`
  ADD CONSTRAINT `fk_estabelecimento_servido_transporte` FOREIGN KEY (`estabelecimento_empresa_id`,`estabelecimento_id`) REFERENCES `estabelecimento` (`empresa_id`, `estabelecimento_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transporte_servido_estabelecimento` FOREIGN KEY (`transporte_id`) REFERENCES `transporte` (`transporte_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `trabalha`
--
ALTER TABLE `trabalha`
  ADD CONSTRAINT `fk_empresa_trabalha_ramo_atividade` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`empresa_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ramo_atividade_trabalha_empresa` FOREIGN KEY (`ramo_atividade_id`) REFERENCES `ramo_atividade` (`ramo_atividade_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `turma`
--
ALTER TABLE `turma`
  ADD CONSTRAINT `fk_turma_tem_curso` FOREIGN KEY (`curso_id`) REFERENCES `curso` (`curso_id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
