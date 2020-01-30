
Create procedure spr_Customerwise_Categorywise( @Customer nvarchar(2550),      
      @Product_Hierarchy nVarchar(256),               
      @Category nVarchar(2550),                         
      @FromDate datetime,        
             @ToDate datetime)        
as       
Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)        
      
Declare @One As Datetime      
Declare @Seven As Datetime      
Declare @Eight As Datetime      
Declare @Ten As Datetime      
Declare @Eleven As Datetime      
Declare @Fourteen As Datetime      
Declare @Fifteen As Datetime      
Declare @TwentyOne As Datetime      
Declare @TwentyTwo As Datetime      
Declare @Thirty As Datetime      
Declare @ThirtyOne As Datetime      
Declare @Sixty As Datetime      
Declare @SixtyOne As Datetime      
Declare @Ninety As Datetime      
Declare @NinetyOne as Datetime      
Declare @OneTwenty as datetime      
Declare @TOBEDEFINED nVarchar(50)

Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)

    
Declare @Continue int        
Declare @CategoryID int        
Set @Continue = 1        
    
Create Table #tempCategory(CategoryID int, Status int)              
Exec dbo.GetLeafCategories @Product_Hierarchy, @Category        
      
Set @One = Cast(Datepart(dd, GetDate()) As nvarchar) + N'/' +      
Cast(Datepart(mm, GetDate()) As nvarchar) + N'/' +      
Cast(Datepart(yyyy, GetDate()) As nvarchar)      
Set @Seven = DateAdd(d, -7, @One)      
Set @Eight = DateAdd(d, -1, @Seven)      
Set @Ten = DateAdd(d, -2, @Eight)      
Set @Eleven = DateAdd(d, -1, @Ten)      
Set @Fourteen = DateAdd(d, -3, @Eleven)      
Set @Fifteen = DateAdd(d, -1, @Fourteen)      
Set @TwentyOne = DateAdd(d, -6, @Fifteen)      
Set @TwentyTwo = DateAdd(d, -1, @TwentyOne)      
Set @Thirty = DateAdd(d, -8, @TwentyTwo)      
Set @ThirtyOne = DateAdd(d, -1, @Thirty)      
Set @Sixty = DateAdd(d, -29, @ThirtyOne)      
Set @SixtyOne = DateAdd(d, -1, @Sixty)      
Set @Ninety = DateAdd(d, -29, @SixtyOne)      
Set @NinetyOne = DateAdd(d, -1, @Ninety)      
Set @OneTwenty = DateAdd(d, -29, @NinetyOne)      
      
Set @One = dbo.MakeDayEnd(@One)      
Set @Eight = dbo.MakeDayEnd(@Eight)      
Set @Eleven = dbo.MakeDayEnd(@Eleven)      
Set @Fifteen = dbo.MakeDayEnd(@Fifteen)      
Set @TwentyTwo = dbo.MakeDayEnd(@TwentyTwo)      
Set @ThirtyOne = dbo.MakeDayEnd(@ThirtyOne)      
Set @SixtyOne = dbo.MakeDayEnd(@SixtyOne)      
Set @NinetyOne= dbo.MakeDayEnd(@NinetyOne)      
      
create table #tmpCust(customerid nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @Customer = N'%'      
   insert into #tmpCust select customerid from customer      
else      
   insert into #tmpCust select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)      
    
Create table #tmpCat(Category varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
If @Category = '%' And @Product_Hierarchy = '%'    
Begin    
    
   Insert into #tmpCat select Category_Name from ItemCategories Where [level] = 1    
    
End    
Else If @Category = '%' And @Product_Hierarchy != '%'    
Begin    
    
 Insert InTo #tmpCat select Category_Name From itemcategories itc, itemhierarchy ith    
 where itc.[level] = ith.hierarchyid and ith.hierarchyname = @Product_Hierarchy    
    
End    
Else          
Begin    
    
   Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter)          
End    
Create Table #temp2 (IDS Int IDENTITY(1, 1), CatID Int)    
Create Table #temp3 (CatID Int, Status Int)    
Create Table #temp4 (LeafID Int, CatID Int, Parent nVarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)    
    
