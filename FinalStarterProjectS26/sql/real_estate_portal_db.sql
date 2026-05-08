-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 08, 2026 at 03:05 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `real_estate_portal_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddOrUpdateUser` (IN `p_userId` INT, IN `p_userName` VARCHAR(50), IN `p_contactInfo` VARCHAR(200), IN `p_passwordHash` VARCHAR(255), IN `p_userType` ENUM('agent','buyer','renter'))   BEGIN
    IF p_userId IS NULL OR p_userId = 0 THEN
        INSERT INTO Users (userName, contactInfo, passwordHash, userType)
        VALUES (p_userName, p_contactInfo, p_passwordHash, p_userType);
    ELSE
        UPDATE Users
        SET userName = p_userName,
            contactInfo = p_contactInfo,
            passwordHash = p_passwordHash,
            userType = p_userType
        WHERE userId = p_userId;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `HandleTransaction` (IN `p_propertyId` INT, IN `p_userId` INT, IN `p_transactionType` ENUM('sale','rental'), IN `p_amount` DECIMAL(12,2))   BEGIN
    INSERT INTO Transactions (
        propertyId,
        userId,
        transactionType,
        transactionDate,
        amount
    )
    VALUES (
        p_propertyId,
        p_userId,
        p_transactionType,
        NOW(),
        p_amount
    );

    IF p_transactionType = 'sale' THEN
        UPDATE Properties
        SET status = 'sold'
        WHERE propertyId = p_propertyId;

    ELSEIF p_transactionType = 'rental' THEN
        UPDATE Properties
        SET status = 'rented'
        WHERE propertyId = p_propertyId;
    END IF;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `favoriteId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `propertyId` int(11) NOT NULL,
  `savedDate` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `favorites`
--

INSERT INTO `favorites` (`favoriteId`, `userId`, `propertyId`, `savedDate`) VALUES
(4, 9, 1, '2026-05-04 20:34:48'),
(5, 9, 2, '2026-05-04 20:34:48'),
(6, 9, 7, '2026-05-04 20:34:48');

-- --------------------------------------------------------

--
-- Table structure for table `inquiries`
--

CREATE TABLE `inquiries` (
  `inquiryId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `propertyId` int(11) NOT NULL,
  `message` varchar(255) NOT NULL,
  `inquiryDate` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inquiries`
--

INSERT INTO `inquiries` (`inquiryId`, `userId`, `propertyId`, `message`, `inquiryDate`) VALUES
(4, 9, 7, 'Hello, I am interested in this property. Is it still available?', '2026-05-02 14:46:52'),
(5, 9, 8, 'Hi, is this Bronx condo still available?', '2026-05-04 16:11:18');

-- --------------------------------------------------------

--
-- Table structure for table `properties`
--

CREATE TABLE `properties` (
  `propertyId` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `propertyType` varchar(50) NOT NULL,
  `address` varchar(200) NOT NULL,
  `city` varchar(100) NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `status` enum('available','sold','rented') NOT NULL DEFAULT 'available',
  `agentId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `properties`
--

