-- =====================================================================
-- Regra de negócio: cada turma deve ter entre 10 e 28 alunos
-- Tabela alvo: alunos
-- =====================================================================

DELIMITER $$

-- Impede inserir um aluno numa turma que já tenha 28 alunos
CREATE TRIGGER trg_check_turma_max_before_insert
BEFORE INSERT ON alunos
FOR EACH ROW
BEGIN
  DECLARE v_count INT;
  SELECT COUNT(*) INTO v_count FROM `alunos` WHERE `turma_turma_ID` = NEW.turma_turma_ID;
  IF v_count >= 28 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A turma já atingiu o limite máximo de 28 alunos.';
  END IF;
END$$

-- Impede remover um aluno de uma turma que já tenha 10 alunos ou menos
CREATE TRIGGER trg_check_turma_min_before_delete
BEFORE DELETE ON alunos
FOR EACH ROW
BEGIN
  DECLARE v_count INT;
  SELECT COUNT(*) INTO v_count FROM `alunos` WHERE `turma_turma_ID` = OLD.turma_turma_ID;
  IF v_count <= 10 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A turma não pode ficar com menos de 10 alunos.';
  END IF;
END$$

-- Complementa as regras anteriores quando um aluno muda de turma (UPDATE)
CREATE TRIGGER trg_check_turma_update_before_update
BEFORE UPDATE ON alunos
FOR EACH ROW
BEGIN
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
END$$

DELIMITER ;
