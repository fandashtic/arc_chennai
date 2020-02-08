select * into #ParameterInfo
From ParameterInfo Where ParameterID in(40, 559)
--Exec ARC_GetUnusedReportId
Update #ParameterInfo Set ParameterID = 140
Delete From #ParameterInfo Where ParameterName = 'UOM'
select * from #ParameterInfo
If Not Exists(select top 1 1 from ParameterInfo Where ParameterID = 140)
Begin	
	Insert into ParameterInfo
	select * from #ParameterInfo
End
Drop table #ParameterInfo
GO
Insert Into ReportData(ID,Node,Action,ActionData,Description,Parent,Parameters,Image,SelectedImage,FormatID,DetailCommand,KeyType,Inactive,ForwardParam,PrintType,PrintWidth)
Select 53, 'Accounts', Action, ActionData, ' Click to view Accounts reports' , 151 , Parameters, Image, SelectedImage, FormatID, DetailCommand, KeyType, Inactive, ForwardParam, PrintType, PrintWidth from ReportData  Where Id = 151 UNION ALL
Select 70, 'Analysis', Action, ActionData, ' Click to view Analysis reports' , 151 , Parameters, Image, SelectedImage, FormatID, DetailCommand, KeyType, Inactive, ForwardParam, PrintType, PrintWidth from ReportData  Where Id = 151 UNION ALL 
Select 399, 'Master', Action, ActionData, ' Click to view Master reports' , 151 , Parameters, Image, SelectedImage, FormatID, DetailCommand, KeyType, Inactive, ForwardParam, PrintType, PrintWidth from ReportData  Where Id = 151 UNION ALL
Select 414, 'Billing', Action, ActionData, ' Click to view Billing reports' , 151 , Parameters, Image, SelectedImage, FormatID, DetailCommand, KeyType, Inactive, ForwardParam, PrintType, PrintWidth from ReportData  Where Id = 151 UNION ALL
Select 417, 'Warehouse', Action, ActionData, ' Click to view Warehouse reports' , 151 , Parameters, Image, SelectedImage, FormatID, DetailCommand, KeyType, Inactive, ForwardParam, PrintType, PrintWidth from ReportData  Where Id = 151
Select 376, 'Dump', Action, ActionData, ' Click to view dump reports' , 151 , Parameters, Image, SelectedImage, FormatID, DetailCommand, KeyType, Inactive, ForwardParam, PrintType, PrintWidth from ReportData  Where Id = 151

Update ReportData Set Parent = 53 Where Node In ('Outstanding Ledger By Customer wise', 'Outstanding Tracking Report By Customer', 'Stock Value By Month', 'WD Abstract', 'Collections Report', 'Collections - Advance', 'Collections CustomerWise')
Update ReportData Set Parent = 70 Where Node In ('BillsCut & LinesCut', 'Order Vs Invoice', 'Bill Vs Sales')
Update ReportData Set Parent = 399 Where Node In ('Items Master','Price List')
Update ReportData Set Parent = 414 Where Node In ('Vanloading Items', 'Vanloading Invoices')
Update ReportData Set Parent = 417 Where Node In ('Purchase Return', 'Stock Adjustment - Others', 'Non Moving Stock', 'Stock Adjustment - Damage', 'Daily Stock Movement', 'Consolidated Non Moving Stock', 'Order vs Invoice vs Delivery')
