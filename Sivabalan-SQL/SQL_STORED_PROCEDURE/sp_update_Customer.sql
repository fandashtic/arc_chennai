
CREATE PROCEDURE [sp_update_Customer]            
 (@CustomerID  [nvarchar](15),            
  @Company_Name nvarchar(128),            
  @ContactPerson [nvarchar](255),            
  @CustomerCategory int,            
  @BillingAddress [nvarchar](255),            
  @ShippingAddress [nvarchar](255),            
  @AreaID  [int],            
  @CityID  [int],            
  @StateID  [int],            
  @CountryID  [int],            
  @Phone  [nvarchar](50),            
  @Email  [nvarchar](50),            
  @Active  [int],            
  @BeatID        [int],            
  @Discount      Decimal(18,6),            
  @DLNumber [nvarchar](50),            
  @TNGSTNumber [nvarchar] (50),            
  @CreditTerm int,            
  @DLNumber21 [nvarchar] (50),            
  @CSTNumber nvarchar(50),            
  @CreditLimit Decimal(18,6),            
  @AlternateCode nvarchar(20),            
  @CreditRating nvarchar(50),            
  @ChannelType int,            
  @Locality int,            
  @Payment_Mode int,  
  @AutoSC int =0,  
  @Password nvarchar(20)=N'',  
  @District int = 0,  
  @Town int = 0,  
  @AccountType int = 0,  
  @SequenceNo decimal(18,6)=0,  
  @TINNUMBER nvarchar(20) = N'',  
  @AlternateName nvarchar(250) = N'',  
  @TrackPoints decimal(18,6)=0,		
  @CollectedPoints decimal(18,6)=0,    
  @SubChannelID int=0,  
  @Potential nvarchar(100)=N'',  
  @MobileNumber nvarchar(50)=N'',  
  @Residence nvarchar(50)=N'',
  @PinCode nvarchar(50)=N'',
  @TradeCategoryID Int=Null,
  @NoOfBillsOutstanding Int = 0,
  @SegmentID int=null,
  @KeyAccountID int = 0,
  @RCSID nVarchar(200)=N'',
  @updateStatus nVarchar(58)=N'',
  @TranType Int = 0
)       
AS                 
Declare @Invalidvalue int

if(@AutoSc=1)           
begin    
 update auditmaster set customerID=@AlternateCode where customerID=(select alternatecode from customer where customerID=@CustomerID)          
 update itemclosingstock set customerID=@AlternateCode where customerID=(select alternatecode from customer where customerID=@CustomerID)          
 update sentinvoices set customerID=@AlternateCode where customerID=(select alternatecode from customer where customerID=@CustomerID)           
end    
if(@TranType = 1)	
Begin 
 -- If update status is not given then all fields should be allowed to update.
 If @updateStatus = N''
	Set @updateStatus = '1111111111111111111111111111111111111111111111111111111111'
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ID'),1)) = 1
Begin
  update customer Set CustomerID = @CustomerID where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ID'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ID'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'ID Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Name'),1)) = 1
--Begin
--  update customer Set [Company_Name] = @Company_Name where CustomerID = @customerID
--End
--Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Name'),1)) > 1  
--Begin
--	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Name'),1)
--	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--	values('TradeCustomer', 'Name Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
--End 

If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Cntperson'),1)) = 1
Begin
  update customer Set ContactPerson = @ContactPerson where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Cntperson'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Cntperson'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Cntperson Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Catdesc'),1)) = 1
Begin
  --CustomerCateogry will be always be 2 (Retailer will be the default CustomerCategory)
  update customer Set CustomerCategory  = 2 where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Catdesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Catdesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Catdesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 



If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'BillAdd'),1)) = 1
Begin
  update customer Set BillingAddress  = @BillingAddress where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'BillAdd'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'BillAdd'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'BillAdd Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 



If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ShipAdd'),1)) = 1
Begin
  update customer Set ShippingAddress = @ShippingAddress where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ShipAdd'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ShipAdd'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'ShipAdd Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CityDesc'),1)) = 1
