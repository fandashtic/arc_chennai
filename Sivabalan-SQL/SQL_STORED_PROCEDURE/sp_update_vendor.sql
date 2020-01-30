CREATE PROCEDURE sp_update_vendor(@VENDORID nvarchar(15),          
      @CONTACT_PERSON nvarchar(50),          
      @ADDRESS nvarchar(255),          
      @CITYID int,          
      @STATEID int,          
      @COUNTRYID int,          
      @ZIP int,          
      @FAX nvarchar(50),          
      @PHONE nvarchar(50),          
      @EMAIL nvarchar(50),          
      @ACTIVE int,          
      @ALTERNATECODE nvarchar(20),          
      @Locality int,          
      @ProductSupplied nvarchar(255),        
      @VendorRating nvarchar(50),  
      @SaleID int,  
      @TNGST nvarchar(30),  
      @CST nvarchar(30),  
      @Payable_To nvarchar(256),  
      @CreditTerm int,  
      @TINNUMBER nvarchar(20) = N'',
	  @PANNUMBER nvarchar(100) = N'',
	  @BStateID Int = 0,
	  @GSTIN nVarChar(15) = N'',
	  @IsRegistered int = 0
	  )  
AS          
Begin
Declare @OrgIsRegistered Int
Select @OrgIsRegistered = IsRegistered From Vendors WHERE VendorID = @VENDORID   

Declare @NewStateID as int
Declare @BillingState nvarchar(255)

If Exists(Select isnull(Flag,0) from tbl_mERP_ConfigAbstract where ScreenCode ='GSTaxEnabled' and ISNULL(Flag ,0) = 1)
Begin
	IF IsNull(@BStateID,0) > 0
	Begin
		
		Select @BillingState = ForumStateCode + '-' + StateName From StateCode Where StateID = @BStateID
		
		If IsNull(@BillingState,'') <> ''
		Begin
			If Exists (select StateID from State where State = @BillingState)
			Begin
				select Top 1 @NewStateID =  StateID from state where State = @BillingState			
			End
			Else
			Begin
				INSERT INTO [State] ( [State]) VALUES (@BillingState)
				select @NewStateID = @@identity
			End	
			
			Set @STATEID = @NewStateID
			
		End				
	End
End     
Else
Begin
	if IsNull(@CITYID,0) > 0
	Begin
		Select Top 1 @NewStateID = StateID from City Where CityID = @CITYID
		Set @STATEID = @NewStateID
	End
End

UPDATE Vendors SET         
     ContactPerson = @CONTACT_PERSON,          
     Address = @ADDRESS,          
     CityID = @CITYID,          
     StateID = @STATEID,          
     CountryID = @COUNTRYID,          
     Zip = @ZIP,          
     Fax = @FAX,          
     Phone = @PHONE,          
     Email = @EMAIL,          
     Active = @ACTIVE,          
     AlternateCode = @ALTERNATECODE,          
     Locality = @Locality ,        
     ProductSupplied = @ProductSupplied,        
     VendorRating = @VendorRating,        
     SaleID = @SaleID,      
     TNGST = @TNGST,  
     CST = @CST,  
     Payable_To = @Payable_To,  
     CreditTerm = @CreditTerm,  
     TIN_Number = @TINNUMBER,
	 PANNUMBER = @PANNUMBER,
	 [BillingStateID]=@BStateID , 
	 [GSTIN] = @GSTIN ,
	 [IsRegistered] = Case When IsNull(@OrgIsRegistered,0) =  1 Then @OrgIsRegistered Else @IsRegistered End
	 
	 WHERE VendorID = @VENDORID   

End
