CREATE procedure spr_list_Monthwise_Customer_OutStanding_Elf( @Customer nvarchar(2550),  
   						  @FromDate datetime,    
				                  @ToDate datetime)    
As   
Begin
If @ToDate >= @FromDate
Begin
Declare @ColumnCounter as int
Declare @ColumnName as nvarchar(30)
Declare @Counter as Int
Declare @Counter1 as Int
Declare @Year as Int
Declare @Month as int
Declare @OpeningDate as datetime
Declare @SQL as nvarchar(4000)
Declare @MinDate as datetime
Declare @StartDate as datetime



Set @MinDate =  (select min(InvoiceDate) from invoiceabstract)

If (select min(DocumentDate) from Collections) < @MinDate
Set @MinDate = (select min(DocumentDate) from Debitnote)

If (select min(DocumentDate) from CreditNote) < @MinDate
Set @MinDate = (select min(DocumentDate) from CreditNote)

If (select min(DocumentDate) from DebitNote) < @MinDate
Set @MinDate = (select min(DocumentDate) from DebitNote)

Set @Counter = Datediff(month,@FromDate,@ToDate) + 1
Set @Counter1 = Datediff(month,@FromDate,@ToDate) + 1

-- Getting the current financial operating year
Set @Month = (select datepart(month,@FromDate))
Set @Year = (select datepart(year,@FromDate))

Set @FromDate = '01' + '/' + cast(@Month as nvarchar) + '/' + cast(@Year as nvarchar)

Set @StartDate = @MinDate
Set @Todate = dateadd(month, 1, @FromDate) 

Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)      

create table #tmpCust(customerid nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @Customer='%'  
insert into #tmpCust select customerid from customer  
else  
insert into #tmpCust select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)  

create table #temp  
(
CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
)  

Set @ColumnCounter = 1
Set @ColumnName = N'Column' + cast(@ColumnCounter as nvarchar)

While @Counter > 0 

   Begin

   Set @columnname = N'Column' + cast(@ColumnCounter as varchar)
   Set @SQL = N'alter table #temp add ' + @columnname + N' decimal(18,6) null'
   exec sp_executesql @SQL

   -- OutStanding Balance from InvoiceAbstract

	Set @SQL = N' insert into #temp(CustomerID,' + @columnname + ')'  
	Set @SQL = @SQL + N' (Select Inv.CustomerID, Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0)'
	Set @SQL = @SQL + N' When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0)'     
	Set @SQL = @SQL + N' Else IsNull(Inv.Balance,0) End)'
	Set @SQL = @SQL + N' From InvoiceAbstract As Inv'
	Set @SQL = @SQL + N' Where Inv.CustomerID in (select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) And'
	Set @SQL = @SQL + N' Inv.InvoiceDate Between ' + Char(39) + cast(@StartDate as varchar) + Char(39) + ' And ' + Char(39) + cast(dbo.MakeDayEnd(dateadd(day,-1, @Todate)) as varchar) + Char(39)+ ' And'
	Set @SQL = @SQL + N' Inv.Balance > 0 And'
	Set @SQL = @SQL + N' Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And'
	Set @SQL = @SQL + N' Inv.Status & 128 = 0 group by Inv.CustomerID)'

	exec sp_executesql @SQL
	Set @SQL = N'' 

	-- OutStanding Balance from CreditNote

	Set @SQL = N' insert into #temp (CustomerID,' + @columnname + ')'  
	Set @SQL = @SQL + N' (Select Cr.CustomerID, 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr'
	Set @SQL = @SQL + N' where Cr.DocumentDate Between ' + Char(39) + cast(@StartDate as varchar) + Char(39) + N' And ' + Char(39) + cast(dbo.MakeDayEnd(dateadd(day,-1, @Todate)) as varchar) + Char(39)
	Set @SQL = @SQL + N' and Cr.CustomerID in (select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)'    
	Set @SQL = @SQL + N' and Cr.Balance > 0 group by Cr.CustomerID)'

	exec sp_executesql @SQL
	Set @SQL = N'' 

	-- OutStanding Balance from DebitNote

	Set @SQL = N' insert into #temp (CustomerID,' + @columnname + ')' 
	Set @SQL = @SQL + N' (Select Db.CustomerID, IsNull(Sum(Db.Balance), 0) From DebitNote As Db'
	Set @SQL = @SQL + N' where Db.DocumentDate Between ' + Char(39) + cast(@StartDate as varchar) + Char(39) + N' And ' +  Char(39) + cast(dbo.MakeDayEnd(dateadd(day,-1, @Todate)) as varchar) + Char(39) 
	Set @SQL = @SQL + N' and Db.CustomerID in (select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)'    
	Set @SQL = @SQL + N' and Db.balance > 0 group by Db.CustomerID)'      

	exec sp_executesql @SQL
	Set @SQL = N'' 

	-- Outstanding Balance from Collections

	Set @SQL = N' insert into #temp (CustomerID,' + @columnname + ')' 
	Set @SQL = @SQL + N' (Select Col.CustomerID,0 - IsNull(Sum(Col.Balance), 0) From Collections As Col'
	Set @SQL = @SQL + N' Where Col.CustomerID in (select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) And'
	Set @SQL = @SQL + N' Col.DocumentDate Between ' + Char(39) + cast(@StartDate as varchar) + Char(39) + N' And ' +  Char(39) + cast(dbo.MakeDayEnd(dateadd(day,-1, @Todate)) as varchar) + Char(39) + N' And'
	Set @SQL = @SQL + N' IsNull(Col.Status, 0) & 128 = 0 And'
	Set @SQL = @SQL + N' Col.Balance > 0 group by Col.CustomerID)'

	exec sp_executesql @SQL
	Set @SQL = N'' 
	
	-- Resetting the date range for the next slab 

        Set @Todate = dateadd(month, 1, @ToDate) 
	Set @ColumnCounter = @ColumnCounter + 1
	Set @Counter = @Counter - 1
  
	    End


