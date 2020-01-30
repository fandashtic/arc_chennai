CREATE Procedure spr_list_Sales_VAT_Report_ITC
(
@From_Date DateTime,
@To_Date DateTime,
@CustomerName nVarchar(4000),
@CustomerType nVarchar(50),
@TaxCompBrkUp nVARCHAR(10),
@TaxType nVARCHAR(100)
)
AS        

Declare @Inv_Pre nvarchar(50)
Declare @STO_Pre nvarchar(50)
Declare @LST_Incr Integer
Declare @TaxPerc Decimal(18,6)
Declare @AlterSQL nvarchar(4000)
Declare @UpdateSQL nvarchar(4000)
Declare @SelectSQL nvarchar(4000)
Declare @Field_Str nvarchar(Max)
Declare @Field_Str1 nvarchar(Max)
Declare @Field_Str2 nvarchar(Max)
Declare @Field_Str3 nvarchar(Max), @Field_Str4 nvarchar(Max)
Declare @DocType Integer
Declare @DocID Integer
Declare @SalesVal Decimal(18,6)
Declare @TaxVal Decimal(18,6)
Declare @TaxPer Decimal(18,6)
Declare @PerLevel nvarchar(255)


DECLARE @Delimiter as Char(1)        
SET @Delimiter=Char(15)   

Declare @DocumentID nvarchar(50)
Declare @Tax_Code int
Declare @isColExist int
Declare @TaxPercentage Decimal(18,6)
Declare @Tax_Description nvarchar(510)
Declare @Tax_Comp_Desc nvarchar(510)
Declare @Tax_Comp_Code int

Declare @SalesColName nvarchar(510)
Declare @TaxColName nvarchar(510)
Declare @SalesColName_Comp nvarchar(1000)
Declare @TaxColName_Comp nvarchar(1000)

Declare @ColType nvarchar(10)
Declare @SQL nvarchar(4000)
Declare @LTPrefix nvarchar(25)
Declare @CTPrefix nvarchar(25)
Declare @OutstationSelection nvarchar(4000)
Declare @STOSelection nvarchar(4000), @STOSelection_CST nvarchar(4000)
Declare @InvSelection nvarchar(4000)
Declare @RetailInvSelection nvarchar(4000)
Declare @LST_Flag int

Declare @TaxID as Int
Declare @TaxHead nVarchar(1000)
Declare @TaxCompHead nVarchar(1000)
Declare @PKID nvarchar(40), @Saletaxtype nvarchar(40)
set @LTPrefix = 'LST'
set @CTPrefix = 'CST'
--declare @temp datetime
Set DATEFormat DMY 
--set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)
--if(@From_Date > @temp )
--begin
--select 0,'This report cannot be generated for GST period' as Reason
--goto GSTOut
-- end               
                 
--if(@To_Date > @temp )
--begin
--set @To_Date  = @temp 
----goto GSTOut
--end                 

create table #TaxLog(Tax_Code int, ColType Nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)
      
Create Table #TaxType -- to filter taxtype 
(    
[TaxTypeName] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS
)
If @TaxType = N'%' or @TaxType = N'ALL'
    Insert Into #TaxType select TaxType from tbl_mERP_Taxtype 
ELSE
    Insert Into #TaxType select TaxType from tbl_mERP_Taxtype Where TaxType
        In ( Select * from dbo.sp_SplitIn2Rows(@TaxType, @Delimiter))

Create Table #Customer (CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
Create Table #WareHouse (WareHouseID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
  
IF @CustomerType = N'TIN Customers'   
Begin  
 Insert into #Customer select CustomerID from customer where Len(TIN_Number) > 0   
 Insert into #WareHouse select WareHouseID from WareHouse where Len(TIN_Number) > 0   
End  
Else IF @CustomerType = N'Non TIN Customers'   
Begin  
 Insert into #Customer select CustomerID from customer where Len(TIN_Number) = 0  
 Insert into #WareHouse select WareHouseID from WareHouse where Len(TIN_Number) = 0   
End  
Else  
Begin  
 Insert into #Customer select CustomerID from customer  
 Insert into #WareHouse select WareHouseID from WareHouse  
End  

--Filter the customer
If @CustomerName <> '%'     
   Delete from #Customer where customerID not in 
   (
       select CustomerID from Customer 
       where Company_Name in (Select * From DBO.sp_SplitIn2Rows(@CustomerName,@Delimiter))  
   )

--Filter the customer
If @CustomerName <> '%'     
   Delete from #WareHouse where WareHouseID not in 
   (
       select WareHouseID from WareHouse 
       where WareHouse_Name in (Select * From DBO.sp_SplitIn2Rows(@CustomerName,@Delimiter))  
   )


-------------------------- Prefix for Invoice and STO -------------------------------------      
SELECT @Inv_Pre = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'      
SELECT @STO_Pre = Prefix FROM VoucherPrefix WHERE TranID = N'STOCK TRANSFER OUT'      
      
