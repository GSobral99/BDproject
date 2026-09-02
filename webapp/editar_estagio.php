<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['tipo'] != 'administrativo') {
    header("Location: index.php");
    exit;
}
require 'db.php';

// Verificar se temos os IDs necessários
if (!isset($_GET['aluno']) || !isset($_GET['empresa']) || !isset($_GET['estab'])) {
    header("Location: gerir_estagios.php");
    exit;
}

$aluno_id = $_GET['aluno'];
$empresa_id = $_GET['empresa'];
$estabelecimento_id = $_GET['estab'];
$mensagem = "";

// PROCESSAR ATUALIZAÇÃO
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $novo_aluno_id = $_POST['aluno_id'];
    $novo_formador_id = $_POST['formador_id'];
    $data_inicio = $_POST['data_inicio'];
    $data_fim = $_POST['data_fim'];
    
    $parts = explode('|', $_POST['estabelecimento_combinado']);
    $nova_empresa_id = $parts[0];
    $novo_estabelecimento_id = $parts[1];
    
    $sql_check = "SELECT nota_final FROM estagio WHERE aluno_id = ? AND estabelecimento_empresa_id = ? AND estabelecimento_id = ?";
    $stmt_check = mysqli_prepare($conn, $sql_check);
    mysqli_stmt_bind_param($stmt_check, "iii", $aluno_id, $empresa_id, $estabelecimento_id);
    mysqli_stmt_execute($stmt_check);
    $result_check = mysqli_stmt_get_result($stmt_check);
    $estagio = mysqli_fetch_assoc($result_check);
    mysqli_stmt_close($stmt_check);
    
    if ($estagio && $estagio['nota_final'] !== null) {
        // Estágio finalizado - NÃO pode editar!
        $mensagem = "<div class='erro'><i class='fas fa-lock'></i> Erro: Não é possível editar estágios já finalizados!</div>";
        
    } else {
        
        //  VALIDAR DATAS (SÓ SE PUDER EDITAR)
        if ($data_inicio > $data_fim) {
            $mensagem = "<div class='erro'><i class='fas fa-exclamation-triangle'></i> Erro: A data de início não pode ser posterior à data de fim!</div>";
            
        } else {
            
            // EXECUTAR UPDATE (SÓ SE TUDO ESTIVER OK)
            
            // Se mudou de aluno, empresa ou estabelecimento, precisamos apagar e re-registar
            if ($novo_aluno_id != $aluno_id || $nova_empresa_id != $empresa_id || $novo_estabelecimento_id != $estabelecimento_id) {
                
                // Apagar o registo antigo
                $sql_delete = "DELETE FROM estagio WHERE aluno_id = ? AND estabelecimento_empresa_id = ? AND estabelecimento_id = ?";
                $stmt_delete = mysqli_prepare($conn, $sql_delete);
                mysqli_stmt_bind_param($stmt_delete, "iii", $aluno_id, $empresa_id, $estabelecimento_id);
                mysqli_stmt_execute($stmt_delete);
                mysqli_stmt_close($stmt_delete);
                
                // Usar a Stored Procedure P1 para registar o novo estágio
                // P1 valida se aluno, estabelecimento e formador existem antes de inserir
                $sql_sp = "CALL p1_registar_estagio(?, ?, ?, ?, ?, ?)";
                $stmt_sp = mysqli_prepare($conn, $sql_sp);
                mysqli_stmt_bind_param($stmt_sp, "iiiiss",
                    $novo_aluno_id, $novo_formador_id, $nova_empresa_id,
                    $novo_estabelecimento_id, $data_inicio, $data_fim
                );
                
                if (mysqli_stmt_execute($stmt_sp)) {
                    mysqli_stmt_close($stmt_sp);
                    $_SESSION['msg_sucesso'] = "<div class='sucesso'><i class='fas fa-check-circle'></i> Estágio atualizado com sucesso (via SP P1)!</div>";
                    header("Location: gerir_estagios.php");
                    exit;
                } else {
                    // Capturar erro da BD (Trigger ou SP)
                    $erro_bd = mysqli_error($conn);
                    $mensagem = "<div class='erro'><i class='fas fa-exclamation-circle'></i> Erro na Base de Dados: " . htmlspecialchars($erro_bd) . "</div>";
                    mysqli_stmt_close($stmt_sp);
                }
                
            } else {
                
                // Apenas atualizar datas e formador
                // Como já validámos as datas acima, o Trigger T2 não deve causar erro
                $sql_update = "UPDATE estagio SET formador_id = ?, data_inicio = ?, data_fim = ?
                            WHERE aluno_id = ? AND estabelecimento_empresa_id = ? AND estabelecimento_id = ?";
                $stmt_update = mysqli_prepare($conn, $sql_update);
                mysqli_stmt_bind_param($stmt_update, "issiii",
                    $novo_formador_id, $data_inicio, $data_fim,
                    $aluno_id, $empresa_id, $estabelecimento_id
                );
                
                if (mysqli_stmt_execute($stmt_update)) {
                    mysqli_stmt_close($stmt_update);
                    $_SESSION['msg_sucesso'] = "<div class='sucesso'><i class='fas fa-check-circle'></i> Estágio atualizado com sucesso!</div>";
                    header("Location: gerir_estagios.php");
                    exit;
                } else {
                    // Se ainda assim houver erro (não devia acontecer porque já validámos)
                    $erro_bd = mysqli_error($conn);
                    $mensagem = "<div class='erro'><i class='fas fa-exclamation-triangle'></i> Erro inesperado: " . htmlspecialchars($erro_bd) . "</div>";
                    mysqli_stmt_close($stmt_update);
                }
            }
        }
    }
}

