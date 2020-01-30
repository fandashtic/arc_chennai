Create procedure spr_get_CustomerSummary_Detail (@CustID nvarchar(30), @FromDate DateTime, @ToDate DateTime)  
as  
begin   
  
declare @FromMonth int  
declare @ToMonth int  
-- declare @FromYear int  
-- declare @ToYear int  
declare @CurrMonth int  
-- declare @CurrYear int  
declare @Query nvarchar(1000)  
declare @ItemCode nvarchar(50)  
declare @Month nvarchar(15)  
declare @Count int  
  
declare @DateValue nVarchar(100)  
declare @ProductName nvarchar(100)  
declare @ProductCode nvarchar(50)    
Declare @Serial Int  
declare @ColNames nVarchar(4000)  
  
set @FromMonth = datepart(month, @FromDate)  
set @ToMonth = datepart(month, @FromDate) + datediff(m, @FromDate, @ToDate)  
-- set @FromYear = datepart(Year, @FromDate)  
-- set @ToYear = datepart(year, @ToDate)  
set @Count = 0  
set @CurrMonth = @FromMonth  
-- set @CurrYear = @FromYear  
  
  
Set @ColNames=N''  
  
create table #CustomerSummary_Abs  
(  
 Serial Int Identity(1, 1),  
 DateValue nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 ItemCode nVarchar(50),
 Item nvarchar(100),  
 Qty Decimal(18,6),  
 SalePrice Decimal(18,6),  
 Amount Decimal(18,6)  
)  
  
create table #CustomerSummary_Results  
(  
 DateValue nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 Item nvarchar(1000),  
 Qty Decimal(18,6),  
 SalePrice Decimal(18,6)  
)  
  
  
  
-- while @CurrYear <= @ToYear  
-- begin  
 while  @CurrMonth <= @ToMonth  
 begin  
  set @Month = convert(nvarchar, dateadd ( m, @Count, @FromDate) , 106)  
  set @Month = substring( @Month, 4, 15)  
  set @Query  = N'alter table #CustomerSummary_Abs add [' + @Month + N'] Decimal(18,6)'  
  exec (@Query)  
  
  set @Query  = N'alter table #CustomerSummary_Results add [' + @Month + N'] Decimal(18,6)'  
  exec (@Query)  
  
  Set @ColNames=@ColNames + N'['+ @Month + N'],'  
  set @CurrMonth = @CurrMonth + 1  
  set @Count = @Count + 1  
 end  
--  set @Count = 0  
--  set @CurrYear = @CurrYear + 1  
-- end  
Set @ColNames=Left(@ColNames,len(@ColNames)-1)  
  
insert into #CustomerSummary_Abs (DateValue,ItemCode, Item,Qty,SalePrice,Amount)     
--  select distinct It.Product_Code, It.ProductName,IDt.Quantity,IDt.SalePrice  
--  from Items It, InvoiceAbstract IA, InvoiceDetail IDt  
--  where   
--   IDt.InvoiceID = IA.InvoiceID   
--   and IA.CustomerID like @CustID   
--   and It.Product_Code = IDt.Product_Code   
--   and IA.InvoiceDate between @FromDate and @ToDate   
--   --and IA.InvoiceType <> 2  
--   and (IA.Status & 192) = 0  
  
select distinct substring(Convert(nVarchar,IA.InvoiceDate,106),4,15), It.Product_Code, It.ProductName,    
Sum(case IA.InvoiceType   
     when 4 then -IDt.Quantity  
     when 5 then -IDt.Quantity  
     when 6 then -IDt.Quantity  
     else IDt.Quantity end),  
Idt.SalePrice,  
sum(case IA.InvoiceType   
     when 4 then -IDt.Amount  
     when 5 then -IDt.Amount  
     when 6 then -IDt.Amount  
     else IDt.Amount end)  
from Items It, InvoiceAbstract IA, InvoiceDetail IDt  
where   
IDt.InvoiceID = IA.InvoiceID   
and IA.CustomerID like @CustID  
and It.Product_Code = IDt.Product_Code   
and IA.InvoiceDate between @FromDate and @ToDate  
and (IA.Status & 192) = 0  
Group by It.Product_Code,It.ProductName,substring(Convert(nVarchar,IA.InvoiceDate,106),4,15),Idt.SalePrice  
  
