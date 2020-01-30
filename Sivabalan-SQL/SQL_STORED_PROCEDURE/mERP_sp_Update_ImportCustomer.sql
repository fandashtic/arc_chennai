Create ProceduRe mERP_sp_Update_ImportCustomer(
@CustomerID nVarchar(500),
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
@CreditTerm Int,
@Locality Int,
@TIN_Number nVarchar(100),
@Alternate_Name nVarchar(500),
@District Int,
@Pincode nVarchar(100),
@Potential nVarchar(200),
@Residence nVarchar(100),
@MobileNumber nVarchar(100),
@SubChannelID Int,
@NoOfBillsOutstanding Int,
@ZoneID Int = 0,
@Version nVarchar(10) = N''
--,@BStateID Int = 0,
--@SStateID Int = 0,
--@GSTIN nVarChar(15) = N'',
--@IsRegistered int = 0
)
As
Begin
	Declare @SQL as nVarchar(4000)
	Declare @ScreenCode as nVarchar(255)
	Declare @IsGSTEnabled as int
	
	--Select @IsGSTEnabled = ISNULL(Flag,0) from tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled' and ScreenName ='GSTaxEnabled'
	
	If @Version = 'CUG'
	Begin

		
		Select @ScreenCode = ScreenCode from tbl_mERP_ConfigAbstract 
		Where ScreenName = 'Import Customer Modify'
		
		Set @SQL = 'Update Customer Set '
		
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'ContactPerson'),-1) <> 0 And @ContactPerson <> ''
			Set @SQL = @SQL + 'ContactPerson = ' + '''' +  @ContactPerson + '''' + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'CustomerCategory'),-1) <> 0 And @CustomerCategory <> 0
			Set @SQL = @SQL + 'CustomerCategory = ' +  Cast(@CustomerCategory as nVarchar) + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'BillingAddress'),-1) <> 0 And @BillingAddress <> ''
			Set @SQL = @SQL + 'BillingAddress = ' + '''' + @BillingAddress + '''' + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'ShippingAddress'),-1) <> 0 And @ShippingAddress <> ''
			Set @SQL = @SQL + 'ShippingAddress = ' + '''' + @ShippingAddress + '''' + ','
		
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'CityID'),-1) <> 0 And @CityId <> 0
			Set @SQL = @SQL + 'CityID = ' + Cast(@CityId As nVarchar) + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'CountryID'),-1) <> 0 And @CountryID <> 0
			Set @SQL = @SQL + 'CountryID =' + Cast(@CountryID As nVarchar) + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'AreaID'),-1) <> 0 And @AreaID <> 0
			Set @SQL = @SQL + 'AreaID = ' + Cast(@AreaID AS nVarchar)  + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'StateID'),-1) <> 0 And @StateID <> 0
			Set @SQL = @SQL + 'StateID = ' + Cast(@StateID AS nVarchar) + ','


		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'Phone'),-1) <> 0 And @Phone <> ''
			Set @SQL = @SQL + 'Phone = ' + '''' + @Phone  + '''' + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'Email'),-1) <> 0 And @Email <> ''
			Set @SQL = @SQL + 'Email = ' + '''' + @Email + '''' + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'DLNumber'),-1) <> 0 And @DLNumber <> ''
			Set @SQL = @SQL + 'DLNumber = '+  '''' + @DLNumber  + '''' + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'DLNumber21'),-1) <> 0 And @DLNumber21 <>  '' 
			Set @SQL = @SQL + 'DLNumber21 = ' +  '''' + @DLNumber21 + '''' + ','
		
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'TNGST'),-1) <> 0 And @TNGST <> ''
			Set @SQL = @SQL + 'TNGST = ' + '''' + @TNGST +  '''' + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'CST'),-1) <> 0 And @CST <> ''
			Set @SQL = @SQL + 'CST = ' + '''' +  @CST +  '''' + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'CreditLimit'),-1) <> 0 And @CreditLimit <> 0
			Set @SQL = @SQL + 'CreditLimit = ' +  Cast(@CreditLimit  As nVarchar)  +   ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'AlternateCode'),-1) <> 0 And @AlternateCode <> ''
			Set @SQL = @SQL + 'AlternateCode = ' + '''' + @AlternateCode +  '''' + ','


		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'ChannelType'),-1) <> 0 And @ChannelType <> 0
			Set @SQL = @SQL + 'ChannelType = ' + Cast(@ChannelType  as nVarchar) + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'Discount'),-1) <> 0 And @Discount <> 0
			Set @SQL = @SQL + 'Discount = ' + Cast(@Discount as nVarchar) + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'CreditTerm'),-1) <> 0 And @CreditTerm <> 0
			Set @SQL = @SQL + 'CreditTerm = ' + Cast(@CreditTerm as nVarchar) + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'Locality'),-1) <> 0 And @Locality <> 0
			Set @SQL = @SQL + 'Locality =  ' + Cast(@Locality as nVarchar) + ','
		
		

		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'TIN_Number'),-1) <> 0 And @TIN_Number <> ''
			Set @SQL = @SQL + 'TIN_Number = ' + '''' + @TIN_Number  + '''' + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'Alternate_Name'),-1) <> 0 And @Alternate_Name <> ''
			Set @SQL = @SQL + 'Alternate_Name = ' + '''' +  @Alternate_Name + '''' + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'District'),-1) <> 0 And isNUll(@District,0) <> 0
			Set @SQL = @SQL + 'District = ' + Cast(@District As nVarchar) + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'Pincode'),-1) <> 0 And @Pincode <> ''
			Set @SQL = @SQL + 'Pincode = ' + '''' +  @Pincode +  '''' + ','


		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'Potential'),-1) <> 0 And @Potential <> ''
			Set @SQL = @SQL + 'Potential =  ' + '''' +  @Potential + '''' +  ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'Residence'),-1) <> 0 And @Residence <> ''
			Set @SQL = @SQL + 'Residence = ' + '''' +  @Residence + '''' +  ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'MobileNumber'),-1) <> 0 And @MobileNumber <> ''
			Set @SQL = @SQL + 'MobileNumber = ' +  '''' +  @MobileNumber + '''' +  ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'SubChannelID'),-1) <> 0 And @SubChannelID <> 0
			Set @SQL = @SQL + 'SubChannelID =' +  Cast(@SubChannelID As nVarchar) + ','
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'NoOfBillsOutstanding'),-1) <> 0 And @NoOfBillsOutstanding <> 0
			Set @SQL = @SQL + 'NoOfBillsOutstanding = ' + Cast(@NoOfBillsOutstanding as nVarchar)  + ','
		
		If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'Zone'),-1) <> 0 
			Set @SQL = @SQL + 'ZoneID = ' + Cast(@ZoneID as nVarchar)  
		
		--If @IsGSTEnabled = 1
		--Begin
			--Set @SQL = @SQL + ',' + 'BillingStateID = ' + Cast(@BStateID as nVarchar)  + ','
			--Set @SQL = @SQL + 'ShippingStateID = ' + Cast(@SStateID as nVarchar)  + ','			
			--Set @SQL = @SQL + 'GSTIN = ' +  '''' +  @GSTIN + '''' + ','
			--Set @SQL = @SQL + '[IsRegistered] = ' + Cast(@IsRegistered as nVarchar) 
							
		--End	
		
		IF Substring(@SQL,len(@SQL),1) = ','
		Set @SQL = Substring(@SQL,1,len(@SQL) - 1)
		Set @SQL = @SQL + ' Where CustomerID = '  +  '''' + @CustomerID + ''''
			
		Exec sp_ExecuteSql @SQL
		
	End
	Else
	Begin
		update Customer set ContactPerson = @ContactPerson, CustomerCategory = @CustomerCategory, BillingAddress= @BillingAddress, 
		                ShippingAddress = @ShippingAddress, CityId = @CityId , CountryId = @CountryId , AreaID = @AreaID,
						StateID = @StateID, Phone = @Phone, Email = @Email, DLNumber =  @DLNumber, DLNumber21 = @DLNumber21, 
						TNGST = @TNGST, CST =@CST , CreditLimit = @CreditLimit, AlternateCode = @AlternateCode , 
						ChannelType = @ChannelType, Discount = @Discount, CreditTerm = @CreditTerm, 
						Locality = @Locality , TIN_Number = @TIN_Number, Alternate_Name = @Alternate_Name,
						District = @District, Pincode = @Pincode, Potential = @Potential, 
						Residence = @Residence, MobileNumber = @MobileNumber, SubChannelID = @SubChannelID,
						NoOfBillsOutstanding =  @NoOfBillsOutstanding,ZoneID = @ZoneID
						--,BillingStateID = @BStateID, ShippingStateID = @SStateID, GSTIN = @GSTIN, [IsRegistered] = @IsRegistered  
						where CustomerID= @CustomerID
	End
