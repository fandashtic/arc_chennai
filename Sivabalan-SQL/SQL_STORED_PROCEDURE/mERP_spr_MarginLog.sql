Create Procedure mERP_spr_MarginLog(@FromDate DateTime,@ToDate Datetime)
As
Begin
	Set Dateformat DMY
	Declare @WDCode NVarchar(255)  
	Declare @WDDest NVarchar(255)  
	Declare @CompaniesToUploadCode NVarchar(255)  
	Declare @Code int  
	  
	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload    
	Select Top 1 @WDCode = RegisteredOwner From Setup      
	    
	If @CompaniesToUploadCode='ITC001'    
	 Set @WDDest= @WDCode    
	Else    
	Begin    
	 Set @WDDest= @WDCode    
	 Set @WDCode= @CompaniesToUploadCode    
	End   
	
	Create Table #tmpSKU(CategoryID int,[level] int)

	Select 1 as [Code],
	"WDCode"=@WDCode,
	"WDDest" = @WDDest,
	"FromDate" = @FromDate,
	"ToDate" = @ToDate,
	"SKUCode" = MarginLog.Product_Code,
	"SKUName" = I.ProductName,
	"Existing Margin" = isNull(MarginLog.OldMargin,0),
	"New Margin" = MarginLog.NewMargin,
	"Date and Time Changed" = Convert(nVarchar(10),MarginLog.CreationTime,103) + N' ' + Convert(nVarchar(8),MarginLog.CreationTime,108),
	"User" = MarginLog.UserName
	into #tmpMaringLog
	From  tbl_mERP_ProdMargin_AuditLog MarginLog, tbl_merp_margindetail MDetail, Items I
	Where dbo.StripTimeFromDate(MarginLog.CreationTime) Between @FromDate And @ToDate
	And MDetail.Code=MarginLog.Product_Code
	And MDetail.EffectiveDate=MarginLog.NewEffectiveDate
	And I.Product_code=MDetail.Code
	And MDetail.[Level] = 5
	
	Declare AllSKU cursor for
	Select cast(MDetail.Code as int)
	From  tbl_mERP_ProdMargin_AuditLog MarginLog, tbl_merp_margindetail MDetail
	Where dbo.StripTimeFromDate(MarginLog.CreationTime) Between dbo.StripTimeFromDate(@FromDate) And dbo.StripTimeFromDate(@ToDate)
	And MDetail.Code=MarginLog.Product_Code
	And MDetail.EffectiveDate=MarginLog.NewEffectiveDate
	And MDetail.[Level] <> 5
	Open AllSKU
	Fetch from AllSKU into @Code
	While @@fetch_status = 0
	BEGIN
		insert into #tmpSKU select * from dbo.FN_mERP_getSubCategories_For_Category('CG')
		Fetch next from AllSKU into @Code
	END
	Close ALLSKU
	Deallocate ALLSKU
	

	insert into #tmpMaringLog(Code, WDCode,WDDest,FromDate,ToDate,SKUCode,SKUName,[Existing Margin],[New Margin],[Date and Time Changed],[User])
	Select 1,
	"WDCode"=@WDCode,
	"WDDest" = @WDDest,
	"FromDate" = @FromDate,
	"ToDate" = @ToDate,
	"SKUCode" = I.Product_code,
	"SKUName" = I.ProductName,
	"Existing Margin" = isNull(MarginLog.OldMargin,0),
	"New Margin" = MarginLog.NewMargin,
	"Date and Time Changed" = Convert(nVarchar(10),MarginLog.CreationTime,103) + N' ' + Convert(nVarchar(8),MarginLog.CreationTime,108),
	"User" = MarginLog.UserName
	From  tbl_mERP_ProdMargin_AuditLog MarginLog, tbl_merp_margindetail MDetail, Items I
	Where dbo.StripTimeFromDate(MarginLog.CreationTime) Between dbo.StripTimeFromDate(@FromDate) And dbo.StripTimeFromDate(@ToDate)
	And MDetail.Code=MarginLog.Product_Code
	And MDetail.EffectiveDate=MarginLog.NewEffectiveDate
	And I.Product_code in (Select Product_code from Items where categoryid in (select CategoryID from #tmpSKU))
	And MDetail.[Level] <> 5

	select distinct Code, WDCode,WDDest,FromDate,ToDate,SKUCode,SKUName,[Existing Margin],[New Margin],[Date and Time Changed],[User] from #tmpMaringLog
	Drop table #tmpSKU
	Drop Table #tmpMaringLog
	/*And IsNull(MarginLog.RptUploadFlag,0) = 0  */
End
