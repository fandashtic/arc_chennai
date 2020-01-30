CREATE Procedure Sp_Insert_ReceivedCustomer (@ID int, @szFlag nVarchar(5) = '')                          
As                          
Declare @CanSave nvarchar(1)                          
Declare @CityName nvarchar(100)                          
Declare @CountryName nvarchar(100)                          
Declare @AreaName nvarchar(100)                          
Declare @StateName nvarchar(100)                          
Declare @ChannelName nvarchar(510)                          
Declare @BeatName nvarchar(510)                          
Declare @CreditType int                          
Declare @CreditValue Decimal(18,6)                          
Declare @CreditDesc nvarchar(100)                          
Declare @CatDesc nvarchar(100)                          
Declare @tempCreditTerm int                          
Declare @tempCreditDesc nvarchar(100)                          
Declare @ChkBal varchar(10)
            
-------For the Customer Insertion-------------                          
Declare @CustomerID nvarchar(30)                          
Declare @Company_Name nvarchar(256)                          
Declare @CntPerson nvarchar(510)                          
Declare @CatID int                          
Declare @ShipAdd nvarchar(510)                          
Declare @BillAdd nvarchar(510)                          
Declare @AreaID int                          
Declare @CityID Int                          
Declare @StateID int                          
Declare @CountryID Int                          
Declare @Phone nvarchar(100)                          
Declare @Email nvarchar(100)                          
Declare @BeatID int                          
Declare @Discount Decimal(18,6)                          
Declare @DL1 nvarchar(100)                          
Declare @TNGST nvarchar(100)                          
Declare @CreditTerm int                          
Declare @DL2 nvarchar(100)                          
Declare @CST nvarchar(100)                          
Declare @CreditLimit Decimal(18,6)                          
Declare @AlternateCode nvarchar(40)                          
Declare @Creditrating int                          
Declare @ChannelID int                          
Declare @Payment_Mode int                          
Declare @Locality int                          
Declare @CustomerPassword nvarchar(20)                          
Declare @ActStatus int                          
          
--Addition columns add                          
Declare @District nvarchar(100)                          
Declare @DistrictId int                          
Declare @TownClassify int                          
Declare @TIN_NUMBER nvarchar(100)                          
Declare @Alternate_Name nvarchar(100)                          
Declare @SubChannel nvarchar(100)                          
Declare @SubChannelId int                          
Declare @Potential nvarchar(100)                          
Declare @Residence nvarchar(100)                        
            
Declare @SequenceNo Decimal(18,6)            
Declare @TrackPoints Int            
Declare @CollectedPoints Decimal(18,6)            
                          
Set @DistrictId = 0                          
Set @SubChannelId = 0                          
                          
--For Retail Customer                          
Declare @DOB DateTime                          
Declare @ReferredBy nvarchar(100)                          
Declare @Refid int                          
Declare @MembershipCode nvarchar(100)                          
Declare @Fax nvarchar(100)                          
Declare @RetailCategory nvarchar(250)                          
Declare @RetailCategoryID int                          
Declare @Salutation nvarchar(100)                          
Declare @SalutationID int                          
Declare @First_Name nvarchar(200)                          
Declare @Second_Name  nvarchar(200)                          
Declare @PinCode nvarchar(50)                          
Declare @Occupation nvarchar(100)                          
Declare @OccupationID int                          
Declare @Awareness nvarchar(4000)                          
Declare @MobileNumber nvarchar(50)                   
Declare @CitySTDCode nvarchar(50)                                      
          
Declare @SegID int            
Declare @SID int          
  
-- updatestatus  
Declare @UpdateStatus nVarchar(255)     
Declare @RCSID nVarchar(200)  
Declare @MerchandiseType nVarchar(4000)  
Declare @MerchandiseID int
Declare @Invalidvalue int

-- Field1 to Field13 Values
Declare @Field1 nVarchar(255)    
Declare @Field2 nVarchar(255)    
Declare @Field3 nVarchar(255)    
Declare @Field4 nVarchar(255)    
Declare @Field5 nVarchar(255)    
Declare @Field6 nVarchar(255)    
Declare @Field7 nVarchar(255)    
Declare @Field8 nVarchar(255)    
Declare @Field9 nVarchar(255)    
Declare @Field10 nVarchar(255)    
Declare @Field11 nVarchar(255)    
Declare @Field12 nVarchar(255)    
Declare @Field13 nVarchar(255)

Declare @TMDID int

Declare @Zone nVarchar(255)
Declare @ZoneID Int
Declare @Upd as Int

---- Merchandise
Declare @SplitOn nvarchar(5)
Declare @Merchandtype nvarchar(4000) 
Declare @Cnt int
Set @Cnt = 1
Set @SplitOn  ='|'
---- Merchandise
                          
Set @Refid = 0                          
Set @RetailCategoryID = 0                          
Set @SalutationID = 0                          
Set @OccupationID = 0                          
Set @CitySTDCode = NULL                  
            
Set @Upd = 0

             
----------------                          
                          
Select @CanSave=dbo.fn_CanSaveCustomer(@ID)                          

  
                         
