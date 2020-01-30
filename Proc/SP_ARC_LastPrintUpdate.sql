IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'LastPrintOn' AND OBJECT_ID = OBJECT_ID(N'InvoiceAbstract'))
BEGIN
	Alter Table InvoiceAbstract ADD [LastPrintOn] DateTime Default Null
END
GO
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'PrintCount' AND OBJECT_ID = OBJECT_ID(N'InvoiceAbstract'))
BEGIN
	Alter Table InvoiceAbstract ADD [PrintCount] Int Default Null
END
GO
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_LastPrintUpdate')
BEGIN
    DROP PROC SP_ARC_LastPrintUpdate
END
GO
Create Proc SP_ARC_LastPrintUpdate (@InvoiceId INT)  
AS  
BEGIN 
	Update I
	SET
		I.[LastPrintOn] = Getdate(),
		I.[PrintCount] = ISNULL([PrintCount], 0) + 1
	FROM InvoiceAbstract I WITH (NOLOCK)
	WHERE I.InvoiceID = @InvoiceId
END
GO
