CREATE PROCEDURE [dbo].[spr_list_Invoicewise_ColumnItem]  
(@BRANDNAME nVARCHAR (2550),@FROMDATE DATETIME,@TODATE DATETIME)      
as      
Declare @StrSql1 nVarchar(4000)      
Declare @Columns nVarchar(4000)      
Declare @ProductName nvarchar(100)      
Declare @QTY Decimal(18,6)  
Declare @Gross Decimal(18,6)  
Declare @Dis Decimal(18,6)  
Declare @Tax Decimal(18,6)  
Declare @Net Decimal(18,6)      
Declare @InvID int  
Declare @Inv nvarchar(100)  
Declare @DocRef nvarchar(50)  
Declare @CompanyName nvarchar(100)  
Declare @OldInvid INT      
--DECLARE @INVS AS NVARCHAR(50)   
--SELECT @INVS = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'      
Set @OldInvid= -1       
set @Columns = ''      
Set @StrSql1 = ''      
  
Declare @Delimeter as Char(1) 
         
Set @Delimeter=Char(15)        
Create table #tmpDiv(Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
if @BRANDNAME='%'          
   Insert into #tmpDiv select BrandName from Brand          
Else          
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@BRANDNAME,@Delimeter)    
  
Select   
InvoiceID,InvoiceType,DocumentID,DocReference,"DocRef"=Left(DocReference,2),  
InvoiceDate,Status,Customer.Company_Name  
into #ref   
from Invoiceabstract,Customer   
where InvoiceAbstract.CustomerID=Customer.CustomerID  
And InvoiceDate Between @FromDate And @ToDate  And Status & 128 = 0     
  
  
Create Table #Temp  
(InvoiceID int,  
--DocRef nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Invoice nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
CompanyName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
ProductName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
QTY Decimal(18,6),  
GrossValue Decimal(18,6),  
Discount Decimal(18,6),  
Tax Decimal(18
,6),  
NetValue Decimal(18,6))   
  
Create Table #Temp5(InvoiceID int,--DocRef nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Invoice nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
CompanyName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Insert into #Temp     
Select #ref.DocumentID,--#ref.DocRef,  
#ref.DocReference,#ref.Company_Name,  
--@INVS + CAST(InvoiceAbstract.DocumentID AS nVARCHAR),     
  Items.ProductName,     
  Sum(InvoiceDetail.Quantity),  
  Sum(InvoiceDetail.Quantity* InvoiceDetail.SalePrice),  
  Sum(InvoiceDetail.DiscountValue),  
  Sum(InvoiceDetail.TaxAmount),  
  Sum(InvoiceDetail.Amount)  
  From #ref,InvoiceDetail,Items,Brand       
  Where InvoiceDetail.InvoiceID IN  
(Select InvoiceID from #ref where InvoiceType in (1,3) )      
  And #ref.InvoiceID=InvoiceDetail.InvoiceID   
  And InvoiceDetail.Product_Code = Items.Product_Code   
  And Brand.BrandName In (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv)        
  and items.BrandID=Brand.
BrandID     
  Group By #ref.DocumentID,Items.ProductName,#ref.DocReference,#ref.Company_Name--,#ref.DocRef  
--Get the Columns of the Table  
Declare TableColumn Cursor FOR      
 Select Distinct ProductName From #Temp Order by ProductName Asc      
Open
 TableColumn      
FETCH NEXT FROM TableColumn into @ProductName      
WHILE @@FETCH_STATUS =0      
BEGIN      
 SELECT @Columns = 'Alter table #temp5 Add [' + @ProductName + '] Decimal(18,6) default(0)'      
 Exec(@Columns)      
 FETCH NEXT FROM TableColumn into @ProductName      
END       
Close TableColumn      
Deallocate TableColumn   
Exec('Alter table #temp5 Add [GrossAmt] Decimal(18,6),[Discount] Decimal(18,6),  
[Tax] Decimal(18,6),[NetAmt] Decimal(18,6)')      
--Select * from #temp  
Declare InvTotal Cursor FOR      
 Select Invoiceid,--DocRef,  
Invoice,CompanyName,ProductName,Isnull(QTY,0),  
Isnull(GrossValue,0),Isnull(Discount,0),Isnull(Tax,0),Isnull(NetValue,0)   
From #Temp Order by InvoiceID Asc,ProductName Asc      
Open InvTotal  

--FETCH NEXT FROM InvTotal into @InvID,@DocRef,@Inv,@CompanyName,@ProductName,@QTY,@Gross,@Dis,@Tax,@Net      
     
FETCH NEXT FROM InvTotal into @InvID,@Inv,@CompanyName,@ProductName,@QTY,@Gross,@Dis,@Tax,@Net      
WHILE @@FETCH_STATUS =0   
BEGIN     
 
IF (@OldInvid <> @InvID)       
 Begin      
  Select @StrSql1='Insert into #Temp5(InvoiceID,Invoice,CompanyName) Values('  
+ Cast(@InvID as nvarchar) + --',N''' + @DocRef + ''  
',N''' + @Inv + ''',N''' + @CompanyName + ''') ;'    
--+ Cast(@InvID as nvarchar) + ',' + @DocRef + ',N''' + @Inv + ''') ;'      
    
   Exec(@strSql1)      
 End   
Select @OldInvid=@InvID      
 Select @StrSql1='Update #Temp5 Set ['+ @ProductName + '] = ' + Cast(@QTY as nvarchar) +   
' , [GrossAmt] = ISnull(GrossAmt,0) + 
' + Cast(@Gross as nvarchar) +   
' , [Discount] = ISnull(Discount,0) + ' + Cast(@Dis as nvarchar) +   
' , [Tax] = ISnull(Tax,0) + ' + Cast(@Tax as nvarchar) +   
' , [NetAmt] = ISnull(NetAmt,0) + ' + Cast(@Net as nvarchar) +    
' Where InvoiceID='+ Cast(@InvId as nvarchar) + ' ;'      
 Exec(@StrSql1)      
 FETCH NEXT FROM InvTotal into @InvID,--@DocRef,  
@Inv,@CompanyName,@ProductName,@QTY,@Gross,@Dis,@Tax,@Net      
END        
Close InvTotal      
Deallocate InvTotal          
       
Select @StrSql1 ='Select * from #Temp5 order by Invoice Asc'      
Exec(@StrSql1)   
  
      
Drop Table #Temp      
Drop Table #Temp5  
drop table #tmpDiv   
Drop Table #ref
