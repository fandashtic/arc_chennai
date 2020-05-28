--exec [sp_print_InvAbstract_Windows_CIG_IGST_ITC_GST_SLM] 65966 
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'sp_print_InvAbstract_Windows_CIG_IGST_ITC_GST_SLM')
BEGIN
    DROP PROC [sp_print_InvAbstract_Windows_CIG_IGST_ITC_GST_SLM]
END
GO
CREATE PROCEDURE [dbo].[sp_print_InvAbstract_Windows_CIG_IGST_ITC_GST_SLM](@INVNO 
INT) 
AS 
  BEGIN 
      SET dateformat dmy 

      DECLARE @TotalTax DECIMAL(18, 6) 
      DECLARE @TotalQty DECIMAL(18, 6) 
      DECLARE @FirstSales DECIMAL(18, 6) 
      DECLARE @SecondSales DECIMAL(18, 6) 
      DECLARE @Savings DECIMAL(18, 6) 
      DECLARE @GoodsValue DECIMAL(18, 6) 
      DECLARE @ProductDiscountValue DECIMAL(18, 6) 
      DECLARE @AvgProductDiscountPercentage DECIMAL(18, 6) 
      DECLARE @TaxApplicable DECIMAL(18, 6) 
      DECLARE @TaxSuffered DECIMAL(18, 6) 
      DECLARE @ItemCount INT 
      DECLARE @ItemCountWithoutFree INT 
      DECLARE @AdjustedValue DECIMAL(18, 6) 
      DECLARE @SalesTaxwithcess DECIMAL(18, 6) 
      DECLARE @salestaxwithoutCESS DECIMAL(18, 6) 
      DECLARE @DispRef NVARCHAR(50) 
      DECLARE @SCRef NVARCHAR(50) 
      DECLARE @SCID NVARCHAR(50) 
      DECLARE @bRefSC INT 
      DECLARE @TotTaxableSaleVal DECIMAL(18, 6) 
      DECLARE @TotNonTaxableSaleVal DECIMAL(18, 6) 
      DECLARE @TotTaxableGV DECIMAL(18, 6) 
      DECLARE @TotNonTaxableGV DECIMAL(18, 6) 
      DECLARE @TotTaxSuffSaleVal DECIMAL(18, 6) 
      DECLARE @TotNonTaxSuffSaleVal DECIMAL(18, 6) 
      DECLARE @TotTaxSuffGV DECIMAL(18, 6) 
      DECLARE @TotNonTaxSuffGV DECIMAL(18, 6) 
      DECLARE @TotFirstSaleGV DECIMAL(18, 6) 
      DECLARE @TotSecondSaleGV DECIMAL(18, 6) 
      DECLARE @TotFirstSaleValue DECIMAL(18, 6) 
      DECLARE @TotSecondSaleValue DECIMAL(18, 6) 
      DECLARE @TotFirstSaleTaxApplicable DECIMAL(18, 6) 
      DECLARE @TotSecondSaleTaxApplicable DECIMAL(18, 6) 
      DECLARE @AddnDiscount DECIMAL(18, 6) 
      DECLARE @TradeDiscount DECIMAL(18, 6) 
      DECLARE @ChequeNo NVARCHAR(50) 
      DECLARE @ChequeDate DATETIME 
      DECLARE @BankCode NVARCHAR(50) 
      DECLARE @BankName NVARCHAR(100) 
      DECLARE @BranchCode NVARCHAR(50) 
      DECLARE @BranchName NVARCHAR(100) 
      DECLARE @CollectionID INT 
      DECLARE @SCRefNo NVARCHAR(50) 
      DECLARE @DispRefNo NVARCHAR(50) 
      DECLARE @DispRefNumber NVARCHAR(50) 
      DECLARE @SCRefNumber NVARCHAR(50) 
      DECLARE @CANCELLEDSALESRETURNDAMAGES AS NVARCHAR(50) 
      DECLARE @CANCELLEDSALESRETURNSALEABLE AS NVARCHAR(50) 
      DECLARE @SALESRETURNDAMAGES AS NVARCHAR(50) 
      DECLARE @SALESRETURNSALEABLE AS NVARCHAR(50) 
      DECLARE @CANCELLED AS NVARCHAR(50) 
      DECLARE @AMENDED AS NVARCHAR(50) 
      DECLARE @INVOICEFROMVAN AS NVARCHAR(50) 
      DECLARE @INVOICE AS NVARCHAR(50) 
      DECLARE @CREDIT AS NVARCHAR(50) 
      DECLARE @CASH AS NVARCHAR(50) 
      DECLARE @CHEQUE AS NVARCHAR(50) 
      DECLARE @DD AS NVARCHAR(50) 
      DECLARE @SC AS NVARCHAR(50) 
      DECLARE @DISPATCH AS NVARCHAR(50) 
      DECLARE @WDPhoneNumber AS NVARCHAR(20) 
      DECLARE @PointsEarned AS INT 
      DECLARE @TotPointsEarned AS INT 
      DECLARE @CustCode AS NVARCHAR(255) 
      DECLARE @InvoiceDate AS DATETIME 
      DECLARE @ClosingPoints AS NVARCHAR(2000) 
      DECLARE @TargetVsAchievement AS NVARCHAR(2000) 
      DECLARE @CompanyGSTIN AS NVARCHAR(30) 
      DECLARE @CompanyPAN AS NVARCHAR(200) 
      DECLARE @CIN AS NVARCHAR(50) 
      DECLARE @CompanyState NVARCHAR(200) 
      DECLARE @CompanySC NVARCHAR(50) 
      DECLARE @UTGST_flag INT 
      DECLARE @WDFSSAINO AS NVARCHAR(200) 

      SELECT @UTGST_flag = Isnull(flag, 0) 
      FROM   tbl_merp_configabstract(nolock) 
      WHERE  screencode = 'UTGST' 

      SET @CustCode='' 
      SET @CustCode=(SELECT customerid 
                     FROM   invoiceabstract 
                     WHERE  invoiceid = @InvNo) 
      SET @InvoiceDate = (SELECT TOP 1 dbo.Striptimefromdate(invoicedate) 
                          FROM   invoiceabstract 
                          WHERE  invoiceid = @INVNO) 
      SET @ClosingPoints = Isnull((SELECT 
      dbo.Fn_get_currentachievementval(@CustCode, @InvoiceDate)), '') 
      SET @TargetVsAchievement = Isnull((SELECT 
      dbo.Fn_get_currenttarget_achievementval(@CustCode, @InvoiceDate)), '') 
      SET @PointsEarned='' 
      SET @PointsEarned=Cast(Isnull((SELECT Cast(Sum(Isnull(points, 0)) AS INT) 
                                     FROM   tbl_merp_outletpoints op 
                                     WHERE  op.invoiceid = @INVNO 
                                            AND op.status = 0), 0) AS INT) 
      SET @TotPointsEarned='' 
      SET @TotPointsEarned=Cast(Isnull((SELECT Cast(Sum(Isnull(points, 0)) AS 
                                                    INT) 
                                        FROM   tbl_merp_outletpoints op 
                                        WHERE  op.outletcode = @CustCode 
                                               AND op.invoiceid <= @INVNO 
                                               AND op.status = 0), 0) AS INT) 

      SELECT @WDPhoneNumber = telephone 
      FROM   setup 

      SELECT @CompanyGSTIN = gstin 
      FROM   setup 

      SELECT @CompanyPAN = pannumber 
      FROM   setup 

      SELECT @CIN = cin 
      FROM   setup 

      SELECT TOP 1 @CompanyState = statename, 
                   @CompanySC = forumstatecode, 
                   @WDFSSAINO = CASE 
                                  WHEN setup.stregn = '' THEN '' 
                                  ELSE 'FSSAI No. : ' + setup.stregn 
                                END 
      FROM   statecode 
             INNER JOIN setup 
                     ON setup.shippingstateid = statecode.stateid 

      SET @CANCELLEDSALESRETURNDAMAGES = 
      dbo.Lookupdictionaryitem(N'CANCELLED SALES RETURN DAMAGES', DEFAULT) 
      SET @CANCELLEDSALESRETURNSALEABLE = 
      dbo.Lookupdictionaryitem(N'CANCELLED SALES RETURN SALEABLE', DEFAULT) 
      SET @SALESRETURNDAMAGES = 
      dbo.Lookupdictionaryitem(N'SALES RETURN DAMAGES', 
      DEFAULT) 
      SET @SALESRETURNSALEABLE = 
      dbo.Lookupdictionaryitem(N'SALES RETURN SALEABLE', DEFAULT) 
      SET @CANCELLED = dbo.Lookupdictionaryitem(N'CANCELLED', DEFAULT) 
      SET @AMENDED = dbo.Lookupdictionaryitem(N'AMENDED', DEFAULT) 
      SET @INVOICEFROMVAN = dbo.Lookupdictionaryitem(N'INVOICE FROM VAN', 
                            DEFAULT) 
      SET @INVOICE = dbo.Lookupdictionaryitem(N'INVOICE', DEFAULT) 
      SET @CREDIT = dbo.Lookupdictionaryitem(N'Credit', DEFAULT) 
      SET @CASH = dbo.Lookupdictionaryitem(N'Cash', DEFAULT) 
      SET @CHEQUE = dbo.Lookupdictionaryitem(N'Cheque', DEFAULT) 
      SET @DD = dbo.Lookupdictionaryitem(N'DD', DEFAULT) 
      SET @SC = dbo.Lookupdictionaryitem(N'SC', DEFAULT) 
      SET @DISPATCH = dbo.Lookupdictionaryitem(N'DISPATCH', DEFAULT) 

      SELECT @AddnDiscount = additionaldiscount, 
             @TradeDiscount = discountpercentage, 
             @CollectionID = Cast(paymentdetails AS INT) 
      FROM   invoiceabstract 
      WHERE  invoiceid = @INVNO 

      SELECT @TotalTax = Sum(Isnull(stpayable, 0)), 
             @TotalQty = Isnull(Sum(quantity), 0), 
             @FirstSales = (SELECT Isnull(Sum(stpayable + cstpayable), 0) 
                            FROM   invoicedetail 
                            WHERE  invoiceid = @InvNo 
                                   AND saleid = 1), 
             @SecondSales = (SELECT Isnull(Sum(stpayable + cstpayable), 0) 
                             FROM   invoicedetail 
                             WHERE  invoiceid = @InvNo 
                                    AND saleid = 2), 
             @Savings = Sum(mrp * quantity) - Sum(saleprice * quantity), 
             @GoodsValue = Sum(quantity * saleprice), 
             @ProductDiscountValue = Sum(discountvalue), 
             @AvgProductDiscountPercentage = Avg(discountpercentage), 
             @TaxApplicable = Sum(Isnull(cstpayable, 0) + Isnull(stpayable, 0)), 
             @TotTaxableSaleVal = Sum(CASE 
                                        WHEN Isnull(cstpayable, 0) = 0 
                                             AND Isnull(stpayable, 0) = 0 THEN 0 
                                        ELSE amount 
                                      END), 
             @TotNonTaxableSaleVal = Sum(CASE 
                                           WHEN Isnull(cstpayable, 0) = 0 
                                                AND Isnull(stpayable, 0) = 0 
                                         THEN 
                                           amount 
                                           ELSE 0 
                                         END), 
             @TotTaxableGV = Sum(CASE 
                                   WHEN Isnull(cstpayable, 0) = 0 
                                        AND Isnull(stpayable, 0) = 0 THEN 0 
                                   ELSE ( ( quantity * saleprice ) 
                                          - discountvalue 
                                          + ( 
                                                 quantity * saleprice * 
                                                 taxsuffered / 
                                                 100 ) ) 
                                 END),             
             @TotNonTaxableGV = (SELECT Sum(InvDetail.totnontaxablegv) 
                                 FROM   (SELECT Sum(( ( InvDet.quantity * 
                                                        InvDet.saleprice ) 
                                                      - 
                                                      InvDet.discountvalue + 
                                                                          ( 
                                                      InvDet.quantity * 
                                                      InvDet.saleprice * 
                                                      InvDet.taxsuffered / 100 ) 
                                                    ) 
                                                ) 
                                                        "TotNonTaxableGV" 
                                         FROM   invoicedetail InvDet 
                                         WHERE  InvDet.invoiceid = @INVNO 
                                         GROUP  BY InvDet.serial 
                                         HAVING Sum(Isnull(cstpayable, 0)) = 0 
                                                AND Sum(Isnull(stpayable, 0)) = 
                                                    0) 
                                        InvDetail), 
             @TotTaxSuffSaleVal = Sum(CASE 
                                        WHEN Isnull(taxsuffered, 0) = 0 THEN 0 
                                        ELSE amount 
                                      END), 
             @TotNonTaxSuffSaleVal = Sum(CASE 
                                           WHEN Isnull(taxsuffered, 0) = 0 THEN 
                                           amount 
                                           ELSE 0 
                                         END), 
             @TotTaxSuffGV = Sum(CASE 
                                   WHEN Isnull(taxsuffered, 0) = 0 THEN 0 
                                   ELSE ( ( quantity * saleprice ) 
                                          - discountvalue 
                                        ) 
                                 END), 
             @TotNonTaxSuffGV = Sum(CASE 
                                      WHEN Isnull(taxsuffered, 0) = 0 THEN ( 
                                      ( quantity * saleprice ) - discountvalue ) 
                                      ELSE 0 
                                    END), 
             @TotFirstSaleGV = Sum(CASE saleid 
                                     WHEN 1 THEN ( ( quantity * saleprice ) 
                                                   - discountvalue + 
                                                   ( 
                                                   quantity * saleprice 
                                                   * 
                                                   taxsuffered / 100 ) ) 
                                     ELSE 0 
                                   END), 
             @TotSecondSaleGV = Sum(CASE saleid 
                                      WHEN 1 THEN 0 
                                      ELSE ( ( quantity * saleprice ) 
                                             - discountvalue 
                                             + ( 
                                                    quantity * saleprice * 
                                                    taxsuffered 
                                                    / 100 
                                             ) ) 
                                    END), 
             @TotFirstSaleValue = Sum(CASE saleid 
                                        WHEN 1 THEN amount 
                                        ELSE 0 
                                      END), 
             @TotSecondSaleValue = Sum(CASE saleid 
                                         WHEN 1 THEN 0 
                                         ELSE amount 
                                       END), 
             @TotFirstSaleTaxApplicable = Sum(CASE saleid 
                                                WHEN 1 THEN 
                                                ( ( Isnull(cstpayable, 
                                                    0) 
                                                    + 
                                                    Isnull(stpayable, 
                                                    0) ) 
                                                  - 
                                                  ( 
                                                  ( 
                                                  Isnull( 
                                                  cstpayable, 0) 
                                                  + 
                                                  Isnull(stpayable, 0) 
                                                  ) * 
                                                  ( 
                                                  @AddnDiscount + 
                                                  @TradeDiscount 
                                                  ) 
                                                  / 100 ) ) 
                                                ELSE 0 
                                              END), 
             @TotSecondSaleTaxApplicable = Sum(CASE saleid 
                                                 WHEN 1 THEN 0 
                                                 ELSE ( ( Isnull(cstpayable, 0) 
                                                          + 
                                                          Isnull( 
                                                          stpayable, 0) ) - 
                                                        ( 
                                                                 ( 
                                                                 Isnull( 
                                                        cstpayable 
                                                                 , 0) 
                                                                 + 
                                                                 Isnull( 
                                                        stpayable, 
                                                                 0) ) 
                                                        * ( 
                                                                 @AddnDiscount + 
                                                                 @TradeDiscount 
                                                          ) 
                                                        / 
                                                                 100 ) ) 
                                               END) 
      FROM   invoicedetail 
      WHERE  invoiceid = @INVNO 

      CREATE TABLE #temp 
        ( 
           taxsuffered          DECIMAL(18, 6), 
           itemcountwithoutfree INT 
        ) 

      CREATE TABLE #tempitemcount 
        ( 
           itemcount INT 
        ) 

      INSERT #temp 
      SELECT Isnull(Sum(invoicedetail.taxsuffamount), 0), 
             CASE invoicedetail.flagword 
               WHEN 1 THEN 0 
               ELSE 
                 CASE batch_products.free 
                   WHEN 1 THEN 0 
                   ELSE 1 
                 END 
             END 
      FROM   invoicedetail 
             INNER JOIN invoiceabstract 
                     ON invoiceabstract.invoiceid = invoicedetail.invoiceid 
             LEFT OUTER JOIN batch_products 
                          ON invoicedetail.batch_code = 
                             batch_products.batch_code 
      WHERE  invoicedetail.invoiceid = @INVNO   
      GROUP  BY invoicedetail.serial, 
                invoicedetail.product_code, 
                invoicedetail.batch_number, 
                invoicedetail.saleprice, 
                invoicedetail.mrp, 
                invoicedetail.saleid, 
                invoiceabstract.taxonmrp, 
                invoicedetail.flagword, 
                batch_products.[free] 

      /*While counting the number of items in the invoice  
      Same product free item will not be considered as a separate item as the free item will be 
      shown under the free column in the same row along with the saleable item */ 
      INSERT #tempitemcount 
             (itemcount) 
      EXEC Sp_print_retinvitems_respectiveuom_cig_igst_itc_gst 
        @INVNO, 
        1 

      SELECT @TaxSuffered = Sum(taxsuffered) 
      FROM   #temp 

      SELECT @ItemCountWithoutFree = Count(DISTINCT product_code) 
      FROM   invoicedetail 
      WHERE  invoiceid = @InvNo 
             AND saleprice <> 0 

      SELECT @ItemCount = Max(itemcount) * 2 
      FROM   #tempitemcount 

      DROP TABLE #temp 

      DROP TABLE #tempitemcount 

      -------------------------Temp Tax Details 
      SELECT invoiceid, 
             product_code, 
             tax_code, 
             serialno, 
             SGSTPer = Max(CASE 
                             WHEN TCD.taxcomponent_desc = 'SGST' THEN 
                             ITC.tax_percentage 
                             ELSE 0 
                           END), 
             SGSTAmt = Sum(CASE 
                             WHEN TCD.taxcomponent_desc = 'SGST' THEN 
                             ITC.nettaxamount 
                             ELSE 0 
                           END), 
             CGSTPer = Max(CASE 
                             WHEN TCD.taxcomponent_desc = 'CGST' THEN 
                             ITC.tax_percentage 
                             ELSE 0 
                           END), 
             CGSTAmt = Sum(CASE 
                             WHEN TCD.taxcomponent_desc = 'CGST' THEN 
                             ITC.nettaxamount 
                             ELSE 0 
                           END), 
             IGSTPer = Max(CASE 
                             WHEN TCD.taxcomponent_desc = 'IGST' THEN 
                             ITC.tax_percentage 
                             ELSE 0 
                           END), 
             IGSTAmt = Sum(CASE 
                             WHEN TCD.taxcomponent_desc = 'IGST' THEN 
                             ITC.nettaxamount 
                             ELSE 0 
                           END), 
             UTGSTPer = Max(CASE 
                              WHEN TCD.taxcomponent_desc = 'UTGST' THEN 
                              ITC.tax_percentage 
                              ELSE 0 
                            END), 
             UTGSTAmt = Sum(CASE 
                              WHEN TCD.taxcomponent_desc = 'UTGST' THEN 
                              ITC.nettaxamount 
                              ELSE 0 
                            END),              
             CESSPer = Max(CASE 
                             WHEN TCD.taxcomponent_desc = 'CESS' THEN 
                             ITC.tax_percentage 
                             ELSE 0 
                           END),              
             CESSAmt = Sum(CASE 
                             WHEN TCD.taxcomponent_desc = 'CESS' THEN 
                             ITC.nettaxamount 
                             ELSE 0 
                           END), 
             ADDLCESSPer = Max(CASE 
                                 WHEN TCD.taxcomponent_desc = 'ADDL CESS' THEN 
                                 ITC.tax_percentage 
                                 ELSE 0 
                               END), 
             ADDLCESSAmt = Sum(CASE 
                                 WHEN TCD.taxcomponent_desc = 'ADDL CESS' THEN 
                                 ITC.nettaxamount 
                                 ELSE 0 
                               END) 
      INTO   #temptaxdet 
      FROM   gstinvoicetaxcomponents ITC 
             JOIN taxcomponentdetail TCD 
               ON TCD.taxcomponent_code = ITC.tax_component_code 
      WHERE  invoiceid = @INVNo 
      GROUP  BY invoiceid, 
                product_code, 
                tax_code, 
                serialno 

      --Temp Invoice Detail 
      SELECT Serial=ID.serial, 
             TaxID=ID.taxid, 
             TaxableValue = CASE 
                              WHEN Isnull(cstpayable, 0) = 0 
                                   AND Isnull(stpayable, 0) = 0 THEN 0 
                              ELSE ( ( uomqty * uomprice ) - discountvalue ) - 
                                   ( 
                                   ( 
                                   ( uomqty * uomprice ) - discountvalue ) * 
                                   @AddnDiscount / 
                                   100 ) 
                            END, 
             SGSTPer=CASE gstflag 
                       WHEN 1 THEN (SELECT sgstper 
                                    FROM   #temptaxdet 
                                    WHERE  invoiceid = ID.invoiceid 
                                           AND product_code = ID.product_code 
                                           AND serialno = ID.serial 
                                           AND uomqty > 0) 
                       WHEN 0 THEN Isnull(ID.taxcode, 0) 
                                   + Isnull(ID.taxcode2, 0) 
                     END, 
             SGSTAmt=CASE gstflag 
                       WHEN 1 THEN (SELECT Sum(sgstamt) 
                                    FROM   #temptaxdet 
                                    WHERE  invoiceid = ID.invoiceid 
                                           AND product_code = ID.product_code 
                                           AND serialno = ID.serial 
                                           AND uomqty > 0) 
                       WHEN 0 THEN Isnull(ID.stpayable, 0) 
                                   + Isnull(ID.cstpayable, 0) 
                     END, 
             CGSTPer=(SELECT cgstper 
                      FROM   #temptaxdet 
                      WHERE  invoiceid = ID.invoiceid 
                             AND product_code = ID.product_code 
                             AND serialno = ID.serial 
                             AND uomqty > 0), 
             CGSTAmt=(SELECT Sum(cgstamt) 
                      FROM   #temptaxdet 
                      WHERE  invoiceid = ID.invoiceid 
                             AND product_code = ID.product_code 
                             AND serialno = ID.serial 
                             AND uomqty > 0), 
             IGSTPer=(SELECT igstper 
                      FROM   #temptaxdet 
                      WHERE  invoiceid = ID.invoiceid 
                             AND product_code = ID.product_code 
                             AND serialno = ID.serial 
                             AND uomqty > 0), 
             IGSTAmt=(SELECT Sum(igstamt) 
                      FROM   #temptaxdet 
                      WHERE  invoiceid = ID.invoiceid 
                             AND product_code = ID.product_code 
                             AND serialno = ID.serial 
                             AND uomqty > 0), 
             UTGSTPer=(SELECT utgstper 
                       FROM   #temptaxdet 
                       WHERE  invoiceid = ID.invoiceid 
                              AND product_code = ID.product_code 
                              AND serialno = ID.serial 
                              AND uomqty > 0), 
             UTGSTAmt=(SELECT Sum(utgstamt) 
                       FROM   #temptaxdet 
                       WHERE  invoiceid = ID.invoiceid 
                              AND product_code = ID.product_code 
                              AND serialno = ID.serial 
                              AND uomqty > 0), 
             CESSPer=(SELECT cessper 
                      FROM   #temptaxdet 
                      WHERE  invoiceid = ID.invoiceid 
                             AND product_code = ID.product_code 
                             AND serialno = ID.serial 
                             AND uomqty > 0), 
             CESSAmt=(SELECT Sum(cessamt) 
                      FROM   #temptaxdet 
                      WHERE  invoiceid = ID.invoiceid 
                             AND product_code = ID.product_code 
                             AND serialno = ID.serial 
                             AND uomqty > 0), 
             ADDLCESSPer=(SELECT addlcessper 
                          FROM   #temptaxdet 
                          WHERE  invoiceid = ID.invoiceid 
                                 AND product_code = ID.product_code 
                                 AND serialno = ID.serial 
                                 AND uomqty > 0), 
             ADDLCESSAmt=(SELECT Sum(addlcessamt) 
                          FROM   #temptaxdet 
                          WHERE  invoiceid = ID.invoiceid 
                                 AND product_code = ID.product_code 
                                 AND serialno = ID.serial 
                                 AND uomqty > 0) 
      INTO   #tempinvdet2 
      FROM   invoicedetail ID 
      WHERE  invoiceid = @INVNo 
             AND uomqty > 0 

      DECLARE @GSTaxCompHead NVARCHAR(255) 
      DECLARE @GSTaxCompDet NVARCHAR(4000) 
      DECLARE @GSTaxCompHead_DOS NVARCHAR(255) 
      DECLARE @GSTaxCompDet_DOS NVARCHAR(4000) 

      SET @GSTaxCompHead = 'Rate' + Space(8) + 'TaxableVal' + Space(12) 
                           + 'CGST' + Space(8) + CASE WHEN @UTGST_flag = 1 THEN 
                           'UTGST' ELSE '  SGST' END + Space(6) + '  Total Tax' 
      SET @GSTaxCompHead_DOS = 'Rate' + Space(3) + 'TaxableVal' + Space(7) + 
                               'CGST' 
                               + Space(6) + CASE WHEN @UTGST_flag = 1 THEN 
                               'UTGST' 
                               ELSE ' SGST' END + Space(2) + 'Total Tax' 
      SET @GSTaxCompDet = '' 
      SET @GSTaxCompDet_DOS = '' 

      SELECT TaxableValue=Sum(taxablevalue), 
             Rate =CONVERT(DECIMAL(5, 2), CASE WHEN @UTGST_flag = 1 THEN 
                   utgstper 
                   ELSE 
                   sgstper END 
                   ) + CONVERT(DECIMAL(5, 2), cgstper), 
             SGSTAmt =Sum(CASE 
                            WHEN @UTGST_flag = 1 THEN utgstamt 
                            ELSE sgstamt 
                          END), 
             CGSTAmt=Sum(cgstamt), 
             Total=Sum(Isnull(CONVERT(DECIMAL(18, 6), cgstamt), 0) 
                       + Isnull(CONVERT(DECIMAL(18, 6), CASE WHEN @UTGST_flag = 
                       1 
                       THEN 
                       utgstamt 
                             ELSE sgstamt END), 0)) 
      INTO   #gsttaxcompdet 
      FROM   #tempinvdet2 WITH (nolock) 
      GROUP  BY CASE 
                  WHEN @UTGST_flag = 1 THEN utgstper 
                  ELSE sgstper 
                END, 
                cgstper 

      DELETE FROM #gsttaxcompdet 
      WHERE  Isnull(rate, 0) = 0 

      --select * from #GSTTaxCompDet 
      SELECT @GSTaxCompDet = @GSTaxCompDet + '' 
                             + Replicate('0', 5-Len(Cast(Cast(rate AS DECIMAL(5, 
                             2 
                             ))AS 
                                    NVARCHAR(5)))) 
                             + Cast(Cast(rate AS DECIMAL(5, 2))AS NVARCHAR(5)) 
                             + '%' + '  ' 
                             + Space(10-Len(Cast(Cast(taxablevalue AS DECIMAL(10 
                             , 
                             2)) 
                             AS 
                                    NVARCHAR(10)))) 
                             + Space(10-Len(Cast(Cast(taxablevalue AS DECIMAL(10 
                             , 
                             2)) 
                             AS 
                                    NVARCHAR(10)))) 
                             + Cast(Cast(taxablevalue AS DECIMAL(10, 2)) AS 
                             NVARCHAR( 
                             10)) 
                             + '  ' 
                             + Space(10-Len(Cast(Cast(cgstamt AS DECIMAL(10, 2)) 
                             AS 
                             NVARCHAR( 
                                    10)))) 
                             + Space(10-Len(Cast(Cast(cgstamt AS DECIMAL(10, 2)) 
                             AS 
                             NVARCHAR( 
                                    10)))) 
                             + Cast(Cast(cgstamt AS DECIMAL(10, 2)) AS NVARCHAR( 
                             10 
                             )) 
                             + '  ' 
                             + Space(10-Len(Cast(Cast(sgstamt AS DECIMAL(10, 2)) 
                             AS 
                             NVARCHAR( 
                                    10)))) 
                             + Space(10-Len(Cast(Cast(sgstamt AS DECIMAL(10, 2)) 
                             AS 
                             NVARCHAR( 
                                    10)))) 
                             + Cast(Cast(sgstamt AS DECIMAL(10, 2)) AS NVARCHAR( 
                             10 
                             )) 
                             + '  ' 
                             + Space(10-Len(Cast(Cast(total AS DECIMAL(10, 2)) 
                             AS 
                             NVARCHAR(10 
                                    )))) 
                             + Space(10-Len(Cast(Cast(total AS DECIMAL(10, 2)) 
                             AS 
                             NVARCHAR(10 
                                    )))) 
                             + Cast(Cast(total AS DECIMAL(10, 2)) AS NVARCHAR(10 
                             )) 
      FROM   #gsttaxcompdet WITH (nolock) 

      SELECT @GSTaxCompDet_DOS = @GSTaxCompDet_DOS + '' 
                                 + Replicate('0', 5-Len(Cast(Cast(rate AS 
                                 DECIMAL( 
                                 5, 2 
                                 ))AS 
                                        NVARCHAR(5)))) 
                                 + Cast(Cast(rate AS DECIMAL(5, 2))AS NVARCHAR(5 
                                 )) 
                                 + '%' + ' ' 
                                 + Space(10-Len(Cast(Cast(taxablevalue AS 
                                 DECIMAL( 
                                 10, 
                                 2)) AS 
                                        NVARCHAR(10)))) 
                                 + Cast(Cast(taxablevalue AS DECIMAL(10, 2)) AS 
                                 NVARCHAR(10)) 
                                 + ' ' 
                                 + Space(10-Len(Cast(Cast(cgstamt AS DECIMAL(10, 
                                 2 
                                 )) 
                                 AS 
                                        NVARCHAR(10)))) 
                                 + Cast(Cast(cgstamt AS DECIMAL(10, 2)) AS 
                                 NVARCHAR(10 
                                 )) 
                                 + ' ' 
                                 + Space(10-Len(Cast(Cast(sgstamt AS DECIMAL(10, 
                                 2 
                                 )) 
                                 AS 
                                        NVARCHAR(10)))) 
                                 + Cast(Cast(sgstamt AS DECIMAL(10, 2)) AS 
                                 NVARCHAR(10 
                                 )) 
                                 + ' ' 
                                 + Space(10-Len(Cast(Cast(total AS DECIMAL(10, 2 
                                 )) 
                                 AS 
                                        NVARCHAR(10)))) 
                                 + Cast(Cast(total AS DECIMAL(10, 2)) AS 
                                 NVARCHAR( 
                                 10)) 
                                 + ' ' 
      FROM   #gsttaxcompdet WITH (nolock) 

      SELECT TaxableValue=Sum(taxablevalue), 
             SGSTPer=Max(sgstper), 
             SGSTAmt =Sum(sgstamt), 
             CGSTPer=Max(cgstper), 
             CGSTAmt=Sum(cgstamt), 
             IGSTPer=Max(igstper), 
             IGSTAmt=Sum(igstamt), 
             UTGSTPer=Max(utgstper), 
             UTGSTAmt=Sum(utgstamt), 
             CESSPer=Max(cessper), 
             CESSAmt=Sum(cessamt), 
             ADDLCESSPer=Max(addlcessper), 
             ADDLCESSAmt=Sum(addlcessamt), 
             Total= Sum(igstamt + cessamt + addlcessamt) 
      INTO   #gstaxsummary 
      FROM   #tempinvdet2 
      GROUP  BY taxid 

      DECLARE @GSTTaxSumText NVARCHAR(25) 
      DECLARE @GSTTaxComp NVARCHAR(max) 
      DECLARE @GSTTaxComp_DOS NVARCHAR(max) 
      DECLARE @GSTTaxCompText NVARCHAR(200) 
      DECLARE @GSTTaxCompText_DOS NVARCHAR(200) 

      SET @GSTTaxSumText = 'Tax Summary :' 
      SET @GSTTaxCompText = 'Tax Summary/GST  Component' + Space(32) 
                            + 'TaxableVal' + Space(14) + 'IGST' + Space(10) 
                            + 'Cess' + Space(6) + 'AddlCess'+ + Space(4) 
                            + 'Total Tax' 
      SET @GSTTaxCompText_DOS= 'Tax Summary/GST  Component' + Space(19) 
                               + 'TaxableVal ' + Space(6) + 'IGST ' + Space(6) 
                               + 'Cess ' + Space(2) + 'AddlCess '+ + Space(1) 
                               + 'Total Tax' 
      SET @GSTTaxComp = '  '+ + Char(13) + Char(10) 
                        + '  |  Tax Summary/GST  Component' 
                        + Space(32) + 'TaxableVal' + Space(14) + 'IGST' 
                        + Space(10) + 'Cess' + Space(6) + 'AddlCess'+ 
                        + Space(4) + 'Total Tax' + Char(13) + Char(10) 

      SELECT @GSTTaxComp = @GSTTaxComp + '  |  IGST' 
                           + Replicate('  ', 5-Len(Cast(Cast(igstper AS DECIMAL( 
                           5, 
                           2)) 
                           AS 
                                  NVARCHAR(5)))) 
                           + Cast(Cast(igstper AS DECIMAL(5, 2)) AS NVARCHAR(5)) 
                           + '% + Cess' 
                           + Replicate('  ', 5-Len(Cast(Cast(cessper AS DECIMAL( 
                           5, 
                           2)) 
                           AS 
                                  NVARCHAR(5)))) 
                           + Cast(Cast(cessper AS DECIMAL(5, 2)) AS NVARCHAR(5)) 
                           + '% + AddlCess ' 
                           + Replicate('  ', 5-Len(Ltrim(Cast(Cast(addlcessper 
                           AS 
                           DECIMAL(4)) 
                                  AS NVARCHAR(5))))) 
                           + Cast(Cast(addlcessper AS DECIMAL(4)) AS NVARCHAR(5) 
                           ) 
                           + '/M' + Space(2) + ' ' 
                           + Replicate('  ', 10-Len(Ltrim(Cast(Cast(taxablevalue 
                           AS 
                           DECIMAL( 
                                  10, 2)) AS NVARCHAR(10))))) 
                           + Cast(Cast(taxablevalue AS DECIMAL(10, 2)) AS 
                           NVARCHAR 
                           (10) 
                           ) 
                           + ' ' 
                           + Replicate('  ', 10-Len(Ltrim(Cast(Cast(igstamt AS 
                           DECIMAL 
                           (10, 2) 
                                  ) AS NVARCHAR(10))))) 
                           + Cast(Cast(igstamt AS DECIMAL(10, 2)) AS NVARCHAR(10 
                           )) 
                           + ' ' 
                           + Replicate('  ', 10-Len(Cast(cessamt AS DECIMAL(10, 
                           2) 
                           ))) 
                           + Cast(Cast(cessamt AS DECIMAL(10, 2)) AS NVARCHAR(10 
                           )) 
                           + ' ' 
                           + Replicate('  ', 10-Len(Cast(addlcessamt AS DECIMAL( 
                           10 
                           , 2) 
                           ))) 
                           + Cast(Cast(addlcessamt AS DECIMAL(10, 2)) AS 
                           NVARCHAR( 
                           10)) 
                           + ' ' 
                           + Replicate('  ', 10-Len(Ltrim(Cast(Cast(total AS 
                           DECIMAL( 
                           10, 2)) 
                                  AS NVARCHAR(10))))) 
                           + Cast(Cast(total AS DECIMAL(10, 2)) AS NVARCHAR(10)) 
                           + Char(13) + Char(10)
      FROM   #gstaxsummary 

      SET @GSTTaxComp_DOS = '' 

      SELECT @GSTTaxComp_DOS = @GSTTaxComp_DOS + 'IGST' 
                               + Replicate(' ', 5-Len(Cast(Cast(igstper AS 
                               DECIMAL 
                               (5, 
                               2)) AS 
                                      NVARCHAR(5)))) 
                               + Cast(Cast(igstper AS DECIMAL(5, 2)) AS NVARCHAR 
                               (5 
                               )) 
                               + '% + Cess' 
                               + Replicate(' ', 5-Len(Cast(Cast(cessper AS 
                               DECIMAL 
                               (5, 
                               2)) AS 
                                      NVARCHAR(5)))) 
                               + Cast(Cast(cessper AS DECIMAL(5, 2)) AS NVARCHAR 
                               (5 
                               )) 
                               + '% + AddlCess ' 
                               + Replicate(' ', 5-Len(Ltrim(Cast(Cast( 
                               addlcessper 
                               AS 
                               DECIMAL( 
                                      4)) AS NVARCHAR(5))))) 
                               + Cast(Cast(addlcessper AS DECIMAL(4)) AS 
                               NVARCHAR( 
                               5)) 
                               + '/M' + Space(2) + ' ' 
                               + Replicate(' ', 10-Len(Ltrim(Cast(Cast( 
                               taxablevalue AS 
                                      DECIMAL(10, 2)) AS NVARCHAR(10))))) 
                               + Cast(Cast(taxablevalue AS DECIMAL(10, 2)) AS 
                               NVARCHAR 
                               (10)) 
                               + ' ' 
                               + Replicate(' ', 10-Len(Ltrim(Cast(Cast(igstamt 
                               AS 
                               DECIMAL(10, 
                                      2)) AS NVARCHAR(10))))) 
                               + Cast(Cast(igstamt AS DECIMAL(10, 2)) AS 
                               NVARCHAR( 
                               10)) 
                               + ' ' 
                               + Replicate(' ', 10-Len(Cast(cessamt AS DECIMAL( 
                               10, 
                               2)) 
                               )) 
                               + Cast(Cast(cessamt AS DECIMAL(10, 2)) AS 
                               NVARCHAR( 
                               10)) 
                               + ' ' 
                               + Replicate(' ', 10-Len(Cast(addlcessamt AS 
                               DECIMAL 
                               (10, 
                               2)))) 
                               + Cast(Cast(addlcessamt AS DECIMAL(10, 2)) AS 
                               NVARCHAR( 
                               10)) 
                               + ' ' 
                               + Replicate(' ', 10-Len(Ltrim(Cast(Cast(total AS 
                               DECIMAL(10, 2 
                                      )) AS NVARCHAR(10))))) 
                               + Cast(Cast(total AS DECIMAL(10, 2)) AS NVARCHAR( 
                               10 
                               )) 
                               + Space(2) 
      FROM   #gstaxsummary 

      DROP TABLE #temptaxdet 

      DROP TABLE #tempinvdet2 

      ---------------------------------------------------------------- 
      SELECT @AdjustedValue = Sum (CASE 
                                     WHEN invoiceabstract.invoicetype = 4 THEN 
                                   /*For Sales Return Adjustment*/ 
                                   ( CASE collectiondetail.documenttype 
                                       WHEN 4 THEN Isnull( 
                                       collectiondetail.adjustedamount, 0) 
                                       WHEN 5 THEN Isnull( 
                                       collectiondetail.adjustedamount, 0) 
                                       ELSE 0 
                                     END ) 
                                     ELSE 
                                       /* For Invoice Adjustment */ 
                                       CASE 
                                         WHEN collectiondetail.documentid <> 
                                              @InvNo 
                                       THEN 
                                         ( CASE collectiondetail.documenttype 
                                             WHEN 5 THEN -1 
                                             ELSE 1 
                                           END ) * Isnull( 
                                         collectiondetail.adjustedamount, 0) 
                                         ELSE 
                                           CASE 
                                             WHEN collectiondetail.documenttype 
                                                  <> 
                                                  4 
                                           THEN ( 
                                             CASE 
                                             collectiondetail.documenttype 
                                             WHEN 5 THEN -1 
                                             ELSE 1 
                                             END ) * 
                                             Isnull( 
                                             collectiondetail.adjustedamount, 0) 
                                             ELSE 0 
                                           END 
                                       END 
                                   END) 
      FROM   collectiondetail, 
             invoiceabstract 
      WHERE  collectionid = Cast(Isnull(paymentdetails, 0) AS INT) 
             AND invoiceabstract.invoiceid = @InvNo 

      SELECT @SalesTaxwithcess = Sum(stpayable) 
      FROM   invoicedetail 
      WHERE  invoiceid = @INVNO 
             AND Isnull(taxcode, 0) >= 5.00 

      SELECT @salestaxwithoutCESS = Sum(stpayable) 
      FROM   invoicedetail 
      WHERE  invoiceid = @INVNO 
             AND Isnull(taxcode, 0) < 5.00 

      SELECT @DispRefNumber = CASE 
                                WHEN Patindex(N'%[^0-9]%', referencenumber) = 0 
                              THEN 
                                referencenumber 
                                ELSE NULL 
                              END 
      FROM   invoiceabstract 
      WHERE  invoiceid = @INVNO 
             AND status & 1 <> 0 

      SELECT @SCRefNumber = CASE 
                              WHEN Patindex(N'%[^0-9]%', referencenumber) = 0 
                            THEN 
                              referencenumber 
                              ELSE NULL 
                            END 
      FROM   invoiceabstract 
      WHERE  invoiceid = @INVNO 
             AND status & 4 <> 0 

      DECLARE dispinfo CURSOR FOR 
        SELECT refnumber, 
               newrefnumber, 
               CASE 
                 WHEN ( status & 6 <> 0 ) THEN 0 
                 ELSE 1 
               END 
        FROM   dispatchabstract 
        WHERE  dispatchid IN (SELECT * 
                              FROM   dbo.Sp_splitin2rows(@DispRefNumber, N',')) 

      SET @DispRef = N'' 
      SET @SCRef = N'' 

      OPEN dispinfo 

      FETCH FROM dispinfo INTO @SCID, @DispRefNo, @bRefSC 

      IF @@fetch_status <> 0 
        BEGIN 
            DECLARE scinfo CURSOR FOR 
              SELECT podocreference 
              FROM   soabstract 
              WHERE  sonumber IN (SELECT * 
                                  FROM   dbo.Sp_splitin2rows(@SCRefNumber, N',') 
                                 ) 

            OPEN scinfo 

            FETCH FROM scinfo INTO @SCRefNo 

            WHILE @@fetch_status = 0 
              BEGIN 
                  SET @SCRef = @SCRef + N',' + @SCRefNo 

                  FETCH next FROM scinfo INTO @SCRefNo 
              END 

            CLOSE scinfo 

            DEALLOCATE scinfo 
        END 

      WHILE @@fetch_status = 0 
        BEGIN 
            IF Ltrim(@DispRefNo) <> N'' 
              SET @DispRef = @DispRef + N',' + Ltrim(@DispRefNo) 

            IF @bRefSC = 1 
              BEGIN                   
                  DECLARE scinfo CURSOR FOR 
                    SELECT podocreference 
                    FROM   soabstract 
                    WHERE  sonumber IN (SELECT * 
                                        FROM   dbo.Sp_splitin2rows(@SCID, N',')) 

                  OPEN scinfo 

                  FETCH FROM scinfo INTO @SCRefNo 

                  WHILE @@fetch_status = 0 
                    BEGIN 
                        SET @SCRef = @SCRef + N',' + @SCRefNo 

                        FETCH next FROM scinfo INTO @SCRefNo 
                    END 

                  CLOSE scinfo 

                  DEALLOCATE scinfo 
              END 
            ELSE 
              BEGIN 
                  DECLARE scinfo CURSOR FOR 
                    SELECT podocreference 
                    FROM   soabstract 
                    WHERE  sonumber IN (SELECT * 
                                        FROM 
                           dbo.Sp_splitin2rows(@DispRefNumber, 
                           N',') 
                                       ) 

                  OPEN scinfo 

                  FETCH FROM scinfo INTO @SCRefNo 

                  WHILE @@fetch_status = 0 
                    BEGIN 
                        SET @SCRef = @SCRef + N',' + @SCRefNo 

                        FETCH next FROM scinfo INTO @SCRefNo 
                    END 

                  CLOSE scinfo 

                  DEALLOCATE scinfo 
              END 

            FETCH next FROM dispinfo INTO @SCID, @DispRefNo, @bRefSC 
        END 

      CLOSE dispinfo 

      DEALLOCATE dispinfo 

      IF Len(@DispRef) > 1 
        SET @DispRef = Substring(@DispRef, 2, Len(@DispRef) - 1) 
      ELSE 
        SET @DispRef = N'' 

      IF Len(@SCRef) > 1 
        SET @SCRef = Substring(@SCRef, 2, Len(@SCRef) - 1) 
      ELSE 
        SET @SCRef = N'' 

      SELECT @ChequeNo = chequenumber, 
             @ChequeDate = chequedate, 
             @BankCode = bankmaster.bankcode, 
             @BankName = bankmaster.bankname, 
             @BranchCode = branchmaster.branchcode, 
             @BranchName = branchmaster.branchname 
      FROM   collections, 
             branchmaster, 
             bankmaster 
      WHERE  documentid = @CollectionID 
             AND collections.bankcode = bankmaster.bankcode 
             AND collections.branchcode = branchmaster.branchcode 
             AND collections.bankcode = branchmaster.bankcode 

      SELECT "Invoice Date" = CONVERT(VARCHAR(10), invoicedate, 103), 
             "Doc Ref" = invoiceabstract.docreference, 
             "Serial No" = CASE Isnull(gstflag, 0) 
                             WHEN 1 THEN Isnull(gstfulldocid, '') 
                             ELSE CASE invoicetype WHEN 1 THEN Inv.prefix WHEN 3 
                                  THEN 
                                  InvA.prefix WHEN 4 THEN 
                                  SR.prefix WHEN 5 THEN SR.prefix END + Cast( 
                                  documentid AS 
                                  NVARCHAR) 
                           END, 
             "WDPhoneNumber" = 'Phone: ' + @WDPhoneNumber, 
             "Customer Name" = company_name, 
             "Billing Address" = invoiceabstract.billingaddress, 
             "Shipping Address" =invoiceabstract.shippingaddress, 
             "Gross Value" = goodsvalue,
             "Discount Value" = productdiscount,
             "Net Value" = CASE invoiceabstract.invoicetype 
                             WHEN 4 THEN netvalue 
                             ELSE netvalue 
                           END, 
             "TaxPercentage" = 0,
             "SalesValue" =0,
             "TaxCompPercentage"=0,
             "TotalTaxAmt"=0,
             "InvoiceOutstandingDetail" = 
             dbo.Getcustomeroutstanding_windows(@InvNo), 
             "Adjusted Value" = @AdjustedValue, 
             "Salesman" = salesman.salesman_name, 
             "Balance" = CASE invoiceabstract.paymentmode 
                           WHEN 0 THEN 
                             CASE invoiceabstract.invoicetype 
                               WHEN 4 THEN ( ( netvalue + roundoffamount ) 
                                             - Isnull( 
                                             @AdjustedValue, 0) ) 
                               ELSE ( netvalue + roundoffamount ) - Isnull( 
                                    @AdjustedValue, 0) 
                             END 
                           ELSE invoiceabstract.balance 
                         END, 
             "CustomerID" = invoiceabstract.customerid + CASE WHEN 
