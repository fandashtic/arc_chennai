CREATE Procedure [dbo].[mERP_sp_UpgradeScripts]
AS 
BEGIN
-- Script for Quotation existing Data manipulate
--declare @QuoId as int
--deClare @QuoLevel as int
--declare Cur_Quo Cursor for
--select QuotationID,QuotationType from QuotationAbstract 
--where QuotationSubType is null and QuotationLevel is null and UOMConversion is null
--Open Cur_Quo
--Fetch from Cur_Quo into @QuoId,@QuoLevel
--While @@FETCH_STATUS=0
--Begin
--	if @QuoLevel=1 or @QuoLevel=2 
--    Begin
--		if @QuoLevel=1 
--        Begin
--			Update QuotationAbstract set QuotationType=3,QuotationSubType=1,QuotationLevel=1,UOMConversion=1, AllowInvoiceScheme = 1
--			Where QuotationID=@QuoId
--            Update QuotationItems set AllowScheme=1 where QuotationID=@QuoId  
--        End
--        Else if @QuoLevel=2
--        Begin
--            Update QuotationAbstract set QuotationType=3,QuotationSubType=2,QuotationLevel=2,UOMConversion=0, AllowInvoiceScheme = 1
--			Where QuotationID=@QuoId
--            Update QuotationMfrCategory set AllowScheme=1 where QuotationID=@QuoId
--        End
--	End 
--    Else
--		Update QuotationAbstract set Active=0
--        Where QuotationID=@QuoId  
--
--	Fetch from Cur_Quo into @QuoId,@QuoLevel	
--End
--Close Cur_Quo
--Deallocate Cur_Quo


-- Script for DeliveryDate
--Update InvoiceAbstract Set DeliveryDate = InvoiceDate Where isNull(DeliveryDate,'') = ''

-- Script For Collection - Che - Enh
--If (Select Count(*) from chequecollDetails) = 0
--BEGIN
--	Insert into chequecollDetails (CollectionID,DocumentID,DocumentType,Creationdate,ModifiedDate)
--	Select CollectionDetail.CollectionID,CollectionDetail.DocumentId,CollectionDetail.DocumentType,getdate(),getdate()
--	From CollectionDetail,Collections 
--	Where Collections.DocumentID = CollectionDetail.CollectionID 
--	And isnull(Collections.PaymentMode,0) = 1
--END

-- Script for Received Purchase Invoice Pending Quantity updating
--Update InvoiceDetailReceived Set Pending = Quantity ,
--DiscountPercentage = Case When IsNull(SalePrice,0) = 0 then 0 Else (((DiscountValue) / (Quantity*SalePrice)) * 100) End
--Where InvoiceID In (Select InvoiceID from InvoiceAbstractReceived Where IsNull(Status,0) & 1 = 0 )
--And IsNull(Pending,-1) = -1
--And InvoiceID Not in (Select RecdInvoiceID From GRNAbstract Where IsNull(RecdInvoiceID,0) > 0 And IsNull(GrnStatus,0) & 96 = 0)

--Update InvoiceAbstractReceived Set Status = 129,Documentid='Void00',Reference='Void00' Where InvoiceID Not In (Select InvoiceID From InvoiceDetailReceived)
--
--
--Update DynamicProcedure Set SourceProcName = 'sp_print_RetInvItems_MUOM_ITC_Template' Where SourceProcName='sp_print_RetInvItems_MultiUOM_Template'
--Update DynamicProcedure Set SourceHeader = 'Create Procedure sp_print_RetInvItems_MUOM_ITC_Template(@INVNO INT)'
--Where SourceProcName='sp_print_RetInvItems_MUOM_ITC_Template'
--Update DynamicProcedure Set ReplaceParameter = ', "TaxComponent" = NULL' Where SourceProcName='sp_print_RetInvItems_MUOM_ITC_Template'
--
--Update DynamicProcedure Set SourceProcName = 'sp_print_RetInvItems_RespectiveUOM_ITC_Template' Where SourceProcName='sp_print_RetInvItems_RespectiveUOM_Template'
--Update DynamicProcedure Set SourceHeader = 'Create Procedure sp_print_RetInvItems_RespectiveUOM_ITC_Template(@INVNO INT)'
--Where SourceProcName='sp_print_RetInvItems_RespectiveUOM_ITC_Template'
--Update DynamicProcedure Set ReplaceParameter = ', "TaxComponent" = NULL' Where SourceProcName='sp_print_RetInvItems_RespectiveUOM_ITC_Template'
--
--Update DynamicProcedure Set SourceProcName = 'sp_print_RetInvItems_MUOM_SR_ITC_Template' Where SourceProcName='sp_print_RetInvItems_MultiUOM_SR_Template'
--Update DynamicProcedure Set SourceHeader = 'CREATE PROCEDURE sp_print_RetInvItems_MUOM_SR_ITC_Template(@INVNO INT)'
--Where SourceProcName='sp_print_RetInvItems_MUOM_SR_ITC_Template'
--Update DynamicProcedure Set ReplaceParameter = ', "TaxComponent" = NULL' Where SourceProcName='sp_print_RetInvItems_MUOM_SR_ITC_Template'
--
--Update DynamicProcedure Set SourceProcName = 'sp_print_RetInvItems_RespUOM_SR_ITC_Template' Where SourceProcName='sp_print_RetInvItems_RespectiveUOM_SR_Template'
--Update DynamicProcedure Set SourceHeader = 'Create PROCEDURE sp_print_RetInvItems_RespUOM_SR_ITC_Template(@INVNO INT) '
--Where SourceProcName='sp_print_RetInvItems_RespUOM_SR_ITC_Template'
--Update DynamicProcedure Set ReplaceParameter = ', "TaxComponent" = NULL' Where SourceProcName='sp_print_RetInvItems_RespUOM_SR_ITC_Template'
--
--Update DynamicProcedure Set SourceProcName = 'SP_Print_RetInvItems_ITC_Template' Where SourceProcName='SP_Print_RetInvItems_Template'
--Update DynamicProcedure Set SourceHeader = 'CREATE Procedure SP_Print_RetInvItems_ITC_Template(@INVNO INT)'
--Where SourceProcName='SP_Print_RetInvItems_ITC_Template'
--Update DynamicProcedure Set ReplaceParameter = ', "TaxComponent" = NULL' Where SourceProcName='SP_Print_RetInvItems_ITC_Template'
--
--Update DynamicProcedure Set ReplaceParameter = ', "TaxComponents" = NULL' Where SourceProcName = 'sp_Print_InvAbstractSR_ITC_Template'
--
--Update DynamicProcedure Set ReplaceParameter = ',"TaxComponent" = NULL' Where SourceProcName='sp_Print_InvAbstract_ITC_Template'
--And BaseProcName = 'sp_Create_TaxCompTotal_Fields' 
--
--Update DynamicProcedure Set ReplaceParameter = ',"AdjustmentComponent" = NULL' Where SourceProcName='Sp_Print_InvAbstract'
--And BaseProcName = 'sp_create_adjustment_printing'
--
--Update DynamicProcedure Set ReplaceParameter = ',"TaxComponent" = NULL' Where SourceProcName='sp_Print_InvAbstractSR_ITC_Template'
--And BaseProcName = 'sp_Create_TaxCompTotal_Fields'
--
--Update DynamicProcedure Set ReplaceParameter = ',"AdjustmentComponent" = NULL' Where SourceProcName='Sp_Print_InvAbstractSR'
--And BaseProcName = 'sp_create_adjustment_printing'

