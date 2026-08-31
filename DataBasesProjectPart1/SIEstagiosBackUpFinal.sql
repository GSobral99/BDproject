-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 02-Nov-2025 às 22:58
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
-- Banco de dados: `teste57`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_atualizar_media_estabelecimento` (IN `p_estabelecimento_id` INT, IN `p_ano_letivo_id` INT)   BEGIN
    DECLARE v_media DECIMAL(10, 2);
    DECLARE v_avaliacao_id INT;

    SELECT AVG(e.nota_dada_pelo_aluno) INTO v_media
    FROM estagio e
    JOIN alunos a ON e.alunos_ID = a.utilizador_ID 
    JOIN turma t ON a.turma_turma_ID = t.turma_ID
    WHERE e.estabelecimentos_estabelecimentos_ID = p_estabelecimento_id
      AND t.ano_letivo_ano_letivo_ID = p_ano_letivo_id
      AND e.nota_dada_pelo_aluno IS NOT NULL;

    SELECT avaliacao_anual_estabelecimento_ID INTO v_avaliacao_id
    FROM avaliacao_anual_estabelecimento
    WHERE estabelecimentos_estabelecimentos_ID = p_estabelecimento_id
      AND ano_letivo_ano_letivo_ID = p_ano_letivo_id
    LIMIT 1;

    IF v_media IS NOT NULL THEN
        IF v_avaliacao_id IS NOT NULL THEN
            UPDATE avaliacao_anual_estabelecimento
            SET media_avaliacoes = v_media
            WHERE avaliacao_anual_estabelecimento_ID = v_avaliacao_id;
        ELSE
            SELECT IFNULL(MAX(avaliacao_anual_estabelecimento_ID), 0) + 1 
            INTO v_avaliacao_id 
            FROM avaliacao_anual_estabelecimento;
            
            INSERT INTO avaliacao_anual_estabelecimento (
                estabelecimentos_estabelecimentos_ID,
                ano_letivo_ano_letivo_ID,
                avaliacao_anual_estabelecimento_ID,
                media_avaliacoes
            ) VALUES (
                p_estabelecimento_id,
                p_ano_letivo_id,
                v_avaliacao_id,
                v_media
            );
        END IF;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `administrativo`
--

CREATE TABLE `administrativo` (
  `utilizador_ID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `administrativo`
--

INSERT INTO `administrativo` (`utilizador_ID`) VALUES
(1),
(2),
(3),
(373);

