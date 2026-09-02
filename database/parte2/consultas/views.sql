-- =====================================================================
-- Views V1 e V2
-- dump do phpMyAdmin, com nomes de tabela normalizados para minúsculas)
-- =====================================================================

-- V1: Detalhes dos estágios por formador
-- Nº total de estágios supervisionados, média pessoal e média global
DROP VIEW IF EXISTS v1_detalhes_formadores;

CREATE VIEW v1_detalhes_formadores AS
SELECT
  u.nome AS Nome_Formador,
  COUNT(e.aluno_id) AS Total_Estagios,
  ROUND(AVG(e.nota_final), 2) AS Media_Formador,
  (SELECT ROUND(AVG(estagio.nota_final), 2) FROM estagio) AS Media_Global_Todos
FROM formador f
JOIN utilizador u ON f.utilizador_id = u.utilizador_id
JOIN estagio e ON f.utilizador_id = e.formador_id
GROUP BY u.nome;


-- V2: Média de notas finais por empresa e curso
DROP VIEW IF EXISTS v2_media_empresa_curso;

CREATE VIEW v2_media_empresa_curso AS
SELECT
  emp.firma AS Nome_Empresa,
  c.designacao AS Nome_Curso,
  ROUND(AVG(e.nota_final), 2) AS Media_Notas
FROM estagio e
JOIN estabelecimento est ON e.estabelecimento_empresa_id = est.empresa_id
                         AND e.estabelecimento_id = est.estabelecimento_id
JOIN empresa emp ON est.empresa_id = emp.empresa_id
JOIN aluno a ON e.aluno_id = a.utilizador_id
JOIN turma t ON a.turma_id = t.turma_id
JOIN curso c ON t.curso_id = c.curso_id
GROUP BY emp.firma, c.designacao;