-- Menu name changes for MLang
--Create DO - Purchase Bill
--Amend DO - Bill Amendment
--Cancel DO - Cancel Bill
--View DO  - Bills
--If Exists(Select LocalizedValue From MLang.dbo.MLangResources Where DefaultValue = '&Purchase Bill' And Type = 'Label')
--Update MLang.dbo.MLangResources Set LocalizedValue = 'C&reate DO' Where DefaultValue = '&Purchase Bill' And Type = 'Label'
--Else
--Insert Into MLang.dbo.MLangResources (LCID, ProjectID, Type, DefaultValue, LocalizedValue) 
--Values (1033, 'Forum', 'Label', '&Purchase Bill', 'C&reate DO')
--
--If Exists(Select LocalizedValue From MLang.dbo.MLangResources Where DefaultValue = '&Bill Amendment' And Type = 'Label')
--Update MLang.dbo.MLangResources Set LocalizedValue = 'A&mend DO' Where DefaultValue = '&Bill Amendment' And Type = 'Label'
--Else
--Insert Into MLang.dbo.MLangResources (LCID, ProjectID, Type, DefaultValue, LocalizedValue) 
--Values (1033, 'Forum', 'Label', '&Bill Amendment', 'A&mend DO')
--
--If Exists(Select LocalizedValue From MLang.dbo.MLangResources Where DefaultValue = 'Cancel Bil&l' And Type = 'Label')
--Update MLang.dbo.MLangResources Set LocalizedValue = 'Cance&l DO' Where DefaultValue = 'Cancel Bil&l' And Type = 'Label'
--Else
--Insert Into MLang.dbo.MLangResources (LCID, ProjectID, Type, DefaultValue, LocalizedValue) 
--Values (1033, 'Forum', 'Label', 'Cancel Bil&l', 'Cance&l DO')
--
--If Exists(Select LocalizedValue From MLang.dbo.MLangResources Where DefaultValue = '&Bills' And Type = 'Label')
--Update MLang.dbo.MLangResources Set LocalizedValue = 'View &DO' Where DefaultValue = '&Bills' And Type = 'Label'
--Else
--Insert Into MLang.dbo.MLangResources (LCID, ProjectID, Type, DefaultValue, LocalizedValue) 
--Values (1033, 'Forum', 'Label', '&Bills', 'View &DO')
--
----from 6.1.1
--
--Update MLang.dbo.MLangResources set LocalizedValue = 'Manual No' where DefaultValue = 'Select A Document Type'
--Update MLang.dbo.MLangResources Set LocalizedValue = '&Add New Customer Type' Where DefaultValue = '&Add New Channel Type'
--Update MLang.dbo.MLangResources Set LocalizedValue = '&Modify Customer Type' Where DefaultValue = '&Modify Channel Type'
--Update MLang.dbo.MLangResources Set LocalizedValue = 'Customer &Type' Where DefaultValue = 'Channel &Type'
--
--If Not Exists (Select * from MLang.dbo.MLangResources Where DefaultValue = 'Add New Channel...')
--Begin
----
--	Insert into MLang.dbo.MLangResources(LCID, ProjectID, Type, DefaultValue, LocalizedValue) Values
--	    (1033,'Forum','Label','Add New Channel...','Add New Customer Type...')
--End
--
--If Not exists(select * from MLang.dbo.MLangResources where LocalizedValue = 'Manual No')
--Begin
--	Update MLang.dbo.MLangResources set LocalizedValue = 'Manual No' where DefaultValue = 'Select A Document Type'
--End
--
--Update MLang.dbo.MLangResources set LocalizedValue = 'Manual No' where DefaultValue = 'Select A Document Type'
--Update MLang.dbo.MLangResources Set LocalizedValue = '&Add New Customer Type' Where DefaultValue = '&Add New Channel Type'
--Update MLang.dbo.MLangResources Set LocalizedValue = '&Modify Customer Type' Where DefaultValue = '&Modify Channel Type'
--Update MLang.dbo.MLangResources Set LocalizedValue = 'Customer &Type' Where DefaultValue = 'Channel &Type'
--
--If Not Exists (Select * from MLang.dbo.MLangResources Where DefaultValue = 'Add New Channel...')
--Begin
--	Insert into MLang.dbo.MLangResources(LCID, ProjectID, Type, DefaultValue, LocalizedValue) Values
--	    (1033,'Forum','Label','Add New Channel...','Add New Customer Type...')
--End
--
--Delete From MLang..MlangResources Where Type = N'Label' And DefaultValue IN(N'Claim Applicable :','Payout period :')
--Delete From MLang..MlangResources Where Type = N'Label' And DefaultValue IN(N'Claim Applicable','Payout period')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Claim Applicable :','RFA Applicable :')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Payout Period :','RFA Period :')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Claim Applicable','RFA Applicable')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Payout Period','RFA Period')
--
--Delete From MLang..MlangResources Where Type = N'Label'  And DefaultValue IN(N'Price Rebate:','Price Re&bate','&View Price Rebate','Price Rebate')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Price Rebate:','Price To Rebate:')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Price Rebate','Price To Rebate')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Price Re&bate','Price To Rebate')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','&View Price Rebate','View Price To Rebate')
--
--Delete From MLang..MlangResources Where Type = N'MenuLabel'  And DefaultValue IN(N'Price Rebate:','Price Re&bate','&View Price Rebate','Price Rebate')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','MenuLabel','Price Rebate:','Price To Rebate:')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','MenuLabel','Price Rebate','Price To Rebate')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','MenuLabel','Price Re&bate','Price To Rebate')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','MenuLabel','&View Price Rebate','View Price To Rebate')
--
--Delete From MLang..MlangResources Where Type = N'Label'  And 
--DefaultValue IN(N'Payout Status',N'Payout Status:',N'Payout Status :',N'Payout Period :',N'Payout Period',N'Payout Period:')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Payout Status :','RFA Status :')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Payout Status:','RFA Status:')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Payout Status','RFA Status')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Payout Period :','RFA Period :')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Payout Period:','RFA Period:')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)Values(1033,'Forum','Label','Payout Period','RFA Period')
--
--Delete from Mlang..MLangResources Where DefaultValue = 'A.E Accompaniment' and ProjectID = 'FORUM' and Type = 'Label'
--Insert Into Mlang..MLangResources(LCID, projectID, Type, DefaultValue, LocalizedValue)
--Values('1033', 'FORUM', 'Label', 'A.E Accompaniment', 'Mkt Accompaniment')
--
--Delete From mlang..mlangresources Where DefaultValue Like N'Price Re&bate'
--Delete From mlang..mlangresources Where DefaultValue Like N'&View Price Rebate'
--Insert InTo mlang..mlangresources (LCID, ProjectID, Type, DefaultValue, LocalizedValue) 
--Values (1033, 'Forum', 'Label', 'Price Re&bate', 'Price To Trade')
--Insert Into MLang..MlangResources(LCID,ProjectID,Type,DefaultValue,LocalizedValue)
--Values(1033,'Forum','Label','&View Price Rebate','View Price To Trade')
--
--Delete From mlang..mlangresources Where DefaultValue Like N'Customer TM&D RCS  Master'
--Insert InTo mlang..mlangresources (LCID, ProjectID, Type, DefaultValue, LocalizedValue) 
--Values (1033, 'Forum', 'Label', 'Customer TM&D RCS  Master', 'TMD  Customer Merchandising')
--
--update MLang..MLangResources set LocalizedValue ='&Purchase Bill' Where LCID = 1033 And ProjectID = 'Forum' And Type = 'Label' And DefaultValue = N'&Purchase Bill'
--update MLang..MLangResources set LocalizedValue ='&Bill Amendment' Where LCID = 1033 And ProjectID = 'Forum' And Type = 'Label' And DefaultValue = N'&Bill Amendment'
--update MLang..MLangResources set LocalizedValue ='Cancel Bil&l' Where LCID = 1033 And ProjectID = 'Forum' And Type = 'Label' And DefaultValue = N'Cancel Bil&l'



-- Entry for Config
/*
if Not Exists(select * from ATH_Client_ConfigDB..R1ATH_Client_CodeMS where Code_Defn='ItemConfig')      
insert into ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMITC',32,'ItemConfig',getdate())      
if Not Exists(select * from ATH_Client_ConfigDB..R1ATH_Client_CodeMS where Code_Defn='MastersConfig')      
insert into ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMMSC',33,'MastersConfig',getdate())      
if Not Exists(select * from ATH_Client_ConfigDB..R1ATH_Client_CodeMS where Code_Defn='CustomerConfig')      
insert into ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMCSC',34,'CustomerConfig',getdate())    
*/
--Update Reports_To_Upload Set Frequency = 0 Where ReportDataID In(785,786,787,788,928)

--To skip the download old build FSUs file in thin client machine
--Update tblUpdateDetail set TargetClient = 1

--Pending FSUs status set as updated 
Update tblInstallationDetail set Status = 5

--Version 6.2.0 Changes

--Failed FSU to be marked as updated.
--Update tblReleaseDetail set Status=75


