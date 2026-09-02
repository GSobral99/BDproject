-- =====================================================================
-- Consultas SQL-DML (Q1 a Q6)
-- =====================================================================

-- (Q1) Formadores com mais de 1 estágio
SELECT
  u.nome,
  COUNT(e.aluno_id) AS total
FROM Formador f
JOIN Utilizador u ON f.utilizador_id = u.utilizador_id
JOIN Estagio e ON f.utilizador_id = e.formador_id
GROUP BY u.nome
HAVING total > 1;


-- (Q2) Empresas com média de nota_empresa >= 14
SELECT
  emp.firma,
  ROUND(AVG(e.nota_empresa), 2) AS media
FROM Empresa emp
JOIN Estabelecimento est ON emp.empresa_id = est.empresa_id
JOIN Estagio e ON est.empresa_id = e.estabelecimento_empresa_id
              AND est.estabelecimento_id = e.estabelecimento_id
GROUP BY emp.firma
HAVING media >= 14;


-- (Q3) Empresas que comercializam pelo menos 1 produto
SELECT
  emp.firma,
  COUNT(c.produto_id) AS total
FROM Empresa emp
JOIN Estabelecimento est ON emp.empresa_id = est.empresa_id
JOIN Comercializa c ON est.empresa_id = c.estabelecimento_empresa_id
                    AND est.estabelecimento_id = c.estabelecimento_id
GROUP BY emp.firma
HAVING total >= 1;


-- (Q4) Empresas com pelo menos 1 estágio
SELECT
  emp.firma,
  COUNT(e.aluno_id) AS total
FROM Empresa emp
JOIN Estabelecimento est ON emp.empresa_id = est.empresa_id
JOIN Estagio e ON est.empresa_id = e.estabelecimento_empresa_id
              AND est.estabelecimento_id = e.estabelecimento_id
GROUP BY emp.firma
HAVING total >= 1
ORDER BY total DESC;


-- (Q5) Cursos com número de turmas acima da média geral de turmas por curso
SELECT
  c.designacao,
  COUNT(t.turma_id) AS total
FROM Curso c
JOIN Turma t ON c.curso_id = t.curso_id
GROUP BY c.designacao
HAVING total > (
  SELECT AVG(contagem)
  FROM (
    SELECT COUNT(turma_id) AS contagem
    FROM Turma
    GROUP BY curso_id
  ) AS sub
);


-- (Q6) Formadores cuja média de nota_final é superior à média global
SELECT
  u.nome,
  ROUND(AVG(e.nota_final), 2) AS media
FROM Formador f
JOIN Utilizador u ON f.utilizador_id = u.utilizador_id
JOIN Estagio e ON f.utilizador_id = e.formador_id
GROUP BY u.nome
HAVING media > (SELECT AVG(nota_final) FROM Estagio);