// BUSCAR DADOS ATUAIS DO ESTÁGIO
$sql = "SELECT
    e.*,
    u_aluno.nome as nome_aluno,
    emp.firma as nome_empresa,
    est.nome_comercial as nome_estabelecimento,
    u_formador.nome as nome_formador
FROM estagio e
JOIN aluno a ON e.aluno_id = a.utilizador_id
JOIN utilizador u_aluno ON a.utilizador_id = u_aluno.utilizador_id
JOIN estabelecimento est ON e.estabelecimento_empresa_id = est.empresa_id
                        AND e.estabelecimento_id = est.estabelecimento_id
JOIN empresa emp ON est.empresa_id = emp.empresa_id
JOIN formador f ON e.formador_id = f.utilizador_id
JOIN utilizador u_formador ON f.utilizador_id = u_formador.utilizador_id
WHERE e.aluno_id = ? AND e.estabelecimento_empresa_id = ? AND e.estabelecimento_id = ?";

$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "iii", $aluno_id, $empresa_id, $estabelecimento_id);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
$estagio = mysqli_fetch_assoc($result);
mysqli_stmt_close($stmt);

if (!$estagio) {
    header("Location: gerir_estagios.php");
    exit;
}

// Verificar se está finalizado (antes de mostrar o formulário)
if ($estagio['nota_final'] !== null) {
    $_SESSION['msg_erro'] = "<div class='erro'><i class='fas fa-lock'></i> Não é possível editar estágios já finalizados!</div>";
    header("Location: gerir_estagios.php");
    exit;
}