Begin
  If @CityID <> 0
  begin 
  update customer Set CityID = @CityID where CustomerID = @customerID
  end
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CityDesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CityDesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'CityDesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'StateDesc'),1)) = 1
Begin
  update customer Set StateID = @StateID where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'StateDesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'StateDesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'StateDesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CountryDesc'),1)) = 1
Begin
  update customer Set CountryID = @CountryID where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CountryDesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CountryDesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'CountryDesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'AreaDesc'),1)) = 1
Begin
  if @AreaID <> 0 
  begin 
  update customer Set AreaID = @AreaID where CustomerID = @customerID
  end
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'AreaDesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'AreaDesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'AreaDesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Phone'),1)) = 1
Begin
  update customer Set Phone = @Phone where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Phone'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Phone'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Phone Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Email'),1)) = 1
Begin
  update customer Set Email = @Email where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Email'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Email'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Email Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Discount'),1)) = 1
Begin
  update customer Set Discount = @Discount where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Discount'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Discount'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Discount Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'TNGST'),1)) = 1
Begin
  update customer Set TNGST = @TNGSTNumber where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'TNGST'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'TNGST'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'TNGST Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


--
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CreditValue'),1)) = 1
--  update customer Set CreditTerm = @CreditTerm where CustomerID = @customerID
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CreditID'),1)) = 1
--  update customer Set CreditID = @Company_Name where CustomerID = @customerID
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Credittype'),1)) = 1
--  update customer Set Credittype = @Company_Name where CustomerID = @customerID


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'DlNum'),1)) = 1
Begin
  update customer Set DLNumber = @DLNumber where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'DlNum'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'DlNum'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'DlNum Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'dlnum21'),1)) = 1
Begin
  update customer Set DLNumber21 = @DLNumber21 where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'dlnum21'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'dlnum21'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'dlnum21 Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CST'),1)) = 1
begin
  update customer Set CST = @CSTNumber where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CST'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CST'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'CST Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Creditlimit'),1)) = 1
begin
  update customer Set CreditLimit = @CreditLimit where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Creditlimit'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Creditlimit'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Creditlimit Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Forumcode'),1)) = 1
begin
  --AlternateCode will be updated only when the length is less than or equal to 6
  If len(@AlternateCode) <= 6
  update customer Set AlternateCode = @AlternateCode where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Forumcode'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Forumcode'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Forumcode Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Creditrating'),1)) = 1
Begin
  update customer Set CreditRating = @CreditRating where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Creditrating'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Creditrating'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Creditrating Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ChannelDesc'),1)) = 1
Begin  
  IF @ChannelType <> 0 
  Begin 
  update customer Set ChannelType = @ChannelType where CustomerID = @customerID
  End
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ChannelDesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ChannelDesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Creditrating Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Locality'),1)) = 1
Begin
  update customer Set Locality = @Locality where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Locality'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Locality'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Locality Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'PayModeID'),1)) = 1
begin
  update customer Set Payment_Mode = @Payment_Mode where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'PayModeID'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'PayModeID'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'PayModeID Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Password'),1)) = 1
begin
  update customer Set Customer_Password = @Password where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Password'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Password'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Password Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

--
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Active'),1)) = 1
--begin
--  update customer Set Active = @Active where CustomerID = @customerID
--end
--Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Active'),1)) > 1  
--Begin
--	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Active'),1)
--	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--	values('TradeCustomer', 'Active Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
--End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'District'),1)) = 1
Begin
  If @District <> 0 
  begin 
  update customer Set District = @District where CustomerID = @customerID
  end
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'District'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'District'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'District Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'TownClassify'),1)) = 1
begin
  update customer Set TownClassify = @Town where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'TownClassify'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'TownClassify'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'TownClassify Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'TIN_NUMBER'),1)) = 1
begin
  update customer Set TIN_Number = @TINNUMBER where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'TIN_NUMBER'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'TIN_NUMBER'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'TownClassify Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Alternate_Name'),1)) = 1