--If Exists(Select * from PortalClientDB..SysObjects Where XType='U' and Name Like 'XMLDocCode')
--Begin
--  Drop table PortalClientDB..XMLDocCode
--End
--
--
--Create Table PortalClientDB..XMLDocCode(
--Code_Number	nVarchar(10) Collate SQL_Latin1_General_CP1_CI_AS Primary Key ,
--Code_Name	nVarchar(20) Collate SQL_Latin1_General_CP1_CI_AS,	
--Code_Defn	nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS,	
--LastUpdTimeStamp	DateTime	Default Getdate())
--
--
--
--If (Select Count(*) From PortalClientDB..XMLDocCode) > 0 
--Begin
--  Truncate table PortalClientDB..XMLDocCode
--End
--
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DSDWLD','1','Document Successfully Downloaded', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DSUPLD','2','Document Successfully Uploaded', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('RJ000','3','Document Tampered', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DSFORUMPL','4','Document Pulled From 3E', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DS3EPL','4','Document Pulled From 3E', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DS3EPS','5','Document Pushed Into 3E', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DSFORUMPS','5','Document Pushed Into 3E', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3EIV','6','Invoice', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMIV','6','Invoice', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3EPO','7','PO', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMPO','7','PO', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMRC','8','CreditNote', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3ERC','8','CreditNote', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3ERD','9','DebitNote', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMRD','9','DebitNote', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMSO','10','SO', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3ESO','10','SO', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3ECG','11','Catalog', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMCG','11','Catalog', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMIY','12','Inventory', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3EIY','12','Inventory', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3ETO','13','TO', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMTO','13','TO', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMTI','14','TI', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3ETI','14','TI', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3EPR','15','PR', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMPR','15','PR', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3EKOS','16','KOS', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMKOS','16','KOS', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMFWI','17','FWI', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3EFWI','17','FWI', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3EFOR','18','FOR', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMFOR','18','FOR', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMMSG','19','MSG', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT3EGRN','20','GRN', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMGRN','21','GRN', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMSRE','22','SRE', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMCUS','24','CUS', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMSCH','25','SCH', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMITM','26','Item', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMCGY','27','Category', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMFAS','28','FAS', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMCLM','29','Claims', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMTRC','30','TradeCustomer', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMCOL','31','Collection', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMITC','32','ItemConfig', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMMSC','33','MastersConfig', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMCSC','34','CustomerConfig', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMCSS','35','ITCSCH', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMIPM','36','PriceMatrix', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMSA','36','StkAdj', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMCCD','38','CCD', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMMAR','39','Marginupdate', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMQOt','40','QuotationChannel', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMRFA','41','RFA', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMACK','42','ACK', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT4MRPTACK','43','REPORTACK', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMPM','44','ITCPM', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DTFORUMPRL','75','PriceList', Getdate())
--Insert into PortalClientDB..XMLDocCode(Code_Number, Code_Name, Code_Defn, LastUpdTimestamp) Values ('DT4MRCDACK','45','RECDACK', Getdate())

--BackUp changes and XML Doc Type Changes
-- Script for Backup process Change
--if not exists(select * from tbl_mERP_ConfigAbstract where screencode = 'Backup')
--BEGIN
--	insert into tbl_mERP_ConfigAbstract (ScreenCode,ScreenName,Description,Flag,CreationDate,ModifiedDate) values 
--	('Backup','Backup Database','Backup Database',1,getdate(),NULL)
--END
--if not exists(select * from tbl_mERP_ConfigDetail where screencode = 'Backup')
--BEGIN
--	insert into tbl_mERP_ConfigDetail (ScreenCode,ControlName,XMLAttribute,ControlIndex,Description,Flag,AllowConfig,TabIndex,TabLevel,TabName,CreationDate,ModifiedDate,[Value]) values 
--	('Backup','Grace Days',NULL,NULL,'Grace Days',1,1,NULL,NULL,NULL,getdate(),NULL,2)
--END
--Checking Last_Backup_date column exists in Setup Table
/*
update reports_to_upload set XMLReportCode ='DPR'	where reportname ='Performance Report'
update reports_to_upload set XMLReportCode ='CPL'	where reportname ='Closing PipeLine'
update reports_to_upload set XMLReportCode ='ALR'	where reportname ='Audit Log Report'
update reports_to_upload set XMLReportCode ='CVR'	where reportname ='Component Version Report'
update reports_to_upload set XMLReportCode ='CFT'	where reportname ='Customer Facing Time Summary Report'
update reports_to_upload set XMLReportCode ='CDR'	where reportname ='CustomerDetail'
update reports_to_upload set XMLReportCode ='CPA'	where reportname ='CustomerWise Productivity Analysis'
update reports_to_upload set XMLReportCode ='DST'	where reportname ='DS Training Details'
update reports_to_upload set XMLReportCode ='ORD'	where reportname ='Open Received DO'
update reports_to_upload set XMLReportCode ='RDS'	where reportname ='Received Document Status Report'
update reports_to_upload set XMLReportCode ='RSR'	where reportname ='Release Status Report'
update reports_to_upload set XMLReportCode ='STR'	where reportname ='Sales Data'
update reports_to_upload set XMLReportCode ='SPR'	where reportname ='Sales Position Report'
update reports_to_upload set XMLReportCode ='SCR'	where reportname ='Stock Control Report'
update reports_to_upload set XMLReportCode ='TCH'	where reportname ='TMD - Category Handler'
update reports_to_upload set XMLReportCode ='OSM'	where reportname ='TMD - Outlet Salesman Mapping'
update reports_to_upload set XMLReportCode ='SPM'	where reportname ='TMD - Salesman Productivity Measures'
update reports_to_upload set XMLReportCode ='TOU'	where reportname ='TMD- Outlet Update'
update reports_to_upload set XMLReportCode ='OSD'	where reportname ='TMD- Outlet Wise Sales & Damage'
update reports_to_upload set XMLReportCode ='VDR'	where reportname ='VAT Disallowed Report'
update reports_to_upload set XMLReportCode ='WSH'	where reportname ='WD System Health ScoreCard'
update reports_to_upload set XMLReportCode ='OSC'	where reportname ='Open Scheme Credit Note'
update reports_to_upload set XMLReportCode ='EPM'	where reportname ='Edit Product Margin Report'
update reports_to_upload set XMLReportCode ='PLR'	where reportname ='Projected Liability Report'


Create Table #MismatchRpt(ID int, ReportName nvarchar(250)) 
insert into #MismatchRpt Select RD.ID, RD.node from reportdata RD, reports_to_upload RTU where 
RD.ID = RTU.ReportdataID
And RD.Node <> RTU.ReportName

Declare @ID int
Declare @RptName nvarchar(250)

Declare getRpt Cursor For Select ID, ReportName from #MismatchRpt
open getRpt
fetch from getrpt into @ID,@RptName
While @@fetch_status =0
BEGIN
	update reports_to_upload set ReportName = @RptName where ReportDataID=@ID
	fetch next from getrpt into @ID,@RptName
END
Close getrpt
Deallocate getrpt
Drop Table #MismatchRpt
*/
--Reports_To_Upload

--Insert Into Reports_To_Upload 
--(ReportName,Frequency,ParameterID,CompanyID,ReportDataID,DayOfMonthWeek, AliasActionData, GenOrderBy, SendParamValidate, GracePeriod, LatestDoc,XMLReportCode)
--Select ReportName,Frequency,ParameterID,CompanyID,ReportDataID,DayOfMonthWeek, AliasActionData, GenOrderBy, SendParamValidate, GracePeriod, LatestDoc ,XMLReportCode
--From TemplateDB.dbo.Reports_To_Upload
--Where TemplateDB.dbo.Reports_To_Upload.ReportName Not In (Select ReportName From Reports_To_Upload)
--
--
--Update Reports_To_Upload 
--Set SendParamValidate = TemplateDB.dbo.Reports_To_Upload.SendParamValidate, 
--GracePeriod = TemplateDB.dbo.Reports_To_Upload.GracePeriod,
--LatestDoc = TemplateDB.dbo.Reports_To_Upload.LatestDoc,
--Frequency = TemplateDB.dbo.Reports_To_Upload.Frequency,
--XMLReportCode=TemplateDB.dbo.Reports_To_Upload.XMLReportCode
--From TemplateDB.dbo.Reports_To_Upload
--Where TemplateDB.dbo.Reports_To_Upload.ReportName = Reports_To_Upload.ReportName