--- N- Cannot Save Customer, E-existing Customer,Y-Can Save and is a New Customer                          
--OMS Update Begin:
Declare @Customer_ID as Nvarchar(255)
Declare @Channel_Type as Nvarchar(255)
Declare @Outlet_Type as Nvarchar(255)
Declare @Loyalty_Type as Nvarchar(255)
Declare @Menu as Nvarchar(255)
Declare @User_Name as Nvarchar(255)
Declare @OMSLock as Nvarchar(255)
Declare @SrvrName nVarchar(50)
Declare @AEActivityID int 
Declare @AELogID int
Declare @IPAddress as Nvarchar(255)
Select @SrvrName = @@ServerName

Select  @Customer_ID = CustomerID, @Channel_Type = Channel_Type,  @Outlet_Type = Outlet_Type,  
@Loyalty_Type = Loyalty_Type,  @Menu = Menu, 
@User_Name = [User_Name],@OMSLock = OMSLock 
From ReceivedCustomers Where ID= @ID  

If @OMSLock = 1
	Begin
		Declare @OLID as Int
		If Exists(	select Top 1 * from tbl_mERP_OLClass 	Where 	Channel_Type_Desc = @Channel_Type And	Outlet_Type_Desc = @Outlet_Type And	SubOutlet_Type_Desc = @Loyalty_Type And 	Channel_Type_Active = 1 And	Outlet_Type_Active = 1 And	SubOutlet_Type_Active = 1 ) 
		Begin
			Set @OLID = (select Top 1 ID from tbl_mERP_OLClass 	Where 	Channel_Type_Desc = @Channel_Type And	Outlet_Type_Desc = @Outlet_Type And	SubOutlet_Type_Desc = @Loyalty_Type  And	Channel_Type_Active = 1 And	Outlet_Type_Active = 1 And	SubOutlet_Type_Active = 1)
		End	
		If 	@OLID > 0 
			Begin
				If exists (Select * from Customer where customerID = @Customer_ID)
					Begin
--						Declare @ip varchar(40)
--						Exec Sp_GetIP @ip out
						Select @IPAddress = ''
						exec mERP_sp_Insert_AEActivity @User_Name,'7',@SrvrName,@User_Name,@IPAddress,2
						Select @AEActivityID = @@Identity
						exec mERP_sp_Insert_AEActivity_Log @User_Name,'7','Central Update',@AEActivityID,@menu
--						select @AEActivityID = @@identity
						exec mERP_sp_Update_AEActivity_LogReference 'Central Update',@AEActivityID,@@identity
-- 						Insert into tbl_merp_AeActivity(UserName,AEModuleID,MachineID, ForumUserID,IPAddress,AEAuditLogID,Status,Login_Type) Values (@User_Name, 1, @SrvrName, @User_Name,@IPAddress, @@identity,128, 2)
						Update 	tbl_mERP_OLClassMapping set Active = 0, ModiFiedDate = Getdate() Where CustomerID = @Customer_ID and active=1
						Insert Into tbl_mERP_OLClassMapping (CustomerID,OLClassID,Active,AEAuditLogID) Values(@Customer_ID,@OLID,1,@AEActivityID)
--						exec mERP_sp_Insert_AEActivity_Log @User_Name,'1','CLOSE',@AEActivityID,@menu
						exec mERP_sp_Update_AEActivity @User_Name,'1',@SrvrName
					End
				Else
					Begin
						Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
						Values('TMDFieldMapping', 'CustomerID Not Exists' , (@Customer_ID), getdate())
					End	
			End
		Else
			Begin
				Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
				Values('TMDFieldMapping', 'OLClass Mapping Not Exists' , (@Channel_Type + ',' + @Outlet_Type + ',' + @Loyalty_Type), getdate())
			End
	End
Else
	Goto ContinueProcess
--OMS Update End: 
                                                 
ContinueProcess:
              
IF(@CanSave<>N'N')                          
begin                          
 Select   
 @CustomerID=CustomerID,                          
 @Company_Name=Company_Name,                          
 @CntPerson=ContactPerson,                          
 @ShipAdd=ShippingAddress,                  
 @BillAdd=BillingAddress,                          
 @Phone=Phone,                          
 @Email=Email,                          
 @Discount=Discount,                          
 @DL1=DLNumber20,                          
 @DL2=DLNUMBER21,                          
 @CST=CST,                  
 @TNGST=TNGST,                          
 @AlternateCode=ForumCode,                          
 @CreditRating=CreditRating,                          
 @CreditLimit=CreditLimit,                          
 @Payment_Mode=PaymentMode,                          
 @CatDesc=CustomerCategory,                          
 @CityName=City,@CountryName=Country,                          
 @AreaName=Area,@StateName=State,                          
 @ChannelName=ChannelType,@BeatName=Beat,                          
 @CreditType=CreditType,@CreditValue=Creditvalue,@CreditDesc=CreditTerm,                          
 @CustomerPassword=Customer_Password,@ActStatus=Active,                          
 @Locality=Locality,                          
 @District=District,                          
 @TownClassify=TownClassify,                          
 @TIN_NUMBER=TIN_Number,                          
 @Alternate_Name=Alternate_Name,                          
 @SubChannel=SubChannel,                          
 @Potential=Potential,                          
 @Residence=Residence,                           
 @DOB=DOB,                          
 @ReferredBy=ReferredBy,                          
 @MembershipCode=MembershipCode,                          
 @Fax=Fax,                          
 @RetailCategory=RetailCategory,                          
 @Salutation=Salutation,                          
 @First_Name=FirstName,                          
 @Second_Name=SecondName,                          
 @PinCode=PinCode,                          
 @Occupation=Occupation,                          
 @Awareness=Awareness,                          
 @MobileNumber=MobileNumber,                          
 @CitySTDCode=CitySTDCode,            
 @SequenceNo=IsNull(SequenceNo,0),            
 @TrackPoints=IsNull(TrackPoints,0),            
 @CollectedPoints=IsNull(CollectedPoints,0),          
 @segID=IsNull(SegmentID,0),  
 @RCSID = RCSID,  
 @UpdateStatus = UpdateStatus,  
 @MerchandiseType = MerchandiseType,
 @Field1 = Field1,
 @Zone = Field2,
 @Field3 = Field3,
 @Field4 = Field4,
 @Field5 = Field5,
 @Field6 = Field6,
 @Field7 = Field7,
 @Field8 = Field8,
 @Field9 = Field9,
 @Field10 = Field10,
 @Field11 = Field11,
 @Field12 = Field12,
 @Field13 = Field13
