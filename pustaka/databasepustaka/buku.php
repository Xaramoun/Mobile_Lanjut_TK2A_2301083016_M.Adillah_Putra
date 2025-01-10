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

// Create database connection
try {
    $db = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    die(json_encode([
        'success' => false,
        'message' => 'Connection failed: ' . $e->getMessage()
    ]));
}

// Get request method
$method = $_SERVER['REQUEST_METHOD'];

// Handle different HTTP methods
switch($method) {
    case 'GET':
        // Get all books
        $sql = "SELECT * FROM buku ORDER BY id DESC";
        $stmt = $db->prepare($sql);
        $stmt->execute();
        $books = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'data' => $books
        ]);
        break;

    case 'POST':
        // Add new book
        $data = json_decode(file_get_contents("php://input"), true);
        
        // Debug: Print received data
        error_log(print_r($data, true));

        // Validate required fields
        $required_fields = ['judul', 'pengarang', 'penerbit', 'tahun', 'url_gambar', 'status'];
        foreach($required_fields as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                echo json_encode([
                    'success' => false,
                    'message' => "Field '$field' is required"
                ]);
                exit();
            }
        }

        // Insert book
        $sql = "INSERT INTO buku (judul, pengarang, penerbit, tahun, url_gambar, status) 
                VALUES (:judul, :pengarang, :penerbit, :tahun, :url_gambar, :status)";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':judul' => $data['judul'],
                ':pengarang' => $data['pengarang'],
                ':penerbit' => $data['penerbit'],
                ':tahun' => $data['tahun'],
                ':url_gambar' => $data['url_gambar'],
                ':status' => $data['status']
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Book added successfully',
                'id' => $db->lastInsertId()
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to add book: ' . $e->getMessage()
            ]);
        }
        break;

    case 'PUT':
        // Update book
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['id'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Book ID is required'
            ]);
            exit();
        }

        $sql = "UPDATE buku 
                SET judul = :judul, 
                    pengarang = :pengarang,
                    penerbit = :penerbit,
                    tahun = :tahun, 
                    url_gambar = :url_gambar,
                    status = :status 
                WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':id' => $data['id'],
                ':judul' => $data['judul'],
                ':pengarang' => $data['pengarang'],
                ':penerbit' => $data['penerbit'],
                ':tahun' => $data['tahun'],
                ':url_gambar' => $data['url_gambar'],
                ':status' => $data['status']
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Book updated successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update book: ' . $e->getMessage()
            ]);
        }
        break;

    case 'DELETE':
        if (!isset($_GET['id'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Book ID is required'
            ]);
            exit();
        }

        // Cek apakah buku masih dipinjam
        $checkSql = "SELECT COUNT(*) FROM peminjaman WHERE buku = :id";
        $checkStmt = $db->prepare($checkSql);
        $checkStmt->execute([':id' => $_GET['id']]);
        $count = $checkStmt->fetchColumn();

        if ($count > 0) {
            echo json_encode([
                'success' => false,
                'message' => 'Buku tidak dapat dihapus karena masih ada data peminjaman'
            ]);
            exit();
        }

        $sql = "DELETE FROM buku WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([':id' => $_GET['id']]);
            echo json_encode([
                'success' => true,
                'message' => 'Book deleted successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to delete book: ' . $e->getMessage()
            ]);
        }
        break;
}

// Close database connection
$db = null;
?>