--Temp Table #SalesVAT used to store DocumentID, Date, NetValue etc from Invoices, STO       
Create Table #SalesVAT (DocType nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS, TempDocID Integer, DocuDate DateTime, DocuID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, DocRef nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, Cust_Name nvarchar(
255) COLLATE SQL_Latin1_General_CP1_CI_AS, NetValue Decimal(18,6), [TIN Number] nVarchar(50),[Discount Value] Decimal(18,6),[Credit Note Adjusted Amount] Decimal(18,6),[F11 Adjustment] Decimal(18,6),
PrimaryKeyID nvarchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS, PANNumber nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert into #SalesVAT (DocType, TempDocID, DocuDate ,DocuID , DocRef,  Cust_Name, NetValue, [TIN Number],[Discount Value],[Credit Note Adjusted Amount],[F11 Adjustment], PrimaryKeyID, PANNumber)       
Select N'I', DocumentID, InvoiceAbstract.InvoiceDate, @Inv_Pre + Cast(DocumentID as nvarchar), DocReference, Customer.Company_Name, InvoiceAbstract.NetValue, Customer.TIN_Number,
IsNull(DiscountValue,0)+IsNull(AddlDiscountValue,0)+IsNull(ProductDiscount,0)+IsNull(SchemeDiscountAmount,0),IsNull(AdjustedAmount,0),IsNull(AdjustmentValue,0), 'I' + convert(varchar(40), InvoiceAbstract.invoiceid)
, dbo.Fn_Get_PANNumber(InvoiceAbstract.InvoiceID, 'INVOICE', 'CUSTOMER')
From InvoiceAbstract, Customer      
Where InvoiceAbstract.CustomerID = Customer.CustomerID And      
Customer.CustomerID In (Select CustomerID From #Customer) And  
InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
And InvoiceType in (1,3)      
And (isnull(Status, 0) & 192) = 0      
Union      
Select N'S', DocumentID, STOA.DocumentDate, @STO_Pre + Cast(DocumentID as nvarchar),
 N'', WareHouse_Name, sum(STOD.amount) as Netvalue, WareHouse.TIN_Number,0,0,0,  
'S' + convert(varchar(40), STOA.Docserial) primarykeyId , '' PANNumber
From StockTransferOutAbstract STOA Join StockTransferOutDetail STOD on STOA.DocSerial = STOD.DocSerial 
Join WareHouse on STOA.WareHouseID = WareHouse.WareHouseID
Join Batch_Products BP on STOD.Batch_code = BP.Batch_code
Join #TaxType tmp on Case when BP.[TaxType] = 2 then 'CST' Else 'LST' End = tmp.[TaxTypeName]
Where WareHouse.WareHouseID In (Select WareHouseID From #WareHouse) 
And (isnull(STOA.Status, 0) & 192) = 0 And STOA.DocumentDate Between @From_Date and @To_Date 
group by DocumentID, STOA.DocumentDate, WareHouse_Name, WareHouse.TIN_Number,
'S' + convert(varchar(40), STOA.Docserial)  

Union      
Select N'R', DocumentID, InvoiceAbstract.InvoiceDate, @Inv_Pre + Cast(DocumentID as nvarchar), DocReference, Customer.Company_Name,InvoiceAbstract.NetValue, Customer.TIN_Number,
IsNull(DiscountValue,0)+IsNull(AddlDiscountValue,0)+IsNull(ProductDiscount,0)+IsNull(SchemeDiscountAmount,0),IsNull(AdjustedAmount,0),IsNull(AdjustmentValue,0), 'R' + convert(varchar(40), InvoiceAbstract.invoiceid)
, dbo.Fn_Get_PANNumber(InvoiceAbstract.InvoiceID, 'INVOICE', 'CUSTOMER')
From InvoiceAbstract, Customer      
Where InvoiceAbstract.CustomerID = Customer.CustomerID And      
Customer.CustomerID In (Select CustomerID From #Customer) And  
InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
And InvoiceType = 2      
And (isnull(Status, 0) & 192) = 0      
Union      
Select N'R', DocumentID, InvoiceAbstract.InvoiceDate, @Inv_Pre + Cast(DocumentID as nvarchar), DocReference, Customer.Company_Name, 0 - InvoiceAbstract.NetValue, Customer.TIN_Number,
IsNull(DiscountValue,0)+IsNull(AddlDiscountValue,0)+IsNull(ProductDiscount,0)+IsNull(SchemeDiscountAmount,0),IsNull(AdjustedAmount,0),IsNull(AdjustmentValue,0), 'R' + convert(varchar(40), InvoiceAbstract.invoiceid)
--, dbo.Fn_Get_PANNumber(InvoiceAbstract.InvoiceID, 'INVOICE', 'CUSTOMER')
,'' PANNumber
From InvoiceAbstract, Customer      
Where InvoiceAbstract.CustomerID = Customer.CustomerID And      
Customer.CustomerID In (Select CustomerID From #Customer) And  
InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
And InvoiceType in (5, 6)      
And (isnull(Status, 0) & 192) = 0      
Union  
Select N'I', DocumentID, InvoiceAbstract.InvoiceDate, @Inv_Pre + Cast(DocumentID as nvarchar), DocReference, Customer.Company_Name, 0 - InvoiceAbstract.NetValue, Customer.TIN_Number,
IsNull(DiscountValue,0)+IsNull(AddlDiscountValue,0)+IsNull(ProductDiscount,0)+IsNull(SchemeDiscountAmount,0),IsNull(AdjustedAmount,0),IsNull(AdjustmentValue,0), 'I' + convert(varchar(40), InvoiceAbstract.invoiceid)
--, dbo.Fn_Get_PANNumber(InvoiceAbstract.InvoiceID, 'INVOICE', 'CUSTOMER')
,'' PANNumber
From InvoiceAbstract, Customer      
Where InvoiceAbstract.CustomerID = Customer.CustomerID And      
Customer.CustomerID In (Select CustomerID From #Customer) And  
InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
And InvoiceType In (4)      
And (isnull(Status, 0) & 192) = 0      

-- get all the Sales for the given taxtype filter
select primarykeyId, [taxtype], [taxtypename] 
Into #InvoiceTaxType from (
    select primarykeyId, ( Case when cstpayable > 0 then 'CST' Else 'LST' End) [taxtype] 
    from (
        select tmp.primarykeyId, max(Id.stpayable) stpayable, max(Id.cstpayable) cstpayable
        from #SalesVAT tmp Join InvoiceDetail Id on tmp.primarykeyId = tmp.Doctype + convert(varchar(40), Id.InvoiceId) and DocType In ( 'I' , 'R')
        group by tmp.primarykeyId ) tmp 
    )Idtmp 
Join #TaxType tmp on Idtmp.[TaxType] = tmp.[TaxTypeName]

Delete from #SalesVAT 
from #SalesVAT tmpvat Left outer Join #InvoiceTaxType tmp on tmpvat.primarykeyId = tmp.primarykeyId 
where tmp.primarykeyId Is Null and DocType = 'I'


if @TaxCompBrkUp <> 'Yes'
Begin      

select * into #tmpInvoiceDetailOLD from
(
     select InvoiceDetail.*, 
             case 
                 when Customer.Locality = 1 then 
                 case when isnull(InvoiceDetail.CSTPayable,0) = 0 then 1 else 2 End
                 when Customer.Locality = 2 then 
                 case when isnull(InvoiceDetail.STPayable,0) = 0 then 2 else 1 End     
             End as InvLocality
      from InvoiceAbstract, InvoiceDetail, Customer
      where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
            And InvoiceAbstract.CustomerID = Customer.CustomerID 
            And (isnull(InvoiceAbstract.Status, 0) & 128) = 0
            And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
) as tmp


------------------Cursor used to stored both the CST and LST Percentage -------------------   
Declare LST_Tax Cursor For
Select Tax_Code From Tax Where Percentage <> 0 Order By Percentage

--Select Distinct Cast(Percentage as nvarchar) from Tax      
--Where Percentage <> 0 --And Active = 1    
--Union      
--Select Distinct Cast(CST_Percentage as nvarchar) from Tax        
--Where CST_Percentage <> 0  --And Active = 1      
--union
--select Distinct TaxCode from #tmpInvoiceDetailOLD where Taxcode <> 0
--Union
--Select Distinct Cast(StockTransferOutDetail.TaxSuffered as nvarchar)
--From  StockTransferOutDetail, StockTransferOutAbstract, Items      
--Where StockTransferOutDetail.DocSerial = StockTransferOutAbstract.DocSerial      
--      And StockTransferOutDetail.product_Code = Items.Product_Code      
--      And (isnull(Status, 0) & 128) = 0      
--      and StockTransferOutAbstract.DocumentDate Between @From_Date and @To_Date
      
Declare CST_Tax Cursor For 
Select Tax_Code From Tax Where CST_Percentage <> 0 Order By CST_Percentage

--Select Distinct Cast(Percentage as nvarchar) from Tax        
--Where Percentage <> 0 --And Active = 1      
--Union      
--Select Distinct Cast(CST_Percentage as nvarchar) from Tax      
--Where CST_Percentage <> 0  --And Active = 1    
--union
--select Distinct TaxCode2 from #tmpInvoiceDetailOLD where Taxcode2 <> 0
------------------------ Adding CST as Column for Outstation Invoices------------------------      
     Set @Field_Str = N''      
     Open CST_Tax       
     Fetch from CST_Tax Into @TaxID      
--       SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Outstation (Exempt) Sales Value' + N'] Decimal(18,6) null'                     
--       Set @Field_Str = N'[Outstation (Exempt) Sales Value], '      
--       EXEC sp_executesql @AlterSQL                    
           
      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Outstation Sales (0%)_Value' + N'] Decimal(18,6) null'                     
      Set @Field_Str = @Field_Str + N'[Outstation Sales (0%)_Value] as [Outstation Exempted Sales Value], '      
      EXEC sp_executesql @AlterSQL       

     WHILE @@FETCH_STATUS = 0                    
     BEGIN      
      Set @TaxHead = dbo.mERP_fn_GetTaxColFormat(@TaxID, 0) 
      
      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Outstation Sales (' + @TaxHead + N')_Value' + N'] Decimal(18,6) null'            
      Set @Field_Str = @Field_Str + N'[Outstation Sales (' + @TaxHead + N')_Value], '      
      EXEC sp_executesql @AlterSQL                    
            
      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Outstation Sales (' + @TaxHead + N')_Tax' + N'] Decimal(18,6) null'                     
      Set @Field_Str = @Field_Str + N'[Outstation Sales (' + @TaxHead + N')_Tax], '      
      EXEC sp_executesql @AlterSQL      
             
           
     FETCH NEXT FROM CST_Tax INTO @TaxID         
     END      
     Close CST_Tax      
     ---------------------------Adding LST as Column for STO-------------------------------------      
     Set @Field_Str1 = N''          
     Open LST_Tax       
     Fetch from LST_Tax Into @TaxID      
--      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (Exempt) Sales Value' + N'] Decimal(18,6) null'                     
--      Set @Field_Str1 = @Field_Str1 + N'[STO (Exempt) Sales Value], '      
--      EXEC sp_executesql @AlterSQL                    
           
     SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (0%)_Value' + N'] Decimal(18,6) null'                     
     Set @Field_Str1 = @Field_Str1 + N'[STO (0%)_Value] as [STO Exempted Sales Value], '      
     EXEC sp_executesql @AlterSQL                               

     WHILE @@FETCH_STATUS = 0                    
     BEGIN
	  Set @TaxHead = dbo.mERP_fn_GetTaxColFormat(@TaxID, 0)
      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (' + @TaxHead + N')_Value' + N'] Decimal(18,6) null'                     
      Set @Field_Str1 = @Field_Str1 + N'[STO (' + @TaxHead + N')_Value], '      
      EXEC sp_executesql @AlterSQL                    
           
      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (' + @TaxHead + N')_Tax' + N'] Decimal(18,6) null'                     
      Set @Field_Str1 = @Field_Str1 + N'[STO (' + @TaxHead + N')_Tax], '      
      EXEC sp_executesql @AlterSQL                  
            
                 
     FETCH NEXT FROM LST_Tax INTO @TaxID
     End      
     Close LST_Tax      
           
     ---------------------------Adding LST as Column for Invoices---------------------------------      
     Set @Field_Str2 = N''            
     Open LST_Tax       
     Fetch from LST_Tax Into @TaxID
--      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Invoice (Exempt) Sales Value' + N'] Decimal(18,6) null'                     
--      Set @Field_Str2 = @Field_Str2 + N'[Invoice (Exempt) Sales Value], '      
--      EXEC sp_executesql @AlterSQL                    
           
     SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Sales (0%)_Value' + N'] Decimal(18,6) null'                     
     Set @Field_Str2 = @Field_Str2 + N'[Sales (0%)_Value] as [Invoice Exempted Sales Value], '       
     EXEC sp_executesql @AlterSQL                               

     WHILE @@FETCH_STATUS = 0                    
     BEGIN      
	  Set @TaxHead = dbo.mERP_fn_GetTaxColFormat(@TaxID, 0)

      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Sales (' + @TaxHead + N')_Value' + N'] Decimal(18,6) null'                     
      Set @Field_Str2 = @Field_Str2 + N'[Sales (' + @TaxHead + N')_Value], '      
      EXEC sp_executesql @AlterSQL                    
           
      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Sales (' + @TaxHead + N')_Tax' + N'] Decimal(18,6) null'                     
      Set @Field_Str2 = @Field_Str2 + N'[Sales (' + @TaxHead + N')_Tax], '      
      EXEC sp_executesql @AlterSQL                  
            
                 
     FETCH NEXT FROM LST_Tax INTO @TaxID
     End      
     Close LST_Tax    
           
     ------------------------Adding LST as Column for Retail Invoices----------------------------      
     Set @Field_Str3 = N''                
     Open LST_Tax       
     Fetch from LST_Tax Into @TaxID      
