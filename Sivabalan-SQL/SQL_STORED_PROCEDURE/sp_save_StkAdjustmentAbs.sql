
CREATE PROCEDURE sp_save_StkAdjustmentAbs
(
	@STKDATE DATETIME,
	@STKVALUE Decimal(18,6),
	@STKADJTYPE INT,
	@USERNAME NVARCHAR(255),
	@REMARKS NVARCHAR(255) = Null
)
AS
BEGIN
DECLARE @DocumentID int

BEGIN TRAN
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 8
SELECT @DocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 8
COMMIT TRAN

INSERT INTO StockAdjustmentAbstract(AdjustmentDate, AdjustmentValue, DocumentID, 
AdjustmentType, UserName, Remarks)
VALUES(@STKDATE, @STKVALUE, @DocumentID, @STKADJTYPE, @USERNAME, @REMARKS)

SELECT @@IDENTITY, @DocumentID
END
