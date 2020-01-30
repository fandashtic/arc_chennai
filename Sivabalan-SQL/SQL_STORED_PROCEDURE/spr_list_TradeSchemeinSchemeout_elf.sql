CREATE Procedure spr_list_TradeSchemeinSchemeout_elf          
  (@FromDate datetime,          
   @ToDate datetime) as      
Begin    
    
Declare @Counter1 int      
Declare @Counter2 int      
Declare @Counter3 int      
Declare @Counter int      
Declare @SQL nvarchar(100)      
    
Set @ToDate = dbo.MakeDayend(@Todate)      
      
Create Table #temppurchase      
(    
Documentdate datetime,       
Pur_InvoiceNo nvarchar(25) null,      
Pur_SchemeDiscount Decimal(18,6) null,      
Pur_CashDiscount Decimal(18,6) null      
)      
      
Create Table #tempsales      
(      
Documentdate datetime,       
Sales_InvoiceNo nvarchar(25) null,      
Sales_TradeDiscount Decimal(18,6) null,      
Sales_CashDiscount Decimal(18,6) null,      
Sales_SpecialDiscount Decimal(18,6) null      
)      
      
      
insert into #tempPurchase      
(      
Documentdate,Pur_InvoiceNo,Pur_SchemeDiscount,      
Pur_cashDiscount)      
select BillAbstract.BillDate,      
VP.Prefix + cast(BillAbstract.BillID as nvarchar),       
Isnull((select sum(BillDiscount.DiscountAmount) from BillDiscount      
   where BillDiscount.BillID = BillAbstract.BillID and       
   BillDiscount.DiscountID=2),0),      
Isnull((select sum(BillDiscount.DiscountAmount) from BillDiscount      
   where BillDiscount.BillID = BillAbstract.BillID and       
   BillDiscount.DiscountID=4),0)      
from BillAbstract,BillDetail,VoucherPrefix VP      
where VP.TranID = N'BILL'      
and BillDetail.BillID = BillAbstract.BillID    
and BillAbstract.billdate between @FromDate and @ToDate       
and BillAbstract.BillID in (select BillID from Billdiscount where       
           DiscountID in (2,4))
and BillAbstract.Status & 128 = 0     
Group By BillAbstract.BillID,BillAbstract.BillDate,VP.Prefix    
Order by BillAbstract.BillDate   

      
insert into #tempSales      
(      
Documentdate,Sales_InvoiceNo,Sales_TradeDiscount,Sales_CashDiscount,      
Sales_SpecialDiscount)      
select InvoiceAbstract.InvoiceDate,      
VP.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar),      
DiscountValue,      
(Isnull((select DebitNote.NoteValue from DebitNote      
         where DocumentReference = InvoiceAbstract.Adjref      
         and DebitNote.AccountID=13 and DebitNote.Memo= N'Cash Discount'),0)),
ProductDiscount + AdditionalDiscount            
from InvoiceAbstract,VoucherPrefix VP      
where InvoiceDate between @FromDate and @ToDate       
and VP.TranID = N'INVOICE'        
and ((Discountvalue > 0) or (SchemeDiscountAmount > 0) or (ProductDiscount > 0) or (AdjustmentValue !=0)) 
and InvoiceAbstract.InvoiceType In (1, 2, 3, 4, 5, 6)     
and InvoiceAbstract.Status & 128 = 0       
order by InvoiceAbstract.InvoiceDate 
    
Set @Counter = datediff(dd,@FromDate,@ToDate) + 1      
        
While @Counter != 0       
      
Begin      
      
Set @Counter1 = (select count(*) from #temppurchase      
   where dbo.stripdatefromtime(documentdate)= dbo.stripdatefromtime(@fromdate))      
      
Set @Counter2 = (select count(*) from #tempsales      
   where dbo.stripdatefromtime(documentdate)= dbo.stripdatefromtime(@fromdate))      
      
If @counter1 > @counter2      
  begin      
    Set @Counter3 = @Counter1 - @Counter2      
    while @Counter3 !=0      
  begin       
    Set @SQL = N'insert #tempsales (Documentdate) values ('''+ cast (dbo.makedayend(@fromdate) as varchar) + N''')'      
    exec sp_Executesql @SQL      
    Set @Counter3 = @counter3 - 1      
  end      
  end       
      
If @counter1 < @counter2      
   begin      
     Set @Counter3 = @Counter2 - @Counter1      
     while @Counter3 !=0      
  begin       
    Set @SQL = N'insert #tempPurchase (Documentdate)values (''' + cast (dbo.makedayend(@fromdate) as varchar) + N''')'      
    exec sp_Executesql @SQL      
    Set @Counter3 = @counter3 - 1      
  end      
     end       
        
Set @fromdate = dateadd(day,1,@fromdate)      
Set @Counter = @Counter - 1      
end    
      
select * into #tempPurchase1 from #TempPurchase order by DocumentDate    
select * into #tempSales1 From #tempSales order by DocumentDate  
  
Set @SQL = 'alter table #tempPurchase1 add rownum int identity(1,1) '  
exec sp_executesql @SQL  
  
Set @SQL = 'alter table #tempSales1 add rownum int identity(1,1) '  
exec sp_executesql @SQL   
      
select 1,"Date"=#temppurchase1.documentdate,"Purchase Invoice No"= isnull(#temppurchase1.pur_invoiceno,''),       
 "Purchase Scheme Discount"= isnull(#temppurchase1.pur_schemediscount,'0'),      
        "Purchase Cash Discount" = isnull(#temppurchase1.pur_cashdiscount,'0'),      
 "Sales Invoice No"=isnull(#tempsales1.sales_invoiceno,''),      
 "Sales Trade Discount"= isnull(#tempsales1.sales_tradediscount,'0'),      
        "Sales Cash Discount"= isnull(#tempsales1.sales_cashdiscount,'0'),      
 "Sales Special Discount"= isnull(#tempsales1.sales_specialdiscount,'0')      
       from #temppurchase1, #tempsales1      
       where #temppurchase1.rownum = #tempsales1.rownum     
    
drop table #tempPurchase      
drop table #tempSales      
drop table #tempPurchase1      
drop table #tempSales1      
      
end      
    