dbo.Fn_get_pannumber(@InvNo, 'INVOICE', 'CUSTOMER')='' 
THEN '' 
ELSE ' PAN No:' + 
dbo.Fn_get_pannumber(@InvNo, 'INVOICE', 'CUSTOMER') 
END, 
"Item Count without Free" = 'No.ofItems sold: ' 
             + Cast(@ItemCountWithoutFree AS NVARCHAR( 
             3)), 
"TotTaxableGV" = Cast(Isnull(@TotTaxableGV, 0) AS DECIMAL(18, 2)), 
"Rounded Net Value" = Cast(CASE invoiceabstract.invoicetype 
              WHEN 4 THEN ( netvalue + roundoffamount 
                            - Isnull( 
                            @AdjustedValue, 0) ) 
              ELSE netvalue + roundoffamount - Isnull( 
                   @AdjustedValue, 0) 
            END AS DECIMAL(18, 2)), 
"Payment Mode" = CASE paymentmode 
    WHEN 0 THEN @CREDIT 
    WHEN 1 THEN @CASH 
    WHEN 2 THEN @CHEQUE 
    WHEN 3 THEN @DD 
  END, 
"Beat Name" = beat.description, 
"DeliveryDate" = CONVERT(VARCHAR(10), deliverydate, 103), 
"Doc Type" = docserialtype, 
"CurrentInvoicePoints" = CASE 
            WHEN Isnull(Cast(@PointsEarned AS INT), 0) 
                 > 0 
          THEN 
            'PtsEarned: ' 
            + Cast(@PointsEarned AS NVARCHAR(40)) 
            + ' Cum.Pts: ' 
            + Cast(@TotPointsEarned AS NVARCHAR(40)) 
            ELSE '' 
          END, 
