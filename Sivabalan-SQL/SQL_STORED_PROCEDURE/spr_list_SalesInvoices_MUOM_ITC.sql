Create PROCEDURE spr_list_SalesInvoices_MUOM_ITC  
(
	@FROMDATE datetime,              
	@TODATE datetime,              
	@DocType nvarchar(100), 
	@PaymentMode nVarchar(50),
	@InvoiceType nVarChar(50),  
	@UOMDesc nVarchar(30),
	@SalesmanID nVarchar(255),
	@BreakUpValue nvarchar(20)
)              
AS              

Begin
DECLARE @INV AS NVARCHAR(50)              
DECLARE @CASH AS NVARCHAR(50)  
DECLARE @CREDIT AS NVARCHAR(50)              
DECLARE @CHEQUE AS NVARCHAR(50)  
DECLARE @DD AS NVARCHAR(50)  
Declare @Delimeter Char(1)      
DECLARE @OTHERS AS NVARCHAR(50) 
DECLARE @SysDt as Datetime
DECLARE @Title as nVarchar(50)
DECLARE @TaxCompDesc as nVarchar(255)
DECLARE @TaxDesc as nVarchar(255)
DECLARE @Str as nVarchar(4000)
Declare @TaxID Int
Declare @InvoiceCount Int
Declare @TmpInvoiceCount Int
Declare @TmpInvoiceID Int
Declare @TaxValue decimal(18,6)
Declare @TaxCompCode Int
Declare @Locality Int
Declare @LST Int
Declare @CST Int
Declare @Flag Int
Declare @TempTaxDesc nVarchar(255)

Declare @Cur_OutStanding Cursor         
Declare @CustomerID nVarchar(50)
declare @AcId as Int, @InvType as nVarchar(10)
Set @Delimeter = Char(15)        
set dateformat dmy
SELECT @CASH = DBO.LookUpDictionaryItem(N'Cash',default)  
SELECT @OTHERS = DBO.LookUpDictionaryItem(N'Others',default)  
Set @SysDt = GetDate()
  
SELECT @CREDIT = DBO.LookUpDictionaryItem(N'Credit',default)  
SELECT @CHEQUE = DBO.LookUpDictionaryItem(N'Cheque',default)  
SELECT @DD = DBO.LookUpDictionaryItem(N'DD',default)  
SELECT @OTHERS = DBO.LookUpDictionaryItem(N'Others',default)  
Set @SysDt = GetDate()
  
Create Table #TmpInvType(InvType int)            
--Create Table #TmpPaymode(paymode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #TmpPaymode(paymode int)                        
Create Table #TmpPayMode2(paymode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, pid int)  
--Create Table #TmpTax(Title nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, InvoiceID Int, TaxDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, TaxCompDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 
Create Table #TmpTax(Title nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, TaxDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, TaxCompDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 
Create Table #SalesTaxComponent (InvoiceId Int)
  
Insert Into #TmpPayMode2 Values (N'Credit', 0)  
Insert Into #TmpPayMode2 Values (N'Cash', 1)  
Insert Into #TmpPayMode2 Values (N'Cheque', 2)  
Insert Into #TmpPayMode2 Values (N'DD', 3)  

Create Table #TmpAbstract(InvID Int,InvoiceID nVarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,[Doc Ref] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
Date DateTime,[Payment Mode] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,[Payment Date] DateTime,[Credit Term] nVarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID nVarchar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,Customer nVarchar(300)COLLATE SQL_Latin1_General_CP1_CI_AS,[Forum Code] nVarchar(40),[Goods Value] Decimal(18,6),[Product Discount] Decimal(18,6),
[Trade Discount%] nVarchar(100),[Trade Discount] Decimal(18,6),[Addl Discount%] nVarchar(100),[Addl Discount] Decimal(18,6),[Net Value] Decimal(18,6),[Net Volume] Decimal(18,6),
[Adj Ref] nVarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,[Adjusted Amount] Decimal(18,6),Balance Decimal(18,6),[Collected Amount] Decimal(18,6),[Current Outstanding] Decimal(18,6),Branch nVarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
Beat nVarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,Salesman Nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,[Category Group] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
Reference nVarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,[Round off] Decimal(18,6),[Document Type] nVarchar(200)COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Total TaxSuffered Value(%c)] Decimal(18,6),[Total SalesTax Value(%c)] Decimal(18,6))


Create Table #tmpCustOutStanding(CustomerID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,TotalOutStanding Decimal(18,6),AccountID Int)
  

