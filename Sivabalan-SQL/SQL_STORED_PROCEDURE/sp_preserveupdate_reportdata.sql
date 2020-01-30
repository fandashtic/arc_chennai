CREATE Procedure [dbo].[sp_preserveupdate_reportdata]    
as      
-- update report table   
update ReportData set       
  ReportData.[ID] = TemplateDB.dbo.ReportData.[ID],      
  ReportData.[Node] = TemplateDB.dbo.ReportData.[Node],       
  ReportData.[Action] = TemplateDB.dbo.ReportData.[Action],       
  ReportData.[ActionData] = TemplateDB.dbo.ReportData.[ActionData],       
  ReportData.[Description] = TemplateDB.dbo.ReportData.[Description],       
  ReportData.[Parent] = TemplateDB.dbo.ReportData.[Parent],       
  ReportData.[Parameters] = TemplateDB.dbo.ReportData.[Parameters],       
  ReportData.[Image] = TemplateDB.dbo.ReportData.[Image],       
  ReportData.[SelectedImage] = TemplateDB.dbo.ReportData.[SelectedImage],       
  ReportData.[FormatID] = TemplateDB.dbo.ReportData.[FormatID],       
  ReportData.[DetailCommand] = TemplateDB.dbo.ReportData.[DetailCommand],       
  ReportData.[KeyType] = TemplateDB.dbo.ReportData.[KeyType],       
  ReportData.[Inactive] = TemplateDB.dbo.ReportData.[Inactive],       
  ReportData.[ForwardParam] = TemplateDB.dbo.ReportData.[ForwardParam]      
from ReportData RD, TemplateDB.dbo.ReportData      
where  ReportData.id = TemplateDB.dbo.ReportData.id      
--Begin: Service version impact  
--if (select Count(ID) from SysColumns   
--where ID = Object_ID('ReportData') and Name in ('Print_level','Report_Column',  
--'Report_Columnkey','Print_Drilldown_Header','Relatives_ID')) = 5  
--begin  
-- update ReportData set  
--  ReportData.[Report_Column] = TemplateDB.dbo.ReportData.[Report_Column],  
--  ReportData.[Report_Columnkey] = TemplateDB.dbo.ReportData.[Report_Columnkey],  
--  ReportData.[Relatives_ID] = TemplateDB.dbo.ReportData.[Relatives_ID]  
-- from ReportData  
-- Inner Join TemplateDB.dbo.ReportData ON ReportData.[ID] = TemplateDB.dbo.ReportData.[ID]  
--end  
--End: Service version impact  
--Since EVAT report is not required for ITC except kerala WD, ITC requested us to remove it in new version. (UAT point)
insert into ReportData select * from TemplateDB.dbo.ReportData where id not in (select id from ReportData) 
and id <> 977
--Hidden reports
--Truncate table tbl_mERP_OtherReportsUpload
--Begin  
--SET IDENTITY_INSERT tbl_mERP_OtherReportsUpload ON    
--insert into tbl_mERP_OtherReportsUpload (ReportID,
--ReportName,
--Frequency,
--ParameterID,
--CompanyID,
--ReportDataID,
--DayOfMonthWeek,
--AliasActionData,
--GenOrderBy,
--SendParamValidate,
--GracePeriod,
--LatestDoc,
--LastUploadDate,
--AbstractData,
--XMLReportCode)
-- select * from TemplateDB.dbo.tbl_mERP_OtherReportsUpload where reportid not in(select reportid from tbl_mERP_OtherReportsUpload)
--SET IDENTITY_INSERT tbl_mERP_OtherReportsUpload OFF    
--End  

