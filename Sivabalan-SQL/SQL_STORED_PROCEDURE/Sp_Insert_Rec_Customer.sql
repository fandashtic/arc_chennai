CREATE Procedure Sp_Insert_Rec_Customer                        
(@CustomerID nvarchar(15),@Company_Name nvarchar(128),@ContactPerson nvarchar(255),                        
@CustomerCategory nvarchar(50),@BillingAddress nvarchar(255),@ShippingAddress nvarchar(255),                        
@City nvarchar(50),@State nvarchar(50),@Country nvarchar(50),@Area nvarchar(50),@Phone nvarchar(50),                        
@EMail nvarchar(50),@Discount Decimal(18,6),@TNGST nvarchar(50),@CreditType int,@CreditTerm nvarchar(50),                              
@CreditValue int,@DLNumber21 nvarchar(50),@CST nvarchar(50),@CreditLimit Decimal(18,6),                          
@ForumCode nvarchar(40),@CreditRating int,@ChannelType nvarchar(128),@Locality int,                        
@PaymentMode int,@CreationDate datetime,@BranchForumCode nvarchar(6),@Active int,                        
@Status int,@DLNumber20 nvarchar(100),@Beat nvarchar(128),@Customer_Password nvarchar(20) =NULL,                        
@District nvarchar(100)=NULL, @TownClassify int=0, @TIN_NUMBER nvarchar(100)=NULL,                     
@Alternate_Name nvarchar(100)=NULL,@SubChannel nvarchar(100)=NULL, @Potential nvarchar(100)=NULL, @Residence nvarchar(100)=NULL,                    
@DOB1 DateTime = NULL, @ReferredBy nvarchar(100) = NULL, @MembershipCode nvarchar(100) = NULL,                        
@Fax nvarchar(100) = NULL, @RetailCategory nvarchar(250) = NULL, @Salutation nvarchar(100) = NULL,                        
@FirstName nvarchar(200) = NULL, @SecondName  nvarchar(200) = NULL, @PinCode nvarchar(50) = NULL,                        
@Occupation nvarchar(100) = NULL, @Awareness nvarchar(4000) = NULL, @MobileNumber nvarchar(50) = NULL,                        
@CitySTDCode nvarchar(50) = NULL, 
@RCSID nVarChar(255)=NULL,
@UpdateStatus nVarChar(255)=NULL,       
@MerchandiseType nVarChar(4000)=NULL,       
@Field1 nVarChar(255)=NULL,
@Field2 nVarChar(255)=NULL,
@Field3 nVarChar(255)=NULL,
@Field4 nVarChar(255)=NULL,       
@Field5 nVarChar(255)=NULL,
@Field6 nVarChar(255)=NULL,
@Field7 nVarChar(255)=NULL,
@Field8 nVarChar(255)=NULL,
@Field9 nVarChar(255)=NULL,
@Field10 nVarChar(255)=NULL,
@Field11 nVarChar(255)=NULL,
@Field12 nVarChar(255)=NULL,
@Field13 nVarChar(255)=NULL,       
@SequenceNo decimal(18,6)=NULL,          
@TrackPoints int=NULL,          
@CollectedPoints decimal(18,6)=NULL,              
@SegCode nvarchar(255)='',
@Zone nVarchar(255)=Null
,@Channel_Type nVarchar(255),
@Outlet_Type nVarchar(255),
@Loyalty_Type nVarchar(255),
@Menu nVarchar(255),
@User_Name nVarchar(255),
@OMSLock nVarchar(255)
)                              
as                        
Declare @DOB datetime                      
Declare @segID as int        
Select @segID=Isnull(SegmentID,N'') From ReceivedSegments Where SegmentCode=@SegCode        
Set DateFormat DMY          
If IsNull(@MembershipCode,N'') = N''                      
Set @DOB = NUll                
Else                  
Set @DOB = dbo.StripDateFromTime(@DOB1)     


             
INSERT INTO RECEIVEDCUSTOMERS                        
(CUSTOMERID,COMPANY_NAME,CONTACTPERSON,CUSTOMERCATEGORY,                        
BILLINGADDRESS,SHIPPINGADDRESS,CITY,STATE,COUNTRY,AREA,                        
PHONE,EMAIL,DISCOUNT,TNGST,CREDITTYPE,CREDITTERM,                        
CREDITVALUE,DLNUMBER21,CST,CREDITLIMIT,FORUMCODE,                        
CREDITRATING,CHANNELTYPE,LOCALITY,PAYMENTMODE,CREATIONDATE,                        
BRANCHFORUMCODE,ACTIVE,STATUS,DLNUMBER20,BEAT,CUSTOMER_PASSWORD,                        
District, TownClassify, TIN_NUMBER, Alternate_Name,                    
SubChannel, Potential, Residence,                    
DOB, ReferredBy, MembershipCode, Fax, RetailCategory,                        
Salutation, FirstName, SecondName, PinCode,                        
Occupation, Awareness, MobileNumber, CitySTDCode,SequenceNo,TrackPoints,CollectedPoints,SegmentID, RCSID, UpdateStatus, MerchandiseType, 
Field1, Field2, Field3, Field4, Field5, Field6, Field7, Field8, Field9, Field10, Field11, Field12, Field13
,Channel_type,Outlet_type,Loyalty_Type,Menu,User_Name,OMSLock
)                        
VALUES(@CustomerID,@Company_Name,@ContactPerson,                        
@CustomerCategory,@BillingAddress,@ShippingAddress,                        
@City,@State,@Country,@Area,@Phone,@EMail,@Discount,                        
@TNGST,@CreditType,@CreditTerm,@CreditValue,@DLNumber21,@CST,@CreditLimit,                          
@ForumCode,@CreditRating,@ChannelType,@Locality,                        
@PaymentMode,@CreationDate,@BranchForumCode,@Active,                        
@Status,@DLNumber20,@Beat,@Customer_Password,                        
@District, @TownClassify, @TIN_NUMBER, @Alternate_Name,                    
@SubChannel, @Potential, @Residence,                    
@DOB, @ReferredBy, @MembershipCode, @Fax, @RetailCategory,                        
@Salutation, @FirstName, @SecondName, @PinCode,                        
@Occupation, @Awareness, @MobileNumber, @CitySTDCode,@SequenceNo,@TrackPoints,@CollectedPoints,@segID, @RCSID, @UpdateStatus, @MerchandiseType, 
@Field1, @Field2, @Field3, @Field4, @Field5, @Field6, @Field7, @Field8, @Field9, @Field10, @Field11, @Field12, @Field13
,@Channel_type,@Outlet_type,@Loyalty_Type,@Menu,@User_Name,@OMSLock
)                   
                       
SELECT @@IDENTITY   
  