declare CustomerSummary cursor   
for  
select Serial, ItemCode,DateValue,Item from #CustomerSummary_Abs    
  
open CustomerSummary  
fetch next from CustomerSummary into @Serial, @ProductCode, @DateValue,@ProductName    
  
while @@FETCH_STATUS = 0  
begin   
 set @Count = 0  
 set @CurrMonth = @FromMonth  
--  set @CurrYear = @FromYear  
  
--  while @CurrYear <= @ToYear  
--  begin  
  while @CurrMonth <= @ToMonth  
  begin  
   set @Month = convert(nvarchar, dateadd ( m, @Count, @FromDate) , 106)  
   set @Month = substring( @Month, 4, 15)  
     
--    set @Query = '  
--    update #CustomerSummary_Abs   
--    set [' + ( @Month ) + '] = (  
--     select sum(case IA.InvoiceType   
--      when 4 then -IDt.Amount   
--      when 5 then -IDt.Amount  
--      when 6 then -IDt.Amount  
--      else IDt.Amount end)   
--     from InvoiceAbstract IA, InvoiceDetail IDt   
--     where   
--      IA.CustomerID like ''' + @CustID + ''' and  
--      IA.InvoiceID =IDt.InvoiceID and   
--      IDt.Product_Code =  ''' + @ItemCode + ''' and   
--      month(IA.InvoiceDate) = ' + cast(@CurrMonth  as varchar) + ' and   
--      year(IA.InvoiceDate) = ' + cast(@CurrYear as varchar) + ' and  
--      (IA.Status & 192) = 0   
--     )  
--    where ItemCode = ''' + @ItemCode + ''''  
  
  
--    set @Query = '  
--    update #CustomerSummary_Abs   
--    Set [' + ( @Month ) + '] = (  
--     select sum(case IA.InvoiceType   
--      when 4 then -IDt.Amount   
--      when 5 then -IDt.Amount  
--      when 6 then -IDt.Amount  
--      else IDt.Amount end)   
--     from InvoiceAbstract IA, InvoiceDetail IDt   
--     where   
--      IA.CustomerID like ''' + @CustID + ''' and  
--      IA.InvoiceID =IDt.InvoiceID and   
--      IDt.Product_Code =  ''' + @ItemCode + ''' and   
--      Substring(Convert(Varchar,IA.InvoiceDate,106),4,15)='''+ @Month + ''' and  
--      (IA.Status & 192) = 0   
--     )  
--    where ItemCode = ''' + @ItemCode + ''''  
  
   set @Query = N'  
   update #CustomerSummary_Abs   
   Set [' + ( @Month ) + '] = (  
    select Amount  
    from #CustomerSummary_Abs  
    where   
     itemCode =N'''+ @ProductCode + ''' and     
     datevalue=N'''+ @Month + ''' and   
    Serial = ''' + Cast (@Serial As nVarChar) + '''  
    )  
   Where    
   itemCode =N'''+ @ProductCode + ''' and     
    datevalue=N'''+ @Month + ''' and   
    Serial = ''' + Cast (@Serial As nVarChar) + ''''  
   exec (@Query)  
   set @Query = N'update #CustomerSummary_Abs   
        set [' + ( @Month ) + N'] = Null  
        where [' + ( @Month ) + N'] = 0'  
   exec (@Query)  
   set @CurrMonth = @CurrMonth + 1  
   set @Count = @Count + 1  
  end  
--   set @CurrYear = @CurrYear + 1  
--  end  
 fetch next from CustomerSummary into @Serial, @ProductCode, @DateValue,@ProductName    
end  
  
close CustomerSummary  
deallocate CustomerSummary  
  
Set @Query = N'Insert into #CustomerSummary_Results Select DateValue,Item,Qty,SalePrice,'+ @ColNames + N' From #CustomerSummary_Abs'  
Exec (@Query)  
  
--Select * From #CustomerSummary_Abs  
Select * From #CustomerSummary_Results  
  
-- drop table #CustomerSummary_Abs  
-- drop table #CustomerSummary_Results  
  
end  
  

