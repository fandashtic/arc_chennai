CREATE Procedure Sp_Udhayam_CustomerInsertion(@ID int)
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


Select @CanSave=dbo.fn_CanSaveCustomer(@ID)

--- N- Cannot Save Customer, E-existing Customer,Y-Can Save and is a New Customer

IF(@CanSave<>N'N')
begin
	Select @CustomerID=CustomerID,
	@Company_Name=Company_Name,
	@CntPerson=ContactPerson,
	@ShipAdd=BillingAddress,
	@BillAdd=ShippingAddress,	
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
	@Locality=Locality
        From ReceivedCustomers Where ID=@ID

	Select @CatID=CategoryID From CustomerCategory Where CategoryName=@Catdesc

      --Checking For the City
	IF isNull(Len(@CityName),0)<>0
	Begin
		IF Not exists(Select CityID From City Where CityName=@CityName)
		Begin
		  Exec sp_insert_city @CityName
		End			
		Select @CityID=CityID From City Where CityName=@CityName
	End
	Else
		Set @CityID=0	

      --Checking For the Country
	IF isNull(Len(@CountryName),0)<>0
	Begin
		IF Not exists(Select CountryID From Country Where Country=@CountryName)
		Begin
		  Exec sp_insert_country @CountryName
		End			
		Select @CountryID=CountryID From Country Where Country=@CountryName
	End
	Else
		Set @CountryID=0	


      --Checking For the Area
	IF isNull(Len(@AreaName),0)<>0
	Begin
		IF Not exists(Select AreaID From Areas Where Area=@AreaName)
		Begin
		exec sp_insert_Area @AreaName
		End			
		Select @AreaID=AreaID From Areas Where Area=@AreaName
	End
	Else
		Set @AreaID=0	


      --Checking For the State
	IF isNull(Len(@StateName),0)<>0
	Begin
		IF Not exists(Select StateID From State Where State=@StateName)
		Begin
		exec sp_insert_state @StateName
		End			
		Select @StateID=StateID From State Where State=@StateName
	End
	Else
		Set @StateID=0		


      --Checking For the Channel
	IF isNull(Len(@ChannelName),0)<>0
	Begin
		IF Not exists(Select ChannelType From Customer_Channel Where ChannelDesc=@ChannelName)
		Begin
		exec sp_insert_Channel @ChannelName
		End			
		Select @ChannelID=ChannelType From Customer_Channel Where ChannelDesc=@ChannelName
	End
	Else
		Set @ChannelID=0		

      --Checking For the Beat
	IF isNull(Len(@BeatName),0)<>0
	Begin
		IF Not exists(Select BeatID From Beat Where Description=@BeatName)
		Begin
		exec sp_insert_Beat @BeatName
		End			
		Select @BeatId=BeatID From Beat Where Description=@BeatName		
		exec Sp_Save_BeatCustomer @BeatID,@CustomerID
	End
	Else
		Set @BeatID=0		


      --Checking For the CreditTerm
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

---------------------------------------------------------------------------------------
if (@CanSave=N'Y')
begin
		Exec Sp_Insert_Customer @CustomerID,@Company_Name,@CntPerson,@CatID,
		@BillAdd,@ShipAdd,@AreaID,@CityID,@StateID,@CountryID,@Phone,@Email,0,
		@BeatID,@Discount,@DL1,@TNGST,@CreditTerm,@DL2,@CST,@CreditLimit,@AlternateCode,
		@CreditRating,@ChannelID,@Locality,@Payment_Mode,0,@CustomerPassword	

		Update Customer Set Active=@ActStatus Where Customerid=@CustomerID

		Exec sp_Update_Customer_recForumCode @AlternateCode,@CustomerID

 		Exec sp_acc_master_addaccount 1, 22, @Company_Name, 0, N''
End

if (@CanSave=N'E')
begin
		Exec Sp_Update_Customer @CustomerID,@Company_Name,@CntPerson,@CatID,
		@BillAdd,@ShipAdd,@AreaID,@CityID,@StateID,@CountryID,@Phone,@Email,0,
		@BeatID,@Discount,@DL1,@TNGST,@CreditTerm,@DL2,@CST,@CreditLimit,@AlternateCode,
		@CreditRating,@ChannelID,@Locality,@Payment_Mode,0,@CustomerPassword
	
		Update Customer Set Active=@ActStatus Where Customerid=@CustomerID

		exec sp_acc_accountexists 1, @CustomerID 

		exec sp_acc_master_updateaccount 1, 22, @Company_Name, @ActStatus, N''
End
---------------------------------------------------------------------------------------
End

Update ReceivedCustomers Set Status=(Status |128)
	Where ID=@ID



