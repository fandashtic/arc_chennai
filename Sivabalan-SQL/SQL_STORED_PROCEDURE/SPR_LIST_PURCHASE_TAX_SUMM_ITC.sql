CREATE PROCEDURE [dbo].[SPR_LIST_PURCHASE_TAX_SUMM_ITC]
(@FROMDATE DATETIME, @TODATE DATETIME, @Breakup nVarchar(3))    
AS   
Declare @LOCAL As NVarchar(50)
Declare @CENTRAL As NVarchar(50)
Declare @Query As NVarchar(4000)
Declare @Count As Int
Declare @MaxTaxCompLevel As Int
Declare @MaxPurchase As Int
Declare @MaxPurchaseRet As Int
Declare @CurLocality As Int, @CurTaxCode As Int, @CurTaxCompCode As Int, @CurTaxPer As Decimal(18,6) 
Declare @CurTaxAmt As Decimal(18,6), @CurPrevTaxCode As Int, @CurPrevLocality As Int
Declare @BreakupFlag int

declare @temp datetime 
Set DATEFormat DMY
set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)
if(@FROMDATE > @temp )
begin
select 0,'This report cannot be generated for GST period' as Reason
goto GSTOut
 end               
                 
if(@TODATE > @temp )
begin
set @TODATE  = @temp 
--goto GSTOut
end                      

If Upper(@Breakup) = N'YES'
	Set @BreakupFlag = 1
Else
	Set @BreakupFlag = 0

Set @LOCAL = dbo.LookupDictionaryItem(N'LOCAL',Default)
Set @CENTRAL  = dbo.LookupDictionaryItem(N'OUTSTATION',Default)

-- TAXID	---	1 FOR LOCAL;2 FOR CENTRAL    
-- TPAMT	---	TOTAL PURCHASE AMOUNT    
-- TPTAMT	---	TOTAL PURCHASE TAX AMOUNT    
-- TPRAMT	---	TOTAL PURCHASE RETURN AMOUNT    
-- TPRTAMT	---	TOTAL PURCHASE RETURN TAX AMOUNT

