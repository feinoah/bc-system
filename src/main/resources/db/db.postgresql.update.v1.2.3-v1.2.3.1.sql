-- ###########################################################################
-- 宝城综合应用系统的升级脚本
-- 数据库类型: postgresql
-- 升级版本: 从 1.2.2 升级到 1.2.x
-- ###########################################################################
 
 --经济合同添加残值归属
ALTER TABLE BS_CONTRACT_CHARGER ADD COLUMN SCRAPTO VARCHAR(4000);
COMMENT ON COLUMN BS_CONTRACT_CHARGER.SCRAPTO IS '残值归属';


--插入经济合同添的残值归属option-item
insert into BC_OPTION_GROUP (ID,ORDER_, KEY_, VALUE_, ICON) values (NEXTVAL('CORE_SEQUENCE'), '5040', 'contract4Charger.scrapTo', '残值归属', null);
--
insert into BC_OPTION_ITEM (ID,STATUS_, PID, ORDER_, KEY_, VALUE_, ICON) 
	select NEXTVAL('CORE_SEQUENCE'), 0, g.id, '01', 'gongsi', '公司', null from BC_OPTION_GROUP g where g.KEY_='contract4Charger.scrapTo'; 
insert into BC_OPTION_ITEM (ID,STATUS_, PID, ORDER_, KEY_, VALUE_, ICON) 
	select NEXTVAL('CORE_SEQUENCE'), 0, g.id, '02', 'zerenren', '责任人', null from BC_OPTION_GROUP g where g.KEY_='contract4Charger.scrapTo'; 	