--Hidden Reports
--tbl_merp_otherreportsupload
--Insert Into tbl_merp_otherreportsupload 
--(ReportName,Frequency,ParameterID,CompanyID,ReportDataID,DayOfMonthWeek, AliasActionData, GenOrderBy, SendParamValidate, GracePeriod, LatestDoc,XMLReportCode)
--Select ReportName,Frequency,ParameterID,CompanyID,ReportDataID,DayOfMonthWeek, AliasActionData, GenOrderBy, SendParamValidate, GracePeriod, LatestDoc ,XMLReportCode
--From TemplateDB.dbo.tbl_merp_otherreportsupload
--Where TemplateDB.dbo.tbl_merp_otherreportsupload.ReportName Not In (Select ReportName From tbl_merp_otherreportsupload)
--
--Update tbl_merp_otherreportsupload 
--Set SendParamValidate = TemplateDB.dbo.tbl_merp_otherreportsupload.SendParamValidate, 
--GracePeriod = TemplateDB.dbo.tbl_merp_otherreportsupload.GracePeriod,
--LatestDoc = TemplateDB.dbo.tbl_merp_otherreportsupload.LatestDoc,
--Frequency = TemplateDB.dbo.tbl_merp_otherreportsupload.Frequency,
--XMLReportCode=TemplateDB.dbo.tbl_merp_otherreportsupload.XMLReportCode
--From TemplateDB.dbo.tbl_merp_otherreportsupload
--Where TemplateDB.dbo.tbl_merp_otherreportsupload.ReportName = tbl_merp_otherreportsupload.ReportName
--
----Upgrade Script to update new column[CreationDate] Value  for existing records
--Update tbl_merp_UploadReportTracker Set CreationDate = UploadDate Where CreationDate is Null
--/********************************/
--
--Truncate Table ReportParameters_Upload
---- Insert ReportParameters_Upload
--Insert ReportParameters_Upload
--(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type,Skip)
--Select ParameterID, Parameter_Name, Parameter_Value, Parameter_Type,Skip
--From TemplateDB.dbo.ReportParameters_Upload 
--
----End fo reports_to_Upload
--Declare @CompId nvarchar(20)
--SET @CompId = (select TOP 1 RegisteredOwneR + CAST ('MERP' AS NVARCHAR(4)) from setup)
--if not exists (select * from users where username =@CompId)
--	insert into users (USERNAME ,GROUPNAME,ACTIVE) VALUES(@CompId ,'Administrator',1)
--
----To Deactivate the Athena Admin user from Groups
--SET @CompId = (select TOP 1 RegisteredOwneR + CAST ('ad' AS NVARCHAR(4)) from setup)
--If Exists(Select * from Users Where Active= 1 and Username Like @CompId)
--    update Users set Active  = 0 Where Username Like @CompId
--
----To Update reportcode in tbl_mERP_OtherReportsUpload
--update A set a.XMLReportcode = b.XMLReportcode  from tbl_mERP_OtherReportsUpload A, Templatedb..tbl_mERP_OtherReportsUpload B where a.reportname =B.reportname

--To Update tbl_merp_fileInfo
--truncate table tbl_merp_fileInfo
--insert into tbl_merp_fileInfo select * from templatedb..tbl_merp_fileInfo 

Update tbl_merp_fileInfo Set Active = 0 
insert into tbl_merp_fileInfo (FSUID,PatchName,TargetClient,DBVersionNumber,BuildVersion,FileName,VersionNumber,DestinationFolder,AlternativeFolder,
ClientId,Active,CreationTime)
select FSUID,PatchName,TargetClient,DBVersionNumber,BuildVersion,FileName,VersionNumber,DestinationFolder,AlternativeFolder,
ClientId,Active,Getdate() from templatedb..tbl_merp_fileInfo 

--Tax Type
--truncate table tbl_mERP_Taxtype 
--SET IDENTITY_INSERT tbl_mERP_Taxtype ON
--insert into tbl_mERP_Taxtype (TaxID,Taxtype,CreationDate) select TaxID,Taxtype,CreationDate from templatedb..tbl_merp_taxtype order by taxid
--SET IDENTITY_INSERT tbl_mERP_Taxtype OFF

----Scheme Type
--truncate table tbl_mERP_SchemeType
--SET IDENTITY_INSERT tbl_mERP_SchemeType ON
--insert into tbl_mERP_SchemeType (ID,SchemeType) select ID,SchemeType from TemplateDB..tbl_mERP_SchemeType order by ID
--SET IDENTITY_INSERT tbl_mERP_SchemeType OFF
--
----Free Type
--truncate table tbl_mERP_SchemeApplicableType
--SET IDENTITY_INSERT tbl_mERP_SchemeApplicableType ON
--insert into tbl_mERP_SchemeApplicableType (ID,ApplicableOn) select ID,ApplicableOn from TemplateDB..tbl_mERP_SchemeApplicableType order by ID
--SET IDENTITY_INSERT tbl_mERP_SchemeApplicableType OFF
--
----SchemeItem Type
--truncate table tbl_mERP_SchemeItemGroup
--SET IDENTITY_INSERT tbl_mERP_SchemeItemGroup ON
--insert into tbl_mERP_SchemeItemGroup (ID,ItemGroup) select ID,ItemGroup from TemplateDB..tbl_mERP_SchemeItemGroup order by ID
--SET IDENTITY_INSERT tbl_mERP_SchemeItemGroup OFF
--
----Scheme slab type
--truncate table tbl_mERP_SchemeSlabType
--SET IDENTITY_INSERT tbl_mERP_SchemeSlabType ON
--insert into tbl_mERP_SchemeSlabType (SlabTypeID,SlabType) select SlabTypeID,SlabType from TemplateDB..tbl_mERP_SchemeSlabType order by SlabTypeID
--SET IDENTITY_INSERT tbl_mERP_SchemeSlabType OFF
--
----Error Messages for schemes
--truncate table ErrorMessages
--insert into ErrorMessages (ErrorID,Message,Comment) select ErrorID,Message,Comment from TemplateDB..ErrorMessages order by ErrorID
--
----*PM
--truncate table tbl_mERP_PMUOM
--insert into tbl_mERP_PMUOM (ID,PMUOM) select ID,PMUOM from TemplateDB..tbl_mERP_PMUOM order by ID
--
--truncate table tbl_mERP_PMParamType
--insert into tbl_mERP_PMParamType (ID,ParamType,OrderBy) select ID,ParamType,OrderBy from TemplateDB..tbl_mERP_PMParamType order by ID
--
--truncate table tbl_mERP_PMGivenAs
--insert into tbl_mERP_PMGivenAs (ID,GivenAs) select ID,GivenAs from TemplateDB..tbl_mERP_PMGivenAs order by ID
--
--truncate table tbl_mERP_PMFrequency
--insert into tbl_mERP_PMFrequency (ID,Frequency) select ID,Frequency from TemplateDB..tbl_mERP_PMFrequency order by ID
--
----*AE 
--truncate table tbl_mERP_AEModule
--SET IDENTITY_INSERT tbl_mERP_AEModule ON
--insert into tbl_mERP_AEModule (ID,ModuleID,ModuleName) select ID,ModuleID,ModuleName from TemplateDB..tbl_mERP_AEModule order by ID
--SET IDENTITY_INSERT tbl_mERP_AEModule OFF
--
----*Loyalty
--truncate table Loyalty
--insert into Loyalty (LoyaltyID,Loyaltyname) select LoyaltyID,Loyaltyname from TemplateDB..Loyalty order by LoyaltyID
--
----Merchandise
--truncate table Merchandise
--SET IDENTITY_INSERT Merchandise ON
--insert into Merchandise (MerchandiseID,Merchandise,Active) select MerchandiseID,Merchandise,Active from TemplateDB..Merchandise order by MerchandiseID
--SET IDENTITY_INSERT Merchandise OFF
--
----Cust_TMD_Master
--truncate table Cust_TMD_Master
--SET IDENTITY_INSERT Cust_TMD_Master ON
--insert into Cust_TMD_Master (TMDID,TMDName,TMDValue,TMDCtlPos,Active) select TMDID,TMDName,TMDValue,TMDCtlPos,Active from TemplateDB..Cust_TMD_Master order by TMDID
--SET IDENTITY_INSERT Cust_TMD_Master OFF
--
--
----tbl_mERP_SupervisorType
--truncate table tbl_mERP_SupervisorType
--SET IDENTITY_INSERT tbl_mERP_SupervisorType ON
--insert into tbl_mERP_SupervisorType (TypeID,TypeDesc,Active) select TypeID,TypeDesc,Active from TemplateDB..tbl_mERP_SupervisorType order by TypeID
--SET IDENTITY_INSERT tbl_mERP_SupervisorType OFF