if  @PaymentMode = '%'              
--   Insert into #TmpPaymode select [values] from QueryParams where QueryParamID In (11, 26) And [Values] Not In ('Bank Transfer')  
     Insert into #TmpPaymode select pid from #TmpPayMode2
else              
--   Insert into #TmpPaymode select * from dbo.sp_SplitIn2Rows(@InvoiceType, @Delimeter)              
	 Insert into #TmpPaymode Select Pid From #TmpPayMode2 
		Where paymode in (select * from dbo.sp_SplitIn2Rows( @PaymentMode, @Delimeter))	

Create Table #TempSalesman (SalesmanID Int)
         
If @SalesmanID = 'All Salesman' or @SalesmanID = '%'
	Insert Into #TempSalesman Select SalesmanID From Salesman
Else
	Insert Into #TempSalesman Select SalesmanID From Salesman Where Salesman_Name In
		(Select * From dbo.sp_SplitIn2Rows( @SalesmanID, @Delimeter))

  
SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'              
              
If @InvoiceType = N'%'
Begin
	Insert Into #TmpInvType Select 1
	Insert Into #TmpInvType Select 3
	Insert Into #TmpInvType Select 4
End
Else If @InvoiceType = N'Sales Invoices'
Begin
	Insert Into #TmpInvType Select 1
	Insert Into #TmpInvType Select 3
End
Else
	Insert Into #TmpInvType Select 4

Insert Into #TmpAbstract
(
InvID ,InvoiceID ,[Doc Ref],Date ,[Payment Mode] ,[Payment Date],[Credit Term],CustomerID ,Customer ,[Forum Code] ,[Goods Value] ,[Product Discount],
[Trade Discount%] ,[Trade Discount] ,[Addl Discount%] ,[Addl Discount] ,[Net Value] ,[Net Volume] ,[Adj Ref] ,[Adjusted Amount] ,Balance ,[Collected Amount] ,
[Current Outstanding] ,Branch ,Beat ,Salesman ,[Category Group] ,Reference ,[Round off] ,[Document Type] , 
[Total TaxSuffered Value(%c)],[Total SalesTax Value(%c)] 
)
SELECT  InvoiceID, 
"InvoiceID" =case  ISNULL(GSTFlag,0) when 0 then  Cast(@INV  AS nVarchar)+ Cast(Documentid As nVarchar) else ISNULL(GSTFullDocID,'') end,              
"Doc Ref" = InvoiceAbstract.DocReference,              
"Date" = InvoiceDate,               
"Payment Mode" = case IsNull(PaymentMode,0)              
When 0 Then @Credit              
When 1 Then @Cash              
When 2 Then @Cheque              
When 3 Then @DD              
Else @Credit              
End,              
"Payment Date" = PaymentDate,              
"Credit Term" = CreditTerm.Description,             
"CustomerID" = Customer.CustomerID,               
"Customer" = Customer.Company_Name,              
"Forum Code" = Customer.AlternateCode,              
"Goods Value" = (Case When (@InvoiceType=N'%' And InvoiceType=4) Then (0 - GoodsValue) Else GoodsValue End),               
"Product Discount" = (Case When (@InvoiceType=N'%' And InvoiceType=4) Then (0 - ProductDiscount) Else ProductDiscount End),              
"Trade Discount%" = CAST(Cast(DiscountPercentage as Decimal(18,6)) AS nvarchar) + N'%',                 
"Trade Discount" = (Case When (@InvoiceType=N'%' And InvoiceType=4) Then (0 - IsNull(Discountvalue, 0)) Else IsNull(Discountvalue, 0) End),  
-- Cast(InvoiceAbstract.GoodsValue * (DiscountPercentage /100) as Decimal(18,6)),                
"Addl Discount%" = CAST(AdditionalDiscount AS nvarchar) + N'%',                
"Addl Discount" = (Case When (@InvoiceType=N'%' And InvoiceType=4) Then (0 - IsNull(AddlDiscountvalue, 0)) Else IsNull(AddlDiscountvalue, 0) End),  
-- InvoiceAbstract.GoodsValue * (AdditionalDiscount / 100),                
"Net Value" = (Case When (@InvoiceType=N'%' And InvoiceType=4) Then (0 - NetValue) Else NetValue End),              
"Net Volume" = 
	(Case When (@InvoiceType=N'%' And InvoiceType=4) Then (0 -   
		(Case         
		When @UOMdesc = N'UOM1' then         
		(Select Sum(Quantity/Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End) from Items, InvoiceDetail         
		Where Items.Product_Code = InvoiceDetail.Product_Code and         
		InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)        
		When @UOMdesc = N'UOM2' then         
		(Select Sum(Quantity/Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End) from Items, InvoiceDetail         
		Where Items.Product_Code = InvoiceDetail.Product_Code and         
		InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)        
		Else        
		(Select Sum(Quantity) from Items, InvoiceDetail         
		Where Items.Product_Code = InvoiceDetail.Product_Code and         
		InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)        
		End)) 
	Else
		(Case         
		When @UOMdesc = N'UOM1' then         
		(Select Sum(Quantity/Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End) from Items, InvoiceDetail         
		Where Items.Product_Code = InvoiceDetail.Product_Code and         
		InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)        
		When @UOMdesc = N'UOM2' then         
		(Select Sum(Quantity/Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End) from Items, InvoiceDetail         
		Where Items.Product_Code = InvoiceDetail.Product_Code and         
		InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)        
		Else        
		(Select Sum(Quantity) from Items, InvoiceDetail         
		Where Items.Product_Code = InvoiceDetail.Product_Code and         
		InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)        
		End)
	End),  
