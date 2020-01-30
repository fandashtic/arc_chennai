CREATE PROCEDURE sp_get_newAdjustmentReturnGSTID (@OperatingYear nvarchar(10))
AS
	SELECT DocumentID FROM GSTDocumentNumbers WHERE DocType = 103 and OperatingYear = @OperatingYear