--Config Abstract
--Update A set 
--A.ScreenCode=T.ScreenCode,
--A.ScreenName=T.ScreenName,
--A.Description=T.Description,
--A.Flag=T.Flag
--From tbl_mERP_ConfigAbstract A,TemplateDB..tbl_mERP_ConfigAbstract T
--where isNull(A.ScreenCode,'')=isNull(T.ScreenCode,'')

Insert into tbl_mERP_ConfigAbstract (ScreenCode,ScreenName,Description,Flag) 
Select ScreenCode,ScreenName,Description,Flag from TemplateDB..tbl_mERP_ConfigAbstract
Where ScreenCode not in (Select ScreenCode from tbl_mERP_ConfigAbstract)

--Config Detail
--Update A set
--A.ScreenCode=B.ScreenCode,
--A.ControlName=B.ControlName,
--A.XMLAttribute=B.XMLAttribute,
--A.ControlIndex=B.ControlIndex,
--A.Description=B.Description,
--A.Flag=B.Flag,
--A.AllowConfig=B.AllowConfig,
--A.TabIndex=B.TabIndex,
--A.TabLevel=B.TabLevel,
--A.TabName=B.TabName,
--Value=B.Value
--From tbl_mERP_ConfigDetail A,TemplateDB..tbl_mERP_ConfigDetail B
--Where ISNULL(A.Screencode,'')=ISNULL(B.Screencode,'') and ISNULL(A.ControlName,'')=ISNULL(B.ControlName,'') and ISNULL(A.XMLAttribute,'')=ISNULL(B.XMLAttribute,'') and ISNULL(A.Description,'')=ISNULL(B.Description,'')

Insert into tbl_mERP_ConfigDetail 
select B.* from TemplateDB..tbl_mERP_ConfigDetail B Left outer join tbl_mERP_ConfigDetail A
on isNull(B.Screencode,'')=isNull(A.Screencode,'') and isNull(B.ControlName,'') =isNull(A.ControlName,'') and isNull(B.XMLAttribute,'')=isNull(A.XMLAttribute,'') and isNull(B.Description,'')=isNull(A.Description ,'')
where (isNull(A.Screencode,'')='' and isNull(A.ControlName,'')='' and isNull(A.XMLAttribute,'')='' and isNull(A.Description,'')='')


---- DSType Category Grp Mapping 
--Exec mERP_sp_Define_DSTypeCGMapping 
--
---- Product Category Grp Mapping
--Exec mERP_sp_Define_ProdCatGrpMapping	

--Comversion Entry
Truncate table comversion
Insert into ComVersion Select * from TemplateDB..ComVersion

/*To update the LAstUpload Date when its null*/
--Exec mERP_sp_ResetReportUploadDate

/*
When NCS version is upgraded to new version (6.2.0), Tax Type is not updating for existing stocks. 
ITC - UAT point
*/
  /*To Update Tax Type on Batch_products*/
  --BatchProduct updatea
-- Update Batch_Products set Taxtype= Case isnull(Vat_Locality,1) When 0 Then 1 When 1 Then 1 When 2 Then 2 End  where isNull(TaxType,'')='' 

  /*To update Tax Type on Bill Abstact*/ 
--  Update BA SET BA.TaxType = isnull(T2.VatLocality,1) 
--  From BillAbstract BA,
--  (Select GRN.BillID, Min(GRN.GRNID) GRNID From GRNAbstract GRN, BIllAbstract BA
--   Where GRN.BillID = BA.BillID
--   And BA.Status& 128 = 0
--   Group By GRN.BillID) T1,
--  (Select Distinct GRN_ID, IsNull(Vat_Locality,1) VATLOCALITY From Batch_Products) T2
--  Where BA.BillId = T1.BillID
--  And T1.GRNID= T2.GRN_ID
--  And BA.Status & 128 = 0
--  And IsNull(BA.TaxType,0) = 0

  /*To Update  the Received InvoiceAbstract table*/
--  Update InvRA Set InvRA.TaxType = V.Locality
--  From InvoiceAbstractReceived InvRA, Vendors V
--  Where V.VendorID = InvRA.VendorID
--  And IsNull(InvRA.Status,0) & 1 = 0 
--  And IsNull(InvRA.Status,0) & 64 = 0 
--  And IsNull(TaxType,'') = ''
  
  /*To Update Stock Transfer IN*/
--  Update StockTransferInAbstract Set TaxType= 1 Where IsNull(TaxType,0) = 0

--Printing Ini Transaction / RestrictedIni
--Truncate table tbl_mERP_RestrictedIniFiles
--Insert into tbl_mERP_RestrictedIniFiles (IniFileName,PrintMode,CreationDate,ModifiedDate,Active) 
--Select IniFileName,PrintMode,CreationDate,ModifiedDate,Active from TemplateDB..tbl_mERP_RestrictedIniFiles
--
--Truncate table tbl_mERP_transactionIni
--Insert into tbl_mERP_transactionIni (TransactionName,IniName,PrintMode,Active,CreationDate,ModifiedDate)
--Select TransactionName,IniName,PrintMode,Active,CreationDate,ModifiedDate from TemplateDB..tbl_mERP_transactionIni

--To update DBscript values for HH
If Exists(Select * from SysObjects where XType ='U' and Name like 'DBScript')
Begin
--  Insert into DBScript(Executable)
--  Select Distinct Executable from TemplateDB..DBScript Where Executable Not in (Select Executable From DBScript)
--
--  Update DBS Set DBS.Status = tmplDBS.Status From DBScript DBS, TemplateDB..DBScript tmplDBS Where  DBS.Executable = tmplDBS.Executable
 
  --To Grant Access Permission for handheld user
  Exec mERP_sp_Upgrade_HHScripts
End

/* To deactivate shortcuts which are no longer needed*/
--Not Required
/*
update shortcuts set active =0 where message in(
'F8-Change sale price',
'F11-Adjustments(Additional)',
'F8-Change sale price',
'F11-Additional adjustments',
'CTRL+T-Add Item',
'F2 - Amount discount',
'F2-Normal Discount Amount',
'Alt+F2-Discount/Base UOM Qty',
'F3-Amount Discount/UOM1',
'Alt+F3-Amount Discount/UOM2')
*/

IF NOT Exists(Select 'x' From VoucherPrefix Where TranID = 'VEHICLE ALLOCATION')
	Insert Into VoucherPrefix(TranID, Prefix) Values ('VEHICLE ALLOCATION', 'VL')

IF NOT Exists(Select 'x' From DocumentNumbers Where DocType = 108)
	Insert Into DocumentNumbers(DocType,DocumentID,VoucherStart) Values (108, 1, 1)

IF Not Exists (Select 'x' From tbl_merp_GrandTotExceptionalRpts Where ReportID = 1513)
	Insert Into tbl_merp_GrandTotExceptionalRpts (ReportID,ReportName) Values (1513,'Vehicle Allocation Report')