Insert InTo #temp2 Select CategoryID     
From ItemCategories      
Where ItemCategories.Category_Name In (Select Category from #tmpCat)      
    
Declare @Continue2 Int    
Declare @Inc Int    
Declare @TCat Int    
Set @Inc = 1    
Set @Continue2 = IsNull((Select Count(*) From #temp2), 0)    
While @Inc <= @Continue2    
Begin    
Insert InTo #temp3 Select CatID, 0 From #temp2 Where IDS = @Inc    
Select @TCat = CatID From #temp2 Where IDS = @Inc    
While @Continue > 0        
Begin        
 Declare Parent Cursor Keyset For        
 Select CatID From #temp3  Where Status = 0        
 Open Parent        
 Fetch From Parent Into @CategoryID        
 While @@Fetch_Status = 0        
 Begin        
    
  Insert into #temp3    
  Select CategoryID, 0 From ItemCategories         
  Where ParentID = @CategoryID        
    
  If @@RowCount > 0         
   Update #temp3 Set Status = 1 Where CatID = @CategoryID        
  Else        
   Update #temp3 Set Status = 2 Where CatID = @CategoryID        
  Fetch Next From Parent Into @CategoryID        
 End        
 Close Parent        
 DeAllocate Parent        
 Select @Continue = Count(*) From #temp3 Where Status = 0        
End        
Delete #temp3 Where Status not in  (0, 2)        
Insert InTo #temp4 Select CatID, @TCat,     
(Select Category_Name From ItemCategories where CategoryID = @TCat)    
From #temp3    
Delete #temp3    
Set @Continue = 1    
Set @Inc = @Inc + 1    
End    
    
    
create table #temp1      
(CustomerID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,        
CategoryName nvarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,    
CategoryID Int,    
OutstandingValue Decimal(18, 6),     
OnetoSeven Decimal(18,6),      
EighttoTen Decimal(18,6),      
EleventoFourteen Decimal(18,6),      
FifteentoTwentyOne Decimal(18,6),      
TwentyTwotoThirty Decimal(18,6),      
LessthanThirty Decimal(18,6),      
ThirtyOnetoSixty Decimal(18,6),      
SixtyOnetoNinety Decimal(18,6),      
NinetyonetoOneTwenty Decimal(18,6),      
MorethanOneTwenty Decimal(18,6),      
NotOverDue Decimal(18,6),    
OverDue Decimal(18, 6),  
ChequeinHand decimal(18,6)    
)      
    
create table #temp5      
(CustomerID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,        
CategoryName nvarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,    
CategoryID Int,    
OutstandingValue Decimal(18, 6),     
OnetoSeven Decimal(18, 6),      
EighttoTen Decimal(18, 6),      
EleventoFourteen Decimal(18, 6),      
FifteentoTwentyOne Decimal(18, 6),      
TwentyTwotoThirty Decimal(18, 6),      
LessthanThirty Decimal(18, 6),      
ThirtyOnetoSixty Decimal(18, 6),      
SixtyOnetoNinety Decimal(18, 6),      
NinetyonetoOneTwenty Decimal(18, 6),      
MorethanOneTwenty Decimal(18 ,6),      
NotOverDue Decimal(18, 6),    
OverDue Decimal(18, 6),  
ChequeInHand decimal(18,6)    
)      
--one  
-----------------------------------------------------------------    
Insert InTo #temp5    
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (    
Select ids.serial, "ID" = 1, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
    
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,     
    
"CategoryID" = c.CategoryID,    
    
"Balance" = (Case ia.InvoiceType When 4 then 0-Isnull(ia.Balance,0)     
When 5 then 0 - Isnull(ia.Balance,0) When 6 then 0 - Isnull(ia.Balance,0)    
Else IsNull(ia.Balance,0) End),      
    
"Net Amount" = ids.amount,     
    
"Net Value" = IsNull((Select Sum(IsNull(Amount, 0)) From InvoiceDetail Where     
InvoiceDetail.InvoiceId = ia.InvoiceID), 0),     
    
"Outstanding Value" = ((IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      Else IsNull(ia.Balance,0) End)) +  
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1)),    
    
"1-7 Days" = 0,     
"8-10 Days" = 0,     
"11-14 Days" = 0,    
"15-21 Days" = 0,    
"22-30 Days" = 0,    
"<30 Days" = 0,    
"31-60 Days" = 0,    
"61-90 Days" = 0,    
"91-120 Days" = 0,    
">120 Days" = 0,    
"Not Over Due" = 0,     
"Over Due" = 0,  
"chequeinHand"  = 0  
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0    
and ia.invoicedate between @FromDate and @ToDate  
and ia.Balance >= 0     
and ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
it.categoryid = c.categoryid  And c.CategoryID In     
(Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust))CC  


--Union     
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (  
Select ids.serial, "ID" = 2, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
"CategoryID" = c.CategoryID,    
"Balance" = 0,    
"Net Amount" = 0,     
"Net Value" = 0,    
"Outstanding Value" = 0,    
"1-7 Days" = (IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      Else IsNull(ia.Balance,0) End) +   
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1)),    
"8-10 Days" = 0,     
"11-14 Days" = 0,    
"15-21 Days" = 0,    
"22-30 Days" = 0,    
"<30 Days" = 0,    
"31-60 Days" = 0,    
"61-90 Days" = 0,    
"91-120 Days" = 0,    
">120 Days" = 0,    
"Not Over Due" = 0,     
"Over Due" = 0,    
"chequeinHand"  = 0    
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
 ia.Status & 192 = 0 and ia.invoicedate Between @Seven And @One and  
