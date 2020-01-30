
Create Procedure mERP_sp_VersionUpgrade_ITC
As
Begin
--Not Required for 6.1.2 bcoz already these information is exist in Existing DB
Select 1
---- Insert New channels
--Insert InTo Customer_Channel (ChannelDesc,Active)
--Select ChannelDesc,Active From TemplateDB.dbo.Customer_Channel
--Where ChannelDesc Not In (Select ChannelDesc From Customer_Channel)

--Update Customer_Channel Set Code = TemplateDB.dbo.Customer_Channel.Code 
--From TemplateDB.dbo.Customer_Channel 
--Where TemplateDB.dbo.Customer_Channel.ChannelDesc = Customer_Channel.ChannelDesc

---- Insert New Sub Channels
--Insert InTo SubChannel ([Description], Active)
--Select [Description], Active From TemplateDB.dbo.SubChannel
--Where  [Description] Not In (Select [Description] From SubChannel)
--
---- New DSType_Master move to upgrade table.
--Insert InTo DSType_Master (DSTypeName, DSTypeValue, DSTypeCtlPos, Active)
--Select DSTypeName, DSTypeValue, DSTypeCtlPos, Active From TemplateDB.dbo.DSType_Master
--Where DSTypeValue Not In (Select DSTypeValue From DSType_Master Where DSTypeCtlPos in (1,2))

----tbl_mERP_OLClass
--Insert InTo DSType_Master (DSTypeName, DSTypeValue, DSTypeCtlPos, Active)
--Select DSTypeName, DSTypeValue, DSTypeCtlPos, Active From TemplateDB.dbo.DSType_Master
--Where DSTypeValue Not In (Select DSTypeValue From DSType_Master Where DSTypeCtlPos in (1,2))


--Import Customer TMD RCS Master Template entry.
Insert InTo ImportTemplates (TemplateName ,Active)
Select TemplateName , Active from TemplateDB.dbo.ImportTemplates 
Where TemplateName Not In (Select TemplateName from ImportTemplates)

-- Insert Merchandise
Insert Into Merchandise (Merchandise,Active)
Select Merchandise,Active From TemplateDB.dbo.Merchandise 
Where Merchandise Not In (Select Merchandise From Merchandise)

--
--Declare @RUDate DateTime
--Set @RUDate = (Select Case When ReportUploadDate Is Null Then OpeningDate Else ReportUploadDate End From Setup)
--
------ Insert ReportsToUpload
--/********************************/
--
--Insert Into Reports_To_Upload 
--(ReportName,Frequency,ParameterID,CompanyID,ReportDataID,DayOfMonthWeek, AliasActionData, GenOrderBy, SendParamValidate, GracePeriod, LatestDoc, LastUploadDate)
--Select ReportName,Frequency,ParameterID,CompanyID,ReportDataID,DayOfMonthWeek, AliasActionData, GenOrderBy, SendParamValidate, GracePeriod, LatestDoc , @RUDate
--From TemplateDB.dbo.Reports_To_Upload
--Where TemplateDB.dbo.Reports_To_Upload.ReportName Not In (Select ReportName From Reports_To_Upload)
--
----Select * from reports_to_upload
--Update Reports_To_Upload 
--Set LastUploadDate = @RUDate
--From TemplateDB.dbo.Reports_To_Upload
--Where TemplateDB.dbo.Reports_To_Upload.ReportName = Reports_To_Upload.ReportName
--And Reports_To_Upload.SendParamValidate Is Null 
--And Reports_To_Upload.GracePeriod Is Null
--And Reports_To_Upload.LatestDoc Is Null
--And Reports_To_Upload.LastUploadDate Is Null
--
--Update Reports_To_Upload 
--Set SendParamValidate = TemplateDB.dbo.Reports_To_Upload.SendParamValidate, 
--GracePeriod = TemplateDB.dbo.Reports_To_Upload.GracePeriod,
--LatestDoc = TemplateDB.dbo.Reports_To_Upload.LatestDoc,
--Frequency = TemplateDB.dbo.Reports_To_Upload.Frequency
--From TemplateDB.dbo.Reports_To_Upload
--Where TemplateDB.dbo.Reports_To_Upload.ReportName = Reports_To_Upload.ReportName
--
--/********************************/
--
--Truncate Table ReportParameters_Upload
---- Insert ReportParameters_Upload
--Insert ReportParameters_Upload
--(ParameterID, Parameter_Name, Parameter_Value, Parameter_Type,Skip)
--Select ParameterID, Parameter_Name, Parameter_Value, Parameter_Type,Skip
--From TemplateDB.dbo.ReportParameters_Upload 
--
Truncate Table Shortcuts
-- Insert Shortcut messages
Insert InTo Shortcuts (Message,TransactionType,Active,OrderNo)
Select Message,TransactionType,Active,OrderNo
from TemplateDB.dbo.Shortcuts
--
--Truncate Table RetailCustomerCategory
---- Insert Retail Customer Category
--Insert InTo RetailCustomerCategory (CategoryName,Active,CreationDate)
--Select CategoryName,Active,getdate() From TemplateDB.dbo.RetailCustomerCategory

