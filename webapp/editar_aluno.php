<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['tipo'] != 'administrativo') {
    header("Location: index.php");
    exit;
}
require 'db.php';

// Verificar se temos um ID
if (!isset($_GET['id'])) {
    header("Location: gerir_alunos.php");
    exit;
}

$id_aluno = $_GET['id'];
$mensagem = "";

// PROCESSAR ATUALIZAÇÃO
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $nome = $_POST['nome'];
    $login = $_POST['login'];
    $numero = $_POST['numero'];
    $turma_id = $_POST['turma_id'];
    
    // Se a password foi preenchida, atualizamos. Se não, mantemos a antiga.
    $sql_base_user = "UPDATE utilizador SET nome = ?, login = ?";
    $types = "ss";
    $params = [$nome, $login];
    
    if (!empty($_POST['password'])) {
        $sql_base_user .= ", password = ?";
        $types .= "s";
        $params[] = $_POST['password'];
    }
    $sql_base_user .= " WHERE utilizador_id = ?";
    $types .= "i";
    $params[] = $id_aluno;

    // 1. Update Tabela Utilizador
    $stmt = mysqli_prepare($conn, $sql_base_user);
    
    // Bind dinâmico dos parâmetros
    $bind_params = [$types];
    foreach ($params as $key => $value) {
        $bind_params[] = &$params[$key];
    }
    call_user_func_array([$stmt, 'bind_param'], $bind_params);
    
    if (mysqli_stmt_execute($stmt)) {
        mysqli_stmt_close($stmt);
        
        // 2. Update Tabela Aluno
        $stmt2 = mysqli_prepare($conn, "UPDATE aluno SET numero = ?, turma_id = ? WHERE utilizador_id = ?");
        mysqli_stmt_bind_param($stmt2, "iii", $numero, $turma_id, $id_aluno);
        
        if (mysqli_stmt_execute($stmt2)) {
            mysqli_stmt_close($stmt2);
            
            // Guardamos a mensagem na "memória" da sessão
            $_SESSION['msg_sucesso'] = "<div class='sucesso'><i class='fas fa-check-circle'></i> Aluno atualizado com sucesso!</div>";
            
            // Redirecionamos
            header("Location: gerir_alunos.php");
            exit;
        } else {
            $mensagem = "<div class='erro'>Erro ao atualizar aluno: " . mysqli_error($conn) . "</div>";
            mysqli_stmt_close($stmt2);
        }
    } else {
        $mensagem = "<div class='erro'>Erro ao atualizar utilizador: " . mysqli_error($conn) . "</div>";
        mysqli_stmt_close($stmt);
    }
}

// BUSCAR DADOS ATUAIS
$stmt = mysqli_prepare($conn, "SELECT u.*, a.numero, a.turma_id FROM utilizador u JOIN aluno a ON u.utilizador_id = a.utilizador_id WHERE u.utilizador_id = ?");
mysqli_stmt_bind_param($stmt, "i", $id_aluno);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
$aluno = mysqli_fetch_assoc($result);
mysqli_stmt_close($stmt);

if (!$aluno) {
    header("Location: gerir_alunos.php");
    exit;
}

$turmas = mysqli_query($conn, "SELECT * FROM turma ORDER BY sigla");
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Editar Aluno</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        /* Igual aos outros */
        body { font-family: 'Segoe UI', sans-serif; background-color: #e6f2ff; padding: 20px; display: flex; justify-content: center; }
        .card { background: white; padding: 40px; border-radius: 30px; border: 3px solid #0056b3; width: 500px; }
        h1 { color: #0056b3; text-align: center; }
        input, select { width: 100%; padding: 10px; margin-bottom: 15px; border: 2px solid #0056b3; border-radius: 20px; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background: #0056b3; color: white; border: none; border-radius: 20px; font-weight: bold; cursor: pointer; }
        button:hover { background: #004494; }
        .sucesso { color: green; text-align: center; margin-bottom: 10px; }
        .erro { color: red; text-align: center; margin-bottom: 10px; background: #f8d7da; padding: 10px; border-radius: 10px; }
        label { display: block; margin-bottom: 5px; color: #003366; font-weight: bold; }
        .btn-back { display: block; text-align: center; margin-top: 15px; color: #0056b3; text-decoration: none; }
        .btn-back:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="card">
        <h1>Editar Aluno (ID: <?php echo $id_aluno; ?>)</h1>
        <?php echo $mensagem; ?>
        
        <form method="POST">
            <label>Nome:</label>
            <input type="text" name="nome" value="<?php echo htmlspecialchars($aluno['nome']); ?>" required>

            <label>Login:</label>
            <input type="text" name="login" value="<?php echo htmlspecialchars($aluno['login']); ?>" required>

            <label>Password (Deixar em branco para não mudar):</label>
            <input type="text" name="password" placeholder="Nova senha...">

            <label>Nº Aluno:</label>
            <input type="number" name="numero" value="<?php echo htmlspecialchars($aluno['numero']); ?>" required>

            <label>Turma:</label>
            <select name="turma_id">
                <?php while ($t = mysqli_fetch_assoc($turmas)): ?>
                    <option value="<?php echo $t['turma_id']; ?>" <?php if($t['turma_id'] == $aluno['turma_id']) echo 'selected'; ?>>
                        <?php echo htmlspecialchars($t['sigla']); ?>
                    </option>
                <?php endwhile; ?>
            </select>

            <button type="submit">Guardar Alterações</button>
        </form>
        <br>
        <a href="gerir_alunos.php" class="btn-back">Cancelar</a>
    </div>
</body>
</html>