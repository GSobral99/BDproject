<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['tipo'] != 'aluno') {
    header("Location: index.php");
    exit;
}
require 'db.php';

$aluno_id = $_SESSION['user_id'];

$sql = "SELECT
    e.aluno_id, e.estabelecimento_empresa_id, e.estabelecimento_id,
    e.data_inicio, e.data_fim, e.nota_final,
    emp.firma,
    emp.telefone,
    est.nome_comercial, est.morada, est.localidade,
    r.nome as nome_resp, r.email as email_resp, r.telemovel as tel_resp,
    u_formador.nome as nome_formador
FROM estagio e
JOIN estabelecimento est ON e.estabelecimento_empresa_id = est.empresa_id
                        AND e.estabelecimento_id = est.estabelecimento_id
JOIN empresa emp ON est.empresa_id = emp.empresa_id
LEFT JOIN responsavel r ON est.responsavel_id = r.responsavel_id
JOIN formador f ON e.formador_id = f.utilizador_id
JOIN utilizador u_formador ON f.utilizador_id = u_formador.utilizador_id
WHERE e.aluno_id = ?
ORDER BY e.data_inicio DESC";

$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "i", $aluno_id);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
?>


<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Meus Estágios</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #e6f2ff; padding: 20px; }
        
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .btn-back { background-color: #6c757d; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; font-weight: bold;}
        
        .card {
            background: white; border-left: 5px solid #0056b3;
            border-radius: 10px; padding: 25px; margin-bottom: 25px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        h2 { color: #0056b3; margin-top: 0; }
        h3 { font-size: 16px; border-bottom: 1px solid #eee; padding-bottom: 5px; margin-top: 20px; color: #333; }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 30px;
        }
        
        .item { margin-bottom: 8px; color: #555; display: flex; align-items: center; gap: 10px; }
        .item i { width: 20px; color: #0056b3; text-align: center; }
        
        .badge { background-color: #ffc107; padding: 5px 15px; border-radius: 20px; font-weight: bold; font-size: 14px; }
        .badge.nota { background-color: #28a745; color: white; }
    </style>
</head>
<body>

    <div class="header">
        <h1 style="color: #003366;">Os Meus Estágios</h1>
        <a href="empresas.php" class="btn-back"><i class="fas fa-arrow-left"></i> Voltar</a>
    </div>

    <?php if (mysqli_num_rows($result) == 0): ?>
        <p style="text-align: center; color: #777;">Ainda não tens estágios registados.</p>
    <?php else: ?>
        <?php while ($row = mysqli_fetch_assoc($result)): ?>
            
            <?php
                // Procurar transportes
                $sql_t = "SELECT t.meio_transporte, t.linha FROM transporte t
                        JOIN servido s ON t.transporte_id = s.transporte_id
                        WHERE s.estabelecimento_empresa_id = ? AND s.estabelecimento_id = ?";
                $stmt_t = mysqli_prepare($conn, $sql_t);
                mysqli_stmt_bind_param($stmt_t, "ii", $row['estabelecimento_empresa_id'], $row['estabelecimento_id']);
                mysqli_stmt_execute($stmt_t);
                $result_t = mysqli_stmt_get_result($stmt_t);
                $transportes = [];
                while ($t = mysqli_fetch_assoc($result_t)) {
                    $transportes[] = $t;
                }
                mysqli_stmt_close($stmt_t);
            ?>

            <div class="card">
                <div style="display:flex; justify-content:space-between; flex-wrap: wrap;">
                    <h2><?php echo htmlspecialchars($row['firma']); ?></h2>
                    <span>
                        <?php if ($row['nota_final']): ?>
                            <span class="badge nota">Nota Final: <?php echo $row['nota_final']; ?></span>
                        <?php else: ?>
                            <span class="badge">A decorrer</span>
                        <?php endif; ?>
                    </span>
                </div>

                <div class="grid">
                    <div>
                        <h3><i class="fas fa-map-marker-alt"></i> Detalhes</h3>
                        <div class="item"><i class="far fa-calendar-alt"></i> <span><?php echo $row['data_inicio']; ?> a <?php echo $row['data_fim']; ?></span></div>
                        <div class="item"><i class="fas fa-building"></i> <span><?php echo htmlspecialchars($row['nome_comercial']); ?></span></div>
                        <div class="item"><i class="fas fa-map-pin"></i> <span><?php echo htmlspecialchars($row['morada'] . ', ' . $row['localidade']); ?></span></div>
                        
                        <div class="item"><i class="fas fa-phone-alt"></i> <span><?php echo htmlspecialchars($row['telefone']); ?></span></div>
                    </div>
                    
                    <div>
                        <h3><i class="fas fa-user-tie"></i> Responsável (Empresa)</h3>
                        <?php if($row['nome_resp']): ?>
                            <div class="item"><i class="fas fa-user"></i> <span><?php echo htmlspecialchars($row['nome_resp']); ?></span></div>
                            <div class="item"><i class="fas fa-envelope"></i> <span><?php echo htmlspecialchars($row['email_resp']); ?></span></div>
                            <div class="item"><i class="fas fa-phone"></i> <span><?php echo htmlspecialchars($row['tel_resp']); ?></span></div>
                        <?php else: ?>
                            <p style="color:#aaa">Sem responsável atribuído.</p>
                        <?php endif; ?>
                    </div>

                    <div>
                        <h3><i class="fas fa-chalkboard-teacher"></i> Formador (Escola)</h3>
                        <div class="item">
                            <i class="fas fa-user-graduate"></i>
                            <strong><?php echo htmlspecialchars($row['nome_formador']); ?></strong>
                        </div>
                        <p style="font-size: 13px; color: #777; margin-top: 5px;">
                            Este é o docente responsável pela tua avaliação final.
                        </p>
                    </div>
                </div>

                <h3><i class="fas fa-bus"></i> Transportes</h3>
                <?php if (count($transportes) > 0): ?>
                    <?php foreach ($transportes as $t): ?>
                        <span style="background:#eee; padding:5px 10px; border-radius:5px; margin-right:5px; font-size:14px; display:inline-block; margin-top:5px;">
                            <?php echo htmlspecialchars($t['meio_transporte'] . ($t['linha'] ? " - " . $t['linha'] : "")); ?>
                        </span>
                    <?php endforeach; ?>
                <?php else: ?>
                    <span style="color:#999">Sem informação de transportes.</span>
                <?php endif; ?>
            </div>
        <?php endwhile; ?>
    <?php endif; ?>

    <?php mysqli_stmt_close($stmt); ?>
</body>
</html>