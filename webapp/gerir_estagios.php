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
        $sucesso = true;
        
        foreach($ids as $id_combinado) {
            $partes = explode('|', $id_combinado);
            $aluno_id = $partes[0];
            $empresa_id = $partes[1];
            $estabelecimento_id = $partes[2];
            
            $sql_check = "SELECT nota_final FROM estagio WHERE aluno_id = ? AND estabelecimento_empresa_id = ? AND estabelecimento_id = ?";
            $stmt_check = mysqli_prepare($conn, $sql_check);
            mysqli_stmt_bind_param($stmt_check, "iii", $aluno_id, $empresa_id, $estabelecimento_id);
            mysqli_stmt_execute($stmt_check);
            $result_check = mysqli_stmt_get_result($stmt_check);
            $estagio = mysqli_fetch_assoc($result_check);
            mysqli_stmt_close($stmt_check);
            
            if ($estagio && $estagio['nota_final'] !== null) {
                $mensagem = "<div class='erro'><i class='fas fa-exclamation-triangle'></i> Erro: Não é possível apagar estágios já finalizados!</div>";
                $sucesso = false;
                break;
            }
            
            $sql_delete = "DELETE FROM estagio WHERE aluno_id = ? AND estabelecimento_empresa_id = ? AND estabelecimento_id = ?";
            $stmt_delete = mysqli_prepare($conn, $sql_delete);
            mysqli_stmt_bind_param($stmt_delete, "iii", $aluno_id, $empresa_id, $estabelecimento_id);
            
            if (!mysqli_stmt_execute($stmt_delete)) {
                $mensagem = "<div class='erro'><i class='fas fa-exclamation-triangle'></i> Erro ao apagar estágio.</div>";
                $sucesso = false;
                mysqli_stmt_close($stmt_delete);
                break;
            }
            mysqli_stmt_close($stmt_delete);
        }
        
        if ($sucesso && empty($mensagem)) {
            $mensagem = "<div class='sucesso'><i class='fas fa-check-circle'></i> Estágio(s) apagado(s) com sucesso!</div>";
        }
    }
}

$sql = "SELECT 
    e.aluno_id, 
    e.estabelecimento_empresa_id, 
    e.estabelecimento_id,
    e.data_inicio, 
    e.data_fim, 
    e.nota_final,
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
ORDER BY e.data_inicio DESC, u_aluno.nome";

