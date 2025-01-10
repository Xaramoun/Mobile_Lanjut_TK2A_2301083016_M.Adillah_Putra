<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database configuration
$host = 'localhost';
$dbname = 'perpus_2301083016';
$username = 'root';
$password = '';

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Koneksi gagal: ' . $e->getMessage()]);
    exit();
}

// Get request method
$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        try {
            $stmt = $conn->query("SELECT * FROM anggota ORDER BY id DESC");
            $anggota = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode(['success' => true, 'data' => $anggota]);
        } catch(PDOException $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
        break;

    case 'POST':
        try {
            $data = json_decode(file_get_contents('php://input'), true);
            
            // Debug: Print received data
            error_log(print_r($data, true));
            
            // Validasi input
            if (empty($data['nim']) || empty($data['nama']) || empty($data['alamat']) || empty($data['jenis_kelamin'])) {
                echo json_encode(['success' => false, 'message' => 'Semua field harus diisi']);
                exit();
            }
            
            // Validasi jenis_kelamin
            if (!in_array($data['jenis_kelamin'], ['L', 'P'])) {
                echo json_encode(['success' => false, 'message' => 'Jenis kelamin harus L atau P']);
                exit();
            }

            $stmt = $conn->prepare("INSERT INTO anggota (nim, nama, alamat, jenis_kelamin) VALUES (?, ?, ?, ?)");
            $stmt->execute([
                $data['nim'],
                $data['nama'],
                $data['alamat'],
                $data['jenis_kelamin']
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Anggota berhasil ditambahkan',
                'id' => $conn->lastInsertId()
            ]);
        } catch(PDOException $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
        break;

    case 'PUT':
        try {
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($data['id'])) {
                echo json_encode(['success' => false, 'message' => 'ID tidak ditemukan']);
                exit();
            }

            $stmt = $conn->prepare("UPDATE anggota SET nim = ?, nama = ?, alamat = ?, jenis_kelamin = ? WHERE id = ?");
            $result = $stmt->execute([
                $data['nim'],
                $data['nama'],
                $data['alamat'],
                $data['jenis_kelamin'],
                $data['id']
            ]);

            if ($result) {
                echo json_encode(['success' => true, 'message' => 'Data anggota berhasil diperbarui']);
            } else {
                echo json_encode(['success' => false, 'message' => 'Gagal memperbarui data']);
            }
        } catch(PDOException $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
        break;

    case 'DELETE':
        try {
            if (!isset($_GET['id'])) {
                echo json_encode(['success' => false, 'message' => 'ID tidak diberikan']);
                exit();
            }

            $stmt = $conn->prepare("DELETE FROM anggota WHERE id = ?");
            $result = $stmt->execute([$_GET['id']]);

            if ($result) {
                echo json_encode(['success' => true, 'message' => 'Anggota berhasil dihapus']);
            } else {
                echo json_encode(['success' => false, 'message' => 'Gagal menghapus anggota']);
            }
        } catch(PDOException $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Method tidak diizinkan']);
        break;
}

$conn = null;
?>