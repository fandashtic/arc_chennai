--exec spr_list_Customerwise_Invoicewise_Outstanding_ITC '2020-03-20 23:59:59','%','%'
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'Spr_list_customerwise_invoicewise_outstanding_itc')
BEGIN
	DROP PROC [Spr_list_customerwise_invoicewise_outstanding_itc]
END
GO
CREATE PROCEDURE [dbo].[Spr_list_customerwise_invoicewise_outstanding_itc] ( 
@ToDate      DATETIME, 
@Weekdays    NVARCHAR(50), 
@SalesPerson NVARCHAR(50)) 
AS 
    DECLARE @INV AS NVARCHAR(50) 

    SELECT @INV = prefix 
    FROM   voucherprefix 
    WHERE  tranid = N'INVOICE' 

    SELECT documentid, 
           documentdate, 
           status 
    INTO   #collections1 
    FROM   collections 
    WHERE  status IS NULL 
            OR status = 1 

    SELECT DISTINCT collectiondetail.originalid, 
                    "totalcollection"=Sum(collectiondetail.adjustedamount) 
    INTO   #tempba 
    FROM   collectiondetail, 
           #collections1 
    WHERE  collectiondetail.documenttype IN ( 4, 5 ) 
           AND collectiondetail.collectedamount IS NOT NULL 
           AND #collections1.documentdate <= @ToDate 
           AND #collections1.documentid = collectiondetail.collectionid 
    GROUP  BY collectiondetail.originalid 

    SELECT documentid, 
           "INVOI" = @INV + Cast(documentid AS NVARCHAR), 
           customerid, 
           docreference, 
           invoicedate, 
           "DayID"= Datepart (dw, invoicedate), 
           "BillValue"=netvalue + roundoffamount, 
           beatid, 
           salesmanid, 
           status, 
           "DueDate" = Datediff (dy, invoicedate, @ToDate) 
    INTO   #cus 
    FROM   invoiceabstract 
    WHERE  invoicetype IN ( 1, 3 ) 
           AND invoicedate <= @TODATE 
           AND ( invoiceabstract.status & 128 ) = 0 
           AND invoiceabstract.paymentmode != 1 
    ORDER  BY documentid 

    SELECT #cus.invoi, 
           #cus.billvalue, 
           Isnull(#tempba.totalcollection, 0.00) AS totalcollection 
    INTO   #cus2 
    FROM   #cus 
           LEFT OUTER JOIN #tempba 
                        ON #cus.invoi = #tempba.originalid 

    SELECT invoi, 
           billvalue, 
           totalcollection, 
           "Balance" = ( billvalue - totalcollection ) 
    INTO   #cus3 
    FROM   #cus2 

    SELECT documentid, 
           "CustomerID" = #cus.customerid, 
           "Customer Name" = customer.company_name, 
           "InvoiceID" = #cus.invoi, 
           "Doc Ref" = #cus.docreference, 
           "Document Date" = #cus.invoicedate, 
           "Balance" = #cus3.balance, 
           "Beat" = beat.description, 
           "Salesman" = salesman.salesman_name, 
           "Due Date" = #cus.duedate 
    FROM   #cus, 
           customer, 
           #cus3, 
           beat, 
           salesman 
    WHERE  #cus.customerid = customer.customerid 
           AND #cus.invoi = #cus3.invoi 
           AND #cus.beatid = beat.beatid 
           AND #cus.salesmanid IN (SELECT salesmanid 
                                   FROM   salesman 
                                   WHERE  salesman_name LIKE @SalesPerson) 
           AND #cus.salesmanid = salesman.salesmanid 
           AND #cus3.balance > 1 
    ORDER  BY #cus.customerid, 
              #cus.documentid 