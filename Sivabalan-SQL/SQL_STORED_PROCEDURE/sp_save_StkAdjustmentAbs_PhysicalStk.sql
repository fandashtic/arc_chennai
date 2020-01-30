CREATE PROCEDURE sp_save_StkAdjustmentAbs_PhysicalStk(
       @RECONCILE_ID Integer,
       @STKDATE DATETIME,  
       @STKVALUE Decimal(18,6),  
       @STKADJTYPE INT,  
       @USERNAME nvarchar(255))  
  
AS  
DECLARE @DocumentID int  
  
BEGIN TRAN  
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 8  
SELECT @DocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 8  
COMMIT TRAN  
  
INSERT INTO StockAdjustmentAbstract(AdjustmentDate, AdjustmentValue, DocumentID,   
AdjustmentType, UserName)  
VALUES(@STKDATE, @STKVALUE, @DocumentID, @STKADJTYPE, @USERNAME)  

Update ReconcileAbstract Set StockAdjID = Isnull(StockAdjID, N'') + Case isnull(StockAdjID, N'') When N'' Then N'' Else  N', ' End  + Cast(@@IDENTITY as nvarchar) Where ReconcileID = @RECONCILE_ID
  
SELECT @@IDENTITY, @DocumentID  

