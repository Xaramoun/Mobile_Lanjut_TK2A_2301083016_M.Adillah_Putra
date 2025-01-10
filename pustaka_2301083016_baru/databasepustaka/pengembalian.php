<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

require_once 'koneksi.php';

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Handle DELETE request
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    try {
        $id = $_GET['id'] ?? null;
        
        if (!$id) {
            throw new Exception('ID tidak ditemukan');
        }

        // Begin transaction
        $conn->beginTransaction();
        
        // Get peminjaman_id before delete
        $queryGet = "SELECT peminjaman FROM pengembalian WHERE id = :id";
        $stmtGet = $conn->prepare($queryGet);
        $stmtGet->execute([':id' => $id]);
        $peminjamanId = $stmtGet->fetchColumn();

        if (!$peminjamanId) {
            throw new Exception('Data pengembalian tidak ditemukan');
        }

        // Delete pengembalian
        $queryDelete = "DELETE FROM pengembalian WHERE id = :id";
        $stmtDelete = $conn->prepare($queryDelete);
        $stmtDelete->execute([':id' => $id]);

        // Update status buku menjadi Dipinjam
        $updateBuku = "UPDATE buku SET status = 'Dipinjam' 
                      WHERE id = (SELECT buku FROM peminjaman WHERE id = :peminjaman_id)";
        $stmtBuku = $conn->prepare($updateBuku);
        $stmtBuku->execute([':peminjaman_id' => $peminjamanId]);

        // Commit transaction
        $conn->commit();

        echo json_encode([
            'success' => true,
            'message' => 'Data pengembalian berhasil dihapus'
        ]);
    } catch (PDOException $e) {
        // Rollback jika terjadi error
        if ($conn->inTransaction()) {
            $conn->rollBack();
        }
        echo json_encode([
            'success' => false,
            'message' => 'Gagal menghapus data: ' . $e->getMessage()
        ]);
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => $e->getMessage()
        ]);
    }
}

// Handle GET request
else if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $query = "SELECT p.*, pm.tanggal_pinjam, pm.tanggal_kembali, 
                  b.judul as judul_buku, a.nama as nama_anggota
                  FROM pengembalian p
                  JOIN peminjaman pm ON p.peminjaman = pm.id
                  JOIN buku b ON pm.buku = b.id
                  JOIN anggota a ON pm.anggota = a.id
                  ORDER BY p.tanggal_dikembalikan DESC";

        $stmt = $conn->prepare($query);
        $stmt->execute();
        $pengembalian = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'data' => $pengembalian
        ]);
    } catch (PDOException $e) {
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
        
        // Begin transaction
        $conn->beginTransaction();
        
        // Insert ke tabel pengembalian
        $query = "INSERT INTO pengembalian (peminjaman, tanggal_dikembalikan, terlambat, denda) 
                  VALUES (:peminjaman, :tanggal_dikembalikan, :terlambat, :denda)";
        
        $stmt = $conn->prepare($query);
        $stmt->execute([
            ':peminjaman' => $data['peminjaman'],
            ':tanggal_dikembalikan' => $data['tanggal_dikembalikan'],
            ':terlambat' => $data['terlambat'],
            ':denda' => $data['denda']
        ]);

        // Update status buku menjadi tersedia
        $updateBuku = "UPDATE buku SET status = 'Tersedia' 
                      WHERE id = (SELECT buku FROM peminjaman WHERE id = :peminjaman)";
        $stmtBuku = $conn->prepare($updateBuku);
        $stmtBuku->execute([':peminjaman' => $data['peminjaman']]);

        // Commit transaction
        $conn->commit();

        echo json_encode([
            'success' => true,
            'message' => 'Data pengembalian berhasil disimpan'
        ]);
    } catch (PDOException $e) {
        // Rollback jika terjadi error
        $conn->rollBack();
        echo json_encode([
            'success' => false,
            'message' => 'Gagal menyimpan data: ' . $e->getMessage()
        ]);
    }
}
?>