INSERT INTO `properties` (`propertyId`, `title`, `propertyType`, `address`, `city`, `price`, `status`, `agentId`) VALUES
(1, 'Modern Apartment', 'Apartment', '123 Main St', 'Bronx', 2500.00, 'sold', 1),
(2, 'Family House', 'House', '45 River Rd', 'Queens', 650000.00, 'sold', 1),
(3, 'Studio Rental', 'Studio', '9 Park Ave', 'Manhattan', 1800.00, 'available', 1),
(7, 'Brooklyn condo', 'Condo', '55 Grand Ave', 'Brooklyn', 320000.00, 'sold', 8),
(8, 'Bronx Condo', 'Condo', '455 Fordham road', 'Bronx', 35000.00, 'available', 8);

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `transactionId` int(11) NOT NULL,
  `propertyId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `transactionType` enum('sale','rental') NOT NULL,
  `transactionDate` datetime NOT NULL,
  `amount` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`transactionId`, `propertyId`, `userId`, `transactionType`, `transactionDate`, `amount`) VALUES
(4, 1, 2, 'sale', '2026-04-29 19:40:32', 2500.00),
(5, 7, 9, 'sale', '2026-05-03 09:51:13', 320000.00),
(6, 2, 9, 'sale', '2026-05-03 13:02:50', 650000.00);

--
-- Triggers `transactions`
--
DELIMITER $$
CREATE TRIGGER `AfterTransactionInsert` AFTER INSERT ON `transactions` FOR EACH ROW BEGIN

    IF NEW.transactionType = 'sale' THEN

        UPDATE Properties
        SET status = 'sold'
        WHERE propertyId = NEW.propertyId;

    ELSEIF NEW.transactionType = 'rental' THEN

        UPDATE Properties
        SET status = 'rented'
        WHERE propertyId = NEW.propertyId;

    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `userId` int(11) NOT NULL,
  `userName` varchar(50) NOT NULL,
  `contactInfo` varchar(200) DEFAULT NULL,
  `passwordHash` varchar(255) NOT NULL,
  `userType` enum('agent','buyer','renter') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`userId`, `userName`, `contactInfo`, `passwordHash`, `userType`) VALUES
(1, 'agent1', 'agent1@email.com', '$2y$10hash1', 'agent'),
(2, 'buyer1', 'buyer1@email.com', '$2y$10ehash2', 'buyer'),
(3, 'renter1', 'renter1@email.com', '$2y$10hash3', 'renter'),
(8, 'agent2', 'agent2@email.com', '$2y$10$pgRZJmEPiLoXp2NKFd5mIuEIrF.ObHZVUjzKuWxZp7Z7e.LvvQryO', 'agent'),
(9, 'buyer2', 'buyer2@gmail.com', '$2y$10$YkLhm/ZK4CLI7F6041mNu.HU4W7YdDmX1mNK7.rsmMEReOCKUHnDW', 'buyer'),
(10, 'agent3', 'agent3@email.com', '$2y$10$GSSQOhqpQoEsfYvBqMmGQOR4BHKUFnW0Zg1Eup8UTZ4rNo7d/GLY2', 'agent');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`favoriteId`),
  ADD KEY `userId` (`userId`),
  ADD KEY `propertyId` (`propertyId`);

--
-- Indexes for table `inquiries`
--
ALTER TABLE `inquiries`
  ADD PRIMARY KEY (`inquiryId`),
  ADD KEY `userId` (`userId`),
  ADD KEY `propertyId` (`propertyId`);

--
-- Indexes for table `properties`
--
ALTER TABLE `properties`
  ADD PRIMARY KEY (`propertyId`),
  ADD KEY `agentId` (`agentId`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`transactionId`),
  ADD KEY `propertyId` (`propertyId`),
  ADD KEY `userId` (`userId`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`userId`),
  ADD UNIQUE KEY `userName` (`userName`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `favoriteId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `inquiries`
--
ALTER TABLE `inquiries`
  MODIFY `inquiryId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `propertyId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `transactionId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `favorites`
--
ALTER TABLE `favorites`
  ADD CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`),
  ADD CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`propertyId`) REFERENCES `properties` (`propertyId`);

--
-- Constraints for table `inquiries`
--
ALTER TABLE `inquiries`
  ADD CONSTRAINT `inquiries_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`),
  ADD CONSTRAINT `inquiries_ibfk_2` FOREIGN KEY (`propertyId`) REFERENCES `properties` (`propertyId`);

--
-- Constraints for table `properties`
--
ALTER TABLE `properties`
  ADD CONSTRAINT `properties_ibfk_1` FOREIGN KEY (`agentId`) REFERENCES `users` (`userId`);

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`propertyId`) REFERENCES `properties` (`propertyId`),
  ADD CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
