Create Procedure spr_InvWiseDivWise_Abstract(@MANUFACTURER nVarchar(2550),@BRANDNAME nVarchar(2550),@DocDate DateTime)
As
Begin
Declare @Delimeter as Char(1)        
Declare @cur_Div as Cursor
Declare @tmpSql as nVarchar(4000)
Declare @divName as nvarchar(255)
Declare @cur_DivSales as Cursor
Declare @invID AS int
Declare @netValue as decimal(18,6)
Declare @FieldName as nVarchar(4000)
Set @Delimeter = char(15)      

Create table #tmpDiv(Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Create Table #TmpMfr (Mfr nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    

if @BRANDNAME='%'        
   Insert into #tmpDiv select BrandName from Brand        
Else        
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@BRANDNAME,@Delimeter)        

If @MANUFACTURER = '%'   
	Insert Into #TmpMfr Select Manufacturer_Name From Manufacturer  
Else  
	Insert Into #TmpMfr Select * From dbo.sp_SplitIn2Rows(@MANUFACTURER,@Delimeter)  


Create Table #tmpTable(InvID INT,[Document ID] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Document Reference] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Invoice Date] Datetime,  
[Payment Date] DateTime,[Customer Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Invoice Gross Value] Decimal(18,6),[Product Discount] Decimal(18,6),  
[Scheme Discount] Decimal(18,6),[Addl Discount] Decimal(18,6),[Trade Discount] Decimal(18,6),[Tax Amount] Decimal(18,6),  
[Net Sales] Decimal(18,6),[Adj.Doc Reference] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Adj. Amount] Decimal(18,6),[Round Off Amount] Decimal(18,6),  
[Amount Collected] Decimal(18,6),[Balance] Decimal(18,6),[Due Days] Int,[Over Due Days] Int,[Rounded Net Amount] Decimal(18,6))  

Insert Into #tmpTable(InvID,[Document ID],[Document Reference],[Invoice Date],[Payment Date],[Customer Name],[Invoice Gross Value],
[Product Discount],[Scheme Discount],[Addl Discount],[Trade Discount],[Tax Amount],[Net Sales],[Adj.Doc Reference],[Adj. Amount],
[Round Off Amount],[Amount Collected],[Balance],[Due Days],[Over Due Days])
Select IA.InvoiceID,
Case isnull(IA.GSTFlag,0) when 0 then VP.Prefix + Cast(IA.DocumentID as nvarchar) else ISNULL(IA.GSTFullDocID,'') end, IA.DocReference,IA.InvoiceDate,IA.PaymentDate,
C.Company_Name,IA.GrossValue,IA.ProductDiscount,SchemeDiscountAmount,AddlDiscountValue,
"Trade Discount" = IA.GoodsValue * (IA.DiscountPercentage /100) ,TotalTaxApplicable,
"Net Value" =(case IA.InvoiceType 
When 1  then sum(ID.Amount)
When 2  then sum(ID.Amount)
When 3  then sum(ID.Amount)
When 4  then 0 - sum(ID.Amount)
When 5  then 0 - sum(ID.Amount)
When 6  then 0 - sum(ID.Amount)
end),
"Adj.Doc Reference" = IsNull(IA.AdjRef, N''),
"Adjusted Amount" = IsNull(IA.AdjustedAmount, 0),
"Round Off" = RoundOffAmount,
"Collected Amount" = NetValue - IsNull(IA.AdjustedAmount, 0) - IsNull(IA.Balance, 0) + IsNull(IA.RoundOffAmount, 0),
"Balance" = case IA.InvoiceType
when 1 then IA.Balance  
   when 2 then IA.Balance  
   when 3 then IA.Balance  
   when 4 then 0 - IA.Balance  
   when 5 then 0 - IA.Balance  
   when 6 then 0 - IA.Balance  
   end,  
"Due Days" =  DateDiff(dd, IA.InvoiceDate, @DocDate),           
"Over Due Days" = (Case When IA.PaymentDate < @DocDate Then DateDiff(dd,IA.PaymentDate,@DocDate) Else 0 End)
From InvoiceAbstract IA,VoucherPrefix VP,Customer C,InvoiceDetail ID,Items I,Brand B,Manufacturer M
Where 
VP.TranID = N'INVOICE' 
And C.CustomerID = IA.CustomerID 
And (IA.Status & 128) = 0 
And IA.InvoiceID = ID.InvoiceID
And B.BrandName In (select Division COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpDiv)     
And I.BrandID = B.BrandID     
And I.product_Code = ID.product_Code 
And M.Manufacturer_Name in (Select Mfr COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpMfr)  
And I.ManufacturerID = M.ManufacturerID   
And IA.InvoiceDate < = @DocDate
and IA.InvoiceType in (1,2,3,4,5,6)  
And isNull(IA.Balance,0) > 0
group By 
IA.InvoiceID,
VP.Prefix,IA.DocumentID,IA.DocReference,IA.InvoiceDate,IA.PaymentDate,C.Company_Name,IA.GrossValue,
IA.ProductDiscount,IA.SchemeDiscountAmount,IA.AddlDiscountValue,IA.GoodsValue,IA.DiscountPercentage,IA.TotalTaxSuffered,
IA.TotalTaxApplicable,IA.NetValue,IA.Freight,IA.InvoiceType,IA.AdjRef,IA.AdjustedAmount,IA.RoundOffAmount,IA.AdjustedAmount,IA.Balance,IA.GSTFlag,IA.GSTFullDocID

