CREATE procedure [dbo].[sp_acc_upgrade_table_data]
AS
Update AdjustmentReason Set AdjustmentReason.AccountID = TemplateDB.dbo.AdjustmentReason.AccountID
from 	AdjustmentReason, TemplateDB.dbo.AdjustmentReason
Where   AdjustmentReason.Reason = TemplateDB.dbo.AdjustmentReason.Reason And
	AdjustmentReason.AccountID Is Null
If (Select Count(*) From AdjustmentReason) = 0
Begin
SET IDENTITY_INSERT AdjustmentReason ON
Insert into AdjustmentReason(AdjReasonID, Reason, Description, Claimed, Active, CreationDate, AccountID) 
Select * From TemplateDB.dbo.AdjustmentReason
SET IDENTITY_INSERT AdjustmentReason OFF
End
If (Select Count(*) From FAUpgradeStatus) = 0
Begin
Insert Into FAUpgradeStatus(ModuleName, DocumentID, Status) 
Select * From TemplateDB.dbo.FAUpgradeStatus
End
update AccountsMaster set   
		AccountsMaster.[AccountName] = TemplateDB.dbo.AccountsMaster.[AccountName],   
		AccountsMaster.[GroupID] = TemplateDB.dbo.AccountsMaster.[GroupID],   
		AccountsMaster.[Active] = TemplateDB.dbo.AccountsMaster.[Active],
		AccountsMaster.[DefaultGroupID] = TemplateDB.dbo.AccountsMaster.[DefaultGroupID]
from AccountsMaster , TemplateDB.dbo.AccountsMaster  
where  AccountsMaster.AccountID = TemplateDB.dbo.AccountsMaster.AccountID And
       AccountsMaster.Fixed = 1

update AccountGroup set   
		AccountGroup.[GroupName] = TemplateDB.dbo.AccountGroup.[GroupName],   
		AccountGroup.[ParentGroup] = TemplateDB.dbo.AccountGroup.[ParentGroup],   
		AccountGroup.[AccountType] = TemplateDB.dbo.AccountGroup.[AccountType],   
		AccountGroup.[Active] = TemplateDB.dbo.AccountGroup.[Active]
from AccountGroup , TemplateDB.dbo.AccountGroup  
where  AccountGroup.GroupID = TemplateDB.dbo.AccountGroup.GroupID And
       AccountGroup.Fixed = 1

set identity_insert AccountsMaster on
insert into AccountsMaster (AccountID,AccountName,GroupID,Active,Fixed,OpeningBalance,
AdditionalField1,AdditionalField2,AdditionalField3,AdditionalField4,AdditionalField5,
AdditionalField6,AdditionalField7,AdditionalField8,AdditionalField9,AdditionalField10,
AdditionalField11,AdditionalField12,AdditionalField13,AdditionalField14,CreationDate,
AdditionalField15,AdditionalField16,AdditionalField17,UserName,RetailPaymentMode,DefaultGroupID)
Select AccountID,AccountName,GroupID,Active,Fixed,OpeningBalance,AdditionalField1,
AdditionalField2,AdditionalField3,AdditionalField4,AdditionalField5,AdditionalField6,
AdditionalField7,AdditionalField8,AdditionalField9,AdditionalField10,AdditionalField11,
AdditionalField12,AdditionalField13,AdditionalField14,CreationDate,AdditionalField15,
AdditionalField16,AdditionalField17,UserName,RetailPaymentMode,DefaultGroupID 
From TemplateDB.dbo.AccountsMaster
Where AccountID > (Select IsNull(Max(AccountID),0) From AccountsMaster Where Fixed = 1)
And Fixed = 1
If (Select Count(AccountID) From AccountsMaster Where Fixed = 0 And AccountID = 500) = 0
Begin
Insert into AccountsMaster(AccountID,AccountName,GroupID,Active,Fixed)
Values (500, 'User Account Start', 0, 0, 0)
End
set identity_insert AccountsMaster off

