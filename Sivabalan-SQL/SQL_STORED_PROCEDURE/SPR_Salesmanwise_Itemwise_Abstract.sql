CREATE Procedure [dbo].[SPR_Salesmanwise_Itemwise_Abstract]
(@SalesManName nVarchar(4000),
@Beat_Name nVarchar(4000),
@FromDate Datetime,
@ToDate Datetime)
As

Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
Create Table #TempSalesMan(SalesManId INTEGER)

Create Table #TempBeat(Beatid integer)



if @SalesManName='%'     
	Begin
	   Insert into #TempSalesMan select SalesManid from SalesMan
	   Insert into #TempSalesMan Values(0)
	End
Else    
	   Insert into #TempSalesMan Select SalesmaniD from Salesman where salesman_name in (Select * FROM dbo.sp_SplitIn2Rows(@SalesManName,@Delimeter))    
 
If @Beat_Name = '%'
	Begin
	  Insert into #TempBeat select BEatid from Beat
	  Insert into #TempBeat Values(0)
	End
Else    
	   Insert into #TempBeat Select beatid From Beat where Description in (Select * from dbo.sp_SplitIn2Rows(@Beat_Name,@Delimeter))      
Begin




select distinct(Convert(nvarchar,isnull(invoiceabstract.salesmanid,0)) + ':' + Convert(nvarchar,isnull(InvoiceAbstract.BeatID,0))) as ID
, "Salesman" = case isnull(InvoiceAbstract.SalesmanID, 0 ) when 0 then Dbo.LookUpDictionaryItem('Others',Default) else Salesman.Salesman_Name end
, "Beat" = case isnull(InvoiceAbstract.BeatID, 0 ) when 0 then Dbo.LookUpDictionaryItem('OtherBeat',Default) else Beat.Description end
,sum(Case InvoiceAbstract.Invoicetype when 4 then 0-NetValue else NetValue end) as TotalValue  
,Sum(Case InvoiceAbstract.Invoicetype when 4 then 0-Balance Else Balance End) as Balance
from invoiceabstract
Left Outer Join Salesman on Isnull(invoiceabstract.Salesmanid,0) = Salesman.Salesmanid
Left Outer Join Beat on Isnull(Invoiceabstract.Beatid,0) = Beat.Beatid
WHERE 
--Isnull(invoiceabstract.Salesmanid,0)*=Salesman.Salesmanid
--And Isnull(Invoiceabstract.Beatid,0)*= Beat.Beatid
--And 
Isnull(Invoiceabstract.Beatid,0)  in(select beatid from #TempBeat)
And Invoicedate Between @FromDate And @Todate  
And Invoiceabstract.status & 128 = 0  
And Invoiceabstract.InvoiceType in (1,3,4)
And Isnull(invoiceabstract.Salesmanid,0) In (select SalesManId from #TempSalesMan)  
group by 
invoiceabstract.salesmanid,InvoiceAbstract.BeatID
,salesman.salesman_name,   
Beat.Description
end
