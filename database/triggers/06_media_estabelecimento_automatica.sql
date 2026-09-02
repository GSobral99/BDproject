-- =====================================================================
-- Automação: sempre que uma nota_dada_pelo_aluno é inserida, alterada ou
-- removida em `estagio`, a média de avaliação do estabelecimento
-- correspondente (tabela avaliacao_anual_estabelecimento) é recalculada
-- automaticamente através da procedure sp_atualizar_media_estabelecimento.
--
-- IMPORTANTE: requer que database/procedures/sp_atualizar_media_estabelecimento.sql
-- já tenha sido executado antes destes triggers.
--
-- Tabela alvo: estagio
-- =====================================================================

DELIMITER $$

CREATE TRIGGER trg_atualizar_media_estab_after_insert
AFTER INSERT ON estagio
FOR EACH ROW
BEGIN
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
END$$

CREATE TRIGGER trg_atualizar_media_estab_after_update
AFTER UPDATE ON estagio
FOR EACH ROW
BEGIN
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
END$$

CREATE TRIGGER trg_atualizar_media_estab_after_delete
AFTER DELETE ON estagio
FOR EACH ROW
BEGIN
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
END$$

DELIMITER ;
