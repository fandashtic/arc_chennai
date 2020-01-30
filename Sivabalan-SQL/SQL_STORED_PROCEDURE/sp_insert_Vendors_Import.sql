Create  PROCEDURE [sp_insert_Vendors_Import]            
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
  @PANNO Nvarchar(15) = N''       
)          
            
AS   
  If Exists (Select VendorID From Vendors Where VendorID = @VendorID_1)  
   Begin  
 Update Vendors Set   
 [ContactPerson]=@ContactPerson_3,  [Address]=@Address_4,            
 [CityID]=@CityID_5,  [StateID]=@StateID_6,  [CountryID]=@CountryID_7,  [Zip]=@Zip_8,  [Fax]=@Fax_9,            
 [Phone]=@Phone_10,  [Email]=@Email_11,  [AlternateCode]=@AlternateCode, [Locality]=@Locality,          
 [ProductSupplied]=@ProductSupplied, [VendorRating]=@VendorRating, [SaleID]=@SaleID, [TNGST]=@TNGST, [CST]=@CST, [Payable_To]=@Payable_To,  
 [CreditTerm]=@CreditTerm, [TIN_Number]=@TINNUMBER ,[PanNumber] =  @PANNO
 Where VendorID = @VendorID_1  
   End  
   Else  
   Begin   
 INSERT INTO [Vendors]             
 ( [VendorID],  [Vendor_Name],  [ContactPerson],  [Address],            
 [CityID],  [StateID],  [CountryID],  [Zip],  [Fax],            
 [Phone],  [Email], [AlternateCode], [Locality], [ProductSupplied], [VendorRating], [SaleID], [TNGST], [CST],   
 [Payable_To], [CreditTerm],  [TIN_Number],[PanNumber])             
 VALUES             
 ( @VendorID_1, @Vendor_Name_2, @ContactPerson_3, @Address_4, @CityID_5, @StateID_6, @CountryID_7,            
   @Zip_8, @Fax_9, @Phone_10, @Email_11, @AlternateCode, @Locality, @ProductSupplied ,          
   @VendorRating, @SaleID, @TNGST, @CST, @Payable_To, @CreditTerm, @TINNUMBER,@PANNO)   
 End  