ia.Balance >= 0 and ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
it.categoryid = c.categoryid and c.CategoryID In     
(Select CategoryID From #tempCategory) And     
ia.Customerid in (select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) And    
it.CategoryID In (Select its.CategoryID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0    
And  ia.InvoiceDate Between @FromDate And @ToDate  
And   ia.Balance >= 0  
and ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID   And c.CategoryID In     
(Select CategoryID From #tempCategory)) And     
ia.Customerid In (Select ia.CustomerID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where  ia.Status & 192 = 0    
And  ia.InvoiceDate Between @FromDate And @ToDate  
And   ia.Balance >= 0   
and ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID  And c.CategoryID In     
(Select CategoryID From #tempCategory)))CC  
    
--Union     
    
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (  
Select ids.serial, "ID" = 3, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
"CategoryID" = c.CategoryID,    
"Balance" = 0,    
"Net Amount" = 0,    
"Net Value" = 0,    
"Outstanding Value" = 0,    
"1-7 Days" = 0,    
"8-10 Days" = (IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      Else IsNull(ia.Balance,0) End)  
+  
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1))  
,    
"11-14 Days" = 0,    
"15-21 Days" = 0,    
"22-30 Days" = 0,    
"<30 Days" = 0,    
"31-60 Days" = 0,    
"61-90 Days" = 0,    
"91-120 Days" = 0,    
">120 Days" = 0,    
"Not Over Due" = 0,     
"Over Due" = 0,    
"chequeinHand"  = 0  
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0   
and ia.invoicedate Between @Ten And @Eight   
and  ia.Balance >= 0   
and ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
it.categoryid = c.categoryid And c.CategoryID In     
(Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)And    
it.CategoryID In (Select its.CategoryID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where  ia.Status & 192 = 0   
And ia.InvoiceDate Between @FromDate And @ToDate   
And ia.Balance >= 0   
and ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And c.CategoryID In     
(Select CategoryID From #tempCategory)) And     
ia.Customerid In (Select ia.CustomerID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0   
And ia.InvoiceDate Between @FromDate And @ToDate   
And ia.Balance >= 0   
and ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And c.CategoryID In     
(Select CategoryID From #tempCategory)))CC    
--    
--    
--Union     
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (  
Select ids.serial, "ID" = 4, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
"CategoryID" = c.CategoryID,    
"Balance" = 0,    
"Net Amount" = 0,    
"Net Value" = 0,    
"Outstanding Value" = 0,    
"1-7 Days" = 0,    
"8-10 Days" = 0,     
"11-14 Days" = (IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      Else IsNull(ia.Balance,0) End)  
+  
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1))  
,    
"15-21 Days" = 0,    
"22-30 Days" = 0,    
"<30 Days" = 0,    
"31-60 Days" = 0,    
"61-90 Days" = 0,    
"91-120 Days" = 0,    
">120 Days" = 0,    
"Not Over Due" = 0,     
"Over Due" = 0 ,  
"chequeinHand"  = 0    
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0 and ia.invoicedate between @Fourteen And @Eleven  and  
ia.Balance >= 0 and  
ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
it.categoryid = c.categoryid And c.CategoryID In     
(Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)And    
it.CategoryID In (Select its.CategoryID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 and   
ia.InvoiceDate Between @FromDate And @ToDate and  
ia.Balance >= 0 And  
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)) And     
ia.Customerid In (Select ia.CustomerID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 and  
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 And   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)))CC    
--    
--    
--Union     
  
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (  
Select ids.serial, "ID" = 5, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
    
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
    
"CategoryID" = c.CategoryID,    
    
"Balance" = 0,    
-- (Case ia.InvoiceType When 4 then 0-Isnull(ia.Balance,0)     
-- When 5 then 0 - Isnull(ia.Balance,0) When 6 then 0 - Isnull(ia.Balance,0)    
-- Else IsNull(ia.Balance,0) End),      
    
"Net Amount" = 0,    
--ids.amount,     
    
"Net Value" = 0,    
-- IsNull((Select Sum(IsNull(Amount, 0)) From InvoiceDetail Where     
-- InvoiceDetail.InvoiceId = ia.InvoiceID), 0),     
    
"Outstanding Value" = 0,    
"1-7 Days" = 0,    
"8-10 Days" = 0,     
"11-14 Days" = 0,    
"15-21 Days" = (IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      Else IsNull(ia.Balance,0) End)  
+  
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1))  
,    
"22-30 Days" = 0,    
"<30 Days" = 0,    
"31-60 Days" = 0,    
"61-90 Days" = 0,    
"91-120 Days" = 0,    
">120 Days" = 0,    
"Not Over Due" = 0,     
"Over Due" = 0,    
"chequeinHand"  = 0    
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0 And   
ia.invoicedate between @TwentyOne And @Fifteen and    
ia.Balance >= 0 and   
ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
it.categoryid = c.categoryid and   
c.CategoryID In     
(Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)And    
it.CategoryID In (Select its.CategoryID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)) And     
ia.Customerid In (Select ia.CustomerID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)))CC    
--    
--    
--Union     
--    
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (  
Select ids.serial, "ID" = 6, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
"CategoryID" = c.CategoryID,    
"Balance" = 0,    
"Net Amount" = 0,    
"Net Value" = 0,    
"Outstanding Value" = 0,    
"1-7 Days" = 0,    
"8-10 Days" = 0,     
"11-14 Days" = 0,    
"15-21 Days" = 0,    
"22-30 Days" = (IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      Else IsNull(ia.Balance,0) End)  
+  
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1))  
,    
"<30 Days" = 0,    
"31-60 Days" = 0,    
"61-90 Days" = 0,    
"91-120 Days" = 0,    
">120 Days" = 0,    
"Not Over Due" = 0,     
"Over Due" = 0,    
"chequeinHand"  = 0    
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0 And  
ia.invoicedate between @Thirty And @TwentyTwo and    
ia.Balance >= 0 and   
ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
it.categoryid = c.categoryid and   
c.CategoryID In     
(Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)And    
it.CategoryID In (Select its.CategoryID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)) And     
ia.Customerid In (Select ia.CustomerID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)))CC    
--    
--    
--Union     
--    
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (  
Select ids.serial, "ID" = 7, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
    
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
    
"CategoryID" = c.CategoryID,    
    
"Balance" = 0,    
-- (Case ia.InvoiceType When 4 then 0-Isnull(ia.Balance,0)     
-- When 5 then 0 - Isnull(ia.Balance,0) When 6 then 0 - Isnull(ia.Balance,0)    
-- Else IsNull(ia.Balance,0) End),      
    
"Net Amount" = 0,    
--ids.amount,     
    
"Net Value" = 0,    
-- IsNull((Select Sum(IsNull(Amount, 0)) From InvoiceDetail Where     
-- InvoiceDetail.InvoiceId = ia.InvoiceID), 0),     
    
"Outstanding Value" = 0,    
"1-7 Days" = 0,    
"8-10 Days" = 0,     
"11-14 Days" = 0,    
"15-21 Days" = 0,    
"22-30 Days" = 0,    
"<30 Days"  = (IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      Else IsNull(ia.Balance,0) End)  
+  
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1))  
,    
"31-60 Days" = 0,    
"61-90 Days" = 0,    
"91-120 Days" = 0,    
">120 Days" = 0,    
"Not Over Due" = 0,     
"Over Due" = 0,    
"chequeinHand"  = 0    
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0 And   
it.categoryid = c.categoryid and ia.invoicedate > @Thirty and    
ia.Balance >= 0 and   
ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
c.CategoryID In     
(Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)And    
it.CategoryID In (Select its.CategoryID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)) And     
ia.Customerid In (Select ia.CustomerID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)))CC    
--    
--    
--Union     
--    
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (  
Select ids.serial, "ID" = 8, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
    
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
    
"CategoryID" = c.CategoryID,    
    
"Balance" = 0,    
-- (Case ia.InvoiceType When 4 then 0-Isnull(ia.Balance,0)     
-- When 5 then 0 - Isnull(ia.Balance,0) When 6 then 0 - Isnull(ia.Balance,0)    
-- Else IsNull(ia.Balance,0) End),      
    
"Net Amount" = 0,    
--ids.amount,     
    
"Net Value" = 0,    
-- IsNull((Select Sum(IsNull(Amount, 0)) From InvoiceDetail Where     
-- InvoiceDetail.InvoiceId = ia.InvoiceID), 0),     
    
"Outstanding Value" = 0,    
"1-7 Days" = 0,    
"8-10 Days" = 0,     
"11-14 Days" = 0,    
"15-21 Days" = 0,    
"22-30 Days" = 0,    
"<30 Days" = 0,    
"31-60 Days" = (IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      Else IsNull(ia.Balance,0) End)  
+  
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1))  
,    
"61-90 Days" = 0,    
"91-120 Days" = 0,    
">120 Days" = 0,    
"Not Over Due" = 0,     
"Over Due" = 0,    
"chequeinHand"  = 0    
    
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0 And   
ia.invoicedate between @Sixty And @ThirtyOne and    
ia.Balance >= 0 and   
ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
it.categoryid = c.categoryid and   
c.CategoryID In     
(Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)And    
it.CategoryID In (Select its.CategoryID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)) And     
ia.Customerid In (Select ia.CustomerID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)))CC    
--    
--    
--Union     
--    
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (  
Select ids.serial, "ID" = 9, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
    
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
    
"CategoryID" = c.CategoryID,    
    
"Balance" = 0,    
"Net Amount" = 0,     
"Net Value" = 0,    
"Outstanding Value" = 0,    
"1-7 Days" = 0,    
"8-10 Days" = 0,     
"11-14 Days" = 0,    
"15-21 Days" = 0,    
"22-30 Days" = 0,    
"<30 Days" = 0,    
"31-60 Days" = 0,    
"61-90 Days" = (IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      Else IsNull(ia.Balance,0) End)  
+  
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1))  
,    
"91-120 Days" = 0,    
">120 Days" = 0,    
"Not Over Due" = 0,     
"Over Due" = 0,    
 "chequeinHand"  = 0  
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0 And   
ia.invoicedate between @Ninety And @SixtyOne and    
ia.Balance >= 0 and   
ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
it.categoryid = c.categoryid and   
c.CategoryID In     
(Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)And    
it.CategoryID In (Select its.CategoryID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)) And     
ia.Customerid In (Select ia.CustomerID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)))CC    
--    
--    
--Union     
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (    
Select ids.serial, "ID" = 10, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
    
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
    
"CategoryID" = c.CategoryID,    
    
"Balance" = 0,    
-- (Case ia.InvoiceType When 4 then 0-Isnull(ia.Balance,0)     
-- When 5 then 0 - Isnull(ia.Balance,0) When 6 then 0 - Isnull(ia.Balance,0)    
-- Else IsNull(ia.Balance,0) End),      
    
"Net Amount" = 0,    
--ids.amount,     
    
"Net Value" = 0,    
-- IsNull((Select Sum(IsNull(Amount, 0)) From InvoiceDetail Where     
-- InvoiceDetail.InvoiceId = ia.InvoiceID), 0),     
    
"Outstanding Value" = 0,    
"1-7 Days" = 0,    
"8-10 Days" = 0,     
"11-14 Days" = 0,    
"15-21 Days" = 0,    
"22-30 Days" = 0,    
"<30 Days" = 0,    
"31-60 Days" = 0,    
"61-90 Days" = 0,    
"91-120 Days" = (IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      Else IsNull(ia.Balance,0) End)  
+  
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1))  
,    
">120 Days" = 0,    
"Not Over Due" = 0,     
"Over Due" = 0,    
"chequeinHand"  = 0    
    
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0 And   
ia.invoicedate between @OneTwenty And @NinetyOne and    
ia.Balance >= 0 and   
ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
it.categoryid = c.categoryid and   
c.CategoryID In     
(Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)And    
it.CategoryID In (Select its.CategoryID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)) And     
ia.Customerid In (Select ia.CustomerID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)))CC    
--    
--    
--Union     
  
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (    
Select ids.serial, "ID" = 11, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
  
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
    
"CategoryID" = c.CategoryID,    
    
"Balance" = 0,    
-- (Case ia.InvoiceType When 4 then 0-Isnull(ia.Balance,0)     
-- When 5 then 0 - Isnull(ia.Balance,0) When 6 then 0 - Isnull(ia.Balance,0)    
-- Else IsNull(ia.Balance,0) End),      
    
"Net Amount" = 0,    
--ids.amount,     
    
"Net Value" = 0,    
-- IsNull((Select Sum(IsNull(Amount, 0)) From InvoiceDetail Where     
-- InvoiceDetail.InvoiceId = ia.InvoiceID), 0),     
    
"Outstanding Value" = 0,    
"1-7 Days" = 0,    
"8-10 Days" = 0,     
"11-14 Days" = 0,    
"15-21 Days" = 0,    
"22-30 Days" = 0,    
"<30 Days" = 0,    
"31-60 Days" = 0,    
"61-90 Days" = 0,    
"91-120 Days" = 0,    
">120 Days" = (IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      Else IsNull(ia.Balance,0) End)  
+  
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1))  
,    
"Not Over Due" = 0,     
"Over Due" = 0,  
"chequeinHand"  = 0    
    
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0 And   
ia.invoicedate < @OneTwenty and    
ia.Balance >= 0 and   
ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
it.categoryid = c.categoryid and   
c.CategoryID In     
(Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)And    
it.CategoryID In (Select its.CategoryID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)) And     
ia.Customerid In (Select ia.CustomerID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)))CC    
--    
--    
--Union     
--    
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (  
Select ids.serial, "ID" = 12, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
    
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
    
"CategoryID" = c.CategoryID,    
    
"Balance" = 0,    
-- (Case ia.InvoiceType When 4 then 0-Isnull(ia.Balance,0)     
-- When 5 then 0 - Isnull(ia.Balance,0) When 6 then 0 - Isnull(ia.Balance,0)    
-- Else IsNull(ia.Balance,0) End),      
    
"Net Amount" = 0,    
--ids.amount,     
    
"Net Value" = 0,    
-- IsNull((Select Sum(IsNull(Amount, 0)) From InvoiceDetail Where     
-- InvoiceDetail.InvoiceId = ia.InvoiceID), 0),     
    
"Outstanding Value" = 0,    
"1-7 Days" = 0,    
"8-10 Days" = 0,     
"11-14 Days" = 0,    
"15-21 Days" = 0,    
"22-30 Days" = 0,    
"<30 Days" = 0,    
"31-60 Days" = 0,    
"61-90 Days" = 0,    
"91-120 Days" = 0,    
">120 Days" = 0,    
"Not Over Due" = (IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      Else IsNull(ia.Balance,0) End)  +  
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1)),    
"Over Due" = 0,  
"chequeinHand"  = 0    
    
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0  And   
ia.invoicedate between @FromDate and @ToDate  and ia.Balance >= 0 and   
(Case When ia.InvoiceType In (4, 5, 6) Then     
@ToDate Else ia.PaymentDate End) >= @ToDate and      
ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
it.categoryid = c.categoryid and   
c.CategoryID In (Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust))CC    
--    
--    
--Union     
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (    
Select ids.serial, "ID" = 13, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
    
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
    
"CategoryID" = c.CategoryID,    
    
"Balance" = 0,    
-- (Case ia.InvoiceType When 4 then 0-Isnull(ia.Balance,0)     
-- When 5 then 0 - Isnull(ia.Balance,0) When 6 then 0 - Isnull(ia.Balance,0)    
-- Else IsNull(ia.Balance,0) End),      
    
"Net Amount" = 0,    
--ids.amount,     
    
"Net Value" = 0,     
-- IsNull((Select Sum(IsNull(Amount, 0)) From InvoiceDetail Where     
-- InvoiceDetail.InvoiceId = ia.InvoiceID), 0),     
    
"Outstanding Value" = 0,    
"1-7 Days" = 0,    
"8-10 Days" = 0,     
"11-14 Days" = 0,    
"15-21 Days" = 0,    
"22-30 Days" = 0,    
"<30 Days" = 0,    
"31-60 Days" = 0,    
"61-90 Days" = 0,    
"91-120 Days" = 0,    
">120 Days" = 0,    
"Not Over Due" = 0,     
"Over Due" = (IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End) *     
(Case ia.InvoiceType When 4 Then 0 - Isnull(ia.Balance,0)    
                    When 5 Then 0 - Isnull(ia.Balance,0)     
      When 6 Then 0 - Isnull(ia.Balance,0)    
      When 2 Then 0     
      Else IsNull(ia.Balance,0) End)  
+  
(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
(Select   
Case When MAx(isnull(C.Realised,0)) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))  
Else  
(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end  
from Collections C, CollectionDetail CD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
and IsNull(c.Realised, 0) Not In (1))  
,  
"chequeinHand"  = 0    
    
From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0   And   
ia.invoicedate between @FromDate and @ToDate  and ia.Balance >= 0 and   
it.categoryid = c.categoryid and ia.PaymentDate < @ToDate and      
ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
c.CategoryID In (Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust))CC    
--  
--Union     
Insert Into #temp5  
Select [CustomerID], [Category Name], [CategoryID],     
[Outstanding Value], [1-7 Days],     
[8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days],     
[>120 Days], [Not Over Due], [Over Due],[ChequeinHand] From (    
Select ids.serial, "ID" = 13, "InvoiceID" = ia.invoiceid, "CustomerID" = ia.customerid,     
"Item Code" = ids.product_code, "Category Name" = c.Category_Name,    
"CategoryID" = c.CategoryID,    
"Balance" = 0,    
"Net Amount" = 0,    
"Net Value" = 0,     
"Outstanding Value" = 0,    
"1-7 Days" = 0,    
"8-10 Days" = 0,     
"11-14 Days" = 0,    
"15-21 Days" = 0,    
"22-30 Days" = 0,    
"<30 Days" = 0,    
"31-60 Days" = 0,    
"61-90 Days" = 0,    
"91-120 Days" = 0,    
">120 Days" = 0,    
"Not Over Due" = 0,     
"Over Due" = 0, --Chequeinhand  
"ChequeinHand"=(IsNull(ids.amount, 0) / Case IsNull((Select Sum(IsNull(Amount, 1))     
From InvoiceDetail Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) When 0 Then 1 Else     
IsNull((Select Sum(IsNull(Amount, 1)) From InvoiceDetail     
Where InvoiceDetail.InvoiceId = ia.InvoiceID), 1) End)  
  
 *     
--(Select   
--Case When MAx(isnull(C.Realised,0)) =3 Then  
--(dbo.mERP_fn_getCollBalance_ITC_Rpt(MAx(CD.DocumentID), MAx(CD.DocumentType),@Todate))  
--Else  
--	(Case When Max(isnull(CCd.ChqStatus,0)) = 1 And dbo.stripdatefromtime(@todate) < isnull(Max(dbo.stripdatefromtime(CCD.Realisedate)),getdate()) Then
--	(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))
--	When isnull(Max(CCd.ChqStatus),0) = 1 And dbo.stripdatefromtime(@todate) = isnull(Max(dbo.stripdatefromtime(CCD.Realisedate)),getdate()) Then 0
--	Else
--	(isnull(sum(isnull(AdjustedAmount,0)),0)-isnull(sum(isnull(DocAdjustAmount,0)),0))end)
--End  
--from Collections C, CollectionDetail CD,ChequecollDetails CCD  
--Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
--And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
--And C.DocumentDate between @fromdate and @todate
--And CCD.CollectionID = C.Documentid
--and IsNull(c.Realised, 0) Not In (2))  
(Select Sum( 
Case When isnull(C.Realised,0) =3 Then  
(dbo.mERP_fn_getCollBalance_ITC_Rpt(CD.DocumentID, CD.DocumentType,@Todate,C.documentID,GetDate()))  
Else  
	(Case When isnull(CCd.ChqStatus,0) = 1 And dbo.stripdatefromtime(@todate) < isnull(dbo.stripdatefromtime(CCD.Realisedate),getdate()) Then
	(isnull(isnull(AdjustedAmount,0),0)-isnull(isnull(DocAdjustAmount,0),0))
	When isnull(CCd.ChqStatus,0) = 1 And dbo.stripdatefromtime(@todate) >= isnull(dbo.stripdatefromtime(CCD.Realisedate),getdate()) Then 0
	Else
	(isnull(isnull(AdjustedAmount,0),0)-isnull(isnull(DocAdjustAmount,0),0))end)
End ) 
--from Collections C, CollectionDetail CD,ChequecollDetails CCD  
--Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
--And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
--And C.DocumentDate between @fromdate and @todate
--And CCD.CollectionID = C.Documentid
--and IsNull(c.Realised, 0) Not In (2)) 
from Collections C, CollectionDetail CD,ChequecollDetails CCD  
Where CD.Documenttype = 4 and CD.DocumentID = ia.InvoiceID And C.customerID = ia.CustomerID And C.documentID = CD.CollectionID   
And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1  
And CD.Documentid = CCD.Documentid
And C.DocumentDate between @fromdate and @todate
And CCD.CollectionID = C.Documentid
and IsNull(c.Realised, 0) Not In (2))     

   


