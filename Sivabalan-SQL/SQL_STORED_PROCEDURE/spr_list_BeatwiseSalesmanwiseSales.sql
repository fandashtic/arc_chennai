CREATE Procedure spr_list_BeatwiseSalesmanwiseSales (@BeatName nVarChar(2550), @SalesmanName nVarChar(2550), @FromDate DateTime, @ToDate DateTime)      
as      
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)   
  
create table #tmpBeat(BeatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
create table #tmpSale(Salesman_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @BeatName=N'%'  
Begin
   insert into #tmpBeat select Description from Beat  
   Insert InTo #tmpBeat Values (N'')
--   Select * From #tmpBeat
End
else  
Begin
   insert into #tmpBeat select * from dbo.sp_SplitIn2Rows(@BeatName ,@Delimeter)  
End
if @SalesmanName=N'%'  
Begin
   insert into #tmpSale select Salesman_Name from Salesman  
   Insert InTo #tmpSale Values (N'')
--   Select * From #tmpSale
End
else  
Begin
   insert into #tmpSale select * from dbo.sp_SplitIn2Rows(@SalesmanName ,@Delimeter)  
End
  
Select Cast(BeatID As nVarChar) + N'$' + Cast(SalesmanID As nVarChar) "BeatID_SalesManID", IsNull([Beat Name], N'Others') "Beat Name", IsNull([Salesman Name], N'Others') "Salesman Name",       
Sum([Goods Value]) "Goods Value (%c)", Sum([Discount])      
"Discount (%c)", Sum([Net Value]) "Net Value (%c)",       
Sum([Balance]) "Balance (%c)", Sum([Cash Invoice]) "Cash Invoice (%c)", Sum([Credit Invoice]) "Credit Invoice (%c)" From (      
Select ia.BeatID, ia.SalesmanID, be.[Description] "Beat Name", sa.Salesman_Name       
"Salesman Name", GoodsValue "Goods Value", DiscountValue + AddlDiscountValue "Discount",      
(Case When InvoiceType In (4) Then -1 When InvoiceType in (1, 3) Then 1 End) * NetValue "Net Value",      
(Case When InvoiceType In (4) Then -1 When InvoiceType In (1, 3) Then 1 End) * Balance "Balance",       
(Case When InvoiceType In (4) Then -1 When InvoiceType in (1, 3) Then 1 End) * NetValue "Cash Invoice",       
0 "Credit Invoice"       
From InvoiceAbstract ia Left Join Beat be On       
ia.BeatID = be.BeatID Left Join Salesman sa On ia.SalesmanID = sa.SalesmanID Where       
(IsNull(Status, 0) & 192) = 0 And InvoiceType Not In (2) And PaymentMode In (1, 2, 3)       
And IsNull(sa.Salesman_Name, N'') in(select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale)   
And IsNull(be.[Description], N'') in(select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat)   
And InvoiceDate Between  @FromDate And @ToDate  
--And IsNull(sa.Salesman_Name, '') Like '%' And IsNull(be.[Description], '') Like '%' And InvoiceDate Between  '01-01-2005' And '31-01-2005'  
Union      
Select ia.BeatID,  ia.SalesmanID, be.[Description] "Beat Name", sa.Salesman_Name       
"Salesman Name", GoodsValue "Goods Value", DiscountValue + AddlDiscountValue "Discount",      
(Case When InvoiceType In (4) Then -1 When InvoiceType in (1, 3) Then 1 End) * NetValue "Net Value",      
(Case When InvoiceType In (4) Then -1 When InvoiceType In (1, 3) Then 1 End) * Balance "Balance",       
0 "Cash Invoice",       
(Case When InvoiceType In (4) Then -1 When InvoiceType in (1, 3) Then 1 End) * NetValue "Credit Invoice"       
From InvoiceAbstract ia Left Join Beat be On       
ia.BeatID = be.BeatID Left Join Salesman sa On ia.SalesmanID = sa.SalesmanID Where       
(IsNull(Status, 0) & 192) = 0 And InvoiceType Not In (2) And PaymentMode In (0)       
And IsNull(sa.Salesman_Name, N'') in(select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale)   
And IsNull(be.[Description], N'') in(select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat)   
And InvoiceDate Between  @FromDate And @ToDate  
--And IsNull(sa.Salesman_Name, '') Like '%' And IsNull(be.[Description], '') Like '%' And InvoiceDate Between  '01-01-2005' And '31-01-2005'  
) BSS Group By BeatID, SalesmanID, [Beat Name], [Salesman Name]    
  
drop table #tmpBeat  
drop table #tmpSale  
  
  