set identity_insert AccountGroup on
insert into AccountGroup (GroupID,GroupName,AccountType,ParentGroup,Active,Fixed,
			  CreationDate,LastModifiedDate)
Select GroupID,GroupName,AccountType,ParentGroup,Active,Fixed,CreationDate,LastModifiedDate
From TemplateDB.dbo.AccountGroup
Where GroupID > (Select IsNull(Max(GroupID),0) From AccountGroup Where Fixed = 1)
And Fixed = 1
If (Select Count(GroupID) From AccountGroup Where Fixed = 0 And GroupID = 500) = 0
Begin
Insert into AccountGroup(GroupID,GroupName,AccountType,ParentGroup,Active,Fixed)
Values (500, 'User AccountGroup Start', 0, 0, 0, 0)
End
set identity_insert AccountGroup off

update FAReportData set   
		FAReportData.[ReportHeader] = TemplateDB.dbo.FAReportData.[ReportHeader],   
		FAReportData.[ReportTitle] = TemplateDB.dbo.FAReportData.[ReportTitle],   
		FAReportData.[Display] = TemplateDB.dbo.FAReportData.[Display],   
		FAReportData.[ParentID] = TemplateDB.dbo.FAReportData.[ParentID],   
		FAReportData.[ProcedureName] = TemplateDB.dbo.FAReportData.[ProcedureName],   
		FAReportData.[HiddenColumns] = TemplateDB.dbo.FAReportData.[HiddenColumns],   
		FAReportData.[ColumnAlignment] = TemplateDB.dbo.FAReportData.[ColumnAlignment],   
		FAReportData.[ColumnFormat] = TemplateDB.dbo.FAReportData.[ColumnFormat],   
		FAReportData.[ParameterReference] = TemplateDB.dbo.FAReportData.[ParameterReference],   
		FAReportData.[GroupID] = TemplateDB.dbo.FAReportData.[GroupID],  
		FAReportData.[SkipColumnWidth] = TemplateDB.dbo.FAReportData.[SkipColumnWidth],   
		FAReportData.[PrintTitle] = TemplateDB.dbo.FAReportData.[PrintTitle],
		FAReportData.[DefaultColumnWidth] = TemplateDB.dbo.FAReportData.[DefaultColumnWidth],
		FAReportData.[ReportOrder] = TemplateDB.dbo.FAReportData.[ReportOrder]
from FAReportData , TemplateDB.dbo.FAReportData  
where  FAReportData.ReportID = TemplateDB.dbo.FAReportData.ReportID  

SET IDENTITY_INSERT FAReportData ON
insert into FAReportData(ReportID,ReportHeader,ReportTitle,Display,ParentID,ProcedureName,
HiddenColumns,ColumnWidth,ColumnAlignment,ColumnFormat,ParameterReference,GroupID,
SkipColumnWidth,PrintTitle,Header,Footer,TopLineBreak,BottomLineBreak,PageLength,
TopMargin,BottomMargin,PrintWidth,PrintType,DefaultColumnWidth,ReportOrder)
select ReportID,ReportHeader,ReportTitle,Display,ParentID,ProcedureName,HiddenColumns,
ColumnWidth,ColumnAlignment,ColumnFormat,ParameterReference,GroupID,SkipColumnWidth,
PrintTitle,Header,Footer,TopLineBreak,BottomLineBreak,PageLength,TopMargin,BottomMargin,
PrintWidth,PrintType,DefaultColumnWidth,ReportOrder from TemplateDB.dbo.FAReportData 
where ReportID not in (select ReportID from FAReportData ) 
SET IDENTITY_INSERT FAReportData OFF

Insert into FAPrintSetting Select * From TemplateDB.dbo.FAPrintSetting
where ReportID not in (Select ReportID from FAPrintSetting)

--FAConsolidation implementation
-- Declare @Exist as integer
-- Select @Exist=Count(name) from syscolumns where id=(Select id from sysobjects where name='Setup' and type='U') and name='FAConsolidationSupport'
-- If @Exist=1
-- Begin
-- 	Update Setup Set FAConsolidationSupport=1
-- End