From ReceivedCustomers Where ID= @ID                          
      
         
If ( @Field1 <> '')
Begin
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field1'),1)) = 1    
Begin
  Set @TMDID = 0
  Select @TMDID = TMDID from Cust_TMD_Master where TMDCtlPos = 3 and TMDValue = @Field1
If( IsNull(@TMDID,0) <> 0)
Begin
	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
         And TMDCtlPos = 3)  
		Begin  
			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,3,@TMDID)  
		End  
	 Else  
		Begin  
			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 3
		End 
End 
Else
	Begin
		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
		Values('TMDFieldMapping', 'Field1 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field1) , @Field1, getdate())
	End	
End
End

---- Field2, Pos => 4
--If ( @Field2 <> '')
--Begin
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field2'),1)) = 1    
--begin
--  Set @TMDID = 0
--  Select @TMDID = TMDID from Cust_TMD_Master where TMDCtlPos = 4 and TMDValue = @Field2
--	
--If( IsNull(@TMDID,0) <> 0)
--Begin
--	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
--         And TMDCtlPos = 4)  
--		Begin  
--			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,4,@TMDID)  
--		End  
--	 Else  
--		Begin  
--			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 4
--		End 
--End 
--Else
--	Begin
--		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--		Values('TMDFieldMapping', 'Field2 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field2) , @Field2, getdate())
--	End	
--End
--End
--
---- Field3, Pos => 5
--If (@Field3 <> '')
--Begin
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field3'),1)) = 1    
--begin
--  Set @TMDID = 0
--  Select @TMDID = TMDID from Cust_TMD_Master where TMDCtlPos = 5 and TMDValue = @Field3
--If( IsNull(@TMDID,0) <> 0)
--Begin
--	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
--         And TMDCtlPos = 5)  
--		Begin  
--			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,5,@TMDID)  
--		End  
--	 Else  
--		Begin  
--			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 5
--		End 
--End 
--Else
--	Begin
--		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--		Values('TMDFieldMapping', 'Field3 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field3) , @Field3, getdate())
--	End	
--End
--End
--
---- Field4, Pos => 6
--If ( @Field4 <> '')
--Begin
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field4'),1)) = 1    
--begin
--  Set @TMDID = 0
--  Select @TMDID = TMDID from Cust_TMD_Master where TMDCtlPos = 6 and TMDValue = @Field4
--	
--If( IsNull(@TMDID,0) <> 0)
--Begin
--	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
--         And TMDCtlPos = 6)  
--		Begin  
--			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,6,@TMDID)  
--		End  
--	 Else  
--		Begin  
--			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 6
--		End 
--End 
--Else
--	Begin
--		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--		Values('TMDFieldMapping', 'Field4 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field4) , @Field4, getdate())
--	End	
--End
--End
--
--
--
---- Field5, Pos => 7
--If ( @Field5 <> '')
--Begin
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field5'),1)) = 1    
--begin
--  Set @TMDID = 0
--  Select @TMDID = TMDID from Cust_TMD_Master where TMDCtlPos = 7 and TMDValue = @Field5
--	
--If( IsNull(@TMDID,0) <> 0)
--Begin
--	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
--         And TMDCtlPos = 7)  
--		Begin  
--			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,7,@TMDID)  
--		End  
--	 Else  
--		Begin  
--			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 7
--		End 
--End 
--Else
--	Begin
--		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--		Values('TMDFieldMapping', 'Field5 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field5) , @Field5, getdate())
--	End	
--End
--End
--
--
---- Field6, Pos => 8
--
--If ( @Field6 <> '')
--Begin
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field6'),1)) = 1    
--Begin
--  Set @TMDID = 0
--  Select @TMDID = IsNull(TMDID,0) from Cust_TMD_Master where TMDCtlPos = 8 and TMDValue = @Field6
--If( IsNull(@TMDID,0) <> 0)
--Begin
--	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
--         And TMDCtlPos = 8)  
--		Begin  
--			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,8,@TMDID)  
--		End  
--	 Else  
--		Begin  
--			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 8
--		End 
--End 
--Else
--	Begin
--		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--		Values('TMDFieldMapping', 'Field6 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field6) , @Field6, getdate())
--	End	
--End
--End
--
--
---- Field7, Pos => 9
--If ( @Field7 <> '')
--Begin
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field7'),1)) = 1    
--begin
--  Set @TMDID = 0
--  Select @TMDID = TMDID from Cust_TMD_Master where TMDCtlPos = 9 and TMDValue = @Field7
--	
--If( IsNull(@TMDID,0) <> 0)
--Begin
--	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
--         And TMDCtlPos = 9)  
--		Begin  
--			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,9,@TMDID)  
--		End  
--	 Else  
--		Begin  
--			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 9
--		End 
--End 
--Else
--	Begin
--		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--		Values('TMDFieldMapping', 'Field7 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field7) , @Field7, getdate())
--	End	
--End
--End
--
--
---- Field8, Pos => 10
--If ( @Field8 <> '')
--Begin
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field8'),1)) = 1    
--begin
--  Set @TMDID = 0
--  Select @TMDID = TMDID from Cust_TMD_Master where TMDCtlPos = 10 and TMDValue = @Field8
--	
--If( IsNull(@TMDID,0) <> 0)
--Begin
--	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
--         And TMDCtlPos = 10)  
--		Begin  
--			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,10,@TMDID)  
--		End  
--	 Else  
--		Begin  
--			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 10
--		End 
--End 
--Else
--	Begin
--		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--		Values('TMDFieldMapping', 'Field8 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field8) , @Field8, getdate())
--	End	
--End
--End
--     
--
---- Field9, Pos => 11
--If ( @Field9 <> '')
--Begin
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field9'),1)) = 1    
--begin
--  Set @TMDID = 0
--  Select @TMDID = TMDID from Cust_TMD_Master where TMDCtlPos = 11 and TMDValue = @Field9
--	
--If( IsNull(@TMDID,0) <> 0)
--Begin
--	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
--         And TMDCtlPos = 11)  
--		Begin  
--			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,11,@TMDID)  
--		End  
--	 Else  
--		Begin  
--			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 11
--		End 
--End 
--Else
--	Begin
--		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--		Values('TMDFieldMapping', 'Field9 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field9) , @Field9, getdate())
--	End	
--End
--End    
--
--
---- Field10, Pos => 12
--If ( @Field10 <> '')
--Begin
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field10'),1)) = 1    
--begin
--  Set @TMDID = 0
--  Select @TMDID = TMDID from Cust_TMD_Master where TMDCtlPos = 12 and TMDValue = @Field10
--	
--If( IsNull(@TMDID,0) <> 0)
--Begin
--	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
--         And TMDCtlPos = 12)  
--		Begin  
--			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,12,@TMDID)  
--		End  
--	 Else  
--		Begin  
--			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 12
--		End 
--End 
--Else
--	Begin
--		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--		Values('TMDFieldMapping', 'Field10 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field10) , @Field10, getdate())
--	End	
--End
--End    
--
---- Field11, Pos => 13
--If ( @Field11 <> '')
--Begin
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field11'),1)) = 1    
--begin
--  Set @TMDID = 0
--  Select @TMDID = TMDID from Cust_TMD_Master where TMDCtlPos = 13 and TMDValue = @Field11
--	
--If( IsNull(@TMDID,0) <> 0)
--Begin
--	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
--         And TMDCtlPos = 13)  
--		Begin  
--			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,13,@TMDID)  
--		End  
--	 Else  
--		Begin  
--			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 13
--		End 
--End 
--Else
--	Begin
--		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--		Values('TMDFieldMapping', 'Field11 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field11) , @Field11, getdate())
--	End	
--End
--End    
--
--
---- Field12, Pos => 14
--If ( @Field12 <> '')
--Begin
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field12'),1)) = 1    
--begin
--  Set @TMDID = 0
--  Select @TMDID = TMDID from Cust_TMD_Master where TMDCtlPos = 14 and TMDValue = @Field12
--	
--If( IsNull(@TMDID,0) <> 0)
--Begin
--	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
--         And TMDCtlPos = 14)  
--		Begin  
--			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,14,@TMDID)  
--		End  
--	 Else  
--		Begin  
--			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 14
--		End 
--End 
--Else
--	Begin
--		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--		Values('TMDFieldMapping', 'Field12 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field12) , @Field12, getdate())
--	End	
--End
--End    
--
--
---- Field13, Pos => 15
--If ( @Field13 <> '')
--Begin
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field13'),1)) = 1    
--begin
--  Set @TMDID = 0
--  Select @TMDID = TMDID from Cust_TMD_Master where TMDCtlPos = 15 and TMDValue = @Field13
--	
--If( IsNull(@TMDID,0) <> 0)
--Begin
--	 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustomerID  
--         And TMDCtlPos = 15)  
--		Begin  
--			Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustomerID,15,@TMDID)  
--		End  
--	 Else  
--		Begin  
--			Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustomerID and TMDCtlPos = 15
--		End 
--End 
--Else
--	Begin
--		Insert Into tbl_mERP_RecdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--		Values('TMDFieldMapping', 'Field13 Value Doesnt Exist in Master table -- ' + Convert(Varchar(200),@Field13) , @Field13, getdate())
--	End	
--End
--End 



