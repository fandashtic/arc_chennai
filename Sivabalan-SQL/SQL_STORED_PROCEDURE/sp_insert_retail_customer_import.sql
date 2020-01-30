CREATE Procedure sp_insert_retail_customer_import
(
     @Name nvarchar(100),   
     @Address nvarchar(255),  
     @DOB datetime,   
     @ReferredBy nvarchar(128),  
     @MembershipCode nvarchar(30) = N'',  
     @Telephone nvarchar(30) = N'',  
     @Fax nvarchar(30) = N'',  
     @ContactPerson nvarchar(30) = N'',  
     @Discount Decimal(18,6) = 0,  
     @CategoryName nvarchar(50) = N'', 
     @Salutation nvarchar(50) = N'', 
     @FirstName nvarchar(200) = N'', 
     @Lastname nvarchar(200) = N'', 
     @Address2 nvarchar(255) = N'',
     @City nvarchar(100) = N'', 
     @Pin nvarchar(50), 
     @Occupation nvarchar(100)= N'', 
     @Awareness nvarchar(100)= N'', 
     @Mobile nvarchar(50) = 0, 
     @STDCode nvarchar(50) = 0, 
     @Email nvarchar(100) = N'',
	 @TrackPoints int = 0,
	 @CollectedPoints Decimal(18,6) = 0
)   
as  
Declare @nRefBy int
Declare @szMemCode nvarchar(30)
Declare @nCatID int
Declare @nSaluteID int
Declare @CityID int
Declare @nOccupation Int
Declare @nAwareness Int
	--Referred by checking
	if @ReferredBy <> N''
	Begin
	If Exists(Select [Name] From Doctor Where [Name] = @ReferredBy)
		Select @nRefBy = [ID] From Doctor Where [Name] = @ReferredBy
	Else
		Begin
			insert into Doctor (Name) values (@ReferredBy)  
			select @nRefBy = @@IDENTITY  
		End
	End

	--Category checking
	If @CategoryName <> N''
		If Exists(Select CategoryID from RetailCustomerCategory Where CategoryName = @CategoryName)
			Select @nCatID = CategoryID from RetailCustomerCategory Where CategoryName = @CategoryName
		Else
			Begin
				INSERT INTO Retailcustomercategory([CategoryName],[Active]) VALUES (@CategoryName, 1)   
				select @nCatID = @@identity  
			End
		
	Else
		Set @nCatID = 0
	If @Salutation <> N'' 
		If Exists(Select SalutationID from Salutation Where [Description] = @Salutation)
			Select @nSaluteID = SalutationID from Salutation Where [Description] = @Salutation
		Else
			Begin
				Insert into Salutation ([Description]) Values (@Salutation)
				Select @nSaluteID = @@identity  
			End
	Else
		Set @nSaluteID = 0
	 		

	If @City <> N''
		If Exists (Select Isnull(CityID, 0) from City Where CityName = @City)
			Select @CityID = Isnull(CityID, 0) from City Where CityName = @City
		Else
			Begin 
				Insert Into City (CityName, Active, STDCode) Values (@City, 1, @STDCode) 
				Select @CityID = @@identity  
			End	
	Else	 		
		Set @CityID = 0

	if @Occupation <> N'' 
		If Exists (Select isnull(OccupationID, 0) from Occupation Where Occupation = @Occupation)
			Select @nOccupation = isnull(OccupationID, 0) from Occupation Where Occupation = @Occupation
		Else
			Begin
				Insert into Occupation ([Occupation]) Values (@Occupation)
				Select @nOccupation = @@Identity
			End
	Else
		Set @Occupation = 0

	if @Awareness <> N'' 
		if Exists (Select Isnull(AwarenessID, 0) from Awareness Where [Description] = @Awareness)
			Select @nAwareness = Isnull(AwarenessID, 0) from Awareness Where [Description] = @Awareness
		Else
			Begin
				Insert into Awareness ([Description]) Values (@Awareness)
				Set @nAwareness = @@Identity
			End
	Else
		Set @nAwareness = 0

	If Exists(Select Company_Name From Customer Where Membershipcode = @MembershipCode and CustomerCategory = 4)
	Begin	
		--Update customer
		Update Customer Set BillingAddress = @Address , DOB = @dob , ReferredBy = @nRefBy , Phone = @Telephone 
		, Fax = @Fax , ContactPerson = @ContactPerson , Discount = @Discount , RetailCategory = @nCatID, CustomerCategory = 4,
		SalutationID = @nSaluteID, First_Name = @FirstName, Second_name = @Lastname, ShippingAddress = @Address2,
		CityID = @CityID, PinCode = @Pin,Occupation = @nOccupation, Awareness = @nAwareness, MobileNumber = @Mobile, Email = @Email , TrackPoints = @TrackPoints, CollectedPoints = @CollectedPoints
		Where Company_Name = @Name and Membershipcode = @MembershipCode

		Select CustomerID,N'Update' From Customer 
		Where Company_Name = @Name and Membershipcode = @MembershipCode
	End
	Else
	Begin
	--Membershipcode checking
		If Exists(Select Membershipcode from customer where Membershipcode = @MembershipCode and CustomerCategory = 4)
			Begin
				Select 1,N'Reject'
				GOTO SPOUT
			End
		Else If  @MembershipCode = N''
			Begin
				Select @szMemCode = cast(Isnull(Max(Cast(MemberShipCode as Decimal(30,0))),0)+ 1 as nvarchar) 
				From Customer 
				Where PATINDEX(N'%[^0-9]%',MEMBERSHIPCODE)=0
			End
		Else
			Set @szMemCode = @MembershipCode

		--Check Customer name alone exists
		If Exists(Select Company_Name From Customer Where Company_Name = @Name and CustomerCategory = 4)
			Begin		
				Select 2,N'Reject'					
				GOTO SPOUT
			End
		Else
			Begin
				--Insert customer
				insert into Customer(Company_Name, BillingAddress, DOB, ReferredBy, MembershipCode,  CustomerID,  
			        Phone, Fax, ContactPerson, Discount, CustomerCategory, RetailCategory, SalutationID, First_Name, Second_name, ShippingAddress, CityID, PinCode, Occupation, Awareness, MobileNumber, Email,	 TrackPoints ,	 CollectedPoints )
				values (@Name, @Address, @DOB, @nRefBy, @szMemCode, @szMemCode, @Telephone,   
				@Fax, @ContactPerson, @Discount, 4, @nCatID, @nSaluteID, @FirstName, @Lastname, @Address2, @CityID, @Pin, @nOccupation, @nAwareness, @Mobile, @Email, @TrackPoints, @CollectedPoints )  
				select @szMemCode  , N'Insert'
			End
	End
SPOUT:




