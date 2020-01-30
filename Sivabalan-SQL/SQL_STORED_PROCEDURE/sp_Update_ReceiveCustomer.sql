CREATE Procedure sp_Update_ReceiveCustomer(@CustomerID nVarchar(25), @DOB DateTime = NULL,        
@Refid int = 0, @MembershipCode nvarchar(100) = NULL, @Fax nvarchar(100) = NULL,        
@RetailCategoryID int = 0, @SalutationID int = 0, @First_Name nvarchar(200) = NULL,        
@Second_Name  nvarchar(200) = NULL, @PinCode nVarchar(50) = NULL, @OccupationID int = 0,        
@Awareness nvarchar(4000) = NULL, @UpdateStatus nVarchar(58) = NULL )        
As  
Declare @Invalidvalue int

If @updateStatus = N''
	Set @updateStatus = '1111111111111111111111111111111111111111111111111111111111'
      

--  Update Customer Set DOB=@DOB, ReferredBy=@Refid, MembershipCode=@MembershipCode,         
--  Fax=@Fax, RetailCategory=@RetailCategoryID, SalutationID=@SalutationID,        
--  First_Name=@First_Name, Second_Name=@Second_Name, PinCode=@PinCode,        
--  Occupation=@OccupationID,         
----  [Already Commented]Awareness=dbo.sp_CombineDataNameFromID(@Awareness,',')        
--  Awareness=(Select Awareness from #Tmp)    
--  Where Customerid=@CustomerID           
--  Drop Table #Tmp    


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Awareness'),1)) = 1
Begin
  Create Table #Tmp (Awareness nVarchar(4000))    
  Exec sp_CombineDataNameFromID @Awareness,',' --, @UpdateStatus
  update customer Set Awareness = (Select Awareness from #Tmp) where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Awareness'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Awareness'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Awareness Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'DOB'),1)) = 1
Begin
  update customer Set DOB = @DOB where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'DOB'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'DOB'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'DOB Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ReferredBy'),1)) = 1
Begin
  update customer Set ReferredBy = @Refid  where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ReferredBy'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ReferredBy'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'ReferredBy Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 



If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'MembershipCode'),1)) = 1
Begin
  update customer Set MembershipCode = @MembershipCode where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'MembershipCode'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'MembershipCode'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'MembershipCode Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Fax'),1)) = 1
Begin
  update customer Set fax = @FAX where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Fax'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Fax'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Fax Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'RetailCategory'),1)) = 1
Begin
  update customer Set RetailCategory = @RetailCategoryID where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'RetailCategory'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'RetailCategory'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'RetailCategory Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Salutation'),1)) = 1
Begin
  update customer Set SalutationID = @SalutationID where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Salutation'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Salutation'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Salutation Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'FirstName'),1)) = 1
Begin
  update customer Set First_Name = @First_Name where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'FirstName'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'FirstName'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'FirstName Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SecondName'),1)) = 1
Begin
  update customer Set Second_name = @Second_name where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SecondName'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SecondName'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'SecondName Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'PinCode'),1)) = 1
Begin
  update customer Set Pincode = @PinCode where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'PinCode'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'PinCode'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'SecondName Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Occupation'),1)) = 1
Begin
  update customer Set Occupation = @OccupationID  where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Occupation'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Occupation'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Occupation Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


