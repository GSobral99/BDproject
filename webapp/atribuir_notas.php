<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['tipo'] != 'formador') {
    header("Location: index.php");
    exit;
}
require 'db.php';

$formador_id = $_SESSION['user_id'];
$mensagem = "";

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['acao'])) {
    $aluno_id = $_POST['aluno_id'];
    $empresa_id = $_POST['empresa_id'];
    $estabelecimento_id = $_POST['estabelecimento_id'];
    
    $n_empresa = $_POST['nota_empresa'];
    $n_escola = $_POST['nota_escola'];
    $n_relatorio = $_POST['nota_relatorio'];
    $n_procura = $_POST['nota_procura'];
    
    if ($n_empresa < 0 || $n_escola < 0 || $n_relatorio < 0 || $n_procura < 0) {
        $mensagem = "<div class='erro'><i class='fas fa-exclamation-triangle'></i> Erro: Notas negativas não são permitidas. Use valores entre 0 e 20.</div>";
    } 
    else if ($n_empresa > 20 || $n_escola > 20 || $n_relatorio > 20 || $n_procura > 20) {
        $mensagem = "<div class='erro'><i class='fas fa-exclamation-triangle'></i> Erro: As notas não podem ser superiores a 20 valores.</div>";
    }
    else {

        $sql_update = "UPDATE estagio SET
                        nota_empresa = ?,
                        nota_escola = ?,
                        nota_relatorio = ?,
                        nota_procura = ?
                        WHERE aluno_id = ?
                        AND estabelecimento_empresa_id = ?
                        AND estabelecimento_id = ?";
        
        $stmt = mysqli_prepare($conn, $sql_update);
        mysqli_stmt_bind_param($stmt, "ddddiii",
            $n_empresa, $n_escola, $n_relatorio, $n_procura,
            $aluno_id, $empresa_id, $estabelecimento_id
        );
        
        if (mysqli_stmt_execute($stmt)) {
            $p_empresa = 0.4;    // 40%
            $p_escola = 0.3;     // 30%
            $p_relatorio = 0.2;  // 20%
            $p_procura = 0.1;    // 10%

            $sql_calc = "UPDATE estagio
                        SET nota_final = f2_calculo_nota_final(?, ?, ?, ?, ?, ?, ?)
                        WHERE aluno_id = ?
                        AND estabelecimento_empresa_id = ?
                        AND estabelecimento_id = ?";
            
            $stmt2 = mysqli_prepare($conn, $sql_calc);
            
            mysqli_stmt_bind_param($stmt2, "ddddiiiiii",
                $p_empresa, $p_escola, $p_relatorio, $p_procura,
                $empresa_id, $estabelecimento_id, $aluno_id,
                $aluno_id, $empresa_id, $estabelecimento_id
            );
            
            if(mysqli_stmt_execute($stmt2)) {
                $mensagem = "<div class='sucesso'><i class='fas fa-check-circle'></i> Notas gravadas e média calculada com sucesso!</div>";
            } else {
                $mensagem = "<div class='erro'>Erro ao calcular média: " . mysqli_error($conn) . "</div>";
            }
            mysqli_stmt_close($stmt2);
            
        } else {
            $mensagem = "<div class='erro'>Erro ao gravar notas: " . mysqli_error($conn) . "</div>";
        }
        
        mysqli_stmt_close($stmt);
    }
}

$sql = "SELECT
            e.aluno_id, e.estabelecimento_empresa_id, e.estabelecimento_id,
            u_aluno.nome as nome_aluno,
            emp.firma as nome_empresa,
            e.nota_empresa, e.nota_escola, e.nota_relatorio, e.nota_procura, e.nota_final
        FROM estagio e
        JOIN aluno a ON e.aluno_id = a.utilizador_id
        JOIN utilizador u_aluno ON a.utilizador_id = u_aluno.utilizador_id
        JOIN estabelecimento est ON e.estabelecimento_empresa_id = est.empresa_id 
                                AND e.estabelecimento_id = est.estabelecimento_id
        JOIN empresa emp ON est.empresa_id = emp.empresa_id
        WHERE e.formador_id = ?";

