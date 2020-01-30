CREATE PROCEDURE [sp_insert_Vendors]             
 (@VendorID_1  [nvarchar](15),  @Vendor_Name_2  [nvarchar](50),              
  @ContactPerson_3  [nvarchar](50),  @Address_4  [nvarchar](255),              
  @CityID_5  [int],  @StateID_6  [int],  @CountryID_7  [int],              
  @Zip_8  [int],  @Fax_9  [nvarchar](50),  @Phone_10  [nvarchar](50),              
  @Email_11  [nvarchar](50),              
  @AlternateCode [nvarchar](20),              
  @Locality int,             
  @ProductSupplied nvarchar(255),            
  @VendorRating nvarchar(50),            
  @SaleID int,          
  @TNGST nvarchar(30),    
  @CST nvarchar(30),     
  @Payable_To nvarchar(256),    
  @CreditTerm int = 0,    
  @TINNUMBER nvarchar(20) = N'',
  @PANNUMBER nvarchar(100) = N'',
  @BStateID Int = 0,
  @GSTIN nVarChar(15) = N'',
  @IsRegistered int = 0
  )              
              
AS     
Begin     

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
			
			Set @StateID_6 = @NewStateID
			
		End				
	End
End     
Else
Begin
	if IsNull(@CityID_5,0) > 0
	Begin
		Select Top 1 @NewStateID = StateID from City Where CityID = @CityID_5
		Set @StateID_6 = @NewStateID
	End
End

 If Exists (Select VendorID From Vendors Where VendorID = @VendorID_1)    
 Begin    
  Update Vendors Set     
  [ContactPerson]=@ContactPerson_3,  [Address]=@Address_4,              
  [CityID]=@CityID_5,  [StateID]=@StateID_6,  [CountryID]=@CountryID_7,  [Zip]=@Zip_8,  [Fax]=@Fax_9,              
  [Phone]=@Phone_10,  [Email]=@Email_11,  [AlternateCode]=@AlternateCode, [Locality]=@Locality,            
  [ProductSupplied]=@ProductSupplied, [VendorRating]=@VendorRating, [SaleID]=@SaleID, [TNGST]=@TNGST, [CST]=@CST, [Payable_To]=@Payable_To,    
  [CreditTerm]=@CreditTerm, [TIN_Number]=@TINNUMBER, [PANNUMBER] = @PANNUMBER,
  [BillingStateID]=@BStateID , [GSTIN] = @GSTIN ,[IsRegistered] = @IsRegistered   
  Where VendorID = @VendorID_1    
 End    
 Else    
 Begin    
  INSERT INTO [Vendors]               
  ( [VendorID],  [Vendor_Name],  [ContactPerson],  [Address],              
  [CityID],  [StateID],  [CountryID],  [Zip],  [Fax],              
  [Phone],  [Email], [AlternateCode], [Locality], [ProductSupplied], [VendorRating], [SaleID], [TNGST], [CST],     
  [Payable_To], [CreditTerm],  [TIN_Number], [PANNUMBER],[BillingStateID], [GSTIN],[IsRegistered] )               
  VALUES               
  ( @VendorID_1, @Vendor_Name_2, @ContactPerson_3, @Address_4, @CityID_5, @StateID_6, @CountryID_7,              
    @Zip_8, @Fax_9, @Phone_10, @Email_11, @AlternateCode, @Locality, @ProductSupplied ,            
    @VendorRating, @SaleID, @TNGST, @CST, @Payable_To, @CreditTerm, @TINNUMBER, @PANNUMBER,
    @BStateID ,@GSTIN ,@IsRegistered )     
 End   
End    

