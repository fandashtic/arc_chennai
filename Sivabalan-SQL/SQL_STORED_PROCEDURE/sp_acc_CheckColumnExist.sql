Create Procedure sp_acc_CheckColumnExist(@TableName nVarchar(255),@ColumnName nVarchar(255))
As
select count(name) from syscolumns where 
id = (select id from sysobjects where name = @TableName and xtype = 'U') and 
name = @ColumnName


