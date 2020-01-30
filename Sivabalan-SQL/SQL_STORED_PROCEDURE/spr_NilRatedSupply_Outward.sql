Create Procedure spr_NilRatedSupply_Outward
(
@FromDate datetime,
@ToDate Datetime
)
As
Begin
	Set Dateformat DMY
	Declare @Des1 Nvarchar(100)
	Declare @Des2 Nvarchar(100)
	Declare @Des3 Nvarchar(100)
	Declare @Des4 Nvarchar(100)

	Set @Des1 = 'Inter-State Supplies to Registered Person'
	Set @Des2 = 'Intra-State Supplies to Registered Person'
	Set @Des3 = 'Inter-State Supplies to UnRegistered Person'
	Set @Des4 = 'Intra-State Supplies to UnRegistered Person'

	Create table #Temp
	(
	 SlNo int,
	[Description] Nvarchar(100),
	[NilRatedSupplies] Nvarchar(100),
	[Exempted] decimal(18,6),
	[Non-GSTSupplies] Nvarchar(100)
	)
	
	Create Table #TmpAbsInvID(InvoiceID int, SRInvoiceID int, InvoiceType int, Flag int)

	Insert Into #TmpAbsInvID(InvoiceID, SRInvoiceID, InvoiceType)
	Select InvoiceID, SRInvoiceID, InvoiceType
	From InvoiceAbstract Iv(Nolock)
	Where 
		dbo.striptimefromdate(Iv.InvoiceDate) BETWEEN dbo.striptimefromdate(@FROMDATE) AND dbo.striptimefromdate(@TODATE)
		and Iv.GSTFlag = 1 and (Iv.InvoiceType in (1,3,4)) and (Iv.Status & 128) = 0

	Update T Set T.Flag = 1 From InvoiceAbstract IA(Nolock) 
		Inner Join #TmpAbsInvID T ON IA.InvoiceID = T.SRInvoiceID and isnull(IA.GSTFlag,0) = 0
	Where T.InvoiceType = 4

	Delete From #TmpAbsInvID Where isnull(Flag,0) = 1
	
	Select Iv.* Into #TempAbstract
	From InvoiceAbstract Iv(Nolock)
	Where Iv.InvoiceID in(Select InvoiceID From #TmpAbsInvID)
	  
	Select Idt.* into #TempDetail  From InvoiceDetail IDT(Nolock) Join #TempAbstract IA On IA.InvoiceID = IDT.InvoiceID
	Where IsNull(IDT.STPayable,0)+IsNull(IDT.CSTPayable,0)=0

	Select * into #TempCus From Customer c(NoLock)

	Insert Into #Temp(SlNo,[Description],[NilRatedSupplies],[Exempted],[Non-GSTSupplies])
	Select 1, @Des1, '', 0, ''
	Insert Into #Temp(SlNo,[Description],[NilRatedSupplies],[Exempted],[Non-GSTSupplies])
	Select 2, @Des2, '', 0, ''
	Insert Into #Temp(SlNo,[Description],[NilRatedSupplies],[Exempted],[Non-GSTSupplies])
	Select 3, @Des3, '', 0, ''
	Insert Into #Temp(SlNo,[Description],[NilRatedSupplies],[Exempted],[Non-GSTSupplies])
	Select 4, @Des4, '', 0, ''


	--To get DandD Invoice
	Select * Into #TmpDandDInvAbs
	From DandDInvAbstract
	Where dbo.StripTimeFromDate(DandDInvDate) Between dbo.StripTimeFromDate(@FromDate) and dbo.StripTimeFromDate(@ToDate)
		
	Select DD.* Into #TmpDandDInvDet From #TmpDandDInvAbs DA
	Join DandDInvDetail DD ON DA.DandDInvID = DD.DandDInvID

	Insert Into #Temp(SlNo,[Description],[NilRatedSupplies],[Exempted],[Non-GSTSupplies])	
	Select 1, @Des1, '', Sum(InvoiceValue), ''
	From
	(Select (Case when TA.InvoiceType = 4 then -1 Else 1 End)  * IsNull((Sum(((TD.uomqty * TD.uomprice) - TD.DiscountValue)
				-(((TD.uomqty *TD.uomprice)- TD.DiscountValue)*(TA.AdditionalDiscount/100)))),0) as InvoiceValue
	From  #TempAbstract  TA
	JOIN #TempCus TC(Nolock) ON(TC.CustomerID = TA.CustomerID)
	JOIN #TempDetail TD (Nolock) ON( TD.InvoiceID = TA.InvoiceID)
	Where IsNull(TD.STPayable,0)+IsNull(TD.CSTPayable,0)=0 
		and TA.FromStateCode<>TA.ToStateCode and isnull(TA.GSTIN,'') <> ''    -- TC.IsRegistered = 1
	Group By  TA.InvoiceType--,TD.STPayable,TD.CSTPayable
	Union All
	Select Sum(isnull(DD.RebateValue,0)) as InvoiceValue	
	From #TmpDandDInvAbs DA
	Inner Join #TmpDandDInvDet DD ON DA.DandDInvID = DD.DandDInvID
	Where isnull(DD.TotalTaxAmount,0) = 0 and DA.FromStateCode <> DA.ToStateCode and isnull(DA.GSTIN,'') <> '') A

	
	Insert Into #Temp(SlNo,[Description],[NilRatedSupplies],[Exempted],[Non-GSTSupplies])
	Select 2, @Des2, '', Sum(InvoiceValue), ''
	From
	(Select (Case when TA.InvoiceType = 4 then -1 Else 1 End)  * IsNull((Sum(((TD.uomqty * TD.uomprice) - TD.DiscountValue)
			- (((TD.uomqty *TD.uomprice)- TD.DiscountValue)*(TA.AdditionalDiscount/100)))),0) as InvoiceValue
	From  #TempAbstract  TA
	JOIN #TempCus TC(Nolock) ON(TC.CustomerID = TA.CustomerID)
	JOIN #TempDetail TD (Nolock) ON( TD.InvoiceID = TA.InvoiceID)
	Where IsNull(TD.STPayable,0)+IsNull(TD.CSTPayable,0)=0 
		and TA.FromStateCode=TA.ToStateCode and isnull(TA.GSTIN,'') <> '' -- TC.IsRegistered = 1
	Group By  TA.InvoiceType--,TD.STPayable,TD.CSTPayable
	Union All
	Select Sum(isnull(DD.RebateValue,0)) as InvoiceValue	
	From #TmpDandDInvAbs DA
	Inner Join #TmpDandDInvDet DD ON DA.DandDInvID = DD.DandDInvID
	Where isnull(DD.TotalTaxAmount,0) = 0 and DA.FromStateCode = DA.ToStateCode and isnull(DA.GSTIN,'') <> '') A


	Insert Into #Temp(SlNo,[Description],[NilRatedSupplies],[Exempted],[Non-GSTSupplies])
	Select 3, @Des3, '', Sum(InvoiceValue), ''
	From
	(Select (Case when TA.InvoiceType = 4 then -1 Else 1 End)  * IsNull((Sum(((TD.uomqty * TD.uomprice) - TD.DiscountValue)
				- (((TD.uomqty *TD.uomprice)- TD.DiscountValue)*(TA.AdditionalDiscount/100)))),0) as InvoiceValue
	From  #TempAbstract TA
	JOIN #TempCus TC(Nolock) ON(TC.CustomerID = TA.CustomerID)
	JOIN #TempDetail TD (Nolock) ON( TD.InvoiceID = TA.InvoiceID)
	Where IsNull(TD.STPayable,0)+IsNull(TD.CSTPayable,0)=0 
		and TA.FromStateCode<>TA.ToStateCode and isnull(TA.GSTIN,'') = ''  --isnull(TC.IsRegistered,0) = 0
	Group By TA.InvoiceType--,TD.STPayable,TD.CSTPayable
	Union All
	Select Sum(isnull(DD.RebateValue,0)) as InvoiceValue	
	From #TmpDandDInvAbs DA
	Inner Join #TmpDandDInvDet DD ON DA.DandDInvID = DD.DandDInvID
	Where isnull(DD.TotalTaxAmount,0) = 0 and DA.FromStateCode <> DA.ToStateCode and isnull(DA.GSTIN,'') = '') A


	Insert Into #Temp(SlNo,[Description],[NilRatedSupplies],[Exempted],[Non-GSTSupplies])
	Select 4, @Des4, '', Sum(InvoiceValue), ''
	From
	(Select (Case when TA.InvoiceType = 4 then -1 Else 1 End)  * IsNull((Sum(((TD.uomqty * TD.uomprice) - TD.DiscountValue)
			- (((TD.uomqty *TD.uomprice)- TD.DiscountValue)*(TA.AdditionalDiscount/100)))),0) as InvoiceValue
	From  #TempAbstract  TA
	JOIN #TempCus TC(Nolock) ON(TC.CustomerID = TA.CustomerID)
	JOIN #TempDetail TD (Nolock) ON( TD.InvoiceID = TA.InvoiceID)
	Where IsNull(TD.STPayable,0)+IsNull(TD.CSTPayable,0)=0 
		and TA.FromStateCode=TA.ToStateCode and isnull(TA.GSTIN,'') = '' -- isnull(TC.IsRegistered,0) = 0
	Group By  TA.InvoiceType--,TD.STPayable,TD.CSTPayable
	Union All
	Select Sum(isnull(DD.RebateValue,0)) as InvoiceValue	
	From #TmpDandDInvAbs DA
	Inner Join #TmpDandDInvDet DD ON DA.DandDInvID = DD.DandDInvID
	Where isnull(DD.TotalTaxAmount,0) = 0 and DA.FromStateCode = DA.ToStateCode and isnull(DA.GSTIN,'') = '') A

	Select 0 [ID],[Description],[NilRatedSupplies],Exempted=Sum([Exempted]),[Non-GSTSupplies] From #Temp(Nolock)
	Group By [Description],[NilRatedSupplies],[Non-GSTSupplies], SlNo
	Order By SlNo

	Drop Table #TmpAbsInvID

	IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
        Drop Table #Temp
        
    IF OBJECT_ID('tempdb..#TempAbstract') IS NOT NULL
        Drop Table #TempAbstract
        
    IF OBJECT_ID('tempdb..#TempDetail') IS NOT NULL
        Drop Table #TempDetail
        
    IF OBJECT_ID('tempdb..#TempCus') IS NOT NULL
		Drop Table #TempCus        

	IF OBJECT_ID('tempdb..#TmpDandDInvAbs') IS NOT NULL
		Drop Table #TmpDandDInvAbs     

	IF OBJECT_ID('tempdb..#TmpDandDInvDet') IS NOT NULL
		Drop Table #TmpDandDInvDet     

END
