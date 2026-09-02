<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['tipo'] != 'administrativo') {
    header("Location: index.php");
    exit;
}
require 'db.php';

// Q1. Formadores com mais de 1 estágio
$q1 = mysqli_query($conn, "SELECT u.nome, COUNT(e.aluno_id) as total FROM Formador f JOIN Utilizador u ON f.utilizador_id = u.utilizador_id JOIN Estagio e ON f.utilizador_id = e.formador_id GROUP BY u.nome HAVING total > 1");

// Q2. Empresas com média >= 14 (Nota dada pela empresa)
$q2 = mysqli_query($conn, "SELECT emp.firma, ROUND(AVG(e.nota_empresa), 2) as media FROM Empresa emp JOIN Estabelecimento est ON emp.empresa_id = est.empresa_id JOIN Estagio e ON est.empresa_id = e.estabelecimento_empresa_id AND est.estabelecimento_id = e.estabelecimento_id GROUP BY emp.firma HAVING media >= 14");

// Q3. Empresas que comercializam produtos
$q3 = mysqli_query($conn, "SELECT emp.firma, COUNT(c.produto_id) as total FROM Empresa emp JOIN Estabelecimento est ON emp.empresa_id = est.empresa_id JOIN Comercializa c ON est.empresa_id = c.estabelecimento_empresa_id AND est.estabelecimento_id = c.estabelecimento_id GROUP BY emp.firma HAVING total >= 1");

// Q4. Empresas com estágios
$q4 = mysqli_query($conn, "SELECT emp.firma, COUNT(e.aluno_id) as total FROM Empresa emp JOIN Estabelecimento est ON emp.empresa_id = est.empresa_id JOIN Estagio e ON est.empresa_id = e.estabelecimento_empresa_id AND est.estabelecimento_id = e.estabelecimento_id GROUP BY emp.firma HAVING total >= 1");

// Q5. Cursos com turmas acima da média
$q5 = mysqli_query($conn, "SELECT c.designacao, COUNT(t.turma_id) as total FROM Curso c JOIN Turma t ON c.curso_id = t.curso_id GROUP BY c.designacao HAVING total > (SELECT AVG(contagem) FROM (SELECT COUNT(turma_id) as contagem FROM Turma GROUP BY curso_id) as sub)");

// Q6. Formadores com média superior à global
$q6 = mysqli_query($conn, "SELECT u.nome, ROUND(AVG(e.nota_final), 2) as media FROM Formador f JOIN Utilizador u ON f.utilizador_id = u.utilizador_id JOIN Estagio e ON f.utilizador_id = e.formador_id GROUP BY u.nome HAVING media > (SELECT AVG(nota_final) FROM Estagio)");

// V1. View Detalhes Formadores
$v1 = mysqli_query($conn, "SELECT * FROM v1_detalhes_formadores");

// V2. View Média Empresa/Curso
$v2 = mysqli_query($conn, "SELECT * FROM v2_media_empresa_curso");