--OMS Changes...
		Declare @SrvrName nVarchar(50)
		Declare @AEActivityID int 
		Declare @AELogID int
		Declare @IPAddress as Nvarchar(255)
		Select @SrvrName = @@ServerName
		Declare	@LoginUser Nvarchar(255)
		Select @LoginUser = (select RegisteredOwner from setup) + 'MERP'
--		Declare @ip varchar(40)
--		Exec Sp_GetIP @ip out
		Select @IPAddress = ''
		exec mERP_sp_Insert_AEActivity @LoginUser,'9',@SrvrName,@LoginUser,@IPAddress,2
		Select @AEActivityID = @@Identity
		exec mERP_sp_Insert_AEActivity_Log @LoginUser,'9','IMPORT MODIFY CUSTOMER',@AEActivityID,'IMPORT MODIFY CUSTOMER'
		select @@Identity
		Update tbl_mERP_AEActivity Set AEAuditLogID = @AEActivityID Where ID  = @AEActivityID
		Update Customer_Type_Log Set Active = 0 Where CustomerID = @CustomerID And Active = 1        
		iNSERT INTO Customer_Type_Log (AEAuditlogID,CustomerID,Active) Values (@AEActivityID,@CustomerID,1)
		exec mERP_sp_Update_AEActivity @LoginUser,'1',@SrvrName
End

