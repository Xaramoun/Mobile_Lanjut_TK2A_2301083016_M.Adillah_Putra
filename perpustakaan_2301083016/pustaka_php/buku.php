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
    case 'GET':
        if (isset($_GET['action']) && $_GET['action'] == 'get_by_id' && isset($_GET['id'])) {
            $id = $_GET['id'];
            $query = "SELECT * FROM buku WHERE id = ?";
            $stmt = $db->prepare($query);
            $stmt->execute([$id]);
            $buku = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'data' => $buku
            ]);
        } else {
            $sql = "SELECT * FROM buku";
            $stmt = $db->prepare($sql);
            $stmt->execute();
            $buku = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'data' => $buku
            ]);
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);
        
        $sql = "INSERT INTO buku (judul, pengarang, penerbit, tahun_terbit, url_gambar) 
                VALUES (:judul, :pengarang, :penerbit, :tahun_terbit, :url_gambar)";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':judul' => $data['judul'],
                ':pengarang' => $data['pengarang'],
                ':penerbit' => $data['penerbit'],
                ':tahun_terbit' => $data['tahun_terbit'],
                ':url_gambar' => $data['url_gambar']
            ]);
            
            echo json_encode([
                'success' => true,
                'message' => 'Buku added successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to add buku: ' . $e->getMessage()
            ]);
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents("php://input"), true);
        
        $sql = "UPDATE buku 
                SET judul = :judul,
                    pengarang = :pengarang,
                    penerbit = :penerbit,
                    tahun_terbit = :tahun_terbit,
                    url_gambar = :url_gambar
                WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':id' => $data['id'],
                ':judul' => $data['judul'],
                ':pengarang' => $data['pengarang'],
                ':penerbit' => $data['penerbit'],
                ':tahun_terbit' => $data['tahun_terbit'],
                ':url_gambar' => $data['url_gambar']
            ]);
            
            echo json_encode([
                'success' => true,
                'message' => 'Buku updated successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update buku: ' . $e->getMessage()
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
        
        $sql = "DELETE FROM buku WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([':id' => $_GET['id']]);
            echo json_encode([
                'success' => true,
                'message' => 'Buku deleted successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to delete buku: ' . $e->getMessage()
            ]);
        }
        break;
}

$db = null;
?>