-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: freelancing_network
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `freelancing_network`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `freelancing_network` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `freelancing_network`;

--
-- Table structure for table `administrator`
--

DROP TABLE IF EXISTS `administrator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `administrator` (
  `admin_id` int NOT NULL AUTO_INCREMENT,
  `admin_name` varchar(100) NOT NULL,
  `admin_email` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `admin_email` (`admin_email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `administrator`
--

LOCK TABLES `administrator` WRITE;
/*!40000 ALTER TABLE `administrator` DISABLE KEYS */;
INSERT INTO `administrator` VALUES (1,'Unathi Spele','unathi@tcn.local','scrypt:32768:8:1$ZuI9qcwRHFxX6rhp$b803ac05f3c5492e5d2d1459a1d59c2651408be98e7d944b964f2e81e2c00ac66c2b3e2b984fd4ba33d538d79a42a2f72d015c11ad7caa02155ab0aa10bbf997'),(2,'Siyambulela Williams','siyambulela@tcn.local','scrypt:32768:8:1$0HcBlaq8sQdkodfL$ca8d7b3096cfcde1e9feb5791c02ca52ce352316e57bc12b29e6b0d6367a921de0c987e94b472277303220c664bfb97b611b89632d1ec92d79ddbe03ec67e255'),(3,'Busisiwe Tyhokolo','busisiwe@tcn.local','scrypt:32768:8:1$0pG6UiFRt9Jz9ErH$7611cf6245fd36b303abb6182a709048d7643710279f5aafebf697e095e872a3576cbe4b07985c8cc437acaae377273bcb8cec1754756562b5620bb3b4644117'),(4,'Thandolwethu Mlaba','thandolwethu@tcn.local','scrypt:32768:8:1$14RB2cvDM4lJYS64$bfdaa05e4843f7ab5e4b0425141e218502f9bb1344e1c5143c9a741813963ea63da117effe8b0d09c497e3b2025132973c133b11d9023c0561cce0a2a948136f'),(5,'Abongile Sima','abongile@tcn.local','scrypt:32768:8:1$b8B5PvWZbJmUJuf4$174e147896c954494b9ef9927bc40abb05181faa83a364bcfda5826cf6c234c98a829bb27bc400ec28fb856d25d35d23d218b04884a7675e97f2ab48fc9315c7');
/*!40000 ALTER TABLE `administrator` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `booking`
--

DROP TABLE IF EXISTS `booking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking` (
  `booking_id` int NOT NULL AUTO_INCREMENT,
  `booking_date` date NOT NULL,
  `scheduled_date` date NOT NULL,
  `scheduled_time` time NOT NULL,
  `booking_status` varchar(15) NOT NULL DEFAULT 'pending',
  `customer_id` int NOT NULL,
  `freelancer_id` int NOT NULL,
  `location_id` int NOT NULL,
  PRIMARY KEY (`booking_id`),
  KEY `customer_id` (`customer_id`),
  KEY `freelancer_id` (`freelancer_id`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `booking_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  CONSTRAINT `booking_ibfk_2` FOREIGN KEY (`freelancer_id`) REFERENCES `freelancer` (`freelancer_id`),
  CONSTRAINT `booking_ibfk_3` FOREIGN KEY (`location_id`) REFERENCES `location` (`location_id`),
  CONSTRAINT `ck_booking_dates` CHECK ((`scheduled_date` >= `booking_date`)),
  CONSTRAINT `ck_booking_status` CHECK ((`booking_status` in (_utf8mb4'pending',_utf8mb4'confirmed',_utf8mb4'completed',_utf8mb4'cancelled')))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking`
--

LOCK TABLES `booking` WRITE;
/*!40000 ALTER TABLE `booking` DISABLE KEYS */;
INSERT INTO `booking` VALUES (1,'2025-03-01','2025-03-05','09:00:00','completed',1,1,1),(2,'2025-03-02','2025-03-07','14:00:00','completed',3,2,5),(3,'2025-03-04','2025-03-09','10:30:00','completed',5,2,2),(4,'2025-03-06','2025-03-12','08:00:00','confirmed',2,5,4),(5,'2025-03-08','2025-03-15','13:00:00','pending',4,3,3),(6,'2026-10-06','2026-10-23','12:00:00','pending',1,1,2);
/*!40000 ALTER TABLE `booking` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_booking_freelancer_verified_insert` BEFORE INSERT ON `booking` FOR EACH ROW BEGIN
    DECLARE v_status VARCHAR(15);

    SELECT verification_status 
    INTO v_status
    FROM freelancer
    WHERE freelancer_id = NEW.freelancer_id;

    IF v_status IS NULL OR v_status <> 'verified' THEN
        SIGNAL SQLSTATE '45000'
            SET MYSQL_ERRNO = 50001,
                MESSAGE_TEXT = 'Only verified freelancers can be booked';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_booking_freelancer_verified_update` BEFORE UPDATE ON `booking` FOR EACH ROW BEGIN
    DECLARE v_status VARCHAR(15);

    IF NEW.freelancer_id <> OLD.freelancer_id THEN
        SELECT verification_status 
        INTO v_status
        FROM freelancer
        WHERE freelancer_id = NEW.freelancer_id;

        IF v_status IS NULL OR v_status <> 'verified' THEN
            SIGNAL SQLSTATE '45000'
                SET MYSQL_ERRNO = 50001,
                    MESSAGE_TEXT = 'Only verified freelancers can be booked';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `booking_service`
--

DROP TABLE IF EXISTS `booking_service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_service` (
  `booking_id` int NOT NULL,
  `service_id` int NOT NULL,
  `hours_booked` decimal(4,1) NOT NULL,
  `agreed_hourly_rate` decimal(7,2) NOT NULL,
  PRIMARY KEY (`booking_id`,`service_id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `booking_service_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`),
  CONSTRAINT `booking_service_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `service` (`service_id`),
  CONSTRAINT `ck_booking_hours` CHECK ((`hours_booked` > 0)),
  CONSTRAINT `ck_booking_rate` CHECK ((`agreed_hourly_rate` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking_service`
--

LOCK TABLES `booking_service` WRITE;
/*!40000 ALTER TABLE `booking_service` DISABLE KEYS */;
INSERT INTO `booking_service` VALUES (1,1,3.0,251.40),(2,2,2.5,180.53),(3,4,4.0,303.86),(4,3,2.0,201.44),(5,5,1.5,220.13),(6,1,2.0,200.00);
/*!40000 ALTER TABLE `booking_service` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `cus_first_name` varchar(50) NOT NULL,
  `cus_last_name` varchar(50) NOT NULL,
  `cus_phone_num` varchar(15) NOT NULL,
  `cus_email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL DEFAULT 'placeholder',
  `profile_pic` varchar(200) DEFAULT 'default.jpg',
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `cus_email` (`cus_email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (1,'Alexandra','Van Heerden','0814447392','alexandra221@gmail.com','scrypt:32768:8:1$36vC37FUW1tqTCn8$61e9bd05ca8ae268d7da7d3fd65e710229dae48ac77ef242453c8ae272cecb2e2fbc6b70695177941160e2b6a57489e3ded1aa177d438fafd5331fe28b40a1ea','profile_customer_1.jpg'),(2,'Kagiso','Sithole','0786543545','kagiso@gmail.com','scrypt:32768:8:1$6LvxoVydT7UX1KKu$36f7d2b3f1e1e8bde2ea163ce38ca2e27e117288cea5805b00283224eb3a00575772484ad60c1ac3c539fba42124c31666ee367ea41159eed3aca9d3aa4d0521','profile_customer_2.jpg'),(3,'Thato','Modau','0734561110','thatohopemodau229@gmail.com','scrypt:32768:8:1$pSLPd4v3di4hePUD$98aa1af032c9f0eb34c57c68000dd18630a0daf029e109e71d1c07d6d73e22ad55fc36302ebe826f93900eae73369eaf5a63b4de3c0e240bb25d9057b4dee294','profile_customer_3.jpg'),(4,'Pieter','van Wyk','0812678901','pieterwyk000@gmail.com','scrypt:32768:8:1$qoai8elCcKxLCa88$5e6061460575c97dd2a4edc6c3445e21e26cc8a5bc73598809d44678e3601ab5666f4b22eb854952ddda10e8a6518ed945effb90d7ae535b0f3d99c6fcca81c8','default.jpg'),(5,'Langelihle','Nkosi','0756789012','langelihle1234@gmail.com','scrypt:32768:8:1$PB41pxHl02ur0FBP$12f89042750e6921fe9ac7af4543fb61e1f5db3b0a327fa3c95bc458e67153b8aa5859260b4525a5aa417bfed98143807f2652560c26354f0dcbe1801095b773','profile_customer_5.jpeg'),(6,'Unathi','Spele','08138953713','unathispele21@gmail.com','scrypt:32768:8:1$rzfh53wYk2C1BOzv$d59f3677d639969a22183aeb1755402b39dfa47992b53340365c4d8e8e40ae349f5aafe1e65903ec178a1f6e509b18db5717e2719123fb0ab4a1ef8cd199387f','profile_customer_6.jpg');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `freelancer`
--

DROP TABLE IF EXISTS `freelancer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `freelancer` (
  `freelancer_id` int NOT NULL AUTO_INCREMENT,
  `f_first_name` varchar(50) NOT NULL,
  `f_last_name` varchar(50) NOT NULL,
  `f_phone_num` varchar(15) NOT NULL,
  `f_email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL DEFAULT 'placeholder',
  `profile_pic` varchar(200) DEFAULT 'default.jpg',
  `verification_status` varchar(15) NOT NULL DEFAULT 'pending',
  `verification_date` date DEFAULT NULL,
  `admin_id` int DEFAULT NULL,
  `bio` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`freelancer_id`),
  UNIQUE KEY `f_email` (`f_email`),
  KEY `admin_id` (`admin_id`),
  CONSTRAINT `freelancer_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `administrator` (`admin_id`),
  CONSTRAINT `ck_freelancer_status` CHECK ((`verification_status` in (_utf8mb4'pending',_utf8mb4'verified',_utf8mb4'rejected',_utf8mb4'suspended'))),
  CONSTRAINT `ck_freelancer_verified` CHECK (((`verification_status` <> _utf8mb4'verified') or ((`admin_id` is not null) and (`verification_date` is not null))))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `freelancer`
--

LOCK TABLES `freelancer` WRITE;
/*!40000 ALTER TABLE `freelancer` DISABLE KEYS */;
INSERT INTO `freelancer` VALUES (1,'Bongani','Mthembu','0812345678','bonganimthembu@gmail.com','scrypt:32768:8:1$J2MXbjrrFYife63d$2498cf26175d96b235009c9f8b3bc95aa0345c9b3c52064949e5c87ee2edd493c3a368c837f02ef9c2f73b161c3363f950a702dc28cbaa5e17a2913624b3a541','profile_freelancer_1.jpeg','verified','2025-01-15',1,'Good when it comes to completing fast jobs'),(2,'Ncedo','Ncabane','0823456789','Ncedoncabane@gmail.com','scrypt:32768:8:1$RLiqbLSzeVU1FTVQ$ced0e9211554795a8e223ee7672eeaec00af982ccd0a44805da16ba22751ff02393de4e284b5de4072e896f311b456972b7dfbafc57e450e29d9a4af848e765e','profile_freelancer_2.jpeg','verified','2025-01-20',1,'Excellent plumbing and electrical skills. I\'m also proficient in math-based subjects for tutoring'),(3,'Sibusiso','Radebe','0834567890','sibusisoradebe293@gmail.com','scrypt:32768:8:1$EHfDrQFxmMUAdxMw$557f42094448ab21a47b680b9c79673477a69de934a6805ff6f37cf9d08b8d18321e43a24f89169fc4771439ccf7452d23baeae74fc0940b3b80a68d7d7ec9e3','default.jpg','verified','2025-02-01',5,NULL),(4,'Nomvula','Sangweni','0845678901','nomvula@gmail.com','scrypt:32768:8:1$vhKv4CifFIYfOKsb$94a1d9ec3dbed8098c555c752f4feced8caf60d9a3f4fce6d5d217c9181c5b5c98cc08d41ba9cdc07973fb67d70d011a2015e99b7844ce87be63d5355473aa5f','default.jpg','pending',NULL,NULL,NULL),(5,'Jabu','Mahlaba','0856789012','jabumahlaba@gmail.com','scrypt:32768:8:1$YjL2eh1Xqfca6JKs$f5edc1e6e618441e31ffd90ba3dfa01435f6da0320498e2e46274695443e8ef2cf1159c3f1b869aecf6f7b4fe85141bdc3da4d339286820b2d3662e373b0ab45','profile_freelancer_5.jpeg','verified','2025-02-10',2,'one community, one mind');
/*!40000 ALTER TABLE `freelancer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `freelancer_service`
--

DROP TABLE IF EXISTS `freelancer_service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `freelancer_service` (
  `freelancer_id` int NOT NULL,
  `service_id` int NOT NULL,
  PRIMARY KEY (`freelancer_id`,`service_id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `freelancer_service_ibfk_1` FOREIGN KEY (`freelancer_id`) REFERENCES `freelancer` (`freelancer_id`),
  CONSTRAINT `freelancer_service_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `service` (`service_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `freelancer_service`
--

LOCK TABLES `freelancer_service` WRITE;
/*!40000 ALTER TABLE `freelancer_service` DISABLE KEYS */;
INSERT INTO `freelancer_service` VALUES (1,1),(2,1),(5,1),(1,2),(2,2),(2,3),(5,3),(2,4),(2,5);
/*!40000 ALTER TABLE `freelancer_service` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location` (
  `location_id` int NOT NULL AUTO_INCREMENT,
  `location_name` varchar(100) NOT NULL,
  `municipality_name` varchar(100) NOT NULL,
  PRIMARY KEY (`location_id`),
  UNIQUE KEY `unique_location` (`location_name`,`municipality_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location`
--

LOCK TABLES `location` WRITE;
/*!40000 ALTER TABLE `location` DISABLE KEYS */;
INSERT INTO `location` VALUES (2,'Alexandra','City of Johannesburg'),(3,'Khayelitsha','City of Cape Town'),(5,'Mamelodi','City of Tshwane'),(1,'Soweto','City of Johannesburg'),(4,'Umlazi','eThekwini');
/*!40000 ALTER TABLE `location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `payment_method` varchar(10) NOT NULL,
  `payment_date` date NOT NULL,
  `payment_amount` decimal(9,2) NOT NULL,
  `payment_status` varchar(10) NOT NULL DEFAULT 'pending',
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `booking_id` (`booking_id`),
  CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`),
  CONSTRAINT `ck_payment_amount` CHECK ((`payment_amount` > 0)),
  CONSTRAINT `ck_payment_method` CHECK ((`payment_method` in (_cp850'cash',_cp850'card',_cp850'eft'))),
  CONSTRAINT `ck_payment_status` CHECK ((`payment_status` in (_cp850'pending',_cp850'paid',_cp850'refunded',_cp850'cancelled')))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment`
--

LOCK TABLES `payment` WRITE;
/*!40000 ALTER TABLE `payment` DISABLE KEYS */;
INSERT INTO `payment` VALUES (1,1,'eft','2025-03-05',754.20,'paid'),(2,2,'cash','2025-03-06',451.33,'paid'),(3,3,'card','2025-03-07',1215.44,'paid'),(4,4,'eft','2025-03-10',402.88,'pending'),(5,5,'cash','2025-03-11',330.20,'pending'),(6,6,'eft','2026-10-06',400.00,'pending');
/*!40000 ALTER TABLE `payment` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_payment_date_after_booking_insert` BEFORE INSERT ON `payment` FOR EACH ROW BEGIN
    DECLARE v_booking_date DATE;

    SELECT booking_date INTO v_booking_date
    FROM booking
    WHERE booking_id = NEW.booking_id;

    IF v_booking_date IS NOT NULL AND NEW.payment_date < v_booking_date THEN
        SIGNAL SQLSTATE '45000'
            SET MYSQL_ERRNO = 50003,
                MESSAGE_TEXT = 'The payment date cannot be before the booking date';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `portfolio_image`
--

DROP TABLE IF EXISTS `portfolio_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `portfolio_image` (
  `image_id` int NOT NULL AUTO_INCREMENT,
  `filename` varchar(200) NOT NULL,
  `caption` varchar(200) DEFAULT NULL,
  `freelancer_id` int NOT NULL,
  PRIMARY KEY (`image_id`),
  KEY `freelancer_id` (`freelancer_id`),
  CONSTRAINT `portfolio_image_ibfk_1` FOREIGN KEY (`freelancer_id`) REFERENCES `freelancer` (`freelancer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `portfolio_image`
--

LOCK TABLES `portfolio_image` WRITE;
/*!40000 ALTER TABLE `portfolio_image` DISABLE KEYS */;
INSERT INTO `portfolio_image` VALUES (1,'electrician_1_1791265523.jpg','',1),(2,'image_2_1791265715.jpeg','',2),(3,'images_2_1791265726.jpeg','',2),(4,'images_3_5_1791265891.jpeg','',5),(5,'images_1_5_1791265899.jpeg','',5),(6,'people-working-in-tech-office_5_1791265908.png','',5);
/*!40000 ALTER TABLE `portfolio_image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review`
--

DROP TABLE IF EXISTS `review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `review` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `rating` tinyint unsigned NOT NULL,
  `review_comment` varchar(300) DEFAULT NULL,
  `review_date` date NOT NULL,
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `booking_id` (`booking_id`),
  CONSTRAINT `review_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`),
  CONSTRAINT `ck_review_rating` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review`
--

LOCK TABLES `review` WRITE;
/*!40000 ALTER TABLE `review` DISABLE KEYS */;
INSERT INTO `review` VALUES (1,1,5,'Excellent plumbing work, very professional!','2025-03-06'),(2,2,1,'The work done on the electrical grid was not done properly. Very disappointed.','2025-03-08'),(3,3,3,'Electrical work was okay but arrived late.','2025-03-10');
/*!40000 ALTER TABLE `review` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_review_booking_completed_insert` BEFORE INSERT ON `review` FOR EACH ROW BEGIN
    DECLARE v_booking_status VARCHAR(15);

    SELECT booking_status INTO v_booking_status
    FROM booking
    WHERE booking_id = NEW.booking_id;

    IF v_booking_status IS NULL OR v_booking_status <> 'completed' THEN
        SIGNAL SQLSTATE '45000'
            SET MYSQL_ERRNO = 50002,
                MESSAGE_TEXT = 'A review can only be added for a completed booking';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `safety_report`
--

DROP TABLE IF EXISTS `safety_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `safety_report` (
  `report_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `report_type` varchar(10) NOT NULL,
  `report_reason` varchar(100) NOT NULL,
  `report_description` varchar(300) DEFAULT NULL,
  `report_date` date NOT NULL,
  `report_status` varchar(15) NOT NULL DEFAULT 'open',
  PRIMARY KEY (`report_id`),
  KEY `booking_id` (`booking_id`),
  CONSTRAINT `safety_report_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`),
  CONSTRAINT `ck_report_status` CHECK ((`report_status` in (_cp850'open',_cp850'investigating',_cp850'resolved',_cp850'dismissed'))),
  CONSTRAINT `ck_report_type` CHECK ((`report_type` in (_cp850'customer',_cp850'freelancer')))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `safety_report`
--

LOCK TABLES `safety_report` WRITE;
/*!40000 ALTER TABLE `safety_report` DISABLE KEYS */;
INSERT INTO `safety_report` VALUES (1,1,'freelancer','Late arrival','Freelancer arrived 30 minutes late.','2025-03-05','dismissed'),(2,2,'customer','Unsafe environment','Customer location had aggressive dogs.','2025-03-07','investigating'),(3,4,'freelancer','Payment delay','Customer paid 2 days after service.','2025-03-12','resolved'),(4,4,'customer','Rude behaviour','Freelancer was rude on arrival.','2025-03-13','open'),(5,5,'freelancer','No-show','Customer was not home at scheduled time.','2025-03-15','open');
/*!40000 ALTER TABLE `safety_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service`
--

DROP TABLE IF EXISTS `service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service` (
  `service_id` int NOT NULL AUTO_INCREMENT,
  `service_name` varchar(100) NOT NULL,
  `service_category_id` int NOT NULL,
  PRIMARY KEY (`service_id`),
  UNIQUE KEY `service_name` (`service_name`),
  KEY `service_category_id` (`service_category_id`),
  CONSTRAINT `service_ibfk_1` FOREIGN KEY (`service_category_id`) REFERENCES `service_category` (`service_category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service`
--

LOCK TABLES `service` WRITE;
/*!40000 ALTER TABLE `service` DISABLE KEYS */;
INSERT INTO `service` VALUES (1,'Plumbing Repairs',1),(2,'Electrical Work',2),(3,'Maths Tutoring',9),(4,'Electrical Wiring',2),(5,'Computer Repair',11),(6,'Cellphone Repair',11),(7,'TV & Satellite Installation',11),(8,'Fridge & Freezer Repair',11),(9,'Washing Machine Repair',11),(10,'Laptop Repair',11),(11,'Car Mechanic',10),(12,'Panel Beating',10),(13,'Car Wash & Valet',10),(14,'Tyre Fitting & Repair',10),(15,'Auto Electrical',10),(16,'Hairdressing & Braiding',6),(17,'Barbering',6),(18,'Makeup Artistry',6),(19,'Nail Technician',6),(20,'Massage Therapy',6),(21,'Bricklaying',3),(22,'Painting & Decorating',3),(23,'Tiling',3),(24,'Roofing & Waterproofing',3),(25,'Carpentry',3),(26,'Welding & Steel Work',3),(27,'Paving',3),(28,'Event Catering',8),(29,'Baking & Cakes',8),(30,'Event Decor & Setup',8),(31,'DJ & Sound Hire',8),(32,'Photography',8),(33,'House Cleaning',4),(34,'Carpet Cleaning',4),(35,'Window Cleaning',4),(36,'Laundry & Ironing',4),(37,'Office Cleaning',4),(38,'DB Board Installation',2),(39,'Solar Panel Installation',2),(40,'Lighting Installation',2),(41,'Electrical Fault Finding',2),(42,'Prepaid Meter Installation',2),(43,'Garden Maintenance',5),(44,'Lawn Mowing',5),(45,'Tree Felling & Pruning',5),(46,'Landscaping & Design',5),(47,'Geyser Installation',1),(48,'Drain Unblocking',1),(49,'Leak Detection & Repair',1),(50,'Tap & Toilet Repair',1),(51,'Borehole & Water Tank Installation',1),(52,'General Handyman',12),(53,'CCTV Installation',12),(54,'Gate & Fence Repair',12),(55,'Locksmith',12),(56,'Electric Fence Installation',12),(57,'Furniture Removals',7),(58,'Courier & Delivery',7),(59,'Airport & Event Transfers',7),(60,'School Transport',7),(61,'Science Tutoring',9),(62,'English Tutoring',9),(63,'Accounting Tutoring',9),(64,'IT & Computer Literacy Training',9),(65,'Early Childhood Care',9);
/*!40000 ALTER TABLE `service` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_category`
--

DROP TABLE IF EXISTS `service_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_category` (
  `service_category_id` int NOT NULL AUTO_INCREMENT,
  `service_category_name` varchar(50) NOT NULL,
  PRIMARY KEY (`service_category_id`),
  UNIQUE KEY `service_category_name` (`service_category_name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_category`
--

LOCK TABLES `service_category` WRITE;
/*!40000 ALTER TABLE `service_category` DISABLE KEYS */;
INSERT INTO `service_category` VALUES (11,'Appliance & Electronics Repair'),(10,'Automotive & Mechanics'),(6,'Beauty & Grooming'),(3,'Building & Renovations'),(8,'Catering & Events'),(4,'Cleaning & Laundry'),(2,'Electrical & Wiring'),(5,'Gardening & Landscaping'),(1,'Plumbing & Water'),(12,'Security & Handyman'),(7,'Transport & Delivery'),(9,'Tutoring & Education');
/*!40000 ALTER TABLE `service_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_category_report`
--

DROP TABLE IF EXISTS `v_category_report`;
/*!50001 DROP VIEW IF EXISTS `v_category_report`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_category_report` AS SELECT 
 1 AS `service_category_id`,
 1 AS `service_category_name`,
 1 AS `booking_id`,
 1 AS `booking_date`,
 1 AS `scheduled_date`,
 1 AS `service_name`,
 1 AS `customer`,
 1 AS `freelancer`,
 1 AS `location_name`,
 1 AS `municipality_name`,
 1 AS `hours_booked`,
 1 AS `agreed_hourly_rate`,
 1 AS `line_total`,
 1 AS `booking_status`,
 1 AS `payment_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'freelancing_network'
--
/*!50003 DROP PROCEDURE IF EXISTS `category_report` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `category_report`(IN p_category VARCHAR(50))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM service_category WHERE service_category_name = p_category) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unknown service category name';
    END IF;

    SELECT booking_id, scheduled_date, service_name, customer, freelancer, location_name,
           hours_booked, agreed_hourly_rate, line_total, booking_status, payment_status
    FROM v_category_report
    WHERE service_category_name = p_category
    ORDER BY scheduled_date DESC, booking_id DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `category_summary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `category_summary`(IN p_category VARCHAR(50))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM service_category WHERE service_category_name = p_category) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unknown service category name';
    END IF;

    SELECT p_category AS category,
           COUNT(DISTINCT booking_id)                                                  AS bookings,
           COUNT(DISTINCT CASE WHEN booking_status = 'completed' THEN booking_id END)  AS completed,
           COUNT(DISTINCT CASE WHEN booking_status = 'cancelled' THEN booking_id END)  AS cancelled,
           COUNT(DISTINCT CASE WHEN booking_status <> 'cancelled' THEN freelancer END) AS freelancers,
           COALESCE(SUM(CASE WHEN booking_status <> 'cancelled' THEN hours_booked END), 0) AS hours_booked,
           COALESCE(SUM(CASE WHEN booking_status <> 'cancelled' THEN line_total END), 0)   AS total_value
    FROM v_category_report
    WHERE service_category_name = p_category;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `freelancing_network`
--

USE `freelancing_network`;

--
-- Final view structure for view `v_category_report`
--

/*!50001 DROP VIEW IF EXISTS `v_category_report`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_category_report` AS select `sc`.`service_category_id` AS `service_category_id`,`sc`.`service_category_name` AS `service_category_name`,`b`.`booking_id` AS `booking_id`,`b`.`booking_date` AS `booking_date`,`b`.`scheduled_date` AS `scheduled_date`,`s`.`service_name` AS `service_name`,concat(`c`.`cus_first_name`,' ',`c`.`cus_last_name`) AS `customer`,concat(`f`.`f_first_name`,' ',`f`.`f_last_name`) AS `freelancer`,`l`.`location_name` AS `location_name`,`l`.`municipality_name` AS `municipality_name`,`bs`.`hours_booked` AS `hours_booked`,`bs`.`agreed_hourly_rate` AS `agreed_hourly_rate`,round((`bs`.`hours_booked` * `bs`.`agreed_hourly_rate`),2) AS `line_total`,`b`.`booking_status` AS `booking_status`,`p`.`payment_status` AS `payment_status` from (((((((`booking_service` `bs` join `booking` `b` on((`b`.`booking_id` = `bs`.`booking_id`))) join `service` `s` on((`s`.`service_id` = `bs`.`service_id`))) join `service_category` `sc` on((`sc`.`service_category_id` = `s`.`service_category_id`))) join `customer` `c` on((`c`.`customer_id` = `b`.`customer_id`))) join `freelancer` `f` on((`f`.`freelancer_id` = `b`.`freelancer_id`))) join `location` `l` on((`l`.`location_id` = `b`.`location_id`))) left join `payment` `p` on((`p`.`booking_id` = `b`.`booking_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-12  1:43:45