--Cheking For Segment          
  Select @SID=SegmentID From Customersegment where SegmentCode=(Select SegmentCode From           
  ReceivedSegments Where SegmentID=@segID)          
  If IsNull(@SID,N'') = N'' OR IsNull(@SID,0) = 0          
    Begin          
      Set @SID = 0          
    End         
  
-- Checking For MerchandiseType

If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'MerchandisingType'),1)) = 1  
Begin           
    Delete CustMerchandise where [CustomerID]=@CustomerID             
    If IsNull(@MerchandiseType,N'') <> N''
    Begin
	If ((Charindex(@SplitOn,@MerchandiseType)>0) Or  (upper(@MerchandiseType) ='ALL MERCHANDISE'))
	Begin    
	If Charindex(@SplitOn,@MerchandiseType)>0
	Begin
		Set @MerchandiseType = @MerchandiseType + '|'
		While (Charindex(@SplitOn,@MerchandiseType)>0)            
		 Begin
				Select @Merchandtype = ltrim(rtrim(Substring(@MerchandiseType,1,Charindex(@SplitOn,@MerchandiseType)-1)))
				--Select @Merchandtype
				Select @MerchandiseID = MerchandiseID From Merchandise Where Merchandise = @Merchandtype
				If ISNull(@MerchandiseID, N'') = N'' or ISNull(@MerchandiseID,0) = 0            
				Begin   
				   Insert Into Merchandise(Merchandise, Active,CreateDate) values(@Merchandtype, 1, getdate())	         
				End   
				IF Not exists( Select CustomerID From CustMerchandise Where [CustomerID]=@CustomerID )                          
				Begin
					Select @MerchandiseID = MerchandiseID From Merchandise Where Merchandise = @Merchandtype                  
					Insert Into CustMerchandise(CustomerID, MerchandiseID) Values(@CustomerID,@MerchandiseID)
				End	
				Else
				Begin
					Select @MerchandiseID = MerchandiseID From Merchandise Where Merchandise = @Merchandtype                  
					Insert Into CustMerchandise(CustomerID, MerchandiseID) Values(@CustomerID,@MerchandiseID)
				End
				Set @MerchandiseType = Substring(@MerchandiseType,Charindex(@SplitOn,@MerchandiseType)+1,len(@MerchandiseType))
				Set @MerchandiseID = 0				
		 End  -- While 
	End  -- If 
	If @MerchandiseType ='ALL MERCHANDISE'
	Begin   
 	  Insert Into CustMerchandise(CustomerID, MerchandiseID)
	  select @CustomerID,MerchandiseID from Merchandise  	
	End -- End of @MerchandiseType ='All Merchandise'
	End  -- If double condition
    else 
    begin 
    --without allmerchandise tag or without pipeline        				  
		Select @MerchandiseID = MerchandiseID From Merchandise Where Merchandise = @MerchandiseType                  
		If ISNull(@MerchandiseID, N'') = N'' or ISNull(@MerchandiseID,0) = 0            
		Begin   
		Insert Into Merchandise(Merchandise, Active,CreateDate) values(@MerchandiseType, 1, getdate())	         
		End 
  
		IF Not exists( Select CustomerID From CustMerchandise Where [CustomerID]=@CustomerID )                          
		Begin
		Select @MerchandiseID = MerchandiseID From Merchandise Where Merchandise = @MerchandiseType                  
		Insert Into CustMerchandise(CustomerID, MerchandiseID) Values(@CustomerID,@MerchandiseID)
		End	
		Else
		Begin
		Select @MerchandiseID = MerchandiseID From Merchandise Where Merchandise = @MerchandiseType                  
		Update CustMerchandise Set MerchandiseID = @MerchandiseID where CustomerID =@CustomerID
		End
    end 
    end
