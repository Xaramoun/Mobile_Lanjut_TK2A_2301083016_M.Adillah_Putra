<?php
// Matikan error reporting
error_reporting(0);
ini_set('display_errors', 0);

$host = 'localhost';
$username = 'root';
$password = '';
$database = 'pustaka_2301083016';

try {
    $conn = new mysqli($host, $username, $password, $database);

    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }

    $conn->set_charset("utf8");
} catch (Exception $e) {
    header('Content-Type: application/json');
    echo json_encode(['error' => $e->getMessage()]);
    exit();
}
?>
