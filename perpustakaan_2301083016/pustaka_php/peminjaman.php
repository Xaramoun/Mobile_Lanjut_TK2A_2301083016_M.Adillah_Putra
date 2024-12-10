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
    die(json_encode([
        'success' => false,
        'message' => 'Connection failed: ' . $e->getMessage()
    ]));
}

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        $sql = "SELECT * FROM peminjaman ORDER BY id DESC";
        $stmt = $db->prepare($sql);
        $stmt->execute();
        $peminjaman = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'data' => $peminjaman
        ]);
        break;

    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);
        
        $required_fields = ['tanggal_pinjam', 'tanggal_kembali', 'id_buku', 'id_anggota'];
        foreach($required_fields as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                echo json_encode([
                    'success' => false,
                    'message' => "Field '$field' is required"
                ]);
                exit();
            }
        }

        $sql = "INSERT INTO peminjaman (tanggal_pinjam, tanggal_kembali, id_buku, id_anggota) 
                VALUES (:tanggal_pinjam, :tanggal_kembali, :id_buku, :id_anggota)";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':tanggal_pinjam' => $data['tanggal_pinjam'],
                ':tanggal_kembali' => $data['tanggal_kembali'],
                ':id_buku' => $data['id_buku'],
                ':id_anggota' => $data['id_anggota']
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Peminjaman added successfully',
                'id' => $db->lastInsertId()
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to add peminjaman: ' . $e->getMessage()
            ]);
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['id'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Peminjaman ID is required'
            ]);
            exit();
        }

        $sql = "UPDATE peminjaman 
                SET tanggal_pinjam = :tanggal_pinjam,
                    tanggal_kembali = :tanggal_kembali,
                    id_buku = :id_buku,
                    id_anggota = :id_anggota,
                    status = :status
                WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':id' => $data['id'],
                ':tanggal_pinjam' => $data['tanggal_pinjam'],
                ':tanggal_kembali' => $data['tanggal_kembali'],
                ':id_buku' => $data['id_buku'],
                ':id_anggota' => $data['id_anggota'],
                ':status' => $data['status']
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Peminjaman updated successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update peminjaman: ' . $e->getMessage()
            ]);
        }
        break;

    case 'DELETE':
        if (!isset($_GET['id'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Peminjaman ID is required'
            ]);
            exit();
        }

        $sql = "DELETE FROM peminjaman WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([':id' => $_GET['id']]);
            echo json_encode([
                'success' => true,
                'message' => 'Peminjaman deleted successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to delete peminjaman: ' . $e->getMessage()
            ]);
        }
        break;
}

$db = null;
?>
