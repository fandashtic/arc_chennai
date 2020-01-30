Create Procedure mERP_sp_InsertCustomerConfig
	(@MenuName nVarchar(255),
	 @Lock Int,
	 @ID nVarchar(255),
	 @Name nVarchar(255),
	 @ChannelDesc nVarchar(255),
	 @SubChannel nVarchar(255),
	 @Cntperson nVarchar(255),
	 @Catdesc nVarchar(255),
	 @BillAdd nVarchar(255),
	 @ShipAdd nVarchar(255),
	 @PinCode nVarchar(255),
	 @Beatdesc nVarchar(255),
	 @DefaultBeat nVarchar(255),
	 @AreaDesc nVarchar(255),
	 @CityDesc nVarchar(255),
	 @District nVarchar(255),
	 @StateDesc nVarchar(255),
	 @CountryDesc nVarchar(255),
	 @Phone nVarchar(255),
	 @Residence nVarchar(255),
	 @MobileNumber nVarchar(255),
	 @Discount nVarchar(255),
	 @AccType nVarchar(255),
	 @PayModeID nVarchar(255),
	 @Potential nVarchar(255),
	 @Alternate_Name nVarchar(255),
	 @Email nVarchar(255),
	 @DlNum nVarchar(255),
	 @dlnum21 nVarchar(255),
	 @TNGST nVarchar(255),
	 @CST nVarchar(255),
	 @TIN_NUMBER nVarchar(255),
	 @Forumcode nVarchar(255),
	 @Creditrating nVarchar(255),
	 @Locality nVarchar(255),
	 @TrackPoints nVarchar(255),
	 @CollectedPoints nVarchar(255),
	 @CategoryHandler nVarchar(255),
	 @CreditTerm nVarchar(255),
	 @Creditlimit nVarchar(255),
	 @NoOfBills nVarchar(255),
	 @CreditSplitUp nVarchar(255),
	 @RCSID nVarchar(255),
	 @MerchandType nVarchar(255),
	 @Field1 nVarchar(255),
	 @Field2 nVarchar(255),
	 @Field3 nVarchar(255),
	 @Field4 nVarchar(255),
	 @Field5 nVarchar(255),
	 @Field6 nVarchar(255),
	 @Field7 nVarchar(255),
	 @Field8 nVarchar(255),
	 @Field9 nVarchar(255),
	 @Field10 nVarchar(255),
	 @Field11 nVarchar(255),
	 @Field12 nVarchar(255),
	 @Field13 nVarchar(255), 
	 @Active nVarchar(255),
	 @SMSAlert nVarchar(255)
)
As
   
	Declare @nidentity int 
    Insert into tbl_mERP_RecConfigAbstract(Menuname,flag, sTATUS) values(@MenuName,@Lock,0)             
    Select @nidentity= @@IDENTITY  


IF IsNull(@ID,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@ID,1,charindex('|',@ID,1)-1),substring(@ID,charindex('|',@ID,1)+1,len(@ID)), 0)
End 
IF IsNull(@Name,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@Name,1,charindex('|',@Name,1)-1),substring(@Name,charindex('|',@Name,1)+1,len(@Name)),0)
End 
IF IsNull(@ChannelDesc,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@ChannelDesc,1,charindex('|',@ChannelDesc,1)-1),substring(@ChannelDesc,charindex('|',@ChannelDesc,1)+1,len(@ChannelDesc)),0)
End 
IF IsNull(@SubChannel,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@SubChannel,1,charindex('|',@SubChannel,1)-1),substring(@SubChannel,charindex('|',@SubChannel,1)+1,len(@SubChannel)),0)
End 

IF IsNull(@Cntperson,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Cntperson,1,charindex('|',@Cntperson,1)-1),substring(@Cntperson,charindex('|',@Cntperson,1)+1,len(@Cntperson)),0)
End 
IF IsNull(@Catdesc,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Catdesc,1,charindex('|',@Catdesc,1)-1),substring(@Catdesc,charindex('|',@Catdesc,1)+1,len(@Catdesc)),0)
End 

IF IsNull(@BillAdd,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@BillAdd,1,charindex('|',@BillAdd,1)-1),substring(@BillAdd,charindex('|',@BillAdd,1)+1,len(@BillAdd)),0)
End 

IF IsNull(@ShipAdd,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@ShipAdd,1,charindex('|',@ShipAdd,1)-1),substring(@ShipAdd,charindex('|',@ShipAdd,1)+1,len(@ShipAdd)),0)
End 

IF IsNull(@PinCode,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@PinCode,1,charindex('|',@PinCode,1)-1),substring(@PinCode,charindex('|',@PinCode,1)+1,len(@PinCode)),0)
End 

IF IsNull(@Beatdesc,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Beatdesc,1,charindex('|',@Beatdesc,1)-1),substring(@Beatdesc,charindex('|',@Beatdesc,1)+1,len(@Beatdesc)),0)
End 