"InvSchemeDiscount%" = Cast(Cast(Isnull(discountpercentage, 0) AS 
                  DECIMAL 
                  (18, 2) 
             ) AS NVARCHAR(12)), 
"InvSchemeDiscount" = Cast(Cast(Isnull(discountvalue, 0) AS 
                 DECIMAL(18, 2)) AS 
            NVARCHAR(12)), 
--'|Inv.Sch.Disc.@ ' +                     
"InvTradeDiscount%" = Cast(Cast(Isnull(additionaldiscount, 0) AS 
                 DECIMAL( 
                 18, 2)) 
            AS NVARCHAR(12)), 
"InvTradeDiscount" = Cast(Cast(Isnull(addldiscountvalue, 0) AS 
                DECIMAL(18, 2)) 
           AS NVARCHAR(12)), 
"InvCreditAdjustment" = Cast(Cast(Isnull(@AdjustedValue, 0) AS 
                   DECIMAL(18, 2)) 
              AS NVARCHAR(12)), 
"InvRoundOffAmount" = Cast(Cast(Isnull(roundoffamount, 0) AS 
                 DECIMAL(18, 2)) AS 
            NVARCHAR(12)), 
"InvNetAmountPayable" = Cast(Cast(Isnull(CASE 
                   invoiceabstract.invoicetype 
                            WHEN 4 THEN ( 
                            ( 
                            netvalue + roundoffamount ) 
                                          - 
                            Isnull( 
                            @AdjustedValue, 0 
                            ) 
                                        ) 
                            ELSE ( 
                   netvalue + roundoffamount ) - 
                                 Isnull(@AdjustedValue 
                                 , 0) 
                          END, 0) AS DECIMAL(18, 2)) 
              AS 
              NVARCHAR( 
              12)), 