Declare @Cnt Int
Declare @Done Int
Declare @Van nVarChar(50)
Declare @VanNum nVarChar(50)
Set @Van = 'Default Van'
Set @VanNum = 'Default Van'
Set @Cnt = 1
Set @Done = 0
IF Not Exists (Select 'x' From VehicleAllocationVan)
Begin
	If Not Exists(Select 'x' From Van Where Van = @Van Or Van_Number  = @VanNum)
	Begin
		Insert Into Van (Van,Van_Number ,Active ,ReadyStockSalesVAN ) Values (@Van,@VanNum ,1,0)
		Insert Into VehicleAllocationVan (Van,VanNumber) Values (@Van,@VanNum)
		Set @Done = 1
	End
	Else
	Begin
		Set @Van = 'Default Van_' + CAST(@Cnt As nVarChar)
		Set @VanNum = 'Default Van_' + CAST(@Cnt As nVarChar)
		While @Done <> 1
		Begin
			If Not Exists(Select 'x' From Van Where Van = @Van Or Van_Number  = @VanNum)
			Begin
				Insert Into Van (Van,Van_Number ,Active ,ReadyStockSalesVAN ) Values (@Van,@VanNum ,1,0)
				Insert Into VehicleAllocationVan (Van,VanNumber) Values (@Van,@VanNum)
				Set @Done = 1
			End
			Else
			Begin
				Set @Van = 'Default Van_' + CAST(@Cnt As nVarChar)
				Set @VanNum = 'Default Van_' + CAST(@Cnt As nVarChar)
				Set @Cnt = @Cnt + 1
			End	
		End
	End
