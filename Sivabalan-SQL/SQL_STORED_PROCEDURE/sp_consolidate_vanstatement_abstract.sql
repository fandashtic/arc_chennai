
CREATE procedure sp_consolidate_vanstatement_abstract (	@ClientID int,
							@DocSerial int,
							@DocumentID int,
							@DocumentDate datetime,
							@Salesman nvarchar(255),							
							@Beat_Description nvarchar(255),
							@DocumentValue Decimal(18,6),
							@Van nvarchar(50),
							@Status int)
as
Declare @SalesmanID int
Declare @BeatID int
Declare @VanID int
Declare @OldID int

Select @SalesmanID = SalesmanID From Salesman Where Salesman_Name = @Salesman
Select @BeatID = BeatID From Beat Where Description = @Beat_Description
Select @VanID = Van From Van Where Van_Number = @Van
Update VanStatementAbstract Set DocumentDate = @DocumentDate,
SalesmanID = @SalesmanID, BeatID = @BeatID, DocumentValue = @DocumentValue,
VanID = @VanID, Status = @Status 
Where OriginalClientID = @ClientID And ClientDocSerial = @DocSerial
If @@RowCount = 0
Begin
	Insert into VanStatementAbstract (DocumentID, DocumentDate, SalesmanID,
	BeatID, DocumentValue, VanID, Status, OriginalClientID, ClientDocSerial)
	Values (@DocumentID, @DocumentDate, @SalesmanID, @BeatID, @DocumentValue,
	@vanID, @Status, @ClientID, @DocSerial)
	Select @@Identity
End
Else
Begin
	Select @OldID = DocSerial From VanStatementAbstract 
	Where OriginalClientID = @ClientID And ClientDocSerial = @DocSerial
	Delete VanStatementDetail Where DocSerial = @OldID
	Select @OldID
End