"Adj Ref" = IsNull(InvoiceAbstract.AdjRef, N''),    
"Adjusted Amount" = (Case When (@InvoiceType=N'%' And InvoiceType=4) Then (0 - IsNull(InvoiceAbstract.AdjustedAmount, 0)) Else IsNull(InvoiceAbstract.AdjustedAmount, 0) End),              
"Balance" = (Case When (@InvoiceType=N'%' And InvoiceType=4) Then (0 - InvoiceAbstract.Balance) Else InvoiceAbstract.Balance End),              
--"Collected Amount" = NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0),              
"Collected Amount" = (Case When (@InvoiceType=N'%' And InvoiceType=4) Then (0 - Isnull(dbo.fn_getInvCollectedAmount(InvoiceAbstract.CustomerId,InvoiceAbstract.InvoiceID,@TODATE),0)) Else Isnull(dbo.fn_getInvCollectedAmount(InvoiceAbstract.CustomerId,
InvoiceAbstract.InvoiceID,@TODATE),0) End),
"Outstanding " = 0,
"Branch" = ClientInformation.Description,              
"Beat" = Case IsNull(Beat.[Description], N'') When N'' Then @OTHERS 
	Else IsNull(Beat.[Description], N'') End,

"Salesman" = Case IsNull(Salesman.Salesman_Name, N'') When N'' Then @OTHERS
	    else IsNull(Salesman.Salesman_Name, N'') end ,              
"Category Group" = dbo.Fn_GetCG_ITC(InvoiceAbstract.InvoiceID),
"Reference" =               
CASE Status & 15              
WHEN 1 THEN              
''              
WHEN 2 THEN              
''              
WHEN 4 THEN              
''              
WHEN 8 THEN              
''              
END              
+ CAST(NewReference AS nVARCHAR),              
"Round Off" = (Case When (@InvoiceType=N'%' And InvoiceType=4) Then (0 - RoundOffAmount) Else RoundOffAmount End),              
"Document Type" = DocSerialType,              
"Total TaxSuffered Value(%c)" =  (Case When (@InvoiceType=N'%' And InvoiceType=4) Then (0 - (Select Sum((Quantity * SalePrice) * IsNull(TaxSuffered, 0) / 100) From InvoiceDetail  
                               Where InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID)) Else (Select Sum((Quantity * SalePrice) * IsNull(TaxSuffered, 0) / 100) From InvoiceDetail  
                               Where InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID) End),  
"Total SalesTax Value(%c)" = (Case When (@InvoiceType=N'%' And InvoiceType=4) Then (0 - (Select Sum(STPayable + CSTPayable) From InvoiceDetail  
      Where InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID)) Else (Select Sum(STPayable + CSTPayable) From InvoiceDetail  
      Where InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID) End) 

