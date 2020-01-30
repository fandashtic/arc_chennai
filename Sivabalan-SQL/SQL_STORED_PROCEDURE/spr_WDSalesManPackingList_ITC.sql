Create PROCEDURE spr_WDSalesManPackingList_ITC(@SALESMAN nvarchar(2550),    
       @DocPrefix nVarChar(20),   
       @FromNo nvarchar(510),    
       @ToNo nvarchar(510),    
       @FromDate datetime,    
       @ToDate datetime,
       @UOM nVarChar(255))    
AS    
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Declare @MLOthers NVarchar(50)    
Set @MLOthers = dbo.LookupDictionaryItem(N'Others', Default)    

Create Table #FList(SFT nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Salesman Name] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Sales Value (%c)] Decimal(18, 6), 
[Sch Disc] Decimal(18, 6), 
[Discount] Decimal(18, 6), 
[Tax] Decimal(18, 6), 
[No of Invoices] Int,
[Invoices] Varchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Document Reference No] Varchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)
    
Create table #tmpSalesMan(SalesManName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @SALESMAN='%'       
   Insert into #tmpSalesMan select Salesman_Name from Salesman      
Else      
   Insert into #tmpSalesMan select * from dbo.sp_SplitIn2Rows(@SALESMAN,@Delimeter)      
    
IF @FROMNO = '%' SET @FROMNO = '0'    
IF @TONO = '%' SET @TONO = '2147483647'    
    
IF @SALESMAN = '%'    
BEGIN    
 If @DocPrefix ='%'  
 Begin  
Insert InTo #FList
  Select "SFT" =  Cast(InvoiceAbstract.SalesmanID as nvarchar) + ';' + Cast(@FROMNO as nvarchar) + ';'     
   + Cast(@TONO as nvarchar) + ';%', 
   "Salesman Name" = IsNull(Salesman.Salesman_Name, @MLOthers),    
   "Sales Value (%c)" = (NetValue - IsNull(Freight, 0)),     
------------------------------------------------------------------------------------------
   "Sch Disc" = (Select Sum(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0))      
  + sum((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))) 
 *  IsNull(InvoiceAbstract.SchemeDiscountPercentage, 0) / 100
  From InvoiceDetail IDT
  Where IDT.InvoiceID = InvoiceAbstract.InvoiceID),      


-- IsNull((Select Sum(IDT.SchemeDiscAmount + IDT.SplCatDiscAmount) 
-- 	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),

   "Discount" = (Select Sum(IsNull(IDT.DiscountValue, 0) - (IsNull(IDT.SchemeDiscAmount, 0) 
 + IsNull(IDT.SplCatDiscAmount, 0)))      
  + Sum(IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))  
* (Cast((IsNull(InvoiceAbstract.DiscountPercentage, 0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage, 0)) As Decimal(18, 6)) / 100)
  + Sum((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))) 
* IsNull(InvoiceAbstract.AdditionalDiscount, 0) / 100 From InvoiceDetail IDT 
  Where IDT.InvoiceID = InvoiceAbstract.InvoiceID),        


-- IsNull((Select Sum(IsNull(IDT.DiscountValue, 0) - 
-- 	(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0)))
-- 	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),

-- Sum(IsNull(IDT.DiscountValue, 0) - 
-- 	(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0))),
   "Tax" = IsNull((Select Sum(IsNull(IDT.STPayable, 0) + IsNull(IDT.CSTPayable, 0))
	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),

--Sum(IsNull(IDT.STPayable, 0) + IsNull(IDT.CSTPayable, 0)),

--  (IsNull(IDT.SchemeDiscAmount, 0)), (IsNull(IDT.SplCatDiscAmount, 0)),
--  (IsNull(IDT.DiscountValue, 0) - 
--  (IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0))),
--  (IsNull(IDT.STPayable, 0) + IsNull(IDT.CSTPayable, 0)),

-------------------------------------------------------------------------------------------

   "No of Invoices" = (InvoiceAbstract.InvoiceID),     
   "Invoices" = dbo.GetInvoicesForSalesman_ITC(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO),   
   "Document Reference No" = dbo.GetDocReferencesForSalesman_ITC(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO, @DocPrefix)    
--InTo #FList
  From InvoiceAbstract
  Left Outer Join Salesman On  InvoiceAbstract.SalesmanID = Salesman.SalesmanID 
  Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And    
   (InvoiceAbstract.Status & 128) = 0 And     
   InvoiceAbstract.InvoiceType in (1, 3) And    
   Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And    
   dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)    
