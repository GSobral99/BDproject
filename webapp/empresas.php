<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['tipo'] != 'aluno') {
    header("Location: index.php");
    exit;
}
require 'db.php';

$where_clauses = [];
$types = ""; 
$params = []; 

if (!empty($_GET['filtro_local'])) {
    $where_clauses[] = "localidade = ?";
    $types .= "s";
    $params[] = $_GET['filtro_local'];
}

if (!empty($_GET['filtro_tipo'])) {
    $where_clauses[] = "tipo_organizacao = ?";
    $types .= "s";
    $params[] = $_GET['filtro_tipo'];
}

$sql = "SELECT firma, tipo_organizacao, localidade, telefone, website FROM empresa";

if (count($where_clauses) > 0) {
    $sql .= " WHERE " . implode(" AND ", $where_clauses);
}

if (count($params) > 0) {
    $stmt = mysqli_prepare($conn, $sql);

    $bind_params = [$types];
    foreach ($params as $key => $value) {
        $bind_params[] = &$params[$key];
    }
    call_user_func_array([$stmt, 'bind_param'], $bind_params);
    
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
} else {
    $result = mysqli_query($conn, $sql);
}

$lista_locais = mysqli_query($conn, "SELECT DISTINCT localidade FROM empresa ORDER BY localidade");
$lista_tipos = mysqli_query($conn, "SELECT DISTINCT tipo_organizacao FROM empresa ORDER BY tipo_organizacao");
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Portal do Aluno - Empresas</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #e6f2ff;
            padding: 20px;
        }

        /* --- MENU SUPERIOR --- */
        .nav-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            background: white;
            padding: 15px 20px;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 86, 179, 0.1);
            border-bottom: 3px solid #0056b3;
        }

        h1 { margin: 0; color: #0056b3; font-size: 24px; }

        .btn-nav {
            text-decoration: none; padding: 10px 20px; border-radius: 5px;
            font-weight: bold; color: white; transition: opacity 0.3s;
        }
        .btn-sair { background-color: #dc3545; }
        .btn-estagios { background-color: #0056b3; }
        .btn-nav:hover { opacity: 0.9; }

        /* --- BARRA DE FILTROS --- */
        .filter-bar {
            background: white;
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 30px;
            border: 2px solid #b3cce6;
            display: flex;
            gap: 15px;
            align-items: flex-end;
            flex-wrap: wrap;
        }

        .filter-group { display: flex; flex-direction: column; flex: 1; min-width: 200px; }
        .filter-group label { color: #003366; font-weight: bold; font-size: 13px; margin-bottom: 5px; margin-left: 5px; }
        
        select {
            padding: 10px 15px;
            border: 2px solid #0056b3;
            border-radius: 50px;
            background: white;
            color: #333;
            outline: none;
            cursor: pointer;
        }

        .btn-filtrar {
            background-color: #0056b3; color: white; border: none;
            padding: 10px 25px; border-radius: 50px; font-weight: bold; cursor: pointer;
            height: 42px;
        }
        
        .btn-limpar {
            background-color: white; color: #666; border: 2px solid #ccc;
            padding: 10px 20px; border-radius: 50px; font-weight: bold; text-decoration: none;
            height: 18px; line-height: 18px;
        }
        .btn-filtrar:hover { background-color: #004494; }
        .btn-limpar:hover { background-color: #eee; color: #333; }

        /* --- TABELA --- */
        table {
            width: 100%; border-collapse: separate; border-spacing: 0;
            background: white; border-radius: 10px; overflow: hidden;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        th { background-color: #0056b3; color: white; text-transform: uppercase; font-size: 14px; }
        tr:hover { background-color: #f0f8ff; }
        a.web-link { color: #0056b3; text-decoration: none; font-weight: bold; }
        a.web-link:hover { text-decoration: underline; }

        .titulo-seccao { color: #666; margin-bottom: 10px; font-size: 18px; border-left: 5px solid #0056b3; padding-left: 10px; }
    </style>
</head>
<body>

    <div class="nav-bar">
        <a href="index.php" class="btn-nav btn-sair"><i class="fas fa-sign-out-alt"></i> Sair</a>
        <h1>Portal do Aluno</h1>
        <a href="meus_estagios.php" class="btn-nav btn-estagios"><i class="fas fa-briefcase"></i> Meus Estágios</a>
    </div>

    <h2 class="titulo-seccao">Empresas com Disponibilidade</h2>

    <form method="GET" class="filter-bar">
        
        <div class="filter-group">
            <label><i class="fas fa-map-marker-alt"></i> Filtrar por Localidade</label>
            <select name="filtro_local">
                <option value="">-- Todas --</option>
                <?php while ($loc = mysqli_fetch_assoc($lista_locais)): ?>
                    <option value="<?php echo $loc['localidade']; ?>"
                        <?php if(isset($_GET['filtro_local']) && $_GET['filtro_local'] == $loc['localidade']) echo 'selected'; ?>>
                        <?php echo htmlspecialchars($loc['localidade']); ?>
                    </option>
                <?php endwhile; ?>
            </select>
        </div>

        <div class="filter-group">
            <label><i class="fas fa-industry"></i> Filtrar por Ramo/Tipo</label>
            <select name="filtro_tipo">
                <option value="">-- Todos --</option>
                <?php while ($tipo = mysqli_fetch_assoc($lista_tipos)): ?>
                    <option value="<?php echo $tipo['tipo_organizacao']; ?>"
                        <?php if(isset($_GET['filtro_tipo']) && $_GET['filtro_tipo'] == $tipo['tipo_organizacao']) echo 'selected'; ?>>
                        <?php echo htmlspecialchars($tipo['tipo_organizacao']); ?>
                    </option>
                <?php endwhile; ?>
            </select>
        </div>

        <button type="submit" class="btn-filtrar"><i class="fas fa-search"></i> Pesquisar</button>
        
        <?php if(!empty($_GET['filtro_local']) || !empty($_GET['filtro_tipo'])): ?>
            <a href="empresas.php" class="btn-limpar">Limpar Filtros</a>
        <?php endif; ?>

    </form>

    <table>
        <thead>
            <tr>
                <th>Nome da Empresa</th>
                <th>Ramo / Tipo</th>
                <th>Localidade</th>
                <th>Telefone</th>
                <th>Website</th>
            </tr>
        </thead>
        <tbody>
            <?php if (mysqli_num_rows($result) == 0): ?>
                <tr>
                    <td colspan="5" style="text-align: center; color: #777; padding: 30px;">
                        <i class="fas fa-search"></i> Nenhuma empresa encontrada com esses filtros.
                    </td>
                </tr>
            <?php else: ?>
                <?php while ($row = mysqli_fetch_assoc($result)): ?>
                <tr>
                    <td><strong><?php echo htmlspecialchars($row['firma']); ?></strong></td>
                    <td><?php echo htmlspecialchars($row['tipo_organizacao']); ?></td>
                    <td><i class="fas fa-map-marker-alt" style="color:#aaa"></i> <?php echo htmlspecialchars($row['localidade']); ?></td>
                    <td><?php echo htmlspecialchars($row['telefone']); ?></td>
                    <td>
                        <?php if($row['website']): ?>
                            <a href="<?php echo htmlspecialchars($row['website']); ?>" target="_blank" class="web-link">
                                Visitar <i class="fas fa-external-link-alt" style="font-size:12px"></i>
                            </a>
                        <?php else: ?>
                            <span style="color:#ccc">-</span>
                        <?php endif; ?>
                    </td>
                </tr>
                <?php endwhile; ?>
            <?php endif; ?>
        </tbody>
    </table>

</body>
</html>