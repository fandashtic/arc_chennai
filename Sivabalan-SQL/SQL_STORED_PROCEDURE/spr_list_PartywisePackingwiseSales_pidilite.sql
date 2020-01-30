CREATE Procedure spr_list_PartywisePackingwiseSales_pidilite (@Customer nvarchar(2550),     
@BeatName nvarchar(2550), @FromDate DateTime, @ToDate DateTime)    
As    
  
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)  
create table #tmpCust(Company_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
create table #tmpBeat(BeatID int)

if @Customer=N'%'  
   insert into #tmpCust select company_name from customer  
else  
   insert into #tmpCust select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)  

if @BeatName = N'%'
	insert into #tmpBeat select BeatID from Beat union select 0
else
	insert into #tmpBeat select BeatID from Beat Where [Description] In (select * from dbo.sp_SplitIn2Rows(@BeatName, @Delimeter))  
  
Select cu.CustomerID,
--+ Char(15) + cast(ia.BeatID as nvarchar), 
cu.CustomerID "Customer ID", Company_Name "Customer Name",     
"Beat" = IsNull(Beat.Description, N'Others'),
"Address" = IsNull(cu.BillingAddress, ''),
Sum((Case InvoiceType When 4 Then -1 Else 1 End) * Amount) "Net Value",     
Sum((Case InvoiceType When 4 Then -1 Else 1 End) * Quantity) "Total Quantity" From Customer cu     
Join InvoiceAbstract ia On cu.CustomerID = ia.CustomerID Join InvoiceDetail ide On    
ia.InvoiceID = ide.InvoiceID Left Outer Join Beat On ia.BeatId = Beat.BeatId 
Where IsNull(Company_Name, N'') In (select Company_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) And     
IsNull(ia.BeatID, N'') In (select BeatID from #tmpBeat) And
InvoiceDate Between @FromDate And @ToDate And (IsNull(Status, 0) & 192) = 0 And InvoiceType != 2    
Group By  Company_Name, cu.CustomerID, Beat.Description, cu.BillingAddress, ia.BeatID
  
drop table #tmpCust  
  



