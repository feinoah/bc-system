-- ###########################################################################
-- 宝城综合应用系统的升级脚本
-- 数据库类型: postgresql
-- 升级版本: 从 1.4升级到 1.4.1
-- ###########################################################################

--发票销售单增加流水号
ALTER TABLE bs_invoice_sell ADD COLUMN code_no VARCHAR(255);
comment on column bs_invoice_sell.code_no is '发票单流水号，以年计算';