--Not required for 6.1.2  
--Begin: Service version impact  
--if (select Count(ID) from SysColumns   
--where ID = Object_ID('PrintSpecs') and Name in ('ReportLevel','Hide',  
--'Report_Columnkey','OrginalColIndex')) = 4  
--begin  
-- update PrintSpecs set  
--  PrintSpecs.[ReportLevel] = TemplateDB.dbo.PrintSpecs.[ReportLevel],  
--  PrintSpecs.[Hide] = TemplateDB.dbo.PrintSpecs.[Hide],  
--  PrintSpecs.[Report_Columnkey] = TemplateDB.dbo.PrintSpecs.[Report_Columnkey],  
--  PrintSpecs.[OrginalColIndex] = TemplateDB.dbo.PrintSpecs.[OrginalColIndex]  
-- from PrintSpecs  
-- Inner Join TemplateDB.dbo.PrintSpecs ON PrintSpecs.[ID] = TemplateDB.dbo.PrintSpecs.[ID]   
-- and PrintSpecs.[ColIndex] = TemplateDB.dbo.PrintSpecs.[ColIndex]  
-- and isNull(PrintSpecs.[SpecialField],'') = isNull(TemplateDB.dbo.PrintSpecs.[SpecialField],'')  
-- Where PrintSpecs.[ID] >= 2000  
--end  
----End: Service version impact  
--  
--Insert into PrintSpecs Select * From TemplateDB.dbo.PrintSpecs where ID not in (Select ID from PrintSpecs)    

Truncate Table ParameterInfo    
Insert into ParameterInfo Select * From TemplateDB.dbo.ParameterInfo 
   
--Truncate Table FormatInfo    
--SET IDENTITY_INSERT FormatInfo ON    
--Insert into FormatInfo(ID, FormatID, ColWidth, ColAlignment) Select * From TemplateDB.dbo.FormatInfo    
--SET IDENTITY_INSERT FormatInfo OFF 
   
Truncate Table QueryParams    
Insert into QueryParams([Values], QueryParamID) Select [Values], QueryParamID From TemplateDB.dbo.QueryParams    

Truncate Table QueryParams2    
Insert into QueryParams2 Select * From TemplateDB.dbo.QueryParams2    

If (Select Count(*) From CustomPrinting) = 0    
Begin    
SET IDENTITY_INSERT CustomPrinting ON    
Insert into CustomPrinting(TransactionName, PrintFileName, DefaultFileName)   
Select TransactionName, PrintFileName, DefaultFileName From TemplateDB.dbo.CustomPrinting    
Where PrintFileName Not In (Select PrintFileName From CustomPrinting)  
SET IDENTITY_INSERT CustomPrinting OFF    
End    
--TRUNCATE Table UpgradeTables    
--SET IDENTITY_INSERT UpgradeTables ON    
--Insert into UpgradeTables(TableID, TableName, UpgradeCriteria) Select TableID, TableName, UpgradeCriteria From TemplateDB.dbo.UpgradeTables    
--SET IDENTITY_INSERT UpgradeTables OFF    
Truncate Table QueryParams1    
Insert into QueryParams1 Select * From TemplateDB.dbo.QueryParams1   
 
