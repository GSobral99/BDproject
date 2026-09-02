-- =====================================================================
-- Regra de negócio: o responsável associado a um estágio tem de pertencer
-- ao mesmo estabelecimento onde o estágio decorre
-- Tabela alvo: estagio
-- =====================================================================

DELIMITER $$

CREATE TRIGGER trg_check_responsavel_estabelecimento_before_insert
BEFORE INSERT ON estagio
FOR EACH ROW
BEGIN
  DECLARE v_resp_estab_id INT;

  SELECT `estabelecimentos_estabelecimentos_ID`
  INTO v_resp_estab_id
  FROM `responsavel`
  WHERE `id_responsavel` = NEW.responsavel_id_responsavel;

  IF (v_resp_estab_id != NEW.estabelecimentos_estabelecimentos_ID) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Erro: O responsável selecionado não pertence ao estabelecimento de estágio especificado.';
  END IF;
END$$

CREATE TRIGGER trg_check_responsavel_estabelecimento_before_update
BEFORE UPDATE ON estagio
FOR EACH ROW
BEGIN
  DECLARE v_resp_estab_id INT;

  SELECT `estabelecimentos_estabelecimentos_ID`
  INTO v_resp_estab_id
  FROM `responsavel`
  WHERE `id_responsavel` = NEW.responsavel_id_responsavel;

  IF (v_resp_estab_id != NEW.estabelecimentos_estabelecimentos_ID) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Erro: O responsável selecionado não pertence ao estabelecimento de estágio especificado.';
  END IF;
END$$

DELIMITER ;