IF IsNull(@DefaultBeat,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@DefaultBeat,1,charindex('|',@DefaultBeat,1)-1),substring(@DefaultBeat,charindex('|',@DefaultBeat,1)+1,len(@DefaultBeat)),0)
End 

IF IsNull(@AreaDesc,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@AreaDesc,1,charindex('|',@AreaDesc,1)-1),substring(@AreaDesc,charindex('|',@AreaDesc,1)+1,len(@AreaDesc)),0)
End 

IF IsNull(@CityDesc,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@CityDesc,1,charindex('|',@CityDesc,1)-1),substring(@CityDesc,charindex('|',@CityDesc,1)+1,len(@CityDesc)),0)
End 

IF IsNull(@District,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@District,1,charindex('|',@District,1)-1),substring(@District,charindex('|',@District,1)+1,len(@District)),0)
End 

IF IsNull(@StateDesc,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@StateDesc,1,charindex('|',@StateDesc,1)-1),substring(@StateDesc,charindex('|',@StateDesc,1)+1,len(@StateDesc)),0)
End 

IF IsNull(@CountryDesc,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@CountryDesc,1,charindex('|',@CountryDesc,1)-1),substring(@CountryDesc,charindex('|',@CountryDesc,1)+1,len(@CountryDesc)),0)
End 

IF IsNull(@Phone,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Phone,1,charindex('|',@Phone,1)-1),substring(@Phone,charindex('|',@Phone,1)+1,len(@Phone)),0)
End 

IF IsNull(@Residence,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Residence,1,charindex('|',@Residence,1)-1),substring(@Residence,charindex('|',@Residence,1)+1,len(@Residence)),0)
End 

IF IsNull(@MobileNumber,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@MobileNumber,1,charindex('|',@MobileNumber,1)-1),substring(@MobileNumber,charindex('|',@MobileNumber,1)+1,len(@MobileNumber)),0)
End 

IF IsNull(@Discount,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Discount,1,charindex('|',@Discount,1)-1),substring(@Discount,charindex('|',@Discount,1)+1,len(@Discount)),0)
End 


IF IsNull(@AccType,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@AccType,1,charindex('|',@AccType,1)-1),substring(@AccType,charindex('|',@AccType,1)+1,len(@AccType)),0)
End 

IF IsNull(@PayModeID,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@PayModeID,1,charindex('|',@PayModeID,1)-1),substring(@PayModeID,charindex('|',@PayModeID,1)+1,len(@PayModeID)),0)
End 

IF IsNull(@Potential,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Potential,1,charindex('|',@Potential,1)-1),substring(@Potential,charindex('|',@Potential,1)+1,len(@Potential)),0)
End 

IF IsNull(@Alternate_Name,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Alternate_Name,1,charindex('|',@Alternate_Name,1)-1),substring(@Alternate_Name,charindex('|',@Alternate_Name,1)+1,len(@Alternate_Name)),0)
End 

IF IsNull(@Email,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Email,1,charindex('|',@Email,1)-1),substring(@Email,charindex('|',@Email,1)+1,len(@Email)),0)
End 

IF IsNull(@DlNum,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@DlNum,1,charindex('|',@DlNum,1)-1),substring(@DlNum,charindex('|',@DlNum,1)+1,len(@DlNum)),0)
End 

IF IsNull(@dlnum21,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@dlnum21,1,charindex('|',@dlnum21,1)-1),substring(@dlnum21,charindex('|',@dlnum21,1)+1,len(@dlnum21)),0)
End 

IF IsNull(@TNGST,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@TNGST,1,charindex('|',@TNGST,1)-1),substring(@TNGST,charindex('|',@TNGST,1)+1,len(@TNGST)),0)
End 

IF IsNull(@CST,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@CST,1,charindex('|',@CST,1)-1),substring(@CST,charindex('|',@CST,1)+1,len(@CST)),0)
End 

IF IsNull(@TIN_NUMBER,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@TIN_NUMBER,1,charindex('|',@TIN_NUMBER,1)-1),substring(@TIN_NUMBER,charindex('|',@TIN_NUMBER,1)+1,len(@TIN_NUMBER)),0)
End 

IF IsNull(@Forumcode,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Forumcode,1,charindex('|',@Forumcode,1)-1),substring(@Forumcode,charindex('|',@Forumcode,1)+1,len(@Forumcode)),0)
End 

IF IsNull(@Creditrating,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Creditrating,1,charindex('|',@Creditrating,1)-1),substring(@Creditrating,charindex('|',@Creditrating,1)+1,len(@Creditrating)),0)
End 

IF IsNull(@Locality,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Locality,1,charindex('|',@Locality,1)-1),substring(@Locality,charindex('|',@Locality,1)+1,len(@Locality)),0)
End 

IF IsNull(@TrackPoints,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@TrackPoints,1,charindex('|',@TrackPoints,1)-1),substring(@TrackPoints,charindex('|',@TrackPoints,1)+1,len(@TrackPoints)),0)
End 

IF IsNull(@CollectedPoints,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@CollectedPoints,1,charindex('|',@CollectedPoints,1)-1),substring(@CollectedPoints,charindex('|',@CollectedPoints,1)+1,len(@CollectedPoints)),0)
End 

IF IsNull(@CategoryHandler,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@CategoryHandler,1,charindex('|',@CategoryHandler,1)-1),substring(@CategoryHandler,charindex('|',@CategoryHandler,1)+1,len(@CategoryHandler)),0)
End 

IF IsNull(@CreditTerm,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@CreditTerm,1,charindex('|',@CreditTerm,1)-1),substring(@CreditTerm,charindex('|',@CreditTerm,1)+1,len(@CreditTerm)),0)
End

IF IsNull(@Creditlimit,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Creditlimit,1,charindex('|',@Creditlimit,1)-1),substring(@Creditlimit,charindex('|',@Creditlimit,1)+1,len(@Creditlimit)),0)
End

IF IsNull(@NoOfBills,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@NoOfBills,1,charindex('|',@NoOfBills,1)-1),substring(@NoOfBills,charindex('|',@NoOfBills,1)+1,len(@NoOfBills)),0)
End 

IF IsNull(@CreditSplitUp,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@CreditSplitUp,1,charindex('|',@CreditSplitUp,1)-1),substring(@CreditSplitUp,charindex('|',@CreditSplitUp,1)+1,len(@CreditSplitUp)),0)
End

IF IsNull(@RCSID,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@RCSID,1,charindex('|',@RCSID,1)-1),substring(@RCSID,charindex('|',@RCSID,1)+1,len(@RCSID)),0)
End

IF IsNull(@MerchandType,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@MerchandType,1,charindex('|',@MerchandType,1)-1),substring(@MerchandType,charindex('|',@MerchandType,1)+1,len(@MerchandType)),0)
End

IF IsNull(@Field1,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field1,1,charindex('|',@Field1,1)-1),substring(@Field1,charindex('|',@Field1,1)+1,len(@Field1)),0)
End

IF IsNull(@Field2,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field2,1,charindex('|',@Field2,1)-1),substring(@Field2,charindex('|',@Field2,1)+1,len(@Field2)),0)
End

IF IsNull(@Field3,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field3,1,charindex('|',@Field3,1)-1),substring(@Field3,charindex('|',@Field3,1)+1,len(@Field3)),0)
End

IF IsNull(@Field4,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field4,1,charindex('|',@Field4,1)-1),substring(@Field4,charindex('|',@Field4,1)+1,len(@Field4)),0)
End

IF IsNull(@Field5,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field5,1,charindex('|',@Field5,1)-1),substring(@Field5,charindex('|',@Field5,1)+1,len(@Field5)),0)
End

IF IsNull(@Field6,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field6,1,charindex('|',@Field6,1)-1),substring(@Field6,charindex('|',@Field6,1)+1,len(@Field6)),0)
End

IF IsNull(@Field7,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field7,1,charindex('|',@Field7,1)-1),substring(@Field7,charindex('|',@Field7,1)+1,len(@Field7)),0)
End

IF IsNull(@Field8,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field8,1,charindex('|',@Field8,1)-1),substring(@Field8,charindex('|',@Field8,1)+1,len(@Field8)),0)
End

IF IsNull(@Field9,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field9,1,charindex('|',@Field9,1)-1),substring(@Field9,charindex('|',@Field9,1)+1,len(@Field9)),0)
End

IF IsNull(@Field10,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field10,1,charindex('|',@Field10,1)-1),substring(@Field10,charindex('|',@Field10,1)+1,len(@Field10)),0)
End

IF IsNull(@Field11,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field11,1,charindex('|',@Field11,1)-1),substring(@Field11,charindex('|',@Field11,1)+1,len(@Field11)),0)
End

IF IsNull(@Field12,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field12,1,charindex('|',@Field12,1)-1),substring(@Field12,charindex('|',@Field12,1)+1,len(@Field12)),0)
End

IF IsNull(@Field13,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field13,1,charindex('|',@Field13,1)-1),substring(@Field13,charindex('|',@Field13,1)+1,len(@Field13)),0)
End
IF IsNull(@Active,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Active,1,charindex('|',@Active,1)-1),substring(@Active,charindex('|',@Active,1)+1,len(@Active)), 0)  
End   
IF IsNull(@SMSAlert,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@SMSAlert,1,charindex('|',@SMSAlert,1)-1),substring(@SMSAlert,charindex('|',@SMSAlert,1)+1,len(@SMSAlert)), 0)  
End   