$result = mysqli_query($conn, $sql);
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Gerir Estágios</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #e6f2ff; padding: 20px; }
        
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 20px; border: 3px solid #0056b3; }
        
        h1 { color: #0056b3; text-align: center; margin-bottom: 30px; }
        
        .table-wrapper { overflow-x: auto; }
        
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        
        th { background: #0056b3; color: white; padding: 12px 8px; text-align: left; font-size: 13px; position: sticky; top: 0; }
        
        td { padding: 12px 8px; border-bottom: 1px solid #eee; color: #333; font-size: 14px; }
        
        tr:hover { background-color: #f0f8ff; }

        .btn-edit { color: #0056b3; font-size: 18px; margin-right: 10px; cursor: pointer; text-decoration: none; }
        .btn-edit:hover { color: #003366; }
        
        .btn-edit.disabled { color: #ccc; cursor: not-allowed; opacity: 0.5; }

        .acoes-bottom { display: flex; justify-content: space-between; margin-top: 20px; padding-top: 20px; border-top: 2px dashed #b3cce6; flex-wrap: wrap; gap: 10px; }

        .btn-add { background: #28a745; color: white; padding: 10px 20px; border-radius: 50px; text-decoration: none; font-weight: bold; display: inline-flex; align-items: center; gap: 8px; }
        .btn-add:hover { background: #218838; }
        
        .btn-delete-mode { background: #dc3545; color: white; padding: 10px 20px; border-radius: 50px; text-decoration: none; font-weight: bold; }
        .btn-delete-mode:hover { background: #c82333; }
        
        .btn-cancel { background: #6c757d; color: white; padding: 10px 20px; border-radius: 50px; text-decoration: none; font-weight: bold; }
        
        .btn-confirm-delete { background: #a71d2a; color: white; padding: 10px 20px; border-radius: 50px; border: none; font-weight: bold; cursor: pointer; }
        
        .btn-back { display: block; text-align: center; margin-top: 20px; color: #0056b3; text-decoration: none; font-weight: bold; }

        .check-apagar { transform: scale(1.5); margin-right: 10px; cursor: pointer; }
        
        .badge { display: inline-block; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; }
        
        .badge-ativo { background: #fff3cd; color: #856404; }
        
        .badge-finalizado { background: #d4edda; color: #155724; }
        
        .sucesso { background: #d4edda; color: #155724; padding: 15px; border-radius: 10px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        
        .erro { background: #f8d7da; color: #721c24; padding: 15px; border-radius: 10px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        
        .tooltip { position: relative; display: inline-block; }
        
        .tooltip .tooltiptext { visibility: hidden; width: 200px; background-color: #555; color: #fff; text-align: center; border-radius: 6px; padding: 5px; position: absolute; z-index: 1; bottom: 125%; left: 50%; margin-left: -100px; opacity: 0; transition: opacity 0.3s; font-size: 12px; }
        
        .tooltip:hover .tooltiptext { visibility: visible; opacity: 1; }
    </style>
</head>
<body>

<div class="container">
    <h1><i class="fas fa-briefcase"></i> Gestão de Estágios</h1>
    
    <?php if (!empty($mensagem)) echo $mensagem; ?>
    
    <?php if(isset($_SESSION['msg_sucesso'])): ?>
        <div class='sucesso'><?php echo $_SESSION['msg_sucesso']; ?></div>
        <?php unset($_SESSION['msg_sucesso']); ?>
    <?php endif; ?>

    <form method="POST" id="formApagar">
        
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <?php if ($modo_apagar): ?>
                            <th style="width: 60px;"><i class="fas fa-check-square"></i></th>
                        <?php else: ?>
                            <th style="width: 60px;">#</th>
                        <?php endif; ?>
                        <th>Aluno</th>
                        <th>Empresa</th>
                        <th>Estabelecimento</th>
                        <th>Formador</th>
                        <th>Data Início</th>
                        <th>Data Fim</th>
                        <th>Estado</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if(mysqli_num_rows($result) == 0): ?>
                        <tr>
                            <td colspan="8" style="text-align: center; color: #777; padding: 30px;">
                                <i class="fas fa-inbox"></i> Não existem estágios registados.
                            </td>
                        </tr>
                    <?php else: ?>
                        <?php while ($row = mysqli_fetch_assoc($result)): ?>
                        <?php 
                            $estagio_finalizado = ($row['nota_final'] !== null);
                            $id_estagio = $row['aluno_id'].'|'.$row['estabelecimento_empresa_id'].'|'.$row['estabelecimento_id'];
                        ?>
                        <tr>
                            <td>
                                <?php if ($modo_apagar): ?>
                                    <?php if (!$estagio_finalizado): ?>
                                        <input type="checkbox" name="ids_para_apagar[]" value="<?php echo $id_estagio; ?>" class="check-apagar">
                                    <?php else: ?>
                                        <span class="tooltip">
                                            <i class="fas fa-lock" style="color: #ccc;"></i>
                                            <span class="tooltiptext">Estágio finalizado não pode ser apagado</span>
                                        </span>
                                    <?php endif; ?>
                                <?php else: ?>
                                    <?php if (!$estagio_finalizado): ?>
                                        <a href="editar_estagio.php?aluno=<?php echo $row['aluno_id']; ?>&empresa=<?php echo $row['estabelecimento_empresa_id']; ?>&estab=<?php echo $row['estabelecimento_id']; ?>" 
                                           class="btn-edit" 
                                           title="Editar">
                                            <i class="fas fa-pencil-alt"></i>
                                        </a>
                                    <?php else: ?>
                                        <span class="btn-edit disabled tooltip">
                                            <i class="fas fa-lock"></i>
                                            <span class="tooltiptext">Estágio finalizado não pode ser editado</span>
                                        </span>
                                    <?php endif; ?>
                                <?php endif; ?>
                            </td>
                            <td><?php echo htmlspecialchars($row['nome_aluno']); ?></td>
                            <td><?php echo htmlspecialchars($row['nome_empresa']); ?></td>
                            <td><?php echo htmlspecialchars($row['nome_estabelecimento']); ?></td>
                            <td><?php echo htmlspecialchars($row['nome_formador']); ?></td>
                            <td><?php echo date('d/m/Y', strtotime($row['data_inicio'])); ?></td>
                            <td><?php echo date('d/m/Y', strtotime($row['data_fim'])); ?></td>
                            <td>
                                <?php if ($estagio_finalizado): ?>
                                    <span class="badge badge-finalizado">
                                        <i class="fas fa-check"></i> Finalizado (<?php echo $row['nota_final']; ?>)
                                    </span>
                                <?php else: ?>
                                    <span class="badge badge-ativo">
                                        <i class="fas fa-hourglass-half"></i> Ativo
                                    </span>
                                <?php endif; ?>
                            </td>
                        </tr>
                        <?php endwhile; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>

        <div class="acoes-bottom">
            <a href="registar_estagio.php" class="btn-add">
                <i class="fas fa-plus"></i> Adicionar Novo Estágio
            </a>

            <div>
                <?php if ($modo_apagar): ?>
                    <a href="gerir_estagios.php" class="btn-cancel">
                        <i class="fas fa-times"></i> Cancelar
                    </a>
                    <button type="submit" class="btn-confirm-delete" onclick="return confirm('Tem a certeza? Esta ação é irreversível!')">
                        <i class="fas fa-check"></i> Confirmar Eliminação
                    </button>
                <?php else: ?>
                    <a href="gerir_estagios.php?modo=apagar" class="btn-delete-mode">
                        <i class="fas fa-trash"></i> Apagar Estágios
                    </a>
                <?php endif; ?>
            </div>
        </div>
    
    </form>

    <a href="dashboard_admin.php" class="btn-back">
        <i class="fas fa-arrow-left"></i> Voltar ao Painel
    </a>
</div>

</body>
</html>