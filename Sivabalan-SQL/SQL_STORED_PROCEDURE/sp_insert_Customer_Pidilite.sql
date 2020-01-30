Create procedure [sp_insert_Customer_Pidilite]          
 (@CustomerID_1  [nvarchar](15),          
  @Company_Name_2  [nvarchar](128),          
  @ContactPerson_3  [nvarchar](255),          
  @CustomerCategory_4  int,          
  @BillingAddress_5  [nvarchar](255),          
  @ShippingAddress_6  [nvarchar](255),          
  @AreaID_7   int,            
  @CityID_8  int,          
  @StateID_9              int,          
  @CountryID_10  int,          
  @Phone_11  [nvarchar](50),          
  @Email_12  [nvarchar](50),          
  @UnUsed  int,          
  @Beat_13  int,          
  @Discount_14 Decimal(18,6),          
  @DLNumber_15 [nvarchar](50),          
  @TNGSTNumber_16 [nvarchar] (50),          
  @CreditTerm_17 int,          
  @DLNumber_18 [nvarchar] (50),          
  @CSTNumber nvarchar(50),          
  @CreditLimit Decimal(18,6),          
  @AlternateCode nvarchar(20),          
  @CreditRating nvarchar(50),          
  @ChannelType int,          
  @Locality int,          
  @Payment_mode int,        
  @AutoSc int=0,        
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
  @TradeCategoryID Int=null,    
  @AddDiscInCollection Decimal(18,6) = 0)        
AS          
 INSERT INTO [Customer]           
  ( [CustomerID],          
  [Company_Name],          
  [ContactPerson],          
  [CustomerCategory],          
  [BillingAddress],          
  [ShippingAddress],          
  [AreaID],          
  [CityID],          
  [StateID],          
  [CountryID],          
  [Phone],          
  [Email],          
  [Discount],          
  [DLNumber],          
  [TNGST],          
  [CreditTerm],          
  [DLNumber21],          
  [CST],          
  [CreditLimit],          
  [AlternateCode],          
  [CreditRating],          
  [ChannelType],          
  [Locality],          
  [Payment_Mode],        
  [Customer_Password],        
  [District],        
  [TownClassify],        
  [AccountType],        
  [SequenceNo],        
  [TIN_Number],        
  [Alternate_Name],        
  [TrackPoints],        
  [CollectedPoints],        
  [SubChannelID],        
  [Potential],        
  [MobileNumber],        
  [Residence],      
  [PinCode],      
  [TradeCategoryID],    
  [AddCollDiscPercentage])           
VALUES           
 (@CustomerID_1,          
  @Company_Name_2,          
  @ContactPerson_3,          
  @CustomerCategory_4,          
  @BillingAddress_5,          
  @ShippingAddress_6,          
  @AreaID_7,          
  @CityID_8,          
  @StateID_9,          
  @CountryID_10,          
  @Phone_11,          
  @Email_12,          
  @Discount_14,          
  @DLNumber_15,          
  @TNGSTNumber_16,          
  @CreditTerm_17,          
  @DLNumber_18,          
  @CSTNumber,          
  @CreditLimit,          
  @AlternateCode,          
  @CreditRating,          
  @ChannelType,          
  @Locality,          
  @Payment_mode,        
  @Password,        
  @District,        
  @Town,        
  @AccountType,        
  @SequenceNo,        
  @TINNUMBER,        
  @AlternateName,        
  @TrackPoints,        
  @CollectedPoints,        
  @SubChannelID,        
  @Potential,        
  @MobileNumber,        
  @Residence,      
  @PinCode,      
  @TradeCategoryID,    
  @AddDiscInCollection)         