-- Temporary table for Row numbers

create table #tmpCustomer(Rownum int IDENTITY, customerid nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	insert into #tmpCustomer (customerID) Select #temp.CustomerID from #temp group by #temp.CustomerID order by #temp.CustomerID

Set @SQL = N'select #temp.CustomerID,"S.No"=(select #tmpCustomer.Rownum from #tmpCustomer where #tmpCustomer.CustomerID = #temp.CustomerID),'
Set @SQL = @SQL + N'#temp.CustomerID,Customer.Company_Name,' + Char(13)

-- Dyanmic Column Name Mapping
-- Framing SQL Query for columns generated
	
Set @ColumnCounter = 1

Print @Counter1

While @Counter1 != 1
  begin
    Set @SQL = @SQL + N'"' + Cast(Datename(month, @FromDate)as varchar) + ' ' + Cast(Datepart(year,@FromDate)as varchar) + '"=' 
    Set @SQL = @SQL + N'Isnull(Sum(' + 'Column' + cast(@ColumnCounter as varchar) + '),0),' 
    Set @ColumnCounter = @ColumnCounter + 1
    Set @Counter1 = @Counter1 - 1
    Set @FromDate = dateadd(month, 1, @FromDate) 
	  End

Set @SQL = @SQL + N'"' + Cast(Datename(month, @FromDate)as varchar) + ' ' + Cast(Datepart(year,@FromDate)as varchar) + '"=' 
Set @SQL = @SQL + N'Isnull(Sum(' + 'Column' + cast(@ColumnCounter as varchar) + '),0)' 
Set @SQL = @SQL + N' From #temp, Customer'    
Set @SQL = @SQL + N' where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID'  
Set @SQL = @SQL + N' group by #temp.CustomerID, Customer.Company_Name'      
Set @SQL = @SQL + N' Order by #temp.CustomerID' 

exec sp_executesql @SQL
	
drop table #temp  
drop table #tmpCust  
drop table #tmpCustomer
End

Else
select 1

End


