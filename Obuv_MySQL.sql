-- ООО «Обувь»: один файл создания и заполнения базы MySQL.
-- Откройте в MySQL Workbench и выполните весь файл. Требуется MySQL 8.0.16+.
-- Первый импорт: существующие таблицы не удаляются. Повторный запуск даст ошибку.
-- Заказ № 7: дата 30.02.2025 невозможна; сохранена в ImportIssue, order_date = NULL.
SET NAMES utf8mb4;
SET @obuv_old_sql_mode = @@SESSION.sql_mode;
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,NO_BACKSLASH_ESCAPES';
CREATE DATABASE IF NOT EXISTS `obuv` CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
USE `obuv`;

CREATE TABLE `Role` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `AppUser` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `role_id` INT NOT NULL,
  `full_name` VARCHAR(200) NOT NULL,
  `login` VARCHAR(254) NOT NULL UNIQUE,
  `password` VARCHAR(128) NOT NULL,
  FOREIGN KEY (`role_id`) REFERENCES `Role`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `Unit` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `Supplier` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `Manufacturer` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `Category` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `Product` (
  `sku` VARCHAR(30) NOT NULL PRIMARY KEY,
  `name` VARCHAR(150) NOT NULL,
  `unit_id` INT NOT NULL,
  `price` DECIMAL(12,2) NOT NULL,
  `supplier_id` INT NOT NULL,
  `manufacturer_id` INT NOT NULL,
  `category_id` INT NOT NULL,
  `discount_percent` DECIMAL(5,2) NOT NULL,
  `stock_quantity` INT NOT NULL,
  `description` VARCHAR(2000) NOT NULL,
  `photo` VARCHAR(255) NULL,
  FOREIGN KEY (`unit_id`) REFERENCES `Unit`(`id`),
  FOREIGN KEY (`supplier_id`) REFERENCES `Supplier`(`id`),
  FOREIGN KEY (`manufacturer_id`) REFERENCES `Manufacturer`(`id`),
  FOREIGN KEY (`category_id`) REFERENCES `Category`(`id`),
  CHECK (`price` >= 0),
  CHECK (`discount_percent` BETWEEN 0 AND 100),
  CHECK (`stock_quantity` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `PickupPoint` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `address` VARCHAR(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `OrderStatus` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `CustomerOrder` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `order_date` DATE NULL,
  `delivery_date` DATE NOT NULL,
  `pickup_point_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `pickup_code` VARCHAR(20) NOT NULL,
  `status_id` INT NOT NULL,
  FOREIGN KEY (`pickup_point_id`) REFERENCES `PickupPoint`(`id`),
  FOREIGN KEY (`user_id`) REFERENCES `AppUser`(`id`),
  FOREIGN KEY (`status_id`) REFERENCES `OrderStatus`(`id`),
  CHECK (`order_date` IS NULL OR `delivery_date` >= `order_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `OrderItem` (
  `order_id` INT NOT NULL,
  `product_sku` VARCHAR(30) NOT NULL,
  `quantity` INT NOT NULL,
  PRIMARY KEY (`order_id`, `product_sku`),
  FOREIGN KEY (`order_id`) REFERENCES `CustomerOrder`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_sku`) REFERENCES `Product`(`sku`),
  CHECK (`quantity` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `ImportIssue` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `order_id` INT NOT NULL,
  `source_cell` VARCHAR(200) NOT NULL,
  `source_value` VARCHAR(200) NOT NULL,
  `reason` VARCHAR(300) NOT NULL,
  FOREIGN KEY (`order_id`) REFERENCES `CustomerOrder`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

START TRANSACTION;
INSERT INTO `Role` (`id`, `name`) VALUES
(1, 'Администратор'),
(2, 'Менеджер'),
(3, 'Авторизированный клиент');

INSERT INTO `AppUser` (`id`, `role_id`, `full_name`, `login`, `password`) VALUES
(1, 1, 'Никифорова Весения Николаевна', '94d5ous@gmail.com', 'uzWC67'),
(2, 1, 'Сазонов Руслан Германович', 'uth4iz@mail.com', '2L6KZG'),
(3, 1, 'Одинцов Серафим Артёмович', 'yzls62@outlook.com', 'JlFRCZ'),
(4, 2, 'Степанов Михаил Артёмович', '1diph5e@tutanota.com', '8ntwUp'),
(5, 2, 'Ворсин Петр Евгеньевич', 'tjde7c@yahoo.com', 'YOyhfR'),
(6, 2, 'Старикова Елена Павловна', 'wpmrc3do@tutanota.com', 'RSbvHv'),
(7, 3, 'Михайлюк Анна Вячеславовна', '5d4zbu@tutanota.com', 'rwVDh9'),
(8, 3, 'Ситдикова Елена Анатольевна', 'ptec8ym@yahoo.com', 'LdNyos'),
(9, 3, 'Ворсин Петр Евгеньевич', '1qz4kw@mail.com', 'gynQMT'),
(10, 3, 'Старикова Елена Павловна', '4np6se@mail.com', 'AtnDjr');

INSERT INTO `Unit` (`id`, `name`) VALUES
(1, 'шт.');

INSERT INTO `Supplier` (`id`, `name`) VALUES
(1, 'Kari'),
(2, 'Обувь для вас');

INSERT INTO `Manufacturer` (`id`, `name`) VALUES
(1, 'Kari'),
(2, 'Marco Tozzi'),
(3, 'Рос'),
(4, 'Rieker'),
(5, 'Alessio Nesca'),
(6, 'CROSBY');

INSERT INTO `Category` (`id`, `name`) VALUES
(1, 'Женская обувь'),
(2, 'Мужская обувь');

INSERT INTO `Product` (`sku`, `name`, `unit_id`, `price`, `supplier_id`, `manufacturer_id`, `category_id`, `discount_percent`, `stock_quantity`, `description`, `photo`) VALUES
('А112Т4', 'Ботинки', 1, 4990, 1, 1, 1, 3, 6, 'Женские Ботинки демисезонные kari', '1.jpg'),
('F635R4', 'Ботинки', 1, 3244, 2, 2, 1, 2, 13, 'Ботинки Marco Tozzi женские демисезонные, размер 39, цвет бежевый', '2.jpg'),
('H782T5', 'Туфли', 1, 4499, 1, 1, 2, 4, 5, 'Туфли kari мужские классика MYZ21AW-450A, размер 43, цвет: черный', '3.jpg'),
('G783F5', 'Ботинки', 1, 5900, 1, 3, 2, 2, 8, 'Мужские ботинки Рос-Обувь кожаные с натуральным мехом', '4.jpg'),
('J384T6', 'Ботинки', 1, 3800, 2, 4, 2, 2, 16, 'B3430/14 Полуботинки мужские Rieker', '5.jpg'),
('D572U8', 'Кроссовки', 1, 4100, 2, 3, 2, 3, 6, '129615-4 Кроссовки мужские', '6.jpg'),
('F572H7', 'Туфли', 1, 2700, 1, 2, 1, 2, 14, 'Туфли Marco Tozzi женские летние, размер 39, цвет черный', '7.jpg'),
('D329H3', 'Полуботинки', 1, 1890, 2, 5, 1, 4, 4, 'Полуботинки Alessio Nesca женские 3-30797-47, размер 37, цвет: бордовый', '8.jpg'),
('B320R5', 'Туфли', 1, 4300, 1, 4, 1, 2, 6, 'Туфли Rieker женские демисезонные, размер 41, цвет коричневый', '9.jpg'),
('G432E4', 'Туфли', 1, 2800, 1, 1, 1, 3, 15, 'Туфли kari женские TR-YR-413017, размер 37, цвет: черный', '10.jpg'),
('S213E3', 'Полуботинки', 1, 2156, 2, 6, 2, 3, 6, '407700/01-01 Полуботинки мужские CROSBY', NULL),
('E482R4', 'Полуботинки', 1, 1800, 1, 1, 1, 2, 14, 'Полуботинки kari женские MYZ20S-149, размер 41, цвет: черный', NULL),
('S634B5', 'Кеды', 1, 5500, 2, 6, 2, 3, 0, 'Кеды Caprice мужские демисезонные, размер 42, цвет черный', NULL),
('K345R4', 'Полуботинки', 1, 2100, 2, 6, 2, 2, 3, '407700/01-02 Полуботинки мужские CROSBY', NULL),
('O754F4', 'Туфли', 1, 5400, 2, 4, 1, 4, 18, 'Туфли женские демисезонные Rieker артикул 55073-68/37', NULL),
('G531F4', 'Ботинки', 1, 6600, 1, 1, 1, 12, 9, 'Ботинки женские зимние ROMER арт. 893167-01 Черный', NULL),
('J542F5', 'Тапочки', 1, 500, 1, 1, 2, 13, 0, 'Тапочки мужские Арт.70701-55-67син р.41', NULL),
('B431R5', 'Ботинки', 1, 2700, 2, 4, 2, 2, 5, 'Мужские кожаные ботинки/мужские ботинки', NULL),
('P764G4', 'Туфли', 1, 6800, 1, 6, 1, 15, 15, 'Туфли женские, ARGO, размер 38', NULL),
('C436G5', 'Ботинки', 1, 10200, 1, 5, 1, 15, 9, 'Ботинки женские, ARGO, размер 40', NULL),
('F427R5', 'Ботинки', 1, 11800, 2, 4, 1, 15, 11, 'Ботинки на молнии с декоративной пряжкой FRAU', NULL),
('N457T5', 'Полуботинки', 1, 4600, 1, 6, 1, 3, 13, 'Полуботинки Ботинки черные зимние, мех', NULL),
('D364R4', 'Туфли', 1, 12400, 1, 1, 1, 16, 5, 'Туфли Luiza Belly женские Kate-lazo черные из натуральной замши', NULL),
('S326R5', 'Тапочки', 1, 9900, 2, 6, 2, 17, 15, 'Мужские кожаные тапочки "Профиль С.Дали" ', NULL),
('L754R4', 'Полуботинки', 1, 1700, 1, 1, 1, 2, 7, 'Полуботинки kari женские WB2020SS-26, размер 38, цвет: черный', NULL),
('M542T5', 'Кроссовки', 1, 2800, 2, 4, 2, 18, 3, 'Кроссовки мужские TOFA', NULL),
('D268G5', 'Туфли', 1, 4399, 2, 4, 1, 3, 12, 'Туфли Rieker женские демисезонные, размер 36, цвет коричневый', NULL),
('T324F5', 'Сапоги', 1, 4699, 1, 6, 1, 2, 5, 'Сапоги замша Цвет: синий', NULL),
('K358H6', 'Тапочки', 1, 599, 1, 4, 2, 20, 2, 'Тапочки мужские син р.41', NULL),
('H535R5', 'Ботинки', 1, 2300, 2, 4, 1, 2, 7, 'Женские Ботинки демисезонные', NULL);

INSERT INTO `PickupPoint` (`id`, `address`) VALUES
(1, '420151, г. Лесной, ул. Вишневая, 32'),
(2, '125061, г. Лесной, ул. Подгорная, 8'),
(3, '630370, г. Лесной, ул. Шоссейная, 24'),
(4, '400562, г. Лесной, ул. Зеленая, 32'),
(5, '614510, г. Лесной, ул. Маяковского, 47'),
(6, '410542, г. Лесной, ул. Светлая, 46'),
(7, '620839, г. Лесной, ул. Цветочная, 8'),
(8, '443890, г. Лесной, ул. Коммунистическая, 1'),
(9, '603379, г. Лесной, ул. Спортивная, 46'),
(10, '603721, г. Лесной, ул. Гоголя, 41'),
(11, '410172, г. Лесной, ул. Северная, 13'),
(12, '614611, г. Лесной, ул. Молодежная, 50'),
(13, '454311, г.Лесной, ул. Новая, 19'),
(14, '660007, г.Лесной, ул. Октябрьская, 19'),
(15, '603036, г. Лесной, ул. Садовая, 4'),
(16, '394060, г.Лесной, ул. Фрунзе, 43'),
(17, '410661, г. Лесной, ул. Школьная, 50'),
(18, '625590, г. Лесной, ул. Коммунистическая, 20'),
(19, '625683, г. Лесной, ул. 8 Марта'),
(20, '450983, г.Лесной, ул. Комсомольская, 26'),
(21, '394782, г. Лесной, ул. Чехова, 3'),
(22, '603002, г. Лесной, ул. Дзержинского, 28'),
(23, '450558, г. Лесной, ул. Набережная, 30'),
(24, '344288, г. Лесной, ул. Чехова, 1'),
(25, '614164, г.Лесной,  ул. Степная, 30'),
(26, '394242, г. Лесной, ул. Коммунистическая, 43'),
(27, '660540, г. Лесной, ул. Солнечная, 25'),
(28, '125837, г. Лесной, ул. Шоссейная, 40'),
(29, '125703, г. Лесной, ул. Партизанская, 49'),
(30, '625283, г. Лесной, ул. Победы, 46'),
(31, '614753, г. Лесной, ул. Полевая, 35'),
(32, '426030, г. Лесной, ул. Маяковского, 44'),
(33, '450375, г. Лесной ул. Клубная, 44'),
(34, '625560, г. Лесной, ул. Некрасова, 12'),
(35, '630201, г. Лесной, ул. Комсомольская, 17'),
(36, '190949, г. Лесной, ул. Мичурина, 26');

INSERT INTO `OrderStatus` (`id`, `name`) VALUES
(1, 'Завершен'),
(2, 'Новый');

INSERT INTO `CustomerOrder` (`id`, `order_date`, `delivery_date`, `pickup_point_id`, `user_id`, `pickup_code`, `status_id`) VALUES
(1, '2025-02-27', '2025-04-20', 1, 4, '901', 1),
(2, '2022-09-28', '2025-04-21', 11, 1, '902', 1),
(3, '2025-03-21', '2025-04-22', 2, 2, '903', 1),
(4, '2025-02-20', '2025-04-23', 11, 3, '904', 1),
(5, '2025-03-17', '2025-04-24', 2, 4, '905', 1),
(6, '2025-03-01', '2025-04-25', 15, 1, '906', 1),
(7, NULL, '2025-04-26', 3, 2, '907', 1),
(8, '2025-03-31', '2025-04-27', 19, 3, '908', 2),
(9, '2025-04-02', '2025-04-28', 5, 4, '909', 2),
(10, '2025-04-03', '2025-04-29', 19, 4, '910', 2);

INSERT INTO `OrderItem` (`order_id`, `product_sku`, `quantity`) VALUES
(1, 'А112Т4', 2),
(1, 'F635R4', 2),
(2, 'H782T5', 1),
(2, 'G783F5', 1),
(3, 'J384T6', 10),
(3, 'D572U8', 10),
(4, 'F572H7', 5),
(4, 'D329H3', 4),
(5, 'А112Т4', 2),
(5, 'F635R4', 2),
(6, 'H782T5', 1),
(6, 'G783F5', 1),
(7, 'J384T6', 10),
(7, 'D572U8', 10),
(8, 'F572H7', 5),
(8, 'D329H3', 4),
(9, 'B320R5', 5),
(9, 'G432E4', 1),
(10, 'S213E3', 5),
(10, 'E482R4', 5);

INSERT INTO `ImportIssue` (`id`, `order_id`, `source_cell`, `source_value`, `reason`) VALUES
(1, 7, 'Заказ_import.xlsx!C8', '30.02.2025', 'Несуществующая календарная дата. Требуется уточнение; order_date = NULL.');

COMMIT;
SET SESSION sql_mode = @obuv_old_sql_mode;
-- Контроль: 30 товаров, 10 пользователей, 10 заказов, 20 позиций, 36 пунктов.
SELECT 'Product' AS table_name, COUNT(*) AS row_count FROM `Product` UNION ALL SELECT 'AppUser', COUNT(*) FROM `AppUser` UNION ALL SELECT 'CustomerOrder', COUNT(*) FROM `CustomerOrder` UNION ALL SELECT 'OrderItem', COUNT(*) FROM `OrderItem` UNION ALL SELECT 'PickupPoint', COUNT(*) FROM `PickupPoint`;