begin
	 		
		update customer Set Alternate_Name = @AlternateName where CustomerID = @customerID
	
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Alternate_Name'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Alternate_Name'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Alternate_Name Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SubChannel'),1)) = 1
begin
  update customer Set SubChannelID = @SubChannelID where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SubChannel'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SubChannel'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'SubChannel Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Potential'),1)) = 1
Begin
  update customer Set Potential = @Potential where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Potential'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Potential'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'SubChannel Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'MobileNumber'),1)) = 1
begin
  update customer Set MobileNumber = @MobileNumber where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'MobileNumber'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'MobileNumber'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'MobileNumber Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SequenceNumber'),1)) = 1
begin
  update customer Set SequenceNo = @SequenceNo where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SequenceNumber'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SequenceNumber'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'SequenceNumber Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 



If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'TrackPoints'),1)) = 1
begin
  update customer Set TrackPoints = @TrackPoints where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'TrackPoints'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'TrackPoints'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'TrackPoints Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CollectedPoints'),1)) = 1
begin
  update customer Set CollectedPoints = @CollectedPoints where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CollectedPoints'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CollectedPoints'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'CollectedPoints Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Residence'),1)) = 1
begin
  update customer Set Residence = @Residence where CustomerID = @customerID
end
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Residence'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Residence'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Residence Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SegmentCode'),1)) = 1
begin
  update customer Set SegmentID = @SegmentID where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SegmentCode'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SegmentCode'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'SegmentCode Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'DefaultBeat'),1)) = 1
begin
  if @BeatID <> 0 
  begin 
  update customer Set DefaultBeatID = @BeatID where CustomerID = @customerID
  end  
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'DefaultBeat'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'DefaultBeat'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'DefaultBeat Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 


If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'RCSID'),1)) = 1
begin
  update customer Set RCSOutletID = @RCSID where CustomerID = @customerID
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'RCSID'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'RCSID'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'RCSID Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

 --If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CitySTDCode'),1)) = 1
 --  update customer Set [Company_Name] = @Company_Name where CustomerID = @customerID
 end
Else 
 Begin
  UPDATE [Customer]                  
  SET    
   [Company_Name] = @Company_Name,            
   [ContactPerson] = @ContactPerson,            
   [CustomerCategory] = @CustomerCategory,            
   [BillingAddress] = @BillingAddress,            
   [ShippingAddress] = @ShippingAddress,            
   [AreaID] = @AreaID,            
   [CityID] = @CityID,            
   [StateID] = @StateID,            
   [CountryID] = @CountryID,            
   [Phone] = @Phone,            
   [Email] = @Email,            
   [Active] = @Active,            
   [Discount] = @Discount,            
   [DLNumber] = @DLNumber,            
   [TNGST] = @TNGSTNumber,            
   [CreditTerm] = @CreditTerm,            
   [DLNumber21] = @DLNumber21,            
   [CST] = @CSTNumber,            
   [CreditLimit] = @CreditLimit,            
   [AlternateCode] = @AlternateCode,            
   [CreditRating] = @CreditRating,            
   [ChannelType] = @ChannelType,            
   [Locality] = @Locality,            
   [Payment_Mode] = @Payment_mode,  
   [Customer_Password] = @Password,  
   [District] = @District,  
   [TownClassify]= @Town,  
   [AccountType] = @AccountType,  
   [SequenceNo]=@SequenceNo,  
   [TIN_Number] = @TINNUMBER,  
   [Alternate_Name] = @AlternateName,  
   [TrackPoints]= @TrackPoints,  
   [CollectedPoints] = @CollectedPoints,  
   [SubChannelID] = @SubChannelID,  
   [Potential]=@Potential,  
   [MobileNumber] = @MobileNumber,  
   [Residence] = @Residence,
   [PinCode] = @PinCode,
   [TradeCategoryID] = @TradeCategoryID,
   [NoOfBillsOutstanding] = @NoOfBillsOutstanding,
   [SegmentID] =  @SegmentID,
   [ModifiedDate]  = getdate()	
  WHERE             
   ([CustomerID]  = @CustomerID)  
End