--   Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name
 End  
 Else  
 Begin  
Insert InTo #FList
  Select  Cast(InvoiceAbstract.SalesmanID as nvarchar) + ';' + Cast(@FROMNO as nvarchar) + ';'     
   + Cast(@TONO as nvarchar) + ';' + Cast(@DocPrefix As nVarchar), "Salesman Name" = IsNull(Salesman.Salesman_Name, @MLOthers),    
   "Sales Value (%c)" = (NetValue - IsNull(Freight, 0)),     
---------------------------------------------------------------------------------------
   "Sch Disc" = (Select Sum(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0))      
  + sum((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))) 
 *  IsNull(InvoiceAbstract.SchemeDiscountPercentage, 0) / 100
  From InvoiceDetail IDT
  Where IDT.InvoiceID = InvoiceAbstract.InvoiceID),      


-- IsNull((Select Sum(IDT.SchemeDiscAmount + IDT.SplCatDiscAmount) 
-- 	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),

   "Discount" = (Select Sum(IsNull(IDT.DiscountValue, 0) - (IsNull(IDT.SchemeDiscAmount, 0) 
 + IsNull(IDT.SplCatDiscAmount, 0)))      
  + Sum(IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))  
* ((IsNull(InvoiceAbstract.DiscountPercentage, 0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage, 0)) / 100)
  + Sum((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))) 
* IsNull(InvoiceAbstract.AdditionalDiscount, 0) / 100 From InvoiceDetail IDT 
  Where IDT.InvoiceID = InvoiceAbstract.InvoiceID),        


-- IsNull((Select Sum(IsNull(IDT.DiscountValue, 0) - 
-- 	(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0)))
-- 	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),

-- Sum(IsNull(IDT.DiscountValue, 0) - 
-- 	(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0))),
   "Tax" = IsNull((Select Sum(IsNull(IDT.STPayable, 0) + IsNull(IDT.CSTPayable, 0))
	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),

---------------------------------------------------------------------------------------
   "Total Invoices" = (InvoiceID),     
   "Invoices" = dbo.GetInvoicesForSalesman_ITC(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO),  
  "Document Reference No" = dbo.GetDocReferencesForSalesman_ITC(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO, @DocPrefix)    
--InTo #FList
  From InvoiceAbstract
  Left Outer Join Salesman  On InvoiceAbstract.SalesmanID = Salesman.SalesmanID 
  Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And    
   (InvoiceAbstract.Status & 128) = 0 And     
   InvoiceAbstract.InvoiceType in (1, 3) And    
   Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And    
   dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)  And  
   InvoiceAbstract.DocSerialType = @DocPrefix  
--   Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name    
 End  
END    
ELSE    
BEGIN    
 If @DocPrefix ='%'  
 Begin  
Insert InTo #FList
  Select  Cast(InvoiceAbstract.SalesmanID as nvarchar) + ';' + Cast(@FROMNO as nvarchar) + ';'     
   + Cast(@TONO as nvarchar) + ';%', "Salesman Name" = IsNull(Salesman.Salesman_Name, @MLOthers),    
  "Sales Value (%c)" = (NetValue - IsNull(Freight, 0)),     
-----------------------------------------------------------------------

   "Sch Disc" = (Select Sum(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0))      
  + sum((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))) 
 *  IsNull(InvoiceAbstract.SchemeDiscountPercentage, 0) / 100
  From InvoiceDetail IDT
  Where IDT.InvoiceID = InvoiceAbstract.InvoiceID),      


-- IsNull((Select Sum(IDT.SchemeDiscAmount + IDT.SplCatDiscAmount) 
-- 	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),

   "Discount" = (Select Sum(IsNull(IDT.DiscountValue, 0) - (IsNull(IDT.SchemeDiscAmount, 0) 
 + IsNull(IDT.SplCatDiscAmount, 0)))      
  + Sum(IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))  
* ((IsNull(InvoiceAbstract.DiscountPercentage, 0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage, 0)) / 100)
  + Sum((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))) 
* IsNull(InvoiceAbstract.AdditionalDiscount, 0) / 100 From InvoiceDetail IDT 
  Where IDT.InvoiceID = InvoiceAbstract.InvoiceID),        

