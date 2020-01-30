Create Procedure spr_SalesBook_ITC(@CustomerID nVarChar(2550),  
               @TaxSlab nVarChar(2550),  
               @FromDate DateTime,  
               @ToDate DateTime,
               @InvType nVarchar(50),
	       	   @PaymentMode nVarchar(50),	
     	       @DocType nVarchar(50),	     
               @FromNo nVarchar(50),  
               @ToNo nVarchar(50),
			   @TaxSplitUp as nVarchar(5))  
As  
Begin 
Declare @Prefix nVarChar(255)  
Declare @Count Int  
Declare @Count1 Int  
Declare @i Int  
Declare @Tax Decimal(18, 6)  
Declare @TempSql nVarchar(4000)  
Declare @j Int  
Declare @inv Int  
Declare @Type nVarChar(10)  
Declare @SalesVal Decimal(18, 6)  
Declare @TaxVal Decimal(18, 6)  
Declare @Delimeter as Char(1)    
Declare @StCredit as decimal(18,6)
Declare @CrdNt as decimal(18,6)
Declare @F11adj as Decimal(18,6)
Declare @Balance as Decimal(18,6)
Declare @FromInvNo Int  
Declare @ToInvNo Int
Declare @TEMP AS NVARCHAR(1000)
Declare @AllInv as int 
Declare @TaxID as Int
Declare @TaxCompCnt as Int
Declare @TaxCompIncr as Int
Declare @CompDesc as nVarchar(100)
Declare @CompCode as int
Declare @TaxComponentValue as Decimal(18,6)
Declare @TaxDesc as nVarchar(4000)

  
Set @Delimeter = Char(15)    
Set @i = 1  
  
Create table #tmpCus(CustID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )    
Create table #tmpTSlab(TDesc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )    
Create Table #TempSix(Tax_Code Int)  
Create Table #TmpInvType(InvType int)            
Create Table #tmpPaymode(PayMode Int)            
Create Table #TmpPayMode2(PayMode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, PId int)  

  
If @CustomerID = N'%'     
	Insert into #tmpCus select CustomerID from Customer Union select Cast(isNull(CustomerID,'0') as nVarchar) from Cash_Customer Union Select Cast(-1 As nVarChar)  
Else    
	Insert into #tmpCus select * from dbo.sp_SplitIn2Rows(@CustomerID, @Delimeter) Union Select Cast(-1 As nVarChar)  
    
If @TaxSlab = N'%'    
	Insert into #tmpTSlab select Tax_Description From Tax  
Else    
	Insert into #tmpTSlab select * from dbo.sp_SplitIn2Rows(@TaxSlab, @Delimeter)    
  
Insert InTo #TempSix Select Tax_Code From Tax Where Tax_Description In (Select TDesc From #tmpTSlab)  
  
If @TaxSlab = N'%'  
Begin  
 Insert InTo #TempSix Values (-2)  
End  

If @InvType = N'%'
Begin
	Insert Into #TmpInvType Select 1
	Insert Into #TmpInvType Select 3
	Insert Into #TmpInvType Select 4
	Set @AllInv = 1
End
Else If @InvType = N'Sales Invoices'
Begin
	Insert Into #TmpInvType Select 1
	Insert Into #TmpInvType Select 3
	Set @AllInv = 0
End
Else
Begin
	Insert Into #TmpInvType Select 4
	Set @AllInv = 0
End

Insert Into #TmpPayMode2 Values (N'Credit', 0)  
Insert Into #TmpPayMode2 Values (N'Cash', 1)  
Insert Into #TmpPayMode2 Values (N'Cheque', 2)  
Insert Into #TmpPayMode2 Values (N'DD', 3)  


if @PaymentMode = '%'              
	Insert Into #tmpPayMode Select PId From #TmpPayMode2
else              
	Insert into #tmpPayMode Select PId From #TmpPayMode2 Where PayMode In(select * from dbo.sp_SplitIn2Rows(@PaymentMode, @Delimeter))

if @DocType='%'
Begin
	Select  Top 1 @FromInvNo = DocumentID From InvoiceAbstract Where DocReference like @FromNo Order By DocumentID 
	Select  Top 1 @ToInvNo = DocumentID From InvoiceAbstract Where DocReference like @ToNo  Order By DocumentID desc
End
Else
Begin
	Select  Top 1 @FromInvNo = DocumentID From InvoiceAbstract Where DocReference like @FromNo And DocSerialType = @DocType Order By DocumentID 
	Select  Top 1 @ToInvNo = DocumentID From InvoiceAbstract Where DocReference like @ToNo  And DocSerialType = @DocType Order By DocumentID desc
End

  
Select @Prefix = Prefix From VoucherPrefix Where TranID Like N'INVOICE'  
  
