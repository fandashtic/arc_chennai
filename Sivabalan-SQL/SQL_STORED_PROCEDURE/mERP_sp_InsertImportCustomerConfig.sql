Create Procedure mERP_sp_InsertImportCustomerConfig
	(@MenuName nVarchar(255),
	 @Lock Int,
	 @iCustID nVarchar(255),
	 @iCustname nVarchar(255),
	 @iRCSID nVarchar(255),
	 @iCntPerson nVarchar(255),
	 @iCustcategory nVarchar(255),
	 @iBilladdr nVarchar(255),
	 @iShipAddr nVarchar(255),
	 @iCity nVarchar(255),
	 @iCountry nVarchar(255),
	 @iArea nVarchar(255),
	 @iDistrict nVarchar(255),
	 @iState nVarchar(255),
	 @iPhone nVarchar(255),
	 @iEmail nVarchar(255),
	 @iDL20 nVarchar(255),
	 @iDL21 nVarchar(255),
	 @iSTRegn nVarchar(255),
	 @iCST nVarchar(255),
	 @iCreditLimit nVarchar(255),
	 @iForumCode nVarchar(255),
	 @iChanneltype nVarchar(255),
	 @ibeat nVarchar(255),
	 @iDiscount nVarchar(255),
	 @iCreditrating nVarchar(255),
	 @iCreditterm nVarchar(255),
	 @iLocality nVarchar(255),
	 @iTinNumber nVarchar(255),
	 @iAltname nVarchar(255),
	 @iSubchannel nVarchar(255),
	 @itradeCustcategory nVarchar(255),
	 @iNoofBills nVarchar(255),
	 @itrkpoints nVarchar(255),
	 @iCollpoints nVarchar(255),
	 @iPinCode nVarchar(255),
	 @iResidence nVarchar(255),
	 @iMobile nVarchar(255),
	 @iPotential nVarchar(255)
)
As
   
	Declare @nidentity int 
    Insert into tbl_mERP_RecConfigAbstract(Menuname,flag, Status) values(@MenuName,@Lock, 0)             
    Select @nidentity= @@IDENTITY  


IF IsNull(@iCustID,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iCustID,1,charindex('|',@iCustID,1)-1),substring(@iCustID,charindex('|',@iCustID,1)+1,len(@iCustID)),0)
End 

IF IsNull(@iCustname,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iCustname,1,charindex('|',@iCustname,1)-1),substring(@iCustname,charindex('|',@iCustname,1)+1,len(@iCustname)),0)
End 
IF IsNull(@iRCSID,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iRCSID,1,charindex('|',@iRCSID,1)-1),substring(@iRCSID,charindex('|',@iRCSID,1)+1,len(@iRCSID)),0)
End 

IF IsNull(@iCntPerson,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iCntPerson,1,charindex('|',@iCntPerson,1)-1),substring(@iCntPerson,charindex('|',@iCntPerson,1)+1,len(@iCntPerson)),0)
End 

IF IsNull(@iCustcategory,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iCustcategory,1,charindex('|',@iCustcategory,1)-1),substring(@iCustcategory,charindex('|',@iCustcategory,1)+1,len(@iCustcategory)),0)
End 

IF IsNull(@iBilladdr,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iBilladdr,1,charindex('|',@iBilladdr,1)-1),substring(@iBilladdr,charindex('|',@iBilladdr,1)+1,len(@iBilladdr)),0)
End 

IF IsNull(@iShipAddr,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iShipAddr,1,charindex('|',@iShipAddr,1)-1),substring(@iShipAddr,charindex('|',@iShipAddr,1)+1,len(@iShipAddr)),0)
End 

IF IsNull(@iCity,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iCity,1,charindex('|',@iCity,1)-1),substring(@iCity,charindex('|',@iCity,1)+1,len(@iCity)),0)
End 

IF IsNull(@iCountry,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iCountry,1,charindex('|',@iCountry,1)-1),substring(@iCountry,charindex('|',@iCountry,1)+1,len(@iCountry)),0)
End 

IF IsNull(@iArea,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iArea,1,charindex('|',@iArea,1)-1),substring(@iArea,charindex('|',@iArea,1)+1,len(@iArea)),0)
End 

IF IsNull(@iDistrict,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iDistrict,1,charindex('|',@iDistrict,1)-1),substring(@iDistrict,charindex('|',@iDistrict,1)+1,len(@iDistrict)),0)
End 

IF IsNull(@iState,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iState,1,charindex('|',@iState,1)-1),substring(@iState,charindex('|',@iState,1)+1,len(@iState)),0)
End 

IF IsNull(@iPhone,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iPhone,1,charindex('|',@iPhone,1)-1),substring(@iPhone,charindex('|',@iPhone,1)+1,len(@iPhone)),0)
End 

IF IsNull(@iEmail,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iEmail,1,charindex('|',@iEmail,1)-1),substring(@iEmail,charindex('|',@iEmail,1)+1,len(@iEmail)),0)
End 