End
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'MerchandisingType'),1)) > 1  
Begin
		Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'MerchandisingType'),1)
		Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
		values('TradeCustomer', 'Merchandising Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End

-- Checking for Category   
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Catdesc'),1)) = 1  
Begin                            
 Select @CatID=CategoryID From CustomerCategory Where CategoryName=@Catdesc                  
 If ISNull(@CatID,N'') = N'' or ISNull(@CatID,0) = 0            
   Begin            
   Set @CatID = 0            
   End   
End  
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Catdesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Catdesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Cat Desc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End



                          
    --Checking For the District                          
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'District'),1)) = 1  
Begin  
 IF isNull(@District,N'')<>N''              
 Begin                          
  IF Not exists(Select DistrictID From District Where DistrictName=@District)                          
  Begin                          
    insert into District (DistrictName) values(@District)                              
  End                             
  Select @DistrictID=DistrictID From District Where DistrictName=@District                          
 End                          
 Else                          
  Set @DistrictID=0                           
End  
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'District'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'District'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'District Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End


 --Checking For the Zone

If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field2'),1)) = 1  
Begin  
	IF isNull(@Zone,N'') <> N''              
	Begin                          
		IF Not exists(Select ZoneID From tbl_mERP_Zone Where ZoneName = @Zone)                          
		Begin                          
			insert into tbl_mERP_Zone (ZoneName) values(@Zone)                              
		End                             
		Select @ZoneID = ZoneID From tbl_mERP_Zone Where ZoneName = @Zone                          
	End                          
	Else                          
		Set @ZoneID=0                           