--      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Retail (Exempt) Sales Value' + N'] Decimal(18,6) null'                     
--      Set @Field_Str3 = @Field_Str3 + N'[Retail (Exempt) Sales Value], '       
--      EXEC sp_executesql @AlterSQL                    
           
     SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Retail (0%)_Value' + N'] Decimal(18,6) null'                     
     Set @Field_Str3 = @Field_Str3 + N'[Retail (0%)_Value] as [Retail Exempted Sales Value], '       
     EXEC sp_executesql @AlterSQL             

     WHILE @@FETCH_STATUS = 0                    
     BEGIN      
	  Set @TaxHead = dbo.mERP_fn_GetTaxColFormat(@TaxID, 0)

      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Retail (' + @TaxHead + N')_Value' + N'] Decimal(18,6) null'                   
      Set @Field_Str3 = @Field_Str3 + N'[Retail (' + @TaxHead + N')_Value], '       
      EXEC sp_executesql @AlterSQL                    
           
      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Retail (' + @TaxHead + N')_Tax' + N'] Decimal(18,6) null'                     
      Set @Field_Str3 = @Field_Str3 + N'[Retail (' + @TaxHead + N')_Tax],'      
      EXEC sp_executesql @AlterSQL                  
            

     FETCH NEXT FROM LST_Tax INTO @TaxID
     End      
     Close LST_Tax      

     ---------------------------Adding CST as Column for STO-------------------------------------      
     Set @Field_Str4 = N''
     Open CST_Tax       
     Fetch from CST_Tax Into @TaxID      
--      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (Exempt) Sales Value' + N'] Decimal(18,6) null'                     
--      Set @Field_Str1 = @Field_Str1 + N'[STO (Exempt) Sales Value], '      
--      EXEC sp_executesql @AlterSQL                    
           