--Update Collections Set CreationTime = DocumentDate Where CreationTime Is Null    
--Update Payments Set CreationTime = DocumentDate Where CreationTime Is Null    
--Update StockAdjustmentAbstract Set CreationDate = AdjustmentDate Where CreationDate Is Null    
--Update AdjustmentReturnAbstract Set CreationTime = AdjustmentDate Where CreationTime Is Null    
--Update CreditNote Set CreationTime = DocumentDate Where CreationTime Is Null    
--Update DebitNote Set CreationTime = DocumentDate Where CreationTime Is Null    
--Update StockTransferInAbstract Set CreationDate = DocumentDate Where CreationDate Is Null    
--Update StockTransferOutAbstract Set CreationDate = DocumentDate Where CreationDate Is Null    
--Update VanStatementAbstract Set CreationTime = DocumentDate Where CreationTime Is Null  
--Update AdjustmentReturnAbstract Set Total_Value = Value Where Total_Value Is Null  
--Update AdjustmentReturnDetail Set Total_Value = Quantity*Rate Where Total_Value Is Null  
--Update Stock_Request_Abstract Set CreationTime = Stock_Req_Date Where CreationTime Is Null  
----Update SchemeSale Set Flags = IsNull(Flags, 0) | IsNull(SecondaryScheme,0)  
----From SchemeSale, Schemes  
----Where SchemeSale.Type = Schemes.SchemeID  
----Update SchemeSale Set Pending = Free Where IsNull(Claimed,0) = 0  
--If (Select Count(*) From Customer_Channel) = 0  
--Begin  
--SET IDENTITY_INSERT Customer_Channel ON   
--Insert into Customer_Channel(ChannelType, ChannelDesc, Active) Select ChannelType, ChannelDesc, Active From TemplateDB.dbo.Customer_Channel   
--SET IDENTITY_INSERT Customer_Channel OFF    
--End  
--If (Select Count(*) From Customer_Channel) = 0  
--Begin  
--SET IDENTITY_INSERT Customer_Channel ON   
--Insert into Customer_Channel(ChannelType, ChannelDesc, Active) Select ChannelType, ChannelDesc, Active From TemplateDB.dbo.Customer_Channel   
--SET IDENTITY_INSERT Customer_Channel OFF    
--End  
--
--If (Select Count(*) From PaymentMode) = 0  
--Begin  
--SET IDENTITY_INSERT PaymentMode ON    
--Insert into PaymentMode(mode, value, active, PaymentType) Select mode, value, active, PaymentType From TemplateDB.dbo.PaymentMode  
--SET IDENTITY_INSERT PaymentMode OFF    
--End  
--XMLDataMap and XMLColumnMap handled  
--Truncate Table XMLDataMap      
--Insert into XMLDataMap(DocType, AbstractProc, AbstractMap, DetailProc, DetailMap) Select DocType, AbstractProc, AbstractMap, DetailProc, DetailMap From TemplateDB.dbo.XMLDataMap  
--Truncate Table XMLColumnMap      
--Insert into XMLColumnMap(ColumnID, ColumnSource, ColumnInfo, SourceDataType) Select ColumnID, ColumnSource, ColumnInfo, SourceDataType From TemplateDB.dbo.XMLColumnMap  
  
--If Not Exists(Select * From DynamicProcedure Where SourceProcName Like 'sp_print_RetInvItems_SR_Template')  
--Begin  
--Insert Into DynamicProcedure Values ('sp_Create_TaxComp_Fields',   
--'sp_print_RetInvItems_SR_Template', 'Create Procedure sp_print_RetInvItems_SR_Template(@INVNO INT)',   
--'Alter Procedure sp_print_RetInvItems_SR(@INVNO INT)', ', ''TaxComponents''')  
--End  
--  
--If Not Exists(Select * From DynamicProcedure Where SourceProcName Like 'Sp_Print_InvAbstract')  
--Begin  
--Insert Into DynamicProcedure Values ('sp_create_adjustment_printing',   
--'Sp_Print_InvAbstract', 'Create Procedure sp_Print_InvAbstract(@INVNO INT)',   
--'Alter Procedure sp_Print_InvAbstract(@INVNO INT)', ', ''AdjustmentComponent''')  
--End  
--  
--Update DynamicProcedure set ReplaceParameter = ', ''TaxComponents''' Where   
--BaseProcName In ('sp_Create_TaxComp_Fields' , 'sp_Create_TaxCompTotal_Fields')  
--  
--Update DynamicProcedure set ReplaceParameter = ', ''AdjustmentComponent''' Where   
--BaseProcName = 'sp_create_adjustment_printing'  

--For other Tables

--Truncate table tbl_merp_UploadParam_Exception 
--insert into tbl_merp_UploadParam_Exception Select * from TemplateDB.dbo.tbl_merp_UploadParam_Exception 


