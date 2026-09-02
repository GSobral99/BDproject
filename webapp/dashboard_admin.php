<?php
session_start();
// Verificar se é admin
if (!isset($_SESSION['user_id']) || $_SESSION['tipo'] != 'administrativo') {
    header("Location: index.php");
    exit;
}
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Painel do Administrador</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        /*FUNDO GERAL (Igual ao Login) */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #e6f2ff;
            text-align: center;
            padding: 40px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        /*CABEÇALHO */
        h1 {
            color: #0056b3;
            font-size: 36px;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        p.welcome {
            color: #5c85ad;
            font-size: 18px;
            margin-bottom: 50px;
        }

        /*CONTENTOR DOS CARTÕES (Lado a Lado) */
        .container {
            display: flex;
            justify-content: center;
            gap: 40px;
            flex-wrap: wrap; /* Para telemóveis */
            max-width: 1000px;
        }

        /*OS CARTÕES DE OPÇÃO */
        .option-card {
            background: white;
            padding: 40px 30px;
            border-radius: 30px;
            
            /* Borda Azul */
            border: 3px solid #0056b3;
            box-shadow: 0 10px 25px rgba(0, 86, 179, 0.15);
            
            width: 280px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        /* Efeito ao passar o rato (Sobe e Brilha) */
        .option-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 35px rgba(0, 86, 179, 0.25);
            background-color: #f0f8ff;
        }

        /* ÍCONES GRANDES */
        .big-icon {
            font-size: 80px;
            color: #0056b3;
            margin-bottom: 30px;
            transition: transform 0.3s;
        }
        
        /* O ícone roda um pouco no hover */
        .option-card:hover .big-icon {
            transform: scale(1.1);
        }

        /* TÍTULOS E TEXTO */
        h2 {
            color: #003366;
            font-size: 24px;
            margin: 0 0 10px 0;
        }

        p.desc {
            color: #777;
            font-size: 14px;
            margin-bottom: 30px;
            line-height: 1.5;
        }

        /* BOTÕES DENTRO DOS CARTÕES */
        .btn-action {
            background-color: #0056b3;
            color: white;
            padding: 12px 30px;
            border-radius: 50px;
            font-weight: bold;
            text-transform: uppercase;
            border: none;
            transition: background 0.3s;
        }

        .option-card:hover .btn-action {
            background-color: #004494;
        }

        /* BOTÃO DE SAIR (FUNDO DA PÁGINA) */
        .btn-sair {
            margin-top: 60px;
            color: #dc3545;
            text-decoration: none;
            font-weight: bold;
            border: 2px solid #dc3545;
            padding: 10px 25px;
            border-radius: 50px;
            transition: all 0.3s;
        }

        .btn-sair:hover {
            background-color: #dc3545;
            color: white;
        }

    </style>
</head>
<body>

    <h1>Painel de Gestão</h1>
    <p class="welcome">Olá, <strong><?php echo htmlspecialchars($_SESSION['nome']); ?></strong> (Administrador)</p>

    <div class="container">
        
        <a href="gerir_alunos.php" class="option-card">
            <i class="fas fa-user-graduate big-icon"></i>
            
            <h2>Editar Lista de Alunos</h2>
            <p class="desc">Editar, adicionar ou apagar utilizadores e associá-los a turmas para acesso à plataforma.</p>

            <span class="btn-action">Aceder</span>
        </a>

        <a href="gerir_estagios.php" class="option-card">
            <i class="fas fa-briefcase big-icon"></i>
            
            <h2>Gerir Estágios</h2>
            <p class="desc">Adicionar, consultar, editar e apagar estágios. Estágios finalizados não podem ser alterados.</p>
            
            <span class="btn-action">Aceder</span>
        </a>

        <a href="estatisticas.php" class="option-card">
            <i class="fas fa-chart-bar big-icon"></i>
            
            <h2>Ver Estatísticas</h2>
            <p class="desc">Consultar métricas, médias de notas e relatórios de gestão (Q1-Q6).</p>
            
        <span class="btn-action">Visualizar</span>
        </a>

    </div>

    <a href="index.php" class="btn-sair">
        <i class="fas fa-sign-out-alt"></i> Terminar Sessão
    </a>

</body>
</html>