"Cr.Note.Desc" = dbo.Merp_fn_getcreditnotedetails_windows(@INVNO, 1), 
"Cr.Note.Val" = dbo.Merp_fn_getcreditnotedetails_windows(@INVNO, 2), 
"Cr.Note.AdjVal" = 
dbo.Merp_fn_getcreditnotedetails_windows(@INVNO, 3), 
"Cr.Note.BalVal" = 
dbo.Merp_fn_getcreditnotedetails_windows(@INVNO, 4), 
"Cr.Note.Total" = 
dbo.Merp_fn_getcreditnotedetails_windows(@INVNO, 5), 
"Item Count" = @ItemCount, 
"TaxBrkUp" = dbo.Gettaxcompinfoforinv(@INVNO, 1, 1), 
"CompBrkUp" = dbo.Gettaxcompinfoforinv(@INVNO, 2, 1), 
"TotTax" = invoiceabstract.vattaxamount, 
"TIN/NON TIN" = (SELECT CASE Isnull(tin_number, '') 
           WHEN '' THEN 'R E T A I L  I N V O I C E' 
           ELSE 'T A X   I N V O I C E' 
         END 
  FROM   customer cu 
  WHERE  cu.customerid = customer.customerid), 
"ClosingPoints as on Date" = @ClosingPoints, 
"Target Vs Achievement" = @TargetVsAchievement, 
"CompanyGSTIN" = @CompanyGSTIN, 
"CompanyPAN" = @CompanyPAN, 
"CustomerPAN" = customer.pannumber, 
"CustomerGSTIN" = invoiceabstract.gstin, 
"CIN" = @CIN, 
"SCBilling" = SCBilling.forumstatecode, 
"SCShipping" = SCShipping.forumstatecode, 
"BillingState" = SCBilling.statename, 
"ShippingState" = SCShipping.statename, 
"CompanyState" = @CompanyState, 
"CompanySC" = @CompanySC, 
"SGST/UTGST Rate" = CASE @UTGST_flag 
       WHEN 1 THEN 'UTGST Rate' 
       ELSE 'SGST Rate' 
     END, 