End  
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field2'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field2'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Custom Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End


                          
      --Checking For the SubChannel                          
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SubChannel'),1)) = 1  
Begin  
 IF isNull(@SubChannel,N'')<>N''              
 Begin                          
  IF Not exists(Select SubChannelID From SubChannel Where [Description]=@SubChannel)                          
  Begin                          
    insert into SubChannel ([Description]) values(@SubChannel)                              
  End                             
  Select @SubChannelID=SubChannelID From SubChannel Where [Description]=@SubChannel                          
 End                          
 Else                          
  Set @SubChannelID=0                           
End  
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SubChannel'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'SubChannel'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'SubChannel Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End

                        
   --Checking For the RetailCustomer                           
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Catdesc'),1)) = 1  
Begin  
 if IsNull(@CatID,0) = 0 and @CatDesc = N'End Customer'                          
 Begin                          
--  Exec sp_insert_RetailCustomerCategory (@Catdesc)                          
  IF Not exists(Select CategoryID From CustomerCategory Where                           
   [CategoryName]=@CatDesc)                          
  Begin                          
   insert into CustomerCategory([CategoryID], [CategoryName], [Active])                           
    Values (4, N'End Customer', 1)                          
  End              
  Select @CatID=CategoryID From CustomerCategory Where CategoryName=@Catdesc                          
 End   
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Catdesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Catdesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Catdesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End                         
                           
 -- If Category is 'End Customer' then check the Salutation, ReferredBy and so on                             
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Catdesc'),1)) = 1  
Begin  
 if @CatDesc = N'End Customer'                          
 Begin                          
  -- checking for ReferredBy (Doctor)                          
 if IsNull(@ReferredBy,N'') <> N'' or IsNull(@ReferredBy,0) <> 0                            
  begin                            
      select @Refid= [ID] from doctor where [Name] like @ReferredBy                              
      if isnull(@Refid, 0) = 0                              
 begin                              
       insert into doctor (Name) values(@ReferredBy)                              
       select @Refid = @@IDENTITY                                            
     end                              
  end                            
  else                           
   set @Refid = 0                             
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Catdesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Catdesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Catdesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End    
                      
  -- checking for RetailCategory (RetailCustomerCategory)                          
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'RetailCategory'),1)) = 1  
Begin  
  if IsNull(@RetailCategory,N'') <> N'' or IsNull(@RetailCategory,0) <> 0                            
  begin                            
      select @RetailCategoryiD= CategoryID from RetailCustomerCategory                           
    where CategoryName = @RetailCategory                              
  if isnull(@RetailCategoryiD, 0) = 0                              
      begin                              
       insert into RetailCustomerCategory (CategoryName,Active,CreationDate)                       
  values(@RetailCategory,1,getdate())                              
       select @RetailCategoryiD = @@IDENTITY                                            
     end                              
  end                            
  else                           
   set @RetailCategoryiD = 0                             
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'RetailCategory'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'RetailCategory'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'RetailCategory Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End    
                          
  -- checking for Salutation (Salutation)    
  
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Salutation'),1)) = 1  
Begin  
  if IsNull(@Salutation,N'') <> N'' or IsNull(@Salutation,0) <> 0                            
  begin                            
      select @SalutationID = SalutationID from Salutation                           
    where [Description] = @Salutation                              
      if isnull(@SalutationID, 0) = 0                              
      begin                              
       insert into Salutation ([Description]) values(@Salutation)                              
       select @SalutationID = @@IDENTITY                                            
     end                              
  end                            
  else                           
   set @SalutationID = 0                             
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Salutation'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Salutation'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Salutation Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 
  
  
  -- checking for Occupation (Occupation)                          
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Occupation'),1)) = 1  
Begin                          
  if IsNull(@Occupation,N'') <> N'' or IsNull(@Occupation,0) <> 0                            
  begin                            
      select @OccupationID = OccupationID from Occupation                           
     where [Occupation] = @Occupation                              
      if isnull(@OccupationID, 0) = 0                              
      begin                              
       insert into Occupation (Occupation) values(@Occupation)                              
       select @OccupationID = @@IDENTITY                                            
     end                              
  end                            
  else            
      set @OccupationID = 0                             
 End                                     
End 
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Occupation'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Occupation'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Occupation Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 
                 
                            
                          
--Checking For the Country                          
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CountryDesc'),1)) = 1  
Begin  
 IF isNull(@CountryName,N'')<>N''              
 Begin                          
  IF Not exists(Select CountryID From Country Where Country=@CountryName)                          
  Begin                          
    Exec sp_insert_country @CountryName                          
  End                             
  Select @CountryID=CountryID From Country Where Country=@CountryName                          
End                          
 Else                          
  Set @CountryID=0                           
End  
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CountryDesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CountryDesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'CountryDesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

                          
                
      --Checking For the Area                          
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'AreaDesc'),1)) = 1  
Begin  
 IF isNull(@AreaName,N'')<>N''                          
 Begin                          
  IF Not exists(Select AreaID From Areas Where Area=@AreaName)                          
  Begin                          
  exec sp_insert_Area @AreaName                          
  End                             
  Select @AreaID=AreaID From Areas Where Area=@AreaName                          
 End                          
 Else                      
  Set @AreaID=0                           