--    "Sch Disc" = IsNull((Select Sum(IDT.SchemeDiscAmount + IDT.SplCatDiscAmount) 
-- 	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),
--    "Discount" = IsNull((Select Sum(IsNull(IDT.DiscountValue, 0) - 
-- 	(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0)))
-- 	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),

-- Sum(IsNull(IDT.DiscountValue, 0) - 
-- 	(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0))),
   "Tax" = IsNull((Select Sum(IsNull(IDT.STPayable, 0) + IsNull(IDT.CSTPayable, 0))
	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),

-----------------------------------------------------------------------
   "Total Invoices" = (InvoiceID),     
   "Invoices" = dbo.GetInvoicesForSalesman_ITC(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO),    
  "Document Reference No" = dbo.GetDocReferencesForSalesman_ITC(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO, @DocPrefix)    
--InTo #FList
  From InvoiceAbstract, Salesman    
  Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And    
   (InvoiceAbstract.Status & 128) = 0 And     
   InvoiceAbstract.InvoiceType in (1, 3) And    
   InvoiceAbstract.SalesmanID = Salesman.SalesmanID And    
   Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And    
   dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)
--   Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name    
 End  
 Else  
 Begin  
Insert InTo #FList
  Select  Cast(InvoiceAbstract.SalesmanID as nvarchar) + ';' + Cast(@FROMNO as nvarchar) + ';'     
   + Cast(@TONO as nvarchar) + ';' + Cast(@DocPrefix As nVarchar) , "Salesman Name" = IsNull(Salesman.Salesman_Name, @MLOthers),    
   "Sales Value (%c)" = (NetValue - IsNull(Freight, 0)),     
-----------------------------------------------------------------------
   "Sch Disc" = (Select Sum(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0))      
  + sum((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))) 
 *  IsNull(InvoiceAbstract.SchemeDiscountPercentage, 0) / 100
  From InvoiceDetail IDT
  Where IDT.InvoiceID = InvoiceAbstract.InvoiceID),      


-- IsNull((Select Sum(IDT.SchemeDiscAmount + IDT.SplCatDiscAmount) 
-- 	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),

   "Discount" = (Select Sum(IsNull(IDT.DiscountValue, 0) - (IsNull(IDT.SchemeDiscAmount, 0) 
 + IsNull(IDT.SplCatDiscAmount, 0)))      
  + Sum(IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))  
* ((IsNull(InvoiceAbstract.DiscountPercentage, 0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage, 0)) / 100)
  + Sum((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))) 
* IsNull(InvoiceAbstract.AdditionalDiscount, 0) / 100 From InvoiceDetail IDT 
  Where IDT.InvoiceID = InvoiceAbstract.InvoiceID),        

--    "Sch Disc" = IsNull((Select Sum(IDT.SchemeDiscAmount + IDT.SplCatDiscAmount) 
-- 	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),
--    "Discount" = IsNull((Select Sum(IsNull(IDT.DiscountValue, 0) - 
-- 	(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0)))
-- 	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),

-- Sum(IsNull(IDT.DiscountValue, 0) - 
-- 	(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0))),
   "Tax" = IsNull((Select Sum(IsNull(IDT.STPayable, 0) + IsNull(IDT.CSTPayable, 0))
	From InvoiceDetail IDT Where IDT.InvoiceId = InvoiceAbstract.InvoiceID), 0),

-----------------------------------------------------------------------

   "Total Invoices" = (InvoiceID),     
   "Invoices" = dbo.GetInvoicesForSalesman_ITC(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO),    
  "Document Reference No" = dbo.GetDocReferencesForSalesman_ITC(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO, @DocPrefix)    
--InTo #FList
  From InvoiceAbstract, Salesman    
  Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And    
  (InvoiceAbstract.Status & 128) = 0 And     
  InvoiceAbstract.InvoiceType in (1, 3) And    
  InvoiceAbstract.SalesmanID = Salesman.SalesmanID And    
  Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And    
  dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO) And    
  InvoiceAbstract.DocSerialType = @DocPrefix    
--   Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name    
 End  
END    

Select SFT, [Salesman Name], "Sales Value (%c)" = Sum([Sales Value (%c)]), 
"Sch Disc" = Sum([Sch Disc]), "Discount" = Sum([Discount]), 
"Tax" = Sum([Tax]), "No of Invoices" = Count([No of Invoices]), 
"Invoice Ref" = [Invoices],  
"Doc Reference" = [Document Reference No] from #FList
Group By SFT, [Salesman Name], [Invoices], [Document Reference No]

Drop table #tmpSalesMan    
Drop table #FList    
  
