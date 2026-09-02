<?php
session_start();
require 'db.php';

$erro = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $login = $_POST['login'];
    $password = $_POST['password'];

    $stmt = mysqli_prepare($conn, "SELECT * FROM utilizador WHERE login = ? AND password = ?");

    mysqli_stmt_bind_param($stmt, "ss", $login, $password);

    mysqli_stmt_execute($stmt);
    
    $result = mysqli_stmt_get_result($stmt);
    $user = mysqli_fetch_assoc($result);

    if ($user) {
        $_SESSION['user_id'] = $user['utilizador_id'];
        $_SESSION['nome'] = $user['nome'];
        $_SESSION['tipo'] = $user['tipo'];

        if ($user['tipo'] == 'aluno') {
            header("Location: empresas.php");
        } elseif ($user['tipo'] == 'formador') {
            header("Location: atribuir_notas.php");
        } elseif ($user['tipo'] == 'administrativo') {
            header("Location: dashboard_admin.php");
        }
        exit;
    } else {
        $erro = "Login ou Password incorretos!";
    }
    mysqli_stmt_close($stmt);
}
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Bem Vindo - SIESTÁGIOS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #e6f2ff;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
            position: relative;
        }
        
        .login-card {
            background: white;
            padding: 50px 60px;
            border: 3px solid #0056b3;
            border-radius: 30px;
            width: 350px;
            text-align: center;
            box-shadow: 0 10px 25px rgba(0, 86, 179, 0.15);
            z-index: 2;
            margin-bottom: 30px;
        }

        h2 {
            color: #0056b3;
            margin-bottom: 40px;
            font-size: 45px;
            font-weight: bold;
            margin-top: 0;
        }
        
        .input-wrapper {
            position: relative;
            width: 100%;
            margin-bottom: 25px;
        }

        input {
            width: 100%;
            padding: 15px 25px;
            padding-right: 45px;
            border: 2px solid #0056b3;
            border-radius: 50px;
            box-sizing: border-box;
            font-size: 16px;
            outline: none;
            background-color: white;
            color: #003366;
            transition: box-shadow 0.3s ease;
        }
        
        input:focus { box-shadow: 0 0 8px rgba(0, 86, 179, 0.4); }

        ::placeholder { color: #8daec4; opacity: 1; }
        :-ms-input-placeholder { color: #8daec4; }
        ::-ms-input-placeholder { color: #8daec4; }

        .input-icon {
            position: absolute;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
            color: #0056b3;
            font-size: 18px;
        }

        button {
            background-color: #0056b3;
            color: white;
            border: none;
            padding: 15px 50px;
            font-size: 16px;
            font-weight: bold;
            text-transform: uppercase;
            margin-top: 15px;
            cursor: pointer;
            border-radius: 50px;
            transition: background-color 0.3s;
            width: 100%;
        }

        button:hover { background-color: #004494; }
        .error { color: #dc3545; font-weight: bold; margin-bottom: 15px; font-size: 14px; }

        .credentials-box {
            background-color: white;
            width: 350px;
            border-radius: 20px;
            border: 2px solid #0056b3;
            padding: 20px;
            box-shadow: 0 5px 15px rgba(0, 86, 179, 0.1);
            margin-bottom: 30px;
        }

        .credentials-box h3 {
            color: #0056b3;
            margin-top: 0;
            font-size: 16px;
            text-transform: uppercase;
            border-bottom: 1px solid #e6f2ff;
            padding-bottom: 10px;
        }

        .cred-item {
            margin-bottom: 10px;
            font-size: 14px;
            color: #003366;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .cred-item i {
            width: 20px;
            text-align: center;
        }
        
        .cred-code {
            background-color: #e6f2ff;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: monospace;
            font-weight: bold;
        }

        .footer-credits {
            position: fixed;
            bottom: 20px;
            left: 20px;
            text-align: left;
            font-size: 12px;
            color: #5c85ad;
            line-height: 1.5;
            z-index: 0;
        }
        
        .footer-credits strong {
            font-weight: bold;
            display: block;
            margin-bottom: 5px;
            color: #4a6fa5;
        }

    </style>
</head>
<body>

    <div class="login-card">
        <h2>Bem Vindo</h2>
        
        <?php if($erro): ?>
            <div class="error"><?php echo $erro; ?></div>
        <?php endif; ?>

        <form method="POST">
            <div class="input-wrapper">
                <input type="text" name="login" required placeholder="user">
                <i class="far fa-user input-icon"></i>
            </div>
            
            <div class="input-wrapper">
                <input type="password" name="password" required placeholder="password">
                <i class="fas fa-lock input-icon"></i>
            </div>
            
            <button type="submit">ENTRAR</button>
        </form>
    </div>

    <div class="credentials-box">
        <h3><i class="fas fa-terminal"></i> Para testar:</h3>
        <div class="cred-item">
            <i class="fas fa-user-graduate"></i>
            <span>Aluno: <span class="cred-code">joao.silva</span> / <span class="cred-code">pass123</span></span>
        </div>
        <div class="cred-item">
            <i class="fas fa-chalkboard-teacher"></i>
            <span>Formador: <span class="cred-code">ana.mendes</span> / <span class="cred-code">pass123</span></span>
        </div>
        <div class="cred-item">
            <i class="fas fa-cogs"></i>
            <span>Admin: <span class="cred-code">helena.alves</span> / <span class="cred-code">pass123</span></span>
        </div>
    </div>

    <div class="footer-credits">
        <strong>Projeto Base de Dados - Parte 2</strong>
        Gonçalo Sobral - nº129850<br>
        Daniel Masqueiro - nº129853<br>
        Rafael Silva - nº129834
    </div>

</body>
</html>