From invoiceabstract ia, invoicedetail ids, ItemCategories c, Items it where     
ia.Status & 192 = 0 And   
ia.invoicedate between @FromDate And @ToDate and    
ia.Balance >= 0 and   
ia.invoiceid = ids.invoiceid and it.product_code = ids.product_Code and     
it.categoryid = c.categoryid and   
c.CategoryID In     
(Select CategoryID From #tempCategory) And     
ia.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)And    
it.CategoryID In (Select its.CategoryID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory)) And     
ia.Customerid In (Select ia.CustomerID From invoiceabstract ia, invoicedetail ids,     
ItemCategories c, Items its Where ia.Status & 192 = 0 And   
ia.InvoiceDate Between @FromDate And @ToDate And     
ia.Balance >= 0 and   
ia.InvoiceID = ids.InvoiceID And     
ids.Product_Code = its.Product_Code And its.CategoryID = c.CategoryID And     
c.CategoryID In     
(Select CategoryID From #tempCategory))) cc    
  
Insert InTo #temp1 Select CustomerID, CategoryName, CategoryID, Sum(OutstandingValue),     
Sum(OnetoSeven), Sum(EighttoTen), Sum(EleventoFourteen), Sum(FifteentoTwentyOne),    
Sum(TwentyTwotoThirty), Sum(LessthanThirty), Sum(ThirtyOnetoSixty),    
Sum(SixtyOnetoNinety), Sum(NinetyonetoOneTwenty), Sum(MorethanOneTwenty),     
Sum(NotOverDue), Case When Sum(OutstandingValue) = Sum(NotOverDue) Then 0     
        Else Sum(OverDue) End,Sum(chequeinHand) From #temp5 Group By     
CustomerID, CategoryName, CategoryID    
    
--select * from #temp1    
-- select * from #temp4    
Create Table #temp6 (CUCT nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ForumCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,     
BeatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Customer Type] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CreditTerm nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,     
Customer nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Category nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, NoofDocs int,     
NotOverDue Decimal(18, 6), OverDue Decimal(18, 6),     
OutstandingValue Decimal(18, 6), [1-7 Days] Decimal(18, 6), [8-10 Days] Decimal(18, 6),    
[11-14 Days] Decimal(18, 6), [15-21 Days] Decimal(18, 6),     
[22-30 Days] Decimal(18, 6), [<30 Days] Decimal(18, 6),     
[31-60 Days] Decimal(18, 6), [61-90 Days] Decimal(18, 6),     
[91-120 Days] Decimal(18, 6), [>120 Days] Decimal(18, 6),[ChequeInHand] decimal(18,6))    
    