Truncate Table del_Table_List
-- Insert Close period regarding table data
Insert InTo del_Table_List 
(Table_Name, Del_Where, Sort_Order, Is_Processed, Istruncate, IsConstraint, PreSql, PostSql)
Select 
Table_Name, Del_Where, Sort_Order, Is_Processed, Istruncate, IsConstraint, PreSql, PostSql
From TemplateDB.dbo.del_Table_List

--Truncate Table ColorSettings
----Insert New Colors
--Insert InTO ColorSettings (Items, BackColor, ForeColor)
--Select Items, BackColor, ForeColor From TemplateDB.dbo.ColorSettings 

----Insert / Update XMLSplitup table data

--Update XMLSplitup 
--Set Splitup = TemplateDB.dbo.XMLSplitup.Splitup , ModifyDate = getdate()
--From TemplateDB.dbo.XMLSplitup 
--Where XMLSplitup.ReportDataID = TemplateDB.dbo.XMLSplitup.ReportDataID
--
--Insert InTo XMLSplitup (ReportDataID, ReportName, Splitup)
--Select ReportDataID, ReportName, Splitup From TemplateDB.dbo.XMLSplitup 
--Where TemplateDB.dbo.XMLSplitup.ReportDataID Not In
--(Select ReportDataID From XMLSplitup) 

