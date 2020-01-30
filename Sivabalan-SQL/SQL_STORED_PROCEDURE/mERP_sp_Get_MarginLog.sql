Create Procedure mERP_sp_Get_MarginLog
As
Begin
	
	Select Count(*) From tbl_mERP_Margin_Log
	
Select 
		mlog.ID as [ID],
		Cast(mlog.BatchCode As nVarchar) as [BatchCode], 
		IsNull(bp.Batch_Number, '') as [BatchNumber],
		Case When bp.Expiry Is Null Then '' Else 
		Cast(DatePart(mm, bp.Expiry) As nVarchar) + '/' + Cast(DatePart(yyyy, bp.Expiry) As nVarchar) End as [Expiry],
		Case When bp.PKD Is Null Then '' Else 
		Cast(DatePart(mm, bp.PKD) As nVarchar) + '/' + Cast(DatePart(yyyy, bp.PKD) As nVarchar) End as [PKD],
		mlog.ItemCode as [ItemCode], isNull(mlog.OrgPTS,0) as [PTS], isNull(mlog.OrgPTR,0) as [PTR], 
		isNull(mlog.OrgTaxSuff,0) as [TaxSuff],
		isNull(mlog.MargnPercnt,0) as [MarginPerc], isNull(mlog.MarginPTR,0) as [MarginPTR], 
		dbo.stripTimeFromDate(mlog.EffectiveDate) as [EfDate],
		dbo.stripTimeFromDate(mlog.CreationDate) as [CrDate]
	From 
		tbl_mERP_Margin_Log mlog, Batch_Products bp
		where bp.Batch_Code = mlog.BatchCode	
End

