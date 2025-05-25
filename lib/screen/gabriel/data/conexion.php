<?php
header("Access-Control-Allow-Origin: *");

$connect = new mysqli("localhost", "root", "", "coba");

if ($connect) {
} else {
	echo "Gagal Konek";
	exit();
}