--Update ReportData Set SelectedImage = 2 
--
--Update Customer Set ModifiedDate = GetDate() Where ModifiedDate Is Null
--
---- Changes for 6.1.1
--Insert InTo tblTools (Tool_ID, Tool_Data, Tool_Value)
--Select Tool_ID, Tool_Data, Tool_Value From TemplateDB.dbo.tblTools
--Where TemplateDB.dbo.tblTools.Tool_ID Not In (Select Tool_ID From tblTools)
--
----Insert All Error Messgaes
--Truncate Table ErrorMessages
--Insert InTo ErrorMessages (ErrorID, Message,Comment)
--Select ErrorID, Message, Comment From TemplateDB.dbo.ErrorMessages
--
---- Insert Config Values
--
---- Abs
--Insert InTo tbl_mERP_ConfigAbstract (ScreenCode, ScreenName, Description, Flag)
--Select ScreenCode, ScreenName, Description, Flag From TemplateDB.dbo.tbl_mERP_ConfigAbstract
--Where TemplateDB.dbo.tbl_mERP_ConfigAbstract.ScreenCode Not In (Select ScreenCode From tbl_mERP_ConfigAbstract)
--
---- Det
--Insert InTo tbl_mERP_ConfigDetail 
--(ScreenCode, ControlName, XMLAttribute, ControlIndex, Description, TabIndex, TabLevel, AllowConfig, TabName, Flag)
--Select ScreenCode, ControlName, XMLAttribute, ControlIndex, Description, TabIndex, TabLevel, AllowConfig, TabName, Flag
--From TemplateDB.dbo.tbl_mERP_ConfigDetail
--Where TemplateDB.dbo.tbl_mERP_ConfigDetail.ScreenCode Not In (Select Distinct ScreenCode From tbl_mERP_ConfigDetail)
--
-- Insert ReasonMaster Values
--Truncate Table ReasonMaster
--Insert Into ReasonMaster (Reason_Type,Reason_SubType,Reason_Description,Screen_Applicable)
--Select Reason_Type,Reason_SubType,Reason_Description,Screen_Applicable From TemplateDB.dbo.ReasonMaster
--
---- Insert tblCGDivMapping Data
--Insert Into tblCGDivMapping (MapID ,Division ,CategoryGroup)
--Select MapID ,Division ,CategoryGroup From TemplateDB.dbo.tblCGDivMapping
--Where TemplateDB.dbo.tblCGDivMapping.Division Not In (Select Division From tblCGDivMapping)
--
-----Insert DSTypeLabel Data
--Insert Into DSTypeLabel (ControlPos,LabelName)
--Select ControlPos,LabelName From TemplateDB.dbo.DSTypeLabel
--Where TemplateDB.dbo.DSTypeLabel.ControlPos Not In (Select ControlPos From DSTypeLabel)
--
---- Insert ItemsRecUpdateStatus Data
--Insert InTo ItemsRecUpdateStatus (NodeGramps, ChildNode, Sno, Attributes, AllowUpdate)
--Select NodeGramps, ChildNode, Sno, Attributes, AllowUpdate 
--From TemplateDB.dbo.ItemsRecUpdateStatus
--Where TemplateDB.dbo.ItemsRecUpdateStatus.NodeGramps Not in (Select NodeGramps From ItemsRecUpdateStatus)
--
--If Exists(select * from ATH_Client_ConfigDB..R1ATH_Client_CodeMS where Code_Defn='CustomerConfig')
--Begin
--Delete from ATH_Client_ConfigDB..R1ATH_Client_CodeMS Where Code_Name = 34
--Insert InTo ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMCSC',34,'CustomerConfig',getdate())
--End
--Else
--Begin
--Insert InTo ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMCSC',34,'CustomerConfig',getdate())
--End
--
--If Exists(select * from ATH_Client_ConfigDB..R1ATH_Client_CodeMS where Code_Defn='ACK')
--Begin
--Delete from ATH_Client_ConfigDB..R1ATH_Client_CodeMS Where Code_Name = 42
--Insert InTo ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMACK',42,'ACK',getdate())
--End
--Else
--Begin
--Insert InTo ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMACK',42,'ACK',getdate())
--End
--
--If Exists(select * from ATH_Client_ConfigDB..R1ATH_Client_CodeMS where Code_Defn='Marginupdate')
--Begin
--Delete from ATH_Client_ConfigDB..R1ATH_Client_CodeMS Where Code_Name = 39
--Insert InTo ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMMAR',39,'Marginupdate',getdate())
--End
--Else
--Begin
--Insert InTo ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMMAR',39,'Marginupdate',getdate())
--End
--
--If Exists(select * from ATH_Client_ConfigDB..R1ATH_Client_CodeMS where Code_Defn='QuotationChannel')
--Begin
--Delete from ATH_Client_ConfigDB..R1ATH_Client_CodeMS Where Code_Name = 40
--Insert InTo ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMQOt',40,'QuotationChannel',getdate())
--End
--Else
--Begin
--Insert InTo ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMQOT',40,'QuotationChannel',getdate())
--End
--
--If Exists(select * from ATH_Client_ConfigDB..R1ATH_Client_CodeMS where Code_Defn='RFA')
--Begin
--Delete from ATH_Client_ConfigDB..R1ATH_Client_CodeMS Where Code_Defn='RFA'
--Insert InTo ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMRFA',41,'RFA',getdate())
--End
--Else
--Begin
--Insert InTo ATH_Client_ConfigDB..R1ATH_Client_CodeMS values('DTFORUMRFA',41,'RFA',getdate())
--End
--exec sp_UpdateDSTypeMapping
End
