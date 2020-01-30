Create  Procedure spUpdateDuplicateDocID
As
Begin
 Declare @ID int
 Declare @Start int
 Declare @Prefix nVarchar(50)

 Select @Prefix = [Prefix] From VoucherPrefix Where [TranID]=N'DEPOSITS'     
 Select @Start= VoucherStart from DocumentNumbers where DocType=25
 --Select @Prefix = 'DW'
 Declare KeyCursor Cursor 
 For Select DepositID From Deposits Order By DepositID
 Open KeyCursor
 Fetch KeyCursor Into @ID
 While @@Fetch_Status = 0
 Begin
	Update Deposits Set FullDocID = @Prefix + Cast(@Start as Varchar) Where DepositID=@ID
	Set @Start = @Start + 1
 Fetch KeyCursor Into @ID
 End
 Close KeyCursor
 Deallocate KeyCursor

Update DocumentNumbers Set DocumentID=@Start Where DocType=25
End

