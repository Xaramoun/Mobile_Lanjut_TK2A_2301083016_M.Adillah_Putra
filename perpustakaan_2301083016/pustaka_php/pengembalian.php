<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$host = 'localhost';
$dbname = 'pustaka_2301083016';
$username = 'root';
$password = '';

try {
    $db = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Connection failed: ' . $e->getMessage()
    ]);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);
        
        try {
            // Start transaction
            $db->beginTransaction();
            
            // Insert ke tabel pengembalian
            $sql = "INSERT INTO pengembalian (id_peminjaman, tanggal_pengembalian, terlambat, denda) 
                    VALUES (:id_peminjaman, :tanggal_pengembalian, :terlambat, :denda)";
            $stmt = $db->prepare($sql);
            $stmt->execute([
                ':id_peminjaman' => $data['id_peminjaman'],
                ':tanggal_pengembalian' => $data['tanggal_pengembalian'],
                ':terlambat' => $data['terlambat'],
                ':denda' => $data['denda']
            ]);
            
            // Delete dari tabel peminjaman
            $sqlDelete = "DELETE FROM peminjaman WHERE id = :id_peminjaman";
            $stmtDelete = $db->prepare($sqlDelete);
            $stmtDelete->execute([':id_peminjaman' => $data['id_peminjaman']]);
            
            // Commit transaction
            $db->commit();
            
            echo json_encode([
                'success' => true,
                'message' => 'Pengembalian processed successfully'
            ]);
        } catch(PDOException $e) {
            // Rollback jika ada error
            $db->rollBack();
            echo json_encode([
                'success' => false,
                'message' => 'Failed to process pengembalian: ' . $e->getMessage()
            ]);
        }
        break;

    case 'GET':
        $sql = "SELECT * FROM pengembalian ORDER BY id DESC";
        $stmt = $db->prepare($sql);
        $stmt->execute();
        $pengembalian = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'data' => $pengembalian
        ]);
        break;

    case 'DELETE':
        if (!isset($_GET['id'])) {
            echo json_encode([
                'success' => false,
                'message' => 'ID is required'
            ]);
            exit();
        }
        
        $sql = "DELETE FROM pengembalian WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([':id' => $_GET['id']]);
            echo json_encode([
                'success' => true,
                'message' => 'Pengembalian deleted successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to delete pengembalian: ' . $e->getMessage()
            ]);
        }
        break;
}

$db = null;
?>
