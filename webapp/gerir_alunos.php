<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['tipo'] != 'administrativo') {
    header("Location: index.php");
    exit;
}
require 'db.php';

$mensagem = "";
$modo_apagar = isset($_GET['modo']) && $_GET['modo'] == 'apagar';

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['ids_para_apagar'])) {
    $ids = $_POST['ids_para_apagar'];
    
    if (count($ids) > 0) {
        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        $types = str_repeat('i', count($ids));
        
        $sql = "DELETE FROM utilizador WHERE utilizador_id IN ($placeholders)";
        $stmt = mysqli_prepare($conn, $sql);
        
        $bind_params = [$types];
        foreach ($ids as $key => $value) {
            $bind_params[] = &$ids[$key];
        }
        call_user_func_array([$stmt, 'bind_param'], $bind_params);
        
        if (mysqli_stmt_execute($stmt)) {
            $mensagem = "<div class='sucesso'><i class='fas fa-check-circle'></i> Alunos apagados com sucesso!</div>";
        } else {
            $mensagem = "<div class='erro'><i class='fas fa-exclamation-triangle'></i> Erro: Alunos com estágios não podem ser apagados.</div>";
        }
        
        mysqli_stmt_close($stmt);
    }
}

$sql = "SELECT u.utilizador_id, u.nome, u.login, a.numero, t.sigla as turma
        FROM aluno a
        JOIN utilizador u ON a.utilizador_id = u.utilizador_id
        JOIN turma t ON a.turma_id = t.turma_id
        ORDER BY u.nome";

$result = mysqli_query($conn, $sql);
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Gerir Alunos</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #e6f2ff; padding: 20px; }
        
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 30px; border-radius: 20px; border: 3px solid #0056b3; }
        
        h1 { color: #0056b3; text-align: center; }
        
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { background: #0056b3; color: white; padding: 12px; text-align: left; }
        td { padding: 12px; border-bottom: 1px solid #eee; color: #333; }
        tr:hover { background-color: #f0f8ff; }

        .btn-edit { color: #0056b3; font-size: 18px; margin-right: 10px; cursor: pointer; text-decoration: none; }
        .btn-edit:hover { color: #003366; }

        .acoes-bottom { display: flex; justify-content: space-between; margin-top: 20px; padding-top: 20px; border-top: 2px dashed #b3cce6; }

        .btn-add { background: #28a745; color: white; padding: 10px 20px; border-radius: 50px; text-decoration: none; font-weight: bold; }
        .btn-delete-mode { background: #dc3545; color: white; padding: 10px 20px; border-radius: 50px; text-decoration: none; font-weight: bold; }
        .btn-cancel { background: #6c757d; color: white; padding: 10px 20px; border-radius: 50px; text-decoration: none; font-weight: bold; }
        .btn-confirm-delete { background: #a71d2a; color: white; padding: 10px 20px; border-radius: 50px; border: none; font-weight: bold; cursor: pointer; }
        
        .btn-back { display: block; text-align: center; margin-top: 20px; color: #0056b3; text-decoration: none; font-weight: bold; }

        .check-apagar { transform: scale(1.5); margin-right: 10px; cursor: pointer; }
        
        .sucesso { background: #d4edda; color: #155724; padding: 15px; border-radius: 10px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        .erro { background: #f8d7da; color: #721c24; padding: 15px; border-radius: 10px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
    </style>
</head>
<body>

<div class="container">
    <h1><i class="fas fa-users-cog"></i> Gestão de Alunos</h1>
    
    <?php if (!empty($mensagem)) echo $mensagem; ?>
    
    <?php if(isset($_SESSION['msg_sucesso'])): ?>
        <div class='sucesso'><?php echo $_SESSION['msg_sucesso']; ?></div>
        <?php unset($_SESSION['msg_sucesso']); ?>
    <?php endif; ?>

    <form method="POST" id="formApagar">
        
        <table>
            <thead>
                <tr>
                    <?php if ($modo_apagar): ?>
                        <th style="width: 50px;"><i class="fas fa-check-square"></i></th>
                    <?php else: ?>
                        <th style="width: 50px;">#</th>
                    <?php endif; ?>
                    <th>Nome</th>
                    <th>Nº Aluno</th>
                    <th>Turma</th>
                    <th>Login</th>
                </tr>
            </thead>
            <tbody>
                <?php while ($row = mysqli_fetch_assoc($result)): ?>
                <tr>
                    <td>
                        <?php if ($modo_apagar): ?>
                            <input type="checkbox" name="ids_para_apagar[]" value="<?php echo $row['utilizador_id']; ?>" class="check-apagar">
                        <?php else: ?>
                            <a href="editar_aluno.php?id=<?php echo $row['utilizador_id']; ?>" class="btn-edit" title="Editar">
                                <i class="fas fa-pencil-alt"></i>
                            </a>
                        <?php endif; ?>
                    </td>
                    <td><?php echo htmlspecialchars($row['nome']); ?></td>
                    <td><?php echo htmlspecialchars($row['numero']); ?></td>
                    <td><?php echo htmlspecialchars($row['turma']); ?></td>
                    <td><?php echo htmlspecialchars($row['login']); ?></td>
                </tr>
                <?php endwhile; ?>
            </tbody>
        </table>

        <div class="acoes-bottom">
            <a href="registar_aluno.php" class="btn-add">
                <i class="fas fa-plus"></i> Adicionar Novo Aluno
            </a>

            <div>
                <?php if ($modo_apagar): ?>
                    <a href="gerir_alunos.php" class="btn-cancel">
                        <i class="fas fa-times"></i> Cancelar
                    </a>
                    <button type="submit" class="btn-confirm-delete" onclick="return confirm('Tem a certeza? Isto é irreversível!')">
                        <i class="fas fa-check"></i> Confirmar Eliminação
                    </button>
                <?php else: ?>
                    <a href="gerir_alunos.php?modo=apagar" class="btn-delete-mode">
                        <i class="fas fa-trash"></i> Apagar Alunos
                    </a>
                <?php endif; ?>
            </div>
        </div>
    
    </form>

    <a href="dashboard_admin.php" class="btn-back">Voltar ao Painel</a>
</div>

</body>
</html>