--     SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (0%)_Value' + N'] Decimal(18,6) null'                     
--     Set @Field_Str1 = @Field_Str1 + N'[STO (0%)_Value] as [STO Exempted Sales Value], '      
--     EXEC sp_executesql @AlterSQL                               
     
     WHILE @@FETCH_STATUS = 0                    
     BEGIN
	  Set @TaxHead = dbo.mERP_fn_GetTaxColFormat(@TaxID, 0)
      print convert(varchar, @TaxID) +  ' @TaxID ' + @TaxHead 
      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO_CST (' + @TaxHead + N')_Value' + N'] Decimal(18,6) null'                     
      Set @Field_Str4 = @Field_Str4 + N'[STO_CST (' + @TaxHead + N')_Value], '      
      EXEC sp_executesql @AlterSQL                    
           
      SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO_CST (' + @TaxHead + N')_Tax' + N'] Decimal(18,6) null'                     
    Set @Field_Str4 = @Field_Str4 + N'[STO_CST (' + @TaxHead + N')_Tax], '      
      EXEC sp_executesql @AlterSQL                  
            
     FETCH NEXT FROM CST_Tax INTO @TaxID
     End
     --Close CST_Tax
           
     -- Fields Concadinated for select stat.      
     Set @Field_Str = Substring(@Field_Str, 1, Len(@Field_Str) - 1)       
     IF len(@Field_Str)>0  
      Set @Field_Str = N','+@Field_Str  
     Set @Field_Str1 = Substring(@Field_Str1, 1, Len(@Field_Str1) - 1)       
       
     IF Len(@Field_Str1)>0  
      Set @Field_Str1 = N','+@Field_Str1  
       
     Set @Field_Str2= Substring(@Field_Str2, 1, Len(@Field_Str2) - 1)       
     IF Len(@Field_Str2)>0  
      Set @Field_Str2= N','+@Field_Str2  
       
     Set @Field_Str3 = Substring(@Field_Str3, 1, Len(@Field_Str3) - 1)       
     IF Len(@Field_Str3)>0  
      Set @Field_Str3=N','+@Field_Str3  

     IF Len(@Field_Str4)>0
     Begin   
        Set @Field_Str4 = Substring(@Field_Str4, 1, Len(@Field_Str4) - 1)
        Set @Field_Str4=N','+@Field_Str4
     End   
     -- Cursor for Storing Sales Value and VAT for Invoices (Outstation Customers), STO, Invoices, Retail Invoices      

    Select DocType, DocuID, SalesValue, SalesTaxValue, TaxCode, 
    ExemptType, TaxID, PrimaryKeyID, taxtype
    into #tmpNoCompWiseData
    from
    (
     ------------------------ Invoices for Outstation Customers-------------------------------      
     Select 1 as DocType, DocumentID as DocuID, Sum(Amount) - Sum(CSTPayable) as SalesValue, Sum(CSTPayable) as SalesTaxValue, InvoiceDetail.TaxCode2 as TaxCode,
     Cast((Case When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax = 0 Then N'0%'
     When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax <> 0 Then N'0%'
     Else Cast(Cast(InvoiceDetail.TaxCode2 as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar) as ExemptType,
	 InvoiceDetail.TaxID as TaxID, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId) as PrimaryKeyID, N'' as taxtype
     from InvoiceAbstract
	 Inner Join  #tmpInvoiceDetailOLD as InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
	 Left Outer Join  Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode2 = Tax.Percentage
	 Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID
	 Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code
     Where Customer.CustomerID In (Select CustomerID From #Customer)
     And InvoiceType in (1,3)
--      And Customer.Locality = 2
     And InvoiceDetail.InvLocality = 2
     And (isnull(Status, 0) & 128) = 0
     And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
     Group By DocumentID, InvoiceDetail.TaxCode2, Items.Sale_Tax, InvoiceDetail.TaxID, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId)
     union  all    
     -------------------------------------------- STO-----------------------------------------       
     Select 2 as DocType, DocumentID as DocuID, Sum(Amount) as SalesValue, 
     Sum(StockTransferOutDetail.TaxAmount) as SalesTaxValue, StockTransferOutDetail.TaxSuffered as TaxCode,
     Case
     When StockTransferOutDetail.TaxSuffered = 0 and Items.Sale_Tax <> 0 Then N'0%'
     When StockTransferOutDetail.TaxSuffered = 0 and Items.Sale_Tax = 0 Then N'0%'
     Else Cast( Cast(StockTransferOutDetail.TaxSuffered as Decimal(18,6)) as nvarchar) + N'%' End as ExemptType,
	 tax.Tax_Code as TaxID, 'S' + Convert(varchar(40), StockTransferOutAbstract.Docserial) as PrimaryKeyID,
     Case when batch_products.taxtype = 2 then 'SO' Else 'SL' End as taxtype
     From  StockTransferOutDetail, StockTransferOutAbstract, Items, 
      (Select min(Tax_Code) Tax_Code, Percentage, 1 taxtype From Tax group by Percentage
       union Select min(Tax_Code) Tax_Code, cst_Percentage Percentage, 2 taxtype From Tax group by cst_Percentage) tax,
     batch_products, #TaxType tmp 
     Where StockTransferOutDetail.DocSerial = StockTransferOutAbstract.DocSerial 
     And StockTransferOutDetail.batch_code = batch_products.batch_code        
     And Case when batch_products.taxtype = 2 then 2 else 1 end = tax.taxtype 
     And tax.Percentage = StockTransferOutDetail.TaxSuffered
     And StockTransferOutDetail.product_Code = Items.Product_Code      
     And (isnull(Status, 0) & 128) = 0      
     and StockTransferOutAbstract.DocumentDate Between @From_Date and @To_Date and   
     Case when batch_products.[TaxType] = 2 then 'CST' Else 'LST' End = tmp.[TaxTypeName]
     Group by StockTransferOutDetail.TaxSuffered, DocumentID, Items.Sale_Tax, tax.Tax_Code, 
     'S' + Convert(varchar(40), StockTransferOutAbstract.Docserial),
     Case when batch_products.taxtype = 2 then 'SO' Else 'SL' End 

     Union  all    
     ------------------------------------------ Invoices----------------------------------------      
     Select 3 as DocType, DocumentID as DocuID, Sum(Amount) - Sum(STPayable) as SalesValue, Sum(STPayable) as SalesTaxValue, InvoiceDetail.TaxCode as TaxCode,
     Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'0%'       
     When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'      
     Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar) as ExemptType,
	 InvoiceDetail.TaxID as TaxId, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId) as PrimaryKeyID, N'' as taxtype
     from InvoiceAbstract
	 Inner Join  #tmpInvoiceDetailOLD as InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
	 Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage              
	 Inner Join  Customer On invoiceAbstract.CustomerID = Customer.CustomerID  
	 Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code      
     Where Customer.CustomerID In (Select CustomerID From #Customer)      
     And InvoiceType in (1,3)      
--      And Customer.Locality = 1      
     And InvoiceDetail.InvLocality = 1
     And (isnull(Status, 0) & 128) = 0      
     And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
     Group By DocumentID, InvoiceDetail.TaxCode, Items.Sale_Tax, InvoiceDetail.TaxID, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId)
     Union  all    
     ------------------------------------- Retail Invoices--------------------------------------      
     Select 4 as DocType, DocumentID as DocuID, Sum(Amount) - Sum(STPayable) as SalesValue, Sum(STPayable) as SalesTaxValue, InvoiceDetail.TaxCode as TaxCode,
     Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'0%'       
     When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'      
     Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar) as ExemptType,
	 InvoiceDetail.TaxID as TaxId, 'R' + Convert(varchar(40), InvoiceAbstract.InvoiceId) as PrimaryKeyID, N'' as taxtype
     from InvoiceAbstract
	 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
	 Left Outer Join  Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage      
	 Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID      
	 Inner Join  Items On InvoiceDetail.product_Code = Items.Product_Code      
     Where Customer.CustomerID In (Select CustomerID From #Customer)  
     And InvoiceType in (2)  
     And (isnull(Status, 0) & 128) = 0      
     And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
     Group By DocumentID, InvoiceDetail.TaxCode, Items.Sale_Tax, InvoiceDetail.TaxID, 'R' + Convert(varchar(40), InvoiceAbstract.InvoiceId)
     Union  all    
     ------------------Sales Return for Retail Invoices-----------------------------------------  
     Select 7 as DocType, DocumentID as DocuID, 0 - (Sum(Amount) - Sum(STPayable)) as SalesValue, 0 - Sum(STPayable) as SalesTaxValue, InvoiceDetail.TaxCode as TaxCode,
     Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'0%'       
     When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'      
     Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar) as ExemptType,
	 InvoiceDetail.TaxID as TaxId, 'R' + Convert(varchar(40), InvoiceAbstract.InvoiceId) as PrimaryKeyID, N'' as taxtype
     from InvoiceAbstract
	 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
	 Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage            
	 Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID      
	 Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code             
     Where Customer.CustomerID In (Select CustomerID From #Customer)  
     And InvoiceType in (5, 6)  
     And (isnull(Status, 0) & 128) = 0      
     And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
     Group By DocumentID, InvoiceDetail.TaxCode, Items.Sale_Tax, InvoiceDetail.TaxID, 'R' + Convert(varchar(40), InvoiceAbstract.InvoiceId)
     Union  all    
     ------------------ Sales Return for invoices (Local Customers) ---------------------------      
     Select 5 as DocType, DocumentID as DocuID, 0 - (sum(Amount) - sum(STPayable)) as SalesValue, 0 - sum(STPayable) as SalesTaxValue, InvoiceDetail.TaxCode as TaxCode,
     Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'0%'       
     When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'       
     Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar) as ExemptType,
	 InvoiceDetail.TaxID as TaxId, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId) as PrimaryKeyID, N'' as taxtype
     from InvoiceAbstract
	 Inner Join #tmpInvoiceDetailOLD as InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
	 Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage             
	 Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID  
	 Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code      
     Where 
     --And Customer.CustomerID In (Select CustomerID From #Customer)      
     InvoiceType in (4)      
--      And Customer.Locality = 1      
     And InvoiceDetail.InvLocality = 1
     And (isnull(Status, 0) & 128) = 0      
     And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
     Group By DocumentID, InvoiceDetail.TaxCode, Items.Sale_Tax, InvoiceDetail.TaxID, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId)
     Union  all    
     ----------------- Sales Return for invoices (Outstation Customers)-------------------------      
     Select 6 as DocType, DocumentID as DocuID, 0 - (sum(Amount) - sum(CSTPayable)) as SalesValue, 0 - sum(CSTPayable) as SalesTaxValue, InvoiceDetail.TaxCode2 as TaxCode,
     Cast((Case When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax = 0 Then N'0%'
     When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax <> 0 Then N'0%'
     Else Cast(Cast(InvoiceDetail.TaxCode2 as Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar) as ExemptType,
	 InvoiceDetail.TaxID as TaxId, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId) as PrimaryKeyID, N'' as taxtype
     from InvoiceAbstract
	 Inner Join #tmpInvoiceDetailOLD as InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID        
	 Left Outer Join  Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode2 = Tax.CST_Percentage        
	 Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID  
	 Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code        
     Where Customer.CustomerID In (Select CustomerID From #Customer)        
    And InvoiceType in (4)        
--      And Customer.Locality = 2        
     And InvoiceDetail.InvLocality = 2
     And (isnull(Status, 0) & 128) = 0        
     And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date        
     Group By DocumentID, InvoiceDetail.TaxCode2, Items.Sale_Tax, InvoiceDetail.TaxID, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId)
     ) tmp
--     order by PrimaryKeyID, TaxCode, SalesValue

    Delete from #tmpNoCompWiseData
    from #tmpNoCompWiseData tmpvat Left outer Join #InvoiceTaxType tmp on tmpvat.primarykeyId = tmp.primarykeyId 
    where tmp.primarykeyId Is Null and tmpvat.DocType In ( 1, 3, 4, 5, 6, 7 )-- and tmp.DocType = 'I'

 

    Declare TaxVal cursor static for 
    Select DocType, DocuID, SalesValue, SalesTaxValue, TaxCode, ExemptType, TaxID, PrimaryKeyID, taxtype
    from #tmpNoCompWiseData order by PrimaryKeyID, TaxCode, SalesValue
    ------------------- Updating Sales Value and VAT for all Tax levels ------------------------      
    Open TaxVal
    Fetch From TaxVal Into @DocType, @DocID, @SalesVal, @TaxVal, @TaxPer, @PerLevel, @TaxID, @PKID, @Saletaxtype
    WHILE @@FETCH_STATUS = 0                    
    BEGIN      
        Set @TaxHead = dbo.mERP_fn_GetTaxColFormat(@TaxID, 0)

        IF @DocType = 1 Or @DocType = 6         
        Begin        
            if @PerLevel <> N'Exempt' and @PerLevel <> N'0%'
            begin
                SET @UpdateSQL = N'Update #SalesVAT Set [Outstation Sales (' + @TaxHead + N')_Value] = isnull([Outstation Sales (' + @TaxHead + N')_Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where PrimaryKeyID = '''+ Cast(@PKID as nvarchar)  +''' and DocType = ''I'''       
    --            if exists(select * from tempdb..syscolumns where name like '%Outstation (' + @PerLevel + N') Sales Value%')                 
                exec sp_executesql @UpdateSQL                   

                SET @UpdateSQL = N'Update #SalesVAT Set [Outstation Sales (' + @TaxHead + N')_Tax] = isnull([Outstation Sales (' + @TaxHead + N')_Tax],0) + ' + cast (@TaxVal as nvarchar) + N' Where PrimaryKeyID = '''+ Cast(@PKID as nvarchar)  +''' and DocType = ''I'''             
    --           if exists(select * from tempdb..syscolumns where name like '%Outstation (' + @PerLevel + N') VAT%') 
                exec sp_executesql @UpdateSQL                   
            end     
            else
            begin
                SET @UpdateSQL = N'Update #SalesVAT Set [' + N'Outstation Sales (0%)_Value' + N'] = '  
                SET @UpdateSQL = @UpdateSQL + N' ( select sum(SalesValue) from #tmpNoCompWiseData Where ExemptType = ''0%'' and PrimaryKeyID = '''+ Cast(@PKID as nvarchar) + ''' )' 
                Set @UpdateSQL = @UpdateSQL + N' where #SalesVAT.PrimaryKeyID = ''' + convert(varchar(40), @PKID)  + N''' and DocType = ''I'''  
                exec sp_executesql @UpdateSQL                   
            end 
        end    
        Else If @DocType = 2        
        Begin   
            if @PerLevel <> N'Exempt' and @PerLevel <> N'0%'         
            begin     
                if @Saletaxtype = N'SL'
                begin
                    SET @UpdateSQL = N'Update #SalesVAT Set [STO (' + @TaxHead + N')_Value] = isnull([STO (' + @TaxHead + N')_Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where PrimaryKeyID = '''+ Cast(@PKID as nvarchar)  +''' and DocType = ''S'''
        --            if exists(select * from tempdb..syscolumns where name like '%STO (' + @PerLevel + N') Sales Value%')        
                    exec sp_executesql @UpdateSQL                   
                     
                    SET @UpdateSQL = N'Update #SalesVAT Set [STO (' + @TaxHead + N')_Tax] = isnull([STO (' + @TaxHead + N')_Tax],0) + ' + cast (@TaxVal as nvarchar) + N' Where PrimaryKeyID =  '''+ Cast(@PKID as nvarchar)  + ''' and DocType = ''S'''
        --            if exists(select * from tempdb..syscolumns where name like '%STO (' + @PerLevel + N') VAT%') 
                    exec sp_executesql @UpdateSQL                   
                end
                else if @Saletaxtype = N'SO'
                begin
                    SET @UpdateSQL = N'Update #SalesVAT Set [STO_CST (' + @TaxHead + N')_Value] = isnull([STO_CST (' + @TaxHead + N')_Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where PrimaryKeyID = '''+ Cast(@PKID as nvarchar)  +''' and DocType = ''S'''
        --            if exists(select * from tempdb..syscolumns where name like '%STO (' + @PerLevel + N') Sales Value%')        
                    exec sp_executesql @UpdateSQL                   
                     
                    SET @UpdateSQL = N'Update #SalesVAT Set [STO_CST (' + @TaxHead + N')_Tax] = isnull([STO_CST (' + @TaxHead + N')_Tax],0) + ' + cast (@TaxVal as nvarchar) + N' Where PrimaryKeyID =  '''+ Cast(@PKID as nvarchar)  + ''' and DocType = ''S'''
        --            if exists(select * from tempdb..syscolumns where name like '%STO (' + @PerLevel + N') VAT%') 
                    exec sp_executesql @UpdateSQL                   
                end
            end   
            else
            begin
                SET @UpdateSQL = N'Update #SalesVAT Set [' + N'STO (0%)_Value' + N'] = '  
                SET @UpdateSQL = @UpdateSQL + N' ( select sum(SalesValue) from #tmpNoCompWiseData Where ExemptType = ''0%'' and PrimaryKeyID = '''+ Cast(@PKID as nvarchar) + ''' )' 
                Set @UpdateSQL = @UpdateSQL + N' where #SalesVAT.PrimaryKeyID = ''' + convert(varchar(40), @PKID)  + N''' and DocType = ''S'''  
                exec sp_executesql @UpdateSQL
            end        
        End         
        Else If @DocType = 3 or @DocType = 5
        Begin
            if @PerLevel <> N'Exempt' and @PerLevel <> N'0%'          
            begin
			 If exists (Select * from tempdb.information_schema.columns where table_name like '#SalesVAT%' and column_name like 'Sales (' + @TaxHead + N')_Value')
			 Begin
                SET @UpdateSQL = N'Update #SalesVAT Set [Sales (' + @TaxHead + N')_Value] = isnull([Sales (' + @TaxHead + N')_Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where PrimaryKeyID = '''+ Cast(@PKID as nvarchar)  +''' and DocType = ''I'''
    --            if exists(select * from tempdb..syscolumns where name like '%Invoice (' + @PerLevel + N') Sales Value%')        
                exec sp_executesql @UpdateSQL                   
                 
                SET @UpdateSQL = N'Update #SalesVAT Set [Sales (' + @TaxHead + N')_Tax] = isnull([sales (' + @TaxHead + N')_Tax],0) + ' + cast (@TaxVal as nvarchar) + N' Where PrimaryKeyID = '''+ Cast(@PKID as nvarchar)  +''' and DocType = ''I'''
    --            if exists(select * from tempdb..syscolumns where name like '%Invoice (' + @PerLevel + N') VAT%') 
                exec sp_executesql @UpdateSQL 
			 End
            end     
            else
            begin
                SET @UpdateSQL = N'Update #SalesVAT Set [' + N'Sales (0%)_Value' + N'] = '  
                SET @UpdateSQL = @UpdateSQL + N' ( select sum(SalesValue) from #tmpNoCompWiseData Where ExemptType = ''0%'' and PrimaryKeyID = '''+ Cast(@PKID as nvarchar) + ''' )' 
                Set @UpdateSQL = @UpdateSQL + N' where #SalesVAT.PrimaryKeyID = ''' + convert(varchar(40), @PKID)  + N''' and DocType = ''I'' '  
                exec sp_executesql @UpdateSQL
            end     
        End         
        Else If @DocType = 4 or @DocType = 7  
        Begin        
            if @PerLevel <> N'Exempt' and @PerLevel <> N'0%'         
            begin
                SET @UpdateSQL = N'Update #SalesVAT Set [Retail (' + @TaxHead + N')_Value] = isnull([Retail (' + @TaxHead + N')_Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where PrimaryKeyID = '''+ Cast(@PKID as nvarchar)  +''' and DocType = ''R'''
    --            if exists(select * from tempdb..syscolumns where name like '%Retail (' + @PerLevel + N') Sales Value%')            
                exec sp_executesql @UpdateSQL                              
        
                SET @UpdateSQL = N'Update #SalesVAT Set [Retail (' + @TaxHead + N')_Tax] = isnull([Retail (' + @TaxHead + N')_Tax],0) + ' + cast (@TaxVal as nvarchar) + N' Where PrimaryKeyID = '''+ Cast(@PKID as nvarchar)  +''' and DocType = ''R'''
    --            if exists(select * from tempdb..syscolumns where name like '%Retail (' + @PerLevel + N') VAT%') 
                exec sp_executesql @UpdateSQL                   
            end   
            else
            begin
                SET @UpdateSQL = N'Update #SalesVAT Set [' + N'Retail (0%)_Value' + N'] = '  
                SET @UpdateSQL = @UpdateSQL + N' ( select sum(SalesValue) from #tmpNoCompWiseData Where ExemptType = ''0%'' and PrimaryKeyID = '''+ Cast(@PKID as nvarchar) + ''' )' 
                Set @UpdateSQL = @UpdateSQL + N' where #SalesVAT.PrimaryKeyID = ''' + convert(varchar(40), @PKID)  + N''' and DocType = ''R'' '  
                exec sp_executesql @UpdateSQL
            end     
        End        
    Fetch Next From TaxVal Into @DocType, @DocID, @SalesVal, @TaxVal, @TaxPer, @PerLevel, @TaxID, @PKID, @Saletaxtype
    END       
    Close CST_Tax      
    DeAllocate CST_Tax      
    DeAllocate LST_Tax      
    Close TaxVal      
    DeAllocate TaxVal      

    exec (N'Select DocuDate, ''Document Date'' = DocuDate, ''Document ID '' = DocuID , ''Document Ref'' = DocRef, ''Customer/Branch'' = Cust_Name, [TIN Number], "PAN Number" = PANNumber,  NetValue,[Discount Value],[Credit Note Adjusted Amount],[F11 Adjustment]' + @Field_Str + @Field_Str1+@Field_Str4+@Field_Str2+@Field_Str3+ ' From  #SalesVAT Order by DocuDate,DocuID')      
    drop table #tmpInvoiceDetailOLD
End 
Else	--Split Up - Yes
Begin

select * into #tmpSTOTax
from
(
     Select Tax.Tax_Code, Tax.Percentage, TaxComponents.TaxComponent_Code,
            TaxComponents.Sp_Percentage as TaxCompPer, taxtype 
     from     
          (
              select min(Tax_Code) as Tax_Code, Percentage, 1 taxtype from Tax group by Percentage
              union
              select min(Tax_Code) as Tax_Code, cst_Percentage Percentage, 2 taxtype from Tax group by cst_Percentage
          ) Tax, TaxComponents
     where Tax.Tax_Code = TaxComponents.Tax_Code
           and TaxComponents.LST_Flag = Case when taxtype = 2 then 0 else 1 end 
) tmp

select * into #tmpInvoiceDetail from
(
      select InvoiceDetail.InvoiceID, 
             InvoiceDetail.InvLocality,
             isnull(InvoiceDetail.TaxID,0) as TaxID, 
             isnull(InvoiceDetail.product_Code,'') as product_Code, 
             isnull(InvoiceDetail.TaxCode2,0) as TaxCode2, 
             isnull(InvoiceDetail.TaxCode,0) as TaxCode, 
             isnull(InvoiceTaxComponents.Tax_Code,0) as Tax_Code, 
             isnull(InvoiceTaxComponents.Tax_Component_Code,0) as Tax_Component_Code, 
             max(isnull(InvoiceDetail.Amount,0)) as Amount, 
             max(isnull(InvoiceDetail.CSTPayable,0)) as CSTPayable, 
             max(isnull(InvoiceDetail.STPayable,0)) as STPayable, 
             Sum(isnull(InvoiceTaxComponents.Tax_Value,0)) as Tax_Value
      from 
          (
               select InvoiceDetail.InvoiceID, InvoiceDetail.TaxID, InvoiceDetail.product_Code, 
                      InvoiceDetail.TaxCode2, InvoiceDetail.TaxCode, 
                      case 
                          when Customer.Locality = 1 then 
                          case when sum(isnull(InvoiceDetail.CSTPayable,0)) = 0 then 1 else 2 End
                          when Customer.Locality = 2 then 
                          case when sum(isnull(InvoiceDetail.STPayable,0)) = 0 then 2 else 1 End     
                      End as InvLocality,
                      sum(isnull(InvoiceDetail.Amount,0)) as Amount ,
      sum(isnull(InvoiceDetail.CSTPayable,0)) as CSTPayable,
                      sum(isnull(InvoiceDetail.STPayable,0)) as STPayable
               from InvoiceAbstract, InvoiceDetail, Customer
               where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
                     And InvoiceAbstract.CustomerID = Customer.CustomerID 
                     And (isnull(InvoiceAbstract.Status, 0) & 128) = 0
                     And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
               group by InvoiceDetail.InvoiceID, InvoiceDetail.TaxID, InvoiceDetail.product_Code, 
                      InvoiceDetail.TaxCode2, InvoiceDetail.TaxCode, Customer.Locality --, 
                      -- InvoiceDetail.STPayable, InvoiceDetail.CSTPayable
          ) InvoiceDetail
		  Left Outer Join  InvoiceTaxComponents On InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID and InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code and InvoiceDetail.Product_Code = InvoiceTaxComponents.Product_Code
      where InvoiceTaxComponents.Tax_Value > 0
      group by InvoiceDetail.InvoiceID, 
               InvoiceDetail.InvLocality,
             isnull(InvoiceDetail.TaxID,0), 
             isnull(InvoiceDetail.product_Code,''), 
             isnull(InvoiceDetail.TaxCode2,0), 
             isnull(InvoiceDetail.TaxCode,0), 
             isnull(InvoiceTaxComponents.Tax_Code,0), 
             isnull(InvoiceTaxComponents.Tax_Component_Code,0)
) as tmp

Update #tmpInvoiceDetail Set Tax_Value=
CASE 
 When ISnull(TaxCode,0) <> 0 Then STPayable
 When ISnull(TaxCode2,0) <> 0 Then CSTPayable
END
 Where Tax_Component_code=0

--select * from #tmpInvoiceDetail where invoiceid=95
	
--      Fetch Next From TaxVal Into @DocType, @DocID, @SalesVal, @TaxVal, @TaxPer, @PerLevel      


Select DocType, ColType, DocuID, TaxID as Tax_Code, Tax_Component_Code , ExemptType, 
       sum(CompSalesTaxValue) as CompSalesTaxValue, sum(SalesValue) as SalesValue, PrimaryKeyID
into #tmpCompWiseData
from
     (
          ------------------------ Invoices for Outstation Customers-------------------------------      
          Select 1 as DocType, N'O' as ColType, @Inv_Pre + cast(DocumentID as nVarchar) as DocuID, InvoiceDetail.TaxID, InvoiceDetail.Tax_Component_Code , 
                Sum(Amount) - Sum(CSTPayable) as SalesValue, Sum(CSTPayable) as SalesTaxValue, 
                sum(InvoiceDetail.Tax_Value) as CompSalesTaxValue,
--                 Cast((Case When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax = 0 Then N'Exempt'
                Cast((Case When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax = 0 Then N'0%'
                When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax <> 0 Then N'0%'
                Else Cast(Cast(InvoiceDetail.TaxCode2 as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar) as ExemptType, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId) as PrimaryKeyID
          from InvoiceAbstract		  
		  Inner Join #tmpInvoiceDetail as InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
		  Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID		  
		  Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code
		  Right Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode2 = Tax.[Percentage]
          Where Customer.CustomerID In (Select CustomerID From #Customer)
          And InvoiceType in (1,3)
--           And Customer.Locality = 2
          And InvoiceDetail.InvLocality = 2
          And (isnull(Status, 0) & 128) = 0
          And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
          Group By DocumentID, InvoiceDetail.TaxID, InvoiceDetail.Tax_Component_Code, 
                   InvoiceDetail.TaxCode2, Items.Sale_Tax, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId)
          Union  all    
          -------------------------------------------- STO-----------------------------------------    
          Select 2 as DocType, Case when taxtype = 2 then N'SO' Else 'SL' End as ColType, @STO_Pre + cast(DocumentID as nVarchar) as DocuID, StockTransferOutDetail.Tax_Code, StockTransferOutDetail.TaxComponent_Code,
                 Sum(Amount)   as SalesValue, Sum(StockTransferOutDetail.TaxAmount)   as SalesTaxValue, 
                 sum(CompSalesTaxValue) as CompSalesTaxValue,
          Case       
          When StockTransferOutDetail.TaxSuffered = 0 and Items.Sale_Tax <> 0 Then N'0%'      
--           When StockTransferOutDetail.TaxSuffered = 0 and Items.Sale_Tax = 0 Then N'Exempt'      
          When StockTransferOutDetail.TaxSuffered = 0 and Items.Sale_Tax = 0 Then N'0%'      
          Else Cast( Cast(StockTransferOutDetail.TaxSuffered as Decimal(18,6)) as nvarchar) + N'%' End as ExemptType, N'S' + Convert(varchar(40), StockTransferOutAbstract.Docserial) as PrimaryKeyID
          From  StockTransferOutAbstract, Items,
                ( 
                     select StockTransferOutDetail.TaxSuffered, StockTransferOutDetail.DocSerial,
                            StockTransferOutDetail.product_Code,
                            Tax.Tax_Code, Tax.TaxComponent_Code, Tax.TaxCompPer,
                            sum(StockTransferOutDetail.Amount) as Amount ,
                            Sum(StockTransferOutDetail.TaxAmount)   as TaxAmount,
                            sum((isnull(TaxCompPer,0)/100)*Amount) as CompSalesTaxValue, tax.taxtype
                     from StockTransferOutDetail
                          Left Outer Join (   
                              Select * from #tmpSTOTax
                          ) Tax On StockTransferOutDetail.TaxSuffered = Tax.Percentage
						  Inner Join batch_products On StockTransferOutDetail.batch_code = batch_products.batch_code
                     where 
                        Case when batch_products.taxtype = 2 then 2 else 1 end = tax.taxtype
                     group by StockTransferOutDetail.TaxSuffered, StockTransferOutDetail.DocSerial,
                              StockTransferOutDetail.product_Code,  Tax.Tax_Code, Tax.TaxComponent_Code, Tax.TaxCompPer, tax.taxtype 
                ) StockTransferOutDetail, #TaxType
          Where StockTransferOutDetail.DocSerial = StockTransferOutAbstract.DocSerial      
                And StockTransferOutDetail.product_Code = Items.Product_Code      
                And (isnull(Status, 0) & 128) = 0 And 
                Case when taxtype = 2 then 'CST' else 'LST' end = #TaxType.[TaxTypeName] 
                and StockTransferOutAbstract.DocumentDate Between @From_Date and @To_Date   
          Group by StockTransferOutDetail.TaxSuffered, DocumentID, Items.Sale_Tax, 
                   StockTransferOutDetail.Tax_Code, StockTransferOutDetail.TaxComponent_Code, Case when taxtype = 2 then N'SO' Else 'SL' End, N'S' + Convert(varchar(40), StockTransferOutAbstract.Docserial) 
          Union  all  
          ------------------------------------------ Invoices----------------------------------------      
          Select 3 as DocType, N'I' as ColType,  @Inv_Pre + cast(DocumentID as nVarchar) as DocuID, InvoiceDetail.TaxID, InvoiceDetail.Tax_Component_Code , 
                 Sum(Amount) - Sum(STPayable) as SalesValue, Sum(STPayable)  as SalesTaxValue, 
                 sum(InvoiceDetail.Tax_Value) as CompSalesTaxValue,
--           Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'Exempt'       
          Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'0%'       
          When (InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0) or (Sum(STPayable) = 0) Then N'0%'        
          Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)  as ExemptType, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId) as PrimaryKeyID
          from InvoiceAbstract
		  Right Outer Join  Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage             
		  Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID  
		  Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code      
		  Inner Join #tmpInvoiceDetail as InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
          Where Customer.CustomerID In (Select CustomerID From #Customer)      
          And InvoiceType in (1,3)      
--           And Customer.Locality = 1      
          And InvoiceDetail.InvLocality = 1
          And (isnull(Status, 0) & 128) = 0      
          And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
          Group By DocumentID, InvoiceDetail.TaxID, InvoiceDetail.Tax_Component_Code, 
                   InvoiceDetail.TaxCode, Items.Sale_Tax, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId)
          Union  all    
          ------------------------------------- Retail Invoices--------------------------------------      
          Select 4 as DocType, N'R' as ColType,  @Inv_Pre + cast(DocumentID as nVarchar) as DocuID, InvoiceDetail.TaxID, InvoiceDetail.Tax_Component_Code , 
                 Sum(Amount) - Sum(STPayable) as SalesValue, Sum(STPayable)  as SalesTaxValue, 
                 sum(InvoiceDetail.Tax_Value) as CompSalesTaxValue,
--           Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'Exempt'       
          Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'0%'       
          When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'      
          Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)  as ExemptType, 'R' + Convert(varchar(40), InvoiceAbstract.InvoiceId) as PrimaryKeyID
          from InvoiceAbstract
		  Right Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage          
		  Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID      
		  Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code      
		  Inner Join #tmpInvoiceDetail  as InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
          Where Customer.CustomerID In (Select CustomerID From #Customer)  
          And InvoiceType in (2)  
          And (isnull(Status, 0) & 128) = 0      
          And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
          Group By DocumentID, InvoiceDetail.TaxID, InvoiceDetail.Tax_Component_Code, 
                   InvoiceDetail.TaxCode, Items.Sale_Tax, 'R' + Convert(varchar(40), InvoiceAbstract.InvoiceId)
          Union  all    
          ------------------Sales Return for Retail Invoices-----------------------------------------  
          Select 4 as DocType, N'R' as ColType,  @Inv_Pre + cast(DocumentID as nVarchar) as DocuID, InvoiceDetail.TaxID, InvoiceDetail.Tax_Component_Code , 
                 0 - (Sum(Amount) - Sum(STPayable)) as SalesValue, 0 - Sum(STPayable) as SalesTaxValue,
                 -1*sum(InvoiceDetail.Tax_Value) as CompSalesTaxValue,
--           Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'Exempt'       
          Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'0%'       
          When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'      
          Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)  as ExemptType, 'R' + Convert(varchar(40), InvoiceAbstract.InvoiceId) as PrimaryKeyID
          from InvoiceAbstract
		  Right Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage           
		  Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID      
		  Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code      
		  Inner Join #tmpInvoiceDetail  as InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
          Where Customer.CustomerID In (Select CustomerID From #Customer)  
          And InvoiceType in (5, 6)  
          And (isnull(Status, 0) & 128) = 0      
          And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
          Group By DocumentID, InvoiceDetail.TaxID, InvoiceDetail.Tax_Component_Code, 
                   InvoiceDetail.TaxCode, Items.Sale_Tax, 'R' + Convert(varchar(40), InvoiceAbstract.InvoiceId)
          Union  all    
          ------------------ Sales Return for invoices (Local Customers) ---------------------------      
          Select 3 as DocType, N'I' as ColType,  @Inv_Pre + cast(DocumentID as nVarchar) as DocuID, InvoiceDetail.TaxID, InvoiceDetail.Tax_Component_Code , 
                 0 - (sum(Amount) - sum(STPayable)) as SalesValue, 0 - sum(STPayable)  as SalesTaxValue,
                 -1*sum(InvoiceDetail.Tax_Value) as CompSalesTaxValue,
--           Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'Exempt'      
          Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'0%'       
		  When (InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0) or (Sum(STPayable) = 0) Then N'0%'        
          Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)  as ExemptType, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId) as PrimaryKeyID
          from InvoiceAbstract
		  Right Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage             
		  Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID  
		  Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code      
		  Inner Join  #tmpInvoiceDetail  as InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
          Where 
          --And Customer.CustomerID In (Select CustomerID From #Customer)      
          InvoiceType in (4)      
--           And Customer.Locality = 1      
          And InvoiceDetail.InvLocality = 1
          And (isnull(Status, 0) & 128) = 0      
          And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
          Group By DocumentID, InvoiceDetail.TaxID, InvoiceDetail.Tax_Component_Code, 
                   InvoiceDetail.TaxCode, Items.Sale_Tax, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId)
          Union  all    
          ----------------- Sales Return for invoices (Outstation Customers)-------------------------      
          Select 1 as DocType, N'O' as ColType,  @Inv_Pre + cast(DocumentID as nVarchar) as DocuID, InvoiceDetail.TaxID, InvoiceDetail.Tax_Component_Code , 
                 0 - (sum(Amount) - sum(CSTPayable))  as SalesValue, 0 - sum(CSTPayable) as SalesTaxValue,
                 -1*sum(InvoiceDetail.Tax_Value) as CompSalesTaxValue,
--           Cast((Case When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax = 0 Then N'Exempt'         
          Cast((Case When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax = 0 Then N'0%'         
          When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax <> 0 Then N'0%'        
          Else Cast(Cast(InvoiceDetail.TaxCode2 as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)  as ExemptType, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId) as PrimaryKeyID
          from InvoiceAbstract
		  Right Outer Join  Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode2 = Tax.CST_Percentage                 
		  Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID  
		  Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code        
		  Inner Join  #tmpInvoiceDetail  as InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID        
          Where Customer.CustomerID In (Select CustomerID From #Customer)        
          And InvoiceType in (4)        
--           And Customer.Locality = 2        
          And InvoiceDetail.InvLocality = 2
          And (isnull(Status, 0) & 128) = 0        
          And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date        
          Group By DocumentID, InvoiceDetail.TaxID, InvoiceDetail.Tax_Component_Code, 
                   InvoiceDetail.TaxCode2, Items.Sale_Tax, 'I' + Convert(varchar(40), InvoiceAbstract.InvoiceId)
     ) tmp
group by DocType, ColType, DocuID, TaxID, Tax_Component_Code , ExemptType, PrimaryKeyID


Delete from #tmpCompWiseData
from #tmpCompWiseData tmpDel Left outer Join #InvoiceTaxType tmp on tmpDel.PrimaryKeyID = tmp.primarykeyId 
where tmpDel.primarykeyId Is Null


-- --for each Sales Document get the tax detail
--Create the Fixed Columns
Set @SQL = N'Alter Table #SalesVAT Add [Outstation Sales (0%)_Value] decimal(18,6) default 0;'    
Set @SQL = @SQL + N'Alter Table #SalesVAT Add [STO (0%)_Value] decimal(18,6) default 0;'    
Set @SQL = @SQL + N'Alter Table #SalesVAT Add [Sales (0%)_Value] decimal(18,6) default 0;'    
Set @SQL = @SQL + N'Alter Table #SalesVAT Add [Retail (0%)_Value] decimal(18,6) default 0;'    
Exec(@SQL)

--Form the Dynamic selection list
set @OutstationSelection = N'[Outstation Sales (0%)_Value] as [Outstation Exempted Sales Value], '
set @STOSelection = N'[STO (0%)_Value] as [STO Exempted Sales Value], '
set @STOSelection_CST = N''
set @InvSelection = N'[Sales (0%)_Value] as [Invoice Exempted Sales Value], '
set @RetailInvSelection = N'[Retail (0%)_Value] as [Retail Exempted Sales Value], '

Declare cr_Document cursor static  for 
select distinct #SalesVAT.DocuID, isnull(#tmpCompWiseData.ColType, N'E') as ColType,#SalesVAT.PrimaryKeyID as PrimaryKeyID
from #SalesVAT
Left Outer Join  #tmpCompWiseData On #SalesVAT.PrimaryKeyID = #tmpCompWiseData.PrimaryKeyID
--       and (#tmpCompWiseData.ExcemtType <> '0%' or #tmpCompWiseData.ExcemtType <> 'Exempt') 

open cr_Document
fetch next from cr_Document into @DocumentID, @ColType, @PKID
while @@Fetch_Status = 0
Begin
    --Update the Excempt and 0% Cols
    --Outstation
    Set @SQL = N' update #SalesVAT  set [Outstation Sales (0%)_Value]  =  '
    Set @SQL = @SQL + N' (     '
    Set @SQL = @SQL + N' Select sum(SalesValue) from ('
    Set @SQL = @SQL + N' Select max(SalesValue) as SalesValue from #tmpCompWiseData      '
    Set @SQL = @SQL + N' where DocType = 1 and PrimaryKeyID = ''' + convert(varchar(40), @PKID) + ''' and Exempttype = ''0%'''
    Set @SQL = @SQL + N' group by Tax_Code) tmp '
    Set @SQL = @SQL + N' ) '
    Set @SQL = @SQL + N' where PrimaryKeyID = ''' + convert(varchar(40), @PKID) + ''';'
   --STO
    Set @SQL = @SQL + N' update #SalesVAT  set [STO (0%)_Value]  =  '
    Set @SQL = @SQL + N' (     '
    Set @SQL = @SQL + N' Select sum(SalesValue) from ('
    Set @SQL = @SQL + N' Select max(SalesValue) as SalesValue from #tmpCompWiseData      '
    Set @SQL = @SQL + N' where DocType = 2 and PrimaryKeyID = ''' + convert(varchar(40), @PKID) + ''' and Exempttype = ''0%'''
    Set @SQL = @SQL + N' group by Tax_Code) tmp '
    Set @SQL = @SQL + N' ) '
    Set @SQL = @SQL + N' where PrimaryKeyID = ''' + convert(varchar(40), @PKID) + ''';'
    --Invoice
    Set @SQL = @SQL + N' update #SalesVAT  set [Sales (0%)_Value]  =  '
    Set @SQL = @SQL + N' (     '
    Set @SQL = @SQL + N' Select sum(SalesValue) from ('
    Set @SQL = @SQL + N' Select sum(SalesValue) as SalesValue from #tmpCompWiseData      '
    Set @SQL = @SQL + N' where DocType = 3 and PrimaryKeyID = ''' + convert(varchar(40), @PKID) + ''' and Exempttype = ''0%'''
    Set @SQL = @SQL + N' group by Tax_Code) tmp '
    Set @SQL = @SQL + N' ) '
    Set @SQL = @SQL + N' where PrimaryKeyID = ''' + convert(varchar(40), @PKID) + ''';'
-- if @DocumentID = 'I7466'
-- select @SQL
    --Retail Invoices
    Set @SQL = @SQL + N' update #SalesVAT  set [Retail (0%)_Value]  =  '
    Set @SQL = @SQL + N' (     '
    Set @SQL = @SQL + N' Select sum(SalesValue) from ('
    Set @SQL = @SQL + N' Select max(SalesValue) as SalesValue from #tmpCompWiseData      '
    Set @SQL = @SQL + N' where DocType = 4 and PrimaryKeyID = ''' + convert(varchar(40), @PKID) + ''' and Exempttype = ''0%'''
    Set @SQL = @SQL + N' group by Tax_Code) tmp '
    Set @SQL = @SQL + N' ) '
    Set @SQL = @SQL + N' where PrimaryKeyID = ''' + convert(varchar(40), @PKID) + ''';'
    exec(@SQL)

    --Get the Taxes Involved in the Sales Document
    Declare cr_Taxes cursor static for   
    select Distinct Tax.Tax_Code, Tax.Tax_Description,
           case when @ColType = 'O' or @ColType = 'SO' then CST_Percentage else Tax.Percentage end as Percentage
    from #tmpCompWiseData as SalesDetail, Tax 
    where SalesDetail.PrimaryKeyID = @PKID 
          and SalesDetail.Tax_Code = Tax.Tax_Code and Tax.Percentage > 0 --and SalesDetail.CompSalesTaxValue <> 0
    open cr_Taxes
    fetch next from cr_Taxes into @Tax_Code, @Tax_Description, @TaxPercentage
	
    While @@Fetch_Status = 0
    Begin
		Set @TaxHead = dbo.mERP_fn_GetTaxColFormat(@Tax_Code, 0)
         --Log the Tax into a table to find whether tax column already created
         --If not created already add the tax and component columns
        set @isColExist = 0
         if not exists(Select * from #TaxLog where Tax_code = @Tax_code and ColType = @ColType)
         set @isColExist = 1

         insert into #TaxLog values (@Tax_Code, @ColType) 

         --Create or update the LST Column for the tax
         --@ColType 'O' --> Outstation, 'S' --> STO, 'I' --> Invoices, 'R' --> Retail Invoices
         if @ColType = 'O'
         Begin   
              set @SalesColName = N'[Outstation Sales (' + @TaxHead + N')_Value]'
              set @TaxColName = N'[Outstation Sales (' + @TaxHead + N')_Tax]'
              if @isColExist = 1
              set @OutstationSelection = @OutstationSelection + @SalesColName + N', ' + @TaxColName + N', '
              set @LST_Flag = 0
         End
         else if @ColType = 'SL'
         Begin   
              set @SalesColName = N'[STO (' + @TaxHead + N')_Value]'
              set @TaxColName = N'[STO (' + @TaxHead + N')_Tax]'
              if @isColExist = 1
              set @STOSelection = @STOSelection + @SalesColName + N', ' + @TaxColName + N', '
              set @LST_Flag = 1
         End
         else if @ColType = 'SO'
         Begin   
              set @SalesColName = N'[STO_CST_ (' + @TaxHead + N')_Value]'
              set @TaxColName = N'[STO_CST_ (' + @TaxHead + N')_Tax]'
              if @isColExist = 1
              set @STOSelection_CST = @STOSelection_CST + @SalesColName + N', ' + @TaxColName + N', '
              set @LST_Flag = 0
         End
         else if @ColType = 'I'
         Begin   
              set @SalesColName = N'[Sales (' + @TaxHead + N')_Value]'
              set @TaxColName = N'[Sales (' + @TaxHead + N')_Tax]' 
              if @isColExist = 1
              set @InvSelection = @InvSelection + @SalesColName + N', ' + @TaxColName + N', '
              set @LST_Flag = 1
         End
         else if @ColType = 'R'
         Begin   
              set @SalesColName = N'[Retail (' + @TaxHead + N')_Value]'  
              set @TaxColName = N'[Retail (' + @TaxHead + N')_Tax]' 
              if @isColExist = 1
              set @RetailInvSelection = @RetailInvSelection + @SalesColName + N', ' + @TaxColName + N', '
              set @LST_Flag = 1
         End

         if @isColExist = 1
         Begin  
              Set @SQL = N'Alter Table #SalesVAT Add ' + @SalesColName +  N' decimal(18,6) default 0;'    
              Set @SQL = @SQL + N'Alter Table #SalesVAT Add ' + @TaxColName +  N' decimal(18,6) default 0;'    
              Exec(@SQL)
         End
         
         Set @SQL =        N'Update #SalesVAT set ' + @SalesColName + N' = '
         Set @SQL = @SQL + N'      ('
         Set @SQL = @SQL + N'          select sum(Salesvalue) from ('
         Set @SQL = @SQL + N'          Select max(SalesValue) as SalesValue from #tmpCompWiseData'
         Set @SQL = @SQL + N'          where #tmpCompWiseData.PrimaryKeyID = ''' + convert(varchar(40), @PKID)  + N'''' 
         Set @SQL = @SQL + N'                and #tmpCompWiseData.ColType = ''' + cast(@ColType as nvarchar(10)) + N'''' 
         Set @SQL = @SQL + N'                and #tmpCompWiseData.Tax_code = ''' + cast(@Tax_Code as nvarchar(10)) + N''''
         Set @SQL = @SQL + N'                and (#tmpCompWiseData.ExemptType <> ''0%'' and #tmpCompWiseData.ExemptType <> ''Exempt'')' 
         Set @SQL = @SQL + N' group by Tax_Code) tmp '
         Set @SQL = @SQL + N'      )'
         Set @SQL = @SQL + N' where #SalesVAT.PrimaryKeyID = ''' + convert(varchar(40), @PKID)  + N'''' 
         Set @SQL = @SQL + N';'

         Set @SQL = @SQL + N'Update #SalesVAT set ' + @TaxColName + N' = '
         Set @SQL = @SQL + N'      ('
         Set @SQL = @SQL + N'          select sum(CompSalesTaxValue) '
         Set @SQL = @SQL + N'          from #tmpCompWiseData'
         Set @SQL = @SQL + N'          where #tmpCompWiseData.PrimaryKeyID = ''' + convert(varchar(40), @PKID)  + N'''' 
         Set @SQL = @SQL + N'                and #tmpCompWiseData.ColType = ''' + cast(@ColType as nvarchar(10)) + N'''' 
         Set @SQL = @SQL + N'                and #tmpCompWiseData.Tax_code = ''' + cast(@Tax_Code as nvarchar(10)) + N''''
         Set @SQL = @SQL + N'                and (#tmpCompWiseData.ExemptType <> ''0%'' and #tmpCompWiseData.ExemptType <> ''Exempt'')' 
         Set @SQL = @SQL + N'      )'
         Set @SQL = @SQL + N' where #SalesVAT.PrimaryKeyID = ''' + convert(varchar(40), @PKID)  + N'''' 
         Set @SQL = @SQL + N';'

--         Update #SalesVAT set [Invoice (12.500000%) VAT_LT 12.5% ON SalePrice 100% + CT 0% ON SalePrice 100%] =       
--         (select sum(CompSalesTaxValue) from #tmpCompWiseData where #tmpCompWiseData.DocuID = 'I95'
-- 	 and #tmpCompWiseData.ColType = 'I' and #tmpCompWiseData.Tax_code = '1'   
--         and (#tmpCompWiseData.ExemptType <> '0%' and #tmpCompWiseData.ExemptType <> 'Exempt')      ) where #SalesVAT.DocuID = 'I95';
         Exec(@SQL)

         --Create or update the Columns for the tax components
--          Declare cr_TxComp cursor static for 
--          select TaxComponentDetail.TaxComponent_Desc, Taxcomponents.TaxComponent_Code 
--          from Taxcomponents, TaxComponentDetail 
--          where Taxcomponents.Tax_code = @Tax_code 
--                and LST_Flag = @LST_Flag --1 --Local Station 2 --Out Station
--                and Taxcomponents.Taxcomponent_Code = TaxcomponentDetail.Taxcomponent_Code 
--          order by Taxcomponents.TaxComponent_Code
         if @ColType = 'O'
              Declare cr_TxComp cursor static for 
              select distinct TaxComponentDetail.TaxComponent_Desc, TaxComponentDetail.TaxComponent_code
              from InvoiceTaxComponents, TaxComponentDetail           
              where invoiceID in (
                                  select invoiceid 
                                  from #tmpInvoiceDetail as InvoiceDetail 
                                  where  isnull(InvoiceDetail.CSTPayable,0) <> 0
                                 )
                    and InvoiceTaxComponents.Tax_code = @Tax_code 
                    and InvoiceTaxComponents.Tax_Component_code = TaxComponentDetail.TaxComponent_code 
              order by TaxComponentDetail.TaxComponent_code
         else if ( @ColType = 'SL' or @ColType = 'SO' )
              Declare cr_TxComp cursor static for 
              select TaxComponentDetail.TaxComponent_Desc, Taxcomponents.TaxComponent_Code 
              from Taxcomponents, TaxComponentDetail 
              where Taxcomponents.Tax_code = @Tax_code 
                    and LST_Flag = @LST_Flag --1 --Local Station 2 --Out Station
    and Taxcomponents.Taxcomponent_Code = TaxcomponentDetail.Taxcomponent_Code 
              order by Taxcomponents.TaxComponent_Code
         else if @ColType = 'I' or @ColType = 'R'
         Begin
              Declare cr_TxComp cursor static for 
              select distinct TaxComponentDetail.TaxComponent_Desc, TaxComponentDetail.TaxComponent_code
              from InvoiceTaxComponents, TaxComponentDetail           
              where invoiceID in (
                                  select invoiceid 
                                  from #tmpInvoiceDetail as InvoiceDetail 
                                  where  isnull(InvoiceDetail.STPayable,0) <> 0 
                                 )
                    and InvoiceTaxComponents.Tax_code = @Tax_code 
                    and InvoiceTaxComponents.Tax_Component_code = TaxComponentDetail.TaxComponent_code 
              order by TaxComponentDetail.TaxComponent_code
         End

         open cr_TxComp
         fetch next from cr_TxComp into @Tax_Comp_Desc, @Tax_Comp_Code
         While @@Fetch_Status = 0
         Begin
			  Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@Tax_Code, @Tax_Comp_Code)
              --Use substring to reomove the right square bracket 
              set @SalesColName_Comp = substring(@SalesColName, 1,len(@SalesColName) - 1) + N'_' + @TaxCompHead + N']'
--              set @TaxColName_Comp = substring(@TaxColName, 1,len(@TaxColName) - 1) + N'_' + @TaxCompHead + N']'
              set @TaxColName_Comp = (Case @ColType When 'O' Then '[Outstation (' When 'SL' Then '[STO (' When 'SO' Then '[STO_CST (' 
										When 'I' Then '[Sales (' When 'R' Then '[Retail (' End) + @TaxCompHead + ') ]'
              if @isColExist = 1
              Begin  
                   if @ColType = 'O'
                        set @OutstationSelection = @OutstationSelection  + @TaxColName_Comp + N', '
                   else if @ColType = 'SL'
                        set @STOSelection = @STOSelection + @TaxColName_Comp + N', '
                   else if @ColType = 'SO'
                        set @STOSelection_CST = @STOSelection_CST + @TaxColName_Comp + N', '
                   else if @ColType = 'I'
                        set @InvSelection = @InvSelection +  @TaxColName_Comp + N', '
                   else if @ColType = 'R'
                        set @RetailInvSelection = @RetailInvSelection + @TaxColName_Comp + N', '

                   Set @SQL = N'Alter Table #SalesVAT Add ' + @TaxColName_Comp +  N' decimal(18,6) default 0;'   
                   Exec(@SQL)
              End
              --Update Columns for the tax components  for the Tax
              Set @SQL = N'Update #SalesVAT set ' + @TaxColName_Comp + N' = '
              Set @SQL = @SQL + N'      ('
              Set @SQL = @SQL + N'          select sum(CompSalesTaxValue) '
              Set @SQL = @SQL + N'          from #tmpCompWiseData'
              Set @SQL = @SQL + N'          where #tmpCompWiseData.PrimaryKeyID = ''' + convert(varchar(40), @PKID)  + N'''' 
              Set @SQL = @SQL + N'                and #tmpCompWiseData.ColType = ''' + cast(@ColType as nvarchar(10)) + N'''' 
              Set @SQL = @SQL + N'                and #tmpCompWiseData.Tax_code = ''' + cast(@Tax_Code as nvarchar(10)) + N''''
              Set @SQL = @SQL + N'                and #tmpCompWiseData.Tax_Component_code = ''' + cast(@Tax_Comp_Code as nvarchar(10)) + N''''
              Set @SQL = @SQL + N'                and (#tmpCompWiseData.ExemptType <> ''0%'' and #tmpCompWiseData.ExemptType <> ''Exempt'')' 
              Set @SQL = @SQL + N'      )'
              Set @SQL = @SQL + N' where #SalesVAT.PrimaryKeyID = ''' + convert(varchar(40), @PKID)  + N'''' 
              Set @SQL = @SQL + N';'
              Exec(@SQL)

         fetch next from cr_TxComp into @Tax_Comp_Desc, @Tax_Comp_Code
         End
         close cr_TxComp
         Deallocate cr_TxComp

    fetch next from cr_Taxes into @Tax_Code, @Tax_Description, @TaxPercentage
    End  
    close cr_Taxes
    Deallocate cr_Taxes
fetch next from cr_Document into @DocumentID, @ColType, @PKID
End 
close cr_Document
Deallocate cr_Document

set @RetailInvSelection = substring(@RetailInvSelection,1,len(@RetailInvSelection) - 1)

Exec(N'Select DocuDate, ''Document Date'' = DocuDate, ''Document ID '' = DocuID , ''Document Ref'' = DocRef, ''Customer/Branch'' = Cust_Name, [TIN Number], "PAN Number" = PANNumber ,NetValue,[Discount Value],[Credit Note Adjusted Amount],[F11 Adjustment], ' + @OutstationSelection + @STOSelection + @STOSelection_CST + @InvSelection + @RetailInvSelection + N' From  #SalesVAT Order by DocuDate,DocuID')      

drop table #tmpInvoiceDetail
drop table #tmpCompwiseData
drop table #tmpSTOTax
End
Drop Table #SalesVAT
Drop table #Customer  
Drop table #WareHouse  
drop table #TaxLog
--GSTOut:    