update #tmpTable set [Rounded Net Amount] = isnull([Round Off Amount],0) + isnull([Adj. Amount],0)

Create Table #tmpDivSales(InvoiceID Int,DivisionName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,NetValue Decimal(18,6))
Insert Into #tmpDivSales
Select IA.InvoiceID,"Division Name" = B.BrandName,     
"Net Value (%c)" = (Case IA.InvoiceType
  when 1 then Sum(Amount)
   when 2 then Sum(Amount)
   when 3 then Sum(Amount)
   when 4 then 0 - Sum(Amount)
   when 5 then 0 - Sum(Amount)
   when 6 then 0 - Sum(Amount)
   end)    
from InvoiceDetail ID,InvoiceAbstract IA,Brand B,Items I,Manufacturer M 
where IA.InvoiceID = ID.InvoiceID  
And (IA.Status&128 ) = 0 
and IA.InvoiceType in (1,2,3,4,5,6) 
And isNull(IA.Balance,0) > 0   
And B.BrandName In (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv)     
and I.BrandID = B.BrandID     
and I.product_Code = ID.product_Code    
And M.Manufacturer_Name in (Select Mfr COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpMfr)  
And I.ManufacturerID = M.ManufacturerID   
And IA.InvoiceDate < = @DocDate
Group by IA.InvoiceID,IA.InvoiceType,B.BrandName    


set @FieldName = ''
--Cursor To Add Columns
Set  @cur_Div  = Cursor For
Select Division From #tmpDiv
Open @cur_Div
Fetch Next From @cur_Div Into @divName
While @@Fetch_Status = 0
Begin
	Set @tmpSql = 'Alter Table #tmpTable Add [' + cast(@DivName as nvarchar) + '] nVarchar(255) Default(0)'
    Set @FieldName = @FieldName + N'[' + cast(@DivName as nvarchar) + N'],'
    Exec sp_executesql @tmpsql	
	Fetch Next From @cur_Div Into @divName
End
Close @cur_div
Deallocate @cur_div


--Cursor To Update The Table
Set @cur_DivSales  = Cursor For 
Select InvoiceID,DivisionName,NetValue From #tmpDivSales
Open @cur_DivSales
Fetch Next From @cur_DivSales Into @invID,@divName,@netValue
While @@fetch_status = 0
Begin
	Set @tmpSql = 'Update #tmpTable Set [' + Cast(@divName as nVarchar) + '] = '+ cast(@netValue as nVarchar) +' Where 
	InvID = '+ cast(@invID as nVarchar)
	Exec sp_executesql @tmpSql   
    Set @tmpSql = 'Update #tmpTable Set [Rounded Net Amount] = [Rounded Net Amount] + ' + cast(@netValue as nVarchar) + ' Where 
	InvID = '+ cast(@invID as nVarchar)
    Exec sp_executesql @tmpSql   
	Fetch Next From @cur_DivSales Into @invID,@divName,@netValue
End
Close @cur_DivSales
Deallocate @cur_DivSales

Set @FieldName = Substring(@FieldName, 1, Len(@FieldName) - 1)     
IF len(@FieldName)>0
	Set @FieldName = N','+@FieldName


exec (N'Select InvID ,[Document ID], [Document Reference],[Invoice Date],[Payment Date],[Customer Name],[Invoice Gross Value],[Product Discount],
[Scheme Discount],[Addl Discount],[Trade Discount],[Tax Amount],[Net Sales]' + @FieldName + ',[Adj.Doc Reference],[Adj. Amount],[Round Off Amount],[Rounded Net Amount],[Amount Collected],
[Balance],[Due Days],[Over Due Days] From  #tmpTable Order by [Document ID]')    


drop table #tmpTable
DROP TABLE #TMPDIV 
Drop Table #tmpMfr
Drop Table #tmpDivSales

End
