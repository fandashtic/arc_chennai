Create Procedure Sp_InsertRecd_OCGDoc(@CompanyID Nvarchar(255),@DocumentID Int,@ReceivedDate dateTime)
As
Begin
	Set @ReceivedDate = Cast(@ReceivedDate as Datetime)
	Insert Into Recd_OCG (CompanyID,DocumentID,ReceivedDate,Status) 
	Values(@CompanyID,@DocumentID,@ReceivedDate,0)
	select @@Identity As Status
End