Create Table #temp7 (IDs Int IDENTITY(1, 1), CustID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Cat nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, LeafID Int)    
    
Create Table #temp8 (IDs Int , CustID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Cat nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, LeafID Int)    
    

-- Channel type name changed, and new channel classifications added

CREATE TABLE #OLClassMapping (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  

Insert Into #OLClassMapping 
Select  olcm.OLClassID, olcm.CustomerId, olc.Channel_Type_Desc, olc.Outlet_Type_Desc, 
olc.SubOutlet_Type_Desc 
From tbl_merp_olclass olc, tbl_merp_olclassmapping olcm
Where olc.ID = olcm.OLClassID And
olc.Channel_Type_Active = 1 And olc.Outlet_Type_Active = 1 And olc.SubOutlet_Type_Active = 1 And 
olcm.Active = 1 
    
Insert InTo #temp6    
    
Select [CUCT], [CustomerID], [Forum Code], [Beat Name], [Customer Type], 
[Channel Type] , [Outlet Type] , [Loyalty Program],
[Credit Term],     
[Customer], [Category], [No of Docs],     
"Not Over Due" = Sum([Not Over Due]), "Over Due" = Sum([Over Due]),     
"Outstanding Value (%c)" = Sum([Outstanding Value]),     
"1-7 Days" = Sum([1-7 Days]), "8-10 Days" = Sum([8-10 Days]),     
"11-14 Days" = Sum([11-14 Days]), "15-21 Days" = Sum([15-21 Days]),     
"22-30 Days" = Sum([22-30 Days]), "<30 Days" = Sum([<30 Days]),     
"31-60 Days" = Sum([31-60 Days]), "61-90 Days" = Sum([61-90 Days]),     
"91-120 Days" = Sum([91-120 Days]), ">120 Days" = Sum([>120 Days]),  
"ChequeInHand"=Sum(chequeInHand) From (    
Select "CUCT" = #temp1.CustomerID + Char(15) + Cast(#temp4.Parent As nvarchar),     
"ParentCatID" = #temp4.CatID,    
"ParentCatName" = #temp4.Parent,    
"CustomerID" = #temp1.CustomerID,       
"Forum Code"=(Select AlternateCode from Customer where CustomerId=#temp1.CustomerID),      
--"Beat Name"=dbo.fn_GetBeatDescForCus(#temp1.CustomerID),      
"Beat Name"= (Select [Description] from Beat where BeatID = Customer.DefaultBeatID),  
"Customer Type"=(Select Customer_Channel.ChannelDesc      
   From Customer,Customer_Channel      
   Where Customer.ChannelType=Customer_Channel.ChannelType      
   and Customer.Customerid=#temp1.CustomerID),      

"Channel Type" = Case IsNull(olcm.[Channel Type], '') 
				 When '' Then 
					@TOBEDEFINED
				 Else 
				 	olcm.[Channel Type]
				 End,

"Outlet Type" = Case IsNull(olcm.[Outlet Type], '') 
				When '' Then 
					@TOBEDEFINED
				Else 
					olcm.[Outlet Type]
				End,

"Loyalty Program" = Case IsNull(olcm.[Loyalty Program], '') 
				    When '' Then 
						@TOBEDEFINED
				    Else 
						olcm.[Loyalty Program] 
				    End,

"Credit Term"=dbo.fn_GetCreditTermForCus(#temp1.CustomerID),      
"Customer" = Customer.Company_Name,     
"Category" = #temp4.Parent, --#temp1.CategoryName,     
"No of Docs" = 0,  
"Not Over Due" = NotOverDue,    
"Over Due" = OverDue,    
"Outstanding Value" = OutstandingValue,      
"1-7 Days" = OnetoSeven,      
"8-10 Days" = EighttoTen,      
"11-14 Days" = EleventoFourteen,      
"15-21 Days" = FifteentoTwentyOne,      
"22-30 Days" = TwentyTwotoThirty,      
"<30 Days" = LessthanThirty,      
"31-60 Days" = ThirtyOnetoSixty,      
"61-90 Days" = SixtyOnetoNinety,      
"91-120 Days" = NinetyonetoOneTwenty,      
">120 Days" = MorethanOneTwenty,  
"ChequeInHand"=ChequeInHand    
From #temp1
inner join  Customer on #temp1.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID      
left outer join #temp4 on #temp1.CategoryID = #temp4.LeafID  
 right outer join #OLClassMapping olcm on olcm.CustomerID = Customer.CustomerID    
) cc1    
Group By [CUCT], [CustomerID], [Forum Code], [Beat Name], 
[Customer Type], [Channel Type] , [Outlet Type] , [Loyalty Program], [Credit Term],     
[Customer], [Category], [No of Docs]    
    

    
Insert InTo #temp7 Select CustomerID, Category, 0 From #temp6    
    
--select * from #temp6    
-- select * from #temp7    
Declare @Count1 Int    
Declare @Inc1 Int    
Declare @CustID nVarchar(255)    
Declare @Cat nVarChar(255)    
Set @Inc1 = 1    
Select @Count1 = Count(*) From #temp7    
set @continue = 1    
  
Delete #temp3    
    
While @Inc1 <= @Count1    
Begin    
Select @CustID = CustID, @Cat = Cat From #temp7    
Where IDS = @Inc1    
Insert InTo #temp3 Select IsNull((select categoryid from Itemcategories where     
category_name = @cat), 0), 0     
--Select @TCat = CatID From #temp2 Where IDS = @Inc    
While @Continue > 0        
Begin        
 Declare Parent Cursor Keyset For        
 Select CatID From #temp3  Where Status = 0        
 Open Parent        
 Fetch From Parent Into @CategoryID        
 While @@Fetch_Status = 0        
 Begin        
    
  Insert into #temp3    
  Select CategoryID, 0 From ItemCategories         
  Where ParentID = @CategoryID        
    
  If @@RowCount > 0         
   Update #temp3 Set Status = 1 Where CatID = @CategoryID        
  Else        
   Update #temp3 Set Status = 2 Where CatID = @CategoryID        
  Fetch Next From Parent Into @CategoryID        
 End        
 Close Parent        
 DeAllocate Parent        
 Select @Continue = Count(*) From #temp3 Where Status = 0        
End        
Delete #temp3 Where Status not in  (0, 2)        
Insert InTo #temp8 Select @Inc1, @CustID, @Cat, CatID    
From #temp3    
Delete #temp3    
Set @Continue = 1    
Set @Inc1 = @Inc1 + 1    
End    
    
  
Select CUCT, CustomerID, ForumCode, BeatName, [Customer Type], [Channel Type] , [Outlet Type] , [Loyalty Program], 
CreditTerm,     
Customer, Category, NoofDocs = IsNull((Select Count(Distinct ids.InvoiceID) From InvoiceAbstract ia, InvoiceDetail ids,     
Items its, Itemcategories itc Where   
ia.InvoiceID = ids.InvoiceID And     
ids.product_code = its.product_code and     
its.categoryid = itc.categoryid And     
itc.categoryid In (select LeafID from #temp8 where Cat = #temp6.Category And CustID = #temp6.CustomerID)    
And ia.CustomerID = #temp6.CustomerID And     
ia.Balance >= 0 And ia.InvoiceDate Between @FromDate And @ToDate), 0),    
NotOverDue, OverDue, [ChequeInHand] as "Cheque In Hand",OutstandingValue,     
[1-7 Days], [8-10 Days], [11-14 Days], [15-21 Days], [22-30 Days],     
[<30 Days], [31-60 Days], [61-90 Days], [91-120 Days], [>120 Days] From #temp6     
Where 
OutstandingValue + ChequeinHand > 0
    
drop table #temp1    
drop table #temp2    
drop table #temp3    
drop table #temp4    
drop table #temp5    
drop table #temp6    
drop table #temp7    
drop table #temp8    
drop table #tmpCust      
drop table #tempCategory      