--Truncate table tbl_mERP_DynamicParameterDetail
--set IDENTITY_INSERT tbl_mERP_DynamicParameterDetail ON
--insert into tbl_mERP_DynamicParameterDetail(Id,
--DynamicID,
--HeaderName,
--HeaderType,
--DataType,
--Width,
--Description,
--CreationDate) 
--Select Id,
--DynamicID,
--HeaderName,
--HeaderType,
--DataType,
--Width,
--Description,
--CreationDate from TemplateDB.dbo.tbl_mERP_DynamicParameterDetail where id not in (select id from tbl_mERP_DynamicParameterDetail)
--set IDENTITY_INSERT tbl_mERP_DynamicParameterDetail OFF

update Reports_to_upload set
ReportName=TemplateDB.dbo.Reports_to_upload.ReportName,
Frequency=TemplateDB.dbo.Reports_to_upload.Frequency,
ParameterID=TemplateDB.dbo.Reports_to_upload.ParameterID,
CompanyID=TemplateDB.dbo.Reports_to_upload.CompanyID,
DayOfMonthWeek=TemplateDB.dbo.Reports_to_upload.DayOfMonthWeek,
AliasActionData=TemplateDB.dbo.Reports_to_upload.AliasActionData,
GenOrderBy=TemplateDB.dbo.Reports_to_upload.GenOrderBy,
SendParamValidate=TemplateDB.dbo.Reports_to_upload.SendParamValidate,
GracePeriod=TemplateDB.dbo.Reports_to_upload.GracePeriod,
LatestDoc=TemplateDB.dbo.Reports_to_upload.LatestDoc,
AbstractData=TemplateDB.dbo.Reports_to_upload.AbstractData,
XMLReportCode=TemplateDB.dbo.Reports_to_upload.XMLReportCode
from Reports_to_upload A,TemplateDB..Reports_to_upload
where A.ReportDataID=TemplateDB.dbo.Reports_to_upload.ReportDataID

insert into Reports_to_upload (
ReportName,
Frequency,
ParameterID,
CompanyID,
ReportDataID,
DayOfMonthWeek,
AliasActionData,
GenOrderBy,
SendParamValidate,
GracePeriod,
LatestDoc,
LastUploadDate,
AbstractData,
XMLReportCode)
Select 
ReportName,
Frequency,
ParameterID,
CompanyID,
ReportDataID,
DayOfMonthWeek,
AliasActionData,
GenOrderBy,
SendParamValidate,
GracePeriod,
LatestDoc,
LastUploadDate,
AbstractData,
XMLReportCode from TemplateDB.dbo.Reports_to_upload where reportDataid not in (select reportDataid from Reports_to_upload)

Truncate table ReportParameters_Upload
insert into ReportParameters_Upload Select * from TemplateDB.dbo.ReportParameters_Upload 

Delete from ReportParameters_Upload where ParameterID = 6

IF(Select Flag From tbl_mERP_ConfigAbstract where screencode = 'OCGDS') = 1
Begin
	
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'Salesman Name','$All Salesman',200,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'Salesman Type','$All SalesmanType',200,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'Category Group Type','$All',200,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'Product Hierarchy','',200,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'Category Group','$All Category Groups',200,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'Category','$All Salesman',200,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'From Date','$Date',7,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'To Date','$Date',10,0)
	Update Reports_To_upload Set ParameterID = 6 Where ReportDataID = 898	--16.TMD - Salesman Productivity Measures	
End
Else
Begin
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'Salesman Name','$All Salesman',200,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'Salesman Type','$All SalesmanType',200,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'Product Hierarchy','',200,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'Category Group','$All Category Groups',200,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'Category','$All Salesman',200,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'From Date','$Date',7,0)
	Insert Into ReportParameters_Upload(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type, Skip) Values(6,'To Date','$Date',10,0)
	Update Reports_To_upload Set ParameterID = 6 Where ReportDataID = 898	--16.TMD - Salesman Productivity Measures	