End

	Begin
			Create Table #TemptblDependentDetail(InstallationID Int,DependentFSUID Int,DependentSLUID Int)
			Create Table #temptblInstallationDetail(ID Int Identity(1,1), FSUID Int,FileName nVarchar(501))
					Begin
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (6881,'FSU-6881-16Feb16-EH-ConsolidateFSU_Part1')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (6882,'FSU-6882-16Feb16-EH-ConsolidateFSU_Part2')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (6883,'FSU-6883-16Feb16-EH-ConsolidateFSU_Part3')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (6884,'FSU-6884-16Feb16-EH-ConsolidateFSU_Part4')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (6885,'FSU-6885-16Feb16-EH-ConsolidateFSU_Part5')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (6919,'FSU-6919-24Feb16-EH-ConsolidateFSU_Part6')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7040,'FSU-7040-24Mar16-EH-CustomerDetailUpload')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7053,'FSU-7053-15Apr16-IG-CustomerFacingTimeReport')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7083,'FSU-7083-02May16-EH-InvoicePerformance')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7097,'FSU-7097-11May16-EH-AuditTrailReport')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7104,'FSU-7104-20May16-DC-DSPMTargetsUpdate')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7112,'FSU-7112-31May16-DC-ImageType')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7153,'FSU-7153-16Jun16-HH-HandheldPerformance')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7155,'FSU-7155-16Jun16-HH-ViewPerformanceChanges')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7157,'FSU-7157-17Jun16-EH-DayCloseChanges')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7166,'FSU-7166-23Jun16-PMChanges_Blockbuster')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7167,'FSU-7167-23Jun16-EH-PMchanges_Maxpoints')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7189,'FSU-7189-04Jul16-EH-Restrict_OLC')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7207,'FSU-7207-19Jul16-IG-PerformanceReportUpload')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7210,'FSU-7210-21Jul16-EH-DandDPrintChanges')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7211,'FSU-7211-21Jul16-EH-DSPM_GateChanges')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7214,'FSU-7214-27Jul16-IG-mERPUpdates_Jul2016')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7221,'FSU-7221-05Aug16-DC-DSTypeImage')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7231,'FSU-7231-11Aug16-EH-PanNumber_Enable')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7232,'FSU-7232-11Aug16-EH-DSPM_GateChanges_Phase2')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7239,'FSU-7239-17Aug16-EH-BusinessAchivementchanges')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7258,'FSU-7258-29Aug16-EH-QuotationReportChanges')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7265,'FSU-7265-07Sep16-IG-QuotationMarginReport')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7278,'FSU-7278-15Sep16-EH-PANMissingAlert')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7287,'FSU-7287-23Sep16-IG-PLRReportChanges')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7304,'FSU-7304-06Oct16-EH-StockValuationReport')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7312,'FSU-7312-20Oct16-EH-DSTypeCategoryMapping_Phase1')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7313,'FSU-7313-20Oct16-EH-DSTypeCategoryMapping_Phase2')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7314,'FSU-7314-20Oct16-IG-TLCProcesschanges')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7367,'FSU-7367-28Nov16-IG-NonRFASchExpRep_Performance')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7406,'FSU-7406-19Dec16-EH-AutoAdjustCreditNote')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7420,'FSU-7420-03Jan17-DC-mERPUpdateForScheme')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7422,'FSU-7422-03Jan17-EH-DisplaySchProcess')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7423,'FSU-7423-04Jan17-EH-LoyaltyPrintchanges')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7437,'FSU-7437-12Jan17-IG-mERP_Updates_JAN2017')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7439,'FSU-7439-25Jan17-IG-mERP_Updates_JAN2017')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7440,'FSU-7440-25Jan17-EH-MultiInvSinglePrint')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7441,'FSU-7441-30Jan17-EH-DSTypeImage')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7461,'FSU-7461-16Feb17-EH-PMGateDaysWorked_Target')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7510,'FSU-7510-24Mar17-EH-VATDisallowedReportchanges')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7519,'FSU-7519-17Apr17-EH-CustMasSummaryRep')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7655,'FSU-7655-16Jun17-EH-GST_Changes_Part1.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7656,'FSU-7656-16Jun17-EH-GST_Changes_Part2.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7657,'FSU-7657-16Jun17-EH-GST_Changes_Part3.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7658,'FSU-7658-16Jun17-EH-GST_PrintFormats.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7661,'FSU-7661-17Jun17-EH-GST_Changes_Part4.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7663,'FSU-7663-19Jun17-EH-GST_Changes_Part4.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7665,'FSU-7665-20Jun17-EH-GST_Changes_Part5.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7671,'FSU-7671-22Jun17-DC-Update_UOM2Conversion.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7672,'FSU-7672-22Jun17-EH-NonQPS_Schemechanges.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7675,'FSU-7675-23Jun17-EH-CGBilling.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7678,'FSU-7678-24Jun17-EH-GST_Changes_Part6.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7681,'FSU-7681-25Jun17-DC-PTRUpdate_KL.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7685,'FSU-7685-26Jun17-EH-GSTPTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7683,'FSU-7683-26Jun17-DC-UTGST_ConfigEnable.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7693,'FSU-7693-28Jun17-DC-JK_GSTDateConfigChange.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7689,'FSU-7689-27Jun17-EH-GSTIN_NonMandatory.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7694,'FSU-7694-28Jun17-HH-GSTView_Changes.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7709,'FSU-7709-01Jul17-EH-GSTDocID_Changes.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7716,'FSU-7716-04Jul17-IG-GST_InvoicePrintINI.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7712,'FSU-7712-04Jul17-DC-PTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7713,'FSU-7713-04Jul17-DC-PTRUpdate_MH.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7714,'FSU-7714-04Jul17-DC-PTRUpdate_DL.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7715,'FSU-7715-04Jul17-DC-PTRUpdate_HR.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7723,'FSU-7723-05Jul17-DC-DeActivateScheme.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7724,'FSU-7724-05Jul17-DC-PTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7721,'FSU-7721-05Jul17-IG-DSBeatCollDocID.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7730,'FSU-7730-06Jul17-DC-DeActivateScheme.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7731,'FSU-7731-06Jul17-DC-PTRUpdate_1.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7732,'FSU-7732-06Jul17-DC-PTRUpdate_2.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7733,'FSU-7733-06Jul17-DC-PTRUpdate_3.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7734,'FSU-7734-06Jul17-DC-PTRUpdate_4.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7735,'FSU-7735-06Jul17-DC-PTRUpdate_5.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7736,'FSU-7736-06Jul17-DC-PTRUpdate_6.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7738,'FSU-7738-06Jul17-IG-GST_TaxProcess.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7742,'FSU-7742-08Jul17-DC-JK_GSTDateConfigChange.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7743,'FSU-7743-08Jul17-DC-TaxBeforeDiscount_Update.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7750,'FSU-7750-11Jul17-DC-DSPM_14GraceDays.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7749,'FSU-7749-10Jul17-EH-GST-RepChanges-Part1.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7751,'FSU-7751-11Jul17-DC-PTRUpdate_1.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7752,'FSU-7752-11Jul17-DC-PTRUpdate_2.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7753,'FSU-7753-11Jul17-DC-PTRUpdate_3.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7755,'FSU-7755-12Jul17-DC-PTRUpdate_JK.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7754,'FSU-7754-11Jul17-EH-GSTSalesReturn.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7759,'FSU-7759-13Jul17-DC-Update_UOM2Conversion.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7760,'FSU-7760-13Jul17-DC-PTRUpdate_JK.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7769,'FSU-7769-17Jul17-EH-GST-RepChanges-Part2.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7779,'FSU-7779-21Jul17-DC-Enable_VATReports.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7782,'FSU-7782-21Jul17-DC-CGPTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7780,'FSU-7780-21Jul17-EH-OLCUpdate_DefaultCust.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7783,'FSU-7783-24Jul17-DC-PTRMargin.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7786,'FSU-7786-25Jul17-DC-PTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7781,'FSU-7781-21Jul17-DC-Enable_VATReports.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7791,'FSU-7791-27Jul17-DC-PTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7798,'FSU-7798-01Aug17-IG-GST_TaxComp_InvPrintINI.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7799,'FSU-7799-01Aug17-IG-GST_TaxComp_InvPrintINI.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7807,'FSU-7807-04Aug17-DC-GST_TaxComp_CGDOSInvPrintINI.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7810,'FSU-7810-05Aug17-EH-GSTR_Reports.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7814,'FSU-7814-08Aug17-IG-GST_CGInvPrintINI.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7813,'FSU-7813-08Aug17-DC-VATStkPTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7823,'FSU-7823-11Aug17-IG-PurchaseBillSave.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7829,'FSU-7829-17Aug17-DC-GSTR_PurchaseReport.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7830,'FSU-7830-17Aug17-DC-VATStkPTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7846,'FSU-7846-24Aug17-DC-MarginPTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7847,'FSU-7847-24Aug17-DC-MarginPTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7839,'FSU-7839-22Aug17-DC-GST_StkRep_Upload.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7840,'FSU-7840-22Aug17-DC-VATStkPTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7842,'FSU-7842-23Aug17-DC-BillMissingItemTax.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7854,'FSU-7854-29Aug17-DC-Restrict_OLC.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7863,'FSU-7863-01Sep17-DC-MarginPTRUpdate_1.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7864,'FSU-7864-01Sep17-DC-MarginPTRUpdate_2.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7871,'FSU-7871-04Sep17-EH-GST_InwardOutward_Reps.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7896,'FSU-7896-07Sep17-DC-TallyIntegration_GST.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7899,'FSU-7899-08Sep17-DC-TallyIntegration_GST.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7904,'FSU-7904-11Sep17-EH-STockTransfer_Changes.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7910,'FSU-7910-13Sep17-DC-MarginPTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7912,'FSU-7912-13Sep17-EH-GGRRTargetReport.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7918,'FSU-7918-15Sep17-DC-GGRRTargetUploadDate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7927,'FSU-7927-19Sep17-IG-SalesDataRepUpload.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7925,'FSU-7925-19Sep17-DC-Update_UOM2Conversion.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7929,'FSU-7929-20Sep17-IG-VanLoadReports_Changes.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7934,'FSU-7934-21Sep17-DC-TallyIntegration2_GST.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7932,'FSU-7932-20Sep17-EH-ChannelWisePTR_Phase1.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7952,'FSU-7952-04Oct17-DC-GST-RepChanges-Part3.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7954,'FSU-7954-05Oct17-DC-ChannelMarginPTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7959,'FSU-7959-10Oct17-DC-Update_UOMConversions.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7961,'FSU-7961-10Oct17-DC-GGRRTargetReport.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7962,'FSU-7962-11Oct17-EH-CustDSType_v8_Views.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7971,'FSU-7971-16Oct17-DC-SalesDataReport.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7997,'FSU-7997-17Oct17-DC-ChannelPTRUpdate_1.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8006,'FSU-8006-17Oct17-DC-ChannelPTRUpdate_10.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8015,'FSU-8015-17Oct17-DC-ChannelPTRUpdate_19.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7970,'FSU-7970-14Oct17-EH-ChannelWiseRates_RPT.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8020,'FSU-8020-23Oct17-DC-SalesDataReport.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7998,'FSU-7998-17Oct17-DC-ChannelPTRUpdate_2.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8023,'FSU-8023-24Oct17-DC-GGRRUploadParam.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (7999,'FSU-7999-17Oct17-DC-ChannelPTRUpdate_3.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8000,'FSU-8000-17Oct17-DC-ChannelPTRUpdate_4.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8001,'FSU-8001-17Oct17-DC-ChannelPTRUpdate_5.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8002,'FSU-8002-17Oct17-DC-ChannelPTRUpdate_6.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8003,'FSU-8003-17Oct17-DC-ChannelPTRUpdate_7.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8004,'FSU-8004-17Oct17-DC-ChannelPTRUpdate_8.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8005,'FSU-8005-17Oct17-DC-ChannelPTRUpdate_9.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8007,'FSU-8007-17Oct17-DC-ChannelPTRUpdate_11.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8008,'FSU-8008-17Oct17-DC-ChannelPTRUpdate_12.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8009,'FSU-8009-17Oct17-DC-ChannelPTRUpdate_13.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8010,'FSU-8010-17Oct17-DC-ChannelPTRUpdate_14.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8011,'FSU-8011-17Oct17-DC-ChannelPTRUpdate_15.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8012,'FSU-8012-17Oct17-DC-ChannelPTRUpdate_16.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8013,'FSU-8013-17Oct17-DC-ChannelPTRUpdate_17.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8014,'FSU-8014-17Oct17-DC-ChannelPTRUpdate_18.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8016,'FSU-8016-17Oct17-DC-ChannelPTRUpdate_20.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8017,'FSU-8017-17Oct17-DC-ChannelPTRUpdate_21.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8028,'FSU-8028-26Oct17-DC-ChannelMarginSchToDate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8033,'FSU-8033-30Oct17-IG-ChannelwisePTR_Bill.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8034,'FSU-8034-31Oct17-DC-ChannelPTRUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8040,'FSU-8040-02Nov17-DC-RemoveDupChannelPTR.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8039,'FSU-8039-02Nov17-DC-ChannelPTRUpdate_22.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8038,'FSU-8038-01Nov17-EH-CollateRep_Upload.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8045,'FSU-8045-08Nov17-IG-ChannelMarginProcess.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8052,'FSU-8052-14Nov17-EH-AutoAdj_CustGeo_V_Item.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8060,'FSU-8060-17Nov17-IG-StkControlRep_Upload.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8064,'FSU-8064-20Nov17-EH-DSPMReportTargetChanges.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8072,'FSU-8072-22Nov17-DC-FMCG_Inv_Disclaimer.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8065,'FSU-8065-20Nov17-IG-ViewPurchaseBill.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8080,'FSU-8080-28Nov17-DC-SchemeRefresh.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8079,'FSU-8079-27Nov17-IG-SalesReturn_QuotationTax.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8085,'FSU-8085-07Dec17-EH-VSDPM_HHView.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8088,'FSU-8088-13Dec17-DC-Update_UOMConversions.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8091,'FSU-8091-15Dec17-DC-ChannelPTRUpdate_NewGF.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8095,'FSU-8095-22Dec17-IG-SchProdRefresh.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8093,'FSU-8093-18Dec17-EH-WinnerSKU_Changes.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8097,'FSU-8097-29Dec17-EH-CustDetRep_Upload.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8098,'FSU-8098-03Jan18-DC-ResetUploadDt_CustDetRep.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8105,'FSU-8105-18Jan18-EH-WinnerSKUChanges_Phase2.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8110,'FSU-8110-24Jan18-DC-GGRRUploadParam.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8115,'FSU-8115-29Jan18-EH-FMCG_Inv_Disclaimer.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8123,'FSU-8123-31Jan18-EH-E-WayBill.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8125,'FSU-8125-31Jan18-EH-E-WayBill.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8127,'FSU-8127-02Feb18-IG-E-WayBill-CustImport.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8128,'FSU-8128-07Feb18-IG-GateUOBTarget_Formatting.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8134,'FSU-8134-09Feb18-DC-GGRRUploadDateReset.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8139,'FSU-8139-14Feb18-IG-SalesDataRep_Upload.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8147,'FSU-8147-19Feb18-EH-SKUwiseSOQView.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8146,'FSU-8146-19Feb18-DC-PerformanceReport_UploadDateReset.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8149,'FSU-8149-20Feb18-DC-UOM1ConversionUpdate.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8126,'FSU-8126-01Feb18-DC-RemoveDupChannelMargin.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8158,'FSU-8158-22Feb18-DC-ResetUploadDt_CustDetRep.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8154,'FSU-8154-22Feb18-IG-UploadRepParams_STD.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8155,'FSU-8155-22Feb18-EH-DandDChanges.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8181,'FSU-8181-08Mar18-EH-ResetGSTVoucherNumbers.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8184,'FSU-8184-14Mar18-EH-DandDChanges.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8185,'FSU-8185-14Mar18-DC-TallyIntegration3_DnD.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8186,'FSU-8186-20Mar18-EH-DandDChanges.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8187,'FSU-8187-20Mar18-DC-TallyIntegration3_DnD.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8188,'FSU-8188-20Mar18-DC-WinnerSKU_MaxPoints.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8202,'FSU-8202-29Mar18-EH-GSTOutward-Report.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8201,'FSU-8201-29Mar18-DC-UnRestrict_OLC.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8206,'FSU-8206-03Apr18-DC-INDX-V_SpecialCategory_item.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8215,'FSU-8215-04Apr18-DC-ReindexScheme_ViewPerformance.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8207,'FSU-8207-03Apr18-EH-GGRRTargetDailyReport.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8210,'FSU-8210-03Apr18-DC-ResetDt_GGRRTargetDailyRep.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8209,'FSU-8209-03Apr18-EH-GST-RepChanges-Part4.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8224,'FSU-8224-11Apr18-EH-DnDInvoiceAndSTkCntlUploadRep.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8228,'FSU-8228-16Apr18-EH-FSSAINumber.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8235,'FSU-8235-18Apr18-DC-ResetDt-StkcntRpt.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8242,'FSU-8242-24Apr18-DC-DSTypeImage.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8246,'FSU-8246-27Apr18-DC-Resend_DnDRFAXML.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8244,'FSU-8244-24Apr18-EH-CPL_Upload_Report.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8246,'FSU-8246-27Apr18-DC-Resend_DnDRFAXML.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8262,'FSU-8262-16May18-DC-TallyIntegration4_TradeDisc.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8263,'FSU-8263-16May18-IG-mERP_Updates_APR2018.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8270,'FSU-8270-23May18-EH-CustRCSIDImpAuditLogRep.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8272,'FSU-8272-29May18-EH-SalesReturnSimplification.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8273,'FSU-8273-29May18-IG-InvAmend_SchemeIDChange.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8277,'FSU-8277-06Jun18-DC-FMCG_Inv_Disclaimer.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8286,'FSU-8286-20Jun18-EH-SalesReturnSimplification-Part2.FSU')
						Insert Into #temptblInstallationDetail(FSUID,FileName) Values (8301,'FSU-8301-30Jun18-EH-VehicleAllocation')
					End

					Begin
						Declare @tblClientID Int
							Select @tblClientID = Max(ClientiD) from tblClientMaster Where Isnull(IsServer,0) = 1
				
							Insert Into tblInstallationDetail (ClientID,FSUID,ReleaseID,[FileName],Targettool,MaxSkip,SkipCount,DependentFUID,SeverityType,Mode,LocalPath,ExtractedFilePath,InstallationDate,DateofInstallation,
							Status,CreationDate,ModifiedDate,CreatedUser,ModifiedUser,CreatedApplication,ModifiedApplication)
							Select Isnull(@tblClientID,1),FSUID,Null,[FileName],1,0,Null,Null,1,1,'',Null,Null,Null,5,getdate(),Getdate(),Null,Null,Null,Null from #temptblInstallationDetail
					End


					Begin
							
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (2,6882)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (3,6883)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (4,6884)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (5,6885)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (6,6919)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (8,7053)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (9,7083)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (10,7097)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (11,7104)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (13,7153)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (14,7155)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (14,7155)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (15,7157)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (15,7157)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (16,7166)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (16,7166)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (17,7167)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (18,7189)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (19,7207)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (20,7210)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (21,7211)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (22,7214)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (22,7214)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (22,7214)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (24,7231)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (25,7232)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (26,7239)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (27,7258)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (28,7265)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (29,7278)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (30,7287)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (31,7304)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (32,7312)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (33,7313)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (33,7313)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (34,7314)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (35,7367)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (36,7406)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (36,7406)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (36,7406)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (36,7406)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (37,7420)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (38,7422)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (39,7423)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (40,7437)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (40,7437)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (41,7439)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (41,7439)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (41,7439)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (42,7440)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (44,7461)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (44,7461)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (45,7510)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,7440)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,7231)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,7312)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,7422)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,7510)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,7314)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,7406)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,7313)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,7097)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,7083)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,6883)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,6884)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,6885)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (47,7214)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (48,7655)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (49,7656)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (50,7655)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (52,7657)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (53,7663)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (55,7406)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (55,7656)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (56,7656)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (56,7658)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (57,7665)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (59,7665)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (62,7675)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (63,7663)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (64,7656)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (64,7663)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (64,7685)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (64,7689)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (65,7658)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (65,7675)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (72,7709)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (80,7678)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (84,7709)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (84,7675)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (89,7709)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (92,7749)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (95,7675)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (98,7749)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (101,7716)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (102,7799)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (103,7675)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (104,7799)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (106,7663)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (107,7810)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (111,7782)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (111,7685)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (113,7655)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (117,7810)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (119,7655)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (120,7663)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (120,7709)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (122,7655)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (123,7912)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (124,7904)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (124,7912)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (126,7675)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (126,7810)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (127,7899)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (128,7675)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (128,7709)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (128,7904)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (129,7871)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (130,7932)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (132,7912)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (133,7655)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (135,7954)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (136,7954)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (137,7954)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (138,7932)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (139,7927)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (141,7912)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (151,7954)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (159,7954)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (160,7932)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (161,7954)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (164,7927)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (165,7932)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (166,7675)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (166,7406)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (167,7929)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (168,7232)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (169,7799)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (170,8033)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (172,7932)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (173,7155)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (173,7694)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (177,7932)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (178,8060)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (179,8097)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (180,7912)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (180,8093)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (182,7799)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (184,7932)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (184,8052)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (185,8125)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (186,8105)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (188,8105)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (190,8128)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (194,8097)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (196,7657)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (196,7689)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (196,8125)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (196,7685)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (196,7904)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (199,8181)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (199,7655)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (199,8093)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (199,8125)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (199,8154)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (200,7934)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (200,8186)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (202,8186)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (206,8154)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (207,8207)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (208,8154)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (209,8154)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (209,8186)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (210,8186)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (210,7814)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (210,7799)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (210,8115)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (210,7675)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (210,7658)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (210,8052)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (210,7655)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (211,8224)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (213,8224)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (214,8154)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (215,8224)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (216,8187)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (217,8079)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (217,8186)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (217,8228)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (217,8209)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (217,7904)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (218,8263)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (219,8079)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (219,7932)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (219,8186)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (220,8272)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (221,8228)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (118,7655)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (198,7655)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (198,8185)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (222,8272)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (223,7709)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (223,8228)
							Insert Into #TemptblDependentDetail (InstallationID,DependentFSUID) Values (223,8272)
					End

			Declare @DCID Int
			Declare @DCFSUID Int
			Declare @DCInstallationID Int

					Declare Dependent_Details Cursor for
						Select ID,FSUID from #temptblInstallationDetail	--where FSUID = '7655'
					Open Dependent_Details
					Fetch from Dependent_Details into @DCID,@DCFSUID
					While @@FETCH_STATUS=0
					Begin
						Begin
							If (Select Count(*) From #TemptblDependentDetail Where InstallationID = Isnull(@DCID,0)) > 0
							Begin
								Select @DCInstallationID = Max(InstallationID) from tblInstallationDetail where FSUID = @DCFSUID 
						
								Insert Into tblDependentDetail(InstallationID,DependentFSUID)
								Select Isnull(@DCInstallationID,0),DependentFSUID From #TemptblDependentDetail Where InstallationID = Isnull(@DCID,0)
							End
						End
					Fetch from Dependent_Details into @DCID,@DCFSUID
					End
					Close Dependent_Details
					Deallocate Dependent_Details


					Drop Table #temptblInstallationDetail
					Drop Table #TemptblDependentDetail

		End

		
END
