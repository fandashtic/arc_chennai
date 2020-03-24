IF NOT EXISTS (select Top 1 1  from tbl_mERP_TransactionIni Where IniName = 'SalesInvoicePrint.ini' ANd TransactionName = 'GSTInvoice' AND PrintMode = 2)
BEGIN
	Insert into tbl_mERP_TransactionIni (TransactionName,IniName,PrintMode,Active,CreationDate,ModifiedDate,GSTFlag)
	Select 'GSTInvoice', 'SalesInvoicePrint.ini', 2,1, Getdate(), Getdate(), 1
END
GO
IF NOT EXISTS (select Top 1 1  from tbl_mERP_RestrictedIniFiles Where IniFileName = 'SalesInvoicePrint.ini' ANd PrintMode = 2)
BEGIN
	Insert into tbl_mERP_RestrictedIniFiles (IniFileName,PrintMode,CreationDate,ModifiedDate,Active)
	Select 'SalesInvoicePrint.ini', 2, Getdate(), Getdate(), 0
END
GO

--select * from tbl_mERP_TransactionIni
--select * from tbl_mERP_RestrictedIniFiles