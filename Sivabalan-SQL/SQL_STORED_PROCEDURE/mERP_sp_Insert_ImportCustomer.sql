CREATE Procedure mERP_sp_Insert_ImportCustomer(
@CustomerID nVarchar(500),
@Company_Name nVarchar(500),
@ContactPerson nVarchar(500),
@CustomerCategory Int,
@BillingAddress nVarchar(500),
@ShippingAddress nVarchar(500),
@CityId Int,
@CountryId Int,
@AreaID Int,
@StateID Int,
@Phone nVarchar(100),
@Email nVarchar(500),
@DLNumber nVarchar(100),
@DLNumber21 nVarchar(100),
@TNGST nVarchar(100),
@CST nVarchar(100),
@CreditLimit Decimal(18,6),
@AlternateCode nVarchar(40),
@ChannelType Int,
@Discount Decimal(18,6),
@CreditRating Int,
@CreditTerm Int,
@Locality Int,
@TIN_Number nVarchar(100),
@Alternate_Name nVarchar(500),
@TrackPoints Int,
@CollectedPoints Int,
@District Int,
@Pincode nVarchar(100),
@Potential nVarchar(200),
@Residence nVarchar(100),
@MobileNumber nVarchar(100),
@SubChannelID Int,
@TradeCategoryID Int,
@NoOfBillsOutstanding Int,
@ZoneID Int = 0,
@Version nVarchar(10) = N''
--,@BStateID Int = 0,
--@SStateID Int = 0,
--@GSTIN nVarChar(15) = N'',
--@IsRegistered int = 0
,@RCSOutletID nVarchar(50) = N''
)
As
Begin
	Declare @ScreenCode as nVarchar(255)
	If @Version = 'CUG' 
	Begin
	
		Select @ScreenCode = ScreenCode from tbl_mERP_ConfigAbstract 
		Where ScreenName = 'Import Customer Add'
	
		insert into Customer(CustomerId,Company_Name,ContactPerson,CustomerCategory,BillingAddress,ShippingAddress,
				CityId,CountryId,AreaId,StateId,Phone,Email,DLNumber,DLNumber21,TNGST,CST,CreditLimit,AlternateCode,ChannelType,
				Discount,CreditRating,CreditTerm,Locality, TIN_Number, Alternate_Name, TrackPoints, CollectedPoints, District, 
				PinCode, Potential, Residence, MobileNumber, SubChannelID,TradeCategoryID,NoOfBillsOutstanding,ZoneID,RCSOutletID)
				--,BillingStateID,ShippingStateID,GSTIN,[IsRegistered])
		Values
				(@CustomerID, @Company_Name,@ContactPerson ,@CustomerCategory ,@BillingAddress ,@ShippingAddress ,@CityId ,
				@CountryId ,@AreaID ,@StateID ,@Phone ,@Email ,@DLNumber ,@DLNumber21 ,@TNGST ,@CST ,@CreditLimit ,
				@AlternateCode ,@ChannelType ,@Discount ,@CreditRating ,@CreditTerm ,@Locality ,@TIN_Number ,@Alternate_Name ,
				@TrackPoints ,@CollectedPoints ,@District ,@Pincode ,@Potential ,@Residence ,@MobileNumber ,@SubChannelID ,
				@TradeCategoryID ,@NoOfBillsOutstanding,@ZoneID,@RCSOutletID) --,@BStateID,@SStateID,@GSTIN,@IsRegistered)

		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'Trackkpoints'),-1) <> 0 
		Begin
			Update Customer Set TrackPoints = @TrackPoints Where CustomerID = @CustomerID
			Update Customer Set CollectedPoints = @CollectedPoints Where CustomerID = @CustomerID	
		End


	End
	Else
	Begin
			insert into Customer(CustomerId,Company_Name,ContactPerson,CustomerCategory,BillingAddress,ShippingAddress,
				CityId,CountryId,AreaId,StateId,Phone,Email,DLNumber,DLNumber21,TNGST,CST,CreditLimit,AlternateCode,ChannelType,
				Discount,CreditRating,CreditTerm,Locality, TIN_Number, Alternate_Name, TrackPoints, CollectedPoints, District, 
				PinCode, Potential, Residence, MobileNumber, SubChannelID,TradeCategoryID,NoOfBillsOutstanding,ZoneID,RCSOutletID)
				--,BillingStateID,ShippingStateID,GSTIN,[IsRegistered])
			Values
				(@CustomerID, @Company_Name,@ContactPerson ,@CustomerCategory ,@BillingAddress ,@ShippingAddress ,@CityId ,
				@CountryId ,@AreaID ,@StateID ,@Phone ,@Email ,@DLNumber ,@DLNumber21 ,@TNGST ,@CST ,@CreditLimit ,
				@AlternateCode ,@ChannelType ,@Discount ,@CreditRating ,@CreditTerm ,@Locality ,@TIN_Number ,@Alternate_Name ,
				@TrackPoints ,@CollectedPoints ,@District ,@Pincode ,@Potential ,@Residence ,@MobileNumber ,@SubChannelID ,
				@TradeCategoryID ,@NoOfBillsOutstanding ,@ZoneID,@RCSOutletID)--,@BStateID,@SStateID,@GSTIN,@IsRegistered)
	End
--OMS Changes...
		Declare @SrvrName nVarchar(255)
		Declare @AEActivityID int 
		Declare @AELogID int
		Declare @IPAddress as Nvarchar(255)
		Select @SrvrName = @@ServerName
		Declare	@LoginUser Nvarchar(255)
		Select @LoginUser = (select RegisteredOwner from setup) + 'MERP'
--		Declare @ip varchar(40)
--		Exec Sp_GetIP @ip out
		Select @IPAddress = ''
		exec mERP_sp_Insert_AEActivity @LoginUser,'8',@SrvrName,@LoginUser,@IPAddress,2
		Select @AEActivityID = @@Identity
		exec mERP_sp_Insert_AEActivity_Log @LoginUser,'8','IMPORT ADD CUSTOMER',@AEActivityID,'IMPORT ADD CUSTOMER'
		select @@Identity
		Update tbl_mERP_AEActivity Set AEAuditLogID = @AEActivityID Where ID  = @AEActivityID
		Update Customer_Type_Log Set Active = 0 Where CustomerID = @CustomerID And Active = 1        
		iNSERT INTO Customer_Type_Log (AEAuditlogID,CustomerID,Active) Values (@AEActivityID,@CustomerID,1)
		exec mERP_sp_Update_AEActivity @LoginUser,'1',@SrvrName
End
