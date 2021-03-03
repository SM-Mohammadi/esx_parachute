
CREATE TABLE `parachute` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`zone` varchar(255) NOT NULL,
	`item` varchar(255) NOT NULL,
	`price` int(11) NOT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `parachute` (`zone`, `item`, `price`) VALUES
	('GunShop','gadget_parachute', 2000)
;