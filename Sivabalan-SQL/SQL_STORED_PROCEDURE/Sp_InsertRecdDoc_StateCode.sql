Create Procedure Sp_InsertRecdDoc_StateCode(@CompanyID Nvarchar(255),@DocumentID Int,@ReceivedDate dateTime)
As
Begin
	Set @ReceivedDate = Cast(@ReceivedDate as Datetime)
	Insert Into RecdDoc_StateCode (CompanyID,DocumentID,ReceivedDate,Status) 
	Values(@CompanyID,@DocumentID,@ReceivedDate,0)
	select @@Identity As Status
End