If @BreakupFlag = 1
Begin
	Create Table #tmp(TCode Int, Flag Int, Cnt Int)
	CREATE TABLE #PTAXSUM (TAXTYPE nVarchar(5), TAXID Int, TPAMT Decimal(18,6), TPTAMT Decimal(18,6))
	
	Select Distinct bd.TaxCode Into #tmp1 
	From BillAbstract ba, BillDetail bd 
	Where IsNull(STATUS,0) & 128 = 0 
	And BillDate Between @FROMDATE AND @TODATE  
	And ba.BillID = bd.BillID
	
	Insert Into #tmp
	Select Tax_Code, LST_Flag, Count(TaxComponent_Code) From TaxComponents tc, #tmp1 Where tc.Tax_Code = #tmp1.TaxCode 
	Group By Tax_Code, LST_Flag
	
	Select @MaxTaxCompLevel = Max(Cnt) From #tmp
	
	Set @MaxPurchase = @MaxTaxCompLevel
	Set @Count = 1
	While @MaxTaxCompLevel > 0
	Begin
		Set @Query = 'Alter Table #PTAXSUM Add [Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_Purchase] Decimal(18,6)'
		Exec sp_executesql @Query
		Set @Count = @Count + 1
		Set @MaxTaxCompLevel = @MaxTaxCompLevel - 1
	End
	
	Truncate Table #tmp
	
	Set @Query = 'Alter Table #PTAXSUM Add TPRAMT Decimal(18,6), TPRTAMT Decimal(18,6)'    
	Exec sp_executesql @Query

	Select Distinct "Tax_Code"=Tax.Tax_Code Into #tmp2 
	From ADJUSTMENTRETURNABSTRACT a, ADJUSTMENTRETURNDETAIL b, Tax, Vendors v 
	Where IsNull(STATUS,0) & 128 = 0 
	And ADJUSTMENTDATE Between @FROMDATE AND @TODATE  
	And a.ADJUSTMENTID = b.ADJUSTMENTID
	And a.VendorID = v.VendorID 
	And b.Tax = (Case v.Locality When 1 Then Tax.Percentage Else Tax.CST_Percentage End)
	
	Insert Into #tmp
	Select tc.Tax_Code, LST_Flag, Count(TaxComponent_Code) From TaxComponents tc, #tmp2 Where tc.Tax_Code = #tmp2.Tax_Code 
	Group By tc.Tax_Code, LST_Flag
	
	Select @MaxTaxCompLevel = Max(Cnt) From #tmp
	
	Set @MaxPurchaseRet = @MaxTaxCompLevel
	Set @Count = 1
	While @MaxTaxCompLevel > 0
	Begin
		Set @Query = 'Alter Table #PTAXSUM Add [Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_PurchaseReturn] Decimal(18,6)'
		Exec sp_executesql @Query
		Set @Count = @Count + 1
		Set @MaxTaxCompLevel = @MaxTaxCompLevel - 1
	End
	
	INSERT INTO  #PTAXSUM (TAXTYPE,TAXID,TPAMT,TPTAMT)     
	SELECT 'PTAX', VENDORS.LOCALITY ,SUM(BILLDETAIL.AMOUNT), --+ SUM (BILLDETAIL.TAXAMOUNT),
			SUM(BILLDETAIL.TAXAMOUNT)
			FROM BILLABSTRACT,VENDORS,BILLDETAIL
			WHERE (ISNULL(BILLABSTRACT.STATUS,0) & 128)=0
			AND BILLABSTRACT.VENDORID =VENDORS.VENDORID
			AND BILLDETAIL.BILLID = BILLABSTRACT.BILLID		
			AND BILLDATE BETWEEN @FROMDATE AND @TODATE
	GROUP BY VENDORS.LOCALITY
	
	Declare PCur Cursor For 