Create Table #TempOne ([InvoiceID] Int, [Date] DateTime, [Serial No] nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS ,   
 [Document No] nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS , [Customer Name] nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,[Product Discount] Decimal(18,6), [Gross Value] Decimal(18, 6),  
 [Scheme Discount] Decimal(18, 6), [Gross Amount After Scheme Discount] Decimal(18, 6), [Trade Discount] Decimal(18, 6),  
 [Gross Amount After Trade Discount ] Decimal(18, 6), [Addl Discount] Decimal(18, 6), [Gross Amount After Addl Discount] Decimal(18, 6),   
 [Freight] Decimal(18, 6), [Gross Amount After Freight] Decimal(18, 6))



  
Select Distinct TaxID = TaxId,Tax = TaxCode,TaxDesc = Tax_Description, Type = N'L' InTo #TempTwo   
From InvoiceAbstract ia, InvoiceDetail ide ,#TempSix  Tx,Tax T
Where IsNull(ia.Status, 0) & 192 = 0 And
ia.InvoiceType In (Select InvType From #tmpInvType) And
ia.PaymentMode In (Select PayMode From #tmpPayMode) And
(Case IsNull(ia.CustomerID, '0') When '0' Then '-1' Else isnull(ia.CustomerID,'0') End) In (Select CustID From #tmpCus) And
ia.InvoiceDate Between @FromDate And @ToDate And 
ia.DocumentID Between @FromInvNo And @ToInvNo And
ia.DocSerialType  like @DocType  And 
ia.InvoiceID = ide.InvoiceID And 
ide.TaxId = Tx.Tax_Code And 
IsNull(ide.TaxCode, 0) > 0  And  
T.Tax_Code = Tx.Tax_Code 
  
Insert Into #TempTwo Select Distinct TaxId,TaxCode2,TaxDesc = Tax_Description,N'K'  
From InvoiceAbstract ia, InvoiceDetail ide,#TempSix  Tx,Tax T   
Where IsNull(ia.Status, 0) & 192 = 0 And
ia.InvoiceType In (Select InvType From #tmpInvType) And
ia.PaymentMode In (Select PayMode From #tmpPayMode) And
(Case IsNull(ia.CustomerID, '0') When '0' Then '-1' Else isnull(ia.CustomerID,'0') End) In (Select CustID From #tmpCus) And
ia.InvoiceDate Between @FromDate And @ToDate And  
ia.DocumentID Between @FromInvNo And @ToInvNo And
ia.DocSerialType  like @DocType  And 
ia.InvoiceID = ide.InvoiceID And 
ide.TaxId = Tx.Tax_Code And 
IsNull(ide.TaxCode2, 0) > 0 And   
T.Tax_Code = Tx.Tax_Code 
  
Insert Into #TempTwo Select Distinct -1,(IsNull(ide.TaxCode, 0) + IsNull(ide.TaxCode2, 0)),'', N'J'  
From InvoiceAbstract ia, InvoiceDetail ide,#TempSix  Tx
Where IsNull(ia.Status, 0) & 192 = 0 And
ia.InvoiceType In (Select InvType From #tmpInvType) And
ia.PaymentMode In (Select PayMode From #tmpPayMode) And
(Case IsNull(ia.CustomerID, '0') When '0' Then '-1' Else isnull(ia.CustomerID,'0') End) In (Select CustID From #tmpCus) And
ia.InvoiceDate Between @FromDate And @ToDate And  
ia.DocumentID Between @FromInvNo And @ToInvNo And
ia.DocSerialType  like @DocType  And 
ia.InvoiceID = ide.InvoiceID And
ide.TaxId = Tx.Tax_Code And 
(IsNull(ide.TaxCode, 0) + IsNull(ide.TaxCode2, 0)) = 0 
  
Insert Into #TempTwo Select Distinct -1,0,'', N'I'  
  
Select [ID] = Identity(Int, 1, 1), TaxID, Tax,TaxDesc, Type InTo #TempThree From #TempTwo   
Order By Type Desc  


  
Select @Count = Count(Tax) From #TempThree  
  

Select distinct ia.InvoiceID InTo #TempFour   
From InvoiceAbstract ia, InvoiceDetail ide,#TempSix  Tx
Where IsNull(ia.Status, 0) & 192 = 0 And
ia.InvoiceType In (Select InvType From #tmpInvType) And
ia.PaymentMode In (Select PayMode From #tmpPayMode) And
(Case IsNull(ia.CustomerID, '0') When '0' Then '-1' Else isnull(ia.CustomerID,'0') End) In (Select CustID From #tmpCus) And
ia.InvoiceDate Between @FromDate And @ToDate And  
ia.DocumentID Between @FromInvNo And @ToInvNo And
ia.DocSerialType  like @DocType  And 
ia.InvoiceID = ide.InvoiceID And
ide.TaxId = Tx.Tax_Code 

If @TaxSplitUp	= 'Yes'
Create Table #tempTaxComp(ComponentCode Int,TaxComponent nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

  

Select [ID] = Identity(Int, 1, 1), InvoiceID InTo #TempFive From #TempFour  
  
Select @Count1 = Count(*) From #TempFive  


While @Count >= @i  
Begin  
  Select @TaxID = TaxID,@Type = Type, @Tax = Tax,@TaxDesc = TaxDesc From #TempThree Where [ID] = @i  
    
	If @Type = N'L'  
	Begin  
		Set @TempSql = N'Alter Table #TempOne Add [LST ' + Cast(@Tax As nVarChar) + N'% Sales_' +  Cast(@TaxDesc as nvarchar(510)) + N']   
		Decimal(18, 6) Default(0) Not Null'  
		Exec sp_executesql @TempSql  
	  	Set @TempSql = N'Alter Table #TempOne Add [LST ' + Cast(@Tax As nVarChar) + N'% Tax_' + Cast(@TaxDesc as nVarchar(510)) + N']   
		Decimal(18, 6) Default(0) Not Null'  
    	Exec sp_executesql @TempSql
		If @TaxSplitUp	= 'Yes' 
		begin
			Insert Into #tempTaxComp Select * From dbo.fn_GetTaxComponent(@TaxID,1)		        					
			Select [ID] = Identity(Int, 1, 1), TaxComponent InTo #TempLSTCompDesc From #tempTaxComp
			Select @TaxCompCnt = Count(*) From #TempLSTCompDesc
			Set @TaxCompIncr = 1
			While @TaxCompCnt >= @TaxCompIncr
			begin
				Select @CompDesc = TaxComponent From #TempLSTCompDesc Where [ID] = @TaxCompIncr
				Set @TempSql = N'Alter Table #TempOne Add [' + Cast(@CompDesc As nVarChar) + N'_Of_LST_'  + Cast(@TaxDesc as nVarchar(510)) +  N'% Tax]   
				Decimal(18, 6) Default(0) Not Null'  
				Exec sp_executesql @TempSql  
				Set @TaxCompIncr = @TaxCompIncr + 1
			end
			Drop Table #TempLSTCompDesc
		end
	End  
  
	If @Type = N'K'  
	Begin  
		Set @TempSql = N'Alter Table #TempOne Add [CST ' + Cast(@Tax As nVarChar) + N'% Sales_' +  Cast(@TaxDesc as nVarchar(510)) + N'] 
	 	Decimal(18, 6) Default(0) Not Null'  
		Exec sp_executesql @TempSql  
  	 	Set @TempSql = N'Alter Table #TempOne Add [CST ' + Cast(@Tax As nVarChar) + N'% Tax_' +  Cast(@TaxDesc as Nvarchar(510)) + N'] 
		Decimal(18, 6) Default(0) Not Null'  
	    Exec sp_executesql @TempSql  
		If @TaxSplitUp	= 'Yes' 
		begin
			Insert Into #tempTaxComp Select * From dbo.fn_GetTaxComponent(@TaxID,0)		        					
			Select [ID] = Identity(Int, 1, 1), TaxComponent InTo #TempCSTCompDesc From #tempTaxComp
			Select @TaxCompCnt = Count(*) From #TempCSTCompDesc
			Set @TaxCompIncr = 1
			While @TaxCompCnt >= @TaxCompIncr
			begin
				Select @CompDesc = TaxComponent From #TempCSTCompDesc Where [ID] = @TaxCompIncr
				Set @TempSql = N'Alter Table #TempOne Add [' + Cast(@CompDesc As nVarChar) + N'_Of_CST_'  + Cast(@TaxDesc as nVarchar(510)) +  N'% Tax]   
				Decimal(18, 6) Default(0) Not Null'  
				Exec sp_executesql @TempSql  
				Set @TaxCompIncr = @TaxCompIncr + 1
			end
			Drop Table #TempCSTCompDesc
		end
	End  
	If @Type = N'J'  
	Begin  
  		Set @TempSql = N'Alter Table #TempOne Add [Exempted Sales]   
		Decimal(18, 6) Default(0) Not Null'  
 		Exec sp_executesql @TempSql  
	End  
  
	If @Type = N'I'  
	Begin  
		Set @TempSql = N'Alter Table #TempOne Add 
		[Sales Tax Credit] Decimal(18,6) Default(0) Not Null,
		[Net Value]Decimal(18, 6) Default(0) Not Null, 
		[R/O] Decimal(18, 6) Default(0) Not Null,  
		[Rounded Net Value] Decimal(18, 6) Default(0) Not Null,
		[Credit Note Adjustments.(Rs.)] Decimal(18, 6) Default(0) Not Null,
		[F11 Adjustments (Rs.)] Decimal(18, 6) Default(0) Not Null,
		[Balance (Rs.)] Decimal(18, 6) Default(0) Not Null'
		Exec sp_executesql @TempSql  
	End  
  
	Set @j = 1  
	While @Count1 >= @j  
  	Begin  
    	Select @inv = InvoiceID From #TempFive Where [ID] = @j  

  		If Not Exists(Select * From #TempOne Where InvoiceID = @inv)  
		Begin  
			
			
			If @Type = N'L'  
  			Begin  

				Set @TempSql = N'Insert InTo #TempOne ([InvoiceID], [Date], [Serial No],   
                [Document No], [Customer Name],[Product Discount], [Gross Value], [Scheme Discount],   
				[Gross Amount After Scheme Discount], [Trade Discount], [Gross Amount After Trade Discount], [Addl Discount], [Gross Amount After Addl Discount],   
				[Freight], [Gross Amount After Freight]) 
				
				Select ia.InvoiceID, ia.InvoiceDate, Case IsNull(ia.GSTFlag,0) When 0 then  N''' + @Prefix + '''  + Cast(ia.DocumentID As nVarChar) Else IsNull(ia.GSTFullDocID,'''') END,  
				ia.DocReference, IsNull(c.Company_Name, ''Others''), 
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * IsNull(ia.ProductDiscount, 0)-(Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0))),     
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * IsNull(ia.GoodsValue, 0),   
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)) + IsNull(ia.SchemeDiscountAmount,0),  
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))- IsNull(ia.SchemeDiscountAmount,0),  
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * IsNull(ia.DiscountValue, 0) - IsNull(ia.SchemeDiscountAmount,0),   
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * (IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0),   
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * IsNull(ia.AddlDiscountValue, 0),   
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * ((IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0))  - IsNull(ia.AddlDiscountValue, 0),   
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * IsNull(ia.Freight, 0),   
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * (((IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0)) - IsNull(ia.AddlDiscountValue, 0)) + IsNull(ia.Freight, 0) 
				From InvoiceAbstract ia
				Inner Join InvoiceDetail ide ON ia.InvoiceID = ide.InvoiceID
				Left Outer Join Customer c ON ia.CustomerID = c.CustomerID
				Inner Join Tax t ON ide.TaxID = t.Tax_Code
				Where
 					t.Tax_Description in (Select * from #tmpTSlab)
					And ia.InvoiceID = ' + Cast(@inv As nVarChar) + N'
 				Group By ia.InvoiceID, ia.InvoiceDate, ia.DocumentID, ia.DocReference,   
 				c.Company_Name, ia.GoodsValue, ia.GrossValue, ia.DiscountValue, ia.AddlDiscountValue, ia.GSTFlag,ia.GSTFullDocID,  
 				ia.NetValue, ia.Freight, ia.InvoiceType,ia.SchemeDiscountAmount,ia.ProductDiscount'

				Exec sp_executesql @TempSql  

				--To select given tax related data
				select @SalesVal = (Case When (ia.InvoiceType = 4 And @AllInv = 1) Then -1 Else 1 End) * Sum(IsNull(ide.Amount, 0) - IsNull(ide.STPayable, 0)),
				@TaxVal = (Case When (ia.InvoiceType = 4 And @AllInv = 1) Then -1 Else 1 End) * Sum(IsNull(ide.STPayable, 0))   
				from InvoiceAbstract Ia,Invoicedetail Ide where Ide.invoiceid = @inv and Ia.Invoiceid=ide.invoiceid and Ide.Taxid = @TaxId and Ide.TaxCode = @tax
				group by InvoiceType
				
				Set @TempSql = N'Update #TempOne Set [LST ' + Cast(@Tax As nVarChar) + N'% Sales_' +  Cast(@TaxDesc as nVarchar(510)) + N'] = ' + Cast(@SalesVal as nVarchar) + ',
				[LST ' + Cast(@Tax As nVarChar) + N'% Tax_' +  Cast(@TaxDesc as nVarchar(510)) + N'] = ' + cast(@TaxVal as nVarchar) + '   				
				Where InvoiceID = ' + Cast(@inv as nVarChar) 
				   

				Exec sp_executesql @TempSql 
				set @SalesVal = 0
				set @TaxVal = 0

				If @TaxSplitUp	= 'Yes'
				begin
					Declare  cur_Taxcomp Cursor For 
					Select ComponentCode,TaxComponent From #tempTaxComp
					Open cur_Taxcomp
					Fetch Next From cur_Taxcomp Into @CompCode,@CompDesc
					While @@Fetch_Status = 0
					Begin
						Select  @TaxComponentValue = Sum(Isnull(Tax_Value,0)) From InvoiceTaxComponents Where Tax_Code = @TaxID And Tax_Component_Code = @CompCode				 
						and InvoiceID = @inv  Group By InvoiceID,Tax_Code, Tax_Component_Code
						Set @TempSql = N'Update #TempOne Set [' + Cast(@CompDesc As nVarChar) + N'_Of_LST_' + Cast(@TaxDesc as nVarchar(510)) + N'% Tax] 
						=' + Cast(@TaxComponentValue as nvarchar) + N'Where InvoiceID = ' + Cast(@inv as nVarchar) +''
						Exec sp_executesql @TempSql  
						Set @TaxComponentValue = 0
						Fetch Next From cur_Taxcomp Into @CompCode,@CompDesc
					end
					Close cur_Taxcomp
					Deallocate cur_Taxcomp 
				end
			End  
			Else If @Type = N'K'  
			Begin  
				Set @TempSql = N'Insert InTo #TempOne ([InvoiceID], [Date], [Serial No],   
				[Document No], [Customer Name],[Product Discount], [Gross Value], [Scheme Discount],   
				[Gross Amount After Scheme Discount], [Trade Discount], [Gross Amount After Trade Discount], [Addl Discount], [Gross Amount After Addl Discount],   
				[Freight], [Gross Amount After Freight])
				Select ia.InvoiceID, ia.InvoiceDate, 
				Case IsNull(ia.GSTFlag,0) When 0 then N''' + @Prefix + ''' + Cast(ia.DocumentID As nVarChar) Else IsNull(ia.GSTFullDocID '' '')END,  
				ia.DocReference, IsNull(c.Company_Name, ''Others''),   
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * IsNull(ia.ProductDiscount, 0)-(Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0))),     
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * IsNull(ia.GoodsValue, 0),   
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)) + IsNull(ia.SchemeDiscountAmount,0),  
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0))) - IsNull(ia.SchemeDiscountAmount,0),  
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * IsNull(ia.DiscountValue, 0) - IsNull(ia.SchemeDiscountAmount,0),   
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * (IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0),   
				(Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * IsNull(ia.AddlDiscountValue, 0),   
	            (Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * ((IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0)) - IsNull(ia.AddlDiscountValue, 0),   
       		    (Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * IsNull(ia.Freight, 0),   
		        (Case When (ia.InvoiceType = 4 And ' + Cast(@AllInv as nVarchar) + '= 1) Then -1 Else 1 End) * (((IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0)) - IsNull(ia.AddlDiscountValue, 0)) + IsNull(ia.Freight, 0),
				From InvoiceAbstract ia
				Inner Join InvoiceDetail ide ON ia.InvoiceID = ide.InvoiceID
				Left Outer Join Customer c ON ia.CustomerID = c.CustomerID
				Inner Join Tax t ON t.Tax_Code = ide.TaxID
				Where				 
					t.Tax_Description in (Select * from #tmpTSlab) and 				
					ia.InvoiceID = ' + Cast(@inv As nVarChar) + N'
				Group By ia.InvoiceID, ia.InvoiceDate, ia.DocumentID, ia.DocReference,   
				c.Company_Name, ia.GoodsValue, ia.GrossValue, ia.DiscountValue, ia.AddlDiscountValue,ia.GSTFlag,ia.GSTFullDocID ,   
				ia.NetValue, ia.Freight, ia.InvoiceType,ia.SchemeDiscountAmount,ia.ProductDiscount'  

				Exec sp_executesql @TempSql  

				--To select given tax related data
				select @SalesVal = (Case When (ia.InvoiceType = 4 And @AllInv = 1) Then -1 Else 1 End) * Sum(IsNull(ide.Amount, 0) - IsNull(ide.CSTPayable, 0)),
				@TaxVal = (Case When (ia.InvoiceType = 4 And @AllInv = 1) Then -1 Else 1 End) * Sum(IsNull(ide.CSTPayable, 0))   
				from InvoiceAbstract Ia,Invoicedetail Ide where Ide.invoiceid = @inv and Ia.Invoiceid=ide.invoiceid and Ide.Taxid = @TaxId and Ide.TaxCode2 = @tax
				group by InvoiceType

				Set @TempSql = N'Update #TempOne Set [CST ' + Cast(@Tax As nVarChar) + N'% Sales_' +  Cast(@TaxDesc as nvarchar(510)) + N'] = ' + Cast(@SalesVal as nVarchar) + ',
				[CST ' + Cast(@Tax As nVarChar) + N'% Tax_'+  Cast(@TaxDesc as nVarchar(510)) + N'] = ' + cast(@TaxVal as nVarchar) + '   				
				Where InvoiceID = ' + Cast(@inv as nVarChar) 
				--+ ' ide.TaxID = ' + Cast(@TaxID as nVarchar) + N' ide.TaxCode = ' +  Cast(@Tax As nVarChar)   
				Exec sp_executesql @TempSql 
				set @SalesVal = 0
				set @TaxVal = 0

				If @TaxSplitUp	= 'Yes'
				begin
					Declare  cur_Taxcomp Cursor For 
					Select ComponentCode,TaxComponent From #tempTaxComp
					Open cur_Taxcomp
					Fetch Next From cur_Taxcomp Into @CompCode,@CompDesc
					While @@Fetch_Status = 0
					Begin
						Select  @TaxComponentValue = Sum(Isnull(Tax_Value,0)) From InvoiceTaxComponents Where Tax_Code = @TaxID And Tax_Component_Code = @CompCode				 
						and InvoiceID = @inv Group By InvoiceID,Tax_Code, Tax_Component_Code
						Set @TempSql = N'Update #TempOne Set [' +  Cast(@CompDesc As nVarChar) + N'_Of_CST_' + Cast(@TaxDesc as nVarchar(510)) + N'% Tax] 
						=' + Cast(@TaxComponentValue as nvarchar) + N'Where InvoiceID = ' + Cast(@inv as nVarchar) +''
						Set @TaxComponentValue = 0
						Exec sp_executesql @TempSql  
						Fetch Next From cur_Taxcomp Into @CompCode,@CompDesc
					end
					Close cur_Taxcomp
					Deallocate cur_Taxcomp 
				end
			End  
			Else If @Type = N'J'  
  			Begin  
				Set @TempSql = N'Insert InTo #TempOne ([InvoiceID], [Date], [Serial No],   
				[Document No], [Customer Name],[Product Discount], [Gross Value], [Scheme Discount],   
				[Gross Amount After Scheme Discount], [Trade Discount], [Gross Amount After Trade Discount], [Addl Discount], [Gross Amount After Addl Discount],   
				[Freight], [Gross Amount After Freight], [Exempted Sales])  
				Select ia.InvoiceID, ia.InvoiceDate, Case IsNull(ia.GSTFlag,0) When 0 Then N''' + @Prefix + ''' + Cast(ia.DocumentID as nVarchar) Else IsNull(ia.GSTFullDocID,'' '')END,  
				ia.DocReference, IsNull(c.Company_Name, ''Others''),   
				(Case When (ia.InvoiceType = 4 And ' + cast(@AllInv as nvarchar)   + N'=1) Then -1 Else 1 End) * IsNull(ia.ProductDiscount, 0)-(Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0))),     
				(Case When (ia.InvoiceType = 4 And ' + cast(@AllInv as nvarchar)   + N'=1) Then -1 Else 1 End) * IsNull(ia.GoodsValue, 0),   
				(Case When (ia.InvoiceType = 4 And ' + cast(@AllInv as nvarchar)   + N'=1) Then -1 Else 1 End) * Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)) +IsNull(ia.SchemeDiscountAmount,0),  
				(Case When (ia.InvoiceType = 4 And ' + cast(@AllInv as nvarchar)   + N'=1) Then -1 Else 1 End) * IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0))) -IsNull(ia.SchemeDiscountAmount,0),  
				(Case When (ia.InvoiceType = 4 And ' + cast(@AllInv as nvarchar)   + N'=1) Then -1 Else 1 End) * IsNull(ia.DiscountValue, 0) - IsNull(ia.SchemeDiscountAmount,0),   
				(Case When (ia.InvoiceType = 4 And ' + cast(@AllInv as nvarchar)   + N'=1) Then -1 Else 1 End) * (IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0),   
				(Case When (ia.InvoiceType = 4 And ' + cast(@AllInv as nvarchar)   + N'=1) Then -1 Else 1 End) * IsNull(ia.AddlDiscountValue, 0),   
		        (Case When (ia.InvoiceType = 4 And ' + cast(@AllInv as nvarchar)   + N'=1) Then -1 Else 1 End) * ((IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0)) - IsNull(ia.AddlDiscountValue, 0),   
        		(Case When (ia.InvoiceType = 4 And ' + cast(@AllInv as nvarchar)   + N'=1) Then -1 Else 1 End) * IsNull(ia.Freight, 0),   
				(Case When (ia.InvoiceType = 4 And ' + cast(@AllInv as nvarchar)   + N'=1) Then -1 Else 1 End) * (((IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0)) - IsNull(ia.AddlDiscountValue, 0)) + IsNull(ia.Freight, 0),
   				(Case When (ia.InvoiceType = 4 And ' + cast(@AllInv as nvarchar)   + N'=1) Then -1 Else 1 End) * Sum(IsNull(ide.Amount, 0))   
				From InvoiceAbstract ia
				Inner Join InvoiceDetail ide ON ia.InvoiceID = ide.InvoiceID
				Left Outer Join Customer c ON ia.CustomerID = c.CustomerID
				Inner Join (Select distinct InvoiceID From InvoiceDetail Where IsNull(TaxID, -2) In (Select Tax_Code From #TempSix) ) t ON ide.InvoiceID = t.InvoiceID
				Where				
					(IsNull(ide.TaxCode, 0) + IsNull(ide.TaxCode2, 0)) = 0  And
					ia.InvoiceID = ' + Cast(@inv As nVarChar) + N' 
		        Group By ia.InvoiceID, ia.InvoiceDate, ia.DocumentID, ia.DocReference,   
        		c.Company_Name, ia.GoodsValue, ia.GrossValue, ia.DiscountValue, ia.AddlDiscountValue, ia.GSTFlag,ia.GSTFullDocID ,  
		        ia.NetValue, ia.Freight, ia.InvoiceType,ia.SchemeDiscountAmount,ia.ProductDiscount' 
				
				Exec sp_executesql @TempSql  
  			End  
  			Else If @Type = N'I'  
			Begin  
				Set @TempSql = N''  
				Exec sp_executesql @TempSql  
			End  
 --   			Exec sp_executesql @TempSql  
		End  
		Else  
 		Begin  
			
			If @Type = N'L'  
			Begin  
		     	Set @SalesVal = 0  
				Set @TaxVal = 0  
  
			    Select @SalesVal = (Case When (ia.InvoiceType = 4 	And @AllInv = 1 )Then -1 Else 1 End) * Sum(ide.Amount - ide.STPayable),   
				@TaxVal = (Case When (ia.InvoiceType = 4 And @AllInv = 1 ) Then -1 Else 1 End) * Sum(ide.STPayable)  
				From InvoiceAbstract ia, InvoiceDetail ide Where ia.InvoiceID = ide.InvoiceId  
				And ide.TaxCode = @Tax And ia.InvoiceID = @inv And ide.TaxID = @TaxID Group By ia.InvoiceType  
              
				Set @TempSql = N'Update #TempOne Set [LST ' + Cast(@Tax As nVarChar) + N'% Sales_' + Cast(@TaxDesc as nVarchar(510)) + N'] =   
				[LST ' + Cast(@Tax As nVarChar) + N'% Sales_' + Cast(@TaxDesc as nVarchar(510)) + N'] +'  + Cast(@SalesVal As nVarChar) + N',   
				[LST ' + Cast(@Tax As nVarChar) + N'% Tax_' + Cast(@TaxDesc as nVarchar(510)) + N'] = 
				[LST ' + Cast(@Tax As nVarChar) + N'% Tax_' + Cast(@TaxDesc as nVarchar(510)) + N']+'    
				+ Cast(@TaxVal As nVarChar) + N' Where InvoiceID = ' + Cast(@inv as nVarChar) + '' 
				Exec sp_executesql @TempSql 
				If @TaxSplitUp	= 'Yes'
				begin
					Declare  cur_Taxcomp Cursor For 
					Select ComponentCode,TaxComponent From #tempTaxComp
					Open cur_Taxcomp
					Fetch Next From cur_Taxcomp Into @CompCode,@CompDesc
					While @@Fetch_Status = 0
					Begin
						Select  @TaxComponentValue = Sum(Isnull(Tax_Value,0)) From InvoiceTaxComponents Where Tax_Code = @TaxID And Tax_Component_Code = @CompCode				 
						and InvoiceID = @inv Group By InvoiceID,Tax_Code, Tax_Component_Code
						Set @TempSql = N'Update #TempOne Set [' + Cast(@CompDesc As nVarChar) + N'_Of_LST_' + Cast(@TaxDesc as nVarchar(510)) + N'% Tax] 
						=[' + Cast(@CompDesc As nVarChar) + N'_Of_LST_' + Cast(@TaxDesc as nVarchar(510)) + N'% Tax] +' + Cast(@TaxComponentValue as nvarchar) + N'Where InvoiceID = ' + Cast(@inv as nVarchar) +''
						Exec sp_executesql @TempSql  
						Set @TaxComponentValue = 0
						Fetch Next From cur_Taxcomp Into @CompCode,@CompDesc
					end
					Close cur_Taxcomp
					Deallocate cur_Taxcomp 
				end 
    		End  
  			Else If @Type = N'K'  
			Begin  
            	Set @SalesVal = 0  
				Set @TaxVal = 0  
		
				Select @SalesVal = (Case When (ia.InvoiceType = 4 And @AllInv = 1 ) Then -1 Else 1 End) * Sum(ide.Amount - ide.CSTPayable),   
				@TaxVal = (Case When(ia.InvoiceType = 4 And @AllInv = 1 ) Then -1 Else 1 End) * Sum(ide.CSTPayable)  
				From InvoiceAbstract ia, InvoiceDetail ide Where ia.InvoiceID = ide.InvoiceId  
				And ide.TaxCode2 = @Tax And ia.InvoiceID = @inv And ide.TaxID = @TaxID Group By ia.InvoiceType  
        
				Set @TempSql = N'Update #TempOne Set [CST ' + Cast(@Tax As nVarChar) + N'% Sales_' + Cast(@TaxDesc as nVarchar(510)) + N'] =   
				[CST ' + Cast(@Tax As nVarChar) + N'% Sales_' + Cast(@TaxDesc as nVarchar(510)) + N'] +'  + Cast(@SalesVal As nVarChar) + N',   
				[CST ' + Cast(@Tax As nVarChar) + N'% Tax_' + Cast(@TaxDesc as nVarchar(510)) + N'] = 
				[CST ' + Cast(@Tax As nVarChar) + N'% Tax_' + Cast(@TaxDesc as nVarchar(510)) + N']+'    
				+ Cast(@TaxVal As nVarChar) + N' Where InvoiceID = ' + Cast(@inv as nVarChar) + '' 
				Exec sp_executesql @TempSql   
				If @TaxSplitUp	= 'Yes'
				begin
					Declare  cur_Taxcomp Cursor For 
					Select ComponentCode,TaxComponent From #tempTaxComp
					Open cur_Taxcomp
					Fetch Next From cur_Taxcomp Into @CompCode,@CompDesc
					While @@Fetch_Status = 0
					Begin
						Select  @TaxComponentValue = Sum(Isnull(Tax_Value,0)) From InvoiceTaxComponents Where Tax_Code = @TaxID And Tax_Component_Code = @CompCode				 
						and InvoiceID = @inv Group By InvoiceID,Tax_Code, Tax_Component_Code
						Set @TempSql = N'Update #TempOne Set [' +  Cast(@CompDesc As nVarChar) + N'_Of_CST_' + Cast(@TaxDesc as nVarchar(510)) + N'% Tax] 
						=[' +  Cast(@CompDesc As nVarChar) + N'_Of_CST_' + Cast(@TaxDesc as nVarchar(510)) + N'% Tax]+ ' + Cast(@TaxComponentValue as nvarchar) + N'Where InvoiceID = ' + Cast(@inv as nVarchar) +''
						Exec sp_executesql @TempSql  
						Set @TaxComponentValue = 0
						Fetch Next From cur_Taxcomp Into @CompCode,@CompDesc
					end
					Close cur_Taxcomp
					Deallocate cur_Taxcomp 
				end
			End  
			Else If @Type = N'J'  
			Begin  
            	Set @SalesVal = 0  
				Set @TaxVal = 0  
  			    Select @SalesVal = (Case When(ia.InvoiceType = 4 And @AllInv = 1 ) Then -1 Else 1 End) * Sum(ide.Amount)  
	       		-- @TaxVal = (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(ide.STPayable)  
				From InvoiceAbstract ia, InvoiceDetail ide Where ia.InvoiceID = ide.InvoiceId  
				And (IsNull(ide.TaxCode, 0) + IsNull(ide.TaxCode2, 0)) = @Tax And   
				ia.InvoiceID = @inv Group By ia.InvoiceType  
	            Set @TempSql = N'Update #TempOne Set [Exempted Sales] =   
			    [Exempted Sales] + ' + Cast(@SalesVal As nVarChar) + N'  
				Where InvoiceID = ' + Cast(@inv as nVarChar) + ''  
				Exec sp_executesql @TempSql 
			End  
        	Else If @Type = N'I'  
			Begin  
            	Set @SalesVal = 0  
				Set @TaxVal = 0  
				Set @StCredit = 0
				Set @CrdNt = 0	
				Set @F11adj = 0
				Set @Balance = 0 
				Select @SalesVal = (Case When(ia.InvoiceType = 4 And @AllInv = 1 ) Then -1 Else 1 End) * IsNull(ia.NetValue, 0),  
				@TaxVal = (Case When(ia.InvoiceType = 4 And @AllInv = 1 ) Then -1 Else 1 End) * IsNull(ia.RoundOffAmount, 0)  ,
				@StCredit =(Case When(ia.InvoiceType = 4 And @AllInv = 1 ) Then -1 Else 1 End)*(Select Sum(IsNull(stcredit,0)) From InvoiceDetail Where InvoiceID = @inv),
	   	        @CrdNt = (Case When(ia.InvoiceType = 4 And @AllInv = 1 ) Then -1 Else 1 End) * (Select Sum(IsNull(AdjustedAmount,0)) From CollectionDetail Where CollectionID = isnull(ia.PaymentDetails,0) And DocumentType IN(1,2)   
                And DocumentID Not In(Select IsNull(ReferenceID,0) From AdjustmentReference Where InvoiceID = ia.InvoiceID )),    
  				@F11adj = (Case When(ia.InvoiceType = 4 And @AllInv = 1 ) Then -1 Else 1 End) * IsNull(ia.AdjustmentValue,0),
				@Balance = (Case When(ia.InvoiceType = 4 And @AllInv = 1 ) Then -1 Else 1 End)*IsNull(ia.Balance,0)
				From InvoiceAbstract ia Where ia.InvoiceID = @inv  
	
				Set @TempSql = N'Update #TempOne Set 
				[Sales Tax Credit] = '+ Cast(@StCredit as nVarchar) + N',
				[Net Value] =[Net Value] + ' + Cast(@SalesVal As nVarChar) + N',  
				[R/O] = [R/O] + ' + Cast(@TaxVal As nVarChar) + N',  
				[Rounded Net Value] = ' + Cast(@SalesVal + @TaxVal As nVarChar) + N',
				[Credit Note Adjustments.(Rs.)]  = ' + Cast(isnull(@CrdNt,0) as nVarchar) + N',
				[F11 Adjustments (Rs.)] =  ' + Cast(@F11adj as nVarchar) + N',
				[Balance (Rs.)] = ' + Cast(@Balance as nVarchar) + N'
				Where InvoiceID = ' + Cast(@inv as nVarChar) + '' 
				Exec sp_executesql @TempSql 
  			End  
--  			Exec sp_executesql @TempSql  
		End  
    	Set @j = @j + 1   
		
		
	End  
  Set @i = @i + 1  
If @TaxSplitUp	= 'Yes'
Delete From #tempTaxComp
End  

Select * From #TempOne order by [Serial No]
--order by cast(Replace([Serial No],@Prefix,'')as int)  
  
Drop Table #TempOne  
Drop Table #TempTwo  
Drop Table #TempThree  
Drop Table #TempFour  
Drop Table #TempFive  
Drop Table #tmpCus  
Drop Table #tmpTSlab  
Drop Table #TempSix  
Drop Table #TmpInvType
Drop Table #tmpPaymode
Drop Table #TmpPayMode2
If @TaxSplitUp	= 'Yes'
Drop Table  #tempTaxComp

End
