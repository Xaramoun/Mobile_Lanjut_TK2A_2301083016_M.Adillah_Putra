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

// Log incoming request
$input = file_get_contents('php://input');
error_log("Received request: " . $_SERVER['REQUEST_METHOD']);
error_log("Received data: " . $input);

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
            // Read all anggota
            $stmt = $pdo->prepare("SELECT * FROM Anggota");
            $stmt->execute();
            $anggota = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($anggota);
            break;
            
        case 'POST':
            // Create new anggota
            $input = file_get_contents('php://input');
            $data = json_decode($input, true);
            
            // Validate required fields
            if (!isset($data['nim']) || !isset($data['nama']) || !isset($data['alamat']) || !isset($data['jenis_kelamin'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Missing required fields']);
                break;
            }
            
            try {
                $stmt = $pdo->prepare("INSERT INTO Anggota (nim, nama, alamat, jenis_kelamin) VALUES (?, ?, ?, ?)");
                $stmt->execute([
                    $data['nim'],
                    $data['nama'],
                    $data['alamat'],
                    $data['jenis_kelamin']
                ]);
                http_response_code(200);
                echo json_encode(['message' => 'Anggota created successfully']);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['error' => 'Failed to create anggota: ' . $e->getMessage()]);
            }
            break;
            
        case 'PUT':
            // Update anggota
            $data = json_decode(file_get_contents('php://input'), true);
            $stmt = $pdo->prepare("UPDATE Anggota SET nama = ?, alamat = ?, jenis_kelamin = ? WHERE nim = ?");
            $stmt->execute([$data['nama'], $data['alamat'], $data['jenis_kelamin'], $data['nim']]);
            echo json_encode(['message' => 'Anggota updated successfully']);
            break;
            
        case 'DELETE':
            // Delete anggota
            $nim = $_GET['nim'];
            $stmt = $pdo->prepare("DELETE FROM Anggota WHERE nim = ?");
            $stmt->execute([$nim]);
            echo json_encode(['message' => 'Anggota deleted successfully']);
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
?>