End

Delete from ParameterInfo WHERE ParameterID = 306	

If Not Exists (Select * from ParameterInfo WHERE ParameterID = 306)
BEGIN
	IF(Select Flag From tbl_mERP_ConfigAbstract where screencode = 'OCGDS') = 1
	Begin
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'Salesman Name',200,'$All Salesman','Salesman:Salesman_Name',1,0,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'Salesman Type',200,'$All SalesmanType','DSType_Master:DSTypeValue:OCGType in (Select case when Flag =1 then 0 else flag end  from tbl_merp_configabstract where screencode = ''OCGDS'' union Select Top 1 Flag from tbl_merp_configabstract where screencode = ''OCGDS'') And DSTypeCtlPos = 1 And DSTypeValue like ''%''',1,0,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'Category Group Type',200,'$All','QueryParams:[Values]:QueryParamID IN(103) And [Values] like ''%''',Null,NUll,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'Product Hierarchy',200,'','ItemHierarchy:HierarchyName:HierarchyID IN(2,3) And HierarchyName like ''%''',0,0,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'Category Group',200,'$All Category Groups','ProductCategoryGroupAbstract:GroupName:GroupID In (Select * From dbo.fn_GetOCGName({$3})) and GroupName like ''%''',1,0,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'Category',200,'$All Categories','ItemCategories:Category_Name:CategoryID In   (Select * From dbo.fn_GetCatFrmCG_ITC_OCG({$5},{$4},Default,{$3})) and Category_Name like ''%''',1,0,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'From Date',7,'$MFDate',Null,0,0,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'To Date',10,'$Date',Null,0,0,'')
	End
	Else
	Begin
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'Salesman Name',200,'$All Salesman','Salesman:Salesman_Name',1,0,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'Salesman Type',200,'$All SalesmanType','DSType_Master:DSTypeValue:OCGType in (Select case when Flag =1 then 0 else flag end  from tbl_merp_configabstract where screencode = ''OCGDS'' union Select Top 1 Flag from tbl_merp_configabstract where screencode = ''OCGDS'') And DSTypeCtlPos = 1 And DSTypeValue like ''%''',1,0,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'Product Hierarchy',200,'','ItemHierarchy:HierarchyName:HierarchyID IN(2,3) And HierarchyName like ''%''',0,0,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'Category Group',200,'$All Category Groups','ProductCategoryGroupAbstract:GroupName:GroupID In (Select * From dbo.fn_GetOCGName({$3})) and GroupName like ''%''',1,0,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'Category',200,'$All Categories','ItemCategories:Category_Name:CategoryID In   (Select * From dbo.fn_GetCatFrmCG_ITC_OCG({$5},{$4},Default,{$3})) and Category_Name like ''%''',1,0,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'From Date',7,'$MFDate',Null,0,0,'')
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID,orderby)
		Values(306,'To Date',10,'$Date',Null,0,0,'')		
	End
END

IF(Select Flag From tbl_mERP_ConfigAbstract where screencode = 'OCGDS') = 1
Begin
	Update Reports_To_Upload Set AliasActionData = 'spr_SMan_Productivity_Measures_Upload_OCG'  Where ReportDataID = 898
	Update ReportData Set ActionData = 'spr_SMan_Productivity_Measures_OCG' Where ID = 898
	Update ReportData Set ActionData = 'spr_TMD_Daily_SPM_OCG' Where ID = 1160
End
Else
Begin
	Update Reports_To_Upload Set AliasActionData = 'spr_SMan_Productivity_Measures_Upload'  Where ReportDataID = 898
	Update ReportData Set ActionData = 'spr_SMan_Productivity_Measures' Where ID = 898
	Update ReportData Set ActionData = 'spr_TMD_Daily_SPM' Where ID = 1160	
End
