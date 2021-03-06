--exec SP_ARC_SalesReturns '2020-02-27 00:00:00','2020-03-05 23:59:59','%','Base UOM'
Exec ARC_Insert_ReportData 622, 'Sales Return', 1, 'SP_ARC_SalesReturns', 'Click to view Sales Return', 561, 584, 1, 2, 0, 623, 200, 0, 3, 0, 170, 'No'
GO
--Exec ARC_GetUnusedReportId 
IF EXISTS(SELECT * 
          FROM   sys.objects 
          WHERE  NAME = N'SP_ARC_SalesReturns') 
  BEGIN 
      DROP PROC [SP_ARC_SalesReturns] 
  END 

go 

CREATE PROCEDURE [dbo].[Sp_arc_salesreturns] (@FromDate DATETIME, 
                                              @ToDate   DATETIME, 
                                              @Type     NVARCHAR(255), 
                                              @UOMDesc  NVARCHAR(30)) 
AS 
  BEGIN 
      SET dateformat dmy 

      DECLARE @INV AS NVARCHAR(50) 
      DECLARE @SA AS NVARCHAR(50) 

      SELECT @INV = prefix 
      FROM   voucherprefix WITH (NOLOCK)
      WHERE  tranid = N'INVOICE' 

      SELECT @SA = prefix 
      FROM   voucherprefix  WITH (NOLOCK)
      WHERE  tranid = N'STOCK ADJUSTMENT' 

      CREATE TABLE #tempsalesreturndd 
        ( 
           [INVOICE ID]     NVARCHAR(500) COLLATE sql_latin1_general_cp1_ci_as, 
           [FROM DATE]      DATETIME, 
           [TO DATE]        DATETIME, 
           [INVOICE NUMBER] NVARCHAR(500) COLLATE sql_latin1_general_cp1_ci_as, 
		   [Order Number] INT,
		   [Order Date] DATETIME NULL,
		   [Order Value]   DECIMAL(18, 6), 
           [INVOICE DATE]   DATETIME, 
           [INVOICE VALUE]  DECIMAL(18, 6), 
           [SR Number]         NVARCHAR(255) COLLATE sql_latin1_general_cp1_ci_as, 
           [SR DATE]           DATETIME, 
           [SR TYPE]           NVARCHAR(255) COLLATE sql_latin1_general_cp1_ci_as, 
           [SALESMAN ID]          INT, 
           [SALESMAN NAME]        NVARCHAR(50) COLLATE sql_latin1_general_cp1_ci_as, 
           [CUSTOMER ID]    NVARCHAR(15) COLLATE sql_latin1_general_cp1_ci_as, 
           [CUSTOMER NAME]  NVARCHAR(150) COLLATE sql_latin1_general_cp1_ci_as 
           DEFAULT 
           '' 
        ) 

      IF @Type = '%' 
          OR @Type = '' 
        BEGIN 
            INSERT INTO #tempsalesreturndd 
                        ([INVOICE ID], 
                         [from date], 
                         [to date], 
                         [invoice number],
						 [Order Number],
						 [Order Date],
						 [Order Value],
                         [invoice date], 
                         [invoice value], 
                         [SR Number], 
                         [SR DATE], 
                         [SR TYPE], 
                         [SALESMAN ID], 
                         [SALESMAN NAME], 
                         [customer id], 
                         [customer name]) 
            SELECT invoiceid, 
                   @FromDate, 
                   @ToDate, 
                   SR.referencenumber, 
				   (Select TOP 1 SONumber  FROM invoiceabstract WITH (NOLOCK) WHERE GSTFullDocID = SR.ReferenceNumber),
				   (SELECT TOP 1 SODate from SOAbstract WITH (NOLOCK) WHERE SONumber = (Select TOP 1 SONumber  FROM invoiceabstract WITH (NOLOCK) WHERE GSTFullDocID = SR.ReferenceNumber)),
				   (SELECT TOP 1 Value from SOAbstract WITH (NOLOCK) WHERE SONumber = (Select TOP 1 SONumber  FROM invoiceabstract WITH (NOLOCK) WHERE GSTFullDocID = SR.ReferenceNumber)),
                   (SELECT TOP 1 invoicedate 
                    FROM   invoiceabstract S WITH (nolock) 
                    WHERE  gstfulldocid = SR.referencenumber), 
                   (SELECT TOP 1 Isnull(netvalue, 0) 
                                 + Isnull(roundoffamount, 0) 
                    FROM   invoiceabstract S WITH (nolock) 
                    WHERE  gstfulldocid = SR.referencenumber), 
                   CASE Isnull(gstflag, 0) 
                     WHEN 0 THEN @INV + Cast(documentid AS NVARCHAR(255)) 
                     ELSE Isnull(gstfulldocid, '') 
                   END DocID, 
                   invoicedate, 
                   "Type" = CASE 
                              WHEN Isnull(SR.status, 0) & 32 <> 0 
                                   AND Isnull(SR.status, 0) & 64 = 0 THEN 
                              'DnD' 
                              ELSE 'SR' 
                            END, 
                   SR.salesmanid, 
                   salesman.salesman_name, 
                   SR.customerid, 
                   customer.company_name 
            FROM   invoiceabstract SR  WITH (NOLOCK), 
                   salesman  WITH (NOLOCK), 
                   customer  WITH (NOLOCK) 
            WHERE  SR.salesmanid = salesman.salesmanid 
                   AND SR.customerid = customer.customerid 
                   AND CONVERT(NVARCHAR(10), invoicedate, 103) BETWEEN 
                       @FROMDATE AND @TODATE 
                   AND Isnull(invoicetype, 0) IN ( 4, 5 ) 
                   AND Isnull(status, 0) & 192 = 0 
            ORDER  BY invoicedate, 
                      customer.company_name, 
                      type 

            INSERT INTO #tempsalesreturndd 
                        ([INVOICE ID], 
                         [from date], 
                         [to date], 
                         [SR Number], 
                         [SR DATE], 
                         [SR TYPE]) 
            SELECT SAA.adjustmentid, 
                   @FromDate, 
                   @ToDate, 
                   @SA 
                   + Cast(SAA.documentid AS NVARCHAR(255)) DocID, 
                   SAA.adjustmentdate, 
                   "Type" = 'Damages in Godown' 
            FROM   stockadjustmentabstract SAA  WITH (NOLOCK)
            WHERE  SAA.adjustmenttype = 0 
                   AND SAA.adjustmentid IN (SELECT SAD.serialno 
                                            FROM   stockadjustment SAD  WITH (NOLOCK) 
                                            WHERE 
                       SAD.reasonid IN (SELECT reason_type_id 
                                        FROM   reasonmaster  WITH (NOLOCK)
                                        WHERE 
                       reason_subtype = 3)) 
                   AND CONVERT(NVARCHAR(10), SAA.adjustmentdate, 103) BETWEEN 
                       @FROMDATE AND @TODATE 

            INSERT INTO #tempsalesreturndd 
                        ([INVOICE ID], 
                         [from date], 
                         [to date], 
                         [SR Number], 
                         [SR DATE], 
                         [SR TYPE]) 
            SELECT SAA.adjustmentid, 
                   @FromDate, 
                   @ToDate, 
                   @SA 
                   + Cast(SAA.documentid AS NVARCHAR(255)) DocID, 
                   SAA.adjustmentdate, 
                   "Type" = 'Damages on Arrival' 
            FROM   stockadjustmentabstract SAA  WITH (NOLOCK)
            WHERE  SAA.adjustmenttype = 0 
                   AND SAA.adjustmentid IN (SELECT SAD.serialno 
                                            FROM   stockadjustment SAD  WITH (NOLOCK)
                                            WHERE 
                       SAD.reasonid IN (SELECT reason_type_id 
                                        FROM   reasonmaster 
                                        WHERE 
                       reason_subtype = 4)) 
                   AND CONVERT(NVARCHAR(10), SAA.adjustmentdate, 103) BETWEEN 
                       @FROMDATE AND @TODATE 
        END 
      ELSE IF @Type = 'Sales Return Damage'
        BEGIN 
            INSERT INTO #tempsalesreturndd 
                        ([INVOICE ID], 
                         [from date], 
                         [to date], 
                         [SR Number], 
						 [Order Number],
						 						 [Order Date],
						 [Order Value],
                         [SR DATE], 
                         [SR TYPE], 
                         [SALESMAN ID], 
                         [SALESMAN NAME], 
                         [customer id], 
                         [customer name]) 
            SELECT invoiceid, 
                   @FromDate, 
                   @ToDate, 
                   CASE Isnull(gstflag, 0) 
                     WHEN 0 THEN @INV + Cast(documentid AS NVARCHAR(255)) 
                     ELSE Isnull(gstfulldocid, '') 
                   END DocID, 
				   (Select TOP 1 I.SONumber  FROM invoiceabstract I WITH (NOLOCK) WHERE I.GSTFullDocID = invoiceabstract.ReferenceNumber),
				   				   (SELECT TOP 1 SODate from SOAbstract WITH (NOLOCK) WHERE SONumber = (Select TOP 1 SONumber  FROM invoiceabstract WITH (NOLOCK) WHERE GSTFullDocID = invoiceabstract.ReferenceNumber)),
				   (SELECT TOP 1 Value from SOAbstract WITH (NOLOCK) WHERE SONumber = (Select TOP 1 SONumber  FROM invoiceabstract WITH (NOLOCK) WHERE GSTFullDocID = invoiceabstract.ReferenceNumber)),

                   invoicedate, 
                   "Type" = 'DnD', 
                   invoiceabstract.salesmanid, 
                   salesman.salesman_name, 
                   invoiceabstract.customerid, 
                   customer.company_name 
            FROM   invoiceabstract  WITH (NOLOCK), 
                   salesman  WITH (NOLOCK), 
                   customer  WITH (NOLOCK)
            WHERE  invoiceabstract.salesmanid = salesman.salesmanid 
                   AND invoiceabstract.customerid = customer.customerid 
                   AND CONVERT(NVARCHAR(10), invoicedate, 103) BETWEEN 
                       @FROMDATE AND @TODATE 
                   AND Isnull(invoicetype, 0) IN ( 4, 5 ) 
                   AND Isnull(invoiceabstract.status, 0) & 32 <> 0 
                   AND Isnull(invoiceabstract.status, 0) & 64 = 0 
                   AND Isnull(status, 0) & 192 = 0 
        END 
      ELSE IF @Type = 'SR' 
        BEGIN 
            INSERT INTO #tempsalesreturndd 
                        ([INVOICE ID], 
                         [from date], 
                         [to date], 
                         [SR Number], 
						 [Order Number],
						 						 [Order Date],
						 [Order Value],
                         [SR DATE], 
                         [SR TYPE], 
                         [SALESMAN ID], 
                         [SALESMAN NAME], 
                         [customer id], 
                         [customer name]) 
            SELECT invoiceid, 
                   @FromDate, 
                   @ToDate,                    
                   CASE Isnull(gstflag, 0) 
                     WHEN 0 THEN @INV + Cast(documentid AS NVARCHAR(255)) 
                     ELSE Isnull(gstfulldocid, '') 
                   END DocID, 
				  (Select TOP 1 I.SONumber  FROM invoiceabstract I WITH (NOLOCK) WHERE I.GSTFullDocID = invoiceabstract.ReferenceNumber),
				  				   (SELECT TOP 1 SODate from SOAbstract WITH (NOLOCK) WHERE SONumber = (Select TOP 1 SONumber  FROM invoiceabstract WITH (NOLOCK) WHERE GSTFullDocID = invoiceabstract.ReferenceNumber)),
				   (SELECT TOP 1 Value from SOAbstract WITH (NOLOCK) WHERE SONumber = (Select TOP 1 SONumber  FROM invoiceabstract WITH (NOLOCK) WHERE GSTFullDocID = invoiceabstract.ReferenceNumber)),

                   invoicedate, 
                   "Type" = 'SR', 
                   invoiceabstract.salesmanid, 
                   salesman.salesman_name, 
                   invoiceabstract.customerid, 
                   customer.company_name 
            FROM   invoiceabstract  WITH (NOLOCK), 
                   salesman  WITH (NOLOCK), 
                   customer  WITH (NOLOCK) 
            WHERE  invoiceabstract.salesmanid = salesman.salesmanid 
                   AND invoiceabstract.customerid = customer.customerid 
                   AND CONVERT(NVARCHAR(10), invoicedate, 103) BETWEEN 
                       @FROMDATE AND @TODATE 
                   AND Isnull(invoiceabstract.status, 0) & 32 = 0 
                   --And IsNull(invoiceabstract.Status,0) & 64 <>0 
                   AND Isnull(invoicetype, 0) IN ( 4, 5 ) 
                   AND Isnull(status, 0) & 192 = 0 
        END 
      ELSE IF @Type = 'Damages in Godown' 
        BEGIN 
            INSERT INTO #tempsalesreturndd 
                        ([INVOICE ID], 
                         [from date], 
                         [to date], 
                         [SR Number], 
                         [SR DATE], 
                         [SR TYPE]) 
            SELECT SAA.adjustmentid, 
                   @FromDate, 
                   @ToDate, 
                   @SA 
                   + Cast(SAA.documentid AS NVARCHAR(255)) DocID, 
                   SAA.adjustmentdate, 
                   "Type" = 'Damages in Godown' 
            FROM   stockadjustmentabstract SAA 
            WHERE  SAA.adjustmenttype = 0 
                   AND SAA.adjustmentid IN (SELECT SAD.serialno 
                                            FROM   stockadjustment SAD  WITH (NOLOCK)
                                            WHERE 
                       SAD.reasonid IN (SELECT reason_type_id 
                                        FROM   reasonmaster  WITH (NOLOCK)
                                        WHERE 
                       reason_subtype = 3)) 
                   AND CONVERT(NVARCHAR(10), SAA.adjustmentdate, 103) BETWEEN 
                       @FROMDATE AND @TODATE 
        END 
      ELSE IF @Type = 'Damages on Arrival' 
        BEGIN 
            INSERT INTO #tempsalesreturndd 
                        ([INVOICE ID], 
                         [from date], 
                         [to date], 
                         [SR Number], 
                         [SR DATE], 
                         [SR TYPE]) 
            SELECT SAA.adjustmentid, 
                   @FromDate, 
                   @ToDate, 
                   @SA 
                   + Cast(SAA.documentid AS NVARCHAR(255)) DocID, 
                   SAA.adjustmentdate, 
                   "Type" = 'Damages on Arrival' 
            FROM   stockadjustmentabstract SAA  WITH (NOLOCK)
            WHERE  SAA.adjustmenttype = 0 
                   AND SAA.adjustmentid IN (SELECT SAD.serialno 
                                            FROM   stockadjustment SAD  WITH (NOLOCK)
                                            WHERE 
                       SAD.reasonid IN (SELECT reason_type_id 
                                        FROM   reasonmaster  WITH (NOLOCK)
                                        WHERE 
                       reason_subtype = 4)) 
                   AND CONVERT(NVARCHAR(10), SAA.adjustmentdate, 103) BETWEEN 
                       @FROMDATE AND @TODATE 
        END 

      --update #TempSalesReturnDD set invoiceid=Invoiceid+ '|' + Type  
      UPDATE #tempsalesreturndd 
      SET    [INVOICE ID] = [INVOICE ID] + '|' + '1' 
      WHERE  [SR TYPE] = 'SR' 

      UPDATE #tempsalesreturndd 
      SET    [INVOICE ID] = [INVOICE ID] + '|' + '2' 
      WHERE  [SR TYPE] = 'DnD' 

      UPDATE #tempsalesreturndd 
      SET    [INVOICE ID] = [INVOICE ID] + '|' + '3' 
      WHERE  [SR TYPE] = 'Damages in Godown' 

      UPDATE #tempsalesreturndd 
      SET    [INVOICE ID] = [INVOICE ID] + '|' + '4' 
      WHERE  [SR TYPE] = 'Damages on Arrival' 

      SELECT *, 
             dbo.Fn_arc_getcustomercategory([customer id]) [CUSTOMER CATEGORY GROUP], 
             dbo.Fn_arc_getcustomergroup([customer id])    [CUSTOMER GROUP]
			 
      FROM   #tempsalesreturndd V WITH (nolock) 	 
      ORDER  BY dbo.Striptimefromdate([SR DATE]), 
                Isnull([customer name], ''), 
                [SR TYPE] 

      DROP TABLE #tempsalesreturndd 
  END 
go 