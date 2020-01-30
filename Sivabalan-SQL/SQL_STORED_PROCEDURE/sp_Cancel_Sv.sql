CREATE procedure sp_Cancel_Sv
(
@SVNumber Int,
@Remarks nVarchar(510),
@CancelUserName nVarchar(50)
)
As
UPDATE SVAbstract SET Status = Status | 192, Remarks = @Remarks ,
CancelUserName = @CancelUserName ,CancelDate = getdate()
WHERE SVNumber = @SVNumber

UPDATE SOAbstract SET Status = Status | 192, Remarks = @Remarks ,
CancelUserName = @CancelUserName ,CancelDate = getdate()
WHERE SalesVisitNumber = @SVNumber


