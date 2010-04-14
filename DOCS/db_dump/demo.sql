-- phpMyAdmin SQL Dump
-- version 3.2.5deb2
-- http://www.phpmyadmin.net
--
-- Хост: localhost
-- Время создания: Мар 29 2010 г., 00:30
-- Версия сервера: 5.1.43
-- Версия PHP: 5.3.1-4

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- База данных: `mojotest`
--

-- --------------------------------------------------------

--
-- Структура таблицы `mjsmf_members`
--

CREATE TABLE IF NOT EXISTS `mjsmf_members` (
  `ID_MEMBER` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `memberName` varchar(80) NOT NULL DEFAULT '',
  `dateRegistered` int(10) unsigned NOT NULL DEFAULT '0',
  `posts` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `ID_GROUP` smallint(5) unsigned NOT NULL DEFAULT '0',
  `lngfile` tinytext NOT NULL,
  `lastLogin` int(10) unsigned NOT NULL DEFAULT '0',
  `realName` tinytext NOT NULL,
  `instantMessages` smallint(5) NOT NULL DEFAULT '0',
  `unreadMessages` smallint(5) NOT NULL DEFAULT '0',
  `buddy_list` text NOT NULL,
  `pm_ignore_list` tinytext NOT NULL,
  `messageLabels` text NOT NULL,
  `passwd` varchar(64) NOT NULL DEFAULT '',
  `emailAddress` tinytext NOT NULL,
  `personalText` tinytext NOT NULL,
  `gender` tinyint(4) unsigned NOT NULL DEFAULT '0',
  `birthdate` date NOT NULL DEFAULT '0001-01-01',
  `websiteTitle` tinytext NOT NULL,
  `websiteUrl` tinytext NOT NULL,
  `location` tinytext NOT NULL,
  `ICQ` tinytext NOT NULL,
  `AIM` varchar(16) NOT NULL DEFAULT '',
  `YIM` varchar(32) NOT NULL DEFAULT '',
  `MSN` tinytext NOT NULL,
  `hideEmail` tinyint(4) NOT NULL DEFAULT '0',
  `showOnline` tinyint(4) NOT NULL DEFAULT '1',
  `timeFormat` varchar(80) NOT NULL DEFAULT '',
  `signature` text NOT NULL,
  `timeOffset` float NOT NULL DEFAULT '0',
  `avatar` tinytext NOT NULL,
  `pm_email_notify` tinyint(4) NOT NULL DEFAULT '0',
  `karmaBad` smallint(5) unsigned NOT NULL DEFAULT '0',
  `karmaGood` smallint(5) unsigned NOT NULL DEFAULT '0',
  `usertitle` tinytext NOT NULL,
  `notifyAnnouncements` tinyint(4) NOT NULL DEFAULT '1',
  `notifyOnce` tinyint(4) NOT NULL DEFAULT '1',
  `notifySendBody` tinyint(4) NOT NULL DEFAULT '0',
  `notifyTypes` tinyint(4) NOT NULL DEFAULT '2',
  `memberIP` tinytext NOT NULL,
  `memberIP2` tinytext NOT NULL,
  `secretQuestion` tinytext NOT NULL,
  `secretAnswer` varchar(64) NOT NULL DEFAULT '',
  `ID_THEME` tinyint(4) unsigned NOT NULL DEFAULT '0',
  `is_activated` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `validation_code` varchar(10) NOT NULL DEFAULT '',
  `ID_MSG_LAST_VISIT` int(10) unsigned NOT NULL DEFAULT '0',
  `additionalGroups` tinytext NOT NULL,
  `smileySet` varchar(48) NOT NULL DEFAULT '',
  `ID_POST_GROUP` smallint(5) unsigned NOT NULL DEFAULT '0',
  `totalTimeLoggedIn` int(10) unsigned NOT NULL DEFAULT '0',
  `passwordSalt` varchar(5) NOT NULL DEFAULT '',
  PRIMARY KEY (`ID_MEMBER`),
  KEY `memberName` (`memberName`(30)),
  KEY `dateRegistered` (`dateRegistered`),
  KEY `ID_GROUP` (`ID_GROUP`),
  KEY `birthdate` (`birthdate`),
  KEY `posts` (`posts`),
  KEY `lastLogin` (`lastLogin`),
  KEY `lngfile` (`lngfile`(30)),
  KEY `ID_POST_GROUP` (`ID_POST_GROUP`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=20 ;

--
-- Дамп данных таблицы `mjsmf_members`
--

INSERT INTO `mjsmf_members` (`ID_MEMBER`, `memberName`, `dateRegistered`, `posts`, `ID_GROUP`, `lngfile`, `lastLogin`, `realName`, `instantMessages`, `unreadMessages`, `buddy_list`, `pm_ignore_list`, `messageLabels`, `passwd`, `emailAddress`, `personalText`, `gender`, `birthdate`, `websiteTitle`, `websiteUrl`, `location`, `ICQ`, `AIM`, `YIM`, `MSN`, `hideEmail`, `showOnline`, `timeFormat`, `signature`, `timeOffset`, `avatar`, `pm_email_notify`, `karmaBad`, `karmaGood`, `usertitle`, `notifyAnnouncements`, `notifyOnce`, `notifySendBody`, `notifyTypes`, `memberIP`, `memberIP2`, `secretQuestion`, `secretAnswer`, `ID_THEME`, `is_activated`, `validation_code`, `ID_MSG_LAST_VISIT`, `additionalGroups`, `smileySet`, `ID_POST_GROUP`, `totalTimeLoggedIn`, `passwordSalt`) VALUES
(0, 'guest', 0, 0, 0, '', 0, 'Guest', 0, 0, '', '', '', '9474d8c82a7bdef16bb503f7dbd1b02f5aaf601f', '', 'I''m guest', 0, '0001-01-01', '', '', '', '', '', '', '', 1, 0, '', '', 0, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 0, 'oyaebu', 0, '', '', 0, 0, '!QAZa'),
(1, 'austin', 0, 0, 0, '', 0, 'Austin Powers', 0, 0, '', '', '', 'affed750772acc7816bdfb3740357b6e40c9e18f', 'austin@powers.ap', '', 0, '1939-11-12', '', '', '', '', '', '', '', 0, 1, '', '', 3, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 1, '', 0, '', '', 0, 0, 'AuSt!');

-- --------------------------------------------------------

--
-- Структура таблицы `mjsmf_sessions`
--

CREATE TABLE IF NOT EXISTS `mjsmf_sessions` (
  `session_id` char(32) NOT NULL,
  `last_update` int(10) unsigned NOT NULL,
  `data` text NOT NULL,
  PRIMARY KEY (`session_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `mjsmf_sessions`
--

INSERT INTO `mjsmf_sessions` (`session_id`, `last_update`, `data`) VALUES
('5d87e770c3c3c9dc8cb7ee12cffaf26b', 1267763364, 'rand_code|s:32:"8b2793eec4261ac1152f1163d3462c67";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('c1aed11fd6814e8ce3d0d254d4aeff51', 1267794440, 'rand_code|s:32:"88d32104c30be589848fc40eacfadbd8";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('93194e33900dc40d5c3c6239994b13eb', 1267830456, 'rand_code|s:32:"9b2566ab58261354ed4539c1870dd94f";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('2c003bc2163cca24732f1ccb39bd9850', 1267906029, 'rand_code|s:32:"1300dd093bb298e2602a0d70c3ff953a";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('46dde114045c96625edebfdb464d5cff', 1269326448, 'rand_code|s:32:"5034b2558667345f96e62facf5d97288";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('8faa911a761b6c866bf9af71a31a8d62', 1269639082, 'rand_code|s:32:"d9695f902adbb31c35751fa9d131ecb7";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('a266592f9feb867bc9f48e7ca7324da0', 1269684537, 'rand_code|s:32:"1a13c836a9958b5b1bfb1db996187279";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";');

-- --------------------------------------------------------

--
-- Структура таблицы `mj_awps`
--

CREATE TABLE IF NOT EXISTS `mj_awps` (
  `awp_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(48) NOT NULL,
  `ins` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned DEFAULT NULL,
  `sequence` tinyint(3) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`awp_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='User''s Automated Work Places' AUTO_INCREMENT=5 ;

--
-- Дамп данных таблицы `mj_awps`
--

INSERT INTO `mj_awps` (`awp_id`, `name`, `ins`, `upd`, `member_id`, `whoedit`, `sequence`) VALUES
(0, 'MjCMS guest AWP', '2010-02-09 00:00:00', '2010-02-15 23:14:08', 1, NULL, 255),
(1, 'MjCMS admin AWP', '2010-02-09 00:00:00', '2010-02-15 23:14:15', 1, NULL, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `mj_cats_data`
--

CREATE TABLE IF NOT EXISTS `mj_cats_data` (
  `cat_id` int(10) unsigned NOT NULL,
  `lang` char(4) NOT NULL,
  `name` char(32) NOT NULL,
  `cname` char(16) DEFAULT NULL,
  `descr` text NOT NULL,
  `keywords` text NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `extra_data` text NOT NULL,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned DEFAULT NULL,
  `ins` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `cat_id_idx` (`cat_id`),
  KEY `cname_idx` (`cname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Categories data';

--
-- Дамп данных таблицы `mj_cats_data`
--

INSERT INTO `mj_cats_data` (`cat_id`, `lang`, `name`, `cname`, `descr`, `keywords`, `is_active`, `extra_data`, `member_id`, `whoedit`, `ins`, `upd`) VALUES
(2, 'en', 'eee', 'rrr', '', '', 1, '', 1, NULL, '2010-03-07 05:07:08', '2010-03-07 05:07:08'),
(3, 'en', 'hui', 'sun', 'vv', 'chai', 1, '', 1, 1, '2010-03-07 06:00:43', '2010-03-07 06:00:53'),
(4, 'en', 'on', 'eng', 'opa', 'zopa\n', 1, '', 1, NULL, '2010-03-07 06:02:31', '2010-03-07 06:02:31'),
(5, 'ru', 'wewe', 'ere', 'wewe', 'wewe', 1, '', 1, NULL, '2010-03-07 07:24:21', '2010-03-07 07:24:21');

-- --------------------------------------------------------

--
-- Структура таблицы `mj_cats_trans`
--

CREATE TABLE IF NOT EXISTS `mj_cats_trans` (
  `cat_id` int(10) NOT NULL,
  `lang` char(4) NOT NULL,
  `name` char(32) NOT NULL,
  `descr` text NOT NULL,
  `keywords` text NOT NULL,
  `member_id` mediumint(8) NOT NULL,
  `whoedit` mediumint(8) DEFAULT NULL,
  `ins` datetime NOT NULL,
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `menu_lng_idx` (`cat_id`,`lang`),
  KEY `cat_id_idx` (`cat_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Categories translations';

--
-- Дамп данных таблицы `mj_cats_trans`
--

INSERT INTO `mj_cats_trans` (`cat_id`, `lang`, `name`, `descr`, `keywords`, `member_id`, `whoedit`, `ins`, `upd`) VALUES
(2, 'ru', 'eerr', 'rere', 'ererrrr', 1, 1, '2010-03-07 22:02:33', '2010-03-07 22:07:31');

-- --------------------------------------------------------

--
-- Структура таблицы `mj_cats_tree`
--

CREATE TABLE IF NOT EXISTS `mj_cats_tree` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `level` tinyint(3) NOT NULL DEFAULT '1',
  `left_key` int(10) NOT NULL DEFAULT '0',
  `right_key` int(10) NOT NULL DEFAULT '0',
  `group` int(10) NOT NULL,
  `ins` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `level` (`level`),
  KEY `group` (`group`),
  KEY `comlete_idx` (`level`,`left_key`,`right_key`,`group`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Categories data tree' AUTO_INCREMENT=6 ;

--
-- Дамп данных таблицы `mj_cats_tree`
--

INSERT INTO `mj_cats_tree` (`id`, `level`, `left_key`, `right_key`, `group`, `ins`, `upd`) VALUES
(2, 1, 3, 8, 0, '0000-00-00 00:00:00', '2010-03-07 22:07:58'),
(3, 2, 4, 7, 0, '0000-00-00 00:00:00', '2010-03-07 22:07:58'),
(4, 3, 5, 6, 0, '0000-00-00 00:00:00', '2010-03-07 22:07:58'),
(5, 1, 1, 2, 0, '0000-00-00 00:00:00', '2010-03-07 22:07:58');

-- --------------------------------------------------------

--
-- Структура таблицы `mj_menus_data`
--

CREATE TABLE IF NOT EXISTS `mj_menus_data` (
  `menu_id` int(10) unsigned NOT NULL,
  `lang` char(4) NOT NULL,
  `text` char(32) NOT NULL,
  `cname` char(16) DEFAULT NULL,
  `link` text NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `extra_data` text NOT NULL,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned DEFAULT NULL,
  `ins` datetime NOT NULL,
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `menu_id_idx` (`menu_id`),
  KEY `cname_idx` (`cname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `mj_menus_data`
--

INSERT INTO `mj_menus_data` (`menu_id`, `lang`, `text`, `cname`, `link`, `is_active`, `extra_data`, `member_id`, `whoedit`, `ins`, `upd`) VALUES
(3, 'en', 'MjCMS adm menu', 'mjcmsadm', 'is_active', 0, '', 1, 1, '2010-02-26 23:45:35', '2010-03-04 20:48:31'),
(5, 'en', 'Slave', 'mumucn', '', 1, '', 1, 1, '2010-03-03 17:59:24', '2010-03-03 22:48:22'),
(6, 'en', 'OpaOpa', 'zzzda', '', 1, '', 1, 1, '2010-03-04 12:11:09', '2010-03-04 16:44:34'),
(19, 'en', 'dds', 'hhhd', '', 1, '', 1, NULL, '2010-03-04 12:42:54', '2010-03-04 12:42:54'),
(20, 'en', 'refdsf', 'sdeer', '', 1, '', 1, NULL, '2010-03-04 12:43:41', '2010-03-04 12:43:41'),
(21, 'en', 'ewer', 'aew', '', 1, '', 1, NULL, '2010-03-04 12:45:02', '2010-03-04 12:45:02'),
(22, 'en', 'wqwqe', 'wewqq', '', 1, '', 1, 1, '2010-03-04 12:54:28', '2010-03-04 13:08:31'),
(23, 'en', 'eeyub', 'ebubue', 'oyaebu', 1, '', 1, 1, '2010-03-04 16:45:42', '2010-03-04 17:28:39'),
(24, 'en', 'opopo', 'yoyo', 'ololo', 1, '', 1, NULL, '2010-03-04 17:06:41', '2010-03-04 17:06:41'),
(25, 'en', 'pliio', 'dodo', 'jopa', 1, '', 1, NULL, '2010-03-04 21:00:09', '2010-03-04 21:00:09'),
(26, 'en', 'ttt', 'ttt', 'ttt', 1, '', 1, NULL, '2010-03-04 22:11:36', '2010-03-04 22:11:36'),
(27, 'en', 'sssd', 'dsdsd', 'sdsdsd', 1, '', 1, NULL, '2010-03-04 22:12:05', '2010-03-04 22:12:05'),
(28, 'en', 'ds', 'zdx', 'wewewe', 1, '', 1, NULL, '2010-03-04 22:13:12', '2010-03-04 22:13:12'),
(29, 'en', 'eweyavol', 'eweyavol', 'eweyavol', 1, '', 1, NULL, '2010-03-04 22:28:13', '2010-03-04 22:28:13'),
(30, 'en', 'hhhuuii', 'hhhuuii', 'hhhuuii', 1, '', 1, NULL, '2010-03-04 22:30:16', '2010-03-04 22:30:16');

-- --------------------------------------------------------

--
-- Структура таблицы `mj_menus_trans`
--

CREATE TABLE IF NOT EXISTS `mj_menus_trans` (
  `menu_id` int(10) NOT NULL,
  `lang` char(4) NOT NULL,
  `text` char(32) NOT NULL,
  `link` text NOT NULL,
  `member_id` mediumint(8) NOT NULL,
  `whoedit` mediumint(8) DEFAULT NULL,
  `ins` datetime NOT NULL,
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `menu_lng_idx` (`menu_id`,`lang`),
  KEY `menu_id_idx` (`menu_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Menus translations';

--
-- Дамп данных таблицы `mj_menus_trans`
--


-- --------------------------------------------------------

--
-- Структура таблицы `mj_menus_tree`
--

CREATE TABLE IF NOT EXISTS `mj_menus_tree` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `level` tinyint(3) NOT NULL DEFAULT '1',
  `left_key` int(10) NOT NULL DEFAULT '0',
  `right_key` int(10) NOT NULL DEFAULT '0',
  `group` int(10) NOT NULL,
  `ins` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `level` (`level`),
  KEY `group` (`group`),
  KEY `comlete_idx` (`level`,`left_key`,`right_key`,`group`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Menus data tree' AUTO_INCREMENT=31 ;

--
-- Дамп данных таблицы `mj_menus_tree`
--

INSERT INTO `mj_menus_tree` (`id`, `level`, `left_key`, `right_key`, `group`, `ins`, `upd`) VALUES
(3, 1, 1, 30, 0, '0000-00-00 00:00:00', '2010-03-04 22:30:16'),
(5, 2, 2, 17, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(6, 2, 18, 19, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(19, 2, 20, 21, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(20, 2, 22, 23, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(22, 2, 26, 27, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(21, 2, 24, 25, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(23, 3, 3, 16, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(24, 2, 28, 29, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(25, 4, 10, 11, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(26, 4, 6, 7, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(27, 4, 14, 15, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(28, 4, 12, 13, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(29, 4, 8, 9, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51'),
(30, 4, 4, 5, 0, '0000-00-00 00:00:00', '2010-03-05 02:59:51');

-- --------------------------------------------------------

--
-- Структура таблицы `mj_pages`
--

CREATE TABLE IF NOT EXISTS `mj_pages` (
  `page_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `is_published` tinyint(1) unsigned NOT NULL DEFAULT '1',
  `cat_id` int(10) unsigned NOT NULL,
  `lang` char(4) NOT NULL,
  `slug` char(128) DEFAULT NULL,
  `intro` text NOT NULL,
  `body` text,
  `header` char(64) NOT NULL,
  `descr` text NOT NULL,
  `keywords` char(255) NOT NULL,
  `showintro` tinyint(1) NOT NULL DEFAULT '1',
  `use_customtitle` tinyint(1) NOT NULL DEFAULT '0',
  `custom_title` char(128) DEFAULT NULL,
  `allow_comments` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `comments_mode` enum('comment','thread') DEFAULT 'comment',
  `use_password` tinyint(1) NOT NULL DEFAULT '0',
  `password` char(64) DEFAULT NULL,
  `use_acces_sets` tinyint(1) NOT NULL DEFAULT '0',
  `comments_count` bigint(20) NOT NULL,
  `author_id` mediumint(8) NOT NULL,
  `member_id` mediumint(8) NOT NULL,
  `whoedit` mediumint(8) NOT NULL,
  `ins` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `dt_created` datetime NOT NULL,
  `dt_publishstart` datetime DEFAULT NULL,
  `dt_publishend` datetime DEFAULT NULL,
  PRIMARY KEY (`page_id`),
  UNIQUE KEY `slug_uniq_idx` (`slug`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Active posts table' AUTO_INCREMENT=28 ;

--
-- Дамп данных таблицы `mj_pages`
--

INSERT INTO `mj_pages` (`page_id`, `is_published`, `cat_id`, `lang`, `slug`, `intro`, `body`, `header`, `descr`, `keywords`, `showintro`, `use_customtitle`, `custom_title`, `allow_comments`, `comments_mode`, `use_password`, `password`, `use_acces_sets`, `comments_count`, `author_id`, `member_id`, `whoedit`, `ins`, `upd`, `dt_created`, `dt_publishstart`, `dt_publishend`) VALUES
(2, 1, 0, 'ru', 'sdsdsd', '<p>\n	iiii</p>\n', '<p>\n	bbbbbbbb</p>\n', 'hhhhh', 'keywords', '', 0, 0, NULL, 0, NULL, 0, 'use_acces_sets', 0, 0, 1, 1, 0, '2010-03-13 15:58:01', '2010-03-13 15:58:01', '0000-00-00 00:00:00', '0000-00-00 00:00:00', NULL),
(27, 1, 0, 'ru', '22e', '<p>\n	22222</p>\n', '<p>\n	22222</p>\n', '222-22', '', '', 1, 0, '', 1, 'comment', 0, NULL, 0, 0, 1, 1, 1, '2010-03-18 00:59:59', '2010-03-18 13:27:52', '2010-03-18 00:59:00', '2010-03-18 00:59:00', NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `mj_pages_archive`
--

CREATE TABLE IF NOT EXISTS `mj_pages_archive` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `page_id` bigint(20) unsigned NOT NULL,
  `is_published` tinyint(1) unsigned NOT NULL,
  `cat_id` int(10) unsigned NOT NULL,
  `lang` char(4) NOT NULL,
  `slug` char(128) NOT NULL,
  `intro` text NOT NULL,
  `body` text NOT NULL,
  `header` char(64) NOT NULL,
  `descr` char(255) NOT NULL,
  `keywords` char(255) NOT NULL,
  `showintro` tinyint(1) NOT NULL,
  `use_customtitle` tinyint(1) NOT NULL,
  `custom_title` char(128) NOT NULL,
  `allow_comments` tinyint(1) unsigned NOT NULL,
  `comments_mode` char(8) NOT NULL,
  `use_password` tinyint(1) NOT NULL,
  `password` char(64) NOT NULL,
  `use_acces_sets` tinyint(1) NOT NULL,
  `comments_count` bigint(20) NOT NULL,
  `author_id` mediumint(8) NOT NULL,
  `member_id` mediumint(8) NOT NULL,
  `whoedit` mediumint(8) NOT NULL,
  `ins` datetime NOT NULL,
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `dt_created` datetime NOT NULL,
  `dt_publishstart` datetime NOT NULL,
  `dt_publishend` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Archive posts table' AUTO_INCREMENT=3 ;

--
-- Дамп данных таблицы `mj_pages_archive`
--

INSERT INTO `mj_pages_archive` (`id`, `page_id`, `is_published`, `cat_id`, `lang`, `slug`, `intro`, `body`, `header`, `descr`, `keywords`, `showintro`, `use_customtitle`, `custom_title`, `allow_comments`, `comments_mode`, `use_password`, `password`, `use_acces_sets`, `comments_count`, `author_id`, `member_id`, `whoedit`, `ins`, `upd`, `dt_created`, `dt_publishstart`, `dt_publishend`) VALUES
(1, 27, 1, 0, 'ru', '22e', '<p>\n	22222eee</p>', '<p>\n	22222</p>', '222-22', '', '', 1, 0, '', 1, '', 0, '', 0, 0, 1, 1, 1, '2010-03-18 00:59:59', '2010-03-18 13:26:52', '2010-03-18 00:59:00', '2010-03-18 00:59:00', '0000-00-00 00:00:00'),
(2, 27, 1, 0, 'ru', '22e', '<p>\n	22222eee</p>', '<p>\n	22222</p>', '222-22', '', '', 1, 0, '', 1, '', 0, '', 0, 0, 1, 1, 1, '2010-03-18 00:59:59', '2010-03-18 13:27:52', '2010-03-18 00:59:00', '2010-03-18 00:59:00', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `mj_permissions`
--

CREATE TABLE IF NOT EXISTS `mj_permissions` (
  `permission_id` int(10) unsigned NOT NULL,
  `awp_id` int(10) unsigned DEFAULT NULL,
  `role_id` int(10) unsigned DEFAULT NULL,
  `r` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `w` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned DEFAULT NULL,
  `ins` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `perm_role_idx` (`permission_id`,`role_id`),
  KEY `role_id_idx` (`role_id`),
  KEY `awp_id_idx` (`awp_id`),
  KEY `perm_awp_idx` (`permission_id`,`awp_id`),
  KEY `perm_awp_role_idx` (`permission_id`,`awp_id`,`role_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Permissions by awp:role combo';

--
-- Дамп данных таблицы `mj_permissions`
--

INSERT INTO `mj_permissions` (`permission_id`, `awp_id`, `role_id`, `r`, `w`, `member_id`, `whoedit`, `ins`, `upd`) VALUES
(4, 1, NULL, 1, 1, 1, NULL, '2010-03-29 00:12:20', '2010-03-29 00:12:20'),
(8, 1, NULL, 1, 1, 1, NULL, '2010-03-29 00:12:20', '2010-03-29 00:12:20'),
(14, 1, NULL, 1, 1, 1, NULL, '2010-03-29 00:12:20', '2010-03-29 00:12:20'),
(15, 1, NULL, 1, 1, 1, NULL, '2010-03-29 00:12:20', '2010-03-29 00:12:20'),
(2, 1, NULL, 1, 1, 1, NULL, '2010-03-29 00:12:20', '2010-03-29 00:12:20'),
(17, 1, NULL, 1, 1, 1, NULL, '2010-03-29 00:12:20', '2010-03-29 00:12:20'),
(9, 1, NULL, 1, 1, 1, NULL, '2010-03-29 00:12:20', '2010-03-29 00:12:20'),
(3, 1, NULL, 1, 1, 1, NULL, '2010-03-29 00:12:20', '2010-03-29 00:12:20'),
(11, 1, NULL, 1, 1, 1, NULL, '2010-03-29 00:12:20', '2010-03-29 00:12:20'),
(13, 1, NULL, 1, 1, 1, NULL, '2010-03-29 00:12:20', '2010-03-29 00:12:20'),
(16, 1, NULL, 1, 1, 1, NULL, '2010-03-29 00:12:20', '2010-03-29 00:12:20'),
(10, 1, NULL, 1, 1, 1, NULL, '2010-03-29 00:12:20', '2010-03-29 00:12:20');

-- --------------------------------------------------------

--
-- Структура таблицы `mj_permission_types`
--

CREATE TABLE IF NOT EXISTS `mj_permission_types` (
  `permission_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `controller` char(32) NOT NULL,
  `action` char(32) NOT NULL,
  `descr` char(64) NOT NULL,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned DEFAULT NULL,
  `ins` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`permission_id`),
  UNIQUE KEY `c_a_uniq_idx` (`controller`,`action`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Permission types library' AUTO_INCREMENT=18 ;

--
-- Дамп данных таблицы `mj_permission_types`
--

INSERT INTO `mj_permission_types` (`permission_id`, `controller`, `action`, `descr`, `member_id`, `whoedit`, `ins`, `upd`) VALUES
(2, 'menus', 'manage', 'Allow manage menus', 1, NULL, '2010-03-18 19:40:30', '2010-03-18 19:40:30'),
(3, 'categories', 'manage', 'Allow manage categories', 1, NULL, '2010-03-18 19:41:17', '2010-03-18 19:41:17'),
(4, 'pages', 'manage', 'Allow manage pages', 1, 1, '2010-03-18 19:41:58', '2010-03-18 19:46:19'),
(5, 'menus', 'manage_others', 'Allow manage same role user''s record', 1, 1, '2010-03-18 19:43:31', '2010-03-18 21:40:51'),
(6, 'categories', 'manage_others', 'Allow manage same role user''s records', 1, 1, '2010-03-18 19:46:04', '2010-03-18 21:40:35'),
(7, 'pages', 'manage_others', 'Allow manage same role user''s pages', 1, 1, '2010-03-18 19:46:35', '2010-03-18 21:41:00'),
(8, 'categories', 'manage_any', 'Allow manage any user''s records', 1, NULL, '2010-03-18 21:46:31', '2010-03-18 21:46:31'),
(9, 'menus', 'manage_any', 'Allow manage any user''s records', 1, NULL, '2010-03-18 21:46:49', '2010-03-18 21:46:49'),
(10, 'pages', 'manage_any', 'Allow manage any user''s records', 1, NULL, '2010-03-18 21:47:04', '2010-03-18 21:47:04'),
(11, 'urls', 'manage', 'Allow manage urls', 1, NULL, '2010-03-28 16:19:10', '2010-03-28 16:19:10'),
(12, 'urls', 'manage_others', 'Allow manage same role user''s urls', 1, 1, '2010-03-28 16:19:36', '2010-03-28 16:20:41'),
(13, 'urls', 'manage_any', 'Allow manage any user''s urls', 1, NULL, '2010-03-28 16:20:19', '2010-03-28 16:20:19'),
(14, 'filemanager', 'manage', 'Allow manage personal files on local FS', 1, 1, '2010-03-28 16:27:26', '2010-03-28 23:56:36'),
(15, 'permissions', 'manage', 'Allow manage permissions system', 1, NULL, '2010-03-29 00:10:00', '2010-03-29 00:10:00'),
(16, 'awp_roles', 'manage', 'Allow manage AWP/Roles && their permissions', 1, NULL, '2010-03-29 00:10:54', '2010-03-29 00:10:54'),
(17, 'users', 'manage', 'Allow manage users records', 1, NULL, '2010-03-29 00:11:30', '2010-03-29 00:11:30');

-- --------------------------------------------------------

--
-- Структура таблицы `mj_roles`
--

CREATE TABLE IF NOT EXISTS `mj_roles` (
  `role_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `awp_id` smallint(5) unsigned NOT NULL,
  `name` char(48) NOT NULL,
  `ins` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned DEFAULT NULL,
  `sequence` tinyint(3) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`role_id`),
  KEY `awp_id_idx` (`awp_id`),
  KEY `alternatives_idx` (`role_id`,`awp_id`,`sequence`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='User''s roles @ workplaces [text_content/moderator, etc]' AUTO_INCREMENT=4 ;

--
-- Дамп данных таблицы `mj_roles`
--

INSERT INTO `mj_roles` (`role_id`, `awp_id`, `name`, `ins`, `upd`, `member_id`, `whoedit`, `sequence`) VALUES
(0, 0, 'MjCMS guest role', '2010-02-09 00:00:00', '2010-02-15 23:14:33', 1, NULL, 255),
(1, 1, 'MjCMS admin role', '2010-02-09 00:00:00', '2010-02-15 23:14:43', 1, NULL, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `mj_role_alternatives`
--

CREATE TABLE IF NOT EXISTS `mj_role_alternatives` (
  `member_id` mediumint(8) unsigned NOT NULL,
  `role_id` smallint(5) unsigned NOT NULL,
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `whoedit` mediumint(8) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `mj_role_alternatives`
--


-- --------------------------------------------------------

--
-- Структура таблицы `mj_sessions`
--

CREATE TABLE IF NOT EXISTS `mj_sessions` (
  `session_id` char(32) NOT NULL,
  `member_id` mediumint(8) unsigned NOT NULL,
  `data` text,
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `session_id` (`session_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Internal MjCMS user sessions store';

--
-- Дамп данных таблицы `mj_sessions`
--


-- --------------------------------------------------------

--
-- Структура таблицы `mj_short_urls`
--

CREATE TABLE IF NOT EXISTS `mj_short_urls` (
  `alias_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `sugrp_id` int(10) unsigned DEFAULT NULL,
  `is_custom` tinyint(1) NOT NULL,
  `alias` char(8) NOT NULL,
  `sha1_sum` char(40) NOT NULL,
  `orig_url` text NOT NULL,
  `ins` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned NOT NULL,
  PRIMARY KEY (`alias_id`),
  UNIQUE KEY `alias_id_is_custom_idx` (`alias_id`,`is_custom`),
  UNIQUE KEY `grp_alias_idx` (`sugrp_id`,`alias`),
  UNIQUE KEY `sugrp_srch_idx` (`sugrp_id`,`sha1_sum`),
  KEY `srch_idx` (`sugrp_id`,`alias`,`sha1_sum`),
  KEY `sugrp_id_idx` (`sugrp_id`),
  KEY `sugrp_id_is_custom_idx` (`sugrp_id`,`is_custom`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Short urls links' AUTO_INCREMENT=3 ;

--
-- Дамп данных таблицы `mj_short_urls`
--

INSERT INTO `mj_short_urls` (`alias_id`, `sugrp_id`, `is_custom`, `alias`, `sha1_sum`, `orig_url`, `ins`, `upd`, `member_id`, `whoedit`) VALUES
(2, NULL, 1, 'mojo', '6338066e0e94370f64269743aa880b1aa7aaa956', 'http://search.cpan.org/~kraih/', '2010-03-24 17:29:02', '2010-03-24 17:29:02', 1, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `mj_short_url_groups`
--

CREATE TABLE IF NOT EXISTS `mj_short_url_groups` (
  `sugrp_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(32) NOT NULL,
  `ins` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned NOT NULL,
  PRIMARY KEY (`sugrp_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Short url groups' AUTO_INCREMENT=3 ;

--
-- Дамп данных таблицы `mj_short_url_groups`
--

INSERT INTO `mj_short_url_groups` (`sugrp_id`, `name`, `ins`, `upd`, `member_id`, `whoedit`) VALUES
(1, 'SomeElse', '2010-03-23 12:05:56', '2010-03-23 12:51:08', 1, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `mj_users`
--

CREATE TABLE IF NOT EXISTS `mj_users` (
  `member_id` mediumint(8) unsigned NOT NULL,
  `replace_member_id` mediumint(8) unsigned DEFAULT NULL,
  `is_cms_active` tinyint(1) DEFAULT NULL,
  `role_id` smallint(5) unsigned NOT NULL DEFAULT '0',
  `name` tinytext NOT NULL,
  `site_lng` char(4) DEFAULT NULL,
  `ins` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `whoedit` mediumint(8) unsigned DEFAULT NULL,
  `startpage` text,
  PRIMARY KEY (`member_id`),
  KEY `role_idx` (`role_id`),
  KEY `m_id_cms_active_idx` (`member_id`,`is_cms_active`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='MjCMS-specific user fields';

--
-- Дамп данных таблицы `mj_users`
--

INSERT INTO `mj_users` (`member_id`, `replace_member_id`, `is_cms_active`, `role_id`, `name`, `site_lng`, `ins`, `upd`, `whoedit`, `startpage`) VALUES
(0, NULL, 1, 0, 'Guest', NULL, '2010-02-09 00:00:00', '2010-03-22 21:07:38', NULL, '/'),
(1, NULL, 1, 1, 'Austin Powers', 'en', '2010-02-09 00:00:00', '2010-03-22 23:03:05', 1, '/mjadmin/pages');

-- --------------------------------------------------------

--
-- Структура таблицы `mj_users_extrareplaces`
--

CREATE TABLE IF NOT EXISTS `mj_users_extrareplaces` (
  `member_id` mediumint(8) unsigned NOT NULL,
  `slave_id` mediumint(8) unsigned NOT NULL,
  `upd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `whoedit` mediumint(8) NOT NULL,
  UNIQUE KEY `member_slave_idx` (`member_id`,`slave_id`),
  KEY `member_id_idx` (`member_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Extra replaces rules';

--
-- Дамп данных таблицы `mj_users_extrareplaces`
--

