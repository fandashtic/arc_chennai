--Exec SP_ARC_SalesReturns_Detail '79928|1', '|', 'Base UOM'
Exec ARC_Insert_ReportData 623, 'Sales Return Detail', 1, 'SP_ARC_SalesReturns_Detail', 'Click to view Sales Return Detail', 622, 0, 1, 2, 0, 0, 0, 1, 0, 0, 170, 'No'
GO
--Exec ARC_GetUnusedReportId 
IF EXISTS(SELECT * 
          FROM   sys.objects 
          WHERE  NAME = N'SP_ARC_SalesReturns_Detail') 
  BEGIN 
      DROP PROC [SP_ARC_SalesReturns_Detail] 
  END 
go 

CREATE PROCEDURE [dbo].[Sp_arc_salesreturns_detail] (@AbstractData NVARCHAR(500) 
, 
                                                     @SplitType    NVARCHAR(500 
), 
                                                     @UOMDesc      NVARCHAR(30)) 
AS 
  BEGIN 
      SET dateformat dmy 

      DECLARE @ID INT 
      DECLARE @Type NVARCHAR(255) 

      SET @ID=Substring(@AbstractData, 1, Charindex('|', @AbstractData) - 1) 
      SET @Type=Substring(@AbstractData, Charindex('|', @AbstractData) + 1, Len( 
                @AbstractData)) 

      CREATE TABLE #tempsalesreturndd_detail 
        ( 
           [INVOICE ID] INT, 
           [ITEM CODE]  NVARCHAR(15) COLLATE sql_latin1_general_cp1_ci_as, 
           [ITEM NAME]  NVARCHAR(255) COLLATE sql_latin1_general_cp1_ci_as, 
           [BATCH NO]   NVARCHAR(128) COLLATE sql_latin1_general_cp1_ci_as, 
           [UOM]        NVARCHAR(255) COLLATE sql_latin1_general_cp1_ci_as, 
           [QUANTITY]   DECIMAL(18, 6), 
           [VALUE]      DECIMAL(18, 6), 
           [REASON]     NVARCHAR(100) COLLATE sql_latin1_general_cp1_ci_as, 
        ) 

      --IF @Type = 'Sales Return - Damages' 
      IF @Type = '2' 
        BEGIN 
            INSERT INTO #tempsalesreturndd_detail 
                        ([invoice id], 
                         [item code], 
                         [item name], 
                         [batch no], 
                         [uom], 
                         [quantity], 
                         [value], 
                         [reason]) 
            SELECT invoiceid, 
                   invoicedetail.product_code, 
                   items.productname, 
                   batch_number, 
                   CASE 
                     WHEN @UOMdesc = 'UOM1' THEN (SELECT description 
                                                  FROM   uom  WITH (NOLOCK)
                                                  WHERE  uom = items.uom1) 
                     WHEN @UOMdesc = 'UOM2' THEN (SELECT description 
                                                  FROM   uom  WITH (NOLOCK)
                                                  WHERE  uom = items.uom2) 
                     ELSE (SELECT description 
                           FROM   uom  WITH (NOLOCK)
                           WHERE  uom = items.uom) 
                   END, 
                   "Quantity" = CASE 
                                  WHEN @UOMdesc = 'UOM1' THEN 
                                  Sum(invoicedetail.quantity) / 
                                                                CASE 
                                                                  WHEN 
                                  Isnull(Max(items.uom1_conversion), 0) 
                                  = 0 THEN 
                                                                  1 
                                                                  ELSE 
                                  Max(items.uom1_conversion) 
                                                                END 
                                  WHEN @UOMdesc = 'UOM2' THEN 
                                  Sum(invoicedetail.quantity) / 
                                                                CASE 
                                                                  WHEN 
                                  Isnull(Max(items.uom2_conversion), 0) 
                                  = 0 THEN 
                                                                  1 
                                                                  ELSE 
                                  Max(items.uom2_conversion) 
                                                                END 
                                  ELSE Sum(invoicedetail.quantity) 
                                END, 
                   ( Sum(invoicedetail.quantity) * invoicedetail.saleprice ) AS 
                   Value, 
                   reasonmaster.reason_description 
            FROM   invoicedetail  WITH (NOLOCK), 
                   items  WITH (NOLOCK), 
                   reasonmaster  WITH (NOLOCK)
            WHERE  invoicedetail.product_code = items.product_code 
                   AND invoicedetail.reasonid = reasonmaster.reason_type_id 
                   AND invoiceid = @ID 
            GROUP  BY invoiceid, 
                      invoicedetail.product_code, 
                      items.productname, 
                      batch_number, 
                      reasonmaster.reason_description, 
                      invoicedetail.saleprice, 
                      items.uom1, 
                      items.uom2, 
                      items.uom 
        END 
      --else if @Type = 'Sales Return - Saleable' 
      ELSE IF @Type = '1' 
        BEGIN 
            INSERT INTO #tempsalesreturndd_detail 
                        ([invoice id], 
                         [item code], 
                         [item name], 
                         [batch no], 
                         [uom], 
                         [quantity], 
                         [value], 
                         [reason]) 
            SELECT invoiceid, 
                   invoicedetail.product_code, 
                   items.productname, 
                   batch_number, 
                   CASE 
                     WHEN @UOMdesc = 'UOM1' THEN (SELECT description 
                                                  FROM   uom  WITH (NOLOCK)
                                                  WHERE  uom = items.uom1) 
                     WHEN @UOMdesc = 'UOM2' THEN (SELECT description 
                                                  FROM   uom  WITH (NOLOCK)
                                                  WHERE  uom = items.uom2) 
                     ELSE (SELECT description 
                           FROM   uom  WITH (NOLOCK)
                           WHERE  uom = items.uom) 
                   END, 
                   "Quantity" = CASE 
                                  WHEN @UOMdesc = 'UOM1' THEN 
                                  Sum(invoicedetail.quantity) / 
                                                                CASE 
                                                                  WHEN 
                                  Isnull(Max(items.uom1_conversion), 0) 
                                  = 0 THEN 
                                                                  1 
                                                                  ELSE 
                                  Max(items.uom1_conversion) 
                                                                END 
                                  WHEN @UOMdesc = 'UOM2' THEN 
                                  Sum(invoicedetail.quantity) / 
                                                                CASE 
                                                                  WHEN 
                                  Isnull(Max(items.uom2_conversion), 0) 
                                  = 0 THEN 
                                                                  1 
                                                                  ELSE 
                                  Max(items.uom2_conversion) 
                                                                END 
                                  ELSE Sum(invoicedetail.quantity) 
                                END, 
                   ( Sum(invoicedetail.quantity) * invoicedetail.saleprice ) AS 
                   Value, 
                   reasonmaster.reason_description 
            FROM   invoicedetail  WITH (NOLOCK), 
                   items  WITH (NOLOCK), 
                   reasonmaster  WITH (NOLOCK) 
            WHERE  invoicedetail.product_code = items.product_code 
                   AND invoicedetail.reasonid = reasonmaster.reason_type_id 
                   AND invoiceid = @ID 
            GROUP  BY invoiceid, 
                      invoicedetail.product_code, 
                      items.productname, 
                      batch_number, 
                      reasonmaster.reason_description, 
                      invoicedetail.saleprice, 
                      items.uom1, 
                      items.uom2, 
                      items.uom 
        END 
      --else if @Type = 'Godown Damage' 
      ELSE IF @Type = '3' 
          OR @Type = '4' 
        BEGIN 
            INSERT INTO #tempsalesreturndd_detail 
                        ([invoice id], 
                         [item code], 
                         [item name], 
                         [batch no], 
                         [uom], 
                         [quantity], 
                         [value], 
                         [reason]) 
            SELECT @ID         AS InvoiceID, 
                   sa.product_code, 
                   items.productname, 
                   sa.batch_number, 
                   CASE 
                     WHEN @UOMdesc = 'UOM1' THEN (SELECT description 
                                                  FROM   uom  WITH (NOLOCK)
                                                  WHERE  uom = items.uom1) 
                     WHEN @UOMdesc = 'UOM2' THEN (SELECT description 
                                                  FROM   uom  WITH (NOLOCK)
                                                  WHERE  uom = items.uom2) 
                     ELSE (SELECT description 
                           FROM   uom  WITH (NOLOCK)
                           WHERE  uom = items.uom) 
                   END, 
                   "Quantity" = CASE 
                                  WHEN @UOMdesc = 'UOM1' THEN Sum(sa.quantity) / 
                                  CASE 
                                    WHEN 
                                  Isnull(items.uom1_conversion, 0) = 0 THEN 
                                    1 
                                                       ELSE 
                                  items.uom1_conversion 
                                                     END 
                                  WHEN @UOMdesc = 'UOM2' THEN Sum(sa.quantity) / 
                                  CASE 
                                    WHEN 
                                  Isnull(items.uom2_conversion, 0) = 0 THEN 
                                    1 
                                                       ELSE 
                                  items.uom2_conversion 
                                                     END 
                                  ELSE Sum(sa.quantity) 
                                END, 
                   ( sa.rate ) AS Value, 
                   reasonmaster.reason_description 
            FROM   stockadjustmentabstract saa  WITH (NOLOCK), 
                   stockadjustment sa  WITH (NOLOCK), 
                   items  WITH (NOLOCK), 
                   reasonmaster  WITH (NOLOCK)
            WHERE  sa.serialno = saa.adjustmentid 
                   AND sa.product_code = items.product_code 
                   AND sa.reasonid = reasonmaster.reason_type_id 
                   AND saa.adjustmentid = @ID 
            GROUP  BY sa.product_code, 
                      items.productname, 
                      sa.batch_number, 
                      reasonmaster.reason_description, 
                      items.uom1_conversion, 
                      items.uom2_conversion, 
                      sa.rate, 
                      items.uom1, 
                      items.uom2, 
                      items.uom 
        END 

      SELECT 
	  [INVOICE ID], [ITEM CODE], [ITEM NAME], 
	  dbo.fn_Arc_GetCategoryGroup(P.CategoryGroup) [CATEGORY GROUP], 
	  dbo.fn_Arc_GetCategory(P.Category) CATEGORY, 
	  dbo.fn_Arc_GetItemFamily(P.ItemFamily) [ITEM FAMILY], 
	  dbo.fn_Arc_GetItemSubFamily(P.ItemSubFamily) [ITEM SUB FAMILY], 
	  dbo.fn_Arc_GetItemGroup(P.ItemGroup) [ITEM GROUP],
	  [BATCH NO], 
	  [UOM], 
	  [QUANTITY], 
	  [VALUE], 
	  [REASON]

      FROM   #tempsalesreturndd_detail I WITH (NOLOCK)
	  LEFT OUTER JOIN Product_Mappings P WITH (NOLOCK) ON P.Product_Code = I.[ITEM CODE]
      ORDER  BY [item code], 
                [reason] 

      DROP TABLE #tempsalesreturndd_detail 
  END 
go 