IF IsNull(@iDL20,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iDL20,1,charindex('|',@iDL20,1)-1),substring(@iDL20,charindex('|',@iDL20,1)+1,len(@iDL20)),0)
End 

IF IsNull(@iDL21,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iDL21,1,charindex('|',@iDL21,1)-1),substring(@iDL21,charindex('|',@iDL21,1)+1,len(@iDL21)),0)
End 

IF IsNull(@iSTRegn,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iSTRegn,1,charindex('|',@iSTRegn,1)-1),substring(@iSTRegn,charindex('|',@iSTRegn,1)+1,len(@iSTRegn)),0)
End 

IF IsNull(@iCST,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iCST,1,charindex('|',@iCST,1)-1),substring(@iCST,charindex('|',@iCST,1)+1,len(@iCST)),0)
End 

IF IsNull(@iCreditLimit,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iCreditLimit,1,charindex('|',@iCreditLimit,1)-1),substring(@iCreditLimit,charindex('|',@iCreditLimit,1)+1,len(@iCreditLimit)),0)
End 

IF IsNull(@iForumCode,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iForumCode,1,charindex('|',@iForumCode,1)-1),substring(@iForumCode,charindex('|',@iForumCode,1)+1,len(@iForumCode)),0)
End 


IF IsNull(@iChanneltype,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iChanneltype,1,charindex('|',@iChanneltype,1)-1),substring(@iChanneltype,charindex('|',@iChanneltype,1)+1,len(@iChanneltype)),0)
End 

IF IsNull(@ibeat,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@ibeat,1,charindex('|',@ibeat,1)-1),substring(@ibeat,charindex('|',@ibeat,1)+1,len(@ibeat)),0)
End 

IF IsNull(@iDiscount,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iDiscount,1,charindex('|',@iDiscount,1)-1),substring(@iDiscount,charindex('|',@iDiscount,1)+1,len(@iDiscount)),0)
End 

IF IsNull(@iCreditrating,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iCreditrating,1,charindex('|',@iCreditrating,1)-1),substring(@iCreditrating,charindex('|',@iCreditrating,1)+1,len(@iCreditrating)),0)
End 

IF IsNull(@iCreditterm,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iCreditterm,1,charindex('|',@iCreditterm,1)-1),substring(@iCreditterm,charindex('|',@iCreditterm,1)+1,len(@iCreditterm)),0)
End 

IF IsNull(@iLocality,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iLocality,1,charindex('|',@iLocality,1)-1),substring(@iLocality,charindex('|',@iLocality,1)+1,len(@iLocality)),0)
End 


IF IsNull(@iTinNumber,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iTinNumber,1,charindex('|',@iTinNumber,1)-1),substring(@iTinNumber,charindex('|',@iTinNumber,1)+1,len(@iTinNumber)),0)
End 

IF IsNull(@iAltname,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iAltname,1,charindex('|',@iAltname,1)-1),substring(@iAltname,charindex('|',@iAltname,1)+1,len(@iAltname)),0)
End 

IF IsNull(@iSubchannel,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iSubchannel,1,charindex('|',@iSubchannel,1)-1),substring(@iSubchannel,charindex('|',@iSubchannel,1)+1,len(@iSubchannel)),0)
End 

IF IsNull(@itradeCustcategory,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@itradeCustcategory,1,charindex('|',@itradeCustcategory,1)-1),substring(@itradeCustcategory,charindex('|',@itradeCustcategory,1)+1,len(@itradeCustcategory)),0)
End 

IF IsNull(@iNoofBills,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iNoofBills,1,charindex('|',@iNoofBills,1)-1),substring(@iNoofBills,charindex('|',@iNoofBills,1)+1,len(@iNoofBills)),0)
End 

IF IsNull(@itrkpoints,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@itrkpoints,1,charindex('|',@itrkpoints,1)-1),substring(@itrkpoints,charindex('|',@itrkpoints,1)+1,len(@itrkpoints)),0)
End 

IF IsNull(@iCollpoints,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iCollpoints,1,charindex('|',@iCollpoints,1)-1),substring(@iCollpoints,charindex('|',@iCollpoints,1)+1,len(@iCollpoints)),0)
End 

IF IsNull(@iPinCode,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iPinCode,1,charindex('|',@iPinCode,1)-1),substring(@iPinCode,charindex('|',@iPinCode,1)+1,len(@iPinCode)),0)
End 

IF IsNull(@iResidence,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iResidence,1,charindex('|',@iResidence,1)-1),substring(@iResidence,charindex('|',@iResidence,1)+1,len(@iResidence)),0)
End 

IF IsNull(@iMobile,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iMobile,1,charindex('|',@iMobile,1)-1),substring(@iMobile,charindex('|',@iMobile,1)+1,len(@iMobile)),0)
End 

IF IsNull(@iPotential,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag, Status) values(@nidentity,substring(@iPotential,1,charindex('|',@iPotential,1)-1),substring(@iPotential,charindex('|',@iPotential,1)+1,len(@iPotential)),0)
End
