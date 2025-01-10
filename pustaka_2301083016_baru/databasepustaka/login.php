<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
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
    
    // Debug: Cek koneksi database
    error_log("Database connected successfully");
    
    // Debug: Tampilkan semua data di tabel login
    $debug_query = "SELECT * FROM login";
    $debug_stmt = $db->query($debug_query);
    $all_users = $debug_stmt->fetchAll(PDO::FETCH_ASSOC);
    error_log("All users in database: " . print_r($all_users, true));
    
} catch(PDOException $e) {
    die(json_encode([
        'success' => false,
        'message' => 'Connection failed: ' . $e->getMessage()
    ]));
}

// Get request method
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);
    error_log("Received POST data: " . print_r($data, true));
} else if ($method === 'GET') {
    $data = $_GET;
    error_log("Received GET data: " . print_r($data, true));
} else {
    $data = [];
}

// Validate required fields
if (!isset($data['username']) || !isset($data['password'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Username dan password diperlukan',
        'debug' => [
            'method' => $method,
            'received_data' => $data
        ]
    ]);
    exit();
}

// Query untuk login
$sql = "SELECT id, username, nama FROM login WHERE username = :username AND password = :password LIMIT 1";
$stmt = $db->prepare($sql);

try {
    // Debug: Print query parameters
    error_log("Attempting login with username: " . $data['username']);
    error_log("SQL Query: " . $sql);
    
    $stmt->execute([
        ':username' => $data['username'],
        ':password' => $data['password']
    ]);

    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Debug: Print query result
    error_log("Query result: " . print_r($user, true));

    if ($user) {
        echo json_encode([
            'success' => true,
            'message' => 'Login berhasil',
            'user' => [
                'id' => $user['id'],
                'username' => $user['username'],
                'nama' => $user['nama']
            ]
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Username atau password salah',
            'debug' => [
                'attempted_username' => $data['username'],
                'query' => $sql
            ]
        ]);
    }
} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Login error: ' . $e->getMessage(),
        'debug' => [
            'sql_error' => $e->getMessage(),
            'sql_query' => $sql
        ]
    ]);
}

// Close database connection
$db = null;
?>