--
-- Acionadores `administrativo`
--
DELIMITER $$
CREATE TRIGGER `trg_check_disjoint_admin_before_insert` BEFORE INSERT ON `administrativo` FOR EACH ROW BEGIN
    DECLARE v_is_aluno INT;
    DECLARE v_is_formador INT;
    SELECT COUNT(*) INTO v_is_aluno FROM `alunos` WHERE `utilizador_ID` = NEW.utilizador_ID;
    SELECT COUNT(*) INTO v_is_formador FROM `formador` WHERE `utilizador_ID` = NEW.utilizador_ID;
    IF (v_is_aluno > 0 OR v_is_formador > 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Este utilizador já existe como aluno ou formador.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `alunos`
--

CREATE TABLE `alunos` (
  `utilizador_ID` int(11) NOT NULL,
  `administrativo_ID` int(11) NOT NULL,
  `turma_turma_ID` int(11) NOT NULL,
  `numero` int(11) NOT NULL,
  `observacoes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `alunos`
--

INSERT INTO `alunos` (`utilizador_ID`, `administrativo_ID`, `turma_turma_ID`, `numero`, `observacoes`) VALUES
(4, 1, 1, 1004, NULL),
(5, 1, 1, 1005, NULL),
(6, 1, 1, 1006, NULL),
(7, 1, 1, 1007, NULL),
(8, 1, 1, 1008, NULL),
(9, 1, 1, 1009, NULL),
(10, 1, 1, 1010, NULL),
(11, 1, 1, 1011, NULL),
(12, 1, 1, 1012, NULL),
(13, 1, 1, 1013, NULL),
(14, 1, 1, 1014, NULL),
(15, 1, 1, 1015, NULL),
(16, 1, 1, 1016, NULL),
(17, 1, 1, 1017, NULL),
(18, 1, 1, 1018, NULL),
(19, 1, 1, 1019, NULL),
(20, 1, 1, 1020, NULL),
(21, 1, 1, 1021, NULL),
(22, 1, 1, 1022, NULL),
(23, 1, 1, 1023, NULL),
(24, 1, 2, 1024, NULL),
(25, 1, 2, 1025, NULL),
(26, 1, 2, 1026, NULL),
(27, 1, 2, 1027, NULL),
(28, 1, 2, 1028, NULL),
(29, 1, 2, 1029, NULL),
(30, 1, 2, 1030, NULL),
(31, 1, 2, 1031, NULL),
(32, 1, 2, 1032, NULL),
(33, 1, 2, 1033, NULL),
(34, 1, 2, 1034, NULL),
(35, 1, 2, 1035, NULL),
(36, 1, 2, 1036, NULL),
(37, 1, 2, 1037, NULL),
(38, 1, 2, 1038, NULL),
(39, 1, 2, 1039, NULL),
(40, 1, 2, 1040, NULL),
(41, 1, 2, 1041, NULL),
(42, 1, 2, 1042, NULL),
(43, 1, 2, 1043, NULL),
(44, 1, 2, 1044, NULL),
(45, 1, 2, 1045, NULL),
(46, 1, 2, 1046, NULL),
(47, 1, 2, 1047, NULL),
(48, 1, 2, 1048, NULL),
(49, 1, 3, 1049, NULL),
(50, 1, 3, 1050, NULL),
(51, 1, 3, 1051, NULL),
(52, 1, 3, 1052, NULL),
(53, 1, 3, 1053, NULL),
(54, 1, 3, 1054, NULL),
(55, 1, 3, 1055, NULL),
(56, 1, 3, 1056, NULL),
(57, 1, 3, 1057, NULL),
(58, 1, 3, 1058, NULL),
(59, 1, 3, 1059, NULL),
(60, 1, 3, 1060, NULL),
(61, 1, 3, 1061, NULL),
(62, 1, 3, 1062, NULL),
(63, 1, 3, 1063, NULL),
(64, 1, 3, 1064, NULL),
(65, 1, 3, 1065, NULL),
(66, 1, 3, 1066, NULL),
(67, 1, 4, 1067, NULL),
(68, 1, 4, 1068, NULL),
(69, 1, 4, 1069, NULL),
(70, 1, 4, 1070, NULL),
(71, 1, 4, 1071, NULL),
(72, 1, 4, 1072, NULL),
(73, 1, 4, 1073, NULL),
(74, 1, 4, 1074, NULL),
(75, 1, 4, 1075, NULL),
(76, 1, 4, 1076, NULL),
(77, 1, 4, 1077, NULL),
(78, 1, 4, 1078, NULL),
(79, 1, 4, 1079, NULL),
(80, 1, 4, 1080, NULL),
(81, 1, 4, 1081, NULL),
(82, 1, 5, 1082, NULL),
(83, 1, 5, 1083, NULL),
(84, 1, 5, 1084, NULL),
(85, 1, 5, 1085, NULL),
(86, 1, 5, 1086, NULL),
(87, 1, 5, 1087, NULL),
(88, 1, 5, 1088, NULL),
(89, 1, 5, 1089, NULL),
(90, 1, 5, 1090, NULL),
(91, 1, 5, 1091, NULL),
(92, 1, 5, 1092, NULL),
(93, 1, 5, 1093, NULL),
(94, 1, 5, 1094, NULL),
(95, 1, 5, 1095, NULL),
(96, 1, 5, 1096, NULL),
(97, 1, 5, 1097, NULL),
(98, 1, 5, 1098, NULL),
(99, 1, 5, 1099, NULL),
(100, 1, 5, 1100, NULL),
(101, 1, 5, 1101, NULL),
(102, 1, 5, 1102, NULL),
(103, 1, 5, 1103, NULL),
(104, 1, 6, 1104, NULL),
(105, 1, 6, 1105, NULL),
(106, 1, 6, 1106, NULL),
(107, 1, 6, 1107, NULL),
(108, 1, 6, 1108, NULL),
(109, 1, 6, 1109, NULL),
(110, 1, 6, 1110, NULL),
(111, 1, 6, 1111, NULL),
(112, 1, 6, 1112, NULL),
(113, 1, 6, 1113, NULL),
(114, 1, 6, 1114, NULL),
(115, 1, 6, 1115, NULL),
(116, 1, 6, 1116, NULL),
(117, 1, 6, 1117, NULL),
(118, 1, 6, 1118, NULL),
(119, 1, 6, 1119, NULL),
(120, 1, 6, 1120, NULL),
(121, 1, 6, 1121, NULL),
(122, 1, 6, 1122, NULL),
(123, 1, 6, 1123, NULL),
(124, 1, 6, 1124, NULL),
(125, 1, 6, 1125, NULL),
(126, 1, 6, 1126, NULL),
(132, 1, 7, 1132, NULL),
(133, 1, 7, 1133, NULL),
(134, 1, 7, 1134, NULL),
(135, 1, 7, 1135, NULL),
(136, 1, 7, 1136, NULL),
(137, 1, 7, 1137, NULL),
(138, 1, 7, 1138, NULL),
(139, 1, 7, 1139, NULL),
(140, 1, 7, 1140, NULL),
(144, 1, 7, 1144, NULL),
(145, 1, 7, 1145, NULL),
(146, 1, 7, 1146, NULL),
(148, 1, 7, 1148, NULL),
(149, 1, 7, 1149, NULL),
(150, 1, 7, 1150, NULL),
(151, 1, 7, 1151, NULL),
(152, 1, 7, 1152, NULL),
(153, 1, 7, 1153, NULL),
(155, 1, 7, 1155, NULL),
(157, 1, 7, 1157, NULL),
(158, 1, 7, 1158, NULL),
(159, 1, 7, 1159, NULL),
(160, 1, 8, 1160, NULL),
(161, 1, 8, 1161, NULL),
(162, 1, 8, 1162, NULL),
(163, 1, 8, 1163, NULL),
(164, 1, 8, 1164, NULL),
(165, 1, 8, 1165, NULL),
(166, 1, 8, 1166, NULL),
(167, 1, 8, 1167, NULL),
(168, 1, 8, 1168, NULL),
(169, 1, 8, 1169, NULL),
(170, 1, 8, 1170, NULL),
(171, 1, 8, 1171, NULL),
(172, 1, 8, 1172, NULL),
(173, 1, 8, 1173, NULL),
(174, 1, 8, 1174, NULL),
(175, 1, 8, 1175, NULL),
(176, 1, 8, 1176, NULL),
(177, 1, 8, 1177, NULL),
(178, 1, 8, 1178, NULL),
(179, 1, 8, 1179, NULL),
(180, 1, 8, 1180, NULL),
(181, 1, 8, 1181, NULL),
(182, 1, 8, 1182, NULL),
(183, 1, 8, 1183, NULL),
(184, 1, 8, 1184, NULL),
(185, 1, 8, 1185, NULL),
(186, 1, 9, 1186, NULL),
(187, 1, 9, 1187, NULL),
(188, 1, 9, 1188, NULL),
(189, 1, 9, 1189, NULL),
(190, 1, 9, 1190, NULL),
(191, 1, 9, 1191, NULL),
(192, 1, 9, 1192, NULL),
(193, 1, 9, 1193, NULL),
(194, 1, 9, 1194, NULL),
(195, 1, 9, 1195, NULL),
(196, 1, 9, 1196, NULL),
(197, 1, 9, 1197, NULL),
(198, 1, 9, 1198, NULL),
(199, 1, 9, 1199, NULL),
(200, 1, 9, 1200, NULL),
(201, 1, 9, 1201, NULL),
(202, 1, 9, 1202, NULL),
(203, 1, 9, 1203, NULL),
(204, 1, 9, 1204, NULL),
(205, 1, 9, 1205, NULL),
(206, 1, 9, 1206, NULL),
(207, 1, 9, 1207, NULL),
(208, 1, 9, 1208, NULL),
(209, 1, 9, 1209, NULL),
(210, 1, 10, 1210, NULL),
(211, 1, 10, 1211, NULL),
(212, 1, 10, 1212, NULL),
(213, 1, 10, 1213, NULL),
(214, 1, 10, 1214, NULL),
(215, 1, 10, 1215, NULL),
(216, 1, 10, 1216, NULL),
(217, 1, 10, 1217, NULL),
(218, 1, 10, 1218, NULL),
(219, 1, 10, 1219, NULL),
(220, 1, 10, 1220, NULL),
(221, 1, 10, 1221, NULL),
(222, 1, 10, 1222, NULL),
(223, 1, 10, 1223, NULL),
(224, 1, 10, 1224, NULL),
(225, 1, 10, 1225, NULL),
(226, 1, 10, 1226, NULL),
(227, 1, 10, 1227, NULL),
(228, 1, 10, 1228, NULL),
(229, 1, 11, 1229, NULL),
(230, 1, 11, 1230, NULL),
(231, 1, 11, 1231, NULL),
(232, 1, 11, 1232, NULL),
(233, 1, 11, 1233, NULL),
(234, 1, 11, 1234, NULL),
(235, 1, 11, 1235, NULL),
(236, 1, 11, 1236, NULL),
(237, 1, 11, 1237, NULL),
(238, 1, 11, 1238, NULL),
(239, 1, 11, 1239, NULL),
(240, 1, 11, 1240, NULL),
(241, 1, 11, 1241, NULL),
(242, 1, 11, 1242, NULL),
(243, 1, 12, 1243, NULL),
(244, 1, 12, 1244, NULL),
(245, 1, 12, 1245, NULL),
(246, 1, 12, 1246, NULL),
(247, 1, 12, 1247, NULL),
(248, 1, 12, 1248, NULL),
(249, 1, 12, 1249, NULL),
(250, 1, 12, 1250, NULL),
(251, 1, 12, 1251, NULL),
(252, 1, 12, 1252, NULL),
(253, 1, 13, 1253, NULL),
(254, 1, 13, 1254, NULL),
(256, 1, 13, 1256, NULL),
(257, 1, 13, 1257, NULL),
(258, 1, 13, 1258, NULL),
(259, 1, 13, 1259, NULL),
(260, 1, 13, 1260, NULL),
(261, 1, 13, 1261, NULL),
(262, 1, 13, 1262, NULL),
(263, 1, 13, 1263, NULL),
(264, 1, 13, 1264, NULL),
(265, 1, 13, 1265, NULL),
(266, 1, 13, 1266, NULL),
(267, 1, 13, 1267, NULL),
(268, 1, 13, 1268, NULL),
(269, 1, 13, 1269, NULL),
(270, 1, 13, 1270, NULL),
(271, 1, 13, 1271, NULL),
(272, 1, 13, 1272, NULL),
(273, 1, 13, 1273, NULL),
(274, 1, 13, 1274, NULL),
(275, 1, 14, 1275, NULL),
(276, 1, 14, 1276, NULL),
(277, 1, 14, 1277, NULL),
(278, 1, 14, 1278, NULL),
(279, 1, 14, 1279, NULL),
(280, 1, 14, 1280, NULL),
(281, 1, 14, 1281, NULL),
(282, 1, 14, 1282, NULL),
(283, 1, 14, 1283, NULL),
(284, 1, 14, 1284, NULL),
(285, 1, 14, 1285, NULL),
(286, 1, 14, 1286, NULL),
(287, 1, 14, 1287, NULL),
(288, 1, 14, 1288, NULL),
(289, 1, 14, 1289, NULL),
(290, 1, 14, 1290, NULL),
(291, 1, 14, 1291, NULL),
(292, 1, 14, 1292, NULL),
(293, 1, 14, 1293, NULL),
(297, 1, 14, 1297, NULL),
(298, 1, 14, 1298, NULL),
(299, 1, 15, 1299, NULL),
(300, 1, 15, 1300, NULL),
(301, 1, 15, 1301, NULL),
(302, 1, 15, 1302, NULL),
(303, 1, 15, 1303, NULL),
(304, 1, 15, 1304, NULL),
(305, 1, 15, 1305, NULL),
(306, 1, 15, 1306, NULL),
(307, 1, 15, 1307, NULL),
(308, 1, 15, 1308, NULL),
(311, 1, 15, 1311, NULL),
(313, 1, 15, 1313, NULL),
(314, 1, 15, 1314, NULL),
(315, 1, 15, 1315, NULL),
(316, 1, 15, 1316, NULL),
(317, 1, 15, 1317, NULL),
(318, 1, 15, 1318, NULL),
(319, 1, 15, 1319, NULL),
(320, 1, 15, 1320, NULL),
(321, 1, 15, 1321, NULL),
(322, 1, 15, 1322, NULL),
(323, 1, 15, 1323, NULL),
(324, 1, 15, 1324, NULL),
(325, 1, 16, 1325, NULL),
(326, 1, 16, 1326, NULL),
(327, 1, 16, 1327, NULL),
(328, 1, 16, 1328, NULL),
(329, 1, 16, 1329, NULL),
(330, 1, 16, 1330, NULL),
(331, 1, 16, 1331, NULL),
(332, 1, 16, 1332, NULL),
(333, 1, 16, 1333, NULL),
(334, 1, 16, 1334, NULL),
(335, 1, 16, 1335, NULL),
(336, 1, 16, 1336, NULL),
(337, 1, 17, 1337, NULL),
(338, 1, 17, 1338, NULL),
(339, 1, 17, 1339, NULL),
(340, 1, 17, 1340, NULL),
(341, 1, 17, 1341, NULL),
(342, 1, 17, 1342, NULL),
(343, 1, 17, 1343, NULL),
(344, 1, 17, 1344, NULL),
(345, 1, 17, 1345, NULL),
(346, 1, 17, 1346, NULL),
(347, 1, 17, 1347, NULL),
(349, 1, 17, 1349, NULL),
(350, 1, 17, 1350, NULL),
(351, 1, 17, 1351, NULL),
(352, 1, 17, 1352, NULL),
(353, 1, 18, 1353, NULL),
(354, 1, 18, 1354, NULL),
(355, 1, 18, 1355, NULL),
(356, 1, 18, 1356, NULL),
(357, 1, 18, 1357, NULL),
(358, 1, 18, 1358, NULL),
(359, 1, 18, 1359, NULL),
(360, 1, 18, 1360, NULL),
(361, 1, 18, 1361, NULL),
(362, 1, 18, 1362, NULL),
(363, 1, 18, 1363, NULL),
(364, 1, 18, 1364, NULL),
(365, 1, 18, 1365, NULL),
(366, 1, 18, 1366, NULL),
(367, 1, 18, 1367, NULL),
(368, 1, 18, 1368, NULL),
(369, 1, 18, 1369, NULL),
(370, 1, 18, 1370, NULL),
(371, 1, 18, 1371, NULL),
(372, 1, 18, 1372, NULL);

--
-- Acionadores `alunos`
--
DELIMITER $$
CREATE TRIGGER `trg_check_disjoint_aluno_before_insert` BEFORE INSERT ON `alunos` FOR EACH ROW BEGIN
    DECLARE v_is_formador INT;
    DECLARE v_is_admin INT;
    SELECT COUNT(*) INTO v_is_formador FROM `formador` WHERE `utilizador_ID` = NEW.utilizador_ID;
    SELECT COUNT(*) INTO v_is_admin FROM `administrativo` WHERE `utilizador_ID` = NEW.utilizador_ID;
    IF (v_is_formador > 0 OR v_is_admin > 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Este utilizador já existe como formador ou administrativo.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_check_turma_max_before_insert` BEFORE INSERT ON `alunos` FOR EACH ROW BEGIN
  DECLARE v_count INT;
  SELECT COUNT(*) INTO v_count FROM `alunos` WHERE `turma_turma_ID` = NEW.turma_turma_ID;
  IF v_count >= 28 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A turma já atingiu o limite máximo de 28 alunos.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_check_turma_min_before_delete` BEFORE DELETE ON `alunos` FOR EACH ROW BEGIN
  DECLARE v_count INT;
  SELECT COUNT(*) INTO v_count FROM `alunos` WHERE `turma_turma_ID` = OLD.turma_turma_ID;
  IF v_count <= 10 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A turma não pode ficar com menos de 10 alunos.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_check_turma_update_before_update` BEFORE UPDATE ON `alunos` FOR EACH ROW BEGIN
    DECLARE v_count_new INT;
    DECLARE v_count_old INT;
    IF OLD.turma_turma_ID != NEW.turma_turma_ID THEN
        SELECT COUNT(*) INTO v_count_new FROM `alunos` WHERE `turma_turma_ID` = NEW.turma_turma_ID;
        IF v_count_new >= 28 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A turma de destino está cheia (28 alunos).';
        END IF;
        SELECT COUNT(*) INTO v_count_old FROM `alunos` WHERE `turma_turma_ID` = OLD.turma_turma_ID;
        IF v_count_old <= 10 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A turma de origem não pode ficar com menos de 10 alunos.';
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `ano_letivo`
--

CREATE TABLE `ano_letivo` (
  `ano_letivo_ID` int(11) NOT NULL,
  `ano` varchar(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `ano_letivo`
--

INSERT INTO `ano_letivo` (`ano_letivo_ID`, `ano`) VALUES
(1, '2024/2025'),
(2, '2025/2026');

-- --------------------------------------------------------

--
-- Estrutura da tabela `avaliacao_anual_estabelecimento`
--

CREATE TABLE `avaliacao_anual_estabelecimento` (
  `estabelecimentos_estabelecimentos_ID` int(11) NOT NULL,
  `ano_letivo_ano_letivo_ID` int(11) NOT NULL,
  `avaliacao_anual_estabelecimento_ID` int(11) NOT NULL,
  `media_avaliacoes` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `avaliacao_anual_estabelecimento`
--

INSERT INTO `avaliacao_anual_estabelecimento` (`estabelecimentos_estabelecimentos_ID`, `ano_letivo_ano_letivo_ID`, `avaliacao_anual_estabelecimento_ID`, `media_avaliacoes`) VALUES
(1, 1, 1, 4),
(2, 1, 2, 5),
(1, 2, 3, 4),
(2, 2, 4, 5),
(12, 1, 5, 5),
(13, 1, 6, 4),
(14, 1, 7, 4),
(15, 1, 8, 5),
(16, 1, 9, 4),
(17, 1, 10, 4),
(12, 2, 11, 5),
(13, 2, 12, 3),
(14, 2, 13, 4),
(15, 2, 14, 5),
(21, 1, 15, 4),
(22, 1, 16, 5),
(23, 1, 17, 3),
(22, 2, 18, 5),
(23, 2, 19, 4);

-- --------------------------------------------------------

--
-- Estrutura da tabela `curso`
--

CREATE TABLE `curso` (
  `curso_ID` int(11) NOT NULL,
  `designacao` text NOT NULL,
  `codigo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `curso`
--

INSERT INTO `curso` (`curso_ID`, `designacao`, `codigo`) VALUES
(1, 'Desporto', 123),
(2, 'Gestão de E-Sports', 1412),
(3, 'Produção Audiovisual\r\n\r\n', 9614);

-- --------------------------------------------------------

--
-- Estrutura da tabela `empresas`
--

CREATE TABLE `empresas` (
  `administrativo_ID` int(11) NOT NULL,
  `empresas_ID` int(11) NOT NULL,
  `firma` text NOT NULL,
  `contribuinte` int(11) NOT NULL,
  `morada` text NOT NULL,
  `localidade` text NOT NULL,
  `codigo_postal` varchar(8) NOT NULL,
  `telefone` int(11) NOT NULL,
  `email` text NOT NULL,
  `website` text DEFAULT NULL,
  `observacoes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `empresas`
--

INSERT INTO `empresas` (`administrativo_ID`, `empresas_ID`, `firma`, `contribuinte`, `morada`, `localidade`, `codigo_postal`, `telefone`, `email`, `website`, `observacoes`) VALUES
(373, 1, 'Grupo Desportivo Fabril', 500131066, 'R. Grupo Desportivo Fabril do Barreiro, Lavradio', 'Barreiro', '2835-328', 212026859, 'gdfgeral@gmail.com', 'www.gdfabril.com', 'Empresa gestora de complexo desportivo. Oferece várias modalidades (ex: Basquetebol, fitness, futebol). Excelente potencial para estagiários do curso de Desporto, com foco em instrução ou gestão de instalações.\r\nFoi quem criou a Lenda Viva\r\n'),
(1, 2, 'Sport Lisboa e Benfica - SAD', 504882066, 'Av. Eusébio da Silva Ferreira', 'Lisboa', '1500-313', 217219500, 'geral@slbenfica.pt', 'www.slbenfica.pt', 'Clube desportivo de grande dimensão com foco em futebol profissional e formação. Várias modalidades. Potencial para estágios em gestão desportiva, marketing ou performance.'),
(2, 3, 'Futebol Clube do Porto - SAD', 504505500, 'Estádio do Dragão, Via FC Porto', 'Porto', '4350-415', 225070500, 'geral@fcporto.pt', 'www.fcporto.pt', 'Clube histórico com forte aposta em múltiplas modalidades de alta competição. Oportunidades de estágio em diversas áreas, incluindo scouting e análise de dados.'),
(2, 4, 'Sporting Clube de Portugal - SAD', 504620218, 'Estádio José Alvalade, Rua Professor Fernando da Fonseca', 'Lisboa', '1600-616', 217516000, 'geral@sporting.pt', 'www.sporting.pt', 'Famoso pela academia de formação em futebol. Oferece várias modalidades olímpicas. Bom para estágios focados em treino desportivo e formação jovem.'),
(3, 5, 'Fitness Hut - Gestão de Health Clubs', 510008770, 'Rua Joshua Benoliel 6', 'Lisboa', '1250-136', 211555520, 'info@fitnesshut.pt', 'www.fitnesshut.pt', 'Cadeia de ginásios \"premium low-cost\" com forte presença nacional. Ideal para estagiários de Desporto focados em fitness, aulas de grupo e gestão de health clubs.'),
(1, 6, 'Sporting Clube de Braga - SAD', 505004149, 'Estádio Municipal de Braga, Parque Norte', 'Braga', '4700-207', 253306610, 'geral@scbraga.pt', 'www.scbraga.pt', 'Clube em crescimento com instalações modernas e foco em futebol e e-sports. Potencial para estágios em performance desportiva e novas mídias.'),
(1, 7, 'FTW - For The Win Esports', 514223344, 'Rua da Inovação 123, Taguspark', 'Porto Salvo', '2740-122', 210123456, 'geral@ftw.pt', 'www.ftw.pt', 'Organização de E-Sports com equipas profissionais em vários jogos. Potencial para estágios em gestão de equipas, marketing digital e organização de eventos.'),
(2, 8, 'RTP Arena', 500201104, 'Av. Marechal Gomes da Costa 37', 'Lisboa', '1849-030', 217947001, 'arena@rtp.pt', 'www.rtp.pt/play/arena', 'Plataforma de E-Sports e gaming da RTP. Foco em transmissão e produção de conteúdo. Ideal para estágios em produção audiovisual de E-Sports e jornalismo de gaming.'),
(3, 9, 'Plural Entertainment Portugal', 504622172, 'Rua Mário Castelhano 40, Queluz de Baixo', 'Queluz', '2734-502', 214347000, 'geral@pluralportugal.pt', 'www.pluralportugal.pt', 'Produtora líder em ficção (novelas, séries). Oportunidades em todas as fases de produção, desde captação, som, edição e pós-produção.'),
(1, 10, 'SP Televisão', 508291150, 'Rua Manuel Pinto de Azevedo 818', 'Porto', '4100-320', 226199400, 'geral@sptelevisao.pt', 'www.sptelevisao.pt', 'Grande produtora de ficção e programas de entretenimento para vários canais. Estágios em produção, realização, e escrita de guião.');

-- --------------------------------------------------------

--
-- Estrutura da tabela `empresas_ramo`
--

CREATE TABLE `empresas_ramo` (
  `empresas_empresas_ID_` int(11) NOT NULL,
  `ramo_ramo_ID_` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `empresas_ramo`
--

INSERT INTO `empresas_ramo` (`empresas_empresas_ID_`, `ramo_ramo_ID_`) VALUES
(1, 1),
(1, 2),
(1, 5),
(2, 1),
(2, 2),
(2, 3),
(2, 5),
(3, 1),
(3, 2),
(3, 3),
(4, 1),
(4, 2),
(4, 3),
(5, 1),
(5, 4),
(6, 1),
(6, 2),
(6, 6),
(7, 5),
(7, 6),
(8, 6),
(8, 7),
(9, 8),
(9, 9),
(10, 8),
(10, 9);

-- --------------------------------------------------------

--
-- Estrutura da tabela `estabelecimentos`
--

CREATE TABLE `estabelecimentos` (
  `administrativo_ID` int(11) DEFAULT NULL,
  `empresas_empresas_ID` int(11) NOT NULL,
  `zona_zona_ID` int(11) NOT NULL,
  `estabelecimentos_ID` int(11) NOT NULL,
  `nome` text NOT NULL,
  `tipo_estabelecimento` text NOT NULL,
  `morada` text NOT NULL,
  `localidade` text NOT NULL,
  `codigo_postal` varchar(8) NOT NULL,
  `telefone` int(11) NOT NULL,
  `email` text NOT NULL,
  `foto` text DEFAULT NULL,
  `horario` text DEFAULT NULL,
  `data_fundacao` date NOT NULL,
  `ja_aceitou_estagiarios` bit(1) DEFAULT NULL,
  `observacoes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `estabelecimentos`
--

INSERT INTO `estabelecimentos` (`administrativo_ID`, `empresas_empresas_ID`, `zona_zona_ID`, `estabelecimentos_ID`, `nome`, `tipo_estabelecimento`, `morada`, `localidade`, `codigo_postal`, `telefone`, `email`, `foto`, `horario`, `data_fundacao`, `ja_aceitou_estagiarios`, `observacoes`) VALUES
(373, 1, 1, 1, 'Complexo Desportivo GDF', 'Complexo Desportivo', 'R. Grupo Desportivo Fabril do Barreiro', 'Lavradio', '2835-328', 212026059, 'gdfgeral@gmail.com', 'uploads/estabelecimentos/gdf.jpg', 'Seg-Sex: 08:00-22:00, Sáb: 09:00-20:00', '1937-01-01', b'1', 'Estádio e pavilhões desportivos.'),
(373, 1, 1, 2, 'Loja do Adepto - GDF', 'Loja', 'R. Grupo Desportivo Fabril do Barreiro', 'Lavradio', '2835-328', 212026060, 'loja@gdfabril.pt', 'uploads/estabelecimentos/loja_gdf.jpg', 'Seg-Sex: 10:00-18:00, Sáb: 10:00-13:00', '2005-05-10', b'1', 'Merchandising oficial do Grupo Desportivo Fabril.'),
(1, 2, 2, 3, 'Estádio do Sport Lisboa e Benfica', 'Estádio Desportivo', 'Av. Eusébio da Silva Ferreira', 'Lisboa', '1500-313', 217219501, 'estadio@slbenfica.pt', 'uploads/estabelecimentos/estadio_luz.jpg', '10:00-18:00 (Museu e Visitas)', '2003-10-25', b'1', 'Visitas ao estádio e museu Cosme Damião.'),
(1, 2, 2, 4, 'Benfica Campus', 'Academia Desportiva', 'Av. República da Gâmbia', 'Seixal', '2840-558', 212255000, 'campus@slbenfica.pt', 'uploads/estabelecimentos/benfica_campus.jpg', '09:00-18:00 (Serviços)', '2006-09-22', b'1', 'Centro de estágio e formação de jovens.'),
(2, 3, 3, 5, 'Estádio do Dragão', 'Estádio Desportivo', 'Via FC Porto', 'Porto', '4350-415', 225070501, 'estadio@fcporto.pt', 'uploads/estabelecimentos/dragao.jpg', '10:00-19:00 (Museu e Visitas)', '2003-11-16', b'1', 'Complexo com museu e loja do clube.'),
(2, 3, 3, 6, 'Dragão Arena', 'Pavilhão Desportivo', 'Via FC Porto', 'Porto', '4350-415', 225070502, 'arena@fcporto.pt', 'uploads/estabelecimentos/dragao_arena.jpg', 'Depende dos eventos', '2009-04-23', b'1', 'Pavilhão para modalidades como Andebol e Basquetebol.'),
(2, 4, 2, 7, 'Estádio José Alvalade', 'Estádio Desportivo', 'Rua Professor Fernando da Fonseca', 'Lisboa', '1600-616', 217516001, 'estadio@sporting.pt', 'uploads/estabelecimentos/alvalade.jpg', '10:00-18:00 (Visitas e Loja)', '2003-08-06', b'1', 'Complexo inclui loja verde e museu.'),
(3, 5, 2, 8, 'Fitness Hut - Picoas', 'Ginásio', 'Rua Tomás Ribeiro, 65', 'Lisboa', '1050-227', 211555521, 'info.picoas@fitnesshut.pt', 'uploads/estabelecimentos/fhut_picoas.jpg', 'Seg-Sex: 07:00-23:00, Sáb: 09:00-20:00, Dom: 09:00-14:00', '2012-01-10', b'1', 'Ginásio com aulas de grupo, PT e zona de crossfit.'),
(3, 5, 3, 9, 'Fitness Hut - Trindade', 'Ginásio', 'Rua de Camões, 200', 'Porto', '4000-145', 221555522, 'info.trindade@fitnesshut.pt', 'uploads/estabelecimentos/fhut_trindade.jpg', 'Seg-Sex: 07:00-23:00, Sáb: 09:00-20:00, Dom: 09:00-14:00', '2016-05-15', b'1', 'Ginásio no centro do Porto, perto do metro.'),
(1, 6, 4, 10, 'Estádio Municipal de Braga', 'Estádio Desportivo', 'Parque Norte, Dume', 'Braga', '4700-207', 253306611, 'estadio@scbraga.pt', 'uploads/estabelecimentos/municipal_braga.jpg', '10:00-18:00 (Visitas)', '2003-12-30', b'1', 'Conhecido como A Pedreira. Sede dos jogos do SC Braga.'),
(2, 4, 5, 11, 'Academia Sporting - Alcochete', 'Academia Desportiva', 'Unidade N. 10 488, Herdade da Torre D\'Abreu', 'Alcochete', '2890-150', 217516002, 'academia@sporting.pt', 'uploads/estabelecimentos/academia_alcochete.jpg', '09:00-18:00 (Serviços)', '2002-06-21', b'1', 'Foco na formação de atletas. Potencial para estágios em treino.'),
(1, 7, 2, 12, 'FTW Sede (Taguspark)', 'Escritório', 'Rua da Inovação 123, Taguspark', 'Porto Salvo', '2740-122', 210123457, 'sede@ftw.pt', NULL, 'Seg-Sex: 09:00-18:00', '2019-01-10', b'1', 'Escritório principal, foco em gestão e marketing.'),
(1, 7, 2, 13, 'FTW Arena (Lisboa)', 'Arena E-Sports', 'Rua C, Edifício Gaming', 'Lisboa', '1500-100', 210123458, 'arena@ftw.pt', NULL, 'Seg-Dom: 14:00-02:00', '2020-05-15', b'1', 'Arena de treino e competição para equipas.'),
(1, 7, 3, 14, 'FTW Loja (Porto)', 'Loja', 'Rua Sá da Bandeira, 500', 'Porto', '4000-427', 220123456, 'loja.porto@ftw.pt', NULL, 'Seg-Sáb: 10:00-20:00', '2021-02-01', b'1', 'Loja de merchandising e periféricos de gaming.'),
(2, 8, 2, 15, 'RTP Arena Estúdios', 'Estúdio', 'Av. Marechal Gomes da Costa 37', 'Lisboa', '1849-030', 217947002, 'estudios.arena@rtp.pt', NULL, 'Seg-Sex: 10:00-19:00', '2018-03-05', b'1', 'Estúdios de transmissão e produção de conteúdo online.'),
(2, 8, 2, 16, 'RTP Arena Redação', 'Escritório', 'Av. Marechal Gomes da Costa 37', 'Lisboa', '1849-030', 217947003, 'redacao.arena@rtp.pt', NULL, 'Seg-Sex: 09:00-18:00', '2018-03-05', b'0', 'Redação de jornalismo de E-Sports e planeamento.'),
(2, 8, 3, 17, 'RTP Arena Hub (Porto)', 'Escritório', 'Rua de Gondarém, 1024', 'Porto', '4150-375', 220123457, 'hub.porto.arena@rtp.pt', NULL, 'Seg-Sex: 09:00-18:00', '2022-01-20', b'1', 'Pequeno escritório para equipas de reportagem no norte.'),
(1, 10, 3, 21, 'SP Televisão Sede (Porto)', 'Escritório', 'Rua Manuel Pinto de Azevedo 818', 'Porto', '4100-320', 226199401, 'sede.porto@sptelevisao.pt', NULL, 'Seg-Sex: 09:00-18:00', '2007-11-01', b'1', 'Sede principal e serviços centrais.'),
(1, 10, 3, 22, 'SP Estúdios (Porto)', 'Estúdio', 'Rua Manuel Pinto de Azevedo 820', 'Porto', '4100-320', 226199402, 'estudios.porto@sptelevisao.pt', NULL, 'Seg-Sex: 08:00-20:00', '2010-04-12', b'1', 'Estúdios de gravação de programas e ficção no Porto.'),
(1, 10, 2, 23, 'SP Televisão (Lisboa)', 'Escritório', 'Av. da Liberdade, 150', 'Lisboa', '1250-146', 210123459, 'esc.lisboa@sptelevisao.pt', NULL, 'Seg-Sex: 09:00-18:00', '2009-02-01', b'1', 'Escritório de apoio à produção em Lisboa.');

-- --------------------------------------------------------

--
-- Estrutura da tabela `estabelecimentos_produtos`
--

CREATE TABLE `estabelecimentos_produtos` (
  `estabelecimentos_estabelecimentos_ID_` int(11) NOT NULL,
  `produtos_produtos_ID_` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `estabelecimentos_produtos`
--

INSERT INTO `estabelecimentos_produtos` (`estabelecimentos_estabelecimentos_ID_`, `produtos_produtos_ID_`) VALUES
(2, 6),
(2, 10),
(3, 7),
(3, 11),
(5, 8),
(7, 9),
(8, 12),
(8, 13),
(8, 14),
(8, 15),
(9, 12),
(9, 13),
(9, 14),
(9, 15),
(13, 5),
(14, 2),
(14, 3),
(15, 1),
(15, 4),
(22, 16),
(22, 17),
(22, 18);

-- --------------------------------------------------------

--
-- Estrutura da tabela `estabelecimentos_transportes`
--

CREATE TABLE `estabelecimentos_transportes` (
  `estabelecimentos_estabelecimentos_ID_` int(11) NOT NULL,
  `transporte_transporte_ID_` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `estabelecimentos_transportes`
--

INSERT INTO `estabelecimentos_transportes` (`estabelecimentos_estabelecimentos_ID_`, `transporte_transporte_ID_`) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 1),
(2, 2),
(2, 3),
(3, 4),
(3, 7),
(3, 9),
(4, 16),
(4, 17),
(5, 10),
(5, 12),
(6, 10),
(6, 12),
(7, 5),
(7, 8),
(8, 6),
(8, 8),
(9, 11),
(9, 13),
(10, 14),
(10, 15),
(11, 16),
(11, 17),
(12, 6),
(12, 9),
(13, 6),
(13, 8),
(14, 11),
(14, 13),
(15, 5),
(15, 8),
(16, 5),
(16, 8),
(17, 11),
(17, 13),
(21, 11),
(21, 13),
(22, 11),
(22, 13),
(23, 6),
(23, 8);

-- --------------------------------------------------------

--
-- Estrutura da tabela `estagio`
--

CREATE TABLE `estagio` (
  `alunos_ID` int(11) NOT NULL,
  `formador_ID` int(11) NOT NULL,
  `estabelecimentos_estabelecimentos_ID` int(11) NOT NULL,
  `estagio_ID` int(11) NOT NULL,
  `data_inicio` datetime DEFAULT NULL,
  `data_fim` datetime DEFAULT NULL,
  `nota_dada_empresa` int(11) DEFAULT NULL,
  `nota_dada_escola` int(11) DEFAULT NULL,
  `nota_relatorio` int(11) DEFAULT NULL,
  `nota_procura` int(11) DEFAULT NULL,
  `nota_final` int(11) DEFAULT NULL,
  `nota_dada_pelo_aluno` int(11) DEFAULT NULL,
  `responsavel_id_responsavel` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `estagio`
--

INSERT INTO `estagio` (`alunos_ID`, `formador_ID`, `estabelecimentos_estabelecimentos_ID`, `estagio_ID`, `data_inicio`, `data_fim`, `nota_dada_empresa`, `nota_dada_escola`, `nota_relatorio`, `nota_procura`, `nota_final`, `nota_dada_pelo_aluno`, `responsavel_id_responsavel`) VALUES
(4, 374, 1, 51, '2025-03-03 09:00:00', '2025-06-20 18:00:00', 18, 17, 16, 19, 18, 5, 1),
(5, 375, 1, 52, '2025-03-03 09:00:00', '2025-06-20 18:00:00', 17, 18, 18, 17, 18, 4, 1),
(6, 374, 2, 53, '2025-03-04 09:00:00', '2025-06-23 18:00:00', 16, 15, 17, NULL, 16, 4, 14),
(24, 375, 1, 54, '2025-03-04 09:00:00', '2025-06-23 18:00:00', 19, 18, 18, 20, 19, 5, 1),
(25, 374, 1, 55, '2025-03-05 09:00:00', '2025-06-24 18:00:00', 14, 16, 15, 15, 15, 3, 1),
(49, 375, 2, 56, '2025-03-05 09:00:00', '2025-06-24 18:00:00', 18, 17, 17, NULL, 17, 5, 14),
(50, 374, 1, 57, '2025-03-06 09:00:00', '2025-06-25 18:00:00', 16, 17, 16, 18, 17, 4, 1),
(67, 375, 1, 58, '2025-03-06 09:00:00', '2025-06-25 18:00:00', 17, 16, 18, 17, 17, 4, 1),
(82, 374, 2, 59, '2025-03-07 09:00:00', '2025-06-26 18:00:00', 19, 19, 18, NULL, 19, 5, 14),
(104, 375, 1, 60, '2025-03-07 09:00:00', '2025-06-26 18:00:00', 15, 15, 16, 16, 16, 3, 1),
(132, 376, 12, 61, '2025-03-10 09:00:00', '2025-06-27 18:00:00', 19, 18, 18, 20, 19, 5, 2),
(133, 377, 13, 62, '2025-03-10 09:00:00', '2025-06-27 18:00:00', 17, 17, 16, 18, 17, 4, 4),
(160, 376, 14, 63, '2025-03-11 09:00:00', '2025-06-30 18:00:00', 16, 18, 17, NULL, 17, 4, 6),
(161, 377, 15, 64, '2025-03-11 09:00:00', '2025-06-30 18:00:00', 18, 17, 18, 19, 18, 5, 8),
(186, 376, 16, 65, '2025-03-12 09:00:00', '2025-07-01 18:00:00', 17, 16, 17, 18, 17, 4, 10),
(187, 377, 17, 66, '2025-03-12 09:00:00', '2025-07-01 18:00:00', 16, 17, 15, NULL, 16, 3, 12),
(210, 376, 12, 67, '2025-03-13 09:00:00', '2025-07-02 18:00:00', 20, 19, 19, 20, 20, 5, 3),
(211, 377, 13, 68, '2025-03-13 09:00:00', '2025-07-02 18:00:00', 15, 16, 17, 17, 16, 3, 5),
(229, 376, 14, 69, '2025-03-14 09:00:00', '2025-07-03 18:00:00', 18, 18, 17, NULL, 18, 4, 7),
(243, 377, 15, 70, '2025-03-14 09:00:00', '2025-07-03 18:00:00', 17, 18, 18, 19, 18, 5, 9),
(253, 378, 21, 71, '2025-03-17 09:00:00', '2025-07-04 18:00:00', 18, 17, 18, 18, 18, 5, 27),
(254, 379, 22, 72, '2025-03-17 09:00:00', '2025-07-04 18:00:00', 19, 19, 17, 20, 19, 5, 28),
(256, 380, 23, 73, '2025-03-18 09:00:00', '2025-07-07 18:00:00', 16, 15, 16, NULL, 16, 3, 29),
(275, 378, 15, 74, '2025-03-18 09:00:00', '2025-07-07 18:00:00', 17, 18, 17, 17, 17, 4, 20),
(276, 379, 16, 75, '2025-03-19 09:00:00', '2025-07-08 18:00:00', 18, 17, 19, 18, 18, 4, 26),
(299, 380, 17, 76, '2025-03-19 09:00:00', '2025-07-08 18:00:00', 19, 18, 18, NULL, 18, 5, 24),
(300, 378, 21, 77, '2025-03-20 09:00:00', '2025-07-09 18:00:00', 15, 16, 15, 17, 16, 3, 27),
(325, 379, 22, 78, '2025-03-20 09:00:00', '2025-07-09 18:00:00', 18, 18, 19, 19, 19, 5, 28),
(326, 380, 23, 79, '2025-03-21 09:00:00', '2025-07-10 18:00:00', 17, 16, 17, NULL, 17, 4, 29),
(353, 378, 15, 80, '2025-03-21 09:00:00', '2025-07-10 18:00:00', 19, 18, 18, 20, 19, 5, 21);

--
-- Acionadores `estagio`
--
DELIMITER $$
CREATE TRIGGER `trg_atualizar_media_estab_after_delete` AFTER DELETE ON `estagio` FOR EACH ROW BEGIN
    DECLARE v_ano_letivo_id INT;
    
    IF OLD.nota_dada_pelo_aluno IS NOT NULL THEN
        SELECT t.ano_letivo_ano_letivo_ID INTO v_ano_letivo_id
        FROM `alunos` a
        JOIN `turma` t ON a.turma_turma_ID = t.turma_ID
        WHERE a.utilizador_ID = OLD.alunos_ID;  
        
        IF v_ano_letivo_id IS NOT NULL THEN
            CALL sp_atualizar_media_estabelecimento(
                OLD.estabelecimentos_estabelecimentos_ID,
                v_ano_letivo_id
            );
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_atualizar_media_estab_after_insert` AFTER INSERT ON `estagio` FOR EACH ROW BEGIN
    DECLARE v_ano_letivo_id INT;
    
    IF NEW.nota_dada_pelo_aluno IS NOT NULL THEN
        SELECT t.ano_letivo_ano_letivo_ID INTO v_ano_letivo_id
        FROM `alunos` a
        JOIN `turma` t ON a.turma_turma_ID = t.turma_ID
        WHERE a.utilizador_ID = NEW.alunos_ID;  
        
        IF v_ano_letivo_id IS NOT NULL THEN
            CALL sp_atualizar_media_estabelecimento(
                NEW.estabelecimentos_estabelecimentos_ID,
                v_ano_letivo_id
            );
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_atualizar_media_estab_after_update` AFTER UPDATE ON `estagio` FOR EACH ROW BEGIN
    DECLARE v_ano_letivo_id INT;
    DECLARE v_ano_letivo_id_old INT;
    
    IF (NEW.nota_dada_pelo_aluno != OLD.nota_dada_pelo_aluno OR 
        NEW.alunos_ID != OLD.alunos_ID OR
        NEW.estabelecimentos_estabelecimentos_ID != OLD.estabelecimentos_estabelecimentos_ID) THEN  

        SELECT t.ano_letivo_ano_letivo_ID INTO v_ano_letivo_id
        FROM `alunos` a
        JOIN `turma` t ON a.turma_turma_ID = t.turma_ID
        WHERE a.utilizador_ID = NEW.alunos_ID; 
        
        IF v_ano_letivo_id IS NOT NULL THEN
            CALL sp_atualizar_media_estabelecimento(
                NEW.estabelecimentos_estabelecimentos_ID,
                v_ano_letivo_id
            );
        END IF;

        IF (NEW.alunos_ID != OLD.alunos_ID OR 
            NEW.estabelecimentos_estabelecimentos_ID != OLD.estabelecimentos_estabelecimentos_ID) THEN  
            
            SELECT t.ano_letivo_ano_letivo_ID INTO v_ano_letivo_id_old
            FROM `alunos` a
            JOIN `turma` t ON a.turma_turma_ID = t.turma_ID
            WHERE a.utilizador_ID = OLD.alunos_ID;  
            
            IF v_ano_letivo_id_old IS NOT NULL THEN
                CALL sp_atualizar_media_estabelecimento(
                    OLD.estabelecimentos_estabelecimentos_ID,
                    v_ano_letivo_id_old
                );
            END IF;
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_calcular_nota_final_before_insert` BEFORE INSERT ON `estagio` FOR EACH ROW BEGIN
    DECLARE v_soma DECIMAL(10, 2);
    DECLARE v_contador INT;
    SET v_soma = 0;
    SET v_contador = 0;
    IF NEW.nota_dada_empresa IS NOT NULL THEN
        SET v_soma = v_soma + NEW.nota_dada_empresa;
        SET v_contador = v_contador + 1;
    END IF;
    IF NEW.nota_dada_escola IS NOT NULL THEN
        SET v_soma = v_soma + NEW.nota_dada_escola;
        SET v_contador = v_contador + 1;
    END IF;
    IF NEW.nota_relatorio IS NOT NULL THEN
        SET v_soma = v_soma + NEW.nota_relatorio;
        SET v_contador = v_contador + 1;
    END IF;
    IF NEW.nota_procura IS NOT NULL THEN
        SET v_soma = v_soma + NEW.nota_procura;
        SET v_contador = v_contador + 1;
    END IF;
    IF v_contador > 0 THEN
        SET NEW.nota_final = v_soma / v_contador;
    ELSE
        SET NEW.nota_final = NULL;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_calcular_nota_final_before_update` BEFORE UPDATE ON `estagio` FOR EACH ROW BEGIN
    DECLARE v_soma DECIMAL(10, 2);
    DECLARE v_contador INT;
    SET v_soma = 0;
    SET v_contador = 0;
    IF NEW.nota_dada_empresa IS NOT NULL THEN
        SET v_soma = v_soma + NEW.nota_dada_empresa;
        SET v_contador = v_contador + 1;
    END IF;
    IF NEW.nota_dada_escola IS NOT NULL THEN
        SET v_soma = v_soma + NEW.nota_dada_escola;
        SET v_contador = v_contador + 1;
    END IF;
    IF NEW.nota_relatorio IS NOT NULL THEN
        SET v_soma = v_soma + NEW.nota_relatorio;
        SET v_contador = v_contador + 1;
    END IF;
    IF NEW.nota_procura IS NOT NULL THEN
        SET v_soma = v_soma + NEW.nota_procura;
        SET v_contador = v_contador + 1;
    END IF;
    IF v_contador > 0 THEN
        SET NEW.nota_final = v_soma / v_contador;
    ELSE
        SET NEW.nota_final = NULL;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_check_notas_before_insert` BEFORE INSERT ON `estagio` FOR EACH ROW BEGIN
  IF NEW.nota_dada_empresa IS NOT NULL AND (NEW.nota_dada_empresa < 0 OR NEW.nota_dada_empresa > 20) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A nota_dada_empresa está fora do intervalo (0 a 20).';
  END IF;
  IF NEW.nota_dada_escola IS NOT NULL AND (NEW.nota_dada_escola < 0 OR NEW.nota_dada_escola > 20) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A nota_dada_escola está fora do intervalo (0 a 20).';
  END IF;
  IF NEW.nota_relatorio IS NOT NULL AND (NEW.nota_relatorio < 0 OR NEW.nota_relatorio > 20) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A nota_relatorio está fora do intervalo (0 a 20).';
  END IF;
  IF NEW.nota_procura IS NOT NULL AND (NEW.nota_procura < 0 OR NEW.nota_procura > 20) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A nota_procura está fora do intervalo (0 a 20).';
  END IF;
  IF NEW.nota_dada_pelo_aluno IS NOT NULL AND (NEW.nota_dada_pelo_aluno < 1 OR NEW.nota_dada_pelo_aluno > 5) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A nota_dada_pelo_aluno está fora do intervalo (1 a 5).';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_check_notas_before_update` BEFORE UPDATE ON `estagio` FOR EACH ROW BEGIN
  IF NEW.nota_dada_empresa IS NOT NULL AND (NEW.nota_dada_empresa < 0 OR NEW.nota_dada_empresa > 20) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A nota_dada_empresa está fora do intervalo (0 a 20).';
  END IF;
  IF NEW.nota_dada_escola IS NOT NULL AND (NEW.nota_dada_escola < 0 OR NEW.nota_dada_escola > 20) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A nota_dada_escola está fora do intervalo (0 a 20).';
  END IF;
  IF NEW.nota_relatorio IS NOT NULL AND (NEW.nota_relatorio < 0 OR NEW.nota_relatorio > 20) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A nota_relatorio está fora do intervalo (0 a 20).';
  END IF;
  IF NEW.nota_procura IS NOT NULL AND (NEW.nota_procura < 0 OR NEW.nota_procura > 20) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A nota_procura está fora do intervalo (0 a 20).';
  END IF;
  IF NEW.nota_dada_pelo_aluno IS NOT NULL AND (NEW.nota_dada_pelo_aluno < 1 OR NEW.nota_dada_pelo_aluno > 5) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A nota_dada_pelo_aluno está fora do intervalo (1 a 5).';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_check_responsavel_estabelecimento_before_insert` BEFORE INSERT ON `estagio` FOR EACH ROW BEGIN
    DECLARE v_resp_estab_id INT;

    SELECT `estabelecimentos_estabelecimentos_ID`
    INTO v_resp_estab_id
    FROM `responsavel`
    WHERE `id_responsavel` = NEW.responsavel_id_responsavel;

    IF (v_resp_estab_id != NEW.estabelecimentos_estabelecimentos_ID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: O responsável selecionado não pertence ao estabelecimento de estágio especificado.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_check_responsavel_estabelecimento_before_update` BEFORE UPDATE ON `estagio` FOR EACH ROW BEGIN
    DECLARE v_resp_estab_id INT;

    SELECT `estabelecimentos_estabelecimentos_ID`
    INTO v_resp_estab_id
    FROM `responsavel`
    WHERE `id_responsavel` = NEW.responsavel_id_responsavel;

    IF (v_resp_estab_id != NEW.estabelecimentos_estabelecimentos_ID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: O responsável selecionado não pertence ao estabelecimento de estágio especificado.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `formador`
--

CREATE TABLE `formador` (
  `utilizador_ID` int(11) NOT NULL,
  `numero` int(11) NOT NULL,
  `disciplina` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `formador`
--

INSERT INTO `formador` (`utilizador_ID`, `numero`, `disciplina`) VALUES
(374, 501, 'Técnicas de Treino Desportivo'),
(375, 502, 'Gestão de Equipas Desportivas'),
(376, 503, 'Análise Tática E-Sports'),
(377, 504, 'Produção e Streaming de Eventos'),
(378, 505, 'Captação e Edição de Som'),
(379, 506, 'Realização Audiovisual'),
(380, 507, 'Produção Cinematográfica');

--
-- Acionadores `formador`
--
DELIMITER $$
CREATE TRIGGER `trg_check_disjoint_formador_before_insert` BEFORE INSERT ON `formador` FOR EACH ROW BEGIN
    DECLARE v_is_aluno INT;
    DECLARE v_is_admin INT;
    SELECT COUNT(*) INTO v_is_aluno FROM `alunos` WHERE `utilizador_ID` = NEW.utilizador_ID;
    SELECT COUNT(*) INTO v_is_admin FROM `administrativo` WHERE `utilizador_ID` = NEW.utilizador_ID;
    IF (v_is_aluno > 0 OR v_is_admin > 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Este utilizador já existe como aluno ou administrativo.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `produtos`
--

CREATE TABLE `produtos` (
  `produtos_ID` int(11) NOT NULL,
  `nome` text NOT NULL,
  `marca` text NOT NULL,
  `tipo_produto` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `produtos`
--

INSERT INTO `produtos` (`produtos_ID`, `nome`, `marca`, `tipo_produto`) VALUES
(1, 'Camisola Principal 25/26 - GDFabril', 'GD Fabril', 'Equipamento Desportivo'),
(2, 'Camisola Principal 25/26 - SLBenfica', 'SL Benfica', 'Equipamento Desportivo'),
(3, 'Camisola Principal 25/26 - FCPorto', 'FC Porto', 'Equipamento Desportivo'),
(4, 'Camisola Principal 25/26 - SportingCP', 'Sporting CP', 'Equipamento Desportivo'),
(5, 'Camisola Principal 25/26 - SCBraga', 'SC Braga', 'Equipamento Desportivo'),
(6, 'Cachecol - GDFabril', 'GD Fabril', 'Merchandising'),
(7, 'Cachecol - SLBenfica', 'SL Benfica', 'Merchandising'),
(8, 'Porta-chaves Estádio - FCPorto', 'FC Porto', 'Merchandising'),
(9, 'Mascote Jubas (Peluche)', 'Sporting CP', 'Merchandising'),
(10, 'Miniatura Estádio Braga', 'SC Braga', 'Merchandising'),
(11, 'Whey Protein 1kg', 'Prozis', 'Suplemento'),
(12, 'Barra Energética', 'MyProtein', 'Suplemento'),
(13, 'Bebida Isotónica Laranja', 'Powerade', 'Bebida Desportiva'),
(14, 'Água Vitalis 50cl', 'Vitalis', 'Bebida'),
(15, 'Plano de Treino Personalizado', 'Fitness Hut', 'Serviço de PT'),
(16, 'Acompanhamento Nutricional', 'Fitness Hut', 'Serviço de Nutrição'),
(17, 'Cadeado de Cacifo', 'Fitness Hut', 'Acessório'),
(18, 'Bilhete Evento - RTP Arena CS Major', 'RTP Arena', 'Bilheteira'),
(19, 'Camisola Pro-Player - FTW', 'FTW', 'Equipamento eSports'),
(20, 'Mousepad Gamer - FTW Edition', 'FTW', 'Merchandising eSports'),
(21, 'Hoodie - RTP Arena', 'RTP Arena', 'Merchandising eSports'),
(22, 'Bootcamp de CS (Fim de Semana)', 'FTW Arena', 'Serviço de Treino'),
(23, 'Camisola Principal 25/26 - GDFabril', 'GD Fabril', 'Equipamento Desportivo'),
(24, 'Camisola Principal 25/26 - SLBenfica', 'SL Benfica', 'Equipamento Desportivo'),
(25, 'Camisola Principal 25/26 - FCPorto', 'FC Porto', 'Equipamento Desportivo'),
(26, 'Cachecol - SportingCP', 'Sporting CP', 'Merchandising'),
(27, 'Cachecol - GDFabril', 'GD Fabril', 'Merchandising'),
(28, 'Bola de Futebol (Tamanho 5) - SLBenfica', 'SL Benfica', 'Acessório'),
(29, 'Plano de Treino Personalizado', 'Fitness Hut', 'Serviço de PT'),
(30, 'Whey Protein 1kg', 'Prozis', 'Suplemento'),
(31, 'Inscrição Mensal (Plano Total)', 'Fitness Hut', 'Serviço de Ginásio'),
(32, 'Garrafa de Água Reutilizável', 'Fitness Hut', 'Acessório'),
(33, 'Serviço de Aluguer de Estúdio (Dia)', 'SP Televisão', 'Serviço de Produção'),
(34, 'Serviço de Pós-Produção (Hora)', 'SP Televisão', 'Serviço de Pós-Produção'),
(35, 'Serviço de Captação Áudio', 'SP Televisão', 'Serviço de Produção'),
(36, 'Labubu - Edição GDFabril', 'GD Fabril', 'Art Toy / Merchandising'),
(37, 'Labubu - Edição SLBenfica', 'SL Benfica', 'Art Toy / Merchandising'),
(38, 'Labubu - Edição FCPorto', 'FC Porto', 'Art Toy / Merchandising'),
(39, 'Labubu - Edição SportingCP', 'Sporting CP', 'Art Toy / Merchandising'),
(40, 'Labubu - Edição Fitness Hut', 'Fitness Hut', 'Art Toy / Merchandising'),
(41, 'Labubu - Edição SCBraga', 'SC Braga', 'Art Toy / Merchandising'),
(42, 'Labubu - Edição FTW', 'FTW', 'Art Toy / Merchandising eSports'),
(43, 'Labubu - Edição RTP Arena', 'RTP Arena', 'Art Toy / Merchandising eSports'),
(44, 'Labubu - Edição Plural (Câmera)', 'Plural', 'Art Toy / Merchandising'),
(45, 'Labubu - Edição SP Televisão (Claquete)', 'SP Televisão', 'Art Toy / Merchandising'),
(46, 'Cadeira Gaming Pro', 'FTW', 'Hardware'),
(47, 'Teclado Mecânico Pro', 'FTW', 'Hardware'),
(48, 'Headset Surround 7.1', 'RTP Arena', 'Hardware'),
(49, 'Sessão Coaching Online (LoL)', 'FTW', 'Serviço de Treino'),
(50, 'Subscrição Premium Arena+', 'RTP Arena', 'Serviço Digital'),
(51, 'Workshop de Escrita de Guião', 'Plural', 'Serviço de Formação'),
(52, 'Visita Guiada aos Estúdios (Plural)', 'Plural', 'Serviço de Bilheteira'),
(53, 'Aluguer Kit Câmara RED', 'SP Televisão', 'Serviço de Aluguer'),
(54, 'Serviço de Color Grading (Hora)', 'SP Televisão', 'Serviço de Pós-Produção'),
(55, 'T-shirt Novela \"Festa é Festa\"', 'Plural', 'Merchandising');

-- --------------------------------------------------------

--
-- Estrutura da tabela `ramo`
--

CREATE TABLE `ramo` (
  `administrativo_ID` int(11) NOT NULL,
  `ramo_ID` int(11) NOT NULL,
  `CAE` int(11) NOT NULL,
  `descricao` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `ramo`
--

INSERT INTO `ramo` (`administrativo_ID`, `ramo_ID`, `CAE`, `descricao`) VALUES
(1, 1, 93110, 'Gestão de instalações desportivas'),
(1, 2, 93120, 'Atividades de clubes desportivos'),
(1, 3, 93190, 'Outras atividades desportivas'),
(2, 4, 96040, 'Atividades de bem-estar físico'),
(2, 5, 47640, 'Comércio a retalho de artigos de desporto'),
(3, 6, 93299, 'Outras atividades de diversão e recreativas'),
(1, 7, 60200, 'Atividades de televisão'),
(2, 8, 59110, 'Produção de filmes, de vídeos e de programas de televisão'),
(3, 9, 59120, 'Atividades de pós-produção de filmes, vídeos e programas de televisão');

-- --------------------------------------------------------

--
-- Estrutura da tabela `responsavel`
--

CREATE TABLE `responsavel` (
  `id_responsavel` int(11) NOT NULL,
  `estabelecimentos_estabelecimentos_ID` int(11) NOT NULL,
  `nome` text NOT NULL,
  `titulo` text NOT NULL,
  `cargo` text NOT NULL,
  `telefone` int(11) NOT NULL,
  `email` text NOT NULL,
  `telemovel` int(11) NOT NULL,
  `observacoes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `responsavel`
--

INSERT INTO `responsavel` (`id_responsavel`, `estabelecimentos_estabelecimentos_ID`, `nome`, `titulo`, `cargo`, `telefone`, `email`, `telemovel`, `observacoes`) VALUES
(1, 1, 'João Silva', 'Sr.', 'Diretor Desportivo', 212026059, 'joao.silva@gdfabril.pt', 912345678, 'Contacto principal para estágios.'),
(2, 12, 'Ana Silva', 'Dra.', 'Gestora de RH', 210123460, 'ana.silva@ftw.pt', 911111111, 'Contacto principal para estágios de gestão.'),
(3, 12, 'Bruno Costa', 'Eng.', 'IT Manager', 210123461, 'bruno.costa@ftw.pt', 911111112, NULL),
(4, 13, 'Carlos Dias', 'Sr.', 'Gerente da Arena', 210123462, 'carlos.dias@ftw.pt', 911111113, 'Contacto para eventos e gestão de equipas.'),
(5, 13, 'Diana Moreira', 'Sra.', 'Técnica de Eventos', 210123463, 'diana.moreira@ftw.pt', 911111114, NULL),
(6, 14, 'Eduardo Faria', 'Sr.', 'Gerente de Loja (Porto)', 220123460, 'eduardo.faria@ftw.pt', 911111115, 'Contacto para estágios em retalho/marketing no Porto.'),
(7, 14, 'Filipa Guedes', 'Sra.', 'Sub-Gerente', 220123461, 'filipa.guedes@ftw.pt', 911111116, NULL),
(8, 15, 'Gonçalo Alves', 'Dr.', 'Coordenador de Produção', 217947010, 'goncalo.alves@rtp.pt', 922222221, 'Tutor para estágios em produção e streaming.'),
(9, 15, 'Helena Pires', 'Dra.', 'Produtora Sénior', 217947011, 'helena.pires@rtp.pt', 922222222, NULL),
(10, 16, 'Inês Tavares', 'Dra.', 'Editora Chefe', 217947012, 'ines.tavares@rtp.pt', 922222223, 'Tutor para estágios em jornalismo de E-Sports.'),
(11, 16, 'Jorge Matos', 'Dr.', 'Jornalista Sénior', 217947013, 'jorge.matos@rtp.pt', 922222224, NULL),
(12, 17, 'Luís Nogueira', 'Sr.', 'Gestor de Equipa (Porto)', 220123470, 'luis.nogueira@rtp.pt', 922222225, 'Contacto no Hub do Porto.'),
(13, 17, 'Maria Ramos', 'Dra.', 'Coordenadora Norte', 220123471, 'maria.ramos@rtp.pt', 922222226, NULL),
(14, 2, 'Maria Santos', 'Sra.', 'Gestora de Loja', 212026060, 'maria.santos@gdfabril.pt', 916789012, 'Responsável pela loja de merchandising. Contactar para estágios em gestão de retalho desportivo.'),
(20, 15, 'Gonçalo Alves', 'Dr.', 'Coordenador de Produção', 217947010, 'goncalo.alves@rtp.pt', 922222221, 'Tutor para estágios em produção e streaming.'),
(21, 15, 'Helena Pires', 'Dra.', 'Produtora Sénior', 217947011, 'helena.pires@rtp.pt', 922222222, NULL),
(22, 16, 'Inês Tavares', 'Dra.', 'Editora Chefe', 217947012, 'ines.tavares@rtp.pt', 922222223, 'Tutor para estágios em jornalismo de E-Sports.'),
(23, 16, 'Jorge Matos', 'Dr.', 'Jornalista Sénior', 217947013, 'jorge.matos@rtp.pt', 922222224, NULL),
(24, 17, 'Luís Nogueira', 'Sr.', 'Gestor de Equipa (Porto)', 220123470, 'luis.nogueira@rtp.pt', 922222225, 'Contacto no Hub do Porto.'),
(25, 17, 'Maria Ramos', 'Dra.', 'Coordenadora Norte', 220123471, 'maria.ramos@rtp.pt', 922222226, NULL),
(26, 16, 'Inês Ribeiro', 'Dra.', 'Editora-Chefe', 217947003, 'ines.ribeiro@rtp.pt', 917654321, 'Lidera equipa de jornalismo de gaming. Estágios em jornalismo digital e escrita de conteúdo.'),
(27, 21, 'Paulo Gomes', 'Sr.', 'Diretor de Produção', 226199401, 'paulo.gomes@sptelevisao.pt', 912098765, 'Supervisiona todas as produções. Estágios em coordenação e gestão de produção audiovisual.'),
(28, 22, 'Carla Nunes', 'Sra.', 'Realizadora', 226199402, 'carla.nunes@sptelevisao.pt', 913210987, 'Realizadora de ficção e programas. Estágios em realização, câmara e direção artística.'),
(29, 23, 'André Silva', 'Sr.', 'Coordenador de Escritório', 210123459, 'andre.silva@sptelevisao.pt', 914321098, 'Coordena escritório de Lisboa. Estágios em produção e pós-produção audiovisual.');

-- --------------------------------------------------------

--
-- Estrutura da tabela `transporte`
--

CREATE TABLE `transporte` (
  `transporte_ID` int(11) NOT NULL,
  `meio_transporte` text NOT NULL,
  `linha` text NOT NULL,
  `observacoes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `transporte`
--

INSERT INTO `transporte` (`transporte_ID`, `meio_transporte`, `linha`, `observacoes`) VALUES
(1, 'Autocarro', 'Carris Metropolitana 3720', 'Liga Barreiro ao Lavradio'),
(2, 'Autocarro', 'Carris Metropolitana 3721', 'Circula pela zona do GDF'),
(3, 'Comboio', 'Barreiro-Sado', ''),
(4, 'Metro', 'Linha Vermelha', 'Estação Colégio Militar/Luz para Benfica'),
(5, 'Metro', 'Linha Amarela', 'Estação Campo Grande'),
(6, 'Metro', 'Linha Verde', 'Estação Picoas/Marquês de Pombal'),
(7, 'Autocarro', 'Carris 701, 736, 768', 'Várias linhas para zona da Luz'),
(8, 'Autocarro', 'Carris 1, 44, 83', 'Centro de Lisboa'),
(9, 'Comboio', 'Linha de Sintra (CP)', 'Estação Campolide/Sete Rios'),
(10, 'Metro', 'Linha D (Amarela)', 'Estação Estádio do Dragão'),
(11, 'Metro', 'Linha A, B, C, E, F', 'Estação Trindade (centro)'),
(12, 'Autocarro', 'STCP 200, 207', 'Zona do Dragão'),
(13, 'Autocarro', 'STCP 204, 300, 301', 'Centro do Porto'),
(14, 'Autocarro', 'TUB 2, 43', 'Zona do Estádio Municipal'),
(15, 'Comboio', 'Linha do Minho (CP)', 'Estação de Braga'),
(16, 'Autocarro', 'Rodoviária do Alentejo', 'De Lisboa para Alcochete'),
(17, 'Autocarro', 'TST 561, 562', 'Ligação a Alcochete');

-- --------------------------------------------------------

--
-- Estrutura da tabela `turma`
--

CREATE TABLE `turma` (
  `curso_curso_ID` int(11) NOT NULL,
  `ano_letivo_ano_letivo_ID` int(11) NOT NULL,
  `turma_ID` int(11) NOT NULL,
  `sigla` varchar(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `turma`
--

INSERT INTO `turma` (`curso_curso_ID`, `ano_letivo_ano_letivo_ID`, `turma_ID`, `sigla`) VALUES
(1, 1, 1, '1DA'),
(1, 1, 2, '1DB'),
(1, 1, 3, '3DA'),
(1, 2, 4, '2DA'),
(1, 2, 5, '2DB'),
(1, 2, 6, '3DB'),
(2, 1, 7, '1EA'),
(2, 1, 8, '1EB'),
(2, 1, 9, '3EA'),
(2, 2, 10, '2EA'),
(2, 2, 11, '2EB'),
(2, 2, 12, '3EB'),
(3, 1, 13, '1AA'),
(3, 1, 14, '1AB'),
(3, 1, 15, '3AA'),
(3, 2, 16, '2AA'),
(3, 2, 17, '2AB'),
(3, 2, 18, '3AB');

-- --------------------------------------------------------

--
-- Estrutura da tabela `utilizador`
--

CREATE TABLE `utilizador` (
  `utilizador_ID` int(11) NOT NULL,
  `nome` text NOT NULL,
  `login` text NOT NULL,
  `password` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `utilizador`
--

INSERT INTO `utilizador` (`utilizador_ID`, `nome`, `login`, `password`) VALUES
(1, 'Daniel Masqueiro', 'adm1', 'fcporto123'),
(2, 'Gonçalo Sobral', 'adm2', 'pem(ale)@9'),
(3, 'Rafael Silva', 'adm3', '@alternas666'),
(4, 'Cristiano Ronaldo', 'cr7', 'ronaldo123'),
(5, 'Lionel Messi', 'lm10', 'messi123'),
(6, 'LeBron James', 'kingjames', 'lebron123'),
(7, 'Stephen Curry', 'curry30', 'steph123'),
(8, 'Kylian Mbappé', 'mbappe', 'kiki123'),
(9, 'Erling Haaland', 'haaland', 'erling123'),
(10, 'Jude Bellingham', 'jude', 'bellingham123'),
(11, 'Luka Doncic\r\n', 'luka77', 'doncic123'),
(12, 'Nikola Jokic', 'joker', 'jokic123'),
(13, 'António Silva', 'asilva', 'benfica123'),
(14, 'João Neves', 'jneves', 'benfica456'),
(15, 'Diogo Costa', 'dcosta', 'porto123'),
(16, 'Alan Varela', 'varela', 'porto456'),
(17, 'Kevin Durant', 'kd', 'durant123'),
(18, 'Giannis Antetokounmpo', 'giannis', 'anteto123'),
(19, 'Bukayo Saka', 'saka', 'saka123'),
(20, 'Cole Palmer', 'palmer', 'cole123'),
(21, 'Michael Jordan', 'mj23', 'jordan123'),
(22, 'Kobe Bryant', 'kobe', 'mamba123'),
(23, 'Neymar Jr', 'neymar', 'njr123'),
(24, 'Zinedine Zidane', 'zizou', 'zidane123'),
(25, 'Ronaldo Nazário', 'r9', 'fenomeno123'),
(26, 'Ronaldinho', 'r10', 'gaucho123'),
(27, 'Shaquille ONeal', 'shaq', 'diesel123'),
(28, 'Magic Johnson', 'magic', 'magic123'),
(29, 'Larry Bird', 'bird', 'bird123'),
(30, 'Diego Maradona', 'd10s', 'maradona123'),
(31, 'Pelé', 'pele', 'rei123'),
(32, 'Paolo Maldini', 'maldini', 'maldini123'),
(33, 'Franz Beckenbauer', 'kaiser', 'beckenbauer123'),
(34, 'Johan Cruyff', 'cruyff', 'cruyff123'),
(35, 'Zlatan Ibrahimovi?', 'zlatan', 'zlatan123'),
(36, 'Thierry Henry', 'henry', 'henry123'),
(37, 'Dennis Bergkamp', 'bergkamp', 'bergkamp123'),
(38, 'Hakeem Olajuwon', 'hakeem', 'hakeem123'),
(39, 'Tim Duncan', 'duncan', 'duncan123'),
(40, 'Dirk Nowitzki', 'dirk', 'dirk123'),
(41, 'Allen Iverson', 'iverson', 'answer123'),
(42, 'Vítor Baía', 'vbaia', 'baia123'),
(43, 'Rui Costa', 'rcosta', 'maestro123'),
(44, 'Luís Figo', 'figo', 'figo123'),
(45, 'Eusébio', 'eusebio', 'pantera123'),
(46, 'Vini Jr', 'vini', 'vini123'),
(47, 'Rodrygo', 'rodrygo', 'rodrygo123'),
(48, 'Lamine Yamal', 'yamal', 'yamal123'),
(49, 'Kawhi Leonard', 'kawhi', 'leonard123'),
(50, 'Paul George', 'pg13', 'george123'),
(51, 'James Harden', 'harden', 'harden123'),
(52, 'Damian Lillard', 'dame', 'lillard123'),
(53, 'Jayson Tatum', 'tatum', 'tatum123'),
(54, 'Devin Booker', 'booker', 'booker123'),
(55, 'Anthony Davis', 'ad', 'davis123'),
(56, 'Kyrie Irving', 'kyrie', 'irving123'),
(57, 'Pedri', 'pedri', 'pedri123'),
(58, 'Gavi', 'gavi', 'gavi123'),
(59, 'Florian Wirtz', 'wirtz', 'wirtz123'),
(60, 'Jamal Musiala', 'musiala', 'musiala123'),
(61, 'Phil Foden', 'foden', 'foden123'),
(62, 'Rodri', 'rodri', 'rodri123'),
(63, 'Declan Rice', 'rice', 'rice123'),
(64, 'Martin Ødegaard', 'odegaard', 'odegaard123'),
(65, 'Virgil van Dijk', 'vandijk', 'virgil123'),
(66, 'Alisson Becker', 'alisson', 'alisson123'),
(67, 'Scottie Pippen', 'pippen', 'pippen123'),
(68, 'Dennis Rodman', 'rodman', 'rodman123'),
(69, 'Charles Barkley', 'barkley', 'barkley123'),
(70, 'Karl Malone', 'malone', 'malone123'),
(71, 'John Stockton', 'stockton', 'stockton123'),
(72, 'David Robinson', 'robinson', 'robinson123'),
(73, 'Patrick Ewing', 'ewing', 'ewing123'),
(74, 'Hristo Stoichkov', 'stoichkov', 'stoichkov123'),
(75, 'Roberto Baggio', 'baggio', 'baggio123'),
(76, 'Romário', 'romario', 'romario123'),
(77, 'Gabriel Batistuta', 'batistuta', 'bati123'),
(78, 'Pavel Nedved', 'nedved', 'nedved123'),
(79, 'Andriy Shevchenko', 'shevchenko', 'sheva123'),
(80, 'Kaká', 'kaka', 'kaka123'),
(81, 'Didier Drogba', 'drogba', 'drogba123'),
(82, 'Frank Lampard', 'lampard', 'lampard123'),
(83, 'Steven Gerrard', 'gerrard', 'gerrard123'),
(84, 'Paul Scholes', 'scholes', 'scholes123'),
(85, 'Ryan Giggs', 'giggs', 'giggs123'),
(86, 'David Beckham', 'beckham', 'beckham123'),
(87, 'Wayne Rooney', 'rooney', 'rooney123'),
(88, 'Frank Ribéry', 'ribery', 'ribery123'),
(89, 'Arjen Robben', 'robben', 'robben123'),
(90, 'Bastian Schweinsteiger', 'schweinsteiger', 'basti123'),
(91, 'Philipp Lahm', 'lahm', 'lahm123'),
(92, 'Iker Casillas', 'casillas', 'iker123'),
(93, 'Carles Puyol', 'puyol', 'puyol123'),
(94, 'Xavi Hernández', 'xavi', 'xavi123'),
(95, 'Andrés Iniesta', 'iniesta', 'iniesta123'),
(96, 'David Villa', 'villa', 'villa123'),
(97, 'Fernando Torres', 'torres', 'torres123'),
(98, 'Cesc Fàbregas', 'cesc', 'cesc123'),
(99, 'Sergio Ramos', 'ramos', 'ramos123'),
(100, 'Gerard Piqué', 'pique', 'pique123'),
(101, 'Sergio Busquets', 'busquets', 'busquets123'),
(102, 'Jordi Alba', 'alba', 'alba123'),
(103, 'Dani Alves', 'alves', 'alves123'),
(104, 'Andrea Pirlo', 'pirlo', 'pirlo123'),
(105, 'Gennaro Gattuso', 'gattuso', 'gattuso123'),
(106, 'Filippo Inzaghi', 'inzaghi', 'inzaghi123'),
(107, 'Alessandro Del Piero', 'delpiero', 'delpiero123'),
(108, 'Francesco Totti', 'totti', 'totti123'),
(109, 'Daniele De Rossi', 'derossi', 'derossi123'),
(110, 'Fabio Cannavaro', 'cannavaro', 'cannavaro123'),
(111, 'Gianluigi Buffon', 'buffon', 'gigi123'),
(112, 'Paolo Cannavaro', 'pcannavaro', 'pcannavaro123'),
(113, 'Alessandro Nesta', 'nesta', 'nesta123'),
(114, 'Jaap Stam', 'stam', 'stam123'),
(115, 'Edgar Davids', 'davids', 'davids123'),
(116, 'Clarence Seedorf', 'seedorf', 'seedorf123'),
(117, 'Ruud van Nistelrooy', 'ruud', 'ruud123'),
(118, 'Patrick Kluivert', 'kluivert', 'kluivert123'),
(119, 'Marc Overmars', 'overmars', 'overmars123'),
(120, 'Edwin van der Sar', 'vandersar', 'vandersar123'),
(121, 'Robert Pires', 'pires', 'pires123'),
(122, 'Patrick Vieira', 'vieira', 'vieira123'),
(123, 'Emmanuel Petit', 'petit', 'petit123'),
(124, 'Marcel Desailly', 'desailly', 'desailly123'),
(125, 'Lilian Thuram', 'thuram', 'thuram123'),
(126, 'Laurent Blanc', 'blanc', 'blanc123'),
(132, 's1mple', 's1mple', 'navi123'),
(133, 'ZywOo', 'zywoo', 'vitality123'),
(134, 'm0NESY', 'monesy', 'g2123'),
(135, 'NiKo', 'niko', 'g2456'),
(136, 'ropz', 'ropz', 'faze123'),
(137, 'Faker', 'faker', 't1123'),
(138, 'Caps', 'caps', 'g2lol123'),
(139, 'Ninja', 'ninja', 'tyler123'),
(140, 'Shroud', 'shroud', 'shroud123'),
(144, 'xQc', 'xqc', 'xqc123'),
(145, 'Gaules', 'gaules', 'tribo123'),
(146, 'tarik', 'tarik', 'tarik123'),
(148, 'Tekkz', 'tekkz', 'tekkz123'),
(149, 'Umut', 'umut', 'rblz123'),
(150, 'Ollelito', 'ollelito', 'olle123'),
(151, 'Anders Vejrgang', 'anders', 'anders123'),
(152, 'TenZ', 'tenz', 'sentinels123'),
(153, 'Asuna', 'asuna', '100t123'),
(155, 'Sykkuno', 'sykkuno', 'sykkuno123'),
(157, 'Dr Disrespect', 'drd', 'doc123'),
(158, 'TimTheTatman', 'tim', 'tim123'),
(159, 'summit1g', 'summit', 'summit123'),
(160, 'device', 'device', 'astralis123'),
(161, 'Magisk', 'magisk', 'magisk123'),
(162, 'dupreeh', 'dupreeh', 'dupreeh123'),
(163, 'gla1ve', 'gla1ve', 'gla1ve123'),
(164, 'Xyp9x', 'xyp9x', 'xyp9x123'),
(165, 'FalleN', 'fallen', 'fallen123'),
(166, 'coldzera', 'coldzera', 'cold123'),
(167, 'fer', 'fer', 'fer123'),
(168, 'TACO', 'taco', 'taco123'),
(169, 'fnx', 'fnx', 'fnx123'),
(170, 'kennyS', 'kennys', 'kennys123'),
(171, 'shox', 'shox', 'shox123'),
(172, 'apEX', 'apex', 'apex123'),
(173, 'NBK-', 'nbk', 'nbk123'),
(174, 'Happy', 'happy', 'happy123'),
(175, 'olofmeister', 'olofm', 'olof123'),
(176, 'KRIMZ', 'krimz', 'krimz123'),
(177, 'flusha', 'flusha', 'flusha123'),
(178, 'JW', 'jw', 'jw123'),
(179, 'pronax', 'pronax', 'pronax123'),
(180, 'GeT_RiGhT', 'getright', 'getright123'),
(181, 'f0rest', 'f0rest', 'f0rest123'),
(182, 'Xizt', 'xizt', 'xizt123'),
(183, 'friberg', 'friberg', 'friberg123'),
(184, 'Adam', 'adam', 'adam123'),
(185, 'NEO', 'neo', 'neo123'),
(186, 'TaZ', 'taz', 'taz123'),
(187, 'pashaBiceps', 'pasha', 'pasha123'),
(188, 'byali', 'byali', 'byali123'),
(189, 'Snax', 'snax', 'snax123'),
(190, 'shroud_cs', 'shroud_cs', 'shroud_cs123'),
(191, 'n0thing', 'n0thing', 'n0thing123'),
(192, 'Skadoodle', 'skadoodle', 'skadoodle123'),
(193, 'seang@res', 'seangares', 'seangares123'),
(194, 'Hiko', 'hiko', 'hiko123'),
(195, 'summit1g_cs', 'summit_cs', 'summit_cs123'),
(196, 'Pimp', 'pimp', 'pimp123'),
(197, 'Maniac', 'maniac', 'maniac123'),
(198, 'SPUNJ', 'spunj', 'spunj123'),
(199, 'YNk', 'ynk', 'ynk123'),
(200, 'karrigan', 'karrigan', 'karrigan123'),
(201, 'rain', 'rain', 'rain123'),
(202, 'GuardiaN', 'guardian', 'guardian123'),
(203, 'seized', 'seized', 'seized123'),
(204, 'Edward', 'edward', 'edward123'),
(205, 'Zeus', 'zeus', 'zeus123'),
(206, 'flamie', 'flamie', 'flamie123'),
(207, 'electronic', 'electronic', 'electronic123'),
(208, 'Boombl4', 'boombl4', 'boombl4123'),
(209, 'Perfecto', 'perfecto', 'perfecto123'),
(210, 'b1t', 'b1t', 'b1t123'),
(211, 'donk', 'donk', 'donk123'),
(212, 'huNter-', 'hunter', 'hunter123'),
(213, 'jks', 'jks', 'jks123'),
(214, 'ALEX', 'alex', 'alex123'),
(215, 'mezii', 'mezii', 'mezii123'),
(216, 'blameF', 'blamef', 'blamef123'),
(217, 'stavn', 'stavn', 'stavn123'),
(218, 'cadiaN', 'cadian', 'cadian123'),
(219, 'TeSeS', 'teses', 'teses123'),
(220, 'sjuush', 'sjuush', 'sjuush123'),
(221, 'jabbi', 'jabbi', 'jabbi123'),
(222, 'refrezh', 'refrezh', 'refrezh123'),
(223, 'nicoodoz', 'nicoodoz', 'nicoodoz123'),
(224, 'roeJ', 'roej', 'roej123'),
(225, 'FASHR', 'fashr', 'fashr123'),
(226, 'k0nfig', 'k0nfig', 'k0nfig123'),
(227, 'aizy', 'aizy', 'aizy123'),
(228, 'MSL', 'msl', 'msl123'),
(229, 'North', 'north', 'north123'),
(230, 'valde', 'valde', 'valde123'),
(231, 'gade', 'gade', 'gade123'),
(232, 'cajunb', 'cajunb', 'cajunb123'),
(233, 'tenzki', 'tenzki', 'tenzki123'),
(234, 'Snappi', 'snappi', 'snappi123'),
(235, 'Marco', 'marco', 'marco123'),
(236, 'JUGi', 'jugi', 'jugi123'),
(237, 'mertz', 'mertz', 'mertz123'),
(238, 'acoR', 'acor', 'acor123'),
(239, 'Bubzkji', 'bubzkji', 'bubzkji123'),
(240, 'es3tag', 'es3tag', 'es3tag123'),
(241, 'blameF2', 'blamef2', 'blamef2123'),
(242, 'poizon', 'poizon', 'poizon123'),
(243, 'OBo', 'obo', 'obo123'),
(244, 'RUSH', 'rush', 'rush123'),
(245, 'stanislaw', 'stanislaw', 'stanislaw123'),
(246, 'tarik_cs', 'tarik_cs', 'tarik_cs123'),
(247, 'Brehze', 'brehze', 'brehze123'),
(248, 'CeRq', 'cerq', 'cerq123'),
(249, 'Ethan', 'ethan', 'ethan123'),
(250, 'nahtE', 'nahte', 'nahte123'),
(251, 'daps', 'daps', 'daps123'),
(252, 'koosta', 'koosta', 'koosta123'),
(253, 'Leonardo DiCaprio', 'leo', 'dicaprio123'),
(254, 'Tom Hanks', 'thanks', 'hanks123'),
(256, 'Denzel Washington', 'denzelw', 'denzel123'),
(257, 'Scarlett Johansson', 'scarlett', 'scarjo123'),
(258, 'Robert Downey Jr.', 'rdj', 'ironman123'),
(259, 'Margot Robbie', 'margot', 'robbie123'),
(260, 'Cillian Murphy', 'cillian', 'oppenheimer123'),
(261, 'Florence Pugh', 'florence', 'pugh123'),
(262, 'Timothée Chalamet', 'timmy', 'chalamet123'),
(263, 'Zendaya', 'zendaya', 'zendaya123'),
(264, 'Keanu Reeves', 'keanu', 'reeves123'),
(265, 'Brad Pitt', 'bradp', 'pitt123'),
(266, 'Angelina Jolie', 'angelina', 'jolie123'),
(267, 'Christian Bale', 'bale', 'batman123'),
(268, 'Joaquin Phoenix', 'joaquin', 'joker123'),
(269, 'Anya Taylor-Joy', 'anya', 'anya123'),
(270, 'Chris Hemsworth', 'chris', 'thor123'),
(271, 'Dwayne Johnson', 'therock', 'rock123'),
(272, 'Ryan Gosling', 'ryang', 'gosling123'),
(273, 'Emma Stone', 'emma', 'stone123'),
(274, 'Jenna Ortega', 'jenna', 'ortega123'),
(275, 'Al Pacino', 'pacino', 'pacino123'),
(276, 'Robert De Niro', 'deniro', 'deniro123'),
(277, 'Jack Nicholson', 'nicholson', 'nicholson123'),
(278, 'Marlon Brando', 'brando', 'brando123'),
(279, 'Anthony Hopkins', 'hopkins', 'hopkins123'),
(280, 'Morgan Freeman', 'freeman', 'freeman123'),
(281, 'Samuel L. Jackson', 'samuel', 'jackson123'),
(282, 'Harrison Ford', 'ford', 'ford123'),
(283, 'Clint Eastwood', 'eastwood', 'eastwood123'),
(284, 'Cate Blanchett', 'cate', 'blanchett123'),
(285, 'Jodie Foster', 'jodie', 'foster123'),
(286, 'Sigourney Weaver', 'weaver', 'weaver123'),
(287, 'Tom Cruise', 'cruise', 'cruise123'),
(288, 'Will Smith', 'smith', 'smith123'),
(289, 'Matt Damon', 'damon', 'damon123'),
(290, 'George Clooney', 'clooney', 'clooney123'),
(291, 'Julia Roberts', 'roberts', 'roberts123'),
(292, 'Sandra Bullock', 'bullock', 'bullock123'),
(293, 'Nicole Kidman', 'kidman', 'kidman123'),
(297, 'Mahershala Ali', 'mahershala_ali', 'ali123'),
(298, 'Daniel Day-Lewis', 'ddl', 'ddl123'),
(299, 'Gary Oldman', 'oldman', 'oldman123'),
(300, 'Kevin Spacey', 'spacey', 'spacey123'),
(301, 'John Travolta', 'travolta', 'travolta123'),
(302, 'Bruce Willis', 'willis', 'willis123'),
(303, 'Liam Neeson', 'neeson', 'neeson123'),
(304, 'Russell Crowe', 'crowe', 'crowe123'),
(305, 'Mel Gibson', 'gibson', 'gibson123'),
(306, 'Arnold Schwarzenegger', 'arnold', 'arnold123'),
(307, 'Sylvester Stallone', 'stallone', 'stallone123'),
(308, 'Jackie Chan', 'chan', 'chan123'),
(311, 'Michelle Yeoh', 'yeoh', 'yeoh123'),
(313, 'Gong Li', 'gong', 'gong123'),
(314, 'Tony Leung', 'leung', 'leung123'),
(315, 'Tilda Swinton', 'swinton', 'swinton123'),
(316, 'Willem Dafoe', 'dafoe', 'dafoe1A23'),
(317, 'Ralph Fiennes', 'fiennes', 'fiennes123'),
(318, 'Helena Bonham Carter', 'helena', 'helena123'),
(319, 'Alan Rickman', 'rickman', 'rickman123'),
(320, 'Maggie Smith', 'maggie', 'maggie123'),
(321, 'Judi Dench', 'judi', 'judi123'),
(322, 'Ian McKellen', 'mckellen', 'mckellen123'),
(323, 'Patrick Stewart', 'stewart', 'stewart123'),
(324, 'Christopher Lee', 'lee', 'lee123'),
(325, 'Adam Sandler', 'sandler', 'sandler123'),
(326, 'Jim Carrey', 'carrey', 'carrey123'),
(327, 'Ben Stiller', 'stiller', 'stiller123'),
(328, 'Owen Wilson', 'wilson', 'wilson123'),
(329, 'Vince Vaughn', 'vaughn', 'vaughn123'),
(330, 'Will Ferrell', 'ferrell', 'ferrell123'),
(331, 'Steve Carell', 'carell', 'carell123'),
(332, 'Seth Rogen', 'rogen', 'rogen123'),
(333, 'Jonah Hill', 'hill', 'hill123'),
(334, 'Michael Cera', 'cera', 'cera123'),
(335, 'Jason Bateman', 'bateman', 'bateman123'),
(336, 'Melissa McCarthy', 'mccarthy', 'mccarthy123'),
(337, 'Kristen Wiig', 'wiig', 'wiig123'),
(338, 'Maya Rudolph', 'rudolph', 'rudolph123'),
(339, 'Tina Fey', 'fey', 'fey123'),
(340, 'Amy Poehler', 'poehler', 'poehler123'),
(341, 'Bill Hader', 'hader', 'hader123'),
(342, 'Andy Samberg', 'samberg', 'samberg123'),
(343, 'Jason Sudeikis', 'sudeikis', 'sudeikis123'),
(344, 'Will Arnett', 'arnett', 'arnett123'),
(345, 'Aubrey Plaza', 'plaza', 'plaza123'),
(346, 'Chris Pratt', 'pratt', 'pratt123'),
(347, 'Nick Offerman', 'offerman', 'offerman123'),
(349, 'Donald Glover', 'glover', 'glover123'),
(350, 'Danny DeVito', 'devito', 'devito123'),
(351, 'Charlie Day', 'day', 'day123'),
(352, 'Rob McElhenney', 'mcelhenney', 'mcelhenney123'),
(353, 'Kaitlin Olson', 'olson', 'olson123'),
(354, 'Glenn Howerton', 'howerton', 'howerton123'),
(355, 'Saoirse Ronan', 'ronan', 'ronan123'),
(356, 'Natalie Portman', 'portman', 'portman123'),
(357, 'Anne Hathaway', 'hathaway', 'hathaway123'),
(358, 'Jake Gyllenhaal', 'gyllenhaal', 'gyllenhaal1aS23'),
(359, 'Oscar Isaac', 'isaac', 'isaac123'),
(360, 'Adam Driver', 'driver', 'driver123'),
(361, 'Laura Dern', 'dern', 'dern123'),
(362, 'Jeff Goldblum', 'goldblum', 'goldblum123'),
(363, 'Sam Neill', 'neill', 'neill123'),
(364, 'Tessa Thompson', 'thompson', 'thompson123'),
(365, 'Mark Ruffalo', 'ruffalo', 'ruffalo123'),
(366, 'Taika Waititi', 'waititi', 'waititi123'),
(367, 'Jemaine Clement', 'clement', 'clement123'),
(368, 'Rhys Darby', 'darby', 'darby123'),
(369, 'Simu Liu', 'liu', 'liu123'),
(370, 'Awkwafina', 'awkwafina', 'awkwafina123'),
(371, 'Kumail Nanjiani', 'nanjiani', 'nanjiani123'),
(372, 'Paul Rudd', 'rudd', 'rudd123'),
(373, 'Alfredo da Silva', 'GrupoDesportivoFabril', 'OsManosAcabaramComOFabril'),
(374, 'Sérgio Conceição', 'sergio_c', 'formador123'),
(375, 'Rúben Amorim', 'ruben_a', 'formador456'),
(376, 'Tarik \"tarik\" Celik', 'tarik_prof', 'formador789'),
(377, 'Alexandre \"Gaules\" Borba', 'gaules_prof', 'formador101'),
(378, 'Ana Moura', 'ana_moura_av', 'formador112'),
(379, 'João Botelho', 'joao_botelho', 'formador131'),
(380, 'Leonel Vieira', 'leonel_v', 'formador414');

-- --------------------------------------------------------

--
-- Estrutura da tabela `vagas`
--

CREATE TABLE `vagas` (
  `empresas_empresas_ID` int(11) NOT NULL,
  `ano_letivo_ano_letivo_ID` int(11) NOT NULL,
  `n_vagas` int(11) DEFAULT NULL,
  `vagas_cheias` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `vagas`
--

INSERT INTO `vagas` (`empresas_empresas_ID`, `ano_letivo_ano_letivo_ID`, `n_vagas`, `vagas_cheias`) VALUES
(1, 1, 8, b'0'),
(1, 2, 10, b'0'),
(2, 1, 15, b'0'),
(2, 2, 15, b'0'),
(3, 1, 12, b'0'),
(3, 2, 12, b'0'),
(4, 1, 14, b'0'),
(4, 2, 14, b'0'),
(5, 1, 10, b'0'),
(5, 2, 12, b'0'),
(6, 1, 6, b'0'),
(6, 2, 8, b'0'),
(7, 1, 5, b'0'),
(7, 2, 6, b'0'),
(8, 1, 8, b'0'),
(8, 2, 8, b'0'),
(9, 1, 10, b'0'),
(9, 2, 10, b'0'),
(10, 1, 12, b'0'),
(10, 2, 12, b'0');

-- --------------------------------------------------------

--
-- Estrutura da tabela `zona`
--

CREATE TABLE `zona` (
  `zona_ID` int(11) NOT NULL,
  `localidade` text NOT NULL,
  `mapa` text DEFAULT NULL,
  `designacao` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `zona`
--

INSERT INTO `zona` (`zona_ID`, `localidade`, `mapa`, `designacao`) VALUES
(1, 'Barreiro', 'uploads/mapas/barreiro.png', 'Zona do Barreiro e Lavradio'),
(2, 'Lisboa', 'uploads/mapas/lisboa.png', 'Zona da Grande Lisboa'),
(3, 'Porto', 'uploads/mapas/porto.png', 'Zona da Grande Porto'),
(4, 'Braga', 'uploads/mapas/braga.png', 'Zona de Braga'),
(5, 'Alcochete', 'uploads/mapas/alcochete.png', 'Zona de Alcochete');

-- --------------------------------------------------------

--
-- Estrutura da tabela `zona_transportes`
--

CREATE TABLE `zona_transportes` (
  `zona_zona_ID_` int(11) NOT NULL,
  `transporte_transporte_ID_` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `zona_transportes`
--

INSERT INTO `zona_transportes` (`zona_zona_ID_`, `transporte_transporte_ID_`) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 4),
(2, 5),
(2, 6),
(2, 7),
(2, 8),
(2, 9),
(3, 10),
(3, 11),
(3, 12),
(3, 13),
(4, 14),
(4, 15),
(5, 16),
(5, 17);

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `administrativo`
--
ALTER TABLE `administrativo`
  ADD PRIMARY KEY (`utilizador_ID`);

--
-- Índices para tabela `alunos`
--
ALTER TABLE `alunos`
  ADD PRIMARY KEY (`utilizador_ID`),
  ADD UNIQUE KEY `numero` (`numero`),
  ADD KEY `FK_alunos_turma_alunos_turma` (`turma_turma_ID`),
  ADD KEY `FK_alunos_administrativo` (`administrativo_ID`);

--
-- Índices para tabela `ano_letivo`
--
ALTER TABLE `ano_letivo`
  ADD PRIMARY KEY (`ano_letivo_ID`),
  ADD UNIQUE KEY `ano` (`ano`);

--
-- Índices para tabela `avaliacao_anual_estabelecimento`
--
ALTER TABLE `avaliacao_anual_estabelecimento`
  ADD PRIMARY KEY (`avaliacao_anual_estabelecimento_ID`),
  ADD KEY `FK_avaliacao_anual_estabelecimento_noname_estabelecimentos` (`estabelecimentos_estabelecimentos_ID`),
  ADD KEY `FK_avaliacao_anual_estabelecimento_noname_ano_letivo` (`ano_letivo_ano_letivo_ID`);

--
-- Índices para tabela `curso`
--
ALTER TABLE `curso`
  ADD PRIMARY KEY (`curso_ID`),
  ADD UNIQUE KEY `codigo` (`codigo`);

--
-- Índices para tabela `empresas`
--
ALTER TABLE `empresas`
  ADD PRIMARY KEY (`empresas_ID`),
  ADD UNIQUE KEY `telefone` (`telefone`),
  ADD UNIQUE KEY `contribuinte` (`contribuinte`,`email`,`website`) USING HASH,
  ADD KEY `FK_empresas_noname_administrativo` (`administrativo_ID`);

--
-- Índices para tabela `empresas_ramo`
--
ALTER TABLE `empresas_ramo`
  ADD PRIMARY KEY (`empresas_empresas_ID_`,`ramo_ramo_ID_`),
  ADD KEY `FK_ramo_empresas_ramo_empresas_` (`ramo_ramo_ID_`);

--
-- Índices para tabela `estabelecimentos`
--
ALTER TABLE `estabelecimentos`
  ADD PRIMARY KEY (`estabelecimentos_ID`),
  ADD UNIQUE KEY `telefone` (`telefone`,`email`) USING HASH,
  ADD KEY `FK_estabelecimentos_estabelecimentos_zona_zona` (`zona_zona_ID`),
  ADD KEY `FK_estabelecimentos_noname_administrativo` (`administrativo_ID`),
  ADD KEY `FK_estabelecimentos_empresas` (`empresas_empresas_ID`);

--
-- Índices para tabela `estabelecimentos_produtos`
--
ALTER TABLE `estabelecimentos_produtos`
  ADD PRIMARY KEY (`estabelecimentos_estabelecimentos_ID_`,`produtos_produtos_ID_`),
  ADD KEY `FK_produtos_estabelecimentos_produtos_estabelecimentos_` (`produtos_produtos_ID_`);

--
-- Índices para tabela `estabelecimentos_transportes`
--
ALTER TABLE `estabelecimentos_transportes`
  ADD PRIMARY KEY (`estabelecimentos_estabelecimentos_ID_`,`transporte_transporte_ID_`),
  ADD KEY `FK_transporte_estabelecimentos_transportes_estabelecimentos_` (`transporte_transporte_ID_`);

--
-- Índices para tabela `estagio`
--
ALTER TABLE `estagio`
  ADD PRIMARY KEY (`estagio_ID`),
  ADD KEY `FK_estagio_noname_estabelecimentos` (`estabelecimentos_estabelecimentos_ID`),
  ADD KEY `FK_estagio_responsavel_ID` (`responsavel_id_responsavel`),
  ADD KEY `FK_estagio_noname_alunos` (`alunos_ID`),
  ADD KEY `FK_estagio_noname_formador` (`formador_ID`);

--
-- Índices para tabela `formador`
--
ALTER TABLE `formador`
  ADD PRIMARY KEY (`utilizador_ID`),
  ADD UNIQUE KEY `numero` (`numero`);

--
-- Índices para tabela `produtos`
--
ALTER TABLE `produtos`
  ADD PRIMARY KEY (`produtos_ID`);

--
-- Índices para tabela `ramo`
--
ALTER TABLE `ramo`
  ADD PRIMARY KEY (`ramo_ID`),
  ADD KEY `FK_ramo_noname_administrativo` (`administrativo_ID`);

--
-- Índices para tabela `responsavel`
--
ALTER TABLE `responsavel`
  ADD PRIMARY KEY (`id_responsavel`),
  ADD KEY `FK_responsavel_estabelecimentos` (`estabelecimentos_estabelecimentos_ID`);

--
-- Índices para tabela `transporte`
--
ALTER TABLE `transporte`
  ADD PRIMARY KEY (`transporte_ID`);

--
-- Índices para tabela `turma`
--
ALTER TABLE `turma`
  ADD PRIMARY KEY (`turma_ID`),
  ADD KEY `FK_turma_noname_curso` (`curso_curso_ID`),
  ADD KEY `FK_turma_noname_ano_letivo` (`ano_letivo_ano_letivo_ID`);

--
-- Índices para tabela `utilizador`
--
ALTER TABLE `utilizador`
  ADD PRIMARY KEY (`utilizador_ID`),
  ADD UNIQUE KEY `login` (`login`) USING HASH;

--
-- Índices para tabela `vagas`
--
ALTER TABLE `vagas`
  ADD PRIMARY KEY (`empresas_empresas_ID`,`ano_letivo_ano_letivo_ID`),
  ADD KEY `FK_vagas_noname_ano_letivo` (`ano_letivo_ano_letivo_ID`);

--
-- Índices para tabela `zona`
--
ALTER TABLE `zona`
  ADD PRIMARY KEY (`zona_ID`);

--
-- Índices para tabela `zona_transportes`
--
ALTER TABLE `zona_transportes`
  ADD PRIMARY KEY (`zona_zona_ID_`,`transporte_transporte_ID_`),
  ADD KEY `FK_transporte_zona_transportes_zona_` (`transporte_transporte_ID_`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `ano_letivo`
--
ALTER TABLE `ano_letivo`
  MODIFY `ano_letivo_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `curso`
--
ALTER TABLE `curso`
  MODIFY `curso_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `empresas`
--
ALTER TABLE `empresas`
  MODIFY `empresas_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de tabela `estabelecimentos`
--
ALTER TABLE `estabelecimentos`
  MODIFY `estabelecimentos_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de tabela `estagio`
--
ALTER TABLE `estagio`
  MODIFY `estagio_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=81;

--
-- AUTO_INCREMENT de tabela `produtos`
--
ALTER TABLE `produtos`
  MODIFY `produtos_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT de tabela `ramo`
--
ALTER TABLE `ramo`
  MODIFY `ramo_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de tabela `responsavel`
--
ALTER TABLE `responsavel`
  MODIFY `id_responsavel` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de tabela `transporte`
--
ALTER TABLE `transporte`
  MODIFY `transporte_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de tabela `turma`
--
ALTER TABLE `turma`
  MODIFY `turma_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de tabela `utilizador`
--
ALTER TABLE `utilizador`
  MODIFY `utilizador_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=381;

--
-- AUTO_INCREMENT de tabela `zona`
--
ALTER TABLE `zona`
  MODIFY `zona_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `administrativo`
--
ALTER TABLE `administrativo`
  ADD CONSTRAINT `FK_administrativo_utilizador` FOREIGN KEY (`utilizador_ID`) REFERENCES `utilizador` (`utilizador_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `alunos`
--
ALTER TABLE `alunos`
  ADD CONSTRAINT `FK_alunos_administrativo` FOREIGN KEY (`administrativo_ID`) REFERENCES `administrativo` (`utilizador_ID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_alunos_turma_alunos_turma` FOREIGN KEY (`turma_turma_ID`) REFERENCES `turma` (`turma_ID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_alunos_utilizador` FOREIGN KEY (`utilizador_ID`) REFERENCES `utilizador` (`utilizador_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `avaliacao_anual_estabelecimento`
--
ALTER TABLE `avaliacao_anual_estabelecimento`
  ADD CONSTRAINT `FK_avaliacao_anual_estabelecimento_noname_ano_letivo` FOREIGN KEY (`ano_letivo_ano_letivo_ID`) REFERENCES `ano_letivo` (`ano_letivo_ID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_avaliacao_estabelecimentos` FOREIGN KEY (`estabelecimentos_estabelecimentos_ID`) REFERENCES `estabelecimentos` (`estabelecimentos_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `empresas`
--
ALTER TABLE `empresas`
  ADD CONSTRAINT `FK_empresas_noname_administrativo` FOREIGN KEY (`administrativo_ID`) REFERENCES `administrativo` (`utilizador_ID`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `empresas_ramo`
--
ALTER TABLE `empresas_ramo`
  ADD CONSTRAINT `FK_empresas_empresas_ramo_ramo_` FOREIGN KEY (`empresas_empresas_ID_`) REFERENCES `empresas` (`empresas_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_ramo_empresas_ramo_empresas_` FOREIGN KEY (`ramo_ramo_ID_`) REFERENCES `ramo` (`ramo_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `estabelecimentos`
--
ALTER TABLE `estabelecimentos`
  ADD CONSTRAINT `FK_estabelecimentos_empresas` FOREIGN KEY (`empresas_empresas_ID`) REFERENCES `empresas` (`empresas_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_estabelecimentos_estabelecimentos_zona_zona` FOREIGN KEY (`zona_zona_ID`) REFERENCES `zona` (`zona_ID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_estabelecimentos_noname_administrativo` FOREIGN KEY (`administrativo_ID`) REFERENCES `administrativo` (`utilizador_ID`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `estabelecimentos_produtos`
--
ALTER TABLE `estabelecimentos_produtos`
  ADD CONSTRAINT `FK_estabelecimentos_produtos_estabelecimentos` FOREIGN KEY (`estabelecimentos_estabelecimentos_ID_`) REFERENCES `estabelecimentos` (`estabelecimentos_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_produtos_estabelecimentos_produtos_estabelecimentos_` FOREIGN KEY (`produtos_produtos_ID_`) REFERENCES `produtos` (`produtos_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `estabelecimentos_transportes`
--
ALTER TABLE `estabelecimentos_transportes`
  ADD CONSTRAINT `FK_estabelecimentos_transportes_estabelecimentos` FOREIGN KEY (`estabelecimentos_estabelecimentos_ID_`) REFERENCES `estabelecimentos` (`estabelecimentos_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_transporte_estabelecimentos_transportes_estabelecimentos_` FOREIGN KEY (`transporte_transporte_ID_`) REFERENCES `transporte` (`transporte_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `estagio`
--
ALTER TABLE `estagio`
  ADD CONSTRAINT `FK_estagio_estabelecimentos` FOREIGN KEY (`estabelecimentos_estabelecimentos_ID`) REFERENCES `estabelecimentos` (`estabelecimentos_ID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_estagio_noname_alunos` FOREIGN KEY (`alunos_ID`) REFERENCES `alunos` (`utilizador_ID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_estagio_noname_formador` FOREIGN KEY (`formador_ID`) REFERENCES `formador` (`utilizador_ID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_estagio_responsavel_ID` FOREIGN KEY (`responsavel_id_responsavel`) REFERENCES `responsavel` (`id_responsavel`);

--
-- Limitadores para a tabela `formador`
--
ALTER TABLE `formador`
  ADD CONSTRAINT `FK_formador_utilizador` FOREIGN KEY (`utilizador_ID`) REFERENCES `utilizador` (`utilizador_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `ramo`
--
ALTER TABLE `ramo`
  ADD CONSTRAINT `FK_ramo_noname_administrativo` FOREIGN KEY (`administrativo_ID`) REFERENCES `administrativo` (`utilizador_ID`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `responsavel`
--
ALTER TABLE `responsavel`
  ADD CONSTRAINT `FK_responsavel_estabelecimentos` FOREIGN KEY (`estabelecimentos_estabelecimentos_ID`) REFERENCES `estabelecimentos` (`estabelecimentos_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `turma`
--
ALTER TABLE `turma`
  ADD CONSTRAINT `FK_turma_noname_ano_letivo` FOREIGN KEY (`ano_letivo_ano_letivo_ID`) REFERENCES `ano_letivo` (`ano_letivo_ID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_turma_noname_curso` FOREIGN KEY (`curso_curso_ID`) REFERENCES `curso` (`curso_ID`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `vagas`
--
ALTER TABLE `vagas`
  ADD CONSTRAINT `FK_vagas_noname_ano_letivo` FOREIGN KEY (`ano_letivo_ano_letivo_ID`) REFERENCES `ano_letivo` (`ano_letivo_ID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_vagas_para_empresas` FOREIGN KEY (`empresas_empresas_ID`) REFERENCES `empresas` (`empresas_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `zona_transportes`
--
ALTER TABLE `zona_transportes`
  ADD CONSTRAINT `FK_transporte_zona_transportes_zona_` FOREIGN KEY (`transporte_transporte_ID_`) REFERENCES `transporte` (`transporte_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_zona_zona_transportes_transporte_` FOREIGN KEY (`zona_zona_ID_`) REFERENCES `zona` (`zona_ID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
