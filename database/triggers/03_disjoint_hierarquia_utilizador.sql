-- =====================================================================
-- Regra de negócio: um utilizador só pode ser aluno OU formador OU
-- administrativo, nunca mais do que um ao mesmo tempo (herança disjunta)
-- Tabelas alvo: administrativo, alunos, formador
-- =====================================================================

DELIMITER $$

CREATE TRIGGER trg_check_disjoint_admin_before_insert
BEFORE INSERT ON administrativo
FOR EACH ROW
BEGIN
  DECLARE v_is_aluno INT;
  DECLARE v_is_formador INT;
  SELECT COUNT(*) INTO v_is_aluno FROM `alunos` WHERE `utilizador_ID` = NEW.utilizador_ID;
  SELECT COUNT(*) INTO v_is_formador FROM `formador` WHERE `utilizador_ID` = NEW.utilizador_ID;
  IF (v_is_aluno > 0 OR v_is_formador > 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Este utilizador já existe como aluno ou formador.';
  END IF;
END$$

CREATE TRIGGER trg_check_disjoint_aluno_before_insert
BEFORE INSERT ON alunos
FOR EACH ROW
BEGIN
  DECLARE v_is_formador INT;
  DECLARE v_is_admin INT;
  SELECT COUNT(*) INTO v_is_formador FROM `formador` WHERE `utilizador_ID` = NEW.utilizador_ID;
  SELECT COUNT(*) INTO v_is_admin FROM `administrativo` WHERE `utilizador_ID` = NEW.utilizador_ID;
  IF (v_is_formador > 0 OR v_is_admin > 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Este utilizador já existe como formador ou administrativo.';
  END IF;
END$$

CREATE TRIGGER trg_check_disjoint_formador_before_insert
BEFORE INSERT ON formador
FOR EACH ROW
BEGIN
  DECLARE v_is_aluno INT;
  DECLARE v_is_admin INT;
  SELECT COUNT(*) INTO v_is_aluno FROM `alunos` WHERE `utilizador_ID` = NEW.utilizador_ID;
  SELECT COUNT(*) INTO v_is_admin FROM `administrativo` WHERE `utilizador_ID` = NEW.utilizador_ID;
  IF (v_is_aluno > 0 OR v_is_admin > 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Este utilizador já existe como aluno ou administrativo.';
  END IF;
END$$

DELIMITER ;
