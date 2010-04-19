-- phpMyAdmin SQL Dump
-- version 3.3.1deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 19, 2010 at 04:05 PM
-- Server version: 5.0.51
-- PHP Version: 5.3.1-5

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `mojotest`
--

-- --------------------------------------------------------

--
-- Table structure for table `mjsmf_members`
--

CREATE TABLE IF NOT EXISTS `mjsmf_members` (
  `ID_MEMBER` mediumint(8) unsigned NOT NULL auto_increment,
  `memberName` varchar(80) NOT NULL default '',
  `dateRegistered` int(10) unsigned NOT NULL default '0',
  `posts` mediumint(8) unsigned NOT NULL default '0',
  `ID_GROUP` smallint(5) unsigned NOT NULL default '0',
  `lngfile` tinytext NOT NULL,
  `lastLogin` int(10) unsigned NOT NULL default '0',
  `realName` tinytext NOT NULL,
  `instantMessages` smallint(5) NOT NULL default '0',
  `unreadMessages` smallint(5) NOT NULL default '0',
  `buddy_list` text NOT NULL,
  `pm_ignore_list` tinytext NOT NULL,
  `messageLabels` text NOT NULL,
  `passwd` varchar(64) NOT NULL default '',
  `emailAddress` tinytext NOT NULL,
  `personalText` tinytext NOT NULL,
  `gender` tinyint(4) unsigned NOT NULL default '0',
  `birthdate` date NOT NULL default '0001-01-01',
  `websiteTitle` tinytext NOT NULL,
  `websiteUrl` tinytext NOT NULL,
  `location` tinytext NOT NULL,
  `ICQ` tinytext NOT NULL,
  `AIM` varchar(16) NOT NULL default '',
  `YIM` varchar(32) NOT NULL default '',
  `MSN` tinytext NOT NULL,
  `hideEmail` tinyint(4) NOT NULL default '0',
  `showOnline` tinyint(4) NOT NULL default '1',
  `timeFormat` varchar(80) NOT NULL default '',
  `signature` text NOT NULL,
  `timeOffset` float NOT NULL default '0',
  `avatar` tinytext NOT NULL,
  `pm_email_notify` tinyint(4) NOT NULL default '0',
  `karmaBad` smallint(5) unsigned NOT NULL default '0',
  `karmaGood` smallint(5) unsigned NOT NULL default '0',
  `usertitle` tinytext NOT NULL,
  `notifyAnnouncements` tinyint(4) NOT NULL default '1',
  `notifyOnce` tinyint(4) NOT NULL default '1',
  `notifySendBody` tinyint(4) NOT NULL default '0',
  `notifyTypes` tinyint(4) NOT NULL default '2',
  `memberIP` tinytext NOT NULL,
  `memberIP2` tinytext NOT NULL,
  `secretQuestion` tinytext NOT NULL,
  `secretAnswer` varchar(64) NOT NULL default '',
  `ID_THEME` tinyint(4) unsigned NOT NULL default '0',
  `is_activated` tinyint(3) unsigned NOT NULL default '1',
  `validation_code` varchar(10) NOT NULL default '',
  `ID_MSG_LAST_VISIT` int(10) unsigned NOT NULL default '0',
  `additionalGroups` tinytext NOT NULL,
  `smileySet` varchar(48) NOT NULL default '',
  `ID_POST_GROUP` smallint(5) unsigned NOT NULL default '0',
  `totalTimeLoggedIn` int(10) unsigned NOT NULL default '0',
  `passwordSalt` varchar(5) NOT NULL default '',
  PRIMARY KEY  (`ID_MEMBER`),
  KEY `memberName` (`memberName`(30)),
  KEY `dateRegistered` (`dateRegistered`),
  KEY `ID_GROUP` (`ID_GROUP`),
  KEY `birthdate` (`birthdate`),
  KEY `posts` (`posts`),
  KEY `lastLogin` (`lastLogin`),
  KEY `lngfile` (`lngfile`(30)),
  KEY `ID_POST_GROUP` (`ID_POST_GROUP`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=22 ;

--
-- Dumping data for table `mjsmf_members`
--

INSERT INTO `mjsmf_members` (`ID_MEMBER`, `memberName`, `dateRegistered`, `posts`, `ID_GROUP`, `lngfile`, `lastLogin`, `realName`, `instantMessages`, `unreadMessages`, `buddy_list`, `pm_ignore_list`, `messageLabels`, `passwd`, `emailAddress`, `personalText`, `gender`, `birthdate`, `websiteTitle`, `websiteUrl`, `location`, `ICQ`, `AIM`, `YIM`, `MSN`, `hideEmail`, `showOnline`, `timeFormat`, `signature`, `timeOffset`, `avatar`, `pm_email_notify`, `karmaBad`, `karmaGood`, `usertitle`, `notifyAnnouncements`, `notifyOnce`, `notifySendBody`, `notifyTypes`, `memberIP`, `memberIP2`, `secretQuestion`, `secretAnswer`, `ID_THEME`, `is_activated`, `validation_code`, `ID_MSG_LAST_VISIT`, `additionalGroups`, `smileySet`, `ID_POST_GROUP`, `totalTimeLoggedIn`, `passwordSalt`) VALUES
(0, 'guest', 0, 0, 0, '', 0, 'Guest', 0, 0, '', '', '', '9474d8c82a7bdef16bb503f7dbd1b02f5aaf601f', '', 'I''m guest', 0, '0001-01-01', '', '', '', '', '', '', '', 1, 0, '', '', 0, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 0, 'oyaebu', 0, '', '', 0, 0, '!QAZa'),
(1, 'austin', 0, 0, 0, '', 0, 'Austin Powers', 0, 0, '', '', '', 'affed750772acc7816bdfb3740357b6e40c9e18f', 'austin@powers.ap', '', 0, '1939-11-12', '', '', '', '', '', '', '', 0, 1, '', '', 3, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 1, '', 0, '', '', 0, 0, 'AuSt!'),
(20, 'Morbo', 1271615794, 0, 0, '', 0, 'Morbo', 0, 0, '', '', '', 'ecafe79de815678b999f15a90b4e1cc32a35c09f', 'morbo@powers.app', '', 0, '0001-01-01', '', '', '', '', '', '', '', 1, 1, '', '', 0, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 0, '395bd7cd21', 0, '', '', 0, 0, '5a71'),
(21, 'pepyaka', 1271627335, 0, 0, '', 0, 'pepyaka', 0, 0, '', '', '', '39c17d4c979a0312c04c074e4cde55ad96601d2f', 'pepyaka21@powers.apw', '', 0, '0001-01-01', '', '', '', '', '', '', '', 1, 1, '', '', 0, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 1, '', 0, '', '', 0, 0, 'b7f7');

-- --------------------------------------------------------

--
-- Table structure for table `mjsmf_sessions`
--

CREATE TABLE IF NOT EXISTS `mjsmf_sessions` (
  `session_id` char(32) NOT NULL,
  `last_update` int(10) unsigned NOT NULL,
  `data` text NOT NULL,
  PRIMARY KEY  (`session_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `mjsmf_sessions`
--

INSERT INTO `mjsmf_sessions` (`session_id`, `last_update`, `data`) VALUES
('5d87e770c3c3c9dc8cb7ee12cffaf26b', 1267763364, 'rand_code|s:32:"8b2793eec4261ac1152f1163d3462c67";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('c1aed11fd6814e8ce3d0d254d4aeff51', 1267794440, 'rand_code|s:32:"88d32104c30be589848fc40eacfadbd8";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('93194e33900dc40d5c3c6239994b13eb', 1267830456, 'rand_code|s:32:"9b2566ab58261354ed4539c1870dd94f";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('2c003bc2163cca24732f1ccb39bd9850', 1267906029, 'rand_code|s:32:"1300dd093bb298e2602a0d70c3ff953a";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('46dde114045c96625edebfdb464d5cff', 1269326448, 'rand_code|s:32:"5034b2558667345f96e62facf5d97288";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('8faa911a761b6c866bf9af71a31a8d62', 1269639082, 'rand_code|s:32:"d9695f902adbb31c35751fa9d131ecb7";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('a266592f9feb867bc9f48e7ca7324da0', 1269684537, 'rand_code|s:32:"1a13c836a9958b5b1bfb1db996187279";USER_AGENT|s:100:"Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.1.8) Gecko/20100218 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('0ad0bef55b17b108d7f6dcc8bcb283e5', 1270203841, 'rand_code|s:32:"ab00a75afe7fff443f709344d8ee8c78";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('7e178fde282b447cff905bff966cc426', 1270624228, 'rand_code|s:32:"e2084ed61642e6bdd255097a55ef3d85";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('f1b76994a7fb9002ad35b5d77f0f91a1', 1271409820, 'rand_code|s:32:"2058676fc8c3afeefc3c6ab774cd1b67";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('4f5b80a66385d1267dfd5224cf72eead', 1271490299, 'rand_code|s:32:"07b3030d1d51cdac8c8d53be10bc16b1";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('8dd646045c2f0d2acac397ecff2103a6', 1271571671, 'rand_code|s:32:"31181c61db465da7ac91b5bf25fcb798";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('d5dee676a0f02fdd4a5fb020b83f06a8', 1271668450, 'rand_code|s:32:"8a0322a4f4845231fd3241b2bc292b31";USER_AGENT|s:79:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceape/2.0.3";');

-- --------------------------------------------------------

--
-- Table structure for table `mj_awps`
--

CREATE TABLE IF NOT EXISTS `mj_awps` (
  `awp_id` smallint(5) unsigned NOT NULL auto_increment,
  `name` char(48) NOT NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned default NULL,
  `sequence` tinyint(3) unsigned NOT NULL default '1',
  PRIMARY KEY  (`awp_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='User''s Automated Work Places' AUTO_INCREMENT=6 ;

--
-- Dumping data for table `mj_awps`
--

INSERT INTO `mj_awps` (`awp_id`, `name`, `ins`, `upd`, `member_id`, `whoedit`, `sequence`) VALUES
(0, 'MjNCMS guest AWP', '2010-02-09 00:00:00', '2010-04-15 16:40:56', 1, 1, 255),
(1, 'MjNCMS admin AWP', '2010-02-09 00:00:00', '2010-04-15 11:45:16', 1, NULL, 0),
(2, 'MjNCMS content-side users', '2010-04-15 11:46:35', '2010-04-15 17:09:48', 1, NULL, 200);

-- --------------------------------------------------------

--
-- Table structure for table `mj_blocks`
--

CREATE TABLE IF NOT EXISTS `mj_blocks` (
  `block_id` int(10) unsigned NOT NULL auto_increment,
  `lang` char(4) default NULL,
  `is_active` tinyint(1) unsigned NOT NULL default '0',
  `use_access_roles` tinyint(1) NOT NULL default '0',
  `show_header` tinyint(1) NOT NULL default '1',
  `alias` char(32) default NULL,
  `header` char(64) NOT NULL,
  `body` text NOT NULL,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned NOT NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`block_id`),
  KEY `id_active_idx` (`block_id`,`is_active`),
  KEY `id_active_alias_idx` (`block_id`,`is_active`,`alias`),
  KEY `use_access_roles_idx` (`use_access_roles`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Html blocks table' AUTO_INCREMENT=4 ;

--
-- Dumping data for table `mj_blocks`
--

INSERT INTO `mj_blocks` (`block_id`, `lang`, `is_active`, `use_access_roles`, `show_header`, `alias`, `header`, `body`, `member_id`, `whoedit`, `ins`, `upd`) VALUES
(2, NULL, 1, 0, 1, 'anybody_block', 'Block4Everybody', '<b>Hello everybody</b>\r\n<br /> And 1 more time', 1, 1, '2010-04-18 00:02:26', '2010-04-18 10:42:55');

-- --------------------------------------------------------

--
-- Table structure for table `mj_blocks_access_roles`
--

CREATE TABLE IF NOT EXISTS `mj_blocks_access_roles` (
  `block_id` int(10) unsigned NOT NULL,
  `role_id` smallint(5) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned NOT NULL,
  `ins` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  UNIQUE KEY `block_role_idx` (`block_id`,`role_id`),
  KEY `block_id_idx` (`block_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='blocks roles access limitations';

--
-- Dumping data for table `mj_blocks_access_roles`
--


-- --------------------------------------------------------

--
-- Table structure for table `mj_blocks_translations`
--

CREATE TABLE IF NOT EXISTS `mj_blocks_translations` (
  `block_id` int(10) unsigned NOT NULL,
  `lang` char(4) NOT NULL,
  `header` char(64) NOT NULL,
  `body` text,
  `member_id` mediumint(8) NOT NULL,
  `whoedit` mediumint(8) NOT NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  UNIQUE KEY `block_lang_idx` (`block_id`,`lang`),
  KEY `block_id_idx` (`block_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Blocks translations table';

--
-- Dumping data for table `mj_blocks_translations`
--


-- --------------------------------------------------------

--
-- Table structure for table `mj_cats_data`
--

CREATE TABLE IF NOT EXISTS `mj_cats_data` (
  `cat_id` int(10) unsigned NOT NULL,
  `lang` char(4) NOT NULL,
  `name` char(32) NOT NULL,
  `cname` char(16) default NULL,
  `descr` text NOT NULL,
  `keywords` text NOT NULL,
  `is_active` tinyint(1) NOT NULL default '1',
  `extra_data` text NOT NULL,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned default NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  UNIQUE KEY `cat_id_idx` (`cat_id`),
  KEY `cname_idx` (`cname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Categories data';

--
-- Dumping data for table `mj_cats_data`
--

INSERT INTO `mj_cats_data` (`cat_id`, `lang`, `name`, `cname`, `descr`, `keywords`, `is_active`, `extra_data`, `member_id`, `whoedit`, `ins`, `upd`) VALUES
(9, 'en', 'Demo 2', 'demo2', 'demo2 descr', 'demo2 kwds', 1, '', 1, NULL, '2010-04-12 14:11:29', '2010-04-12 14:11:29'),
(8, 'en', 'Demo 1', 'demo1', 'demo1 descr', 'demo1 kwds', 1, '', 1, 1, '2010-04-12 14:10:35', '2010-04-12 14:11:06');

-- --------------------------------------------------------

--
-- Table structure for table `mj_cats_trans`
--

CREATE TABLE IF NOT EXISTS `mj_cats_trans` (
  `cat_id` int(10) NOT NULL,
  `lang` char(4) NOT NULL,
  `name` char(32) NOT NULL,
  `descr` text NOT NULL,
  `keywords` text NOT NULL,
  `member_id` mediumint(8) NOT NULL,
  `whoedit` mediumint(8) default NULL,
  `ins` datetime NOT NULL,
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  UNIQUE KEY `menu_lng_idx` (`cat_id`,`lang`),
  KEY `cat_id_idx` (`cat_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Categories translations';

--
-- Dumping data for table `mj_cats_trans`
--


-- --------------------------------------------------------

--
-- Table structure for table `mj_cats_tree`
--

CREATE TABLE IF NOT EXISTS `mj_cats_tree` (
  `id` int(10) NOT NULL auto_increment,
  `level` tinyint(3) NOT NULL default '1',
  `left_key` int(10) NOT NULL default '0',
  `right_key` int(10) NOT NULL default '0',
  `group` int(10) NOT NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `level` (`level`),
  KEY `group` (`group`),
  KEY `comlete_idx` (`level`,`left_key`,`right_key`,`group`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Categories data tree' AUTO_INCREMENT=10 ;

--
-- Dumping data for table `mj_cats_tree`
--

INSERT INTO `mj_cats_tree` (`id`, `level`, `left_key`, `right_key`, `group`, `ins`, `upd`) VALUES
(9, 1, 3, 4, 0, '0000-00-00 00:00:00', '2010-04-12 14:11:29'),
(8, 1, 1, 2, 0, '0000-00-00 00:00:00', '2010-04-12 14:10:35');

-- --------------------------------------------------------

--
-- Table structure for table `mj_menus_data`
--

CREATE TABLE IF NOT EXISTS `mj_menus_data` (
  `menu_id` int(10) unsigned NOT NULL,
  `lang` char(4) NOT NULL,
  `text` char(32) NOT NULL,
  `cname` char(16) default NULL,
  `link` text NOT NULL,
  `is_active` tinyint(1) NOT NULL default '1',
  `extra_data` text NOT NULL,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned default NULL,
  `ins` datetime NOT NULL,
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  UNIQUE KEY `menu_id_idx` (`menu_id`),
  KEY `cname_idx` (`cname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `mj_menus_data`
--

INSERT INTO `mj_menus_data` (`menu_id`, `lang`, `text`, `cname`, `link`, `is_active`, `extra_data`, `member_id`, `whoedit`, `ins`, `upd`) VALUES
(3, 'en', 'MjNCMS adm menu', 'mjncmsadm', '', 1, '', 1, 1, '2010-02-26 23:45:35', '2010-04-14 22:28:55'),
(37, 'en', 'SiteMenu', 'onsite', '', 1, '', 1, NULL, '2010-04-12 23:02:24', '2010-04-12 23:02:24'),
(39, 'en', 'JustPage', '', '/justpage.html', 1, '', 1, 1, '2010-04-13 00:18:18', '2010-04-13 00:29:34'),
(36, 'en', 'Admin', 'admin', '/mjadmin', 1, '', 1, NULL, '2010-04-12 14:08:28', '2010-04-12 14:08:28'),
(47, 'en', 'Add ShortLink', '', '/sl/add', 1, '', 1, NULL, '2010-04-15 21:13:05', '2010-04-15 21:13:05'),
(46, 'en', '4Users', '', '/user', 1, '', 1, 1, '2010-04-15 20:43:12', '2010-04-19 00:52:27'),
(40, 'en', 'DemoCat1', '', '/demo1.htm', 1, '', 1, 1, '2010-04-13 00:19:30', '2010-04-15 20:41:43'),
(41, 'en', 'DemoCat2', '', '/demo2.htm', 1, '', 1, 1, '2010-04-13 00:19:51', '2010-04-15 20:41:51'),
(44, 'en', 'Forum', '', '/forum', 1, '', 1, NULL, '2010-04-13 11:28:14', '2010-04-13 11:28:14'),
(45, 'en', 'Main page', '', '/', 1, '', 1, NULL, '2010-04-15 20:31:23', '2010-04-15 20:31:23');

-- --------------------------------------------------------

--
-- Table structure for table `mj_menus_trans`
--

CREATE TABLE IF NOT EXISTS `mj_menus_trans` (
  `menu_id` int(10) NOT NULL,
  `lang` char(4) NOT NULL,
  `text` char(32) NOT NULL,
  `link` text NOT NULL,
  `member_id` mediumint(8) NOT NULL,
  `whoedit` mediumint(8) default NULL,
  `ins` datetime NOT NULL,
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  UNIQUE KEY `menu_lng_idx` (`menu_id`,`lang`),
  KEY `menu_id_idx` (`menu_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Menus translations';

--
-- Dumping data for table `mj_menus_trans`
--

INSERT INTO `mj_menus_trans` (`menu_id`, `lang`, `text`, `link`, `member_id`, `whoedit`, `ins`, `upd`) VALUES
(36, 'ru', 'Админка', '', 1, NULL, '2010-04-14 11:54:41', '2010-04-14 11:54:41');

-- --------------------------------------------------------

--
-- Table structure for table `mj_menus_tree`
--

CREATE TABLE IF NOT EXISTS `mj_menus_tree` (
  `id` int(10) NOT NULL auto_increment,
  `level` tinyint(3) NOT NULL default '1',
  `left_key` int(10) NOT NULL default '0',
  `right_key` int(10) NOT NULL default '0',
  `group` int(10) NOT NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `level` (`level`),
  KEY `group` (`group`),
  KEY `comlete_idx` (`level`,`left_key`,`right_key`,`group`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Menus data tree' AUTO_INCREMENT=48 ;

--
-- Dumping data for table `mj_menus_tree`
--

INSERT INTO `mj_menus_tree` (`id`, `level`, `left_key`, `right_key`, `group`, `ins`, `upd`) VALUES
(3, 1, 1, 6, 0, '0000-00-00 00:00:00', '2010-04-13 11:28:14'),
(37, 1, 7, 20, 0, '0000-00-00 00:00:00', '2010-04-15 21:13:05'),
(39, 2, 14, 15, 0, '0000-00-00 00:00:00', '2010-04-15 21:13:19'),
(36, 2, 2, 3, 0, '0000-00-00 00:00:00', '2010-04-12 14:08:28'),
(47, 2, 12, 13, 0, '0000-00-00 00:00:00', '2010-04-15 21:13:19'),
(46, 2, 10, 11, 0, '0000-00-00 00:00:00', '2010-04-15 21:13:19'),
(45, 2, 8, 9, 0, '0000-00-00 00:00:00', '2010-04-15 21:13:19'),
(44, 2, 4, 5, 0, '0000-00-00 00:00:00', '2010-04-13 11:28:14'),
(41, 2, 18, 19, 0, '0000-00-00 00:00:00', '2010-04-15 21:13:19'),
(40, 2, 16, 17, 0, '0000-00-00 00:00:00', '2010-04-15 21:13:19');

-- --------------------------------------------------------

--
-- Table structure for table `mj_pages`
--

CREATE TABLE IF NOT EXISTS `mj_pages` (
  `page_id` bigint(20) unsigned NOT NULL auto_increment,
  `is_published` tinyint(1) unsigned NOT NULL default '1',
  `cat_id` int(10) unsigned NOT NULL,
  `lang` char(4) NOT NULL,
  `slug` char(128) default NULL,
  `intro` text NOT NULL,
  `body` text,
  `header` char(64) NOT NULL,
  `descr` text NOT NULL,
  `keywords` char(255) NOT NULL,
  `showintro` tinyint(1) NOT NULL default '1',
  `use_customtitle` tinyint(1) NOT NULL default '0',
  `custom_title` char(128) default NULL,
  `allow_comments` tinyint(1) unsigned NOT NULL default '0',
  `comments_mode` enum('comment','thread') default 'comment',
  `use_password` tinyint(1) NOT NULL default '0',
  `password` char(64) default NULL,
  `use_access_roles` tinyint(1) NOT NULL default '0',
  `comments_count` bigint(20) NOT NULL,
  `author_id` mediumint(8) NOT NULL,
  `member_id` mediumint(8) NOT NULL,
  `whoedit` mediumint(8) NOT NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `dt_created` datetime NOT NULL,
  `dt_publishstart` datetime default NULL,
  `dt_publishend` datetime default NULL,
  PRIMARY KEY  (`page_id`),
  UNIQUE KEY `slug_uniq_idx` (`slug`),
  KEY `use_access_roles_idx` (`use_access_roles`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Active posts table' AUTO_INCREMENT=5 ;

--
-- Dumping data for table `mj_pages`
--

INSERT INTO `mj_pages` (`page_id`, `is_published`, `cat_id`, `lang`, `slug`, `intro`, `body`, `header`, `descr`, `keywords`, `showintro`, `use_customtitle`, `custom_title`, `allow_comments`, `comments_mode`, `use_password`, `password`, `use_access_roles`, `comments_count`, `author_id`, `member_id`, `whoedit`, `ins`, `upd`, `dt_created`, `dt_publishstart`, `dt_publishend`) VALUES
(1, 1, 0, 'en', 'justpage', '<p>\n	<img alt="" ilo-full-src="http://mojotest:82/userfiles/mjncms/1/avopingvo.jpg" src="/userfiles/mjncms/1/avopingvo.jpg" style="width: 96px; height: 96px;" /></p>\n<p>\n	This is justpage intro. hi! cool!</p>\n<p>\n	&nbsp;</p>\n<p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-14 22:38:35', '2010-04-12 02:13:00', '2010-04-12 02:13:00', NULL),
(2, 1, 8, 'en', 'd1cp1', '<p>\n	iintro</p>\n', '<p>\n	bbody</p>\n', 'demo1 cat page 1', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 0, '2010-04-12 14:15:14', '2010-04-12 14:15:14', '2010-04-12 03:14:00', '2010-04-12 03:14:00', NULL),
(3, 1, 8, 'en', 'd1cp2', '<p>\n	introoo</p>\n', '<p>\n	bodyyy</p>\n', 'demo1 cat page 2', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:15:44', '2010-04-12 14:18:35', '2010-04-12 04:15:00', '2010-04-12 04:15:00', NULL),
(4, 1, 0, 'en', 'index', '<p>\n	Index page</p>\n', '<p>\n	bla</p>\n<p>\n	bla</p>\n<p>\n	&nbsp;</p>\n<p>\n	be careful this demo runs on lowerclocked NAS :)</p>\n<p>\n	&nbsp;</p>\n<p>\n	bla</p>\n<p>\n	Index so index....</p>\n<p>\n	&nbsp;</p>\n<p>\n	btw, <a href="/mjadmin">admin side</a></p>', 'Main index page', 'MjNCMS project - PERL Mojolicious CMS demo site index page', 'MjNCMS, Mojolicious, Mojo, CMS', 1, 1, 'MjNCMS project demo site index page', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-15 19:45:55', '2010-04-18 10:36:08', '2010-04-15 11:45:00', '2010-04-15 11:45:00', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `mj_pages_access_roles`
--

CREATE TABLE IF NOT EXISTS `mj_pages_access_roles` (
  `page_id` int(10) unsigned NOT NULL,
  `role_id` smallint(5) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned NOT NULL,
  `ins` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  UNIQUE KEY `page_role_idx` (`page_id`,`role_id`),
  KEY `page_id_idx` (`page_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='pages roles access limitations';

--
-- Dumping data for table `mj_pages_access_roles`
--


-- --------------------------------------------------------

--
-- Table structure for table `mj_pages_archive`
--

CREATE TABLE IF NOT EXISTS `mj_pages_archive` (
  `id` bigint(20) unsigned NOT NULL auto_increment,
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
  `use_access_roles` tinyint(1) NOT NULL,
  `comments_count` bigint(20) NOT NULL,
  `author_id` mediumint(8) NOT NULL,
  `member_id` mediumint(8) NOT NULL,
  `whoedit` mediumint(8) NOT NULL,
  `ins` datetime NOT NULL,
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `dt_created` datetime NOT NULL,
  `dt_publishstart` datetime NOT NULL,
  `dt_publishend` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Archive posts table' AUTO_INCREMENT=20 ;

--
-- Dumping data for table `mj_pages_archive`
--

INSERT INTO `mj_pages_archive` (`id`, `page_id`, `is_published`, `cat_id`, `lang`, `slug`, `intro`, `body`, `header`, `descr`, `keywords`, `showintro`, `use_customtitle`, `custom_title`, `allow_comments`, `comments_mode`, `use_password`, `password`, `use_access_roles`, `comments_count`, `author_id`, `member_id`, `whoedit`, `ins`, `upd`, `dt_created`, `dt_publishstart`, `dt_publishend`) VALUES
(1, 3, 1, 8, 'en', 'd1cp2', '<p>\n	introoo</p>\n', '<p>\n	bodyyy</p>\n', 'demo1 cat page 2', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:15:44', '2010-04-12 14:18:35', '2010-04-12 03:15:00', '2010-04-12 03:15:00', '0000-00-00 00:00:00'),
(2, 1, 1, 0, 'en', 'justpage', '<p>\n	This is justpage intro</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 14:19:16', '2010-04-12 03:13:00', '2010-04-12 03:13:00', '0000-00-00 00:00:00'),
(3, 1, 1, 0, 'en', 'justpage', '<p>\n	This is justpage intro</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 14:19:34', '2010-04-12 04:13:00', '2010-04-12 04:13:00', '0000-00-00 00:00:00'),
(4, 1, 1, 0, 'en', 'justpage', '<p>\n	This is justpage intro</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 22:29:34', '2010-04-12 05:13:00', '2010-04-12 05:13:00', '0000-00-00 00:00:00'),
(5, 1, 1, 0, 'en', 'justpage', '<p>\n	This is justpage intro</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 22:30:59', '2010-04-12 06:13:00', '2010-04-12 06:13:00', '0000-00-00 00:00:00'),
(6, 1, 1, 0, 'en', 'justpage', '<p>\n	This is justpage introoo</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 22:31:27', '2010-04-12 06:13:00', '2010-04-12 06:13:00', '0000-00-00 00:00:00'),
(7, 1, 1, 0, 'en', 'justpage', '<p>\n	This is justpage introoo</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 22:31:52', '2010-04-12 07:13:00', '2010-04-12 07:13:00', '0000-00-00 00:00:00'),
(8, 1, 1, 0, 'en', 'justpage', '<p>\n	This is justpage introoo</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 22:37:29', '2010-04-12 08:13:00', '2010-04-12 08:13:00', '0000-00-00 00:00:00'),
(9, 1, 1, 0, 'en', 'justpage', '<p>\n	This is justpage introoo</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 22:39:11', '2010-04-12 09:13:00', '2010-04-12 09:13:00', '0000-00-00 00:00:00'),
(10, 1, 1, 0, 'en', 'justpage', '<p>\n	This is justpage intro. hi!</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 22:40:26', '2010-04-12 09:13:00', '2010-04-12 09:13:00', '0000-00-00 00:00:00'),
(11, 1, 1, 0, 'en', 'justpage', '<p>\n	This is justpage intro. hi!</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 22:41:31', '2010-04-12 10:13:00', '2010-04-12 10:13:00', '0000-00-00 00:00:00'),
(12, 1, 1, 0, 'en', 'justpage', '<p>\n	This is justpage intro. hi! eee!</p>', '<p>\n	This is justpagebody</p>', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 22:41:51', '2010-04-12 10:13:00', '2010-04-12 10:13:00', '0000-00-00 00:00:00'),
(13, 1, 1, 0, 'en', 'justpage', '<p>\n	<img alt="" ilo-full-src="http://mojotest:82/userfiles/mjcms/1/avopingvo.jpg" src="/userfiles/mjcms/1/avopingvo.jpg" style="width: 96px; height: 96px;" /></p>\n<p>\n	This is justpage intro. hi! eee!</p>', '<p>\n	This is justpagebody</p>', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 23:01:12', '2010-04-12 10:13:00', '2010-04-12 10:13:00', '0000-00-00 00:00:00'),
(14, 1, 1, 0, 'en', 'justpage', '<p>\n	<img alt="" ilo-full-src="http://mojotest:82/userfiles/mjcms/1/avopingvo.jpg" src="/userfiles/mjcms/1/avopingvo.jpg" style="width: 96px; height: 96px;" /></p>\n<p>\n	This is justpage intro. hi!</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-12 23:01:24', '2010-04-12 11:13:00', '2010-04-12 11:13:00', '0000-00-00 00:00:00'),
(15, 1, 1, 0, 'en', 'justpage', '<p>\n	<img alt="" ilo-full-src="http://mojotest:82/userfiles/mjcms/1/avopingvo.jpg" src="/userfiles/mjcms/1/avopingvo.jpg" style="width: 96px; height: 96px;" /></p>\n<p>\n	This is justpage intro. hi! cool!</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-14 12:04:38', '2010-04-12 12:13:00', '2010-04-12 12:13:00', '0000-00-00 00:00:00'),
(16, 1, 1, 0, 'en', 'justpage', '<p>\n	<img alt="" ilo-full-src="http://mojotest:82/userfiles/mjcms/1/avopingvo.jpg" src="/userfiles/mjcms/1/avopingvo.jpg" style="width: 96px; height: 96px;" /></p>\n<p>\n	This is justpage intro. hi! cool!</p>\n<p>\n	&nbsp;</p>\n<p>\n	А вот хуй!</p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-14 22:38:35', '2010-04-12 01:13:00', '2010-04-12 01:13:00', '0000-00-00 00:00:00'),
(17, 4, 1, 0, 'en', 'index', '<p>\n	Index page</p>\n', '<p>\n	bla</p>\n<p>\n	bla</p>\n<p>\n	bla</p>\n<p>\n	Index so index....</p>\n', 'Main index page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-15 19:45:55', '2010-04-15 20:40:43', '2010-04-15 08:45:00', '2010-04-15 08:45:00', '0000-00-00 00:00:00'),
(18, 4, 1, 0, 'en', 'index', '<p>\n	Index page</p>\n', '<p>\n	bla</p>\n<p>\n	bla</p>\n<p>\n	bla</p>\n<p>\n	Index so index....</p>\n', 'Main index page', 'MjNCMS project demo site index page', 'MjNCMS, Mojolicious, Mojo', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-15 19:45:55', '2010-04-18 01:16:18', '2010-04-15 09:45:00', '2010-04-15 09:45:00', '0000-00-00 00:00:00'),
(19, 4, 1, 0, 'en', 'index', '<p>\n	Index page</p>\n', '<p>\n	bla</p>\n<p>\n	bla</p>\n<p>\n	&nbsp;</p>\n<p>\n	be careful this demo runs on lowerclocked NAS :)</p>\n<p>\n	&nbsp;</p>\n<p>\n	bla</p>\n<p>\n	Index so index....</p>\n<p>\n	&nbsp;</p>\n<p>\n	btw, <a href="/mjadmin">admin side</a></p>\n<p>\n	&nbsp;</p>', 'Main index page', 'MjNCMS project demo site index page', 'MjNCMS, Mojolicious, Mojo', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-15 19:45:55', '2010-04-18 10:36:08', '2010-04-15 10:45:00', '2010-04-15 10:45:00', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `mj_pages_translations`
--

CREATE TABLE IF NOT EXISTS `mj_pages_translations` (
  `page_id` bigint(20) unsigned NOT NULL,
  `lang` char(4) NOT NULL,
  `intro` text NOT NULL,
  `body` text,
  `header` char(64) NOT NULL,
  `descr` text NOT NULL,
  `keywords` char(255) NOT NULL,
  `custom_title` char(128) default NULL,
  `member_id` mediumint(8) NOT NULL,
  `whoedit` mediumint(8) NOT NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  UNIQUE KEY `page_lang_idx` (`page_id`,`lang`),
  KEY `page_id_idx` (`page_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Pages translations table';

--
-- Dumping data for table `mj_pages_translations`
--


-- --------------------------------------------------------

--
-- Table structure for table `mj_permissions`
--

CREATE TABLE IF NOT EXISTS `mj_permissions` (
  `permission_id` int(10) unsigned NOT NULL,
  `awp_id` int(10) unsigned default NULL,
  `role_id` int(10) unsigned default NULL,
  `r` tinyint(1) unsigned NOT NULL default '0',
  `w` tinyint(1) unsigned NOT NULL default '0',
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned default NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  KEY `perm_role_idx` (`permission_id`,`role_id`),
  KEY `role_id_idx` (`role_id`),
  KEY `awp_id_idx` (`awp_id`),
  KEY `perm_awp_idx` (`permission_id`,`awp_id`),
  KEY `perm_awp_role_idx` (`permission_id`,`awp_id`,`role_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Permissions by awp:role combo';

--
-- Dumping data for table `mj_permissions`
--

INSERT INTO `mj_permissions` (`permission_id`, `awp_id`, `role_id`, `r`, `w`, `member_id`, `whoedit`, `ins`, `upd`) VALUES
(15, NULL, 1, 1, 1, 1, NULL, '2010-04-18 16:55:28', '2010-04-18 16:55:28'),
(17, NULL, 1, 1, 1, 1, NULL, '2010-04-18 16:55:28', '2010-04-18 16:55:28'),
(9, NULL, 1, 1, 1, 1, NULL, '2010-04-18 16:55:28', '2010-04-18 16:55:28'),
(16, NULL, 1, 1, 1, 1, NULL, '2010-04-18 16:55:28', '2010-04-18 16:55:28'),
(10, NULL, 1, 1, 1, 1, NULL, '2010-04-18 16:55:28', '2010-04-18 16:55:28'),
(13, NULL, 1, 1, 1, 1, NULL, '2010-04-18 16:55:28', '2010-04-18 16:55:28'),
(22, NULL, 1, 1, 1, 1, NULL, '2010-04-18 16:55:28', '2010-04-18 16:55:28'),
(8, NULL, 1, 1, 1, 1, NULL, '2010-04-18 16:55:28', '2010-04-18 16:55:28'),
(19, 1, NULL, 1, 1, 1, NULL, '2010-04-18 16:54:54', '2010-04-18 16:54:54'),
(18, 1, NULL, 1, 1, 1, NULL, '2010-04-18 16:54:54', '2010-04-18 16:54:54'),
(4, 1, NULL, 1, 1, 1, NULL, '2010-04-18 16:54:54', '2010-04-18 16:54:54'),
(14, 1, NULL, 1, 1, 1, NULL, '2010-04-18 16:54:54', '2010-04-18 16:54:54'),
(20, 1, NULL, 1, 1, 1, NULL, '2010-04-18 16:54:54', '2010-04-18 16:54:54'),
(2, 1, NULL, 1, 1, 1, NULL, '2010-04-18 16:54:54', '2010-04-18 16:54:54'),
(19, 2, NULL, 1, 1, 1, NULL, '2010-04-16 13:40:17', '2010-04-16 13:40:17'),
(19, 0, NULL, 1, 1, 1, NULL, '2010-04-16 13:40:04', '2010-04-16 13:40:04'),
(3, 1, NULL, 1, 1, 1, NULL, '2010-04-18 16:54:54', '2010-04-18 16:54:54'),
(20, 0, NULL, 1, 1, 1, NULL, '2010-04-16 13:40:04', '2010-04-16 13:40:04'),
(20, 2, NULL, 1, 1, 1, NULL, '2010-04-16 13:40:17', '2010-04-16 13:40:17'),
(21, 1, NULL, 1, 1, 1, NULL, '2010-04-18 16:54:54', '2010-04-18 16:54:54'),
(11, 1, NULL, 1, 1, 1, NULL, '2010-04-18 16:54:54', '2010-04-18 16:54:54');

-- --------------------------------------------------------

--
-- Table structure for table `mj_permission_types`
--

CREATE TABLE IF NOT EXISTS `mj_permission_types` (
  `permission_id` int(10) unsigned NOT NULL auto_increment,
  `controller` char(32) NOT NULL,
  `action` char(32) NOT NULL,
  `descr` char(64) NOT NULL,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned default NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`permission_id`),
  UNIQUE KEY `c_a_uniq_idx` (`controller`,`action`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Permission types library' AUTO_INCREMENT=25 ;

--
-- Dumping data for table `mj_permission_types`
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
(17, 'users', 'manage', 'Allow manage users records', 1, NULL, '2010-03-29 00:11:30', '2010-03-29 00:11:30'),
(18, 'translations', 'manage', 'Manage translations', 1, NULL, '2010-04-09 14:44:11', '2010-04-09 14:44:11'),
(19, 'users', 'auth', 'Allow users do auth things login/logout, etc', 1, 1, '2010-04-15 12:43:56', '2010-04-17 18:09:44'),
(20, 'urls', 'contentside_add', 'Allow add urls from content-side', 1, NULL, '2010-04-16 13:39:36', '2010-04-16 13:39:36'),
(21, 'blocks', 'manage', 'Allow manage blocks', 1, 1, '2010-04-17 18:07:54', '2010-04-17 18:08:24'),
(22, 'blocks', 'manage_any', 'Allow manage any user''s blocks', 1, NULL, '2010-04-17 18:08:14', '2010-04-17 18:08:14'),
(23, 'blocks', 'manage_others', 'Allow manage same role user''s blocks', 1, NULL, '2010-04-17 18:08:50', '2010-04-17 18:08:50');

-- --------------------------------------------------------

--
-- Table structure for table `mj_roles`
--

CREATE TABLE IF NOT EXISTS `mj_roles` (
  `role_id` smallint(5) unsigned NOT NULL auto_increment,
  `awp_id` smallint(5) unsigned NOT NULL,
  `name` char(48) NOT NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned default NULL,
  `sequence` tinyint(3) unsigned NOT NULL default '1',
  PRIMARY KEY  (`role_id`),
  KEY `awp_id_idx` (`awp_id`),
  KEY `alternatives_idx` (`role_id`,`awp_id`,`sequence`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='User''s roles @ workplaces [text_content/moderator, etc]' AUTO_INCREMENT=6 ;

--
-- Dumping data for table `mj_roles`
--

INSERT INTO `mj_roles` (`role_id`, `awp_id`, `name`, `ins`, `upd`, `member_id`, `whoedit`, `sequence`) VALUES
(0, 0, 'MjNCMS guest role', '2010-02-09 00:00:00', '2010-04-15 11:45:27', 1, NULL, 255),
(1, 1, 'MjNCMS admin role', '2010-02-09 00:00:00', '2010-04-15 11:45:35', 1, NULL, 0),
(2, 2, 'Standart User', '2010-04-15 11:47:23', '2010-04-15 17:11:31', 1, 1, 200),
(5, 1, 'Content editor', '2010-04-18 22:34:49', '2010-04-18 22:34:49', 1, NULL, 200);

-- --------------------------------------------------------

--
-- Table structure for table `mj_role_alternatives`
--

CREATE TABLE IF NOT EXISTS `mj_role_alternatives` (
  `member_id` mediumint(8) unsigned NOT NULL,
  `role_id` smallint(5) unsigned NOT NULL,
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `whoedit` mediumint(8) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `mj_role_alternatives`
--

INSERT INTO `mj_role_alternatives` (`member_id`, `role_id`, `upd`, `whoedit`) VALUES
(1, 2, '2010-04-18 22:36:45', 1),
(1, 1, '2010-04-18 22:36:45', 1);

-- --------------------------------------------------------

--
-- Table structure for table `mj_sessions`
--

CREATE TABLE IF NOT EXISTS `mj_sessions` (
  `session_id` char(32) NOT NULL,
  `member_id` mediumint(8) unsigned NOT NULL,
  `data` text,
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  UNIQUE KEY `session_id` (`session_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Internal MjCMS user sessions store';

--
-- Dumping data for table `mj_sessions`
--


-- --------------------------------------------------------

--
-- Table structure for table `mj_short_urls`
--

CREATE TABLE IF NOT EXISTS `mj_short_urls` (
  `alias_id` bigint(20) unsigned NOT NULL auto_increment,
  `sugrp_id` int(10) unsigned default NULL,
  `is_custom` tinyint(1) NOT NULL,
  `alias` char(8) NOT NULL,
  `sha1_sum` char(40) NOT NULL,
  `orig_url` text NOT NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned NOT NULL,
  PRIMARY KEY  (`alias_id`),
  UNIQUE KEY `alias_id_is_custom_idx` (`alias_id`,`is_custom`),
  UNIQUE KEY `grp_alias_idx` (`sugrp_id`,`alias`),
  UNIQUE KEY `sugrp_srch_idx` (`sugrp_id`,`sha1_sum`),
  KEY `srch_idx` (`sugrp_id`,`alias`,`sha1_sum`),
  KEY `sugrp_id_idx` (`sugrp_id`),
  KEY `sugrp_id_is_custom_idx` (`sugrp_id`,`is_custom`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Short urls links' AUTO_INCREMENT=5 ;

--
-- Dumping data for table `mj_short_urls`
--

INSERT INTO `mj_short_urls` (`alias_id`, `sugrp_id`, `is_custom`, `alias`, `sha1_sum`, `orig_url`, `ins`, `upd`, `member_id`, `whoedit`) VALUES
(2, NULL, 1, 'mojo', '6338066e0e94370f64269743aa880b1aa7aaa956', 'http://search.cpan.org/~kraih/', '2010-03-24 17:29:02', '2010-03-24 17:29:02', 1, 0),
(3, NULL, 0, '1', '252682bb9a8891c2ddd45d62eb597093def84b72', 'http://leprosorium.ru/', '2010-04-16 13:47:27', '2010-04-16 13:47:27', 1, 0),
(4, NULL, 1, 'wowowowo', '37f07ecc66f7c5334e1b95ff0e7a0afefadc23b6', 'http://groups.google.com/group/mojolicious/', '2010-04-16 14:11:54', '2010-04-16 14:11:54', 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `mj_short_url_groups`
--

CREATE TABLE IF NOT EXISTS `mj_short_url_groups` (
  `sugrp_id` int(10) unsigned NOT NULL auto_increment,
  `name` char(32) NOT NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `member_id` mediumint(8) unsigned NOT NULL,
  `whoedit` mediumint(8) unsigned NOT NULL,
  PRIMARY KEY  (`sugrp_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Short url groups' AUTO_INCREMENT=3 ;

--
-- Dumping data for table `mj_short_url_groups`
--

INSERT INTO `mj_short_url_groups` (`sugrp_id`, `name`, `ins`, `upd`, `member_id`, `whoedit`) VALUES
(1, 'SomeElse', '2010-03-23 12:05:56', '2010-03-23 12:51:08', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `mj_users`
--

CREATE TABLE IF NOT EXISTS `mj_users` (
  `member_id` mediumint(8) unsigned NOT NULL,
  `replace_member_id` mediumint(8) unsigned default NULL,
  `is_cms_active` tinyint(1) default NULL,
  `role_id` smallint(5) unsigned NOT NULL default '0',
  `name` tinytext NOT NULL,
  `site_lng` char(4) default NULL,
  `ins` datetime NOT NULL default '0000-00-00 00:00:00',
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `whoedit` mediumint(8) unsigned default NULL,
  `startpage` text,
  PRIMARY KEY  (`member_id`),
  KEY `role_idx` (`role_id`),
  KEY `m_id_cms_active_idx` (`member_id`,`is_cms_active`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='MjCMS-specific user fields';

--
-- Dumping data for table `mj_users`
--

INSERT INTO `mj_users` (`member_id`, `replace_member_id`, `is_cms_active`, `role_id`, `name`, `site_lng`, `ins`, `upd`, `whoedit`, `startpage`) VALUES
(0, NULL, 1, 0, 'Guest', NULL, '2010-02-09 00:00:00', '2010-03-22 21:07:38', NULL, '/'),
(1, 1, 1, 1, 'Austin Powers', 'en', '2010-02-09 00:00:00', '2010-04-19 00:14:28', 1, '/mjadmin/pages'),
(20, NULL, 1, 5, 'Morbo', 'en', '0000-00-00 00:00:00', '2010-04-18 22:36:34', 1, '/'),
(21, NULL, 1, 2, 'pepyaka222', 'en', '0000-00-00 00:00:00', '2010-04-19 15:59:47', 0, '/');

-- --------------------------------------------------------

--
-- Table structure for table `mj_users_extrareplaces`
--

CREATE TABLE IF NOT EXISTS `mj_users_extrareplaces` (
  `member_id` mediumint(8) unsigned NOT NULL,
  `slave_id` mediumint(8) unsigned NOT NULL,
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `whoedit` mediumint(8) NOT NULL,
  UNIQUE KEY `member_slave_idx` (`member_id`,`slave_id`),
  KEY `member_id_idx` (`member_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Extra replaces rules';

--
-- Dumping data for table `mj_users_extrareplaces`
--

INSERT INTO `mj_users_extrareplaces` (`member_id`, `slave_id`, `upd`, `whoedit`) VALUES
(1, 1, '2010-04-18 22:36:45', 1);
