--exec SP_ARC_Sales_Details '79853','Base UOM','%','Yes','%','%'
Exec ARC_Insert_ReportData 621, 'Sales Detail', 1, 'SP_ARC_Sales_Details', 'Click to view Sales details', 561, 0, 1, 2, 0, 0, 3, 1, 0, 0, 136, 'No'
GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * 
          FROM   sys.objects 
          WHERE  NAME = N'SP_ARC_Sales_Details') 
  BEGIN 
      DROP PROC sp_arc_sales_details 
  END 

go 

CREATE PROCEDURE [dbo].Sp_arc_sales_details (@INVOICEID    INT, 
                                             @UOMDesc      NVARCHAR(30), 
                                             @Salesman     NVARCHAR(4000) = 
'All', 
                                             @TaxCompBrkUp NVARCHAR(10) = 'No', 
                                             @CustomerID   NVARCHAR(2250), 
                                             @CustomerName NVARCHAR(2250)) 
AS 
  BEGIN 
      DECLARE @ADDNDIS AS DECIMAL(18, 6) 
      DECLARE @TRADEDIS AS DECIMAL(18, 6) 
      DECLARE @MaxCTDynamicCols INT 
      DECLARE @MaxLTDynamicCols INT 
      DECLARE @Col INT 
      DECLARE @LTColCnt INT 
      DECLARE @CTColCnt INT 
      DECLARE @Tax_Code INT 
      DECLARE @Tax_Code1 INT 
      DECLARE @SQL NVARCHAR(4000) 
      DECLARE @CompType NVARCHAR(10) 
      DECLARE @CompType1 NVARCHAR(10) 
      DECLARE @DynFields NVARCHAR(4000) 
      DECLARE @TaxCompVal DECIMAL(18, 6) 
      DECLARE @TaxCompPer DECIMAL(18, 6) 
      DECLARE @CatName NVARCHAR(510) 
      DECLARE @TaxComp_Code INT 
      DECLARE @TaxComp_desc NVARCHAR (50) 
      DECLARE @TaxPer DECIMAL(18, 6) 
      DECLARE @LTPrefix NVARCHAR(10) 
      DECLARE @CTPrefix NVARCHAR(10) 
      DECLARE @Product_Code NVARCHAR(510) 
      DECLARE @IntraPrefix NVARCHAR(10) 
      DECLARE @InterPrefix NVARCHAR(10) 
      DECLARE @CS_TaxCode INT 

      SET @LTPrefix = 'LST ' 
      SET @CTPrefix = 'CST ' 
      SET @IntraPrefix = 'Intra ' 
      SET @InterPrefix = 'Inter ' 

      SELECT @ADDNDIS = Isnull(additionaldiscount, 0), 
             @TRADEDIS = Isnull(discountpercentage, 0) 
      FROM   invoiceabstract 
      WHERE  invoiceid = @INVOICEID 

      IF @TaxCompBrkUp <> 'Yes' 
        BEGIN 
            SELECT * 
            INTO   #tmpmaindataone 
            FROM   (SELECT invoicedetail.product_code, 
                           "Item Code" = invoicedetail.product_code, 
                           "Item Name" = items.productname, 
                           "Batch" = invoicedetail.batch_number, 
                           --      "Quantity" = SUM(InvoiceDetail.Quantity), 
                           "Quantity" =( CASE 
                                           WHEN @UOMdesc = 'UOM1' THEN 
                                           Sum(invoicedetail.quantity) / 
                                           CASE 
                                             WHEN 
                                           Isnull(items.uom1_conversion, 0) = 0 
                                           THEN 1 
                                                                           ELSE 
                                           items.uom1_conversion 
                                                                         END 
                                           WHEN @UOMdesc = 'UOM2' THEN 
                                           Sum(invoicedetail.quantity) / 
                                           CASE 
                                             WHEN 
                                           Isnull(items.uom2_conversion, 0) = 0 
                                           THEN 1 
                                                                           ELSE 
                                           items.uom2_conversion 
                                                                         END 
                                           ELSE Sum(invoicedetail.quantity) 
                                         END ), 
                           "Volume" = ( CASE 
                                          WHEN @UOMdesc = 'UOM1' THEN 
                                          dbo.Sp_get_reportingqty( 
                                          Sum(invoicedetail.quantity), 
                                          CASE 
                                          WHEN 
                                        Isnull(items.uom1_conversion, 0) = 0 
                                          THEN 
                                          1 
                                                                 ELSE 
                                        items.uom1_conversion 
                                                               END) 
                                          WHEN @UOMdesc = 'UOM2' THEN 
                                          dbo.Sp_get_reportingqty( 
                                          Sum(invoicedetail.quantity), 
                                          CASE 
                                          WHEN 
                                        Isnull(items.uom2_conversion, 0) = 0 
                                          THEN 
                                          1 
                                                                 ELSE 
                                        items.uom2_conversion 
                                                               END) 
                                          ELSE Sum(invoicedetail.quantity) 
                                        END ), 
                           --"Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0), 
                           "Sales Price" = ( CASE 
                                               WHEN @UOMdesc = 'UOM1' THEN ( 
                                               invoicedetail.saleprice ) * 
                                                                           CASE 
                                               WHEN 
                   Isnull(items.uom1_conversion, 0) 
                   = 0 THEN 1 
                   ELSE 
                   items.uom1_conversion 
                   END 
                   WHEN @UOMdesc = 'UOM2' THEN ( invoicedetail.saleprice ) * 
                   CASE 
                     WHEN 
                   Isnull(items.uom2_conversion, 0) 
                   = 0 THEN 1 
                   ELSE 
                   items.uom2_conversion 
                   END 
                   ELSE ( invoicedetail.saleprice ) 
                   END ), 
                   "Invoice UOM" = (SELECT description 
                   FROM   uom 
                   WHERE  uom = invoicedetail.uom), 
                   "Invoice Qty" = Sum(invoicedetail.uomqty), 
                   "Sale Tax" = Round(( Max(invoicedetail.taxcode 
                   + invoicedetail.taxcode2) ), 2), 
                   "Tax Suffered" = Isnull(Max(invoicedetail.taxsuffered), 0), 
                   "Discount" = Sum(discountpercentage), 
                   "STCredit" = Round(( Sum(invoicedetail.taxcode) / 100.00 ) * 
                                      ( 
                                      ( ( 
                                      ( 
                   invoicedetail.saleprice * Sum( 
                   invoicedetail.quantity) ) 
                   - 
                   ( ( 
                   invoicedetail.saleprice 
                   * Sum(invoicedetail.quantity) ) * ( Sum( 
                   discountpercentage 
                   ) / 100.00 ) ) ) * ( @ADDNDIS / 100.00 ) ) + 
                   ( 
                   ( 
                   ( invoicedetail.saleprice * Sum( 
                   invoicedetail.quantity) ) 
                   - ( 
                   ( 
                   invoicedetail.saleprice * Sum( 
                   invoicedetail.quantity) ) * ( 
                   Sum 
                   ( 
                   discountpercentage) / 100.00 ) ) ) 
                   * ( @TRADEDIS / 100.00 ) ) ), 2), 
                   "Total" = Round(Sum(amount), 2), 
                   "Forum Code" = items.alias, 
                   "Tax Suffered Value" = Isnull(Sum(( invoicedetail.quantity * 
                   invoicedetail.saleprice ) * 
                   Isnull( 
                   invoicedetail.taxsuffered, 0) / 100 
                        ), 0), 
                   "Sales Tax Value" = Isnull(Sum(stpayable + cstpayable), 0), 
                   "Serial" = invoicedetail.serial, 
                   "Tax On Quantity" = taxonqty, 
                   "HSN Number" = Max(invoicedetail.hsnnumber) 
                    FROM   invoicedetail, 
                           items 
                    WHERE  invoicedetail.invoiceid = @INVOICEID 
                           AND invoicedetail.product_code = items.product_code 
                    GROUP  BY invoicedetail.product_code, 
                              items.productname, 
                              invoicedetail.batch_number, 
                              invoicedetail.saleprice, 
                              items.alias, 
                              uom1_conversion, 
                              uom2_conversion, 
                              invoicedetail.uom, 
                              invoicedetail.serial, 
                              taxonqty, 
                              invoicedetail.hsnnumber) temp 

            SELECT Product_code = product_code, 
                   "Item Code" = [item code], 
                   "Item Name" = [item name], 
                   "Batch" = [batch], 
                   "Quantity" = Sum([quantity]), 
                   "Volume" = Sum([volume]), 
                   "Sales Price" = [sales price], 
                   "Invoice UOM" = [invoice uom], 
                   "Invoice Qty" = Sum([invoice qty]), 
                   "Sale Tax" = CASE 
                                  WHEN [tax on quantity] = 1 THEN Cast( 
                                  Max([sale tax]) AS NVARCHAR) 
                                  ELSE Cast(Max([sale tax]) AS NVARCHAR) + '%' 
                                END, 
                   "Tax Suffered" = Cast(Max([tax suffered]) AS NVARCHAR) 
                                    + '%', 
                   "Discount" = Cast(Sum([discount]) AS NVARCHAR) + '%', 
                   "STCredit" = Sum([stcredit]), 
                   "Total" = Sum([total]), 
                   "Forum Code" = [forum code], 
                   "Tax Suffered Value" = Sum([tax suffered value]), 
                   "Sales Tax Value" = Sum([sales tax value]), 
                   "HSN Number" = Max([hsn number]) 
            --, "Serial" = [Serial] 
            FROM   #tmpmaindataone 
            GROUP  BY product_code, 
                      [item code], 
                      [item name], 
                      [batch], 
                      [sales price], 
                      [invoice uom], 
                      [tax on quantity], 
                      --[Sale Tax], [Tax Suffered], [Discount], 
                      [forum code], 
                      [hsn number]--, [Serial] 
        END 
      ELSE 
        BEGIN 
            SELECT * 
            INTO   #tmpmaindatatwo 
            FROM   (SELECT invoicedetail.taxid AS Tax_Code, 
                           "Item Code" = invoicedetail.product_code, 
                           "Item Name" = items.productname, 
                           "Batch" = invoicedetail.batch_number, 
                           --      "Quantity" = SUM(InvoiceDetail.Quantity), 
                           "Quantity" =( CASE 
                                           WHEN @UOMdesc = 'UOM1' THEN 
                                           Sum(invoicedetail.quantity) / 
                                           CASE 
                                             WHEN 
                                           Isnull(items.uom1_conversion, 0) = 0 
                                           THEN 1 
                                                                           ELSE 
                                           items.uom1_conversion 
                                                                         END 
                                           WHEN @UOMdesc = 'UOM2' THEN 
                                           Sum(invoicedetail.quantity) / 
                                           CASE 
                                             WHEN 
                                           Isnull(items.uom2_conversion, 0) = 0 
                                           THEN 1 
                                                                           ELSE 
                                           items.uom2_conversion 
                                                                         END 
                                           ELSE Sum(invoicedetail.quantity) 
                                         END ), 
                           "Volume" = ( CASE 
                                          WHEN @UOMdesc = 'UOM1' THEN 
                                          dbo.Sp_get_reportingqty( 
                                          Sum(invoicedetail.quantity), 
                                          CASE 
                                          WHEN 
                                        Isnull(items.uom1_conversion, 0) = 0 
                                          THEN 
                                          1 
                                                                 ELSE 
                                        items.uom1_conversion 
                                                               END) 
                                          WHEN @UOMdesc = 'UOM2' THEN 
                                          dbo.Sp_get_reportingqty( 
                                          Sum(invoicedetail.quantity), 
                                          CASE 
                                          WHEN 
                                        Isnull(items.uom2_conversion, 0) = 0 
                                          THEN 
                                          1 
                                                                 ELSE 
                                        items.uom2_conversion 
                                                               END) 
                                          ELSE Sum(invoicedetail.quantity) 
                                        END ), 
                           --      "Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0), 
                           "Sales Price" = ( CASE 
                                               WHEN @UOMdesc = 'UOM1' THEN ( 
                                               invoicedetail.saleprice ) * 
                                                                           CASE 
                                               WHEN 
                   Isnull(items.uom1_conversion, 0) 
                   = 0 THEN 1 
                   ELSE 
                   items.uom1_conversion 
                   END 
                   WHEN @UOMdesc = 'UOM2' THEN ( invoicedetail.saleprice ) * 
                   CASE 
                     WHEN 
                   Isnull(items.uom2_conversion, 0) 
                   = 0 THEN 1 
                   ELSE 
                   items.uom2_conversion 
                   END 
                   ELSE ( invoicedetail.saleprice ) 
                   END ), 
                   "Invoice UOM" = (SELECT description 
                   FROM   uom 
                   WHERE  uom = invoicedetail.uom), 
                   "Invoice Qty" = Sum(invoicedetail.uomqty), 
                   "Sale Tax" = Round(( Max(invoicedetail.taxcode 
                   + invoicedetail.taxcode2) ), 2), 
                   "Tax Suffered" = Isnull(Max(invoicedetail.taxsuffered), 0), 
                   "Discount" = Sum(discountpercentage), 
                   "STCredit" = Round(( Sum(invoicedetail.taxcode) / 100.00 ) * 
                                      ( 
                                      ( ( 
                                      ( 
                   invoicedetail.saleprice * Sum( 
                   invoicedetail.quantity) ) 
                   - 
                   ( ( 
                   invoicedetail.saleprice 
                   * Sum(invoicedetail.quantity) ) * ( Sum( 
                   discountpercentage 
                   ) / 100.00 ) ) ) * ( @ADDNDIS / 100.00 ) ) + 
                   ( 
                   ( 
                   ( invoicedetail.saleprice * Sum( 
                   invoicedetail.quantity) ) 
                   - ( 
                   ( 
                   invoicedetail.saleprice * Sum( 
                   invoicedetail.quantity) ) * ( 
                   Sum 
                   ( 
                   discountpercentage) / 100.00 ) ) ) 
                   * ( @TRADEDIS / 100.00 ) ) ), 2), 
                   "Total" = Round(Sum(amount), 2), 
                   "Forum Code" = items.alias, 
                   "Tax Suffered Value" = Isnull(Sum(( invoicedetail.quantity * 
                   invoicedetail.saleprice ) * 
                   Isnull( 
                   invoicedetail.taxsuffered, 0) / 100 
                        ), 0), 
                   "Sales Tax Value" = Isnull(Sum(stpayable + cstpayable), 0), 
                   "Serial" = invoicedetail.serial, 
                   "Tax On Quantity" = taxonqty, 
                   "HSN Number" = Max(invoicedetail.hsnnumber) 
                    FROM   invoicedetail, 
                           items 
                    WHERE  invoicedetail.invoiceid = @INVOICEID 
                           AND invoicedetail.product_code = items.product_code 
                    GROUP  BY invoicedetail.taxid, 
                              invoicedetail.product_code, 
                              items.productname, 
                              invoicedetail.batch_number, 
                              invoicedetail.saleprice, 
                              items.alias, 
                              uom1_conversion, 
                              uom2_conversion, 
                              invoicedetail.uom, 
                              invoicedetail.serial, 
                              taxonqty) tmp 

            SELECT * 
            INTO   #tmpmaindata 
            FROM   (SELECT Tax_Code = tax_code, 
                           "Item Code" = [item code], 
                           "Item Name" = [item name], 
                           "Batch" = [batch], 
                           "Quantity" = Sum([quantity]), 
                           "Volume" = Sum([volume]), 
                           "Sales Price" = [sales price], 
                           "Invoice UOM" = [invoice uom], 
                           "Invoice Qty" = Sum([invoice qty]), 
                           "Sale Tax" = CASE 
                                          WHEN [tax on quantity] = 1 THEN Cast( 
                                          Max([sale tax]) AS NVARCHAR) 
                                          ELSE Cast(Max([sale tax]) AS NVARCHAR) 
                                               + 
                                               '%' 
                                        END, 
                           "Tax Suffered" = Cast(Max([tax suffered]) AS NVARCHAR 
                                            ) 
                                            + '%', 
                           "Discount" = Cast(Sum([discount]) AS NVARCHAR) + '%', 
                           "STCredit" = Sum([stcredit]), 
                           "Total" = Sum([total]), 
                           "Forum Code" = [forum code], 
                           "Tax Suffered Value" = Sum([tax suffered value]), 
                           "Sales Tax Value" = Sum([sales tax value]) 
                           --, "Serial" = [Serial] 
                           , 
                           "HSN Number" =Max([hsn number]) 
                    FROM   #tmpmaindatatwo 
                    GROUP  BY tax_code, 
                              [item code], 
                              [item name], 
                              [batch], 
                              [sales price], 
                              [invoice uom], 
                              [tax on quantity], 
                              --[Sale Tax], [Tax Suffered], [Discount], 
                              [forum code], 
                              [hsn number]--, [Serial] 
                   ) temp2 

            SELECT * 
            INTO   #tmpcompwisedata 
            FROM   (SELECT InvoiceDetail.product_code, 
                           invoicetaxcomponents.tax_component_code, 
                           taxcomponentdetail.taxcomponent_desc, 
                           "CS_TaxCode"=tax.cs_taxcode, 
                           invoicetaxcomponents.tax_percentage AS CompWiseTaxPer 
                           , 
                           Sum(tax_value) 
                           AS CompWiseTax, 
                           CASE 
                             WHEN Sum(Isnull(cstpayable, 0)) <> 0 THEN @CTPrefix 
                             --CST Component 
                             ELSE @LTPrefix 
                           END                                 AS CompType, 
                           InvoiceDetail.taxid                 AS Tax_Code 
                    FROM   (SELECT invoicedetail.invoiceid, 
                                   invoicedetail.product_code, 
                                   invoicedetail.taxid, 
                                   Sum(invoicedetail.cstpayable) AS CSTPayable 
                            FROM   invoicedetail 
                            WHERE  invoicedetail.invoiceid = @InvoiceID 
                            GROUP  BY invoicedetail.invoiceid, 
                                      invoicedetail.product_code, 
                                      invoicedetail.taxid) InvoiceDetail, 
                           items, 
                           invoicetaxcomponents, 
                           taxcomponentdetail, 
                           tax 
                    WHERE  InvoiceDetail.invoiceid = @INVOICEID 
                           AND InvoiceDetail.invoiceid = 
                               invoicetaxcomponents.invoiceid 
                           AND items.product_code = 
                               invoicetaxcomponents.product_code 
                           AND InvoiceDetail.product_code = items.product_code 
                           AND InvoiceDetail.taxid = 
                               invoicetaxcomponents.tax_code 
                           AND taxcomponentdetail.taxcomponent_code = 
                               invoicetaxcomponents.tax_component_code 
                    --and TaxComponentDetail.TaxComponent_desc = InvoiceTaxComponents.Tax_Code 
                    GROUP  BY InvoiceDetail.product_code, 
                              invoicetaxcomponents.tax_component_code, 
                              invoicetaxcomponents.tax_percentage, 
                              InvoiceDetail.taxid, 
                              taxcomponentdetail.taxcomponent_desc, 
                              tax.cs_taxcode) tmp 

            --Select * from  #tmpCompWiseData 
            ----------Find the No Of columns To be introduced 
            SELECT TOP 1 @MaxLTDynamicCols = Count(tax_component_code) 
            FROM   #tmpcompwisedata 
            WHERE  comptype = @LTPrefix 
                   AND compwisetax > 0 
                   AND Isnull(cs_taxcode, 0) = 0 
            GROUP  BY product_code 
            ORDER  BY Count(tax_component_code) DESC 

            SELECT TOP 1 @MaxCTDynamicCols = Count(tax_component_code) 
            FROM   #tmpcompwisedata 
            WHERE  comptype = @CTPrefix 
                   AND compwisetax > 0 
                   AND Isnull(cs_taxcode, 0) = 0 
            GROUP  BY product_code 
            ORDER  BY Count(tax_component_code) DESC 

            ----------Add the columns in main data table 
            IF @MaxLTDynamicCols > 0 
                OR @MaxCTDynamicCols > 0 
              BEGIN 
                  SET @Col = 1 --Dynamic Columns 
                  SET @DynFields = '' 

                  --LT Columns 
                  WHILE @Col <= @MaxLTDynamicCols 
                    BEGIN 
                        SET @SQL = N'Alter Table #tmpMainData Add [' 
                                   + @LTPrefix + 'Component ' 
                                   + Cast(@Col AS NVARCHAR) 
                                   + N' Tax%] decimal(18,6) default 0;' 
                        SET @SQL = @SQL + N'Alter Table #tmpMainData Add [' 
                                   + @LTPrefix + 'Component ' 
                                   + Cast(@Col AS NVARCHAR) 
                                   + N' Tax Amount] decimal(18,6) default 0;' 

                        EXEC(@SQL) 

                        SET @SQL = N'Update #tmpMainData set [' + @LTPrefix 
                                   + 'Component ' + Cast(@Col AS NVARCHAR) 
                                   + N' Tax%] = 0;' 
                        SET @SQL = @SQL + N'Update #tmpMainData set [' 
                                   + @LTPrefix + 'Component ' 
                                   + Cast(@Col AS NVARCHAR) 
                                   + N' Tax Amount] = 0;' 

                        EXEC(@SQL) 

                        SET @Col = @Col + 1 
                    --  end 
                    END 

                  SET @Col = 1 

                  --CT Columns 
                  WHILE @Col <= @MaxCTDynamicCols 
                    BEGIN 
                        SET @SQL = N'Alter Table #tmpMainData Add [' 
                                   + @CTPrefix + 'Component ' 
                                   + Cast(@Col AS NVARCHAR) 
                                   + N' Tax%] decimal(18,6) default 0;' 
                        SET @SQL = @SQL + N'Alter Table #tmpMainData Add [' 
                                   + @CTPrefix + 'Component ' 
                                   + Cast(@Col AS NVARCHAR) 
                                   + N' Tax Amount] decimal(18,6) default 0;' 

                        EXEC(@SQL) 

                        SET @SQL = N'Update #tmpMainData set [' + @CTPrefix 
                                   + 'Component ' + Cast(@Col AS NVARCHAR) 
                                   + N' Tax%] = 0;' 
                        SET @SQL = @SQL + N'Update #tmpMainData set [' 
                                   + @CTPrefix + 'Component ' 
                                   + Cast(@Col AS NVARCHAR) 
                                   + N' Tax Amount] = 0;' 

                        EXEC(@SQL) 

                        SET @Col = @Col + 1 
                    --  end 
                    END 

                  ----------For every Category and percentage combination 
                  DECLARE taxfetch CURSOR FOR 
                    SELECT product_code 
                    FROM   #tmpcompwisedata 
                    WHERE  cs_taxcode = 0 
                    GROUP  BY product_code 

                  OPEN taxfetch 

                  FETCH next FROM taxfetch INTO @Product_Code 

                  WHILE( @@FETCH_STATUS = 0 ) 
                    BEGIN 
                        --get the componentwise tax value in the order of Tax_Component_Code 
                        SET @col = 1 --Dynamic Column 
                        SET @LTColCnt = 1 
                        SET @CTColCnt = 1 

                        DECLARE taxdata CURSOR FOR 
                          SELECT compwisetax, 
                                 compwisetaxper, 
                                 comptype, 
                                 tax_code, 
                                 taxcomponent_desc, 
                                 tax_component_code 
                          FROM   #tmpcompwisedata 
                          WHERE  product_code = @Product_Code 
                                 AND cs_taxcode = 0 
                          ORDER  BY tax_component_code, 
                                    comptype DESC 

                        OPEN taxdata 

                        FETCH next FROM taxdata INTO @TaxCompVal, @TaxCompPer, 
                        @CompType1, 
                        @Tax_Code1, @TaxComp_desc, @TaxComp_Code 

                        WHILE( @@FETCH_STATUS = 0 ) 
                          BEGIN 
                              --update the dynamic cols 
                              IF @CompType1 = @CTPrefix 
                                BEGIN 
                                    --Update Value 
                                    -- 
                                    SET @SQL=N'update #tmpMainData set [' + 
                                             @CTPrefix 
                                             + 'Component ' + Cast(@CTColCnt AS 
                                             NVARCHAR 
                                             ) 
                                             + N' Tax Amount] = ' 
                                             + Cast(@TaxCompVal AS NVARCHAR) 
                                    SET @SQL= @SQL + N' where [Item Code] = ''' 
                                              + Cast(@Product_Code AS NVARCHAR) 
                                              + N''' and Tax_Code = ''' 
                                              + Cast(@Tax_Code1 AS NVARCHAR) + 
                                              N'''' 

                                    EXEC(@SQL) 

                                    --Update Percentage 
                                    SET @SQL=N'update #tmpMainData set [' + 
                                             @CTPrefix 
                                             + 'Component ' + Cast(@CTColCnt AS 
                                             NVARCHAR 
                                             ) 
                                             + N' Tax%] = ' 
                                             + Cast(@TaxCompPer AS NVARCHAR) 
                                    SET @SQL= @SQL + N' where [Item Code] = ''' 
                                              + Cast(@Product_Code AS NVARCHAR) 
                                              + N''' and Tax_Code = ''' 
                                              + Cast(@Tax_Code1 AS NVARCHAR) + 
                                              N'''' 

                                    EXEC(@SQL) 

                                    SET @CTColCnt = @CTColCnt + 1 
                                -- end 
                                END 
                              ELSE 
                                BEGIN 
                                    --Update Value 
                                    SET @SQL=N'update #tmpMainData set [' + 
                                             @LTPrefix 
                                             + 'Component ' + Cast(@LTColCnt AS 
                                             NVARCHAR 
                                             ) 
                                             + N' Tax Amount] = ' 
                                             + Cast(@TaxCompVal AS NVARCHAR) 
                                    SET @SQL= @SQL + N' where [Item Code] = ''' 
                                              + Cast(@Product_Code AS NVARCHAR) 
                                              + N''' and Tax_Code = ''' 
                                              + Cast(@Tax_Code1 AS NVARCHAR) + 
                                              N'''' 

                                    EXEC(@SQL) 

                                    --Update Percentage 
                                    SET @SQL=N'update #tmpMainData set [' + 
                                             @LTPrefix 
                                             + 'Component ' + Cast(@LTColCnt AS 
                                             NVARCHAR 
                                             ) 
                                             + N' Tax%] = ' 
                                             + Cast(@TaxCompPer AS NVARCHAR) 
                                    SET @SQL= @SQL + N' where [Item Code] = ''' 
                                              + Cast(@Product_Code AS NVARCHAR) 
                                              + N''' and Tax_Code = ''' 
                                              + Cast(@Tax_Code1 AS NVARCHAR) + 
                                              N'''' 

                                    EXEC(@SQL) 

                                    SET @LTColCnt = @LTColCnt + 1 
                                --  end 
                                END 

                              SET @Col = @Col + 1 

                              FETCH next FROM taxdata INTO @TaxCompVal, 
                              @TaxCompPer, 
                              @CompType1, 
                              @Tax_Code1, @TaxComp_desc, @TaxComp_Code 
                          END 

                        CLOSE taxdata 

                        DEALLOCATE taxdata 

                        FETCH next FROM taxfetch INTO @Product_Code 
                    END 

                  CLOSE taxfetch 

                  DEALLOCATE taxfetch 
              END 

            --------------------------------------------------------------------------------------------------------- second cursor 
            DECLARE taxdata CURSOR FOR 
              SELECT DISTINCT taxcomponent_desc 
              FROM   #tmpcompwisedata 
              WHERE  cs_taxcode > 0 

            --order by Tax_Component_Code, CompType Desc 
            OPEN taxdata 

            FETCH next FROM taxdata INTO @TaxComp_desc 

            WHILE( @@FETCH_STATUS = 0 ) 
              BEGIN 
                  --update the dynamic cols 
                  -- if @CompType1  = @CTPrefix 
                  BEGIN 
                      --Update Value 
                      SET @SQL = N'Alter Table #tmpMainData Add [' 
                                 + @TaxComp_desc 
                                 + N' Tax Amount] decimal(18,6) default 0;' 
                      SET @SQL = @SQL + N'Alter Table #tmpMainData Add [' 
                                 + @TaxComp_desc 
                                 + N' Tax Rate] decimal(18,6) default 0;' 

                      EXEC(@SQL) 

                      PRINT @SQL 

                      --  Set @SQL=N'update #tmpMainData set [' +@TaxComp_desc + N' Tax Amount] = ' + Cast(@TaxCompVal as nvarchar)
                      -- Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N''''--and Tax_Component_code = ''' + CAST (@TaxComp_Code as int) 
                      --  Exec(@SQL) 
                      --  --Update Percentage 
                      --Set @SQL=N'update #tmpMainData set ['+@TaxComp_desc+ N'TaxRate] = ' + Cast(@TaxCompPer as nvarchar)
                      --Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N''''--and Tax_Component_code = ''' + CAST (@TaxComp_Code as int) 
                      --  Exec(@SQL) 
                      SET @CTColCnt = @CTColCnt + 1 
                  -- end 
                  END 

                  -- Else 
                  --              Begin 
                  --                   --Update Value 
                  --Set @SQL = @SQL + N'Alter Table #tmpMainData Add ['+@TaxComp_desc + N' Tax Amount] decimal(18,6) default 0;'
                  --Set @SQL = N'Alter Table #tmpMainData Add ['+@TaxComp_desc+ N'TaxRate] decimal(18,6) default 0;'
                  --Exec(@SQL) 
                  --                  Set @SQL=N'update #tmpMainData set ['+@TaxComp_desc + N' Tax Amount] = ' + Cast(@TaxCompVal as nvarchar)
                  --                 Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''''-- and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N'''and Tax_Component_code = ''' + CAST (@TaxComp_Code as int)
                  --                   Exec(@SQL) 
                  --                   --Update Percentage 
                  --                  Set @SQL=N'update #tmpMainData set ['+@TaxComp_desc+ N'TaxRate] = ' + Cast(@TaxCompPer as nvarchar)
                  --                  Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' '--and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N'''and Tax_Component_code = ''' + CAST (@TaxComp_Code as int)
                  --                   Exec(@SQL) 
                  --                   set @LTColCnt = @LTColCnt + 1 
                  --                 --  end 
                  --              End 
                  SET @Col = @Col + 1 

                  FETCH next FROM taxdata INTO @TaxComp_desc 
              END 

            CLOSE taxdata 

            DEALLOCATE taxdata 

            DECLARE taxfetch CURSOR FOR 
              SELECT product_code 
              FROM   #tmpcompwisedata 
              WHERE  cs_taxcode > 0 
              GROUP  BY product_code 

            OPEN taxfetch 

            FETCH next FROM taxfetch INTO @Product_Code 

            WHILE( @@FETCH_STATUS = 0 ) 
              BEGIN 
                  --get the componentwise tax value in the order of Tax_Component_Code 
                  SET @col = 1 --Dynamic Column 
                  SET @LTColCnt = 1 
                  SET @CTColCnt = 1 

                  DECLARE taxdata CURSOR FOR 
                    SELECT compwisetax, 
                           compwisetaxper, 
                           comptype, 
                           tax_code, 
                           taxcomponent_desc, 
                           tax_component_code 
                    FROM   #tmpcompwisedata 
                    WHERE  product_code = @Product_Code 
                           AND cs_taxcode > 0 
                    ORDER  BY tax_component_code, 
                              comptype DESC 

                  OPEN taxdata 

                  FETCH next FROM taxdata INTO @TaxCompVal, @TaxCompPer, 
                  @CompType1, 
                  @Tax_Code1, @TaxComp_desc, @TaxComp_Code 

                  WHILE( @@FETCH_STATUS = 0 ) 
                    BEGIN 
                        --update the dynamic cols 
                        -- if @CompType1  = @CTPrefix 
                        BEGIN 
                            --Update Value 
                            --                  Set @SQL = @SQL + N'Alter Table #tmpMainData Add [' +@TaxComp_desc + N' Tax Amount] decimal(18,6) default 0;'
                            --                  Set @SQL = N'Alter Table #tmpMainData Add ['+@TaxComp_desc+ N'TaxRate] decimal(18,6) default 0;'
                            --Exec(@SQL) 
                            SET @SQL=N'update #tmpMainData set [' 
                                     + @TaxComp_desc + N' Tax Amount] = ' 
                                     + Cast(@TaxCompVal AS NVARCHAR) 
                            SET @SQL= @SQL + N' where [Item Code] = ''' 
                                      + Cast(@Product_Code AS NVARCHAR) 
                                      + N''' and Tax_Code = ''' 
                                      + Cast(@Tax_Code1 AS NVARCHAR) + N'''' 
                            --and Tax_Component_code = ''' + CAST (@TaxComp_Code as int) 

                            EXEC(@SQL) 

                            PRINT @SQL 

                            --Update Percentage 
                            SET @SQL=N'update #tmpMainData set [' 
                                     + @TaxComp_desc + N' Tax Rate] = ' 
                                     + Cast(@TaxCompPer AS NVARCHAR) 
                            SET @SQL= @SQL + N' where [Item Code] = ''' 
                                      + Cast(@Product_Code AS NVARCHAR) 
                                      + N''' and Tax_Code = ''' 
                                      + Cast(@Tax_Code1 AS NVARCHAR) + N'''' 
                            --and Tax_Component_code = ''' + CAST (@TaxComp_Code as int) 

                            EXEC(@SQL) 

                            PRINT @SQL 

                            SET @CTColCnt = @CTColCnt + 1 
                        -- end 
                        END 

                        -- Else 
                        --              Begin 
                        --                   --Update Value 
                        --Set @SQL = @SQL + N'Alter Table #tmpMainData Add ['+@TaxComp_desc + N' Tax Amount] decimal(18,6) default 0;'
                        --Set @SQL = N'Alter Table #tmpMainData Add ['+@TaxComp_desc+ N'TaxRate] decimal(18,6) default 0;'
                        --Exec(@SQL) 
                        --                  Set @SQL=N'update #tmpMainData set ['+@TaxComp_desc + N' Tax Amount] = ' + Cast(@TaxCompVal as nvarchar)
                        --                 Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''''-- and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N'''and Tax_Component_code = ''' + CAST (@TaxComp_Code as int)
                        --                   Exec(@SQL) 
                        --                   --Update Percentage 
                        --                  Set @SQL=N'update #tmpMainData set ['+@TaxComp_desc+ N'TaxRate] = ' + Cast(@TaxCompPer as nvarchar)
                        --                  Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' '--and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N'''and Tax_Component_code = ''' + CAST (@TaxComp_Code as int)
                        --                   Exec(@SQL) 
                        --                   set @LTColCnt = @LTColCnt + 1 
                        --                 --  end 
                        --              End 
                        SET @Col = @Col + 1 

                        FETCH next FROM taxdata INTO @TaxCompVal, @TaxCompPer, 
                        @CompType1, 
                        @Tax_Code1, @TaxComp_desc, @TaxComp_Code 
                    END 

                  CLOSE taxdata 

                  DEALLOCATE taxdata 

                  FETCH next FROM taxfetch INTO @Product_Code 
              END 

            CLOSE taxfetch 

            DEALLOCATE taxfetch 

            SELECT * 
            FROM   #tmpmaindata 

            DROP TABLE #tmpmaindata 

            DROP TABLE #tmpcompwisedata 

            DROP TABLE #tmpmaindatatwo 
        END 
  END 

go 