?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Estatísticas e Relatórios</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #e6f2ff; padding: 20px; }
        
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .btn-back { background-color: #6c757d; color: white; padding: 10px 20px; text-decoration: none; border-radius: 50px; font-weight: bold; }
        h1 { color: #003366; margin: 0; }

        /* GRID LAYOUT */
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
        }

        /* CARTÕES */
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 20px;
            border: 2px solid #0056b3;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        }

        .stat-card h3 {
            color: #0056b3;
            border-bottom: 2px solid #e6f2ff;
            padding-bottom: 10px;
            margin-top: 0;
            font-size: 16px;
            display: flex;
            justify-content: space-between;
        }

        .tag { font-size: 12px; background: #e6f2ff; padding: 2px 8px; border-radius: 4px; color: #555; }

        /* TABELAS DENTRO DOS CARTÕES */
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { text-align: left; font-size: 13px; color: #666; padding: 5px; border-bottom: 1px solid #ddd; }
        td { padding: 8px 5px; font-size: 14px; color: #333; border-bottom: 1px solid #f9f9f9; }
        tr:last-child td { border-bottom: none; }
        
        .empty { text-align: center; color: #999; font-style: italic; padding: 15px; }
        .highlight { font-weight: bold; color: #0056b3; }
    </style>
</head>
<body>

    <div class="header">
        <h1><i class="fas fa-chart-pie"></i> Relatórios de Gestão</h1>
        <a href="dashboard_admin.php" class="btn-back"><i class="fas fa-arrow-left"></i> Voltar</a>
    </div>

    <div class="dashboard-grid">

        <div class="stat-card">
            <h3>Formadores (> 1 Estágio) <span class="tag">Q1</span></h3>
            <table>
                <tr><th>Nome</th><th>Total</th></tr>
                <?php if(mysqli_num_rows($q1) == 0): ?>
                    <tr><td colspan='2' class='empty'>Sem dados</td></tr>
                <?php else: ?>
                    <?php while($r = mysqli_fetch_assoc($q1)): ?>
                        <tr><td><?php echo htmlspecialchars($r['nome']); ?></td><td class="highlight"><?php echo $r['total']; ?></td></tr>
                    <?php endwhile; ?>
                <?php endif; ?>
            </table>
        </div>

        <div class="stat-card">
            <h3>Top Empresas (Média >= 14) <span class="tag">Q2</span></h3>
            <table>
                <tr><th>Empresa</th><th>Média</th></tr>
                <?php if(mysqli_num_rows($q2) == 0): ?>
                    <tr><td colspan='2' class='empty'>Sem dados</td></tr>
                <?php else: ?>
                    <?php while($r = mysqli_fetch_assoc($q2)): ?>
                        <tr><td><?php echo htmlspecialchars($r['firma']); ?></td><td class="highlight"><?php echo $r['media']; ?> val.</td></tr>
                    <?php endwhile; ?>
                <?php endif; ?>
            </table>
        </div>

        <div class="stat-card">
            <h3>Empresas c/ Produtos <span class="tag">Q3</span></h3>
            <table>
                <tr><th>Empresa</th><th>Qtd.</th></tr>
                <?php if(mysqli_num_rows($q3) == 0): ?>
                    <tr><td colspan='2' class='empty'>Sem dados</td></tr>
                <?php else: ?>
                    <?php while($r = mysqli_fetch_assoc($q3)): ?>
                        <tr><td><?php echo htmlspecialchars($r['firma']); ?></td><td><?php echo $r['total']; ?></td></tr>
                    <?php endwhile; ?>
                <?php endif; ?>
            </table>
        </div>

        <div class="stat-card">
            <h3>Estágios por Empresa <span class="tag">Q4</span></h3>
            <table>
                <tr><th>Empresa</th><th>Qtd.</th></tr>
                <?php if(mysqli_num_rows($q4) == 0): ?>
                    <tr><td colspan='2' class='empty'>Sem dados</td></tr>
                <?php else: ?>
                    <?php while($r = mysqli_fetch_assoc($q4)): ?>
                        <tr><td><?php echo htmlspecialchars($r['firma']); ?></td><td class="highlight"><?php echo $r['total']; ?></td></tr>
                    <?php endwhile; ?>
                <?php endif; ?>
            </table>
        </div>

        <div class="stat-card">
            <h3>Cursos > Média Turmas <span class="tag">Q5</span></h3>
            <table>
                <tr><th>Curso</th><th>Total Turmas</th></tr>
                <?php if(mysqli_num_rows($q5) == 0): ?>
                    <tr><td colspan='2' class='empty'>Sem dados</td></tr>
                <?php else: ?>
                    <?php while($r = mysqli_fetch_assoc($q5)): ?>
                        <tr><td><?php echo htmlspecialchars($r['designacao']); ?></td><td><?php echo $r['total']; ?></td></tr>
                    <?php endwhile; ?>
                <?php endif; ?>
            </table>
        </div>

        <div class="stat-card">
            <h3>Formadores (Top Performance) <span class="tag">Q6</span></h3>
            <table>
                <tr><th>Nome</th><th>Média Final</th></tr>
                <?php if(mysqli_num_rows($q6) == 0): ?>
                    <tr><td colspan='2' class='empty'>Sem dados</td></tr>
                <?php else: ?>
                    <?php while($r = mysqli_fetch_assoc($q6)): ?>
                        <tr><td><?php echo htmlspecialchars($r['nome']); ?></td><td class="highlight"><?php echo $r['media']; ?></td></tr>
                    <?php endwhile; ?>
                <?php endif; ?>
            </table>
        </div>

        <div class="stat-card" style="grid-column: span 2;">
            <h3><i class="fas fa-table"></i> Detalhe Completo Formadores <span class="tag">View V1</span></h3>
            <table>
                <tr><th>Nome</th><th>Total Est.</th><th>Média Pessoal</th><th>Média Global</th></tr>
                <?php if(mysqli_num_rows($v1) == 0): ?>
                    <tr><td colspan='4' class='empty'>Sem dados</td></tr>
                <?php else: ?>
                    <?php while($r = mysqli_fetch_assoc($v1)): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($r['Nome_Formador']); ?></td>
                            <td><?php echo $r['Total_Estagios']; ?></td>
                            <td style="color: #666; font-weight: bold;"><?php echo $r['Media_Formador']; ?></td>
                            <td style="color: #666; font-weight: bold;"><?php echo $r['Media_Global_Todos']; ?></td>
                        </tr>
                    <?php endwhile; ?>
                <?php endif; ?>
            </table>
        </div>

        <div class="stat-card" style="grid-column: span 2;">
            <h3><i class="fas fa-table"></i> Média por Empresa e Curso <span class="tag">View V2</span></h3>
            <table>
                <tr><th>Empresa</th><th>Curso</th><th>Média Notas</th></tr>
                <?php if(mysqli_num_rows($v2) == 0): ?>
                    <tr><td colspan='3' class='empty'>Sem dados</td></tr>
                <?php else: ?>
                    <?php while($r = mysqli_fetch_assoc($v2)): ?>
                        <tr>
                            <td><strong><?php echo htmlspecialchars($r['Nome_Empresa']); ?></strong></td>
                            <td><?php echo htmlspecialchars($r['Nome_Curso']); ?></td>
                            <td class="highlight"><?php echo $r['Media_Notas']; ?></td>
                        </tr>
                    <?php endwhile; ?>
                <?php endif; ?>
            </table>
        </div>

    </div>

</body>
</html>