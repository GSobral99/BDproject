-- =====================================================================
-- Procedure: recalcula media_avaliacoes em avaliacao_anual_estabelecimento
-- a partir da média de nota_dada_pelo_aluno em estagio, para um dado
-- estabelecimento e ano letivo. Cria o registo de avaliação se ainda
-- não existir para esse par (estabelecimento, ano_letivo).
-- =====================================================================

DELIMITER $$

CREATE PROCEDURE sp_atualizar_media_estabelecimento(
  IN p_estabelecimento_id INT,
  IN p_ano_letivo_id INT
)
BEGIN
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
