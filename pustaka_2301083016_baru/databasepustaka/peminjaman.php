<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

require_once 'koneksi.php';

// Handle DELETE request
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    try {
        // Ambil ID dari URL parameter
        $id = isset($_GET['id']) ? $_GET['id'] : null;
        
        if (!$id) {
            throw new Exception('ID tidak ditemukan');
        }

        // Mulai transaction
        $conn->beginTransaction();

        // Delete data peminjaman
        $query = "DELETE FROM peminjaman WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->execute([':id' => $id]);

        // Commit transaction
        $conn->commit();

        echo json_encode([
            'success' => true,
            'message' => 'Data peminjaman berhasil dihapus'
        ]);
    } catch (Exception $e) {
        // Rollback jika terjadi error
        if ($conn->inTransaction()) {
            $conn->rollBack();
        }
        echo json_encode([
            'success' => false,
            'message' => 'Gagal menghapus data: ' . $e->getMessage()
        ]);
    }
}

// Handle GET request
else if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $query = "SELECT p.*, b.judul as judul_buku, a.nama as nama_anggota 
                 FROM peminjaman p 
                 JOIN buku b ON p.buku = b.id 
                 JOIN anggota a ON p.anggota = a.id 
                 ORDER BY p.tanggal_pinjam DESC";
        
        $stmt = $conn->prepare($query);
        $stmt->execute();
        $peminjaman = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'data' => $peminjaman
        ]);
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Gagal mengambil data: ' . $e->getMessage()
        ]);
    }
}

// Handle POST request
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!isset($data['anggota']) || 
            !isset($data['buku']) || 
            !isset($data['tanggal_pinjam']) || 
            !isset($data['tanggal_kembali'])) {
            throw new Exception('Data tidak lengkap');
        }

        $query = "INSERT INTO peminjaman (anggota, buku, tanggal_pinjam, tanggal_kembali) 
                 VALUES (:anggota, :buku, :tanggal_pinjam, :tanggal_kembali)";
        
        $stmt = $conn->prepare($query);
        $stmt->execute([
            ':anggota' => $data['anggota'],
            ':buku' => $data['buku'],
            ':tanggal_pinjam' => $data['tanggal_pinjam'],
            ':tanggal_kembali' => $data['tanggal_kembali']
        ]);

        echo json_encode([
            'success' => true,
            'message' => 'Data peminjaman berhasil disimpan'
        ]);
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Gagal menyimpan data: ' . $e->getMessage()
        ]);
    }
}

$conn = null;
?>