FROM InvoiceAbstract
Inner Join  Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
Left Outer Join  CreditTerm On InvoiceAbstract.CreditTerm = CreditTerm.CreditID
Left Outer Join  ClientInformation On InvoiceAbstract.ClientID = ClientInformation.ClientID 
Left Outer Join  Beat On InvoiceAbstract.BeatID = Beat.BeatID
Left Outer Join  Salesman  On InvoiceAbstract.SalesmanID = Salesman.SalesmanID             
--, #TmpPayMode2              
WHERE 
InvoiceAbstract.DocSerialType like @DocType And
(InvoiceAbstract.Status & 128) = 0 And  
InvoiceType in (Select InvType From #TmpInvType) AND 
InvoiceDate BETWEEN @FROMDATE AND @TODATE AND              
InvoiceAbstract.SalesmanID In(Select SalesmanID From #TempSalesman) And         
--InvoiceAbstract.PaymentMode = #TmpPayMode2.PID And  
InvoiceAbstract.PaymentMode In (Select paymode From #TmpPaymode) 
Order By DocumentID
--Inserts distincts customerID for calculating the outstanding
Insert Into #tmpCustOutStanding(CustomerID,AccountID) 
(Select CustomerID,AccountID From  Customer where CustomerID in (select Distinct CustomerID from #TmpAbstract) )

	--Cursor to find the Total outstanding for the customer 
	Set @Cur_OutStanding = Cursor For Select CustomerID,AccountID From #tmpCustOutStanding
	Open @Cur_OutStanding
	 Fetch Next From @Cur_OutStanding Into @CustomerID,@AcID
	While @@Fetch_Status = 0
	Begin
		--Updates the Outstanding field for each Customer
			Update #TmpAbstract Set [Current Outstanding] = dbo.sp_acc_getaccountbalance_ITC(@AcId,@Todate,@SysDt)
	
			where CustomerID = @CustomerId
	Fetch Next From @Cur_OutStanding Into @CustomerID,@AcID
	
	End  

If @BreakUpValue = 'Yes'
Begin

	Insert Into #SalesTaxComponent Select InvID From #TmpAbstract

	--Select TaxValue to update	
	Select InvoiceDetail.InvoiceId, TaxID, Case When InvoiceType = 4 Then 0 - Sum(STPayable) Else Sum(STPayable) End as ST, Case When InvoiceType = 4 Then 0 -Sum(CSTPayable) Else Sum(CSTPayable) End as CST Into #TempTaxValue --Sum(CSTPayable) as CST Into #TempTaxValue 
		From InvoiceAbstract, InvoiceDetail
		Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
		And InvoiceDetail.InvoiceId   In (Select Distinct(InvoiceID ) From #SalesTaxComponent)
		Group By InvoiceDetail.InvoiceId, TaxID,InvoiceType 
		Order By InvoiceDetail.InvoiceID

	--Select TaxComponent Value to update
	Select Distinct  IA.InvoiceId, ID.TaxID, TaxComponent_Code, 
		(Select Case When IA.InvoiceType = 4 Then 0 - Sum(Tax_Value) 
		Else Sum(Tax_Value)  End From InvoiceTaxComponents Where InvoiceID = IA.InvoiceID And
		Tax_Code =  ID.TaxID and Tax_Component_Code = TCD.TaxComponent_Code)  as TaxCompValue, Case When TaxCode <> 0 Then 1 
		When TaxCode2 <> 0 Then 2
		Else 0 End as LST
 	Into #TempTaxCompValue 
	From InvoiceAbstract IA, InvoiceDetail ID, TaxComponentDetail TCD,  InvoiceTaxComponents ITC
	Where IA.InvoiceID = ID.InvoiceID
	And ID.InvoiceID In(Select Distinct(InvoiceID) From #SalesTaxComponent)
	And IA.InvoiceDate Between @FromDate And @ToDate
	And IA.SalesmanID In(Select SalesmanID From  #TempSalesman)
	And (IA.Status & 128)=0 
	And  ID.InvoiceID = ITC.InvoiceID  
	And ITC.InvoiceID In( Select Distinct(InvoiceID) From #SalesTaxComponent)
	And ID.TaxID = ITC.Tax_Code
	And ITC.Tax_Component_Code = TCD.TaxComponent_Code

	--Cursor to create dynamic column of TaxDescription
	Declare TaxCursor Cursor
	For Select Distinct(TaxID), T.Tax_Description,  Case When TaxCode <> 0 Then 1 
														When TaxCode2 <> 0 Then 2
														Else 0 End as LST
      From InvoiceAbstract IA, InvoiceDetail ID, Tax T, Customer C 
	Where IA.InvoiceID = ID.InvoiceID
	And IA.InvoiceDate between @FromDate and @ToDate     
	And (IA.Status & 128 )=0      	
	And IA.CustomerID = C.CustomerID
	And IA.SalesmanID In(Select SalesmanID From  #TempSalesman)
	And ID.TaxID = T.Tax_Code
	Order By TaxID
	
	Open TaxCursor
	
	Fetch Next From TaxCursor Into @TaxID, @TaxDesc, @LST
	
	While @@Fetch_Status = 0
	Begin

		Set @TempTaxDesc = @TaxDesc

		If @LST = 1 
			Set @TaxDesc = 'LST ' + @TaxDesc 
		Else If  @LST = 2
			Set @TaxDesc = 'CST ' + @TaxDesc 
		Else  
			Set @TaxDesc = ''

		If @TaxDesc <> ''
		Begin
			Set @Str = 'Alter Table #TmpAbstract Add [' + @TaxDesc + '(%c)] Decimal(18,6) Null'
			Exec sp_executesql @Str
			
			If @LST = 1 
				Set @Str = 'Update #TmpAbstract Set [' + @TaxDesc + '(%c)]  =  #TempTaxValue.ST From #TempTaxValue  Where #TmpAbstract.InvID = #TempTaxValue.InvoiceID  And ' +
						'TaxID = ' + Cast(@TaxID as varchar) 
			Else If @LST = 2
				Set @Str = 'Update #TmpAbstract Set [' + @TaxDesc + '(%c)]  =  #TempTaxValue.CST From #TempTaxValue  Where #TmpAbstract.InvID = #TempTaxValue.InvoiceID  And ' +
					'TaxID = ' + Cast(@TaxID as varchar) 

			Exec sp_executesql @Str			
	
			--Cursor to create dynamic column of TaxComponent Description		
			Declare TaxComCursor Cursor
			For 	Select Distinct (Select Case When Sum(STPayable) <> 0 Then 1 When Sum(CSTPayable) <> 0 Then 2 Else 0  End  From InvoiceDetail Where InvoiceID = ITC.InvoiceID And Product_Code = ITC.Product_Code ), TaxComponent_Desc, TCD.TaxComponent_Code
			From TaxComponentDetail TCD, InvoiceTaxComponents ITC
			Where ITC.InvoiceID In(Select InvoiceID From #SalesTaxComponent)
			And ITC.Tax_Code = @TaxID
			And TCD.TaxComponent_Code = ITC.Tax_Component_Code
			Order By  TCD.TaxComponent_Code			

			Open TaxComCursor
		
			Fetch Next From TaxComCursor Into @Flag, @TaxCompDesc, @TaxCompCode
			While @@Fetch_Status = 0
			Begin
				If @TaxCompDesc <> '' And @Flag = @LST
				Begin
					If @Flag = 1
						Set @Title = 'LST ' 
					Else if @Flag = 2
						Set @Title = 'CST ' 
					Else
						Set @Title = ''	
					
					If @Title <> ''
					Begin
						Set @Str = 'Alter Table #TmpAbstract Add [' + @Title +  Rtrim(@TaxCompDesc) + '_Of_' + @TempTaxDesc + '(%c)] Decimal(18,6) Null'
						Exec sp_executesql @Str
	
						Set @Str = 'Update #TmpAbstract Set ['	+  @Title + Rtrim(@TaxCompDesc) + '_Of_' + @TempTaxDesc  + '(%c)]  =  #TempTaxCompValue.TaxCompValue From #TempTaxCompValue, #TmpAbstract  ' +
						'Where #TmpAbstract.InvID = #TempTaxCompValue.InvoiceID  And TaxID = ' + Cast(@TaxID as varchar) +  ' And #TempTaxCompValue.TaxComponent_Code = ' +
						Cast(@TaxCompCode as varchar)  + ' And #TempTaxCompValue.LST = ' + Cast(@Flag as Varchar)

						Exec sp_executesql @Str			

					End
				End
			Fetch Next From TaxComCursor Into @Flag, @TaxCompDesc, @TaxCompCode
			End
			Close TaxComCursor
			Deallocate TaxComCursor
		End
	Fetch Next From TaxCursor Into @TaxID, @TaxDesc, @LST
	End
	
	Close TaxCursor
	Deallocate TaxCursor

	Drop Table #TmpTax
	Drop Table #SalesTaxComponent
	Drop Table #TempTaxValue
	Drop Table #TempSalesman
	Drop Table #TempTaxCompValue
End	

Select * From #TmpAbstract 

Drop Table #TmpAbstract
Drop Table #tmpCustOutStanding
Drop Table #TmpInvType
Drop Table #TmpPaymode
Drop Table #TmpPayMode2

End



