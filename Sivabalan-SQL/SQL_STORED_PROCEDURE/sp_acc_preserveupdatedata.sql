CREATE PROCEDURE sp_acc_preserveupdatedata
AS
If (Select Count(*) From AdjustmentReason) = 0
Begin
SET IDENTITY_INSERT AdjustmentReason ON
Insert into AdjustmentReason(AdjReasonID, Reason, Description, Claimed, Active, CreationDate, AccountID) Select * From TemplateDB.dbo.AdjustmentReason
SET IDENTITY_INSERT AdjustmentReason OFF
End
