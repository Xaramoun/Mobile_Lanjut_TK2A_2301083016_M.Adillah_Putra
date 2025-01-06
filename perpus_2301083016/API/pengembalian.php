<?php
header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

$host = 'localhost';
$dbname = 'pustaka_2301083016';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];
$input = file_get_contents('php://input');
error_log("Received input: " . $input);
$data = json_decode($input, true);

switch ($method) {
    case 'GET':
        try {
            $stmt = $pdo->prepare("SELECT * FROM pengembalian");
            $stmt->execute();
            $pengembalian = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($pengembalian);
        } catch (PDOException $e) {
            error_log("Database error in GET: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
        }
        break;
        
    case 'POST':
        try {
            if ($data === null) {
                error_log("Invalid JSON received: " . $input);
                http_response_code(400);
                echo json_encode(['error' => 'Invalid JSON data received']);
                exit();
            }
            
            error_log("Processing data: " . json_encode($data));
            
            // Validate required fields
            if (!isset($data['id_peminjaman']) || !isset($data['tanggal_pengembalian']) || 
                !isset($data['terlambat']) || !isset($data['denda'])) {
                error_log("Missing required fields. Received data: " . json_encode($data));
                http_response_code(400);
                echo json_encode(['error' => 'Missing required fields']);
                exit();
            }
            
            // Check if peminjaman exists
            $checkStmt = $pdo->prepare("SELECT id FROM peminjaman WHERE id = ?");
            $checkStmt->execute([$data['id_peminjaman']]);
            if (!$checkStmt->fetch()) {
                error_log("Invalid id_peminjaman: " . $data['id_peminjaman']);
                http_response_code(400);
                echo json_encode(['error' => 'Invalid id_peminjaman: ' . $data['id_peminjaman']]);
                exit();
            }
            
            $stmt = $pdo->prepare("INSERT INTO pengembalian (tanggal_pengembalian, terlambat, denda, id_peminjaman, keterangan) VALUES (?, ?, ?, ?, ?)");
            
            $params = [
                $data['tanggal_pengembalian'],
                intval($data['terlambat']),
                floatval($data['denda']),
                intval($data['id_peminjaman']),
                $data['keterangan'] ?? ''
            ];
            
            error_log("Executing query with params: " . json_encode($params));
            $stmt->execute($params);
            
            $newId = $pdo->lastInsertId();
            error_log("Successfully inserted record with ID: " . $newId);
            
            echo json_encode(['message' => 'Pengembalian created successfully', 'id' => $newId]);
        } catch (PDOException $e) {
            error_log("Database error in POST: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
        }
        break;
        
    case 'PUT':
        try {
            if ($data === null) {
                error_log("Invalid JSON received: " . $input);
                http_response_code(400);
                echo json_encode(['error' => 'Invalid JSON data received']);
                exit();
            }
            
            error_log("Processing data: " . json_encode($data));
            
            // Validate required fields
            if (!isset($data['id']) || !isset($data['id_peminjaman']) || !isset($data['tanggal_pengembalian']) || 
                !isset($data['terlambat']) || !isset($data['denda'])) {
                error_log("Missing required fields. Received data: " . json_encode($data));
                http_response_code(400);
                echo json_encode(['error' => 'Missing required fields']);
                exit();
            }
            
            // Check if peminjaman exists
            $checkStmt = $pdo->prepare("SELECT id FROM peminjaman WHERE id = ?");
            $checkStmt->execute([$data['id_peminjaman']]);
            if (!$checkStmt->fetch()) {
                error_log("Invalid id_peminjaman: " . $data['id_peminjaman']);
                http_response_code(400);
                echo json_encode(['error' => 'Invalid id_peminjaman: ' . $data['id_peminjaman']]);
                exit();
            }
            
            $stmt = $pdo->prepare("UPDATE pengembalian SET tanggal_pengembalian = ?, terlambat = ?, denda = ?, id_peminjaman = ?, keterangan = ? WHERE id = ?");
            
            $params = [
                $data['tanggal_pengembalian'],
                intval($data['terlambat']),
                floatval($data['denda']),
                intval($data['id_peminjaman']),
                $data['keterangan'] ?? '',
                intval($data['id'])
            ];
            
            error_log("Executing query with params: " . json_encode($params));
            $stmt->execute($params);
            
            error_log("Successfully updated record with ID: " . $data['id']);
            
            echo json_encode(['message' => 'Pengembalian updated successfully']);
        } catch (PDOException $e) {
            error_log("Database error in PUT: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
        }
        break;
        
    case 'DELETE':
        try {
            $id = $_GET['id'];
            
            // Check if pengembalian exists
            $checkStmt = $pdo->prepare("SELECT id FROM pengembalian WHERE id = ?");
            $checkStmt->execute([$id]);
            if (!$checkStmt->fetch()) {
                error_log("Invalid id: " . $id);
                http_response_code(400);
                echo json_encode(['error' => 'Invalid id: ' . $id]);
                exit();
            }
            
            $stmt = $pdo->prepare("DELETE FROM pengembalian WHERE id = ?");
            
            error_log("Executing query with params: " . json_encode([$id]));
            $stmt->execute([$id]);
            
            error_log("Successfully deleted record with ID: " . $id);
            
            echo json_encode(['message' => 'Pengembalian deleted successfully']);
        } catch (PDOException $e) {
            error_log("Database error in DELETE: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}
?>