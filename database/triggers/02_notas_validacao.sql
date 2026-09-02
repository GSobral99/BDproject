-- =====================================================================
-- Regra de negócio: notas da escola/empresa entre 0-20, nota do aluno entre 1-5
-- Tabela alvo: estagio
-- =====================================================================

DELIMITER $$

CREATE TRIGGER trg_check_notas_before_insert
BEFORE INSERT ON estagio
FOR EACH ROW
BEGIN
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
END$$

CREATE TRIGGER trg_check_notas_before_update
BEFORE UPDATE ON estagio
FOR EACH ROW
BEGIN
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
END$$

DELIMITER ;
