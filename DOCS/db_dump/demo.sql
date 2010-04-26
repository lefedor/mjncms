-- phpMyAdmin SQL Dump
-- version 3.3.1deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 27, 2010 at 02:20 AM
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
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=41 ;

--
-- Dumping data for table `mjsmf_members`
--

INSERT INTO `mjsmf_members` (`ID_MEMBER`, `memberName`, `dateRegistered`, `posts`, `ID_GROUP`, `lngfile`, `lastLogin`, `realName`, `instantMessages`, `unreadMessages`, `buddy_list`, `pm_ignore_list`, `messageLabels`, `passwd`, `emailAddress`, `personalText`, `gender`, `birthdate`, `websiteTitle`, `websiteUrl`, `location`, `ICQ`, `AIM`, `YIM`, `MSN`, `hideEmail`, `showOnline`, `timeFormat`, `signature`, `timeOffset`, `avatar`, `pm_email_notify`, `karmaBad`, `karmaGood`, `usertitle`, `notifyAnnouncements`, `notifyOnce`, `notifySendBody`, `notifyTypes`, `memberIP`, `memberIP2`, `secretQuestion`, `secretAnswer`, `ID_THEME`, `is_activated`, `validation_code`, `ID_MSG_LAST_VISIT`, `additionalGroups`, `smileySet`, `ID_POST_GROUP`, `totalTimeLoggedIn`, `passwordSalt`) VALUES
(0, 'guest', 0, 0, 0, '', 0, 'Guest', 0, 0, '', '', '', '9474d8c82a7bdef16bb503f7dbd1b02f5aaf601f', '', 'I''m guest', 0, '0001-01-01', '', '', '', '', '', '', '', 1, 0, '', '', 0, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 0, 'oyaebu', 0, '', '', 0, 0, '!QAZa'),
(1, 'austin', 0, 0, 0, '', 0, 'Austin Powers', 0, 0, '', '', '', 'affed750772acc7816bdfb3740357b6e40c9e18f', 'austin@powers.ap', '', 0, '1939-11-12', '', '', '', '', '', '', '', 0, 1, '', '', 3, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 1, '', 0, '', '', 0, 0, 'AuSt!'),
(20, 'Morbo', 1271615794, 0, 0, '', 0, 'Morbo', 0, 0, '', '', '', 'ecafe79de815678b999f15a90b4e1cc32a35c09f', 'morbo@powers.app', '', 0, '0001-01-01', '', '', '', '', '', '', '', 1, 1, '', '', 0, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 0, '395bd7cd21', 0, '', '', 0, 0, '5a71'),
(21, 'pepyaka', 1271627335, 0, 0, '', 0, 'pepyaka', 0, 0, '', '', '', '39c17d4c979a0312c04c074e4cde55ad96601d2f', 'pepyaka21@powers.apw', '', 0, '0001-01-01', '', '', '', '', '', '', '', 1, 1, '', '', 0, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 1, '', 0, '', '', 0, 0, 'b7f7'),
(22, 'chupakabra', 1271687788, 0, 0, '', 0, 'chupakabra', 0, 0, '', '', '', '8976fe787e7a12ef44d2237c94abee426125aa3c', 'chupakabra@powers.app', '', 0, '0001-01-01', '', '', '', '', '', '', '', 1, 1, '', '', 0, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 1, '', 0, '', '', 0, 0, 'e2af'),
(40, 'loogin', 1272230959, 0, 0, '', 0, 'loogin', 0, 0, '', '', '', 'e78100a5aee103e9436b113a30789730a83ab907', 'loogin@loogin.lg', '', 0, '0001-01-01', '', '', '', '', '', '', '', 1, 1, '', '', 0, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 1, '', 0, '', '', 0, 0, '0cd8'),
(38, 'Fry', 1272134715, 0, 0, '', 0, 'Fry', 0, 0, '', '', '', 'ccd720c03d4e26501f09c8c9a573fbc86898c74e', 'ffl-public@yandex.ru', '', 0, '0001-01-01', '', '', '', '', '', '', '', 1, 1, '', '', 0, '', 0, 0, 0, '', 1, 1, 0, 2, '', '', '', '', 0, 1, '', 0, '', '', 0, 0, '7016');

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
('d5dee676a0f02fdd4a5fb020b83f06a8', 1271668450, 'rand_code|s:32:"8a0322a4f4845231fd3241b2bc292b31";USER_AGENT|s:79:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceape/2.0.3";'),
('020c416d56fc9facbce6bc3ec05ff8fb', 1271687691, 'rand_code|s:32:"0af7678245fd9e847b7fd40d241de6da";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('bb7b92305f6279d6b9aebae1bedc4392', 1271709968, 'rand_code|s:32:"f718429cbc6ded2b57212cbcbe1eba38";USER_AGENT|s:107:"Mozilla/5.0 (X11; U; Linux i686; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.366.2 Safari/533.4";'),
('be667308e54455a1eb7326dcfa6e807b', 1271710216, 'rand_code|s:32:"b3b3c921c82bc2b949f6518d1d75af2a";USER_AGENT|s:71:"Mozilla/5.0 (compatible; Konqueror/4.3; Linux) KHTML/4.3.4 (like Gecko)";'),
('dd89f87ffc64922daa25a81a7277bea7', 1271710353, 'rand_code|s:32:"32a34f42ab302248da5179ef944a24d2";USER_AGENT|s:63:"Opera/9.80 (X11; Linux i686; U; ru) Presto/2.2.15 Version/10.10";'),
('91aa52eb82d00d045dd7d54e3992b32f', 1271915303, 'rand_code|s:32:"fc5726eb24fa6c0b17b07aa1161af28f";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('b3e5711dad48f3adccc79211e7b4ae19', 1272008008, 'rand_code|s:32:"94a61f2f67d61836fed26c475347f4dc";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('b3a62e974c3aa3129c0189db2325a921', 1272193235, 'rand_code|s:32:"a13a3f3fe8a5f8ab61dd82103945fbd9";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('e56ba0336438867ae0188c1cbede1899', 1272193255, 'rand_code|s:32:"b79a40507fb574c4be3dbe37b606edb4";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('701e9f2745d8a37925c45062685fc815', 1272193268, 'rand_code|s:32:"72d365200c49a40203dfa01153796a59";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('4c48184413e858ec88019925a06eff75', 1272193301, 'rand_code|s:32:"2e1402d20984e26527932987f52483cb";USER_AGENT|s:0:"";'),
('9d132dfb8d5c92ba5be628adc44435dd', 1272228642, 'rand_code|s:32:"47049341ddb38eddd8e27ca2eab61cd1";USER_AGENT|s:79:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceape/2.0.3";'),
('99caab28f03d83a3636f78a908460460', 1272232084, 'rand_code|s:32:"92a2633f9cdb962bfe1ea4ef653a4c70";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('30d939a877e7d56a67a4105fe6e0e34c', 1272274206, 'rand_code|s:32:"08adead4c2759b795ec5e56f8e40a81c";USER_AGENT|s:103:"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100308 Iceweasel/3.5.8 (like Firefox/3.5.8)";'),
('14c7933035646e4087c758147d2520ed', 1272318987, 'rand_code|s:32:"46ba0a70be717e7b4f9809fa6c8f96e8";USER_AGENT|s:0:"";');

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
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='User''s Automated Work Places' AUTO_INCREMENT=7 ;

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
(2, 'en', 1, 0, 1, 'anybody_block', 'Block4Everybody', '<b>Hello everybody</b>\r\n<br /> \r\n<a href="/mjadmin">ADMIN PANEL</a>', 1, 1, '2010-04-18 00:02:26', '2010-04-26 13:48:36');

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

INSERT INTO `mj_blocks_translations` (`block_id`, `lang`, `header`, `body`, `member_id`, `whoedit`, `ins`, `upd`) VALUES
(2, 'ru', 'Блок для всех!', '<b>Превед</b>\r\n<br /> \r\n<a href="/mjadmin">Одминко</a>', 1, 0, '2010-04-26 18:09:42', '2010-04-26 18:09:42');

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
  `cat_id` int(10) unsigned default '0',
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
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Active posts table' AUTO_INCREMENT=17 ;

--
-- Dumping data for table `mj_pages`
--

INSERT INTO `mj_pages` (`page_id`, `is_published`, `cat_id`, `lang`, `slug`, `intro`, `body`, `header`, `descr`, `keywords`, `showintro`, `use_customtitle`, `custom_title`, `allow_comments`, `comments_mode`, `use_password`, `password`, `use_access_roles`, `comments_count`, `author_id`, `member_id`, `whoedit`, `ins`, `upd`, `dt_created`, `dt_publishstart`, `dt_publishend`) VALUES
(1, 1, 0, 'en', 'justpage', '<p>\n	<img alt="My avatar alt" ilo-full-src="http://mojotest:82/userfiles/mjncms/1/avopingvo.jpg" some="else" src="/userfiles/mjncms/1/avopingvo.jpg" style="width: 96px; height: 96px;" title="AvoTitle" /></p>\n<p>\n	This is justpage intro. hi!</p>\n', '<p>\n	This is just page 1 body</p>\n<p>\n	&nbsp;</p>\n<div style="page-break-after: always;">\n	<span style="display: none;">&nbsp;</span></div>\n<p>\n	&nbsp;</p>\n<p>\n	This is just page 2 body</p>\n<p>\n	&nbsp;</p>\n<div style="page-break-after: always;">\n	<span style="display: none;">&nbsp;</span></div>\n<p>\n	&nbsp;</p>\n<p>\n	This is just page 3 body</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-23 23:05:27', '2010-04-12 06:13:00', '2010-04-12 06:13:00', NULL),
(2, 1, 8, 'en', 'd1cp1', '<p>\n	iintro</p>\n', '<p>\n	bbody</p>\n', 'demo1 cat page 1', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 0, '2010-04-12 14:15:14', '2010-04-12 14:15:14', '2010-04-12 03:14:00', '2010-04-12 03:14:00', NULL),
(3, 1, 8, 'en', 'd1cp2', '<p>\n	introoo</p>\n', '<p>\n	bodyyy</p>\n', 'demo1 cat page 2', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:15:44', '2010-04-12 14:18:35', '2010-04-12 04:15:00', '2010-04-12 04:15:00', NULL),
(4, 1, 0, 'en', 'index', '<p>\n	Index page</p>\n', '<p some="thing">\n	bla</p>\n<p>\n	bla</p>\n<p>\n	&nbsp;</p>\n<p>\n	be careful this demo runs on lowerclocked NAS :)</p>\n<p>\n	&nbsp;</p>\n<p>\n	bla</p>\n<p>\n	Index so index....</p>\n<p>\n	&nbsp;</p>\n<p>\n	btw, <a href="/mjadmin">admin side</a></p>\n', 'Main index page', 'MjNCMS project - PERL Mojolicious CMS demo site index page', 'MjNCMS, Mojolicious, Mojo, CMS', 1, 1, 'MjNCMS project demo site index page', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-15 19:45:55', '2010-04-22 13:05:03', '2010-04-15 02:45:00', '2010-04-15 02:45:00', NULL),
(5, 1, 8, 'en', 'page_page1', '<p>\n	i1</p>\n', '<p>\n	b1</p>\n', 'p1', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:27:00', '2010-04-22 20:46:38', '2010-04-22 09:26:00', '2010-04-22 09:26:00', NULL),
(6, 1, 8, 'en', 'page_page2', '<p>\n	i2 v3</p>\n', '<p>\n	b2</p>\n', 'p2', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:27:24', '2010-04-23 23:31:03', '2010-04-22 02:27:00', '2010-04-22 02:27:00', NULL),
(7, 1, 8, 'en', 'page_page3', '<p>\n	i3</p>\n', '<p>\n	b3</p>\n', 'p3', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:27:52', '2010-04-22 20:46:38', '2010-04-22 09:27:00', '2010-04-22 09:27:00', NULL),
(8, 1, 8, 'en', 'page_page4', '<p>\n	i4</p>\n', '<p>\n	b4</p>\n', 'p4', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:28:13', '2010-04-22 20:46:38', '2010-04-22 09:27:00', '2010-04-22 09:27:00', NULL),
(9, 1, 8, 'en', 'page_page5', '<p>\n	i5</p>\n', '<p>\n	b5</p>\n', 'p5', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:28:28', '2010-04-22 20:46:38', '2010-04-22 09:28:00', '2010-04-22 09:28:00', NULL),
(10, 1, 8, 'en', 'page_page6', '<p>\n	i6</p>\n', '<p>\n	b6</p>\n', 'p6', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:28:44', '2010-04-22 20:46:38', '2010-04-22 09:28:00', '2010-04-22 09:28:00', NULL),
(11, 1, 8, 'en', 'page_page7', '<p>\n	i7</p>\n', '<p>\n	b7</p>\n', 'p7', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 0, '2010-04-22 19:29:04', '2010-04-22 20:46:38', '2010-04-22 08:28:00', '2010-04-22 08:28:00', NULL),
(12, 1, 8, 'en', 'page_page8', '<p>\n	i8</p>\n', '<p>\n	b8</p>\n', 'p8', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 0, '2010-04-22 19:30:03', '2010-04-22 20:46:38', '2010-04-22 08:29:00', '2010-04-22 08:29:00', NULL),
(13, 1, 8, 'en', 'page_page9', '<p>\n	i9</p>\n', '<p>\n	b9</p>\n', 'p9', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 0, '2010-04-22 19:30:22', '2010-04-22 20:46:38', '2010-04-22 08:30:00', '2010-04-22 08:30:00', NULL),
(14, 1, 8, 'en', 'page_page10', '<p>\n	i10</p>\n', '<p>\n	b10</p>\n', 'p10', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 0, '2010-04-22 19:30:39', '2010-04-22 20:46:38', '2010-04-22 08:30:00', '2010-04-22 08:30:00', NULL),
(15, 1, 8, 'en', 'page_page11', '<p>\n	i11</p>\n', '<p>\n	b11</p>\n', 'p11', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 0, '2010-04-22 19:31:05', '2010-04-22 20:46:38', '2010-04-22 08:30:00', '2010-04-22 08:30:00', NULL),
(16, 1, 8, 'en', 'page_page12', '<p>\n	i12</p>\n', '<p>\n	b12</p>\n', 'p12', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 0, '2010-04-22 19:31:24', '2010-04-22 20:46:38', '2010-04-22 08:31:00', '2010-04-22 08:31:00', NULL);

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
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Archive posts table' AUTO_INCREMENT=38 ;

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
(19, 4, 1, 0, 'en', 'index', '<p>\n	Index page</p>\n', '<p>\n	bla</p>\n<p>\n	bla</p>\n<p>\n	&nbsp;</p>\n<p>\n	be careful this demo runs on lowerclocked NAS :)</p>\n<p>\n	&nbsp;</p>\n<p>\n	bla</p>\n<p>\n	Index so index....</p>\n<p>\n	&nbsp;</p>\n<p>\n	btw, <a href="/mjadmin">admin side</a></p>\n<p>\n	&nbsp;</p>', 'Main index page', 'MjNCMS project demo site index page', 'MjNCMS, Mojolicious, Mojo', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-15 19:45:55', '2010-04-18 10:36:08', '2010-04-15 10:45:00', '2010-04-15 10:45:00', '0000-00-00 00:00:00'),
(20, 4, 1, 0, 'en', 'index', '<p>\n	Index page</p>\n', '<p>\n	bla</p>\n<p>\n	bla</p>\n<p>\n	&nbsp;</p>\n<p>\n	be careful this demo runs on lowerclocked NAS :)</p>\n<p>\n	&nbsp;</p>\n<p>\n	bla</p>\n<p>\n	Index so index....</p>\n<p>\n	&nbsp;</p>\n<p>\n	btw, <a href="/mjadmin">admin side</a></p>', 'Main index page', 'MjNCMS project - PERL Mojolicious CMS demo site index page', 'MjNCMS, Mojolicious, Mojo, CMS', 1, 1, 'MjNCMS project demo site index page', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-15 19:45:55', '2010-04-19 22:33:50', '2010-04-15 11:45:00', '2010-04-15 11:45:00', '0000-00-00 00:00:00'),
(21, 4, 1, 0, 'en', 'index', '<p>\n	Index page</p>\n', '<p some="thing">\n	bla</p>\n<p>\n	bla</p>\n<p>\n	&nbsp;</p>\n<p>\n	be careful this demo runs on lowerclocked NAS :)</p>\n<p>\n	&nbsp;</p>\n<p>\n	bla</p>\n<p>\n	Index so index....</p>\n<p>\n	&nbsp;</p>\n<p>\n	btw, <a href="/mjadmin">admin side</a></p>\n', 'Main index page', 'MjNCMS project - PERL Mojolicious CMS demo site index page', 'MjNCMS, Mojolicious, Mojo, CMS', 1, 1, 'MjNCMS project demo site index page', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-15 19:45:55', '2010-04-22 10:00:19', '2010-04-15 12:45:00', '2010-04-15 12:45:00', '0000-00-00 00:00:00'),
(22, 1, 1, 0, 'en', 'justpage', '<p>\n	<img alt="" ilo-full-src="http://mojotest:82/userfiles/mjncms/1/avopingvo.jpg" src="/userfiles/mjncms/1/avopingvo.jpg" style="width: 96px; height: 96px;" /></p>\n<p>\n	This is justpage intro. hi! cool!</p>\n<p>\n	&nbsp;</p>\n<p>\n', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-22 10:04:37', '2010-04-12 02:13:00', '2010-04-12 02:13:00', '0000-00-00 00:00:00'),
(23, 1, 1, 0, 'en', 'justpage', '<p>\n	<img alt="My avatar alt" ilo-full-src="http://mojotest:82/userfiles/mjncms/1/avopingvo.jpg" src="/userfiles/mjncms/1/avopingvo.jpg" style="width: 96px; height: 96px;" title="AvoTitle"/></p>\n<p>\n	This is justpage intro. hi! cool!</p>\n<p>\n	&nbsp;</p>', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-22 10:16:04', '2010-04-12 03:13:00', '2010-04-12 03:13:00', '0000-00-00 00:00:00'),
(24, 4, 1, 0, 'en', 'index', '<p>\n	Index page</p>', '<p some="thing">\n	bla</p>\n<p>\n	bla</p>\n<p>\n	&nbsp;</p>\n<div style="page-break-after: always;">\n	<span style="display: none;">&nbsp;</span></div>\n<p>\n	be careful this demo runs on lowerclocked NAS :)</p>\n<p>\n	&nbsp;</p>\n<div style="page-break-after: always;">\n	<span style="display: none;">&nbsp;</span></div>\n<p>\n	bla</p>\n<p>\n	Index so index....</p>\n<p>\n	&nbsp;</p>\n<p>\n	btw, <a href="/mjadmin">admin side</a></p>\n', 'Main index page', 'MjNCMS project - PERL Mojolicious CMS demo site index page', 'MjNCMS, Mojolicious, Mojo, CMS', 1, 1, 'MjNCMS project demo site index page', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-15 19:45:55', '2010-04-22 13:05:03', '2010-04-15 01:45:00', '2010-04-15 01:45:00', '0000-00-00 00:00:00'),
(25, 1, 1, 0, 'en', 'justpage', '<p>\n	<img alt="My avatar alt" ilo-full-src="http://mojotest:82/userfiles/mjncms/1/avopingvo.jpg" src="/userfiles/mjncms/1/avopingvo.jpg" style="width: 96px; height: 96px;" title="AvoTitle" some="else"/></p>\n<p>\n	This is justpage intro. hi! cool!</p>', '<p>\n	This is justpagebody</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-22 13:06:41', '2010-04-12 04:13:00', '2010-04-12 04:13:00', '0000-00-00 00:00:00'),
(26, 5, 1, 8, 'en', 'h1', '<p>\n	i1</p>\n', '<p>\n	b1</p>\n', 'h1', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:27:00', '2010-04-22 19:27:36', '2010-04-22 08:26:00', '2010-04-22 08:26:00', '0000-00-00 00:00:00'),
(27, 10, 1, 0, 'en', 'p6', '<p>\n	i6</p>\n', '<p>\n	b6</p>\n', 'p6', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:28:44', '2010-04-22 19:29:14', '2010-04-22 08:28:00', '2010-04-22 08:28:00', '0000-00-00 00:00:00'),
(28, 9, 1, 0, 'en', 'p5', '<p>\n	i5</p>\n', '<p>\n	b5</p>\n', 'p5', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:28:28', '2010-04-22 19:29:22', '2010-04-22 08:28:00', '2010-04-22 08:28:00', '0000-00-00 00:00:00'),
(29, 8, 1, 0, 'en', 'p4', '<p>\n	i4</p>\n', '<p>\n	b4</p>\n', 'p4', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:28:13', '2010-04-22 19:29:32', '2010-04-22 08:27:00', '2010-04-22 08:27:00', '0000-00-00 00:00:00'),
(30, 7, 1, 0, 'en', 'p3', '<p>\n	i3</p>\n', '<p>\n	b3</p>\n', 'p3', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:27:52', '2010-04-22 19:29:41', '2010-04-22 08:27:00', '2010-04-22 08:27:00', '0000-00-00 00:00:00'),
(31, 1, 1, 0, 'en', 'justpage', '<p>\n	<img alt="My avatar alt" ilo-full-src="http://mojotest:82/userfiles/mjncms/1/avopingvo.jpg" some="else" src="/userfiles/mjncms/1/avopingvo.jpg" style="width: 96px; height: 96px;" title="AvoTitle" /></p>\n<p>\n	This is justpage intro. hi! cool!</p>\n', '<p>\n	This is just page 1 body</p>\n<p>\n	&nbsp;</p>\n<div style="page-break-after: always;">\n	<span style="display: none;">&nbsp;</span></div>\n<p>\n	&nbsp;</p>\n<p>\n	This is just page 2 body</p>\n<p>\n	&nbsp;</p>\n<div style="page-break-after: always;">\n	<span style="display: none;">&nbsp;</span></div>\n<p>\n	&nbsp;</p>\n<p>\n	This is just page 3 body</p>\n', 'just single page', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-12 14:14:38', '2010-04-23 23:05:27', '2010-04-12 05:13:00', '2010-04-12 05:13:00', '0000-00-00 00:00:00'),
(32, 6, 1, 8, 'en', 'page_page2', '<p>\n	i2</p>\n', '<p>\n	b2</p>\n', 'p2', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:27:24', '2010-04-23 23:24:18', '2010-04-22 08:27:00', '2010-04-22 08:27:00', '0000-00-00 00:00:00'),
(33, 6, 1, 8, 'en', 'page_page2', '<p>\n	i2 v2</p>\n', '<p>\n	b2</p>\n', 'p2', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:27:24', '2010-04-23 23:25:27', '2010-04-22 09:27:00', '2010-04-22 09:27:00', '0000-00-00 00:00:00'),
(34, 6, 1, 8, 'en', 'page_page2', '<p>\n	i2 v2</p>\n', '<p>\n	b2</p>\n', 'p2', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:27:24', '2010-04-23 23:26:47', '2010-04-22 10:27:00', '2010-04-22 10:27:00', '0000-00-00 00:00:00'),
(35, 6, 1, 8, 'en', 'page_page2', '<p>\n	i2 v2</p>\n', '<p>\n	b2</p>\n', 'p2', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:27:24', '2010-04-23 23:28:06', '2010-04-22 11:27:00', '2010-04-22 11:27:00', '0000-00-00 00:00:00'),
(36, 6, 1, 8, 'en', 'page_page2', '<p>\n	i2 v2</p>\n', '<p>\n	b2</p>\n', 'p2', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:27:24', '2010-04-23 23:28:49', '2010-04-22 12:27:00', '2010-04-22 12:27:00', '0000-00-00 00:00:00'),
(37, 6, 1, 8, 'en', 'page_page2', '<p>\n	i2 v2</p>\n', '<p>\n	b2</p>\n', 'p2', '', '', 1, 0, '', 1, 'comment', 0, '', 0, 0, 1, 1, 1, '2010-04-22 19:27:24', '2010-04-23 23:31:03', '2010-04-22 01:27:00', '2010-04-22 01:27:00', '0000-00-00 00:00:00');

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
(11, 1, NULL, 1, 1, 1, NULL, '2010-04-18 16:54:54', '2010-04-18 16:54:54'),
(23, 6, NULL, 1, 1, 1, NULL, '2010-04-26 00:36:36', '2010-04-26 00:36:36'),
(2, NULL, 6, 1, 1, 1, NULL, '2010-04-26 00:36:51', '2010-04-26 00:36:51');

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
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Permission types library' AUTO_INCREMENT=26 ;

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
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='User''s roles @ workplaces [text_content/moderator, etc]' AUTO_INCREMENT=7 ;

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
(40, 2, '2010-04-26 01:29:19', 1),
(40, 5, '2010-04-26 01:29:19', 1),
(1, 1, '2010-04-26 01:16:23', 1);

-- --------------------------------------------------------

--
-- Table structure for table `mj_sessions`
--

CREATE TABLE IF NOT EXISTS `mj_sessions` (
  `session_id` char(40) NOT NULL,
  `member_id` mediumint(8) unsigned NOT NULL,
  `data` text,
  `upd` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `start_remote` char(15) default NULL,
  `start_proxy` char(15) default NULL,
  `start_proxyclient` char(15) default NULL,
  `last_remote` char(15) default NULL,
  `last_proxy` char(15) default NULL,
  `last_proxyclient` char(15) default NULL,
  UNIQUE KEY `session_id` (`session_id`),
  KEY `sess_member_idx` (`session_id`,`member_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Internal MjCMS user sessions store';

--
-- Dumping data for table `mj_sessions`
--

INSERT INTO `mj_sessions` (`session_id`, `member_id`, `data`, `upd`, `start_remote`, `start_proxy`, `start_proxyclient`, `last_remote`, `last_proxy`, `last_proxyclient`) VALUES
('5d85592c438e73c7e9ee2a877ad78c9b3f5a8607', 1, '1234\0\0\0', '2010-04-27 02:12:28', NULL, NULL, NULL, NULL, NULL, NULL),
('646fd641bccb5a9fb4ba515f9e6c4aad8f153f90', 1, '1234\0\0\0', '2010-04-27 02:14:17', NULL, NULL, NULL, NULL, NULL, NULL),
('16eb58e8b20190180e82187d5dbcc7b551ccb07d', 0, '1234\0\0\0\0', '2010-04-27 02:14:59', NULL, NULL, NULL, NULL, NULL, NULL),
('657a8dbaca2b14ad58e3c6f69c7b59c925169f55', 0, '1234\0\0\0\0', '2010-04-27 02:14:59', NULL, NULL, NULL, NULL, NULL, NULL),
('a91f33f5ff01d57ed2417d479f11cd35e21b6188', 0, '1234\0\0\0\0', '2010-04-27 02:14:59', NULL, NULL, NULL, NULL, NULL, NULL),
('24ecc04ddd08f6f6b4bd301ebe312973ac5eece1', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('e42e9fe885bc8f6a88a83eb70a41aca99d10c0a3', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('f9b04348f9f37db826d73b4e4aab10c918d70f1b', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('efe786b3bcc0da4020a8d86480d29e829ba64294', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('89e8398512c378fd7b2375c2a2a7c0cd7619b667', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('adcd7a0dd4eebccd4e11e1597125f799decb9487', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('374bc5f453d4d9dc0d31ecde2f50eb586913cbde', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('c61962ebcb58406051b2dcce48333bd15873274a', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('d1af4e755f88634b7f7cd75e8f54e2ee4605322f', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('404c92b4a8575cacae9969d2ac56a8680c98f4fe', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('6ce494d7590414023ce166c15c1d2be29fa00876', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('7e0f2bd384d6d2b07e4d68573a37564afa2f35fd', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('f2ddfc502d605e4dc84bf7204b27dc324f9fd092', 0, '1234\0\0\0\0', '2010-04-27 02:15:00', NULL, NULL, NULL, NULL, NULL, NULL),
('5eeee1f5143daec6a6b11e2cda4e03e08b507059', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('b71de45d95a1fe97a53722f0183341928f305499', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('61b91a5e3510df319dd3fa7fe816001a403fbe19', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('c1b5d6a3b69974e6017021c09659894b121a28c7', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('a921cc5b1067694e42f051b19df852efbd1c0757', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('b91c0fb74700a9e3bb9cd97cf0fcd7bb2de90791', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('ae26e5f5319a5f56a3e757844e9a679b50a2c9bc', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('a7ad9b8b9b28553712755a32e726c66a5763898e', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('0d77cd72d6922c9f44cc979b3e9d2c66ee1a6003', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('cabe7d21bb2d684f83ab97b766331aaba6f1c45f', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('bc5de85a3f227ebc8196976ef9e111e96edcc8cd', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('98208e1396daf8cc0d313ffb5b8ff9b94ca672f4', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('d24fee65ba681b781c0b83769078f4a703e0df98', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('48eb22619f93a1ec2cac2f0808189504181eaa02', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('4981d7f06de7942592f04fc17d1c66ac85a75f35', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('27341d0d1e437ade6d2e205a7bede9d1f2fc8193', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('08ffad0e0581f8bac50806377be24c4e6a3855fe', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('6463bc78b36786ae044412fb708af26eb116df8b', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('e4a7261345928013de13cbe52be6c95fbcc18329', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('e9202611a26e321ac77be1a2ce058b4e3f3bfb0e', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('87de0fa601803d1c39df741b6da6ef9bc1f2ae0d', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('afa87af5458c7ab77b9c71280c8daa4db5df7066', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('386a8137a7c84fa4876baa546d59257e93a415e4', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('8de4b1bda48efeec5513ee2265ea2a57776fdb54', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('a0f05140c901afda4d44b75c673196d5ca71e0e1', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('41e26b18626d41fcc36f1f69be9cc8333413014c', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('9c1eff88d6c37dee04d853c856e8cbab1395b279', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('05282cbb8b440a50a62884cf9742edab940e582a', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('77bd7a7a2c3cb2ae33ed6e5fde22c85691013a61', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('14b07c2bbe48bc965859ef7dbe752a940b040eab', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('09b95a4f16cd56e0df75679c25c1f9a68e3b86f3', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('612ec0fc28aa5f447e8fddf6c4d186ac8ddce0e6', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('c15bcf77409e3eeb60974c6c713692f67f6dae85', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('3b21d2fc682ebfdd8e53a7b6f3b9e1b6c98cf535', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('4a6c11041a0266c189639b3b40c904cffe9f3760', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('9cdac8e06a3940f08bdebbd7bc5a68243bcc785a', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('328350337d92349b428b1fac2b024cd2669e3116', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('17f0ad63196f42d14001dc549de099190b548eb1', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('88d3090123971d68d863e696739913e567baadcc', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('4a83b726bee6cb03c430ac3f5137953cc6b2ceb1', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('bc67d00c1e2a0601dda635840124448964a5e821', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('9b62da9f7d3808fbaea17d58851d9eab83b8e3ae', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('6a4b3948f146cbdba064c6897eafd3d7b9ebaadc', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('40bc0b738542b0b26ec3e8fd7d80eb39dbe60e22', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('970af5fa6e250ab5829b2d8f885785987b8b52a0', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('13b56c5a6e12cf7b96da52c0a512a63d2095b38d', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('6837f8856329f2fea0d8d5bb424ddd55713fbae7', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('070cdf565e1a8993c262292fb265e45325e6827a', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('796a40beb8ad78b350bd587d20a9d174c61ac31c', 0, '1234\0\0\0\0', '2010-04-27 02:15:01', NULL, NULL, NULL, NULL, NULL, NULL),
('54db4a898246d6ea0fd3c1753e9f98e5889a8e37', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('e82ef5606d287184d8186b8150c35489b7fcd15c', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('66fead6311851d424ae30c969df87b81471ba227', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('1c9d391e1e23c21031c8b02ce687f1cf46f54c90', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('662985fa05afbc673af06f193a2e26e6f2da099d', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('183ff40d0bf6ab43564c3c83aae35464e956c71c', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('996761ba5a4c41a740fba989e840aa4f4a9d1d09', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('978f13b251a8ee8e87de84ac64c5f237e755f6f7', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('4e1eb4851ce71824e5ab551f502db802434d4754', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('86670fea7a2f5e1d4e66392083000572fc510a8b', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('1895304c6ebb60605f7a9cab874e6fc43b57550e', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('82111344f2a5644058842fc6af7806a679dcea34', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('b4d7e11e81104f0d9d4379e2d62e5f9bfaf4cc79', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('81e81d328420ca63786e829028bf8474b40f3498', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('55c44412d2e622cf38e02f947745a529d62a4832', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('2116f182c3777116839e817ad303f103280bdf21', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('ccf2d074d81ea1e047d80f86615b7bff3f5ab26d', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('80a907c728d5690b399d1189fa5a28277f2968f0', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('cc762c2cc9d8e499d13e3f57bbec9410ac6e5722', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('b94033f5ae103a99bfb24cf9c4838eeedc33cd7a', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('1cadda4c0820530ce2f85d635d1e3bda0b9ef54f', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('5e9145ddbc31e42fda388a0d6e4a001992f37bcd', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('2d6c1246259e27618c9f051ae6a6733bdfd22448', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('c3f32ab533346ac59cd2e218c497cb6c035b2463', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('c8a1ae939f01d14950ea6ddf550f0ccd24a29cc5', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('fe2d69df0fae9a27e5bcf06877f141f28a44d9fa', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('b15c4bbcc454a2c6cc7eed64168ae7995266ddf4', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('d619d05da266dc461b121009f02e8f30a7df90e1', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('8623aa95211dd8c2367af39ea13978032431d489', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('dfc516c365a9e6f9d94abb4743276cccdfa6bec2', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('10a1d16367e5e53fd9085b43c60ae93240e67e0b', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('029ecc06d5bd90a06bdd9343522868301ad171da', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('5a8cc132e3f9804a7f5b1a6fdcfcaa82f4a3c1d5', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('91f1036ee050f4065908f4a3bf1d50254e8df700', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('ebeef4a6d3e46a068b13e1daf2c4fd307655adab', 0, '1234\0\0\0\0', '2010-04-27 02:15:02', NULL, NULL, NULL, NULL, NULL, NULL),
('e409df8cb025b0c708ae77af38164c6c5899d0b0', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('f08c7b069f5045459438f80368c46a9bd632763b', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('34a5b1e4e5709f0a54ed754cfb6d6eafb1387294', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('a4761645abe23a119be19f4f836cf2870cf4e426', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('8e1a77d6d6a352751ed944ce9b950e1dc9999f93', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('8fdfa44acdbac964026d25cdb1d7782b1f323999', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('60f0381f1edf57b0a826204d7d60314169dcdf98', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('fb7e02620356bfb5dc3e277275e0f1fa27ff088b', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('9560e5dd2348efde0d8fc525268ae777429d69aa', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('5605f24f8123da5acf3e82ce9e1facd27c7f9a0a', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('07ee7487afbb30a5e16c7045c94856087d9ea271', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('667e28651ef6e65e993d7216e3bcd09162da1c0d', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('bc2963997cfb5ab01ea04b59d48ff3956d97aefb', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('05a3590994ea7662b199bdb82bc0f20d1b6ca450', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('66c57dc719c8811257eef61259a9cb7cd39a3e9f', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('90a1f01cb0bc1f05ccdca5949dde71ce75c0e1f3', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('4ef343fcd7628926358e42e16c338bed094fd636', 0, '1234\0\0\0\0', '2010-04-27 02:15:04', NULL, NULL, NULL, NULL, NULL, NULL),
('2e5263964c83555044826a14e295ab3726c9eb9a', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('9aa4fb388592bd6d0f5ff8cfb0d8950a617f4bb9', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('2114b6d5f180e1dd0265b268bffe4feefe67ca8a', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('9a50102e4f57bb8144634d655e80b6ff4030f959', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('37fb4fe79e1d385446cd0b59c42ee0bcb2aab994', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('d0e2989b437d89080a1f2109c0e1e3648d1d6527', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('a83046baf1a5b7ed489234ea09640744a24de185', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('77209f4886a7c77f0ad572730e2e6b41e66e7107', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('2c074ebf79d8a9d6c4c15a69898504bd41acad73', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('9756523658a79ae3dcc44132228c1cad92710392', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('cb9bbe3a77dfaaa4d3352c667161dc64e5d03526', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('79ef1e4257349fbf2d23e1bdb6db499f8c1f141d', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('0949a261ab0092ce31f54b089b68b6c2d920d999', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('b549302e666c47e3be58feb52289f3a6742e60ea', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('ae51a48d564cf7fc0e935329135a3fb1e7527b4a', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('c470d79ea3c6da407b3d6fc71e626fe6ec1c650e', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('787cc5328fd0847531032f02c8e8c3445a714134', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('3c9f513f6c29ea4c334e53507b9fb3b630414abf', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('bcf133241b5d113decea8230fd25c630d78ba5e0', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('33f08300333ffd65e37b27889d3ec7a3fea5b57e', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('9d8ec3d34b6841ba1848d096a5ed2c5920176adb', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('103cd3b894f8a476cd2c0c46d3f4bdaeee427d10', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('c10cfa0e8defb28ffb33f4e8cf8b0f68ceadaf48', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('78635d62058770e7662a351bf69b6fed653cb5ab', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('4c608d85950d79a5f424dd8159a6f6b0b0ad60c3', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('9a127e1294880251aa5edd170cf7bf9aa78a8e68', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('42fe4fc42f7506cb6f17ffaec9651ae94bfee166', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('a075eec5045b7d281090ead1242e85cfd5697054', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('496e079b062caa54fce3960232f85877c8f372df', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('aec81a48cb07086adf60bd4b017db68e996c9a61', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('e84f6fb8837b39a073ef86eac2e4fab621397490', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('b77a2fa5447e6cb1159b6c6ea5000b1225c86714', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('23f685636d561f2cd71c30c9b3b6492b6bd4888a', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('42404066fe16e91d1e102473531913c1aa2eef86', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('b97564203b14ec3e4df36ea792b6ae4cfcb62365', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('ef00ae323903392bbf9061160e2fd97b04ddc05d', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('d894b5311fc9d0fc85aa3a653856c587bfb72e7b', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('dba8cd485bbdae93908f58377f4848d91765c7f9', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('072308737ab08659775f13cc32e44b9297f0de7b', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('390fa6ea4aabe1d024f72e6bbfd6a21d9344d7da', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('351a59bd96ac4b80ce3387a8f2c3c3a12da38380', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('d4d4f869e5ab40ac4ffdd013f3cf2be7be75a987', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('79f38ec7bb49e0c0ba963f267532425836f14162', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('69453768804e7c2047bd96958c8536a865e083e7', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('5a697c5fc2f82bfb65d4888ec89ab73773617b40', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('b2d758d4d2063164b2790f71f920bf28420a96dd', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('3ff325d5eb22120fef66f3dedb65f1be7b983cb3', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('fa683b535aafbdcb5b3e2bdc6223a765d4fc4716', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('c6039290d17f7b16e13b2c7c4d3a329c8683a7f0', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('925bf9675fede2d291ac5bffe9a18d8a8609b288', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('eed217cfc82f8eda5a6fe60bba7dc878e244b628', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('c8062e1a074347066f2f10f202c809bb6566fa67', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('f7ae1271dd3691f3cae6d9ec04c6715bde9c120e', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('00b6e1402c659f7d7a66d592f63577ab4d0eb773', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('c82bbe3d3980af68090ecbccea31640a22898273', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('ab591a3fe888eced247f4409f3d0f1936042a9de', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('18c2bd1d762c7fc48d6aed9f3256334140957969', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('7b2e81597d12a02aa19f5029e5844924cf90363f', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('2724d06ce450fada44b33b76a0fae9f2a1c6b8d0', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('109e20e2b55f86cc39c15dcb30281ac274130482', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('dd2bf4b0608fb08f7f42af44847b6234585ed9b4', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('4232319d21d8f09bf60bf909f1f9f00548b1e017', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('c8ff36a5a27d54893b07a26a991c3f1e499eb308', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('0a4d9c33233a735bc3008731b4dcde0f955ddbb1', 0, '1234\0\0\0\0', '2010-04-27 02:15:05', NULL, NULL, NULL, NULL, NULL, NULL),
('b0fc260ebbae207c924a35fd0253f1f266241a99', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('8aeeab36a234bef0f121784a8a5d7b3aa8970883', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('559dae15886bdd3890295625d1911f41d20ec097', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('89b864decfa887d5ff91d7f34626a5f5a8a9b6fe', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('e4e0df0960c6e40072d6a139dcb460b1e7c12383', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('0d143951fa5f79418b58bd39209edbdc60fe5894', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('13892e318f0d55d65199b6ac001f1ab67c8bfb58', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('03556fa3f9a2efde40fc44c7ab732ef8bc9d28c4', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('20c14da53baa32cd86bc6822a5337909b60e93e4', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('8751043f3e51c5390e40ee418cb2c52ae9c0fd45', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('018b703715db39c3bb8e444f005ef6e0531a0454', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('8a653282e397f2cabd8576cb267f61318bf42ccc', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('a7068ab8d0c3c671b3e3e97d09adb4b09c9955c2', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('16400374c884b677b0f324032b5be4a7370937a2', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('bc6ab93309631d680ad02f0fce1b49a69b0833ad', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('3dacfdfc76a59a97c16daad25ebfaa4d4b5a3f35', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('5493cba6b49825f997e069fa3a665585785dbb86', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('d5b0d94fe1990f50713fcb1ff682a6d622a385a2', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('c404a4cda57a5aef92fe5f1f8614563bfacb3077', 0, '1234\0\0\0\0', '2010-04-27 02:15:06', NULL, NULL, NULL, NULL, NULL, NULL),
('877ade9ec47da914af837f4a7077847222f06ebb', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('3f5edbb100045797bd89ad841821a41be832f723', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('2758b4e283d3536c900ad2b3dae74e59ac186db1', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('9a734ae019361ce9cc138f53a26e52f51e44fb4f', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('2d4da5d17d0f51c454d51efc76741033765af578', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('f8564374e02a2b173fe7b766eb994d675aae34f5', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('7218240d6d0568e182a6d34b0389e438b98c99ab', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('4561245b7e8ac17dde77b6a17cb0f24e7e476fb5', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('3d38fe12d1ddbef0524b7000f34b100e230e9aa1', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('eb2706417be9411d452c3148dc66268148ee54f6', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('75cc9a767c6ebc866302594e2ee7829db0f313fe', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('79002988192e58bf67a7eecf07ee22f90e676e08', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('ba34f40f81d388a246fd893886b3a2625316b40c', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('9a45427b17ea408965d95f3749411d630debf73c', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('d13e21704105f4d23b01570720d5ab77104a25bb', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('157f53c7214d6126ea475eb7a47fb473d7078d3c', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('7093133bd4aca365138a6f79f96cf08c7a608400', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('5698083b8d8c0e1bf9164d180cdc464912f51d52', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('37c439295cb7a22965d653e32648a8da2cbed2f8', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('e823a877d6487c11dd0c9f94756153f3fc0deed8', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('4ed843cddcb9627020ea2c79c9c8b5185d3bf9b8', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('64064d4c4ae26e0eb58ceedae41907485097d394', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('20fb7f2f1f9462f3ba5cf272c115922d45fcb52f', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('4d23c71b5962226d86520249e62914713c12ecb4', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('9f9f1d86011b92edd99b17daa780a8a6ee135c72', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('d035d27172dd1bfebeebeaf23ef5150471f6c79e', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('4eda870a05f1f034286a0f358bd550e583d36bf9', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('5b480b36294dc11df1eae2cd8b9cebdc41a711ff', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('532fefefdaaba0512b396f48733407d1a953c1f6', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('0cb02727704f8810eb18abcd9931c59449c723c7', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('6de8bb2e74485cfa78374753b75debcd9c95c2a2', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('b10e09df2aa4caa808073502fb7d6ed79543c3d9', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('0bc72156146ad82f2c73558f4f5fd8bb04feaa82', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('c4a11f3076f4a8eb89fb0bb6e75ca4494e21a59d', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('7078dce4794d7df52cd4175c08439860b58d5277', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('51ef391bd9adf74479358415bb1320e12a4bc1aa', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('44285c3186a05eca996070c08f2efda048767435', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('974a9b845db733b21e09b7e68e5e7e86d227af88', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('18d4b2aaef39fb450bc89018c822e332d6abd3c8', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('64ee2e7efb29cfc75c5add88dd497a6e6df31425', 0, '1234\0\0\0\0', '2010-04-27 02:15:07', NULL, NULL, NULL, NULL, NULL, NULL),
('872317dbbb5616eb434840b3739e89eec63cc0db', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('7cbdda7bc00a09a02c179804de30fa03e0ca0232', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('39e2e801a15711042ce86a776f545d81170a0aa3', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('737189af9aff6301ddb5cae98a4c7a8de7b4c862', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('93eb7a9b9df8e3facdae332c205fcc97ba5c3f2a', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('64fee60a3de1614b809c44f3ba80205b1dfe238b', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('92bf775912e0a5119954199f6d13dde536bef6fb', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('b35958c1a7f68cbc1a27c33fa1f7800aeb317a19', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('eb20d202b0968dc90e3e4238bfd28c356cc6adef', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('f48af5e7560c5c205f190750fc79ee67ec081575', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('fc7fc0a03558790203b205e38000c191732083ca', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('2904f291a65c6f8175af7e153cefc77b500122a3', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('3f57585bbd721b2e5ae384dba953d9ad9d94405e', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('21719e8da3cca590c43bb697244918c09d5f0464', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('e58f79c5bb28f188011d9c232d4657cefc5168e4', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('9d074e0b9c662404b0ad447ff7281fc92683fcc6', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('0ab203f0da6bad4f317e0db15b7db5e863174f25', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('c14371bca18f3da5fd9e09632afa0f97271d6936', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('8ff7bbd4a6cd0709071997d2b8ebb44a293e8e40', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('0b0c6e6048ae4859c66f3d910c7b77e612df5286', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('61e78cb3054e526642d2331854312f1000b7db67', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('a44347c0b1bb78f6af31a1dbf374c3ec64f88201', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('c44a8682fc96e5eec55ac06f09c94f9a07cc665c', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('ed15521421bafcd147201ba62e36fb52ebe2fe1d', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('11c99cf60bd6cc922ce51f99012d367c63786dc8', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('34021aa11c39c428ebbaa12a44b2ad2e60279f56', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('f92ba68d7fa9c238dcd0850c686150f3a1692408', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('d56f243af708ef35e1438198772b17e981a3ff78', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('b811e305aa757023524a18cade926d233f3d1a87', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('d54fc161baf60d7d85350dc8c95a4b5f995e1767', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('8427eb347d4fa559e5f959d7b2262998d1cfa68c', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('e62c1551f7c44ae005711848cabd31e64d18cdf5', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('6f14b766daf2de1895c4e2d872f5389ab3b63775', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('0887ab2df05b44b4fb58cbb4d8a304094753f3cc', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('66ffab58e7b0a0d860cbb098edf7d9aefac77938', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('d99a15ef1cc17958249fd9c6e00221d2f8d1cafe', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('6579c4c5923973b6bfe74741bd1bfd12dc96b445', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('616accd68529d24331132104d9a58f8f7da8576c', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('3e03a4b120439e72808f82cb8cedb1402d8b2950', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('11534418daede8acc2c6711b4a01dc88b3ad53fa', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('3ecec5d9d2dd89a89fbbdf55ce5aff1efd6c4abe', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('d9643dd70954eef66cee7e24e45e24ba6a631dc5', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('4a32c26c6fbe96ba4299f0ae0d03eb10a4018fc9', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('0236580ef89718261937d2352504ba330d4fa7c8', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('0491c1c77643dcdcdb03e0c6add65e7e522d4bda', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('5c4e605c019b7e576ca23bd3f6a2361c3a81d404', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('b5b0fc555fd04c02f177b7e7729c742f1114b35f', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('49c6ae79bd702a57baa92bdf36e04b7364647780', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('4e533908a37001bc87bc61f64d2b855f0744ac63', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('051e24881c04bd9633b39391e6cb8443e42ea66f', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('e61925debf261070d2d99ae3e13a40b7bf80cae8', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('d753b51f1596d42c8b7dfacf07062a7a1ddd9978', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('9bf0c026eae993eae6e7ccc7cdb1c096306380b9', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('a1b024f9a06c833163648f9debd1c51e97d2e7b0', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('f64765c8ca5f48cca7d688f6c28eb58ba710c636', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('6800055055c50f85542b53a9dc12923665f5d806', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('ba13b8e91c93786483a209ed689016bfa3bb8a90', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('6c4b5f4c895c83a2e0bf5d6ca626eb6a43c3b163', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('dc08c315600a29082a3984a0c33994a3931baa90', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('71067596f5c5db4df845b23e90cf0980274bb795', 0, '1234\0\0\0\0', '2010-04-27 02:15:08', NULL, NULL, NULL, NULL, NULL, NULL),
('38dbb635a2e574a8bdbf8149e77be598b07fb350', 0, '1234\0\0\0\0', '2010-04-27 02:15:09', NULL, NULL, NULL, NULL, NULL, NULL),
('6812bc5951aff2d06de20605e4c0747b42eabb28', 0, '1234\0\0\0\0', '2010-04-27 02:15:09', NULL, NULL, NULL, NULL, NULL, NULL),
('03e2f3eea18841a1ad37d7a06aed5a487f741cb8', 0, '1234\0\0\0\0', '2010-04-27 02:15:09', NULL, NULL, NULL, NULL, NULL, NULL),
('428b48796d0abd2fee81c9f8f58696d3d2d87e5c', 0, '1234\0\0\0\0', '2010-04-27 02:15:09', NULL, NULL, NULL, NULL, NULL, NULL),
('70728285abceb32af0f97287f5f2d0a33d2e62f2', 0, '1234\0\0\0\0', '2010-04-27 02:15:09', NULL, NULL, NULL, NULL, NULL, NULL),
('74458aeafa23a4d61c5c90ab445db5d661ffc10b', 0, '1234\0\0\0\0', '2010-04-27 02:15:09', NULL, NULL, NULL, NULL, NULL, NULL),
('ccf50dfeaf2ca98fc83f73b347fed53a41a0d45c', 0, '1234\0\0\0\0', '2010-04-27 02:15:09', NULL, NULL, NULL, NULL, NULL, NULL),
('7d32748f0d30ff07b95abe4bce6dec3b71b2708c', 0, '1234\0\0\0\0', '2010-04-27 02:15:09', NULL, NULL, NULL, NULL, NULL, NULL),
('d6189e5662095aa81f1b8e4837bfd76e82d3d64e', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('c7e26244c04ffd54635964dc9993485c4564dc96', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('47e19ae2aa2c72265b9795d59c6435cf79ef5996', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('4a7b7b5f36ef1d049755f8706ce88cd4b1605b3c', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('dd76a77a0b58ac041747d8079b754be185d10eb3', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('c240bad6413fae2b540f4db6dd80ceba12ae3ac9', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('5f960a3f1e472dad8e6ae0dd6d19f17ec061a52c', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('7940293e0054d76b0c17f56493b7455a08a33d19', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('ea359e46f82e79a70825a5b3c37ea35da4f12b5c', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('05c5953a42077cb48d99a7f429411a938a7fcb30', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('2492b707331d3aece7f4a30b5bfb45f5d207d22c', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('beca91e93a43655cddb829ba13d9e8fa24183653', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('2e46d727b966556a9cf0c2ba17d5d403e62ab4fd', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('0b37b6df3fc4a3afa84bab9b4d6f7296f29ea081', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('48a2fc8a7d6e71bcda7af45edb44533306a08b02', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('5e47d0b0be5100869a701417d07283478c6a6865', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('7db4fce3672a1fea4904e028ded6d748f494aec8', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('116f36242d565852e86f383f52d162d827b5fd14', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('0b7efb87fd6843d6be4ffb267225c441c56ced2a', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('913d721653d621024c02ac257b52f9b06aeb801c', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('4c3b3ea7443c857e0657aaa84d83c5db732d715a', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('0f0ca10c00b21cc68701f035c28394a5c8637449', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('5c5a8a29864d7892323f8e2af7bc4b0fa005ced2', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('7dbc89d47d6183fcd34cad172c31ea1e35aaa7eb', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('0d657d4791b560aa1119d1cb58e1c16332afaf05', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('8c0b4e58830d194239052410e5c93ed7e63eadf5', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('4ef67e123348b1d5c907b124cc3d0067d0153fc0', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('ba1a4661ceba3a126fe7bea5a439b9c3d9c55437', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('973aa199bc852160f3e4bfcec4fb4bf5310ca418', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('5599ca6ada4ac5f5f1a6c0ba00ba7b83fa144680', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('75d6dbcf91c8be713846b9d90954594f956c62ef', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('78a2a5b7d6a84fb213bdaa88083acc294d18692e', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('3d7d415f1e8a1e934b6da895df14366fb166977e', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('6f931518a44a5c792bfb912c0564378ffbe09db8', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('b8e3c68c8163aec9a60b99798a0d492147ed65f6', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('1f50e410a493cbd8c933b30c3e98724f3c395a98', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('80f0e9d4275c83dc3bfd5876820b02cdfdfc29f7', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('4f9d880a10c1a6a7eb657e3425171c5ca2b1046b', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('bf75a96679830b832338bde1659d6c63fbc4ef53', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('4cffaec4933af3297afa8e179101651b233a4b34', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('3281fbebe646ee76dbf0941e73eeeb9fa9aa4b23', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('74271b4a8eacfca92266f0319af367fe790def2f', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('67e1bcb994fba5870a9cb3dd363d4fa15a9ad2a8', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('1e9dd8a1d8b26d0c47d95e132fe2a30c8a795b93', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('c8969ea7cb7634629b65f738aedf256f889604cb', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('b2e439368561a049034b68881b26169bda578cd5', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('366d5867ebc99e6d87c288b2e6e563c587cf6e0d', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('fb7aef946c511cf2d17f029a4626047675c32918', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('4205ef9e090c4dd7b9ceec29d1bc61817686800f', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('f9f6800f1b94cc0e370932202e0287c8d048b818', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('610a6317d81433e06e83a0b99f85ad00b63b5ba4', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('a6a323304ec9539be8e3d6e3e3701c9664d60f67', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('d54c6a3090ffd41b83cf7fda8fe00cdbeff6120f', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('49e3a0c7aa8db68e3d9985f322e1f60fb5cbe852', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('95b6c860b9f337f52cc3b64c93f979f9fcda3c67', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('caabe9d6d685990dcad5ad83a09802480c0a3b86', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('af51ce91ffc79f54d0861e6ff791e142a5f9f41b', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('32dcc0214fd09f9c3142927df143b860b58780f7', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('47fb68879b32485ae95d2c486b40426bea07eb8a', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('7cf4866858a7fdadc981be1d726e8e65548e210b', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('f70d79b136c2d108382b26e5859b6602681e5d08', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('2016ea0dd052791898721040f6d4a0006be684ba', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('8fe31a22305ea0dcf06196a4dd46c2ac0903a98a', 0, '1234\0\0\0\0', '2010-04-27 02:15:10', NULL, NULL, NULL, NULL, NULL, NULL),
('127c562a1e8cceb0f65a8e0a343bff103bade1f5', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('fe89fc11987260fc2819734b2bb9dcebf50b2028', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('c5a76c20944853dd8960fdb8cd93bbba4e429855', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('5394f62aa4800998de44ab4a875a58184dcc0501', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('7126baabe03791b16a180484dd97e3e405f82122', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('6d6b697468dfd9023b187456f2b704f0765d8d55', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('d7a9265755a1f7d2f90bcdc3de10b82d0bd93425', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('e83bc40a965ed7393fe876ddd0bce13dfd6f8e91', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('1ea1878da521a28b89ac51ece08e111b6baa0e2a', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('6e4ff955e1ae5be2e0907a18c11f4f4ccc56902a', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `mj_sessions` (`session_id`, `member_id`, `data`, `upd`, `start_remote`, `start_proxy`, `start_proxyclient`, `last_remote`, `last_proxy`, `last_proxyclient`) VALUES
('40cc8815e3cd55338a30ce5d99d682485779c495', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('d54951d06038dc6c99f2311e78ad9fd8c1f36f4b', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('9c2ef4aaf1085d7c43cd7c2c0c0f17105ab833bc', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('5899f98c8da55e695c95119c302016f3d2a94e3d', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('8cb5d7b487baed92e883eebdfaf04b7c86b5fb08', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('39f79638f343bb3fd1b178f7c84159ee8490aab0', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('86b1e8d3c9ead6bb570dfb27fa9754824d2ae02b', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('483de9314f1c03f987cad4942e596700876b5825', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('7e1294bd7558a7ddf92616eb7ee0a6ccfdcc66a3', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('185004e2ce0070eb5b3e20b59a7faf238eba3c41', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('860003b190a7af64fd9aa6563319bc5825836250', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('f7cc53cc72267a271030b02005a92c1e6fa887d5', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('5995c0bb22cd2989f3bc1d183ea59e87885d97d2', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('b1f47f4490a85aecf4dc5fce2096d97f83a98a3e', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('bd11a2dabe04c5e58c53acaecb113df4b5283c78', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('138c671dc374831a797f9674b1edcd460530ea02', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('ec274933ebb774a9145547fa3d1cf808aa24a41a', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('2d94c2bb1e041a85c09e79ca0f13accd1f50bea9', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('1a568af77039cb60e9c3ce5ff2ce5ffa6890d9c9', 0, '1234\0\0\0\0', '2010-04-27 02:15:11', NULL, NULL, NULL, NULL, NULL, NULL),
('b4444237ecd647369ad5614ffc4bc3c5f51d8dc9', 0, '1234\0\0\0\0', '2010-04-27 02:15:42', NULL, NULL, NULL, NULL, NULL, NULL),
('c182eb69ea649803c5ed738ad03655ceb4c6ae3a', 0, '1234\0\0\0\0', '2010-04-27 02:15:42', NULL, NULL, NULL, NULL, NULL, NULL),
('4dc3e5f6625a760e8df071e1a9b78bc4b682bd81', 0, '1234\0\0\0\0', '2010-04-27 02:15:42', NULL, NULL, NULL, NULL, NULL, NULL),
('9e69e5f133cd85aa31d785c3fa564733e19ba573', 0, '1234\0\0\0\0', '2010-04-27 02:15:42', NULL, NULL, NULL, NULL, NULL, NULL),
('6b3d949824de7d6808d66e40df6505ffb8b18965', 0, '1234\0\0\0\0', '2010-04-27 02:15:42', NULL, NULL, NULL, NULL, NULL, NULL);

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
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='Short urls links' AUTO_INCREMENT=6 ;

--
-- Dumping data for table `mj_short_urls`
--

INSERT INTO `mj_short_urls` (`alias_id`, `sugrp_id`, `is_custom`, `alias`, `sha1_sum`, `orig_url`, `ins`, `upd`, `member_id`, `whoedit`) VALUES
(2, NULL, 1, 'mojo', '6338066e0e94370f64269743aa880b1aa7aaa956', 'http://search.cpan.org/~kraih/', '2010-03-24 17:29:02', '2010-03-24 17:29:02', 1, 0),
(3, NULL, 0, '1', '252682bb9a8891c2ddd45d62eb597093def84b72', 'http://leprosorium.ru/', '2010-04-16 13:47:27', '2010-04-16 13:47:27', 1, 0),
(4, NULL, 1, 'wowowowo', '37f07ecc66f7c5334e1b95ff0e7a0afefadc23b6', 'http://groups.google.com/group/mojolicious/', '2010-04-16 14:11:54', '2010-04-16 14:11:54', 1, 0),
(5, NULL, 0, '2', 'c37e3c09c2989d523e188e20156b870cce3281ac', 'http://ya.ru/', '2010-04-26 18:40:11', '2010-04-26 18:40:11', 1, 0);

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
  `salt` char(16) default NULL,
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

INSERT INTO `mj_users` (`member_id`, `replace_member_id`, `is_cms_active`, `role_id`, `name`, `site_lng`, `salt`, `ins`, `upd`, `whoedit`, `startpage`) VALUES
(0, NULL, 1, 0, 'Guest', NULL, '', '2010-02-09 00:00:00', '2010-03-22 21:07:38', NULL, '/'),
(1, 1, 1, 1, 'Austin Powerss', 'en', '', '2010-02-09 00:00:00', '2010-04-24 22:08:18', 1, '/mjadmin/pages'),
(20, NULL, 1, 5, 'Morbo', 'en', '', '0000-00-00 00:00:00', '2010-04-18 22:36:34', 1, '/'),
(21, NULL, 1, 2, 'pepyaka222', 'en', '', '0000-00-00 00:00:00', '2010-04-19 15:59:47', 0, '/'),
(22, NULL, 1, 2, 'chupakabra', 'ru', '', '0000-00-00 00:00:00', '2010-04-19 18:37:20', 0, '/'),
(38, NULL, 1, 2, 'Fry', 'en', '984b86443bb52b9d', '0000-00-00 00:00:00', '2010-04-24 23:42:17', 0, '/'),
(40, NULL, 1, 2, 'loogin', NULL, '552e9573fa9989d6', '0000-00-00 00:00:00', '2010-04-26 02:16:12', 1, '/loogin');

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
(1, 1, '2010-04-18 22:36:45', 1),
(40, 21, '2010-04-26 01:29:19', 1),
(40, 38, '2010-04-26 01:29:19', 1),
(40, 22, '2010-04-26 01:29:19', 1);
