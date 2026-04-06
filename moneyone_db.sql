-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 22, 2026 at 12:13 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `moneyone_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin_activity_logs`
--

CREATE TABLE `admin_activity_logs` (
  `id` int(11) NOT NULL,
  `admin_id` varchar(50) NOT NULL,
  `action` varchar(100) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin_activity_logs`
--

INSERT INTO `admin_activity_logs` (`id`, `admin_id`, `action`, `ip_address`, `user_agent`, `status`, `created_at`) VALUES
(1, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 05:41:29'),
(2, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 05:41:36'),
(3, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'failed', '2026-02-13 05:41:53'),
(4, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'failed', '2026-02-13 05:42:01'),
(5, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 05:42:10'),
(6, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 05:42:15'),
(7, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 05:42:59'),
(8, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 05:51:30'),
(9, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 05:51:45'),
(10, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 05:56:07'),
(11, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 05:56:18'),
(12, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 05:57:53'),
(13, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 05:58:46'),
(14, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:01:23'),
(15, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:01:44'),
(16, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:05:40'),
(17, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:05:50'),
(18, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:10:00'),
(19, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:10:12'),
(20, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'success', '2026-02-13 06:12:04'),
(21, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'success', '2026-02-13 06:12:12'),
(22, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:13:25'),
(23, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:14:50'),
(24, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:16:08'),
(25, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:25:04'),
(26, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:25:15'),
(27, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'failed', '2026-02-13 06:27:37'),
(28, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:27:44'),
(29, '6239572985', 'set_pin', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:28:03'),
(30, '6239572985', 'delete_pin', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:28:29'),
(31, '6239572985', 'set_pin', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:28:52'),
(32, '6239572985', 'delete_pin', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:30:54'),
(33, '6239572985', 'set_pin', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:31:10'),
(34, '6239572985', 'change_password', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:32:08'),
(35, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:32:14'),
(36, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'failed', '2026-02-13 06:32:25'),
(37, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:32:38'),
(38, '6239572985', 'change_password', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:33:04'),
(39, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:57:08'),
(40, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:57:08'),
(41, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'failed', '2026-02-13 06:57:50'),
(42, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 06:58:08'),
(43, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 07:13:10'),
(44, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 07:13:11'),
(45, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'failed', '2026-02-13 09:51:11'),
(46, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 09:51:19'),
(47, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 10:20:46'),
(48, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 10:20:46'),
(49, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 18:02:56'),
(50, '6239572985', 'create_scheme:Test1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 18:26:22'),
(51, '6239572985', 'update_charges:Test1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 18:29:53'),
(52, '6239572985', 'create_scheme:Test2', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 18:30:03'),
(53, '6239572985', 'update_charges:Test2', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 18:30:11'),
(54, '6239572985', 'onboard_merchant:7679022140', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 18:44:28'),
(55, '6239572985', 'update_user:7679022140', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 18:51:12'),
(56, '6239572985', 'deactivate_user:7679022140', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 18:51:22'),
(57, '6239572985', 'activate_user:7679022140', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 18:51:24'),
(58, '6239572985', 'delete_user:7679022140', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 19:26:42'),
(59, '6239572985', 'onboard_merchant:7679022140', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 19:28:03'),
(60, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 20:05:21'),
(61, '6239572985', 'delete_pin', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 20:13:49'),
(62, '6239572985', 'set_pin', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 20:21:25'),
(63, '6239572985', 'delete_scheme:Test2', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 20:51:11'),
(64, '6239572985', 'create_scheme:Test 2', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 20:51:28'),
(65, '6239572985', 'Bank account added', NULL, NULL, 'SUCCESS', '2026-02-13 21:05:33'),
(66, '6239572985', 'Bank deactivated', NULL, NULL, 'SUCCESS', '2026-02-13 21:05:36'),
(67, '6239572985', 'Bank activated', NULL, NULL, 'SUCCESS', '2026-02-13 21:05:37'),
(68, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 21:17:11'),
(69, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-13 21:17:25'),
(70, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 09:08:03'),
(71, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 09:58:49'),
(72, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 09:58:49'),
(73, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'failed', '2026-02-14 10:20:33'),
(74, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 10:20:40'),
(75, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 12:13:49'),
(76, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 12:13:49'),
(77, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'failed', '2026-02-14 13:11:13'),
(78, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 13:11:21'),
(79, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 14:00:32'),
(80, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 14:03:52'),
(81, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 14:04:30'),
(82, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 14:10:50'),
(83, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 14:25:12'),
(84, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 14:36:33'),
(85, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 14:36:49'),
(86, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 14:43:04'),
(87, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'failed', '2026-02-14 14:50:54'),
(88, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 14:51:45'),
(89, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 14:58:46'),
(90, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'failed', '2026-02-14 14:59:06'),
(91, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'failed', '2026-02-14 14:59:19'),
(92, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 14:59:31'),
(93, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 15:02:29'),
(94, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'failed', '2026-02-14 15:10:42'),
(95, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 15:10:49'),
(96, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 16:13:30'),
(97, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 17:08:19'),
(98, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 18:08:45'),
(99, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-14 18:18:19'),
(100, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-16 16:04:04'),
(101, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/144.0.0.0', 'success', '2026-02-16 16:24:27'),
(102, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/144.0.0.0', 'success', '2026-02-16 16:24:40'),
(103, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-16 17:13:35'),
(104, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'success', '2026-02-16 17:13:36'),
(105, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-21 15:09:52'),
(106, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-21 16:13:57'),
(107, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-21 16:13:57'),
(108, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-21 16:49:21'),
(109, '6239572985', 'Bank account added', NULL, NULL, 'SUCCESS', '2026-02-21 16:50:46'),
(110, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-21 17:04:11'),
(111, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'failed', '2026-02-21 17:04:24'),
(112, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-21 17:04:32'),
(113, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-22 04:45:42'),
(114, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-22 05:49:14'),
(115, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-22 05:49:14'),
(116, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'failed', '2026-02-22 06:08:06'),
(117, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-22 06:08:14'),
(118, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-22 07:09:21'),
(119, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-22 07:32:40'),
(120, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-22 07:32:40'),
(121, '6239572985', 'login_attempt', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'failed', '2026-02-22 09:46:20'),
(122, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-22 09:46:29'),
(123, '6239572985', 'logout', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-22 11:04:04'),
(124, '6239572985', 'login', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', 'success', '2026-02-22 11:04:17');

-- --------------------------------------------------------

--
-- Table structure for table `admin_banks`
--

CREATE TABLE `admin_banks` (
  `id` int(11) NOT NULL,
  `admin_id` varchar(50) NOT NULL,
  `bank_name` varchar(255) NOT NULL,
  `account_number` varchar(50) NOT NULL,
  `ifsc_code` varchar(20) NOT NULL,
  `branch_name` varchar(255) DEFAULT NULL,
  `account_holder_name` varchar(255) NOT NULL,
  `tpin_hash` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin_banks`
--

INSERT INTO `admin_banks` (`id`, `admin_id`, `bank_name`, `account_number`, `ifsc_code`, `branch_name`, `account_holder_name`, `tpin_hash`, `is_active`, `created_at`, `updated_at`) VALUES
(1, '6239572985', 'test account', '1234567890', 'IFSC0011', 'sss', 'sssss', '$2b$12$1YwyWf28YI1N.XoTBI21D.eJxFD0Oz90pS.lsPIlVih8auapj1BRy', 1, '2026-02-13 21:05:33', '2026-02-13 21:05:37'),
(2, '6239572985', 'Jio Payments Bank ', '003521711678324', 'JIOP0000001', 'Null', 'Soham Karmakar', '$2b$12$jmodKTWb.SId9TIfQ8LP/OyYXK8CoDHpApcVvmS9ZDYap9Veea0mC', 1, '2026-02-21 16:50:46', '2026-02-21 16:50:46');

-- --------------------------------------------------------

--
-- Table structure for table `admin_users`
--

CREATE TABLE `admin_users` (
  `id` int(11) NOT NULL,
  `admin_id` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_login` timestamp NULL DEFAULT NULL,
  `login_attempts` int(11) DEFAULT 0,
  `locked_until` timestamp NULL DEFAULT NULL,
  `password_changed_at` timestamp NULL DEFAULT NULL,
  `must_change_password` tinyint(1) DEFAULT 0,
  `pin_hash` varchar(255) DEFAULT NULL,
  `pin_changed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin_users`
--

INSERT INTO `admin_users` (`id`, `admin_id`, `password_hash`, `is_active`, `created_at`, `last_login`, `login_attempts`, `locked_until`, `password_changed_at`, `must_change_password`, `pin_hash`, `pin_changed_at`) VALUES
(1, '6239572985', '$2b$12$p9anQ7GbaJelZTIq.74DUuOY2jDZ81hN3dEawRlUm6UYP.//PMsn.', 1, '2026-02-13 05:40:08', '2026-02-22 11:04:17', 0, NULL, '2026-02-13 06:33:04', 0, '$2b$12$2kJfheCQTtjA4vEF1qsi7edUeJ/nfPvFdQub886OWUJVAS8WNOUqy', '2026-02-13 20:21:25'),
(2, 'admin', '$2b$12$SnyWbzPNlLzBhmFcG2XamO.fTqsBTMgNWVwR8fZeE6e.1Voi9pSwK', 1, '2026-02-14 14:09:04', NULL, 0, NULL, NULL, 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `admin_wallet`
--

CREATE TABLE `admin_wallet` (
  `id` int(11) NOT NULL,
  `admin_id` varchar(50) NOT NULL,
  `main_balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `unsettled_balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin_wallet`
--

INSERT INTO `admin_wallet` (`id`, `admin_id`, `main_balance`, `unsettled_balance`, `last_updated`) VALUES
(2, 'admin', 0.00, 0.00, '2026-02-14 14:09:04'),
(3, '6239572985', 0.00, 0.00, '2026-02-14 17:52:26');

-- --------------------------------------------------------

--
-- Table structure for table `admin_wallet_transactions`
--

CREATE TABLE `admin_wallet_transactions` (
  `id` int(11) NOT NULL,
  `admin_id` varchar(50) NOT NULL,
  `txn_id` varchar(100) NOT NULL,
  `wallet_type` enum('MAIN','UNSETTLED') NOT NULL,
  `txn_type` enum('CREDIT','DEBIT') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `balance_before` decimal(15,2) NOT NULL,
  `balance_after` decimal(15,2) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `reference_id` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin_wallet_transactions`
--

INSERT INTO `admin_wallet_transactions` (`id`, `admin_id`, `txn_id`, `wallet_type`, `txn_type`, `amount`, `balance_before`, `balance_after`, `description`, `reference_id`, `created_at`) VALUES
(1, '6239572985', 'AWT20260214210558AFA26D', 'MAIN', 'CREDIT', 10.00, 0.00, 10.00, 'PayIN from merchant 7679022140 - PAYIN_7679022140_112_20260214150305', 'PAYIN_7679022140_112_20260214150305', '2026-02-14 15:35:58'),
(2, '6239572985', 'AWT202602142322268E412B', 'MAIN', 'DEBIT', 10.00, 10.00, 0.00, 'Manual topup for 7679022140 - FRD924BB61C73E', 'FRD924BB61C73E', '2026-02-14 17:52:26'),
(3, '6239572985', 'AWT20260214233714443F63', 'MAIN', 'DEBIT', 100.00, 450.00, 350.00, 'Manual topup for 7679022140 - FRC0F8D8DEA486', 'FRC0F8D8DEA486', '2026-02-14 18:07:14'),
(4, '6239572985', 'AWT20260214233734CC8B03', 'MAIN', 'DEBIT', 100.00, 450.00, 350.00, 'Fund request approved for 7679022140 - FR202602142337283583bf', 'FR202602142337283583bf', '2026-02-14 18:07:34');

-- --------------------------------------------------------

--
-- Table structure for table `callback_logs`
--

CREATE TABLE `callback_logs` (
  `id` int(11) NOT NULL,
  `merchant_id` varchar(50) NOT NULL,
  `txn_id` varchar(100) NOT NULL,
  `callback_url` varchar(500) DEFAULT NULL,
  `request_data` text DEFAULT NULL,
  `response_code` int(11) DEFAULT NULL,
  `response_data` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `commercial_charges`
--

CREATE TABLE `commercial_charges` (
  `id` int(11) NOT NULL,
  `scheme_id` int(11) NOT NULL,
  `service_type` enum('PAYOUT','PAYIN') NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `min_amount` decimal(10,2) NOT NULL,
  `max_amount` decimal(10,2) NOT NULL,
  `charge_value` decimal(10,4) NOT NULL,
  `charge_type` enum('PERCENTAGE','FIXED') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `commercial_charges`
--

INSERT INTO `commercial_charges` (`id`, `scheme_id`, `service_type`, `product_name`, `min_amount`, `max_amount`, `charge_value`, `charge_type`, `created_at`, `updated_at`) VALUES
(1, 1, 'PAYOUT', 'PAYOUT 100-1000', 100.00, 1000.00, 0.5000, 'PERCENTAGE', '2026-02-13 18:29:53', '2026-02-13 18:29:53'),
(2, 1, 'PAYOUT', 'PAYOUT 1001-25000', 1001.00, 25000.00, 0.5000, 'PERCENTAGE', '2026-02-13 18:29:53', '2026-02-13 18:29:53'),
(3, 1, 'PAYOUT', 'PAYOUT 25001-50000', 25001.00, 50000.00, 1.0000, 'PERCENTAGE', '2026-02-13 18:29:53', '2026-02-13 18:29:53'),
(4, 1, 'PAYOUT', 'PAYOUT 50001-200000', 50001.00, 200000.00, 10.0000, 'FIXED', '2026-02-13 18:29:53', '2026-02-13 18:29:53'),
(5, 1, 'PAYIN', 'PAYIN 100-500', 100.00, 500.00, 3.5000, 'PERCENTAGE', '2026-02-13 18:29:53', '2026-02-13 18:29:53'),
(6, 1, 'PAYIN', 'PAYIN 501-1000', 501.00, 1000.00, 3.5000, 'PERCENTAGE', '2026-02-13 18:29:53', '2026-02-13 18:29:53'),
(7, 1, 'PAYIN', 'PAYIN 1001-25000', 1001.00, 25000.00, 3.5000, 'PERCENTAGE', '2026-02-13 18:29:53', '2026-02-13 18:29:53'),
(8, 1, 'PAYIN', 'PAYIN 25001-50000', 25001.00, 50000.00, 3.5000, 'PERCENTAGE', '2026-02-13 18:29:53', '2026-02-13 18:29:53'),
(9, 1, 'PAYIN', 'PAYIN 50001-200000', 50001.00, 200000.00, 3.5000, 'PERCENTAGE', '2026-02-13 18:29:53', '2026-02-13 18:29:53'),
(19, 4, 'PAYOUT', 'IMPS', 0.00, 25000.00, 5.0000, 'FIXED', '2026-02-14 14:15:28', '2026-02-14 14:15:28'),
(20, 4, 'PAYOUT', 'NEFT', 0.00, 200000.00, 3.0000, 'FIXED', '2026-02-14 14:15:28', '2026-02-14 14:15:28'),
(21, 4, 'PAYOUT', 'RTGS', 200000.00, 10000000.00, 25.0000, 'FIXED', '2026-02-14 14:15:28', '2026-02-14 14:15:28'),
(22, 4, 'PAYOUT', 'UPI', 0.00, 100000.00, 2.0000, 'FIXED', '2026-02-14 14:15:28', '2026-02-14 14:15:28'),
(23, 4, 'PAYIN', 'UPI', 0.00, 100000.00, 2.0000, 'PERCENTAGE', '2026-02-14 14:15:28', '2026-02-14 14:15:28'),
(24, 4, 'PAYIN', 'Card', 0.00, 200000.00, 2.5000, 'PERCENTAGE', '2026-02-14 14:15:28', '2026-02-14 14:15:28'),
(25, 4, 'PAYIN', 'Net Banking', 0.00, 200000.00, 1.5000, 'PERCENTAGE', '2026-02-14 14:15:28', '2026-02-14 14:15:28');

-- --------------------------------------------------------

--
-- Table structure for table `commercial_schemes`
--

CREATE TABLE `commercial_schemes` (
  `id` int(11) NOT NULL,
  `scheme_name` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_by` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `commercial_schemes`
--

INSERT INTO `commercial_schemes` (`id`, `scheme_name`, `is_active`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'Test1', 1, '6239572985', '2026-02-13 18:26:22', '2026-02-13 18:26:22'),
(3, 'Test 2', 1, '6239572985', '2026-02-13 20:51:28', '2026-02-13 20:51:28'),
(4, 'Default Scheme', 1, 'admin', '2026-02-14 14:15:28', '2026-02-14 14:15:28');

-- --------------------------------------------------------

--
-- Table structure for table `fund_requests`
--

CREATE TABLE `fund_requests` (
  `id` int(11) NOT NULL,
  `request_id` varchar(100) NOT NULL,
  `merchant_id` varchar(50) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `request_type` enum('TOPUP','SETTLEMENT') NOT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  `remarks` text DEFAULT NULL,
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `processed_at` timestamp NULL DEFAULT NULL,
  `processed_by` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fund_requests`
--

INSERT INTO `fund_requests` (`id`, `request_id`, `merchant_id`, `amount`, `request_type`, `status`, `remarks`, `requested_at`, `processed_at`, `processed_by`) VALUES
(1, 'FR202602142112186abb95', '7679022140', 100.00, 'SETTLEMENT', 'APPROVED', 'Approved by admin', '2026-02-14 15:42:18', '2026-02-14 15:42:30', '6239572985'),
(2, 'FRAD931F084CA1', '7679022140', 10.00, 'TOPUP', 'APPROVED', 'Manual topup by admin', '2026-02-14 16:22:46', '2026-02-14 16:22:46', '6239572985'),
(3, 'FR7B7A286441A9', '7679022140', 10.00, 'TOPUP', 'APPROVED', 'Manual topup by admin', '2026-02-14 16:34:06', '2026-02-14 16:34:06', '6239572985'),
(4, 'FR202602142216461c0e7c', '7679022140', 10.00, 'SETTLEMENT', 'APPROVED', 'Approved by admin', '2026-02-14 16:46:46', '2026-02-14 16:46:53', '6239572985'),
(5, 'FR20260214230601c73f6f', '7679022140', 100.00, 'SETTLEMENT', 'APPROVED', 'Approved by admin', '2026-02-14 17:36:01', '2026-02-14 17:36:07', '6239572985'),
(6, 'FR20260214231555b4b4cc', '7679022140', 100.00, 'SETTLEMENT', 'APPROVED', 'Approved by admin', '2026-02-14 17:45:55', '2026-02-14 17:46:04', '6239572985'),
(7, 'FR6AFDE91C3812', '7679022140', 10.00, 'TOPUP', 'APPROVED', 'Manual topup by admin', '2026-02-14 17:48:37', '2026-02-14 17:48:37', '6239572985'),
(8, 'FR5AD0A5D423AC', '7679022140', 100.00, 'TOPUP', 'APPROVED', 'Manual topup by admin', '2026-02-14 17:48:53', '2026-02-14 17:48:53', '6239572985'),
(9, 'FR44174876DB65', '7679022140', 100.00, 'TOPUP', 'APPROVED', 'Manual topup by admin', '2026-02-14 17:50:04', '2026-02-14 17:50:04', '6239572985'),
(10, 'FRC41486F8DF5A', '7679022140', 10.00, 'TOPUP', 'APPROVED', 'Manual topup by admin', '2026-02-14 17:50:14', '2026-02-14 17:50:14', '6239572985'),
(11, 'FRE99F55D43D37', '7679022140', 10.00, 'TOPUP', 'APPROVED', 'Manual topup by admin', '2026-02-14 17:50:26', '2026-02-14 17:50:26', '6239572985'),
(12, 'FR57F067B85E5C', '7679022140', 10.00, 'TOPUP', 'APPROVED', 'Manual topup by admin', '2026-02-14 17:51:08', '2026-02-14 17:51:08', '6239572985'),
(13, 'FRE52BC6CD0B65', '7679022140', 10.00, 'TOPUP', 'APPROVED', 'Manual topup by admin', '2026-02-14 17:52:20', '2026-02-14 17:52:20', '6239572985'),
(14, 'FRD924BB61C73E', '7679022140', 10.00, 'TOPUP', 'APPROVED', 'Manual topup by admin', '2026-02-14 17:52:26', '2026-02-14 17:52:26', '6239572985'),
(15, 'FRA8CCEFB695EE', '7679022140', 600.00, 'TOPUP', 'APPROVED', 'Manual topup by admin', '2026-02-14 18:03:56', '2026-02-14 18:03:56', '6239572985'),
(16, 'FRC0F8D8DEA486', '7679022140', 100.00, 'TOPUP', 'APPROVED', 'Manual topup by admin', '2026-02-14 18:07:14', '2026-02-14 18:07:14', '6239572985'),
(17, 'FR202602142337283583bf', '7679022140', 100.00, 'SETTLEMENT', 'APPROVED', 'Approved by admin', '2026-02-14 18:07:28', '2026-02-14 18:07:34', '6239572985');

-- --------------------------------------------------------

--
-- Table structure for table `merchants`
--

CREATE TABLE `merchants` (
  `id` int(11) NOT NULL,
  `merchant_id` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `pin_hash` varchar(255) DEFAULT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `dob` date DEFAULT NULL,
  `aadhar_card` varchar(20) NOT NULL,
  `pan_no` varchar(20) NOT NULL,
  `pincode` varchar(10) NOT NULL,
  `state` varchar(100) NOT NULL,
  `city` varchar(100) NOT NULL,
  `house_number` varchar(100) DEFAULT NULL,
  `address` text NOT NULL,
  `landmark` varchar(255) DEFAULT NULL,
  `merchant_type` enum('PAYIN','PAYOUT','BOTH') NOT NULL,
  `account_number` varchar(50) NOT NULL,
  `ifsc_code` varchar(20) NOT NULL,
  `gst_no` varchar(50) NOT NULL,
  `scheme_id` int(11) DEFAULT NULL,
  `authorization_key` varchar(255) NOT NULL,
  `module_secret` varchar(255) NOT NULL,
  `aes_iv` varchar(255) NOT NULL,
  `aes_key` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_by` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `password_changed_at` timestamp NULL DEFAULT NULL,
  `pin_changed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merchants`
--

INSERT INTO `merchants` (`id`, `merchant_id`, `password_hash`, `pin_hash`, `full_name`, `email`, `mobile`, `dob`, `aadhar_card`, `pan_no`, `pincode`, `state`, `city`, `house_number`, `address`, `landmark`, `merchant_type`, `account_number`, `ifsc_code`, `gst_no`, `scheme_id`, `authorization_key`, `module_secret`, `aes_iv`, `aes_key`, `is_active`, `created_by`, `created_at`, `updated_at`, `password_changed_at`, `pin_changed_at`) VALUES
(2, '7679022140', '$2b$12$AM4Pvblhn1LEw5m/LkaGteOSnXBmYEg9pS/0vJQjfCgJQiO2J5Bf.', '$2b$12$lQ0xP/NAzo9OdXA2atSL0eQJQANUAYo73IMMiB23p/Odz3UXY3uX.', 'Test User', 'sohamkarmakar72@gmail.com', '7679022140', '2003-09-02', '456789259845', 'AFOPZ3287K', '206001', 'West Bengal', 'Kolkata', '100/1', 'XYZ Road', 'SUDAN', 'BOTH', '1234567890123', 'PAYTM0001', '27ABCDE1234F1Z5', 1, 'mk_live_89dede1f774061e8ac5fc035bb47a6fcd1a71323419ad83297f0781a', 'sk_live_feedf4b9e3cd1de91f26fe08', 'jQ5-yrd3V0TQPb_c', '7e50959b9f73a6ed9442140cb0', 1, '6239572985', '2026-02-13 19:27:58', '2026-02-13 20:20:06', '2026-02-13 20:19:08', '2026-02-13 20:20:06'),
(3, 'TEST001', '$2b$12$fXY8Xa3L5LY3X2VCfCrPYeuNnjVtOVWIlgBi6z2ZskTjswfxNgvGG', NULL, 'Test Merchant', 'test@merchant.com', '9876543210', NULL, '123456789012', 'ABCDE1234F', '400001', 'Maharashtra', 'Mumbai', NULL, 'Test Address', NULL, 'BOTH', '1234567890', 'SBIN0001234', '27ABCDE1234F1Z5', 4, '97CByPByZpmGxsVkMuUt7x2tfhRik4O-hY_zshxcwD0', 'KDaYokukj7694mOASeVWVTQl04hc29x57Ydet-CyScU', 'd0302775b2a134d0d38b26bded371c15', 'e036f3930898b0815d913e8a0ee9ae39ea88c8b5d9a032c05c0f4880d9c6142c', 1, '6239572985', '2026-02-13 19:33:31', '2026-02-14 14:15:28', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `merchant_banks`
--

CREATE TABLE `merchant_banks` (
  `id` int(11) NOT NULL,
  `merchant_id` varchar(50) NOT NULL,
  `bank_name` varchar(255) NOT NULL,
  `account_number` varchar(50) NOT NULL,
  `ifsc_code` varchar(20) NOT NULL,
  `branch_name` varchar(255) DEFAULT NULL,
  `account_holder_name` varchar(255) NOT NULL,
  `tpin_hash` varchar(255) NOT NULL,
  `is_settlement_enabled` tinyint(1) DEFAULT 0,
  `settlement_bank_status` enum('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merchant_banks`
--

INSERT INTO `merchant_banks` (`id`, `merchant_id`, `bank_name`, `account_number`, `ifsc_code`, `branch_name`, `account_holder_name`, `tpin_hash`, `is_settlement_enabled`, `settlement_bank_status`, `is_active`, `created_at`, `updated_at`) VALUES
(2, '7679022140', 'Jio Payments Bank', '003521711678324', 'JIOP0000001', 'Null', 'Soham Karmakar', '$2b$12$/ImX/342vBYxtwXNS7mWxeLYsmgJoqkOpx0BZtVG/n338YocCMKhy', 0, 'PENDING', 1, '2026-02-21 17:17:16', '2026-02-21 17:17:16');

-- --------------------------------------------------------

--
-- Table structure for table `merchant_callbacks`
--

CREATE TABLE `merchant_callbacks` (
  `id` int(11) NOT NULL,
  `merchant_id` varchar(50) NOT NULL,
  `payin_callback_url` varchar(500) DEFAULT NULL,
  `payout_callback_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merchant_callbacks`
--

INSERT INTO `merchant_callbacks` (`id`, `merchant_id`, `payin_callback_url`, `payout_callback_url`, `created_at`, `updated_at`) VALUES
(2, '7679022140', NULL, NULL, '2026-02-13 19:27:58', '2026-02-13 19:27:58');

-- --------------------------------------------------------

--
-- Table structure for table `merchant_documents`
--

CREATE TABLE `merchant_documents` (
  `id` int(11) NOT NULL,
  `merchant_id` varchar(50) NOT NULL,
  `aadhar_front_path` varchar(500) DEFAULT NULL,
  `aadhar_back_path` varchar(500) DEFAULT NULL,
  `pan_card_path` varchar(500) DEFAULT NULL,
  `gst_certificate_path` varchar(500) DEFAULT NULL,
  `cancelled_cheque_path` varchar(500) DEFAULT NULL,
  `shop_photo_path` varchar(500) DEFAULT NULL,
  `profile_photo_path` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merchant_documents`
--

INSERT INTO `merchant_documents` (`id`, `merchant_id`, `aadhar_front_path`, `aadhar_back_path`, `pan_card_path`, `gst_certificate_path`, `cancelled_cheque_path`, `shop_photo_path`, `profile_photo_path`, `created_at`, `updated_at`) VALUES
(2, '7679022140', 'uploads/merchant_documents\\7679022140_aadharFront_moneyone.png', 'uploads/merchant_documents\\7679022140_aadharBack_moneyone.png', 'uploads/merchant_documents\\7679022140_panCard_moneyone.png', 'uploads/merchant_documents\\7679022140_gstCertificate_moneyone.png', NULL, 'uploads/merchant_documents\\7679022140_shopPhoto_moneyone.png', 'uploads/merchant_documents\\7679022140_profilePhoto_moneyone.png', '2026-02-13 19:27:58', '2026-02-13 19:27:58');

-- --------------------------------------------------------

--
-- Table structure for table `merchant_ip_whitelist`
--

CREATE TABLE `merchant_ip_whitelist` (
  `id` int(11) NOT NULL,
  `merchant_id` varchar(50) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `merchant_unsettled_wallet`
--

CREATE TABLE `merchant_unsettled_wallet` (
  `id` int(11) NOT NULL,
  `merchant_id` varchar(50) NOT NULL,
  `balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merchant_unsettled_wallet`
--

INSERT INTO `merchant_unsettled_wallet` (`id`, `merchant_id`, `balance`, `last_updated`) VALUES
(1, 'TEST001', 0.00, '2026-02-14 14:15:28'),
(2, '7679022140', 410.00, '2026-02-14 18:07:34');

-- --------------------------------------------------------

--
-- Table structure for table `merchant_wallet`
--

CREATE TABLE `merchant_wallet` (
  `id` int(11) NOT NULL,
  `merchant_id` varchar(50) NOT NULL,
  `balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merchant_wallet`
--

INSERT INTO `merchant_wallet` (`id`, `merchant_id`, `balance`, `last_updated`) VALUES
(1, '7679022140', 241.50, '2026-02-22 11:01:15'),
(2, 'TEST001', 50000.00, '2026-02-14 14:15:28');

-- --------------------------------------------------------

--
-- Table structure for table `merchant_wallet_transactions`
--

CREATE TABLE `merchant_wallet_transactions` (
  `id` int(11) NOT NULL,
  `merchant_id` varchar(50) NOT NULL,
  `txn_id` varchar(100) NOT NULL,
  `txn_type` enum('CREDIT','DEBIT','HOLD','RELEASE') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `balance_before` decimal(15,2) NOT NULL,
  `balance_after` decimal(15,2) NOT NULL,
  `on_hold_before` decimal(15,2) DEFAULT 0.00,
  `on_hold_after` decimal(15,2) DEFAULT 0.00,
  `description` text DEFAULT NULL,
  `reference_id` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merchant_wallet_transactions`
--

INSERT INTO `merchant_wallet_transactions` (`id`, `merchant_id`, `txn_id`, `txn_type`, `amount`, `balance_before`, `balance_after`, `on_hold_before`, `on_hold_after`, `description`, `reference_id`, `created_at`) VALUES
(1, '7679022140', 'MWT202602142150467470D9', 'CREDIT', 100.00, 1071.50, 1171.50, 0.00, 0.00, 'Topup from admin', '', '2026-02-14 16:20:46'),
(2, '7679022140', 'MWT20260214230720FDFC41', 'DEBIT', 30.00, 1171.50, 1141.50, 0.00, 0.00, 'Fund fetched by admin - cheat', 'cheat', '2026-02-14 17:37:20'),
(3, '7679022140', 'MWT2026021423253745B419', 'DEBIT', 600.00, 1141.50, 541.50, 0.00, 0.00, 'Fund fetched by admin - aaa', 'aaa', '2026-02-14 17:55:37'),
(4, '7679022140', 'MWT20260214233751E032CC', 'DEBIT', 200.00, 541.50, 341.50, 0.00, 0.00, 'Fund fetched by admin - aaa', 'aaa', '2026-02-14 18:07:51'),
(5, '7679022140', 'MWT20260222163115D137B9', 'DEBIT', 100.00, 341.50, 241.50, 0.00, 0.00, 'Fund fetched by admin - cheat', 'cheat', '2026-02-22 11:01:15');

-- --------------------------------------------------------

--
-- Table structure for table `payin_transactions`
--

CREATE TABLE `payin_transactions` (
  `id` int(11) NOT NULL,
  `txn_id` varchar(100) NOT NULL,
  `merchant_id` varchar(50) NOT NULL,
  `order_id` varchar(100) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `charge_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `charge_type` enum('PERCENTAGE','FIXED') NOT NULL DEFAULT 'FIXED',
  `net_amount` decimal(15,2) NOT NULL,
  `payee_name` varchar(255) DEFAULT NULL,
  `payee_email` varchar(255) DEFAULT NULL,
  `payee_mobile` varchar(20) DEFAULT NULL,
  `product_info` varchar(500) DEFAULT NULL,
  `status` enum('INITIATED','PENDING','SUCCESS','FAILED','CANCELLED') NOT NULL DEFAULT 'INITIATED',
  `pg_partner` varchar(50) DEFAULT 'PayU',
  `pg_txn_id` varchar(100) DEFAULT NULL,
  `bank_ref_no` varchar(100) DEFAULT NULL,
  `payment_mode` varchar(50) DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `callback_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payin_transactions`
--

INSERT INTO `payin_transactions` (`id`, `txn_id`, `merchant_id`, `order_id`, `amount`, `charge_amount`, `charge_type`, `net_amount`, `payee_name`, `payee_email`, `payee_mobile`, `product_info`, `status`, `pg_partner`, `pg_txn_id`, `bank_ref_no`, `payment_mode`, `error_message`, `remarks`, `callback_url`, `created_at`, `updated_at`, `completed_at`) VALUES
(1, 'PAYIN_7679022140_744_20260214145752', '7679022140', '744', 10.00, 0.00, 'FIXED', 10.00, 'Test ', 'sohamkarmakar72@gmail.com', '7679022140', 'Payment', 'FAILED', 'PayU', NULL, NULL, NULL, 'Manually marked as failed by admin', 'aaaa', NULL, '2026-02-14 09:27:52', '2026-02-14 10:46:42', NULL),
(2, 'PAYIN_7679022140_112_20260214150305', '7679022140', '112', 10.00, 0.00, 'FIXED', 10.00, 'Test ', 'sohamkarmakar72@gmail.com', '7679022140', 'Payment', 'SUCCESS', 'PayU', 'MANUAL_0214150305', 'ADMIN_14150305', 'MANUAL', NULL, 'aaaa', NULL, '2026-02-14 09:33:05', '2026-02-14 10:48:23', '2026-02-14 10:48:23'),
(3, 'PAYIN_7679022140_TEST001_20260214154336', '7679022140', 'TEST001', 10.00, 0.00, 'FIXED', 10.00, 'John Doe', 'sohamkarmakar72@gmail.com', '9876543210', 'Payment', 'INITIATED', 'PayU', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-14 10:13:36', '2026-02-14 10:13:36', NULL),
(4, 'PAYIN_7679022140_1111_20260214162107', '7679022140', '1111', 1000.00, 35.00, 'PERCENTAGE', 965.00, 'Test ', 'sohamkarmakar72@gmail.com', '7679022140', 'Payment', 'SUCCESS', 'PayU', 'MANUAL_0214162107', 'ADMIN_14162107', 'MANUAL', NULL, 'done', NULL, '2026-02-14 10:51:07', '2026-02-14 15:37:49', '2026-02-14 15:37:49'),
(5, 'PAYIN_7679022140_113_20260214162811', '7679022140', '113', 100.00, 3.50, 'PERCENTAGE', 96.50, 'Test ', 'sohamkarmakar72@gmail.com', '7679022140', 'Payment', 'INITIATED', 'PayU', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-14 10:58:11', '2026-02-14 10:58:11', NULL),
(6, 'PAYIN_7679022140_145_20260214163518', '7679022140', '145', 100.00, 3.50, 'PERCENTAGE', 96.50, 'Soham Board of Secondary', 'sohamkarmakar72@gmail.com', '7679022140', 'Payment', 'INITIATED', 'PayU', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-14 11:05:18', '2026-02-14 11:05:18', NULL),
(7, 'PAYIN_7679022140_TEST001_20260214165022', '7679022140', 'TEST001', 100.00, 3.50, 'PERCENTAGE', 96.50, 'John Doe', 'john@example.com', '9876543210', 'Payment', 'SUCCESS', 'PayU', 'MANUAL_0214165022', 'ADMIN_14165022', 'MANUAL', NULL, 'donee', NULL, '2026-02-14 11:20:22', '2026-02-14 15:57:21', '2026-02-14 15:57:21'),
(8, 'PAYIN_7679022140_TEST121_20260214170000', '7679022140', 'TEST121', 1000.00, 35.00, 'PERCENTAGE', 965.00, 'Abhisek Doe', 'john@gmail.com', '9876444444', 'Payment', 'INITIATED', 'PayU', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-14 11:30:00', '2026-02-14 11:30:00', NULL),
(9, 'PAYIN_7679022140_789456_20260214170322', '7679022140', '789456', 100.00, 3.50, 'PERCENTAGE', 96.50, 'Abhisek ', 'abh@gmail.com', '7894561230', 'Payment', 'INITIATED', 'PayU', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-14 11:33:22', '2026-02-14 11:33:22', NULL),
(10, 'PAYIN_7679022140_111111_20260214201236', '7679022140', '111111', 10000.00, 350.00, 'PERCENTAGE', 9650.00, 'Abhisek ', 'abh@gmail.com', '7894561230', 'Payment', 'INITIATED', 'PayU', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-14 14:42:36', '2026-02-14 14:42:36', NULL),
(11, 'PAYIN_7679022140_12345_20260214212918', '7679022140', '12345', 100.00, 3.50, 'PERCENTAGE', 96.50, 'Soham Karmakar', 'soham@gmail.com', '7679022140', 'Payment', 'INITIATED', 'PayU', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-14 15:59:18', '2026-02-14 15:59:18', NULL),
(12, 'MUDRAPE_7679022140_ORD1771736988117774_20260222103949', '7679022140', 'ORD1771736988117774', 400.00, 14.00, 'PERCENTAGE', 386.00, 'Soham Karmakar', 'sohamkarmakar72@gmail.com', '7679022140', 'Payment', 'INITIATED', 'Mudrape', 'TPAY202602220509573985642', NULL, NULL, NULL, NULL, NULL, '2026-02-22 05:09:56', '2026-02-22 05:09:56', NULL),
(13, 'PAYIN_7679022140_ODR12322454347543534_20260222153048', '7679022140', 'ODR12322454347543534', 400.00, 14.00, 'PERCENTAGE', 386.00, 'Soham Karmakar', 'sohamkarmakar2003@gmail.com', '7679022140', 'Payment', 'INITIATED', 'PayU', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-22 10:00:48', '2026-02-22 10:00:48', NULL),
(14, 'MUDRAPE_7679022140_ODR12322454347222534_20260222153347', '7679022140', 'ODR12322454347222534', 400.00, 14.00, 'PERCENTAGE', 386.00, 'Soham Karmakar', 'sohamkarmakar2003@gmail.com', '7679022140', 'Payment', 'INITIATED', 'Mudrape', 'TPAY202602221003557783590', NULL, NULL, NULL, NULL, NULL, '2026-02-22 10:03:55', '2026-02-22 10:03:55', NULL),
(15, 'MUDRAPE_7679022140_ORD1771757545443761_20260222162226', '7679022140', 'ORD1771757545443761', 400.00, 14.00, 'PERCENTAGE', 386.00, 'Soham Karmakar', 'sohamkarmakar72@gmail.com', '7679022140', 'Payment', 'INITIATED', 'Mudrape', 'TPAY202602221052336945226', NULL, NULL, NULL, NULL, NULL, '2026-02-22 10:52:33', '2026-02-22 10:52:33', NULL),
(16, 'PAYIN_7679022140_ORD1771757972591637_20260222162933', '7679022140', 'ORD1771757972591637', 100.00, 3.50, 'PERCENTAGE', 96.50, 'Soham Karmakar', 'sohamkarmakar72@gmail.com', '7679022140', 'Payment', 'INITIATED', 'PayU', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-22 10:59:33', '2026-02-22 10:59:33', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `payout_transactions`
--

CREATE TABLE `payout_transactions` (
  `id` int(11) NOT NULL,
  `txn_id` varchar(100) NOT NULL,
  `merchant_id` varchar(50) DEFAULT NULL,
  `admin_id` varchar(50) DEFAULT NULL,
  `reference_id` varchar(100) NOT NULL,
  `batch_id` varchar(100) DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `charge_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `charge_type` enum('PERCENTAGE','FIXED') NOT NULL DEFAULT 'FIXED',
  `net_amount` decimal(15,2) NOT NULL,
  `bene_name` varchar(255) NOT NULL,
  `bene_email` varchar(255) DEFAULT NULL,
  `bene_mobile` varchar(20) DEFAULT NULL,
  `bene_bank` varchar(255) DEFAULT NULL,
  `ifsc_code` varchar(20) DEFAULT NULL,
  `account_no` varchar(50) DEFAULT NULL,
  `vpa` varchar(100) DEFAULT NULL,
  `payment_type` enum('IMPS','NEFT','RTGS','UPI') NOT NULL DEFAULT 'IMPS',
  `purpose` varchar(500) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `status` enum('INITIATED','QUEUED','INPROCESS','SUCCESS','FAILED','REVERSED') NOT NULL DEFAULT 'INITIATED',
  `pg_partner` varchar(50) DEFAULT 'PayU',
  `pg_txn_id` varchar(100) DEFAULT NULL,
  `bank_ref_no` varchar(100) DEFAULT NULL,
  `utr` varchar(100) DEFAULT NULL,
  `name_with_bank` varchar(255) DEFAULT NULL,
  `name_match_score` int(11) DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `callback_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payout_transactions`
--

INSERT INTO `payout_transactions` (`id`, `txn_id`, `merchant_id`, `admin_id`, `reference_id`, `batch_id`, `amount`, `charge_amount`, `charge_type`, `net_amount`, `bene_name`, `bene_email`, `bene_mobile`, `bene_bank`, `ifsc_code`, `account_no`, `vpa`, `payment_type`, `purpose`, `mobile`, `status`, `pg_partner`, `pg_txn_id`, `bank_ref_no`, `utr`, `name_with_bank`, `name_match_score`, `error_message`, `remarks`, `callback_url`, `created_at`, `updated_at`, `completed_at`) VALUES
(1, 'TXN0B0C9F9E2BE8', NULL, '6239572985', 'ADMIN202602142207095701E0', NULL, 100.00, 0.00, 'FIXED', 0.00, 'sssss', NULL, NULL, 'test account', 'IFSC0011', '1234567890', NULL, 'IMPS', NULL, NULL, '', 'PayU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-14 16:37:09', '2026-02-14 16:37:09', NULL),
(2, 'TXN8674B6368220', NULL, '6239572985', 'ADMIN20260214220721A6B79D', NULL, 100.00, 0.00, 'FIXED', 0.00, 'sssss', NULL, NULL, 'test account', 'IFSC0011', '1234567890', NULL, 'IMPS', NULL, NULL, '', 'PayU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-14 16:37:21', '2026-02-14 16:37:21', NULL),
(3, 'TXNF8D449682E2A', '7679022140', NULL, 'SF2026021422242180254C', NULL, 110.00, 0.55, 'PERCENTAGE', 109.45, 'Test User', NULL, NULL, 'JIO PAYMENTS BANK', '154499652261', '20011020520600', NULL, 'IMPS', NULL, NULL, '', 'PayU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-14 16:54:21', '2026-02-14 16:54:21', NULL),
(4, 'TXN64DDECC3B3B9', '6239572985', NULL, 'ADMIN20260221222059E67A38', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'INITIATED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-21 16:50:59', '2026-02-21 16:50:59', NULL),
(5, 'TXN1E7827F7FEE4', '6239572985', NULL, 'ADMIN2026022122210649272E', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'INITIATED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-21 16:51:06', '2026-02-21 16:51:06', NULL),
(6, 'TXN7117D9F0296E', '6239572985', NULL, 'ADMIN202602212224321311BA', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'INITIATED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-21 16:54:32', '2026-02-21 16:54:32', NULL),
(7, 'TXNE3955B8C1FE8', '6239572985', NULL, 'ADMIN2026022122244421BA70', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'INITIATED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-21 16:54:44', '2026-02-21 16:54:44', NULL),
(8, 'TXNDF66A93E2FEF', '6239572985', NULL, 'ADMIN20260221222457A35CD0', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'INITIATED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-21 16:54:57', '2026-02-21 16:54:57', NULL),
(9, 'TXNDA317DC2A91E', '6239572985', NULL, 'ADMIN202602212232410F36C2', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'INITIATED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-21 17:02:41', '2026-02-21 17:02:41', NULL),
(10, 'TXN004382A6F6F4', '6239572985', NULL, 'ADMIN202602212234468D6194', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'INITIATED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-21 17:04:46', '2026-02-21 17:04:46', NULL),
(11, 'TXN2899F9340755', '6239572985', NULL, 'ADMIN20260221223618D6F281', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'INITIATED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-21 17:06:18', '2026-02-21 17:06:18', NULL),
(12, 'TXNCF310EA65704', '6239572985', NULL, 'ADMIN2026022122363318621C', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'INITIATED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-21 17:06:33', '2026-02-21 17:06:33', NULL),
(13, 'TXN71F777361DD4', '6239572985', NULL, 'ADMIN20260221223814B67943', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'INITIATED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-21 17:08:14', '2026-02-21 17:08:14', NULL),
(14, 'TXN0A5C6DEA064C', '6239572985', NULL, 'ADMIN202602212240095C27BA', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'FAILED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, 'Mudrape API error: {\"success\":false,\"message\":\"Insufficient balance in SETTLEMENT wallet. Available: ₹0.00, Required: ₹1.00\"}', NULL, NULL, '2026-02-21 17:10:09', '2026-02-21 17:10:14', NULL),
(15, 'TXNA6D2C6A3787D', '7679022140', NULL, 'SF20260221224051B5E275', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Test User', NULL, NULL, 'JIO PAYMENTS BANK', '154499652261', '20011020520600', NULL, 'IMPS', NULL, NULL, 'FAILED', 'PayU', NULL, NULL, NULL, NULL, NULL, 'Transfer initiation failed: {\"timestamp\":\"2026-02-21T17:10:55.987+0000\",\"status\":400,\"error\":\"Missing request header \'pid\' for method parameter of type Long\",\"message\":\"Missing request header \'pid\' for method parameter of type Long\",\"path\":\"/payout/v2/payment\"}', NULL, NULL, '2026-02-21 17:10:51', '2026-02-21 17:10:53', NULL),
(16, 'TXN44BAC3D1D6A6', '7679022140', NULL, 'SF202602212242565E8C4F', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Test User', NULL, NULL, 'JIO PAYMENTS BANK', '154499652261', '20011020520600', NULL, 'IMPS', NULL, NULL, 'FAILED', 'PayU', NULL, NULL, NULL, NULL, NULL, 'Transfer initiation failed: {\"timestamp\":\"2026-02-21T17:13:00.256+0000\",\"status\":400,\"error\":\"Missing request header \'pid\' for method parameter of type Long\",\"message\":\"Missing request header \'pid\' for method parameter of type Long\",\"path\":\"/payout/v2/payment\"}', NULL, NULL, '2026-02-21 17:12:56', '2026-02-21 17:12:57', NULL),
(17, 'TXNA75E3877F091', '7679022140', NULL, 'SF202602212245455BA044', NULL, 520.00, 2.60, 'PERCENTAGE', 517.40, 'Test User', NULL, NULL, 'JIO PAYMENTS BANK', '154499652261', '20011020520600', NULL, 'IMPS', NULL, NULL, 'FAILED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, 'Mudrape API error: {\"success\":false,\"message\":\"Invalid IFSC Code format. Format: AAAA0XXXXXX (e.g., HDFC0001234)\"}', NULL, NULL, '2026-02-21 17:15:45', '2026-02-21 17:15:47', NULL),
(18, 'TXN59BD779B712A', '7679022140', NULL, 'SF20260221224746F4FD42', NULL, 520.00, 2.60, 'PERCENTAGE', 517.40, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'FAILED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, 'Mudrape API error: {\"success\":false,\"message\":\"Insufficient balance in SETTLEMENT wallet. Available: ₹0.00, Required: ₹517.40\"}', NULL, NULL, '2026-02-21 17:17:46', '2026-02-21 17:17:49', NULL),
(19, 'TXNB7DFB350D3B9', '6239572985', NULL, 'ADMIN2026022210180785098F', NULL, 100.00, 0.00, 'FIXED', 100.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'FAILED', 'Mudrape', NULL, NULL, NULL, NULL, NULL, 'Mudrape API error: {\"success\":false,\"message\":\"Insufficient balance in SETTLEMENT wallet. Available: ₹0.00, Required: ₹100.00\"}', NULL, NULL, '2026-02-22 04:48:07', '2026-02-22 04:48:11', NULL),
(20, 'TXNC3EB8A3A9CF7', '6239572985', NULL, 'ADMIN20260222113838DFE48A', NULL, 400.00, 0.00, 'FIXED', 400.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'SUCCESS', 'Mudrape', 'ADMIN20260222113838DFE48A', NULL, '9f57bc4425f67c503f38f0857599cda4', NULL, NULL, NULL, NULL, NULL, '2026-02-22 06:08:46', '2026-02-22 09:47:03', '2026-02-22 09:47:07'),
(21, 'TXN640A289FA4E2', '7679022140', NULL, 'SF2026022211451477CCD6', NULL, 110.00, 0.55, 'PERCENTAGE', 109.45, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'SUCCESS', 'Mudrape', 'SF2026022211451477CCD6', NULL, '59919bd01888fda49cf718ff81e381fc', NULL, NULL, NULL, NULL, NULL, '2026-02-22 06:15:24', '2026-02-22 09:47:08', '2026-02-22 09:47:12'),
(22, 'TXN0ACA990EC0D5', '6239572985', NULL, 'ADMIN20260222115245C396CC', NULL, 5.00, 0.00, 'FIXED', 5.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'SUCCESS', 'Mudrape', 'ADMIN20260222115245C396CC', NULL, '57a01ce3613c94b22a92aa5f86ecdb00', NULL, NULL, NULL, NULL, NULL, '2026-02-22 06:22:52', '2026-02-22 09:47:13', '2026-02-22 09:47:17'),
(23, 'TXN9F602F8BD718', '6239572985', NULL, 'ADMIN2026022212122329A784', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'SUCCESS', 'Mudrape', 'ADMIN2026022212122329A784', NULL, 'd0db75cd313f0729a54a9211d2d4c86b', NULL, NULL, NULL, NULL, NULL, '2026-02-22 06:42:32', '2026-02-22 09:47:18', '2026-02-22 09:47:22'),
(24, 'TXNFD2FE040B46C', '6239572985', NULL, 'ADMIN20260222121840D2DF44', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'SUCCESS', 'Mudrape', 'NIFI64299004482696', NULL, '605312540116', NULL, NULL, NULL, NULL, NULL, '2026-02-22 06:48:40', '2026-02-22 07:02:22', '2026-02-22 06:51:35'),
(25, 'TXN69AEF5DCCB69', '6239572985', NULL, 'ADMIN202602221227254F59F9', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'SUCCESS', 'Mudrape', 'ADMIN202602221227254F59F9', NULL, 'bd8df9f276d56bd1ff528971f973429a', NULL, NULL, NULL, NULL, NULL, '2026-02-22 06:57:34', '2026-02-22 09:47:23', '2026-02-22 09:47:27'),
(26, 'TXN2F459AC30F1E', '6239572985', NULL, 'ADMIN202602221230289E00D8', NULL, 2.00, 0.00, 'FIXED', 2.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'SUCCESS', 'Mudrape', 'ADMIN202602221230289E00D8', NULL, '7c4f7508c28bb3fadc9bff2638b33e42', NULL, NULL, NULL, NULL, NULL, '2026-02-22 07:00:37', '2026-02-22 07:17:01', '2026-02-22 07:17:05'),
(27, 'TXN3C37923D7EF2', '6239572985', NULL, 'ADMIN202602221234359B68F5', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'SUCCESS', 'Mudrape', 'ADMIN202602221234359B68F5', NULL, 'd54a5cabb4dd9ee1a71b1d8460ddfb0b', NULL, NULL, NULL, NULL, NULL, '2026-02-22 07:04:35', '2026-02-22 07:15:01', '2026-02-22 07:15:05'),
(28, 'TXN6D8B23F92CCB', '6239572985', NULL, 'ADMIN2026022212471701045C', NULL, 1.00, 0.00, 'FIXED', 1.00, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank ', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'SUCCESS', 'Mudrape', 'ADMIN2026022212471701045C', NULL, 'e2046dd6b6d3e2218654f076e03537de', NULL, NULL, NULL, NULL, NULL, '2026-02-22 07:17:17', '2026-02-22 07:17:28', '2026-02-22 07:17:32'),
(29, 'TXN7C36DA2B2926', '7679022140', NULL, 'SF20260222155509798550', NULL, 110.00, 0.55, 'PERCENTAGE', 109.45, 'Soham Karmakar', NULL, NULL, 'Jio Payments Bank', 'JIOP0000001', '003521711678324', NULL, 'IMPS', NULL, NULL, 'SUCCESS', 'Mudrape', 'SF20260222155509798550', NULL, 'b47c2520c077ecd799dad36cd746c570', NULL, NULL, NULL, NULL, NULL, '2026-02-22 10:25:09', '2026-02-22 10:25:20', '2026-02-22 10:25:23');

-- --------------------------------------------------------

--
-- Table structure for table `payu_tokens`
--

CREATE TABLE `payu_tokens` (
  `id` int(11) NOT NULL,
  `access_token` text NOT NULL,
  `refresh_token` text DEFAULT NULL,
  `token_type` varchar(50) DEFAULT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `user_uuid` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payu_webhook_config`
--

CREATE TABLE `payu_webhook_config` (
  `id` int(11) NOT NULL,
  `event_type` varchar(100) NOT NULL,
  `webhook_url` varchar(500) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payu_webhook_logs`
--

CREATE TABLE `payu_webhook_logs` (
  `id` int(11) NOT NULL,
  `event_type` varchar(100) NOT NULL,
  `merchant_ref_id` varchar(100) DEFAULT NULL,
  `payu_ref_id` varchar(100) DEFAULT NULL,
  `payload` text DEFAULT NULL,
  `status` enum('RECEIVED','PROCESSED','FAILED') NOT NULL DEFAULT 'RECEIVED',
  `error_message` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `processed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `service_routing`
--

CREATE TABLE `service_routing` (
  `id` int(11) NOT NULL,
  `merchant_id` varchar(50) DEFAULT NULL,
  `service_type` enum('PAYIN','PAYOUT') NOT NULL,
  `routing_type` enum('SINGLE_USER','ALL_USERS') NOT NULL,
  `pg_partner` varchar(50) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `priority` int(11) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `service_routing`
--

INSERT INTO `service_routing` (`id`, `merchant_id`, `service_type`, `routing_type`, `pg_partner`, `is_active`, `priority`, `created_at`, `updated_at`) VALUES
(1, '7679022140', 'PAYIN', 'SINGLE_USER', 'PayU', 0, 1, '2026-02-14 09:17:49', '2026-02-22 10:59:47'),
(3, NULL, 'PAYIN', 'ALL_USERS', 'PayU', 1, 1, '2026-02-14 11:43:35', '2026-02-14 11:43:35'),
(4, '7679022140', 'PAYOUT', 'SINGLE_USER', 'PayU', 0, 1, '2026-02-14 14:17:13', '2026-02-21 17:14:39'),
(5, NULL, 'PAYOUT', 'ALL_USERS', 'PayU', 1, 1, '2026-02-14 17:21:37', '2026-02-14 17:21:37'),
(6, '7679022140', 'PAYIN', 'SINGLE_USER', 'Mudrape', 1, 1, '2026-02-21 15:34:54', '2026-02-22 10:59:47'),
(7, '7679022140', 'PAYOUT', 'SINGLE_USER', 'Mudrape', 1, 1, '2026-02-21 17:14:39', '2026-02-21 17:14:39');

-- --------------------------------------------------------

--
-- Table structure for table `wallet_transactions`
--

CREATE TABLE `wallet_transactions` (
  `id` int(11) NOT NULL,
  `merchant_id` varchar(50) NOT NULL,
  `txn_id` varchar(100) NOT NULL,
  `txn_type` enum('CREDIT','DEBIT') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `balance_before` decimal(15,2) NOT NULL,
  `balance_after` decimal(15,2) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `wallet_transactions`
--

INSERT INTO `wallet_transactions` (`id`, `merchant_id`, `txn_id`, `txn_type`, `amount`, `balance_before`, `balance_after`, `description`, `created_at`) VALUES
(1, '7679022140', 'PAYIN_7679022140_112_20260214150305', 'CREDIT', 10.00, 0.00, 10.00, 'Payin credit - Manual completion by admin. aaaa', '2026-02-14 10:48:23'),
(2, '7679022140', 'PAYIN_7679022140_1111_20260214162107', 'CREDIT', 965.00, 10.00, 975.00, 'Payin credit - Manual completion by admin. done', '2026-02-14 15:37:49'),
(3, '7679022140', 'FT20260214211230', 'CREDIT', 100.00, 0.00, 100.00, 'Fund topup approved - FR202602142112186abb95', '2026-02-14 15:42:30'),
(4, '7679022140', 'PAYIN_7679022140_TEST001_20260214165022', 'CREDIT', 96.50, 975.00, 1071.50, 'Payin credit - Manual completion by admin. donee', '2026-02-14 15:57:21'),
(5, '7679022140', 'FT20260214221653', 'CREDIT', 10.00, 100.00, 110.00, 'Fund topup approved - FR202602142216461c0e7c', '2026-02-14 16:46:53'),
(6, '7679022140', 'FT20260214230607', 'CREDIT', 100.00, 110.00, 210.00, 'Fund topup approved - FR20260214230601c73f6f', '2026-02-14 17:36:07'),
(7, '7679022140', 'FT20260214231604', 'CREDIT', 100.00, 210.00, 310.00, 'Fund topup approved - FR20260214231555b4b4cc', '2026-02-14 17:46:04'),
(8, '7679022140', 'FT20260214233734', 'CREDIT', 100.00, 310.00, 410.00, 'Fund topup approved - FR202602142337283583bf', '2026-02-14 18:07:34');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_activity_logs`
--
ALTER TABLE `admin_activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- Indexes for table `admin_banks`
--
ALTER TABLE `admin_banks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- Indexes for table `admin_users`
--
ALTER TABLE `admin_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admin_id` (`admin_id`);

--
-- Indexes for table `admin_wallet`
--
ALTER TABLE `admin_wallet`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admin_id` (`admin_id`);

--
-- Indexes for table `admin_wallet_transactions`
--
ALTER TABLE `admin_wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_admin_id` (`admin_id`),
  ADD KEY `idx_wallet_type` (`wallet_type`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `callback_logs`
--
ALTER TABLE `callback_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `merchant_id` (`merchant_id`),
  ADD KEY `idx_txn_id` (`txn_id`);

--
-- Indexes for table `commercial_charges`
--
ALTER TABLE `commercial_charges`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_scheme_product` (`scheme_id`,`service_type`,`product_name`);

--
-- Indexes for table `commercial_schemes`
--
ALTER TABLE `commercial_schemes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `scheme_name` (`scheme_name`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `fund_requests`
--
ALTER TABLE `fund_requests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `request_id` (`request_id`),
  ADD KEY `processed_by` (`processed_by`),
  ADD KEY `idx_merchant_id` (`merchant_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `merchants`
--
ALTER TABLE `merchants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `merchant_id` (`merchant_id`),
  ADD UNIQUE KEY `authorization_key` (`authorization_key`),
  ADD UNIQUE KEY `module_secret` (`module_secret`),
  ADD KEY `scheme_id` (`scheme_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `merchant_banks`
--
ALTER TABLE `merchant_banks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `merchant_id` (`merchant_id`);

--
-- Indexes for table `merchant_callbacks`
--
ALTER TABLE `merchant_callbacks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `merchant_id` (`merchant_id`);

--
-- Indexes for table `merchant_documents`
--
ALTER TABLE `merchant_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `merchant_id` (`merchant_id`);

--
-- Indexes for table `merchant_ip_whitelist`
--
ALTER TABLE `merchant_ip_whitelist`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_merchant_ip` (`merchant_id`,`ip_address`);

--
-- Indexes for table `merchant_unsettled_wallet`
--
ALTER TABLE `merchant_unsettled_wallet`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `merchant_id` (`merchant_id`);

--
-- Indexes for table `merchant_wallet`
--
ALTER TABLE `merchant_wallet`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `merchant_id` (`merchant_id`);

--
-- Indexes for table `merchant_wallet_transactions`
--
ALTER TABLE `merchant_wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `txn_id` (`txn_id`),
  ADD KEY `idx_merchant_id` (`merchant_id`),
  ADD KEY `idx_txn_id` (`txn_id`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `payin_transactions`
--
ALTER TABLE `payin_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `txn_id` (`txn_id`),
  ADD KEY `idx_merchant_id` (`merchant_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `payout_transactions`
--
ALTER TABLE `payout_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `txn_id` (`txn_id`),
  ADD KEY `idx_merchant_id` (`merchant_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_reference_id` (`reference_id`),
  ADD KEY `idx_admin_id` (`admin_id`);

--
-- Indexes for table `payu_tokens`
--
ALTER TABLE `payu_tokens`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `payu_webhook_config`
--
ALTER TABLE `payu_webhook_config`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_event` (`event_type`);

--
-- Indexes for table `payu_webhook_logs`
--
ALTER TABLE `payu_webhook_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_event_type` (`event_type`),
  ADD KEY `idx_merchant_ref_id` (`merchant_ref_id`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `service_routing`
--
ALTER TABLE `service_routing`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_routing` (`merchant_id`,`service_type`,`routing_type`,`pg_partner`);

--
-- Indexes for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_merchant_id` (`merchant_id`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_activity_logs`
--
ALTER TABLE `admin_activity_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT for table `admin_banks`
--
ALTER TABLE `admin_banks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `admin_users`
--
ALTER TABLE `admin_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `admin_wallet`
--
ALTER TABLE `admin_wallet`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `admin_wallet_transactions`
--
ALTER TABLE `admin_wallet_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `callback_logs`
--
ALTER TABLE `callback_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `commercial_charges`
--
ALTER TABLE `commercial_charges`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `commercial_schemes`
--
ALTER TABLE `commercial_schemes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `fund_requests`
--
ALTER TABLE `fund_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `merchants`
--
ALTER TABLE `merchants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `merchant_banks`
--
ALTER TABLE `merchant_banks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `merchant_callbacks`
--
ALTER TABLE `merchant_callbacks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `merchant_documents`
--
ALTER TABLE `merchant_documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `merchant_ip_whitelist`
--
ALTER TABLE `merchant_ip_whitelist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `merchant_unsettled_wallet`
--
ALTER TABLE `merchant_unsettled_wallet`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `merchant_wallet`
--
ALTER TABLE `merchant_wallet`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `merchant_wallet_transactions`
--
ALTER TABLE `merchant_wallet_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `payin_transactions`
--
ALTER TABLE `payin_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `payout_transactions`
--
ALTER TABLE `payout_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `payu_tokens`
--
ALTER TABLE `payu_tokens`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payu_webhook_config`
--
ALTER TABLE `payu_webhook_config`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payu_webhook_logs`
--
ALTER TABLE `payu_webhook_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `service_routing`
--
ALTER TABLE `service_routing`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin_activity_logs`
--
ALTER TABLE `admin_activity_logs`
  ADD CONSTRAINT `admin_activity_logs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`admin_id`);

--
-- Constraints for table `admin_banks`
--
ALTER TABLE `admin_banks`
  ADD CONSTRAINT `admin_banks_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`admin_id`) ON DELETE CASCADE;

--
-- Constraints for table `admin_wallet`
--
ALTER TABLE `admin_wallet`
  ADD CONSTRAINT `admin_wallet_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`admin_id`) ON DELETE CASCADE;

--
-- Constraints for table `admin_wallet_transactions`
--
ALTER TABLE `admin_wallet_transactions`
  ADD CONSTRAINT `admin_wallet_transactions_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`admin_id`) ON DELETE CASCADE;

--
-- Constraints for table `callback_logs`
--
ALTER TABLE `callback_logs`
  ADD CONSTRAINT `callback_logs_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE;

--
-- Constraints for table `commercial_charges`
--
ALTER TABLE `commercial_charges`
  ADD CONSTRAINT `commercial_charges_ibfk_1` FOREIGN KEY (`scheme_id`) REFERENCES `commercial_schemes` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `commercial_schemes`
--
ALTER TABLE `commercial_schemes`
  ADD CONSTRAINT `commercial_schemes_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `admin_users` (`admin_id`);

--
-- Constraints for table `fund_requests`
--
ALTER TABLE `fund_requests`
  ADD CONSTRAINT `fund_requests_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fund_requests_ibfk_2` FOREIGN KEY (`processed_by`) REFERENCES `admin_users` (`admin_id`);

--
-- Constraints for table `merchants`
--
ALTER TABLE `merchants`
  ADD CONSTRAINT `merchants_ibfk_1` FOREIGN KEY (`scheme_id`) REFERENCES `commercial_schemes` (`id`),
  ADD CONSTRAINT `merchants_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `admin_users` (`admin_id`);

--
-- Constraints for table `merchant_banks`
--
ALTER TABLE `merchant_banks`
  ADD CONSTRAINT `merchant_banks_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE;

--
-- Constraints for table `merchant_callbacks`
--
ALTER TABLE `merchant_callbacks`
  ADD CONSTRAINT `merchant_callbacks_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE;

--
-- Constraints for table `merchant_documents`
--
ALTER TABLE `merchant_documents`
  ADD CONSTRAINT `merchant_documents_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE;

--
-- Constraints for table `merchant_ip_whitelist`
--
ALTER TABLE `merchant_ip_whitelist`
  ADD CONSTRAINT `merchant_ip_whitelist_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE;

--
-- Constraints for table `merchant_unsettled_wallet`
--
ALTER TABLE `merchant_unsettled_wallet`
  ADD CONSTRAINT `merchant_unsettled_wallet_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE;

--
-- Constraints for table `merchant_wallet`
--
ALTER TABLE `merchant_wallet`
  ADD CONSTRAINT `merchant_wallet_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE;

--
-- Constraints for table `merchant_wallet_transactions`
--
ALTER TABLE `merchant_wallet_transactions`
  ADD CONSTRAINT `merchant_wallet_transactions_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE;

--
-- Constraints for table `payin_transactions`
--
ALTER TABLE `payin_transactions`
  ADD CONSTRAINT `payin_transactions_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE;

--
-- Constraints for table `service_routing`
--
ALTER TABLE `service_routing`
  ADD CONSTRAINT `service_routing_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE;

--
-- Constraints for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD CONSTRAINT `wallet_transactions_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
