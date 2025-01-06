<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database connection
$host = 'localhost';
$dbname = 'pustaka_2301083016';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
    exit();
}

// Handle request
$method = $_SERVER['REQUEST_METHOD'];

try {
    switch ($method) {
        case 'GET':
            // Read all buku
            $stmt = $pdo->prepare("SELECT * FROM Buku");
            $stmt->execute();
            $buku = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($buku);
            break;
            
        case 'POST':
            // Create new buku
            $data = json_decode(file_get_contents('php://input'), true);
            
            // Log the received data for debugging
            error_log('Received data: ' . print_r($data, true));
            
            if (!isset($data['judul']) || !isset($data['pengarang']) || !isset($data['penerbit']) || !isset($data['tahun_terbit'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Missing required fields']);
                break;
            }
            
            $stmt = $pdo->prepare("INSERT INTO Buku (judul, pengarang, penerbit, tahun_terbit, url_gambar) VALUES (?, ?, ?, ?, ?)");
            $stmt->execute([
                $data['judul'],
                $data['pengarang'],
                $data['penerbit'],
                $data['tahun_terbit'],
                $data['url_gambar'] ?? null
            ]);
            
            http_response_code(200);
            echo json_encode(['message' => 'Buku created successfully']);
            break;
            
        case 'PUT':
            // Update existing buku
            $data = json_decode(file_get_contents('php://input'), true);
            $stmt = $pdo->prepare("UPDATE Buku SET judul = ?, pengarang = ?, penerbit = ?, tahun_terbit = ?, url_gambar = ? WHERE id = ?");
            $stmt->execute([
                $data['judul'],
                $data['pengarang'],
                $data['penerbit'],
                $data['tahun_terbit'],
                $data['url_gambar'] ?? null,
                $data['id']
            ]);
            echo json_encode(['message' => 'Buku updated successfully']);
            break;
            
        case 'DELETE':
            $data = json_decode(file_get_contents('php://input'), true);
            $stmt = $pdo->prepare("DELETE FROM Buku WHERE id = ?");
            $stmt->execute([$data['id']]);
            echo json_encode(['message' => 'Buku deleted successfully']);
            break;
            
        default:
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed']);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}