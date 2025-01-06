<?php
// Matikan semua output error PHP
error_reporting(0);
ini_set('display_errors', 0);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

// Enable error logging
ini_set('log_errors', 1);
ini_set('error_log', 'login_error.log');

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Fungsi untuk mengirim response JSON
function sendJsonResponse($data) {
    echo json_encode($data);
    exit();
}

try {
    // Cek method
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        sendJsonResponse(['error' => 'Method not allowed']);
    }

    // Get the raw POST data
    $rawData = file_get_contents('php://input');
    error_log("Raw input data: " . $rawData);

    $data = json_decode($rawData, true);
    error_log("Decoded data: " . print_r($data, true));

    // Koneksi database
    require_once 'koneksi.php';
    
    if (!isset($conn) || $conn->connect_error) {
        sendJsonResponse(['error' => 'Database connection failed']);
    }

    // Validate input
    if (!isset($data['email']) || !isset($data['password'])) {
        throw new Exception('Email and password are required');
    }

    $email = $data['email'];
    $password = $data['password'];
    
    error_log("Attempting login with email: $email");

    // Prepare and execute query
    $stmt = $conn->prepare("SELECT id, nama, email FROM users WHERE email = ? AND password = ?");
    if (!$stmt) {
        error_log("Query preparation failed: " . $conn->error);
        throw new Exception($conn->error);
    }

    $stmt->bind_param("ss", $email, $password);
    $stmt->execute();
    $result = $stmt->get_result();
    
    error_log("Query result rows: " . $result->num_rows);

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        error_log("Login successful for user: " . $user['email']);
        sendJsonResponse([
            'success' => true,
            'message' => 'Login successful',
            'user' => $user
        ]);
    } else {
        error_log("Login failed: Invalid credentials for email: $email");
        sendJsonResponse([
            'success' => false,
            'message' => 'Invalid email or password'
        ]);
    }

} catch (Exception $e) {
    error_log("Login error: " . $e->getMessage());
    http_response_code(400);
    sendJsonResponse([
        'success' => false,
        'message' => $e->getMessage()
    ]);
} finally {
    if (isset($stmt)) {
        $stmt->close();
    }
    if (isset($conn)) {
        $conn->close();
    }
}
?>