// Buscar lista de alunos
$alunos = mysqli_query($conn, "SELECT u.utilizador_id, u.nome, a.numero
                                FROM aluno a
                                JOIN utilizador u ON a.utilizador_id = u.utilizador_id
                                ORDER BY u.nome");

// Buscar lista de estabelecimentos
$estabelecimentos = mysqli_query($conn, "SELECT est.empresa_id, est.estabelecimento_id,
                                                emp.firma, est.nome_comercial
                                        FROM estabelecimento est
                                        JOIN empresa emp ON est.empresa_id = emp.empresa_id
                                        ORDER BY emp.firma, est.nome_comercial");

// Buscar lista de formadores
$formadores = mysqli_query($conn, "SELECT u.utilizador_id, u.nome
                                FROM formador f
                                JOIN utilizador u ON f.utilizador_id = u.utilizador_id
                                ORDER BY u.nome");
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Editar Estágio</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #e6f2ff;
            padding: 40px 20px;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            min-height: 100vh;
        }

        .main-container {
            width: 100%;
            max-width: 700px;
        }

        .form-card {
            background: white;
            padding: 40px;
            border-radius: 30px;
            border: 3px solid #0056b3;
            box-shadow: 0 10px 25px rgba(0, 86, 179, 0.15);
        }

        .header-title {
            text-align: center;
            color: #0056b3;
            margin-bottom: 30px;
        }
        
        .header-title i {
            font-size: 50px;
            margin-bottom: 10px;
            display: block;
        }
        
        .header-title h1 {
            margin: 0;
            font-size: 28px;
            text-transform: uppercase;
        }
        
        .header-title .subtitle {
            color: #666;
            font-size: 14px;
            margin-top: 10px;
        }

        .info-box {
            background: linear-gradient(135deg, #f0f8ff 0%, #e6f2ff 100%);
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 25px;
            border-left: 4px solid #0056b3;
        }
        
        .info-box h3 {
            margin: 0 0 10px 0;
            color: #0056b3;
            font-size: 14px;
            text-transform: uppercase;
        }
        
        .info-box p {
            margin: 5px 0;
            font-size: 14px;
            color: #333;
        }

        .input-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: #003366;
            font-weight: bold;
            font-size: 14px;
        }
        
        label i {
            width: 20px;
            text-align: center;
            margin-right: 5px;
        }

        select, input[type="date"] {
            width: 100%;
            padding: 12px 20px;
            border: 2px solid #0056b3;
            border-radius: 50px;
            background-color: white;
            font-size: 15px;
            color: #333;
            outline: none;
            box-sizing: border-box;
            cursor: pointer;
        }

        select:focus, input:focus {
            box-shadow: 0 0 8px rgba(0, 86, 179, 0.4);
            background-color: #f0f8ff;
        }

        .btn-submit {
            width: 100%;
            background-color: #0056b3;
            color: white;
            border: none;
            padding: 15px;
            font-size: 16px;
            font-weight: bold;
            text-transform: uppercase;
            border-radius: 50px;
            cursor: pointer;
            transition: background 0.3s;
            margin-top: 20px;
        }

        .btn-submit:hover {
            background-color: #004494;
        }

        .btn-back {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #0056b3;
            text-decoration: none;
            font-weight: bold;
        }
        
        .btn-back:hover {
            text-decoration: underline;
        }

        .erro {
            background-color: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 15px;
            margin-bottom: 20px;
            border: 1px solid #f5c6cb;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        
        .date-row {
            display: flex;
            gap: 15px;
        }
        
        .date-row .input-group {
            flex: 1;
        }
    </style>
</head>
<body>

    <div class="main-container">
        
        <div class="form-card">
            
            <div class="header-title">
                <i class="fas fa-edit"></i>
                <h1>Editar Estágio</h1>
                <p class="subtitle">Apenas estágios ativos podem ser editados</p>
            </div>

            <div class="info-box">
                <h3><i class="fas fa-info-circle"></i> Dados Atuais</h3>
                <p><strong>Aluno:</strong> <?php echo htmlspecialchars($estagio['nome_aluno']); ?></p>
                <p><strong>Empresa:</strong> <?php echo htmlspecialchars($estagio['nome_empresa']); ?></p>
                <p><strong>Estabelecimento:</strong> <?php echo htmlspecialchars($estagio['nome_estabelecimento']); ?></p>
                <p><strong>Formador:</strong> <?php echo htmlspecialchars($estagio['nome_formador']); ?></p>
                <p><strong>Período:</strong> <?php echo date('d/m/Y', strtotime($estagio['data_inicio'])); ?> a <?php echo date('d/m/Y', strtotime($estagio['data_fim'])); ?></p>
            </div>

            <?php if (!empty($mensagem)) echo $mensagem; ?>

            <form method="POST">
                
                <div class="input-group">
                    <label><i class="fas fa-user-graduate"></i> Aluno</label>
                    <select name="aluno_id" required>
                        <?php while ($aluno = mysqli_fetch_assoc($alunos)): ?>
                            <option value="<?php echo $aluno['utilizador_id']; ?>"
                                    <?php echo ($aluno['utilizador_id'] == $estagio['aluno_id']) ? 'selected' : ''; ?>>
                                <?php echo htmlspecialchars($aluno['nome'] . " (Nº " . $aluno['numero'] . ")"); ?>
                            </option>
                        <?php endwhile; ?>
                    </select>
                </div>

                <div class="input-group">
                    <label><i class="fas fa-building"></i> Local de Estágio</label>
                    <select name="estabelecimento_combinado" required>
                        <?php while ($local = mysqli_fetch_assoc($estabelecimentos)): ?>
                            <?php
                                $value = $local['empresa_id'] . '|' . $local['estabelecimento_id'];
                                $current = $estagio['estabelecimento_empresa_id'] . '|' . $estagio['estabelecimento_id'];
                            ?>
                            <option value="<?php echo $value; ?>"
                                    <?php echo ($value == $current) ? 'selected' : ''; ?>>
                                <?php echo htmlspecialchars($local['firma'] . ' - ' . $local['nome_comercial']); ?>
                            </option>
                        <?php endwhile; ?>
                    </select>
                </div>

                <div class="input-group">
                    <label><i class="fas fa-chalkboard-teacher"></i> Formador Responsável</label>
                    <select name="formador_id" required>
                        <?php while ($prof = mysqli_fetch_assoc($formadores)): ?>
                            <option value="<?php echo $prof['utilizador_id']; ?>"
                                    <?php echo ($prof['utilizador_id'] == $estagio['formador_id']) ? 'selected' : ''; ?>>
                                <?php echo htmlspecialchars($prof['nome']); ?>
                            </option>
                        <?php endwhile; ?>
                    </select>
                </div>

                <div class="date-row">
                    <div class="input-group">
                        <label><i class="fas fa-calendar-plus"></i> Data Início</label>
                        <input type="date"
                            name="data_inicio"
                            value="<?php echo $estagio['data_inicio']; ?>"
                            required>
                    </div>

                    <div class="input-group">
                        <label><i class="fas fa-calendar-check"></i> Data Fim</label>
                        <input type="date"
                            name="data_fim"
                            value="<?php echo $estagio['data_fim']; ?>"
                            required>
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fas fa-save"></i> Guardar Alterações
                </button>

            </form>

            <a href="gerir_estagios.php" class="btn-back">
                <i class="fas fa-times"></i> Cancelar e Voltar
            </a>

        </div>

    </div>

</body>
</html>