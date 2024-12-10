<?php
$host = "localhost";
$username = "root";
$password = "";
$database = "pustaka_2301083016";

// Create connection
$koneksi = mysqli_connect($host, $username, $password, $database);

// Check connection
if (!$koneksi) {
    die("Connection failed: " . mysqli_connect_error());
}
?>
