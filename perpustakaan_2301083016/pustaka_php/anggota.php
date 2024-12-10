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

// Handle get by ID
if (isset($_GET['action']) && $_GET['action'] == 'get_by_id' && isset($_GET['id'])) {
    $id = $_GET['id'];
    $sql = "SELECT * FROM anggota WHERE id = ?";
    $stmt = $db->prepare($sql);
    
    try {
        $stmt->execute([$id]);
        $anggota = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'data' => $anggota
        ]);
        exit();
    } catch(PDOException $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Failed to get anggota: ' . $e->getMessage()
        ]);
        exit();
    }
}

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        $sql = "SELECT * FROM anggota ORDER BY id DESC";
        $stmt = $db->prepare($sql);
        $stmt->execute();
        $anggota = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'data' => $anggota
        ]);
        break;

    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);
        
        $sql = "INSERT INTO anggota (nim, nama, alamat, jenis_kelamin) 
                VALUES (:nim, :nama, :alamat, :jenis_kelamin)";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':nim' => $data['nim'],
                ':nama' => $data['nama'],
                ':alamat' => $data['alamat'],
                ':jenis_kelamin' => $data['jenis_kelamin']
            ]);
            
            echo json_encode([
                'success' => true,
                'message' => 'Anggota added successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to add anggota: ' . $e->getMessage()
            ]);
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents("php://input"), true);
        
        $sql = "UPDATE anggota 
                SET nim = :nim,
                    nama = :nama,
                    alamat = :alamat,
                    jenis_kelamin = :jenis_kelamin
                WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':id' => $data['id'],
                ':nim' => $data['nim'],
                ':nama' => $data['nama'],
                ':alamat' => $data['alamat'],
                ':jenis_kelamin' => $data['jenis_kelamin']
            ]);
            
            echo json_encode([
                'success' => true,
                'message' => 'Anggota updated successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update anggota: ' . $e->getMessage()
            ]);
        }
        break;

    case 'DELETE':
        if (!isset($_GET['id'])) {
            echo json_encode([
                'success' => false,
                'message' => 'ID is required'
            ]);
            exit();
        }
        
        $sql = "DELETE FROM anggota WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([':id' => $_GET['id']]);
            echo json_encode([
                'success' => true,
                'message' => 'Anggota deleted successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to delete anggota: ' . $e->getMessage()
            ]);
        }
        break;
}

$db = null;
?>