"SGST/UTGST Amt" = CASE @UTGST_flag 
      WHEN 1 THEN 'UTGST Amt' 
      ELSE 'SGST Amt' 
    END, 
"S/UT GST" = CASE @UTGST_flag 
WHEN 1 THEN 'UTGST' 
ELSE 'SGST' 
END, 
"TaxDetails" = Replace(dbo.Gettaxdetails_dos (@INVNO), ';', Char(13)) 
, 
"InvoiceTotals" = '|Credit Adj.          :' 
   + Space(12-Len(Cast(Cast(Isnull(@AdjustedValue, 0) 
   AS 
   DECIMAL( 
   18, 2)) AS NVARCHAR(12)))) 
   + Cast(Cast(Isnull(@AdjustedValue, 0) AS DECIMAL(18 
   , 2) 
   ) AS 
   NVARCHAR(12)) 
   + Char(13) + Char(10) 
   + '|Round off Amt.       :' 
   + Space(12-Len(Cast(Cast(Isnull(roundoffamount, 0) 
   AS 
   DECIMAL( 
   18, 2)) AS NVARCHAR(12)))) 
   + Cast(Cast(Isnull(roundoffamount, 0) AS DECIMAL(18 
   , 2) 
   ) AS 
   NVARCHAR(12)) 
   + Char(13) + Char(10) 
   + '|Net Amt. Payable     :' 
   + Space(14-Len(Cast(Cast(Isnull(CASE 
   invoiceabstract.invoicetype WHEN 4 THEN ((netvalue 
   + 
   roundoffamount) - ( 
   Isnull(@AdjustedValue, 0))) ELSE ((netvalue + 
   roundoffamount) 
   - (Isnull(@AdjustedValue, 0))) END, 0) AS DECIMAL( 
   18, 2 
   )) AS 
   NVARCHAR(12)) + Char(13) + Char(10))) 
   + Cast(Cast(Isnull(CASE invoiceabstract.invoicetype 
   WHEN 4 
   THEN ((netvalue + roundoffamount) - (Isnull( 
   @AdjustedValue, 0) 
   )) ELSE ((netvalue + roundoffamount) - (Isnull( 
   @AdjustedValue, 
   0))) END, 0) AS DECIMAL(18, 2)) AS NVARCHAR(12)) 
   + Char(13) + Char(10), 