--	Select v.Locality, tc.tax_code, tc.taxcomponent_code, tc.Tax_Percentage, 
--	Case When bd.TOQ=1 Then Sum((bd.TaxAmount*tc.SP_Percentage)/Tax.Percentage) Else Sum(bd.Amount * (tc.SP_Percentage/100) * (Case v.Locality When 1 Then (Tax.LSTPartOff/100) Else (Tax.CSTPartOff/100) End)) End  
--	From BillAbstract ba, BillDetail bd, TaxComponents tc, Vendors v, Tax  
--	Where (ISNULL(ba.STATUS,0) & 128)=0
--			AND BILLDATE BETWEEN @FROMDATE AND @TODATE  
--			AND ba.VENDORID = v.VendorID 
--			AND v.Locality in (Select Distinct TAXID From #PTAXSUM Where TAXTYPE = 'PTAX')
--			AND ba.BILLID = bd.BILLID		
--			AND bd.TaxCode = Tax.Tax_Code
--			AND bd.TaxSuffered = (Case v.Locality When 1 Then Tax.Percentage Else Tax.CST_Percentage End)
--			AND Tax.Tax_Code = tc.Tax_Code 
--			AND tc.LST_Flag = (case v.Locality When 1 then 1 else 0 end)
--	Group By v.Locality, tc.Tax_Code, tc.TaxComponent_Code, tc.Tax_Percentage,bd.TOQ
--	Order By v.Locality, tc.tax_code

	Select Locality, tax_code, taxcomponent_code, Tax_Percentage, Sum(isnull(TaxAmount,0)) From
	(Select v.Locality, tc.tax_code, tc.taxcomponent_code, tc.Tax_Percentage, 
	Case When bd.TOQ=1 Then Sum((bd.TaxAmount*tc.SP_Percentage)/Tax.Percentage) Else Sum(bd.Amount * (tc.SP_Percentage/100) * (Case v.Locality When 1 Then (Tax.LSTPartOff/100) Else (Tax.CSTPartOff/100) End)) End as [TaxAmount]
	From BillAbstract ba, BillDetail bd, TaxComponents tc, Vendors v, Tax  
	Where (ISNULL(ba.STATUS,0) & 128)=0
			AND BILLDATE BETWEEN @FROMDATE AND @TODATE  
			AND ba.VENDORID = v.VendorID 
			AND v.Locality in (Select Distinct TAXID From #PTAXSUM Where TAXTYPE = 'PTAX')
			AND ba.BILLID = bd.BILLID		
			AND bd.TaxCode = Tax.Tax_Code
			AND bd.TaxSuffered = (Case v.Locality When 1 Then Tax.Percentage Else Tax.CST_Percentage End)
			AND Tax.Tax_Code = tc.Tax_Code 
			AND tc.LST_Flag = (case v.Locality When 1 then 1 else 0 end)
	Group By v.Locality, tc.Tax_Code, tc.TaxComponent_Code, tc.Tax_Percentage,bd.TOQ) A
	Group BY Locality, tax_code, taxcomponent_code, Tax_Percentage
	Order By Locality, tax_code

	Set @CurPrevTaxCode = 0
	Open PCur
	Fetch From PCur Into @CurLocality, @CurTaxCode, @CurTaxCompCode, @CurTaxPer, @CurTaxAmt
	Set @CurPrevLocality = @CurLocality
	While @@Fetch_Status = 0
	Begin
		If @CurPrevTaxCode <> @CurTaxCode
		Begin
			Set @Count = 1
		End
		Else
		Begin
			If @CurPrevLocality <> @CurLocality
				Set @Count = 1
			Else
				Set @Count = @Count + 1
		End
		Set @Query = 'Update #PTAXSUM Set [Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_Purchase] = IsNull([Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_Purchase],0) + ' + Cast(@CurTaxAmt as nVarchar) + ' '
		Set @Query = @Query + 'Where TaxType = ''PTAX'' And TaxID = ' + Cast(@CurLocality as nVarchar)
		Exec sp_executesql @Query
		Set @CurPrevTaxCode = @CurTaxCode
		Set @CurPrevLocality = @CurLocality
		Fetch Next From PCur Into @CurLocality, @CurTaxCode, @CurTaxCompCode, @CurTaxPer, @CurTaxAmt
	End
	Close PCur
	Deallocate PCur

	Select Distinct ad.AdjustmentID, ad.Product_Code, "Tax_Code" = Max(Tax.Tax_Code) Into #tmp3
	From AdjustmentReturnAbstract aa, AdjustmentReturnDetail ad, Vendors v, Tax 
	Where (ISNULL(aa.STATUS,0) & 128)=0
	AND aa.AdjustmentDate BETWEEN @FROMDATE AND @TODATE  
	AND aa.VENDORID = v.VendorID 
	And aa.AdjustmentID = ad.AdjustmentID 
	And ad.Tax = (CASE v.LOCALITY WHEN 1 THEN TAX.PERCENTAGE ELSE TAX.CST_PERCENTAGE END)
	Group By ad.AdjustmentID, ad.Product_Code
	
	Set @Query = 'INSERT INTO  #PTAXSUM (TAXTYPE, TAXID, TPRAMT, TPRTAMT)
	SELECT ''PRTAX'', VENDORS.LOCALITY, SUM(ADJUSTMENTRETURNDETAIL.TOTAL_VALUE - ADJUSTMENTRETURNDETAIL.TAXAMOUNT),
	SUM(ADJUSTMENTRETURNDETAIL.TOTAL_VALUE - (ADJUSTMENTRETURNDETAIL.QUANTITY * ADJUSTMENTRETURNDETAIL.RATE)) 
	FROM ADJUSTMENTRETURNDETAIL, VOUCHERPREFIX BILLPREFIX,VOUCHERPREFIX ADJPREFIX,VENDORS,ADJUSTMENTRETURNABSTRACT, TAX 
	WHERE (ISNULL(ADJUSTMENTRETURNABSTRACT.STATUS,0)& 128)=0	
	AND ADJUSTMENTDATE BETWEEN ''' + Cast(@FROMDATE as nVarchar) + ''' AND ''' + Cast(@TODATE as nVarchar) + ''' 
	AND ADJUSTMENTRETURNABSTRACT.ADJUSTMENTID = ADJUSTMENTRETURNDETAIL.ADJUSTMENTID   
	AND ADJUSTMENTRETURNABSTRACT.VENDORID = VENDORS.VENDORID    
	AND ADJUSTMENTRETURNDETAIL.TAX = (CASE VENDORS.LOCALITY WHEN 1 THEN TAX.PERCENTAGE ELSE TAX.CST_PERCENTAGE END) 
	AND Tax.Tax_Code = (Select Tax_Code From #tmp3 Where ADJUSTMENTRETURNDETAIL.AdjustmentID = #tmp3.AdjustmentID 
	And ADJUSTMENTRETURNDETAIL.Product_Code = #tmp3.Product_Code) 
	AND BILLPREFIX.TRANID = ''BILL'' AND    
	ADJPREFIX.TRANID = ''STOCK ADJUSTMENT PURCHASE RETURN''    
	GROUP BY VENDORS.LOCALITY' 
	Exec sp_executesql @Query
	
	Declare PRCur Cursor For 
	
	Select Locality, tax_code, taxcomponent_code, Tax_Percentage, Sum(isnull(TaxAmount,0)) From
	(Select v.Locality, tc.tax_code, tc.taxcomponent_code, tc.Tax_Percentage, 
	Case When ad.TAXONQTY=1 Then sum(ad.TaxAmount) Else Sum(ad.Rate * ad.Quantity * (tc.SP_Percentage/100) * (Case v.Locality When 1 Then (Tax.LSTPartOff/100) Else (Tax.CSTPartOff/100) End)) End as [TaxAmount]
	From ADJUSTMENTRETURNABSTRACT aa, ADJUSTMENTRETURNDETAIL ad, TaxComponents tc, Vendors v, Tax    
	Where (ISNULL(aa.STATUS,0) & 128)=0
			AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE 
			AND aa.VENDORID = v.VendorID 
			AND v.Locality in (Select Distinct TAXID From #PTAXSUM Where TAXTYPE = 'PRTAX') 
			AND aa.AdjustmentID = ad.AdjustmentID		
			AND ad.Tax = (CASE v.LOCALITY WHEN 1 THEN TAX.PERCENTAGE ELSE TAX.CST_PERCENTAGE END)  
			AND Tax.Tax_Code = (Select Tax_Code From #tmp3 Where ad.AdjustmentID = #tmp3.AdjustmentID 
			And ad.Product_Code = #tmp3.Product_Code) 
			AND Tax.tax_code = tc.tax_code
			AND tc.LST_Flag = (case v.Locality When 1 then 1 else 0 end)
	group by v.Locality, tc.taxcomponent_code, tc.tax_code, tc.Tax_Percentage,ad.TAXONQTY) A
	Group BY Locality, tax_code, taxcomponent_code, Tax_Percentage
	Order By Locality, tax_code


--	Select v.Locality, tc.tax_code, tc.taxcomponent_code, tc.Tax_Percentage, 
--	Case When ad.TAXONQTY=1 Then sum(ad.TaxAmount) Else Sum(ad.Rate * ad.Quantity * (tc.SP_Percentage/100) * (Case v.Locality When 1 Then (Tax.LSTPartOff/100) Else (Tax.CSTPartOff/100) End)) End   
--	From ADJUSTMENTRETURNABSTRACT aa, ADJUSTMENTRETURNDETAIL ad, TaxComponents tc, Vendors v, Tax    
--	Where (ISNULL(aa.STATUS,0) & 128)=0
--			AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE 
--			AND aa.VENDORID = v.VendorID 
--			AND v.Locality in (Select Distinct TAXID From #PTAXSUM Where TAXTYPE = 'PRTAX') 
--			AND aa.AdjustmentID = ad.AdjustmentID		
--			AND ad.Tax = (CASE v.LOCALITY WHEN 1 THEN TAX.PERCENTAGE ELSE TAX.CST_PERCENTAGE END)  
--			AND Tax.Tax_Code = (Select Tax_Code From #tmp3 Where ad.AdjustmentID = #tmp3.AdjustmentID 
--			And ad.Product_Code = #tmp3.Product_Code) 
--			AND Tax.tax_code = tc.tax_code
--			AND tc.LST_Flag = (case v.Locality When 1 then 1 else 0 end)
--	group by v.Locality, tc.taxcomponent_code, tc.tax_code, tc.Tax_Percentage,ad.TAXONQTY
--	order by v.Locality, tc.tax_code

	Set @CurPrevTaxCode = 0
	Open PRCur
	Fetch From PRCur Into @CurLocality, @CurTaxCode, @CurTaxCompCode, @CurTaxPer, @CurTaxAmt
	Set @CurPrevLocality = @CurLocality
	While @@Fetch_Status = 0
	Begin
		If @CurPrevTaxCode <> @CurTaxCode
		Begin
			Set @Count = 1
		End
		Else
		Begin
			If @CurPrevLocality <> @CurLocality
				Set @Count = 1
			Else
				Set @Count = @Count + 1
		End
		Set @Query = 'Update #PTAXSUM Set [Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_PurchaseReturn] = IsNull([Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_PurchaseReturn],0) + ' + Cast(@CurTaxAmt as nVarchar) + ' '
		Set @Query = @Query + 'Where TaxType = ''PRTAX'' And TaxID = ' + Cast(@CurLocality as nVarchar)
		Exec sp_executesql @Query
		Set @CurPrevTaxCode = @CurTaxCode
		Set @CurPrevLocality = @CurLocality
		Fetch Next From PRCur Into @CurLocality, @CurTaxCode, @CurTaxCompCode, @CurTaxPer, @CurTaxAmt
	End
	Close PRCur
	Deallocate PRCur
	
	Set @Query = 'SELECT "Tax Type"= TAXID,"Tax Type"=CASE TAXID WHEN 1 THEN ''' + @LOCAL + ''' ELSE ''' + @CENTRAL + ''' END, "Purchase Amt."=SUM(ISNULL(TPAMT,0)),"Tax Amt"=SUM(ISNULL(TPTAMT,0)), '
	Set @Count = 1
	While @MaxPurchase > 0
	Begin
		Set @Query = @Query + '"Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_Purchase" = SUM(ISNULL([Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_Purchase],0)), '
		Set @Count = @Count + 1
		Set @MaxPurchase = @MaxPurchase - 1
	End
	Set @Query = @Query + '"Pur.Return Amt"=SUM(ISNULL(TPRAMT,0)),"Tax Amt."=SUM(ISNULL(TPRTAMT,0)), ' 
	Set @Count = 1
	While @MaxPurchaseRet > 0
	Begin
		Set @Query = @Query + '"Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_PurchaseReturn" = SUM(ISNULL([Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_PurchaseReturn],0)), '
		Set @Count = @Count + 1
		Set @MaxPurchaseRet = @MaxPurchaseRet - 1
	End
	Set @Query = @Query + '"Net Purchase"=SUM(ISNULL(TPAMT,0))-SUM(ISNULL(TPRAMT,0)) ,  
	"Net Tax"=SUM(ISNULL(TPTAMT,0))- SUM(ISNULL(TPRTAMT,0)) FROM #PTAXSUM  GROUP BY TAXID'    
	   
	Exec sp_executesql @Query
	
	Drop Table #tmp
	Drop Table #tmp1
	Drop Table #tmp2
	Drop Table #tmp3
	DROP TABLE #PTAXSUM
End
Else
Begin
	CREATE TABLE #PTAXSUM1    
	(    
	TAXID float, ---1 FOR LOCAL;2 FOR CENTRAL    
	TPAMT Decimal(18,6),----TOTAL PURCHASE AMOUNT    
	TPTAMT Decimal(18,6),---TOTAL PURCHASE TAX AMOUNT    
	TPRAMT Decimal(18,6),---TOTAL PURCHASE RETURN AMOUNT    
	TPRTAMT Decimal(18,6)---TOTAL PURCHASE RETURN TAX AMOUNT    
	)    
	INSERT INTO  #PTAXSUM1 (TAXID,TPAMT,TPTAMT)     
	SELECT VENDORS.LOCALITY ,SUM(BILLDETAIL.AMOUNT), --+ SUM (BILLDETAIL.TAXAMOUNT),
			SUM(BILLDETAIL.TAXAMOUNT)
			FROM BILLABSTRACT,VENDORS,BILLDETAIL
			WHERE (ISNULL(BILLABSTRACT.STATUS,0) & 128)=0
			AND BILLABSTRACT.VENDORID =VENDORS.VENDORID
			AND BILLDETAIL.BILLID = BILLABSTRACT.BILLID		
			AND BILLDATE BETWEEN @FROMDATE AND @TODATE
	  GROUP BY VENDORS.LOCALITY    
	    
	INSERT INTO  #PTAXSUM1 (TAXID,TPRAMT,TPRTAMT)    
	  SELECT VENDORS.LOCALITY, SUM(ADJUSTMENTRETURNDETAIL.TOTAL_VALUE - ADJUSTMENTRETURNDETAIL.TAXAMOUNT),
		SUM(ADJUSTMENTRETURNDETAIL.TOTAL_VALUE - (ADJUSTMENTRETURNDETAIL.QUANTITY * ADJUSTMENTRETURNDETAIL.RATE)) FROM     
	  ADJUSTMENTRETURNDETAIL, VOUCHERPREFIX BILLPREFIX,VOUCHERPREFIX ADJPREFIX,VENDORS,ADJUSTMENTRETURNABSTRACT    
	   WHERE ADJUSTMENTRETURNDETAIL.ADJUSTMENTID=ADJUSTMENTRETURNABSTRACT.ADJUSTMENTID    
	   AND ADJUSTMENTDATE BETWEEN @FROMDATE AND @TODATE  
	   AND (ISNULL(ADJUSTMENTRETURNABSTRACT.STATUS,0)& 128)=0	
	  AND ADJUSTMENTRETURNABSTRACT.VENDORID =VENDORS.VENDORID    
	   AND BILLPREFIX.TRANID = 'BILL' AND    
	   ADJPREFIX.TRANID = 'STOCK ADJUSTMENT PURCHASE RETURN'    
	    
	GROUP BY VENDORS.LOCALITY    
	    


	SELECT "Tax Type"= TAXID,"Tax Type"=CASE TAXID WHEN 1 THEN @LOCAL ELSE @CENTRAL END, "Purchase Amt."=SUM(ISNULL(TPAMT,0)),"Tax Amt"=SUM(ISNULL(TPTAMT,0)), "Pur.Return Amt"=SUM(ISNULL(TPRAMT,0)),"Tax Amt."=SUM(ISNULL(TPRTAMT,0)),  
	"Net Purchase"=SUM(ISNULL(TPAMT,0))-SUM(ISNULL(TPRAMT,0)) ,  
	"Net Tax"=SUM(ISNULL(TPTAMT,0))- SUM(ISNULL(TPRTAMT,0)) FROM #PTAXSUM1 GROUP BY TAXID    
	    
	DROP TABLE #PTAXSUM1
End
	GSTOut:   