End  
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'AreaDesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'AreaDesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'AreaDesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 
                          
                          
      --Checking For the State                          
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'StateDesc'),1)) = 1  
Begin  
 IF isNull(@StateName,N'')<>N''              
 Begin                          
  IF Not exists(Select StateID From State Where State=@StateName)                          
  Begin                          
  exec sp_insert_state @StateName                          
  End                             
  Select @StateID=StateID From State Where State=@StateName                          
 End                          
 Else                          
  Set @StateID=0                            
End 
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'StateDesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'StateDesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'StateDesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 
 
                    
      --Checking For the City                          
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CityDesc'),1)) = 1  
Begin  
 IF isNull(@CityName,N'')<>N''                          
 Begin                          
  IF Not exists(Select CityID From City Where CityName=@CityName)                          
  Begin                          
    Exec sp_insert_city @CityName,@DistrictID,@StateID,1,@CitySTDCode                          
  End                             
  Select @CityID=CityID From City Where CityName=@CityName            
  Exec sp_Update_CityInfo @CityID,@DistrictID,@StateID,1,@CityStDCode                          
 End                          
 Else              
 Begin                          
  Set @CityID=0                            
 End   
End                   
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CityDesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CityDesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'CityDesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End                  
                          
      --Checking For the Channel                          
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ChannelDesc'),1)) = 1  
Begin  
 IF isNull(@ChannelName,N'')<>N''              
 Begin                          
  IF Not exists(Select ChannelType From Customer_Channel Where ChannelDesc=@ChannelName)                          
  Begin                          
  exec sp_insert_Channel @ChannelName                          
  End                             
  Select @ChannelID=ChannelType From Customer_Channel Where ChannelDesc=@ChannelName                          
 End                          
 Else                          
  Set @ChannelID=0                            
End  
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ChannelDesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'ChannelDesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'ChannelDesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End                  
     

                          
      --Checking For the Beat     
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'BeatDesc'),1)) = 1  
Begin                       
 IF isNull(@BeatName,N'')<>N''                          
 Begin                          
  IF Not exists(Select BeatID From Beat Where Description=@BeatName)                          
  Begin                          
  exec sp_insert_Beat @BeatName                          
  End                             
  Select @BeatId=BeatID From Beat Where Description=@BeatName                            
  --If @szFlag= 'SITC'   
-- Begin  
  exec Sp_Save_ITCBeatCustomer @BeatID,@CustomerID                     
  Update Customer Set DefaultBeatId = @BeatId Where CustomerID = @CustomerID  
-- End  
--  Else  
--   exec Sp_Save_BeatCustomer @BeatID,@CustomerID                          
 End            
 Else                          
  Set @BeatID=0                            
End  
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'BeatDesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'BeatDesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'BeatDesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 
                        
                          
      --Checking For the CreditTerm    
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CreditValue'),1)) = 1                        
Begin  
  
    IF((@CreditType<>0) And (@CreditValue<>0))                           
 Begin                          
  IF Not exists(Select CreditID From CreditTerm Where Type=@CreditType And Value=@CreditValue)                          
  Begin                          
   If Not Exists(Select Description From CreditTerm Where Description=@CreditDesc)                           
      Begin                          
    Exec Sp_Insert_CreditTerm @CreditDesc,@CreditType,@CreditValue                          
    Select @CreditTerm=CreditID From CreditTerm Where Type=@CreditType And Value=@CreditValue And Description=@CreditDesc                          
   End                          
   Else                          
   Begin                          
    Select @TempCreditTerm=ISnull(Max(Cast(Substring(Description,Len(@CreditDesc)+1,Len(Description))as int))+1,1) From CreditTerm                           
    Where Description like @CreditDesc + N'%' + N'[0-9]'                          
    And ISnumeric(Substring(Description,Len(@CreditDesc)+1,Len(Description)))<>0                             
    And CharIndex(N'.',Substring(Description,Len(@CreditDesc)+1,Len(Description)))=0                          
    And CharIndex(N'-',Substring(Description,Len(@CreditDesc)+1,Len(Description)))=0                          
                          
    Set @tempCreditDesc=@CreditDesc + @TempCreditTerm                           
    Exec Sp_Insert_CreditTerm @tempCreditDesc,@CreditType,@CreditValue                          
    Select @CreditTerm=CreditID From CreditTerm Where Type=@CreditType And Value=@CreditValue And Description=@tempCreditDesc                             
   End                          
  End                          
  Else                          
  Begin                          
  Select @CreditTerm=CreditID From CreditTerm Where Type=@CreditType And Value=@CreditValue                          
  End                          
 End                          
 Else                          
  Set @CreditTerm=0                           
