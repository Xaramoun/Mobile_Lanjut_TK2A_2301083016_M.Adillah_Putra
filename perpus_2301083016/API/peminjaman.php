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
            // Read all peminjaman with join to get anggota and buku details
            $stmt = $pdo->prepare("
                SELECT p.*, a.nama as nama_anggota, b.judul as judul_buku 
                FROM peminjaman p
                JOIN anggota a ON p.id_anggota = a.id
                JOIN buku b ON p.id_buku = b.id
            ");
            $stmt->execute();
            $peminjaman = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($peminjaman);
            break;
            
        case 'POST':
            // Create new peminjaman
            $data = json_decode(file_get_contents('php://input'), true);
            
            // Log received data
            error_log('Received peminjaman data: ' . print_r($data, true));
            
            // Validate required fields
            if (!isset($data['id_anggota']) || !isset($data['id_buku']) || 
                !isset($data['tanggal_pinjam']) || !isset($data['tanggal_kembali'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Missing required fields']);
                break;
            }
            
            $stmt = $pdo->prepare("INSERT INTO peminjaman (id_anggota, id_buku, tanggal_pinjam, tanggal_kembali) VALUES (?, ?, ?, ?)");
            $stmt->execute([
                $data['id_anggota'],
                $data['id_buku'],
                $data['tanggal_pinjam'],
                $data['tanggal_kembali']
            ]);
            
            http_response_code(200);
            echo json_encode(['message' => 'Peminjaman created successfully']);
            break;
            
        default:
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed']);
            break;
    }
} catch (Exception $e) {
    error_log('Error in peminjaman.php: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}