$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "i", $formador_id);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Portal do Formador</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #e6f2ff;
            padding: 20px;
            color: #333;
        }
        .nav-bar {
            background: white; padding: 15px 30px; border-radius: 15px; border-bottom: 3px solid #0056b3;
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 40px;
            box-shadow: 0 5px 15px rgba(0, 86, 179, 0.1);
        }
        .nav-title { color: #0056b3; font-size: 24px; font-weight: bold; margin: 0; display: flex; align-items: center; gap: 10px; }
        .btn-logout { background-color: #dc3545; color: white; text-decoration: none; padding: 10px 20px; border-radius: 50px; font-weight: bold; transition: opacity 0.3s; }
        .btn-logout:hover { opacity: 0.8; }
        
        .sucesso { background-color: #d4edda; color: #155724; padding: 15px; border-radius: 10px; margin-bottom: 20px; border: 1px solid #c3e6cb; }
        .erro { background-color: #f8d7da; color: #721c24; padding: 15px; border-radius: 10px; margin-bottom: 20px; border: 1px solid #f5c6cb; }

        .info-banner {
            background: #cfe2ff;
            border: 2px solid #084298;
            color: #084298;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: bold;
        }
        .info-banner i { font-size: 24px; }

        .container { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 30px; }
        .student-card {
            background: white; border-radius: 20px; padding: 30px;
            border: 2px solid #0056b3; box-shadow: 0 10px 20px rgba(0,0,0,0.05); transition: transform 0.3s;
        }
        .student-card:hover { transform: translateY(-5px); }
        .card-header { border-bottom: 1px solid #e6f2ff; padding-bottom: 15px; margin-bottom: 20px; }
        .student-name { font-size: 20px; color: #003366; font-weight: bold; margin: 0; }
        .company-name { color: #666; font-size: 14px; margin-top: 5px; }

        .grades-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 20px; }
        .grade-input-group label { display: block; font-size: 12px; color: #0056b3; font-weight: bold; margin-bottom: 5px; }
        .grade-input-group input {
            width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 10px;
            text-align: center; font-weight: bold; box-sizing: border-box;
        }
        .grade-input-group input:focus { border-color: #0056b3; outline: none; background-color: #f0f8ff; }

        .btn-submit {
            width: 100%; background-color: #0056b3; color: white; border: none; padding: 12px;
            border-radius: 50px; font-weight: bold; cursor: pointer; text-transform: uppercase; transition: background 0.3s;
        }
        .btn-submit:hover { background-color: #004494; }

        .status-badge { display: inline-block; padding: 5px 12px; border-radius: 15px; font-size: 12px; font-weight: bold; margin-top: 10px; }
        .status-pendente { background-color: #fff3cd; color: #856404; }
        .status-concluido { background-color: #d4edda; color: #155724; }
    </style>
</head>
<body>

    <div class="nav-bar">
        <div class="nav-title">
            <i class="fas fa-chalkboard-teacher"></i> <span>Portal do Formador</span>
        </div>
        <div>
            <span style="margin-right: 15px; font-weight: bold; color: #555;">
                Olá, <?php echo htmlspecialchars($_SESSION['nome']); ?>
            </span>
            <a href="index.php" class="btn-logout"><i class="fas fa-sign-out-alt"></i> Sair</a>
        </div>
    </div>

    <h2 style="color: #003366; margin-bottom: 20px; text-align: center;">Os Seus Alunos para Avaliação</h2>

    <div class="container">
        
        <?php if (mysqli_num_rows($result) == 0): ?>
            <p style="grid-column: 1/-1; text-align: center; color: #777;">Não tem alunos atribuídos ou estágios ativos.</p>
        <?php else: ?>
            
            <?php while ($row = mysqli_fetch_assoc($result)): ?>
                <div class="student-card">
                    <div class="card-header">
                        <h3 class="student-name"><i class="fas fa-user-graduate"></i> <?php echo htmlspecialchars($row['nome_aluno']); ?></h3>
                        <div class="company-name"><i class="fas fa-building"></i> Estágio na <strong><?php echo htmlspecialchars($row['nome_empresa']); ?></strong></div>
                        
                        <?php if($row['nota_final']): ?>
                            <span class="status-badge status-concluido">Nota Final: <?php echo $row['nota_final']; ?></span>
                        <?php else: ?>
                            <span class="status-badge status-pendente">Aguarda Avaliação</span>
                        <?php endif; ?>
                    </div>

                    <form method="POST">
                        <input type="hidden" name="acao" value="lancar_notas">
                        <input type="hidden" name="aluno_id" value="<?php echo $row['aluno_id']; ?>">
                        <input type="hidden" name="empresa_id" value="<?php echo $row['estabelecimento_empresa_id']; ?>">
                        <input type="hidden" name="estabelecimento_id" value="<?php echo $row['estabelecimento_id']; ?>">

                        <div class="grades-grid">
                            <div class="grade-input-group">
                                <label>Nota Empresa (40%)</label>
                                <input type="number" name="nota_empresa" min="0" max="20" step="0.1" value="<?php echo $row['nota_empresa']; ?>" required placeholder="0-20">
                            </div>
                            <div class="grade-input-group">
                                <label>Nota Escola (30%)</label>
                                <input type="number" name="nota_escola" min="0" max="20" step="0.1" value="<?php echo $row['nota_escola']; ?>" required placeholder="0-20">
                            </div>
                            <div class="grade-input-group">
                                <label>Relatório (20%)</label>
                                <input type="number" name="nota_relatorio" min="0" max="20" step="0.1" value="<?php echo $row['nota_relatorio']; ?>" required placeholder="0-20">
                            </div>
                            <div class="grade-input-group">
                                <label>Procura (10%)</label>
                                <input type="number" name="nota_procura" min="0" max="20" step="0.1" value="<?php echo $row['nota_procura']; ?>" required placeholder="0-20">
                            </div>
                        </div>

                        <button type="submit" class="btn-submit"><i class="fas fa-save"></i> Guardar e Calcular</button>
                    </form>
                </div>
            <?php endwhile; ?>
        <?php endif; ?>
    </div>

    <?php mysqli_stmt_close($stmt); ?>
</body>
</html>