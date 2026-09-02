<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['tipo'] != 'administrativo') {
    header("Location: index.php");
    exit;
}
require 'db.php';

$mensagem = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $nome = $_POST['nome'];
    $login = $_POST['login'];
    $pass = $_POST['password'];
    $turma_id = $_POST['turma_id'];
    $numero_aluno = $_POST['numero'];

    $sql_user = "INSERT INTO utilizador (login, password, nome, tipo) VALUES (?, ?, ?, 'aluno')";
    $stmt = mysqli_prepare($conn, $sql_user);
    
    mysqli_stmt_bind_param($stmt, "sss", $login, $pass, $nome);
    
    if (mysqli_stmt_execute($stmt)) {
        $novo_id = mysqli_insert_id($conn);

        $sql_aluno = "INSERT INTO aluno (turma_id, utilizador_id, numero) VALUES (?, ?, ?)";
        $stmt2 = mysqli_prepare($conn, $sql_aluno);
        
        mysqli_stmt_bind_param($stmt2, "iii", $turma_id, $novo_id, $numero_aluno);
        
        if (mysqli_stmt_execute($stmt2)) {
            $_SESSION['msg_sucesso'] = "<div class='sucesso'>Aluno $nome criado com sucesso (ID: $novo_id)!</div>";
            header("Location: gerir_alunos.php");
            exit;
        }
        
        mysqli_stmt_close($stmt2);
    } else {
        if (mysqli_errno($conn) == 1062) {
            $mensagem = "<div class='erro'>O Login '$login' já está a ser usado.</div>";
        } else {
            $mensagem = "<div class='erro'>Erro: " . mysqli_error($conn) . "</div>";
        }
    }
    
    mysqli_stmt_close($stmt);
}

$turmas = mysqli_query($conn, "SELECT turma_id, sigla FROM turma ORDER BY sigla");
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Registar Aluno</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        /* TEMA TECH BLUE */
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
            max-width: 500px;
        }

        /* CARTÃO DO FORMULÁRIO */
        .form-card {
            background: white;
            padding: 40px;
            border-radius: 30px;
            border: 3px solid #0056b3;
            box-shadow: 0 10px 25px rgba(0, 86, 179, 0.15);
        }

        /* CABEÇALHO */
        .header-title {
            text-align: center;
            color: #0056b3;
            margin-bottom: 30px;
        }
        .header-title i { font-size: 50px; margin-bottom: 10px; display: block; }
        .header-title h1 { margin: 0; font-size: 28px; text-transform: uppercase; }

        /* INPUTS E LABELS */
        .input-group { margin-bottom: 15px; }

        label {
            display: block;
            margin-bottom: 8px;
            color: #003366;
            font-weight: bold;
            font-size: 14px;
        }

        input, select {
            width: 100%;
            padding: 12px 20px;
            border: 2px solid #0056b3;
            border-radius: 50px;
            background-color: white;
            font-size: 15px;
            color: #333;
            outline: none;
            box-sizing: border-box;
        }

        input:focus, select:focus {
            box-shadow: 0 0 8px rgba(0, 86, 179, 0.4);
            background-color: #f0f8ff;
        }

        /* BOTÃO SUBMETER */
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
            margin-top: 10px;
        }

        .btn-submit:hover { background-color: #004494; }

        /* BOTÃO VOLTAR */
        .btn-back {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #0056b3;
            text-decoration: none;
            font-weight: bold;
        }
        .btn-back:hover { text-decoration: underline; }

        /* MENSAGENS */
        .sucesso { background-color: #d4edda; color: #155724; padding: 15px; border-radius: 15px; margin-bottom: 20px; border: 1px solid #c3e6cb; text-align: center;}
        .erro { background-color: #f8d7da; color: #721c24; padding: 15px; border-radius: 15px; margin-bottom: 20px; border: 1px solid #f5c6cb; text-align: center;}

        /* SEPARADOR */
        hr { border: 0; border-top: 1px dashed #b3cce6; margin: 25px 0; }

    </style>
</head>
<body>

    <div class="main-container">
        
        <div class="form-card">
            
            <div class="header-title">
                <i class="fas fa-user-plus"></i>
                <h1>Novo Aluno</h1>
            </div>

            <?php echo $mensagem; ?>

            <form method="POST">
                
                <div class="input-group">
                    <label><i class="fas fa-user"></i> Nome Completo</label>
                    <input type="text" name="nome" required placeholder="Nome do aluno">
                </div>

                <div class="input-group">
                    <label><i class="fas fa-at"></i> Login</label>
                    <input type="text" name="login" required placeholder="Ex: joao.silva">
                </div>

                <div class="input-group">
                    <label><i class="fas fa-lock"></i> Password</label>
                    <input type="password" name="password" required placeholder="Senha de acesso">
                </div>

                <hr>

                <div class="input-group">
                    <label><i class="fas fa-users"></i> Turma</label>
                    <select name="turma_id" required>
                        <option value="">-- Selecione a turma --</option>
                        <?php while ($t = mysqli_fetch_assoc($turmas)): ?>
                            <option value="<?php echo $t['turma_id']; ?>">
                                <?php echo htmlspecialchars($t['sigla']); ?>
                            </option>
                        <?php endwhile; ?>
                    </select>
                </div>

                <div class="input-group">
                    <label><i class="fas fa-sort-numeric-down"></i> Número de Aluno</label>
                    <input type="number" name="numero" required placeholder="Nº de aluno">
                </div>

                <button type="submit" class="btn-submit">
                    Criar Aluno
                </button>

            </form>

            <a href="gerir_alunos.php" class="btn-back">
                <i class="fas fa-arrow-left"></i> Voltar à Lista de Alunos
            </a>

        </div>

    </div>

</body>
</html>