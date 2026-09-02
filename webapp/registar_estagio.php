<?php
session_start();
// Verificar permissões (Formador e Administrativo podem registar)
if (!isset($_SESSION['user_id']) || ($_SESSION['tipo'] != 'administrativo' && $_SESSION['tipo'] != 'formador')) {
    header("Location: index.php");
    exit;
}
require 'db.php';

$mensagem = "";

// Carregar listas para os dropdowns
$alunos = mysqli_query($conn, "SELECT utilizador_id, nome FROM utilizador WHERE tipo='aluno' ORDER BY nome");

// Carregar empresas e estabelecimentos combinados
$estabelecimentos_query = "SELECT e.estabelecimento_id, e.empresa_id, e.nome_comercial, emp.firma
                        FROM estabelecimento e
                        JOIN empresa emp ON e.empresa_id = emp.empresa_id
                        ORDER BY emp.firma, e.nome_comercial";
$estabelecimentos = mysqli_query($conn, $estabelecimentos_query);

$formadores = mysqli_query($conn, "SELECT utilizador_id, nome FROM utilizador WHERE tipo='formador' ORDER BY nome");

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $aluno_id = $_POST['aluno_id'];
    
    // Separar o ID da Empresa e do Estabelecimento (vêm juntos no value "empresa|estab")
    $estab_comp = explode('|', $_POST['estabelecimento_combined']);
    $empresa_id = $estab_comp[0];
    $estabelecimento_id = $estab_comp[1];
    
    $formador_id = $_POST['formador_id'];
    $data_inicio = $_POST['data_inicio'];
    $data_fim = $_POST['data_fim'];

    // 1. PREPARAR SQL (Chamada ao Procedure p1_registar_estagio)
    $sql = "CALL p1_registar_estagio(?, ?, ?, ?, ?, ?)";
    $stmt = mysqli_prepare($conn, $sql);

    // Se o procedure não existir ou houver erro técnico na preparação
    if ($stmt === false) {
        $mensagem = "<div class='erro'>Erro técnico: Não foi possível preparar o pedido.</div>";
    } else {
        mysqli_stmt_bind_param($stmt, "iiiiss", $aluno_id, $formador_id, $empresa_id, $estabelecimento_id, $data_inicio, $data_fim);

        // 2. BLOCO DE PROTEÇÃO (TRY-CATCH)
        // É aqui que impedimos os "Fatal Errors"
        try {
            if (mysqli_stmt_execute($stmt)) {
                // SUCESSO
                $_SESSION['msg_sucesso'] = "<div class='sucesso'><i class='fas fa-check-circle'></i> Estágio registado com sucesso!</div>";
                header("Location: gerir_estagios.php");
                exit;
            } else {
                // Se o execute falhar (retornar false), lançamos a exceção manualmente para o bloco catch apanhar
                throw new Exception(mysqli_error($conn), mysqli_errno($conn));
            }
        } catch (Exception $e) {
            // --- TRATAMENTO DOS ERROS ---
            
            $erro_codigo = $e->getCode(); // O número do erro (ex: 1062, 1644)
            $erro_msg = $e->getMessage(); // A mensagem técnica

            if ($erro_codigo == 1062) {
                // ERRO DE DUPLICADO (Tentativa de registar o mesmo estágio)
                $mensagem = "<div class='erro'><i class='fas fa-exclamation-circle'></i> Atenção: Este aluno já tem um estágio registado nesse local. Não são permitidos duplicados.</div>";
            
            } elseif ($erro_codigo == 1644 || strpos($erro_msg, '45000') !== false) {
                // ERRO DE TRIGGER (Datas inválidas)
                // Limpamos o lixo técnico ("SQLSTATE...", "Unhandled exception...") para mostrar só a frase limpa
                $msg_limpa = str_replace("Unhandled user-defined exception:", "", $erro_msg);
                $msg_limpa = preg_replace('/SQLSTATE\[\d+\]:?/', '', $msg_limpa);
                
                $mensagem = "<div class='erro'><i class='fas fa-calendar-times'></i> " . htmlspecialchars($msg_limpa) . "</div>";
            
            } else {
                // OUTROS ERROS GENÉRICOS
                $mensagem = "<div class='erro'><i class='fas fa-bug'></i> Erro inesperado: " . htmlspecialchars($erro_msg) . "</div>";
            }
        }
        mysqli_stmt_close($stmt);
    }
}
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Novo Estágio</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #e6f2ff; padding: 40px 20px; display: flex; justify-content: center; }
        .form-card { background: white; padding: 40px; border-radius: 30px; border: 3px solid #0056b3; width: 100%; max-width: 600px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
        
        /* Ícone em destaque no topo */
        .header-icon { text-align: center; margin-bottom: 10px; }
        .header-icon i { font-size: 40px; color: #0056b3; } 
        
        h1 { color: #0056b3; text-align: center; margin-top: 0; margin-bottom: 30px; font-size: 24px; }
        
        label { display: block; margin-bottom: 5px; color: #003366; font-weight: bold; }
        select, input { width: 100%; padding: 12px; margin-bottom: 15px; border: 2px solid #0056b3; border-radius: 50px; box-sizing: border-box; }
        
        .btn-submit { width: 100%; background: #0056b3; color: white; border: none; padding: 15px; border-radius: 50px; font-weight: bold; cursor: pointer; text-transform: uppercase; }
        .btn-submit:hover { background: #004494; }
        .btn-back { display: block; text-align: center; margin-top: 20px; color: #0056b3; text-decoration: none; font-weight: bold; }
        
        /* Mensagens com tamanho corrigido (mais compactas) */
        .erro {
            background-color: #fff3cd; color: #856404;
            padding: 10px 15px;
            border-radius: 15px; margin-bottom: 20px; border: 1px solid #ffeeba;
            text-align: center; font-weight: bold; font-size: 14px;
        }
        .sucesso {
            background-color: #d4edda; color: #155724;
            padding: 10px 15px;
            border-radius: 15px; margin-bottom: 20px; border: 1px solid #c3e6cb;
            text-align: center; font-size: 14px;
        }
    </style>
</head>
<body>

    <div class="form-card">
        
        <div class="header-icon">
            <i class="fas fa-file-signature"></i>
        </div>
        <h1>Registar Novo Estágio</h1>
        
        <?php echo $mensagem; ?>

        <form method="POST">
            
            <label>Aluno:</label>
            <select name="aluno_id" required>
                <option value="">-- Selecione o Aluno --</option>
                <?php while ($a = mysqli_fetch_assoc($alunos)): ?>
                    <option value="<?php echo $a['utilizador_id']; ?>"><?php echo htmlspecialchars($a['nome']); ?></option>
                <?php endwhile; ?>
            </select>

            <label>Estabelecimento (Empresa):</label>
            <select name="estabelecimento_combined" required>
                <option value="">-- Selecione o Local --</option>
                <?php while ($est = mysqli_fetch_assoc($estabelecimentos)): ?>
                    <option value="<?php echo $est['empresa_id'] . '|' . $est['estabelecimento_id']; ?>">
                        <?php echo htmlspecialchars($est['firma'] . " - " . $est['nome_comercial']); ?>
                    </option>
                <?php endwhile; ?>
            </select>

            <label>Formador Responsável:</label>
            <select name="formador_id" required>
                <option value="">-- Selecione o Formador --</option>
                <?php while ($f = mysqli_fetch_assoc($formadores)): ?>
                    <option value="<?php echo $f['utilizador_id']; ?>"><?php echo htmlspecialchars($f['nome']); ?></option>
                <?php endwhile; ?>
            </select>

            <div style="display: flex; gap: 20px;">
                <div style="flex: 1;">
                    <label>Data Início:</label>
                    <input type="date" name="data_inicio" required>
                </div>
                <div style="flex: 1;">
                    <label>Data Fim:</label>
                    <input type="date" name="data_fim" required>
                </div>
            </div>

            <button type="submit" class="btn-submit">Criar Estágio</button>
        </form>

        <a href="gerir_estagios.php" class="btn-back">Voltar à Gestão</a>
    </div>

</body>
</html>