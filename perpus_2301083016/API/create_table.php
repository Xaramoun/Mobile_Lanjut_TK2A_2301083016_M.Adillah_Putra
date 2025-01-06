<?php
include 'koneksi.php';

// Create users table
$sql = "CREATE TABLE IF NOT EXISTS users (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY email_unique (email)
)";

if ($conn->query($sql) === TRUE) {
    echo "Table users created successfully\n";
    
    // Insert sample user
    $nama = "Admin";
    $email = "admin@admin.com";
    $password = "admin123";
    
    $check = "SELECT * FROM users WHERE email = '$email'";
    $result = $conn->query($check);
    
    if ($result->num_rows == 0) {
        $insert = "INSERT INTO users (nama, email, password) VALUES ('$nama', '$email', '$password')";
        if ($conn->query($insert) === TRUE) {
            echo "Sample user created successfully\n";
            echo "Email: admin@admin.com\n";
            echo "Password: admin123\n";
        } else {
            echo "Error creating sample user: " . $conn->error . "\n";
        }
    } else {
        echo "Sample user already exists\n";
    }
} else {
    echo "Error creating table: " . $conn->error . "\n";
}

$conn->close();
?>