End  
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CreditValue'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'CreditValue'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'CreditValue Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

                        
---------------------------------------------------------------------------------------                          
if (@CanSave=N'Y')                          
begin                          
  Exec Sp_Insert_Customer @CustomerID,@Company_Name,@CntPerson,@CatID,                          
  @BillAdd,@ShipAdd,@AreaID,@CityID,@StateID,@CountryID,@Phone,@Email,0,                          
  @BeatID,@Discount,@DL1,@TNGST,@CreditTerm,@DL2,@CST,@CreditLimit,@AlternateCode,                     
  @CreditRating,@ChannelID,@Locality,@Payment_Mode,0,@CustomerPassword,                       
  @DistrictId, @TownClassify, 0, @SequenceNo, @TIN_NUMBER, @Alternate_Name, @TrackPoints, @CollectedPoints,              
  @SubChannelId, @Potential, @MobileNumber, @Residence                          
            
  Update Customer Set SegmentID=@SID Where Customerid=@CustomerID                         
                           
  Exec sp_Update_ReceiveCustomer @CustomerID, @DOB, @Refid, @MembershipCode,                           
  @Fax, @RetailCategoryID, @SalutationID, @First_Name, @Second_Name, @PinCode,                          
  @OccupationID, @Awareness           
          
  Update Customer Set SegmentID=@SID Where Customerid=@CustomerID                         
  
  Update Customer Set DefaultBeatId = (Case When @BeatId = 0 Then Null Else @BeatId End) Where CustomerId = @CustomerID     -- ITC  
                          
--Update Customer Set Active=@ActStatus,ZoneID = @ZoneID Where Customerid=@CustomerID                          
  Update Customer Set ZoneID = @ZoneID Where Customerid=@CustomerID                          
                            
  if @Catdesc <> N'End Customer'                          
  Begin                          
   Exec sp_Update_Customer_recForumCode @AlternateCode,@CustomerID                     
  End                   
    Exec sp_acc_master_addaccount 1, 22, @Company_Name, 0, N''                                      
End                 
                          
if (@CanSave=N'E')                          
begin                          
  Exec Sp_Update_Customer @CustomerID,@Company_Name,@CntPerson,@CatID,                          
  @BillAdd,@ShipAdd,@AreaID,@CityID,@StateID,@CountryID,@Phone,@Email,0,                          
  @BeatID,@Discount,@DL1,@TNGST,@CreditTerm,@DL2,@CST,@CreditLimit,@AlternateCode,                          
  @CreditRating,@ChannelID,@Locality,@Payment_Mode,0,@CustomerPassword,                          
  @DistrictId, @TownClassify, 0, @SequenceNo, @TIN_NUMBER, @Alternate_Name,   
  @TrackPoints, @CollectedPoints, @SubChannelId, @Potential, @MobileNumber, @Residence, '', null, 0, null, 0, @RCSID, @UpdateStatus, 1   

  --cc                       
  -- Update Customer Set SegmentID=@SID Where Customerid=@CustomerID                         
      
  Exec sp_Update_ReceiveCustomer @CustomerID, @DOB, @Refid, @MembershipCode,                           
  @Fax, @RetailCategoryID, @SalutationID, @First_Name, @Second_Name, @PinCode,                          
  @OccupationID, @Awareness, @UpdateStatus                          
--cc  
If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'BeatDesc'),1)) = 1  
Begin
  if @BeatId <> 0 
  begin 
  Update Customer Set DefaultBeatId = (Case When @BeatId = 0 Then Null Else @BeatId End) Where CustomerId = @CustomerID     -- ITC  
  end  
End
Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'BeatDesc'),1)) > 1  
Begin
	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'BeatDesc'),1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'BeatDesc Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

  
--If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Active'),1)) = 1                         
--  ---check for accountbalance for customer 
--    IF @ActStatus=0 
--	Begin 
--		EXEC CheckBalanceExists_Cust  @Custid = @customerID,  @ret = @ChkBal OUTPUT 
--		If @ChkBal <> 'True'
--		Begin 
--		Update Customer Set Active=@ActStatus Where Customerid=@CustomerID  
--		End     
--    End 
--    IF @ActStatus=1
--    Begin
--        Update Customer Set Active=@ActStatus Where Customerid=@CustomerID  
--    End          
--Else If (Select SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Active'),1)) > 1  
--Begin
--	Select @Invalidvalue = SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Active'),1)
--	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
--	values('TradeCustomer', 'Active Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
--End 


--Zone
Select @Upd =  SubString(@updateStatus,(Select Max(Sno) From ItemsRecUpdateStatus Where Nodegramps ='TradeCustomer' and ChildNode = 'Info' and Attributes = 'Field2'),1)
If (isNull(@Upd,-1) = 1   Or isNull(@Upd,-1) = -1 )

   	Update Customer Set ZoneID = @ZoneID Where Customerid=@CustomerID  

Else If (isNull(@Upd,-1)) > 1  
Begin
	Select @Invalidvalue = isNull(@Upd,-1)
	Insert Into tbl_mERP_recdErrMessages(TransactionType, ErrMessage, KeyValue, ProcessDate)
	values('TradeCustomer', 'Zone Attribute has Invalid Value-- ' + Convert(nVArchar, @Invalidvalue), null, getdate())
End 

   exec sp_acc_accountexists 1, @CustomerID                           
   exec sp_acc_master_updateaccount 1, 22, @Company_Name, @ActStatus, N''                              
End                          
---------------------------------------------------------------------------------------                          
End                          
                          
Update ReceivedCustomers Set Status=(Status |128)                          
 Where ID=@ID                          
