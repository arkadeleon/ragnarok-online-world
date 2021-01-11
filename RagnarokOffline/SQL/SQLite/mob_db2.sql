PRAGMA synchronous = OFF;
PRAGMA journal_mode = MEMORY;
BEGIN TRANSACTION;
CREATE TABLE `mob_db2` (
  `ID` integer  NOT NULL default '0'
,  `Sprite` varchar(24) NOT NULL
,  `kName` text NOT NULL
,  `iName` text NOT NULL
,  `LV` integer  NOT NULL default '0'
,  `HP` integer  NOT NULL default '0'
,  `SP` integer  NOT NULL default '0'
,  `EXP` integer  NOT NULL default '0'
,  `JEXP` integer  NOT NULL default '0'
,  `Range1` integer  NOT NULL default '0'
,  `ATK1` integer  NOT NULL default '0'
,  `ATK2` integer  NOT NULL default '0'
,  `DEF` integer  NOT NULL default '0'
,  `MDEF` integer  NOT NULL default '0'
,  `STR` integer  NOT NULL default '0'
,  `AGI` integer  NOT NULL default '0'
,  `VIT` integer  NOT NULL default '0'
,  `INT` integer  NOT NULL default '0'
,  `DEX` integer  NOT NULL default '0'
,  `LUK` integer  NOT NULL default '0'
,  `Range2` integer  NOT NULL default '0'
,  `Range3` integer  NOT NULL default '0'
,  `Scale` integer  NOT NULL default '0'
,  `Race` integer  NOT NULL default '0'
,  `Element` integer  NOT NULL default '0'
,  `Mode` integer  NOT NULL default '0'
,  `Speed` integer  NOT NULL default '0'
,  `aDelay` integer  NOT NULL default '0'
,  `aMotion` integer  NOT NULL default '0'
,  `dMotion` integer  NOT NULL default '0'
,  `MEXP` integer  NOT NULL default '0'
,  `MVP1id` integer  NOT NULL default '0'
,  `MVP1per` integer  NOT NULL default '0'
,  `MVP2id` integer  NOT NULL default '0'
,  `MVP2per` integer  NOT NULL default '0'
,  `MVP3id` integer  NOT NULL default '0'
,  `MVP3per` integer  NOT NULL default '0'
,  `Drop1id` integer  NOT NULL default '0'
,  `Drop1per` integer  NOT NULL default '0'
,  `Drop2id` integer  NOT NULL default '0'
,  `Drop2per` integer  NOT NULL default '0'
,  `Drop3id` integer  NOT NULL default '0'
,  `Drop3per` integer  NOT NULL default '0'
,  `Drop4id` integer  NOT NULL default '0'
,  `Drop4per` integer  NOT NULL default '0'
,  `Drop5id` integer  NOT NULL default '0'
,  `Drop5per` integer  NOT NULL default '0'
,  `Drop6id` integer  NOT NULL default '0'
,  `Drop6per` integer  NOT NULL default '0'
,  `Drop7id` integer  NOT NULL default '0'
,  `Drop7per` integer  NOT NULL default '0'
,  `Drop8id` integer  NOT NULL default '0'
,  `Drop8per` integer  NOT NULL default '0'
,  `Drop9id` integer  NOT NULL default '0'
,  `Drop9per` integer  NOT NULL default '0'
,  `DropCardid` integer  NOT NULL default '0'
,  `DropCardper` integer  NOT NULL default '0'
,  PRIMARY KEY  (`ID`)
,  UNIQUE KEY (`Sprite`)
);
END TRANSACTION;
