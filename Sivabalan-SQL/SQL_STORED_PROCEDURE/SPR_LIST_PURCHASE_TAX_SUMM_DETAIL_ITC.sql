Create PROCEDURE [dbo].[SPR_LIST_PURCHASE_TAX_SUMM_DETAIL_ITC]
(@TAXID INTEGER,@FROMDATE DATETIME, @TODATE DATETIME, @Breakup nVarchar(3))
AS
Declare @Query As NVarchar(4000)
Declare @Count As Int
Declare @MaxTaxCompLevel As Int
Declare @MaxPurchase As Int
Declare @MaxPurchaseRet As Int
Declare @CurLocality As Int, @CurTaxCode As Int, @CurTaxSuffered Decimal(18,6), @CurTaxCompCode As Int, @CurTaxPer As Decimal(18,6) 
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

If @BreakupFlag = 1
Begin
	Create Table #tmp(TCode Int, Flag Int, Cnt Int)
	CREATE TABLE #PTAXSUBDET(TAXTYPE nVarchar(5), TAXCODE Int, TAXPERCENT Decimal(18,6), TPAMT Decimal(18,6), TPTAMT Decimal(18,6))
	
	Select Distinct bd.TaxCode Into #tmp1 
	From BillAbstract ba, BillDetail bd, Vendors v  
	Where IsNull(STATUS,0) & 128 = 0 
	And BillDate Between @FROMDATE AND @TODATE  
	And ba.BillID = bd.BillID
	And ba.VendorID = v.VendorID 
	And v.Locality = @TaxID
	
	Insert Into #tmp
	Select Tax_Code, LST_Flag, Count(TaxComponent_Code) From TaxComponents tc, #tmp1 Where tc.Tax_Code = #tmp1.TaxCode 
	Group By Tax_Code, LST_Flag
	
	Select @MaxTaxCompLevel = Max(Cnt) From #tmp Where Flag = (Case @TaxID When 1 Then 1 Else 0 End)

	Set @MaxPurchase = @MaxTaxCompLevel
	Set @Count = 1
	While @MaxTaxCompLevel > 0
	Begin
		Set @Query = 'Alter Table #PTAXSUBDET Add [Component ' + Cast(@Count as nVarchar) + ' Tax%_of_Purchase] Decimal(18,6), [Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_Purchase] Decimal(18,6)'
		Exec sp_executesql @Query
		Set @Count = @Count + 1
		Set @MaxTaxCompLevel = @MaxTaxCompLevel - 1
	End
	
	Truncate Table #tmp
	
	Set @Query = 'Alter Table #PTAXSUBDET Add TPRAMT Decimal(18,6), TPRTAMT Decimal(18,6)'    
	Exec sp_executesql @Query
	
	Select Distinct "Tax_Code"=Tax.Tax_Code Into #tmp2 
	From ADJUSTMENTRETURNABSTRACT a, ADJUSTMENTRETURNDETAIL b, Tax, Vendors v 
	Where IsNull(STATUS,0) & 128 = 0 
	And ADJUSTMENTDATE Between @FROMDATE AND @TODATE  
	And a.ADJUSTMENTID = b.ADJUSTMENTID
	And a.VendorID = v.VendorID 
	And v.Locality = @TaxID 
	And b.Tax = (Case @TaxID When 1 Then Tax.Percentage Else Tax.CST_Percentage End)
	
	Insert Into #tmp
	Select tc.Tax_Code, LST_Flag, Count(TaxComponent_Code) From TaxComponents tc, #tmp2 Where tc.Tax_Code = #tmp2.Tax_Code 
	Group By tc.Tax_Code, LST_Flag
	
	Select @MaxTaxCompLevel = Max(Cnt) From #tmp Where Flag = (Case @TaxID When 1 Then 1 Else 0 End)
	
	Set @MaxPurchaseRet = @MaxTaxCompLevel
	Set @Count = 1
	While @MaxTaxCompLevel > 0
	Begin
		Set @Query = 'Alter Table #PTAXSUBDET Add [Component ' + Cast(@Count as nVarchar) + ' Tax%_of_PurchaseReturn] Decimal(18,6), [Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_PurchaseReturn] Decimal(18,6)'
		Exec sp_executesql @Query
		Set @Count = @Count + 1
		Set @MaxTaxCompLevel = @MaxTaxCompLevel - 1
	End
	
	INSERT INTO #PTAXSUBDET(TAXTYPE, TAXCODE, TAXPERCENT, TPAMT, TPTAMT)
	SELECT 'PTAX', BILLDETAIL.TAXCODE, BILLDETAIL.TAXSUFFERED ,SUM(BILLDETAIL.AMOUNT), --+ SUM(BILLDETAIL.TAXAMOUNT),
			SUM(BILLDETAIL.TAXAMOUNT)
			FROM BILLABSTRACT,VENDORS,BILLDETAIL
			WHERE (ISNULL(BILLABSTRACT.STATUS,0) & 128)=0
			AND BILLABSTRACT.VENDORID =VENDORS.VENDORID
			AND BILLDETAIL.BILLID = BILLABSTRACT.BILLID		
			AND VENDORS.LOCALITY=@TAXID
			AND BILLDATE BETWEEN @FROMDATE AND @TODATE 
			GROUP BY BILLDETAIL.TAXCODE, BILLDETAIL.TAXSUFFERED
	
	Declare PCur Cursor For 
	Select v.Locality, tc.tax_code, bd.TaxSuffered, tc.taxcomponent_code, tc.Tax_Percentage, 
	Case When bd.TOQ=1 Then Sum((bd.TaxAmount*tc.SP_Percentage)/Tax.Percentage) Else Sum(bd.Amount * (tc.SP_Percentage/100) * (Case v.Locality When 1 Then (Tax.LSTPartOff/100) Else (Tax.CSTPartOff/100) End)) End
	From BillAbstract ba, BillDetail bd, TaxComponents tc, Vendors v, Tax   
	Where (ISNULL(ba.STATUS,0) & 128)=0
			AND BILLDATE BETWEEN @FROMDATE AND @TODATE  
			AND ba.VENDORID = v.VendorID 
			AND v.Locality = @TAXID
			AND ba.BILLID = bd.BILLID		
			AND bd.TaxCode = Tax.Tax_Code
			AND bd.TaxSuffered = (Case v.Locality When 1 Then Tax.Percentage Else Tax.CST_Percentage End)
			AND Tax.Tax_Code = tc.Tax_Code 
			AND tc.LST_Flag = (case v.Locality When 1 then 1 else 0 end)
	Group By v.Locality, tc.Tax_Code, bd.TaxSuffered, tc.TaxComponent_Code, tc.Tax_Percentage, bd.TOQ
	Order By v.Locality, tc.tax_code
	
	Set @CurPrevTaxCode = 0
	Open PCur
	Fetch From PCur Into @CurLocality, @CurTaxCode, @CurTaxSuffered, @CurTaxCompCode, @CurTaxPer, @CurTaxAmt
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
		Set @Query = 'Update #PTAXSUBDET Set [Component ' + Cast(@Count as nVarchar) + ' Tax%_of_Purchase] = ' + Cast(@CurTaxPer as nVarchar) + ', '
		Set @Query = @Query + '[Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_Purchase] = IsNull([Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_Purchase],0) + ' + Cast(@CurTaxAmt as nVarchar) + ' '
		Set @Query = @Query + 'Where TaxType = ''PTAX'' And TAXPERCENT = ' + Cast(@CurTaxSuffered as nVarchar) + ' And TAXCODE = ' + Cast(@CurTaxCode as nVarchar)
		Exec sp_executesql @Query
		Set @CurPrevTaxCode = @CurTaxCode
		Set @CurPrevLocality = @CurLocality
		Fetch Next From PCur Into @CurLocality, @CurTaxCode, @CurTaxSuffered, @CurTaxCompCode, @CurTaxPer, @CurTaxAmt
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

	Set @Query = 'INSERT INTO  #PTAXSUBDET (TAXTYPE, TAXCODE, TAXPERCENT, TPRAMT, TPRTAMT)
	SELECT ''PRTAX'', MAX(TAX.TAX_CODE), ADJUSTMENTRETURNDETAIL.TAX, SUM(ADJUSTMENTRETURNDETAIL.TOTAL_VALUE-ADJUSTMENTRETURNDETAIL.TAXAMOUNT),
	SUM(ADJUSTMENTRETURNDETAIL.TOTAL_VALUE - (ADJUSTMENTRETURNDETAIL.QUANTITY * ADJUSTMENTRETURNDETAIL.RATE)) 
	FROM ADJUSTMENTRETURNDETAIL, VOUCHERPREFIX BILLPREFIX,VOUCHERPREFIX ADJPREFIX,VENDORS,ADJUSTMENTRETURNABSTRACT,	TAX 
	WHERE (ISNULL(ADJUSTMENTRETURNABSTRACT.STATUS,0)& 128)=0	
	AND ADJUSTMENTDATE BETWEEN ''' + Cast(@FROMDATE as nVarchar) + ''' AND ''' + Cast(@TODATE as nVarchar) + ''' 
	AND ADJUSTMENTRETURNABSTRACT.ADJUSTMENTID = ADJUSTMENTRETURNDETAIL.ADJUSTMENTID   
	AND ADJUSTMENTRETURNABSTRACT.VENDORID = VENDORS.VENDORID  
	AND VENDORS.Locality = ' + Cast(@TAXID as nVarchar) + ' 
	AND ADJUSTMENTRETURNDETAIL.TAX = (CASE VENDORS.LOCALITY WHEN 1 THEN TAX.PERCENTAGE ELSE CST_PERCENTAGE END) 
	AND Tax.Tax_Code = (Select Tax_Code From #tmp3 Where ADJUSTMENTRETURNDETAIL.AdjustmentID = #tmp3.AdjustmentID 
	And ADJUSTMENTRETURNDETAIL.Product_Code = #tmp3.Product_Code) 
	AND BILLPREFIX.TRANID = ''BILL'' AND    
	ADJPREFIX.TRANID = ''STOCK ADJUSTMENT PURCHASE RETURN''    
	GROUP BY ADJUSTMENTRETURNDETAIL.TAX'

	Exec sp_executesql @Query
	
	Declare PRCur Cursor For 
	Select v.Locality, tc.tax_code, ad.Tax, tc.taxcomponent_code, tc.Tax_Percentage, 
	Case When ad.TAXONQTY=1 Then sum(ad.Taxamount) Else Sum(ad.Rate * ad.Quantity * (tc.SP_Percentage/100) * (Case v.Locality When 1 Then (Tax.LSTPartOff/100) Else (Tax.CSTPartOff/100) End)) End 	
	From ADJUSTMENTRETURNABSTRACT aa, ADJUSTMENTRETURNDETAIL ad, TaxComponents tc, Vendors v, Tax    
	Where (ISNULL(aa.STATUS,0) & 128)=0
			AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE 
			AND aa.VENDORID = v.VendorID 
			AND v.Locality = @TaxID 
			AND aa.AdjustmentID = ad.AdjustmentID		
			AND ad.Tax = (CASE v.LOCALITY WHEN 1 THEN TAX.PERCENTAGE ELSE TAX.CST_PERCENTAGE END)  
			AND Tax.Tax_Code = (Select Tax_Code From #tmp3 Where ad.AdjustmentID = #tmp3.AdjustmentID 
			And ad.Product_Code = #tmp3.Product_Code) 
			AND Tax.tax_code = tc.tax_code
			AND tc.LST_Flag = (case v.Locality When 1 then 1 else 0 end)
	group by v.Locality, tc.taxcomponent_code, tc.tax_code, ad.Tax, tc.Tax_Percentage,ad.TAXONQTY
	order by v.Locality, tc.tax_code

	Set @CurPrevTaxCode = 0
	Open PRCur
	Fetch From PRCur Into @CurLocality, @CurTaxCode, @CurTaxSuffered, @CurTaxCompCode, @CurTaxPer, @CurTaxAmt
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
		Set @Query = 'Update #PTAXSUBDET Set [Component ' + Cast(@Count as nVarchar) + ' Tax%_of_PurchaseReturn] = ' + Cast(@CurTaxPer as nVarchar) + ', '
		Set @Query = @Query + '[Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_PurchaseReturn] = IsNull([Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_PurchaseReturn],0) + ' + Cast(@CurTaxAmt as nVarchar) + ' '
		Set @Query = @Query + 'Where TaxType = ''PRTAX'' And TAXPERCENT = ' + Cast(@CurTaxSuffered as nVarchar) + ' And TAXCODE = ' + Cast(@CurTaxCode as nVarchar)
		Exec sp_executesql @Query
		Set @CurPrevTaxCode = @CurTaxCode
		Set @CurPrevLocality = @CurLocality
		Fetch Next From PRCur Into @CurLocality, @CurTaxCode, @CurTaxSuffered, @CurTaxCompCode, @CurTaxPer, @CurTaxAmt
	End
	Close PRCur
	Deallocate PRCur
	
	Set @Query = 'SELECT "TaxPercent"= TAXPERCENT, "Tax Description" = (Case TAXPERCENT When 0 Then ''Exempt'' Else Cast(TAXPERCENT as nVarchar) End), "Purchase Amt."=SUM(ISNULL(TPAMT,0)), "Tax Amt"=SUM(ISNULL(TPTAMT,0)), '
	Set @Count = 1
	While @MaxPurchase > 0
	Begin
		Set @Query = @Query + '"Component ' + Cast(@Count as nVarchar) + ' Tax%_of_Purchase" = SUM(ISNULL([Component ' + Cast(@Count as nVarchar) + ' Tax%_of_Purchase],0)), "Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_Purchase" = SUM(ISNULL([Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_Purchase],0)), '
		Set @Count = @Count + 1
		Set @MaxPurchase = @MaxPurchase - 1
	End
	
	Set @Query = @Query + '"Pur.Return Amt"=SUM(ISNULL(TPRAMT,0)),"Tax Amt."=SUM(ISNULL(TPRTAMT,0)), ' 
	Set @Count = 1
	While @MaxPurchaseRet > 0
	Begin
		Set @Query = @Query + '"Component ' + Cast(@Count as nVarchar) + ' Tax%_of_PurchaseReturn" = SUM(ISNULL([Component ' + Cast(@Count as nVarchar) + ' Tax%_of_PurchaseReturn],0)), "Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_PurchaseReturn" = SUM(ISNULL([Component ' + Cast(@Count as nVarchar) + ' Tax Amount_of_PurchaseReturn],0)), '
		Set @Count = @Count + 1
		Set @MaxPurchaseRet = @MaxPurchaseRet - 1
	End
	Set @Query = @Query + '"Net Purchase"=SUM(ISNULL(TPAMT,0))-SUM(ISNULL(TPRAMT,0)) ,  
	"Net Tax"=SUM(ISNULL(TPTAMT,0))- SUM(ISNULL(TPRTAMT,0)) FROM #PTAXSUBDET  GROUP BY TAXPERCENT'    
	Exec sp_executesql @Query
	
	Drop Table #tmp
	Drop Table #tmp1
	Drop Table #tmp2
	Drop Table #tmp3
	DROP TABLE #PTAXSUBDET
End
Else
Begin
	CREATE TABLE #PTAXSUBDET1
	(
	TAXPERCENT Decimal(18,6),
	TPAMT Decimal(18,6),----TOTAL PURCHASE AMOUNT
	TPTAMT Decimal(18,6),---TOTAL PURCHASE TAX AMOUNT
	TPRAMT Decimal(18,6),---TOTAL PURCHASE RETURN AMOUNT
	TPRTAMT Decimal(18,6)---TOTAL PURCHASE RETURN TAX AMOUNT
	)
	
	INSERT INTO #PTAXSUBDET1 (TAXPERCENT,TPAMT,TPTAMT)
	SELECT BILLDETAIL.TAXSUFFERED ,SUM(BILLDETAIL.AMOUNT), --+ SUM(BILLDETAIL.TAXAMOUNT),
			SUM(BILLDETAIL.TAXAMOUNT)
			FROM BILLABSTRACT,VENDORS,BILLDETAIL
			WHERE (ISNULL(BILLABSTRACT.STATUS,0) & 128)=0
			AND BILLABSTRACT.VENDORID =VENDORS.VENDORID
			AND BILLDETAIL.BILLID = BILLABSTRACT.BILLID		
			AND VENDORS.LOCALITY=@TAXID
			AND BILLDATE BETWEEN @FROMDATE AND @TODATE
			GROUP BY BILLDETAIL.TAXSUFFERED
	
	INSERT INTO #PTAXSUBDET1 (TAXPERCENT,TPRAMT,TPRTAMT)
	SELECT ADJUSTMENTRETURNDETAIL.TAX, SUM(ADJUSTMENTRETURNDETAIL.TOTAL_VALUE-ADJUSTMENTRETURNDETAIL.TAXAMOUNT),
		SUM(ADJUSTMENTRETURNDETAIL.TOTAL_VALUE - (ADJUSTMENTRETURNDETAIL.QUANTITY * ADJUSTMENTRETURNDETAIL.RATE)) FROM 
			ADJUSTMENTRETURNDETAIL, VOUCHERPREFIX BILLPREFIX,VOUCHERPREFIX ADJPREFIX,VENDORS,ADJUSTMENTRETURNABSTRACT
			 WHERE ADJUSTMENTRETURNDETAIL.ADJUSTMENTID=ADJUSTMENTRETURNABSTRACT.ADJUSTMENTID
				AND ADJUSTMENTDATE BETWEEN @FROMDATE AND @TODATE
			AND	ADJUSTMENTRETURNABSTRACT.VENDORID =VENDORS.VENDORID
			AND (ISNULL(ADJUSTMENTRETURNABSTRACT.STATUS,0)& 128)=0	
				AND BILLPREFIX.TRANID = 'BILL' AND
				ADJPREFIX.TRANID = 'STOCK ADJUSTMENT PURCHASE RETURN'		
			AND VENDORS.LOCALITY=@TAXID
			GROUP BY ADJUSTMENTRETURNDETAIL.TAX

	SELECT "TaxPercent"= TAXPERCENT,"Tax Description"= (Case TAXPERCENT When 0 Then 'Exempt' Else Cast(TAXPERCENT as nVarchar) End), "Purchase Amt."=SUM(ISNULL(TPAMT,0)),"Tax Amt"=SUM(ISNULL(TPTAMT,0)), "Pur.Return Amt"=SUM(ISNULL(TPRAMT,0)),"Tax Amt."=SUM(ISNULL(TPRTAMT,0)),
	"Net Purchase"=SUM(ISNULL(TPAMT,0))-SUM(ISNULL(TPRAMT,0)) ,
	"Net Tax"=SUM(ISNULL(TPTAMT,0))- SUM(ISNULL(TPRTAMT,0)) FROM #PTAXSUBDET1  GROUP BY TAXPERCENT
	
	DROP TABLE #PTAXSUBDET1
End
	GSTOut:
