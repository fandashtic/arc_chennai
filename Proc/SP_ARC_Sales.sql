--exec SP_ARC_Sales '2020-02-27 00:00:00','2020-02-27 23:59:59','%','Base UOM','%','No','%'
Exec ARC_Insert_ReportData 620, 'Sales', 1, 'SP_ARC_Sales', 'Click to view Sales', 561, 639, 1, 2, 0, 621, 200, 0, 4, 0, 170, 'No'
GO
--Exec ARC_GetUnusedReportId 
IF EXISTS(SELECT * 
          FROM   sys.objects 
          WHERE  NAME = N'SP_ARC_Sales') 
  BEGIN 
      DROP PROC sp_arc_sales 
  END 

go 

CREATE PROCEDURE [dbo].Sp_arc_sales (@FROMDATE     DATETIME, 
                                     @TODATE       DATETIME, 
                                     @DocType      NVARCHAR(100), 
                                     @UOMDesc      NVARCHAR(30), 
                                     @Salesman     NVARCHAR(4000), 
                                     @TaxCompBrkUp NVARCHAR(10), 
                                     @CustName     NVARCHAR(2250)) 
AS 
  BEGIN 
      DECLARE @INV AS NVARCHAR(50) 
      DECLARE @CASH AS NVARCHAR(50) 
      DECLARE @CREDIT AS NVARCHAR(50) 
      DECLARE @CHEQUE AS NVARCHAR(50) 
      DECLARE @DD AS NVARCHAR(50) 
      DECLARE @CS_TaxCode INT 

      SELECT @CASH = dbo.Lookupdictionaryitem(N'Cash', DEFAULT) 

      SELECT @CREDIT = dbo.Lookupdictionaryitem(N'Credit', DEFAULT) 

      SELECT @CHEQUE = dbo.Lookupdictionaryitem(N'Cheque', DEFAULT) 

      SELECT @DD = dbo.Lookupdictionaryitem(N'DD', DEFAULT) 

      SELECT @INV = prefix 
      FROM   voucherprefix WITH (NOLOCK)
      WHERE  tranid = N'INVOICE' 

      DECLARE @Delimiter AS CHAR(1) 

      SET @Delimiter=Char(15) 

      DECLARE @InvoiceID INT 
      DECLARE @Tax_Code INT 
      DECLARE @isColExist INT 
      DECLARE @Tax_Description NVARCHAR(510) 
      DECLARE @Tax_Comp_Desc NVARCHAR(510) 
      DECLARE @Tax_Comp_Code INT 
      DECLARE @ColName NVARCHAR(510) 
      DECLARE @SQL NVARCHAR(4000) 
      DECLARE @LTPrefix NVARCHAR(25) 
      DECLARE @CTPrefix NVARCHAR(25) 
      DECLARE @IntraPrefix NVARCHAR(25) 
      DECLARE @InterPrefix NVARCHAR(25) 

      SET @LTPrefix = 'LST' 
      SET @CTPrefix = 'CST' 
      SET @IntraPrefix = 'Intra' 
      SET @InterPrefix = 'Inter' 

      CREATE TABLE #taxlog 
        ( 
           tax_code INT, 
           lst_flag INT 
        ) 

      CREATE TABLE #tempsalesman 
        ( 
           salesman_name NVARCHAR(510) COLLATE sql_latin1_general_cp1_ci_as 
        ) 

      DECLARE @Delimeter AS CHAR(1) 

      SET @Delimeter=Char(15) 

      DECLARE @tmpCustId TABLE 
        ( 
           customerid NVARCHAR(255) COLLATE sql_latin1_general_cp1_ci_as 
        ) 
      DECLARE @tmpCustName TABLE 
        ( 
           customername NVARCHAR(255) COLLATE sql_latin1_general_cp1_ci_as 
        ) 

      IF @CustName = '%' 
        INSERT INTO @tmpCustId 
        SELECT customerid 
        FROM   customer  WITH (NOLOCK)
        WHERE  customerid <> '0' 
               AND customercategory NOT IN ( 4, 5 ) 
      ELSE 
        BEGIN 
            INSERT INTO @tmpCustName 
            SELECT * 
            FROM   dbo.Sp_splitin2rows(@CustName, @Delimeter) 

            INSERT INTO @tmpCustId 
            SELECT customerid 
            FROM   customer  WITH (NOLOCK)
            WHERE  customerid IN(SELECT * 
                                 FROM   @tmpCustName) 
                   AND customercategory NOT IN ( 4, 5 ) 
        END 

      IF @Salesman = '%' 
        INSERT INTO #tempsalesman 
        SELECT salesman_name 
        FROM   salesman  WITH (NOLOCK)
      ELSE 
        INSERT INTO #tempsalesman 
        SELECT * 
        FROM   dbo.Sp_splitin2rows(@Salesman, @Delimiter) 

      IF @TaxCompBrkUp <> 'Yes' 
        BEGIN 
            SELECT invoiceid, 
                   "InvoiceID" = CASE Isnull(gstflag, 0) 
                                   WHEN 0 THEN @INV + Cast(documentid AS 
                                               NVARCHAR) 
                                   ELSE Isnull(invoiceabstract.gstfulldocid, '') 
                                 END, 
				   "Order Number"= SONumber,
				   "Order Date"= (SELECT TOP 1 SODate from SOAbstract WITH (NOLOCK) WHERE SONumber = invoiceabstract.SONumber),
				   "Order Value"= (SELECT TOP 1 Value from SOAbstract WITH (NOLOCK) WHERE SONumber = invoiceabstract.SONumber),
				   --"Doc Ref" = invoiceabstract.docreference, 
                   "Invoice Date" = invoicedate, 
                   "Payment Mode" = CASE Isnull(paymentmode, 0) 
                                      WHEN 0 THEN @Credit 
                                      WHEN 1 THEN @Cash 
                                      WHEN 2 THEN @Cheque 
                                      WHEN 3 THEN @DD 
                                      ELSE @Credit 
                                    END, 
                   --"Payment Date" = paymentdate, 
                   "Credit Term" = creditterm.description, 
                   "CustomerID" = customer.customerid, 
                   "Customer" = customer.company_name, 
				   "Customer Category" = dbo.fn_Arc_GetCustomerCategory(customer.CustomerId),
				   "Customer Group" = dbo.fn_Arc_GetCustomerGroup(customer.CustomerId),				    
                   --"AlternateCustomerName" = Isnull(invoiceabstract.alternatecgcustomername, ''), 
                   ----"Billing Address" =  Isnull(invoiceabstract.billingaddress, ''), 
                   --"Forum Code" = customer.alternatecode, 
                   --"Goods Value" = goodsvalue, 
                   --"Product Discount" = productdiscount, 
                   --"Trade Discount%" = Cast(Cast(discountpercentage AS DECIMAL( 
                   --                    18, 
                   --                    6)) 
                   --                    AS 
                   --                    NVARCHAR) 
                   --                    + N'%', 
                   --"Trade Discount" = Cast(invoiceabstract.goodsvalue * 
                   --                        ( discountpercentage / 100 ) AS 
                   --                        DECIMAL(18, 6) 
                   --                   ), 
                   --"Addl Discount%" = Cast(additionaldiscount AS NVARCHAR) 
                   --                   + N'%', 
                   --"Addl Discount" = Isnull(addldiscountvalue, 0), 
                   --freight, 
                   "Net Value" = netvalue, 
--                   "Net Volume" = Cast(( CASE 
--                                           WHEN @UOMdesc = N'UOM1' THEN (SELECT 
--Sum( 
--dbo.Sp_get_reportingqty(quantity, CASE 
--WHEN 
--                               Isnull 
--(items.uom1_conversion, 0) = 
--                               0 
--THEN 1 
--ELSE items.uom1_conversion 
--                                  END 
--)) 
-- FROM   items WITH (NOLOCK), 
--        invoicedetail WITH (NOLOCK) 
-- WHERE  items.product_code = 
--        invoicedetail.product_code 
--        AND invoiceabstract.invoiceid = 
--            invoicedetail.invoiceid) 
--WHEN @UOMdesc = N'UOM2' THEN (SELECT 
--Sum( 
--dbo.Sp_get_reportingqty(quantity, CASE 
--WHEN 
--                               Isnull 
--(items.uom2_conversion, 0) = 
--                               0 
--THEN 1 
--ELSE items.uom2_conversion 
--                                  END 
--)) 
-- FROM   items WITH (NOLOCK), 
--        invoicedetail WITH (NOLOCK) 
-- WHERE  items.product_code = 
--        invoicedetail.product_code 
--        AND invoiceabstract.invoiceid = 
--            invoicedetail.invoiceid) 
--ELSE (SELECT Sum(quantity) 
--      FROM   items WITH (NOLOCK), 
--             invoicedetail WITH (NOLOCK) 
--      WHERE  items.product_code = 
--             invoicedetail.product_code 
--             AND 
--     invoiceabstract.invoiceid 
--     = 
--     invoicedetail.invoiceid) 
--END ) AS NVARCHAR), 
--"Adj Ref" = Isnull(invoiceabstract.adjref, N''), 
--"Adjusted Amount" = Isnull(invoiceabstract.adjustedamount, 0), 
--"Balance" = invoiceabstract.balance, 
--"Collected Amount" = netvalue - 
--Isnull(invoiceabstract.adjustedamount, 0) 
--- 
--Isnull( 
--invoiceabstract.balance, 
--0) 
--+ 
--Isnull( 
--roundoffamount, 0), 
--"Branch" = clientinformation.description, 
"Beat" = beat.description, 
"Salesman" = salesman.salesman_name, 
"Salesman Category" = dbo.fn_Arc_GetSalesmanCategory(salesman.SalesmanID),
--"Reference" = CASE status & 15 WHEN 1 THEN '' WHEN 2 THEN '' WHEN 4 
--THEN 
--'' WHEN 
--8 THEN '' END 
--+ Cast(newreference AS NVARCHAR), 
--"Round Off" = roundoffamount, 
"Van Number" = docserialtype, 
"COLLECTION DAY" = dbo.fn_Arc_GetBeatDayByBeatName(beat.description),
--"Total TaxSuffered Value" = totaltaxsuffered, 
--"Total SalesTax Value" = totaltaxapplicable, 
"GSTIN OF Outlet" = invoiceabstract.gstin 
--"OutletStateCode" = tostatecode 
FROM   invoiceabstract  WITH (NOLOCK)
INNER JOIN customer 
ON invoiceabstract.customerid = customer.customerid 
LEFT OUTER JOIN creditterm 
ON invoiceabstract.creditterm = creditterm.creditid 
LEFT OUTER JOIN clientinformation 
ON invoiceabstract.clientid = 
clientinformation.clientid 
LEFT OUTER JOIN beat 
ON invoiceabstract.beatid = beat.beatid 
INNER JOIN salesman 
ON invoiceabstract.salesmanid = salesman.salesmanid 
WHERE  invoicetype IN ( 1, 3 ) 
AND invoicedate BETWEEN @FROMDATE AND @TODATE 
AND ( invoiceabstract.status & 128 ) = 0 
AND invoiceabstract.docserialtype LIKE @DocType 
AND salesman.salesman_name IN (SELECT salesman_name 
FROM   #tempsalesman WITH (NOLOCK)) 
AND invoiceabstract.customerid IN (SELECT * 
FROM   @tmpCustId) 
ORDER  BY documentid 
END 
ELSE 
BEGIN 
SELECT * 
INTO   #tmpmaindata 
FROM   (SELECT TOP 100 PERCENT invoiceid AS InvoiceID1, 
"InvoiceID" = CASE Isnull(gstflag, 0) 
WHEN 0 THEN @INV + Cast( 
documentid AS 
NVARCHAR) 
ELSE 
Isnull(invoiceabstract.gstfulldocid, '') 
END, 
"Order Number"= SONumber,
				   "Order Date"= (SELECT TOP 1 SODate from SOAbstract WITH (NOLOCK) WHERE SONumber = invoiceabstract.SONumber),
				   "Order Value"= (SELECT TOP 1 Value from SOAbstract WITH (NOLOCK) WHERE SONumber = invoiceabstract.SONumber),
--"Doc Ref" = invoiceabstract.docreference, 
"Invoice Date" = invoicedate, 
"Payment Mode" = CASE 
Isnull(paymentmode, 0) 
WHEN 0 THEN @Credit 
WHEN 1 THEN @Cash 
WHEN 2 THEN @Cheque 
WHEN 3 THEN @DD 
ELSE @Credit 
END, 
"Payment Date" = paymentdate, 
"Credit Term" = creditterm.description, 
"CustomerID" = customer.customerid, 
"Customer" = customer.company_name, 
"Customer Category" = dbo.fn_Arc_GetCustomerCategory(customer.CustomerId),
"Customer Group" = dbo.fn_Arc_GetCustomerGroup(customer.CustomerId),				    
--"AlternateCustomerName" = 
--Isnull( 
--invoiceabstract.alternatecgcustomername, ''), 
--"Billing Address" = Isnull( 
--invoiceabstract.billingaddress, ''), 
--"Forum Code" = customer.alternatecode, 
--"Goods Value" = goodsvalue, 
--"Product Discount" = productdiscount, 
--"Trade Discount%" = 
--Cast(Cast(discountpercentage 
--AS 
--DECIMAL(18, 6)) AS NVARCHAR) 
--+ N'%', 
--"Trade Discount" = Cast( 
--invoiceabstract.goodsvalue * 
--( discountpercentage / 100 ) AS 
--DECIMAL(18, 6) 
--), 
--"Addl Discount%" = Cast(additionaldiscount 
--AS 
--NVARCHAR) 
--+ N'%', 
--"Addl Discount" = Isnull(addldiscountvalue, 
--0 
--), 
--freight, 
--"Net Value" = netvalue, 
--"Net Volume" = Cast(( CASE 
--WHEN 
--@UOMdesc = N'UOM1' 
--THEN ( 
--SELECT Sum( 
--dbo.Sp_get_reportingqty(quantity, CASE 
--WHEN 
--Isnull 
--(items.uom1_conversion, 0) = 
--0 
--THEN 1 
--ELSE items.uom1_conversion 
--END 
--)) 
--FROM   items WITH (NOLOCK), 
--invoicedetail  WITH (NOLOCK)
--WHERE  items.product_code = 
--invoicedetail.product_code 
--AND invoiceabstract.invoiceid = 
--invoicedetail.invoiceid) 
--WHEN @UOMdesc = N'UOM2' THEN (SELECT Sum( 
--dbo.Sp_get_reportingqty(quantity, CASE 
--WHEN 
--Isnull 
--(items.uom2_conversion, 0) = 
--0 
--THEN 1 
--ELSE items.uom2_conversion 
--END 
--)) 
--FROM   items WITH (NOLOCK), 
--invoicedetail  WITH (NOLOCK)
--WHERE  items.product_code = 
--invoicedetail.product_code 
--AND invoiceabstract.invoiceid = 
--invoicedetail.invoiceid) 
--ELSE (SELECT Sum(quantity) 
--FROM   items WITH (NOLOCK), 
--invoicedetail  WITH (NOLOCK)
--WHERE  items.product_code = 
--invoicedetail.product_code 
--AND invoiceabstract.invoiceid 
--= 
--invoicedetail.invoiceid) 
--END ) AS NVARCHAR), 
--"Adj Ref" = Isnull(invoiceabstract.adjref, 
--N''), 
--"Adjusted Amount" = Isnull( 
--invoiceabstract.adjustedamount, 0), 
--"Balance" = invoiceabstract.balance, 
--"Collected Amount" = netvalue - Isnull( 
--invoiceabstract.adjustedamount, 0) 
--- 
--Isnull( 
--invoiceabstract.balance, 0) + 
--Isnull( 
--roundoffamount, 0), 
--"Branch" = clientinformation.description, 
"Beat" = beat.description, 
"Salesman" = salesman.salesman_name, 
"Salesman Category" = dbo.fn_Arc_GetSalesmanCategory(salesman.SalesmanID),
--"Reference" = CASE status & 15 WHEN 1 THEN 
--'' 
--WHEN 2 
--THEN '' WHEN 4 THEN '' WHEN 
--8 THEN '' END 
--+ Cast(newreference AS 
--NVARCHAR 
--), 
--"Round Off" = roundoffamount, 
"Van Number" = docserialtype ,
"COLLECTION DAY" = dbo.fn_Arc_GetBeatDayByBeatName(beat.description),
--"Total TaxSuffered Value" = 
--totaltaxsuffered, 
--"Total SalesTax Value" = totaltaxapplicable 
--, 
"GSTIN OF Outlet" = invoiceabstract.gstin 
--"OutletStateCode" = tostatecode 
FROM   invoiceabstract  WITH (NOLOCK)
INNER JOIN customer  WITH (NOLOCK)
ON invoiceabstract.customerid = customer.customerid 
LEFT OUTER JOIN creditterm 
ON invoiceabstract.creditterm = 
creditterm.creditid 
LEFT OUTER JOIN clientinformation 
ON invoiceabstract.clientid = 
clientinformation.clientid 
LEFT OUTER JOIN beat 
ON invoiceabstract.beatid = beat.beatid 
INNER JOIN salesman 
ON invoiceabstract.salesmanid = salesman.salesmanid 
WHERE  invoicetype IN ( 1, 3 ) 
AND invoicedate BETWEEN @FROMDATE AND @TODATE 
AND ( invoiceabstract.status & 128 ) = 0 
AND invoiceabstract.docserialtype LIKE @DocType 
AND salesman.salesman_name IN (SELECT salesman_name 
FROM   #tempsalesman WITH (NOLOCK)) 
AND invoiceabstract.customerid IN (SELECT * 
FROM   @tmpCustId) 
ORDER  BY documentid) tmp 

--for each invoice get the tax detail 
DECLARE cr_invoice CURSOR static FOR 
SELECT invoiceid1 
FROM   #tmpmaindata  WITH (NOLOCK)

OPEN cr_invoice 

FETCH next FROM cr_invoice INTO @InvoiceID 

WHILE @@Fetch_Status = 0 
BEGIN 
--Get the Taxes Involved in the invoices 
DECLARE cr_taxes CURSOR FOR 
SELECT DISTINCT tax.tax_code, 
tax.tax_description, 
tax.cs_taxcode 
FROM   invoicedetail, 
tax 
WHERE  invoicedetail.invoiceid = @InvoiceID 
AND invoicedetail.taxid = tax.tax_code 

OPEN cr_taxes 

FETCH next FROM cr_taxes INTO @Tax_Code, @Tax_Description, 
@CS_TaxCode 

WHILE @@Fetch_Status = 0 
BEGIN 
--Log the Tax into a table to find whether tax column already created 
--If not created already add the tax and component columns 
SET @isColExist = 0 

IF NOT EXISTS(SELECT * 
FROM   #taxlog 
WHERE  tax_code = @Tax_code 
AND lst_flag = 1) 
SET @isColExist = 1 

INSERT INTO #taxlog 
VALUES      (@Tax_Code, 
1) 

--Create or update the LST Column for the tax 
IF( @CS_TaxCode > 0 ) 
SET @ColName = @IntraPrefix + N'_' + @Tax_Description 
ELSE 
SET @ColName = @LTPrefix + N'_' + @Tax_Description 

SET @SQL=N'Alter Table #tmpMainData Add [' 
+ @ColName + N'] decimal(18,6) default 0;' 

IF @isColExist = 1 
BEGIN 
EXEC(@SQL) 

SET @SQL = N'Update #tmpMainData set [' + @ColName 
+ N'] = 0;' 

EXEC(@SQL) 
END 

--Update LST Column for the tax for the InvoiceID 
SET @SQL = N'update #tmpMainData ' 
SET @SQL = @SQL + N'set [' + @ColName + N'] =' 
SET @SQL = @SQL + N'         (' 
SET @SQL = @SQL 
+ 
N'             select isnull(sum(InvoiceTaxComponents.Tax_Value),0) as TaxVal' 
SET @SQL = @SQL 
+ 
N'             from (select InvoiceID, TaxID, sum(isnull(STPayable,0)) as STPayable from InvoiceDetail WITH (NOLOCK) where InvoiceDetail.invoiceid = '
+ Cast(@InvoiceID AS NVARCHAR) 
+ 
' group by InvoiceID, TaxID) as InvoiceDetail, InvoiceTaxComponents ' 
SET @SQL = @SQL 
+ N'             where InvoiceDetail.invoiceid = ' 
+ Cast(@InvoiceID AS NVARCHAR) 
SET @SQL = @SQL 
+ N'                   and Tax_Code = ' 
+ Cast(@Tax_Code AS NVARCHAR) 
SET @SQL = @SQL 
+ N'                   and isnull(STPayable,0) > 0' 
SET @SQL = @SQL 
+ 
N'                   and InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID' 
SET @SQL = @SQL 
+ 
N'                   and InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code' 
SET @SQL = @SQL + N'         ) where InvoiceID1 = ' 
+ Cast(@InvoiceID AS NVARCHAR) 

EXEC(@SQL) 

--Create or update the LST Columns for the tax components 
DECLARE cr_txcomp CURSOR FOR 
SELECT DISTINCT taxcomponentdetail.taxcomponent_desc, 
taxcomponentdetail.taxcomponent_code 
FROM   invoicetaxcomponents WITH (NOLOCK), 
taxcomponentdetail WITH (NOLOCK) 
WHERE  invoiceid IN (SELECT invoiceid 
FROM   invoicedetail WITH (NOLOCK) 
WHERE  invoiceid IN (SELECT invoiceid1 
FROM   #tmpmaindata WITH (NOLOCK)) 
AND Isnull(stpayable, 0) <> 0) 
AND invoicetaxcomponents.tax_code = @Tax_code 
AND invoicetaxcomponents.tax_component_code = 
taxcomponentdetail.taxcomponent_code 
ORDER  BY taxcomponentdetail.taxcomponent_code 

OPEN cr_txcomp 

FETCH next FROM cr_txcomp INTO @Tax_Comp_Desc, @Tax_Comp_Code 

WHILE @@Fetch_Status = 0 
BEGIN 
IF( @CS_TaxCode > 0 ) 
SET @ColName = @IntraPrefix + N'_' + @Tax_Comp_Desc + N'_of_' 
+ @Tax_Description 
ELSE 
SET @ColName = @LTPrefix + N'_' + @Tax_Comp_Desc + N'_of_' 
+ @Tax_Description 

SET @SQL=N'Alter Table #tmpMainData Add [' 
+ @ColName + N'] decimal(18,6) default 0;' 

IF @isColExist = 1 
BEGIN 
EXEC(@SQL) 

SET @SQL = N'Update #tmpMainData set [' + @ColName 
+ N'] = 0;' 

EXEC(@SQL) 
END 

--Update LST Columns for the tax components  for the Tax 
SET @SQL = N'update #tmpMainData ' 
SET @SQL = @SQL + N'set [' + @ColName + N'] =' 
SET @SQL = @SQL + N'         (' 
SET @SQL = @SQL 
+ 
N'             select isnull(sum(InvoiceTaxComponents.Tax_Value),0) as TaxVal' 
SET @SQL = @SQL 
+ 
N'             from (select InvoiceID, TaxID, sum(isnull(STPayable,0)) as STPayable from InvoiceDetail WITH (NOLOCK) where InvoiceDetail.invoiceid = '
+ Cast(@InvoiceID AS NVARCHAR) 
+ 
' group by InvoiceID, TaxID) as InvoiceDetail, InvoiceTaxComponents ' 
SET @SQL = @SQL 
+ N'             where InvoiceDetail.invoiceid = ' 
+ Cast(@InvoiceID AS NVARCHAR) 
SET @SQL = @SQL 
+ N'                   and Tax_Code = ' 
+ Cast(@Tax_Code AS NVARCHAR) 
SET @SQL = @SQL 
+ N'                   and Tax_Component_Code = ' 
+ Cast(@Tax_Comp_Code AS NVARCHAR) 
SET @SQL = @SQL 
+ N'                   and isnull(STPayable,0) > 0' 
SET @SQL = @SQL 
+ 
N'                   and InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID' 
SET @SQL = @SQL 
+ 
N'                   and InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code' 
SET @SQL = @SQL + N'         ) where InvoiceID1 = ' 
+ Cast(@InvoiceID AS NVARCHAR) 

EXEC(@SQL) 

--                End 
FETCH next FROM cr_txcomp INTO @Tax_Comp_Desc, @Tax_Comp_Code 
END 

CLOSE cr_txcomp 

DEALLOCATE cr_txcomp 

--taxcomponent  End 
--Create or update the CST Column for the tax 
SET @isColExist = 0 

IF NOT EXISTS(SELECT * 
FROM   #taxlog  WITH (NOLOCK)
WHERE  tax_code = @Tax_code 
AND lst_flag = 0) 
SET @isColExist = 1 
INSERT INTO #taxlog 
VALUES      (@Tax_Code, 
0) 

IF( @CS_TaxCode > 0 ) 
SET @ColName = @InterPrefix + N'_' + @Tax_Description 
ELSE 
SET @ColName = @CTPrefix + N'_' + @Tax_Description 

SET @SQL=N'Alter Table #tmpMainData Add [' 
+ @ColName + N'] decimal(18,6) default 0;' 

IF @isColExist = 1 
BEGIN 
EXEC(@SQL) 

SET @SQL = N'Update #tmpMainData set [' + @ColName 
+ N'] = 0;' 

EXEC(@SQL) 
END 

--Update CST Column for the tax for the InvoiceID 
SET @SQL = N'update #tmpMainData ' 
SET @SQL = @SQL + N'set [' + @ColName + N'] =' 
SET @SQL = @SQL + N'         (' 
SET @SQL = @SQL 
+ 
N'             select isnull(sum(InvoiceTaxComponents.Tax_Value),0) as TaxVal' 
SET @SQL = @SQL 
+ 
N'             from (select InvoiceID, TaxID, sum(isnull(CSTPayable,0)) as CSTPayable from InvoiceDetail WITH (NOLOCK) where InvoiceDetail.invoiceid = '
+ Cast(@InvoiceID AS NVARCHAR) 
+ 
' group by InvoiceID, TaxID) as InvoiceDetail, InvoiceTaxComponents ' 
SET @SQL = @SQL 
+ N'             where InvoiceDetail.invoiceid = ' 
+ Cast(@InvoiceID AS NVARCHAR) 
SET @SQL = @SQL 
+ N'                   and Tax_Code = ' 
+ Cast(@Tax_Code AS NVARCHAR) 
SET @SQL = @SQL 
+ N'                   and isnull(CSTPayable,0) > 0' 
SET @SQL = @SQL 
+ 
N'                   and InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID' 
SET @SQL = @SQL 
+ 
N'                   and InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code' 
SET @SQL = @SQL + N'         ) where InvoiceID1 = ' 
+ Cast(@InvoiceID AS NVARCHAR) 

EXEC(@SQL) 

--Create or update the CST Columns for the tax components 
DECLARE cr_txcomp CURSOR FOR 
SELECT DISTINCT taxcomponentdetail.taxcomponent_desc, 
taxcomponentdetail.taxcomponent_code 
FROM   invoicetaxcomponents WITH (NOLOCK), 
taxcomponentdetail WITH (NOLOCK) 
WHERE  invoiceid IN (SELECT invoiceid 
FROM   invoicedetail WITH (NOLOCK) 
WHERE  invoiceid IN (SELECT invoiceid1 
FROM   #tmpmaindata WITH (NOLOCK)) 
AND Isnull(cstpayable, 0) <> 0) 
AND invoicetaxcomponents.tax_code = @Tax_code 
AND invoicetaxcomponents.tax_component_code = 
taxcomponentdetail.taxcomponent_code 
ORDER  BY taxcomponentdetail.taxcomponent_code 

OPEN cr_txcomp 

FETCH next FROM cr_txcomp INTO @Tax_Comp_Desc, @Tax_Comp_Code 

WHILE @@Fetch_Status = 0 
BEGIN 
IF( @CS_TaxCode > 0 ) 
SET @ColName = @InterPrefix + N'_' + @Tax_Comp_Desc + N'_of_' 
+ @Tax_Description 
ELSE 
SET @ColName = @CTPrefix + N'_' + @Tax_Comp_Desc + N'_of_' 
+ @Tax_Description 

SET @SQL=N'Alter Table #tmpMainData Add [' 
+ @ColName + N'] decimal(18,6) default 0;' 

IF @isColExist = 1 
BEGIN 
EXEC(@SQL) 

SET @SQL = N'Update #tmpMainData set [' + @ColName 
+ N'] = 0;' 

EXEC(@SQL) 
END 

--Update LST Columns for the tax components for the Tax 
SET @SQL = N'update #tmpMainData ' 
SET @SQL = @SQL + N'set [' + @ColName + N'] =' 
SET @SQL = @SQL + N'         (' 
SET @SQL = @SQL 
+ 
N'             select isnull(sum(InvoiceTaxComponents.Tax_Value),0) as TaxVal' 
SET @SQL = @SQL 
+ 
N'             from (select InvoiceID, TaxID, sum(isnull(CSTPayable,0)) as CSTPayable from InvoiceDetail WITH (NOLOCK) where InvoiceDetail.invoiceid = '
+ Cast(@InvoiceID AS NVARCHAR) 
+ 
' group by InvoiceID, TaxID) as InvoiceDetail, InvoiceTaxComponents ' 
SET @SQL = @SQL 
+ N'             where InvoiceDetail.invoiceid = ' 
+ Cast(@InvoiceID AS NVARCHAR) 
SET @SQL = @SQL 
+ N'                   and Tax_Code = ' 
+ Cast(@Tax_Code AS NVARCHAR) 
SET @SQL = @SQL 
+ N'                   and Tax_Component_Code = ' 
+ Cast(@Tax_Comp_Code AS NVARCHAR) 
SET @SQL = @SQL 
+ N'                   and isnull(CSTPayable,0) > 0' 
SET @SQL = @SQL 
+ 
N'                   and InvoiceDetail.InvoiceID = InvoiceTaxComponents.InvoiceID' 
SET @SQL = @SQL 
+ 
N'                   and InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code' 
SET @SQL = @SQL + N'         ) where InvoiceID1 = ' 
+ Cast(@InvoiceID AS NVARCHAR) 

EXEC(@SQL) 

--                    End 
FETCH next FROM cr_txcomp INTO @Tax_Comp_Desc, @Tax_Comp_Code 
END 

CLOSE cr_txcomp 

DEALLOCATE cr_txcomp 

-- End 
FETCH next FROM cr_taxes INTO @Tax_Code, @Tax_Description, @CS_TaxCode 
END 

CLOSE cr_taxes 

DEALLOCATE cr_taxes 

FETCH next FROM cr_invoice INTO @InvoiceID 
END 

CLOSE cr_invoice 

DEALLOCATE cr_invoice 

SELECT * 
FROM   #tmpmaindata  WITH (NOLOCK)

DROP TABLE #tempsalesman 

DROP TABLE #tmpmaindata 

DROP TABLE #taxlog 
END 
END 

go 