"CreditNoteDetails" = dbo.Merp_fn_getcreditnotedetails_dos(@INVNO), 
"CreditNoteDetails_GST" = 
dbo.Merp_fn_getcreditnotedetails_gst(@INVNO), 
"Invoice Ref" = invoiceabstract.referencenumber, 
"Net Amount Payable" = Cast(Cast(Isnull(CASE 
                  invoiceabstract.invoicetype 
                           WHEN 4 THEN ( ( 
                           netvalue + roundoffamount ) 
                                         - ( 
                                         Isnull( 
                           @AdjustedValue, 0 
                                         ) ) ) 
                           ELSE 
                  ( ( netvalue + 
                      roundoffamount ) - 
                    ( Isnull(@AdjustedValue, 
                      0) ) ) 
                         END, 0) AS DECIMAL(18, 2)) AS 
             NVARCHAR( 
             12)), 
"Total Tax Text" ='Total Tax Amount:', 
"GSTTaxCompDet" = @GSTaxCompDet, 
"GSTTaxCompDet_DOS" = @GSTaxCompDet_DOS, 
"GSTTaxCompHead" = @GSTaxCompHead, 
"GSTTaxCompHead_DOS" = @GSTaxCompHead_DOS, 
"Tax Summary Text" = @GSTTaxSumText, 
"TaxComp Text" = @GSTTaxCompText, 
"GSTTaxComp" = @GSTTaxComp, 
"Tax Summary Text_DOS" = @GSTTaxCompText_DOS, 
"GSTTaxComp_DOS" = @GSTTaxComp_DOS, 
"FSSAINO" = CASE 
WHEN customer.tngst = '' THEN '' 
ELSE 'FSSAI No. : ' + customer.tngst 
END, 
"WDFSSAINO" = @WDFSSAINO
,"LastPrintOn" = InvoiceAbstract.LastPrintOn
,"PrintCount" = InvoiceAbstract.PrintCount
FROM   invoiceabstract 
INNER JOIN customer 
ON invoiceabstract.customerid = customer.customerid 
LEFT OUTER JOIN beat 
ON invoiceabstract.beatid = beat.beatid 
INNER JOIN voucherprefix SR 
ON SR.tranid = N'SALES RETURN' 
INNER JOIN voucherprefix InvA 
ON InvA.tranid = N'INVOICE AMENDMENT' 
INNER JOIN voucherprefix Inv 
ON Inv.tranid = N'INVOICE' 
LEFT OUTER JOIN creditterm 
ON invoiceabstract.creditterm = creditterm.creditid 
LEFT OUTER JOIN salesman 
ON invoiceabstract.salesmanid = salesman.salesmanid 
LEFT OUTER JOIN salesman2 
ON invoiceabstract.salesman2 = salesman2.salesmanid 
LEFT OUTER JOIN statecode SCBilling 
ON invoiceabstract.tostatecode = SCBilling.stateid 
LEFT OUTER JOIN statecode SCShipping 
ON customer.shippingstateid = SCShipping.stateid 
WHERE  invoiceid = @INVNO 

EXEC SP_SLM_LastPrintUpdate @INVNO
END 

go 