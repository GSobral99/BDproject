-- =====================================================================
-- Automação: nota_final é sempre calculada, nunca inserida manualmente.
-- É a média das notas preenchidas entre nota_dada_empresa, nota_dada_escola,
-- nota_relatorio e nota_procura (ignora as que ainda estão a NULL).
-- Tabela alvo: estagio
-- =====================================================================

DELIMITER $$

CREATE TRIGGER trg_calcular_nota_final_before_insert
BEFORE INSERT ON estagio
FOR EACH ROW
BEGIN
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
END$$

CREATE TRIGGER trg_calcular_nota_final_before_update
BEFORE UPDATE ON estagio
FOR EACH ROW
BEGIN
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
END$$

DELIMITER ;
