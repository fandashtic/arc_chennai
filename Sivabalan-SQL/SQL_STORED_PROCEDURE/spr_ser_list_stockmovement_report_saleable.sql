CREATE procedure [dbo].[spr_ser_list_stockmovement_report_saleable]
                                                      (@Mfr Varchar(2550),        
                                                       @Division Varchar(2550),
                                                       @UOM VarChar(255),
                                                       @FROMDATE datetime,
                                                       @TODATE datetime,
                       				       @ItemCode VarChar(2550))
As        
   
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Create table #tmpMfr(Manufacturer varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
Create table #tmpDiv(Division varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )      
create table #tmpProd(product_code varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

if @Mfr='%'       
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer      
Else      
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Mfr,@Delimeter)      
      
if @Division='%'      
   Insert into #tmpDiv select BrandName from Brand      
Else      
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@Division,@Delimeter)      

if @ItemCode = '%'
	Insert InTo #tmpProd Select Product_code From Items
Else
	Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)

-- Select * from #tmpMfr
-- Select * from #tmpDiv
-- Select * from #tmpProd

    
    
declare @NEXT_DATE datetime        
DECLARE @CORRECTED_DATE datetime        
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS varchar) + '/'         
+ CAST(DATEPART(mm, @TODATE) as varchar) + '/'         
+ cast(DATEPART(yyyy, @TODATE) AS varchar)        
SET  @NEXT_DATE = CAST(DATEPART(dd, GETDATE()) AS varchar) + '/'         
+ CAST(DATEPART(mm, GETDATE()) as varchar) + '/'         
+ cast(DATEPART(yyyy, GETDATE()) AS varchar)        
    
SELECT  Items.Product_Code,         
"Item Code" = Items.Product_Code,         
"Item Name" = ProductName,         
"Category Name" = ItemCategories.Category_Name,
"UOM Description" = 
  Case @UOM When 'Sales UOM' Then IsNull((Select [Description] From UOM Where UOM = Items.UOM), '')
            When 'Reporting UOM' Then IsNull((Select [Description] From UOM Where UOM = Items.ReportingUOM), '')
            When 'Conversion Factor' Then IsNull((Select [ConversionUnit] From ConversionTable Where ConversionID = Items.ConversionUnit), '')
  End, 
        
"Opening Quantity" = 
  Case @UOM When 'Sales UOM' Then (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0))
            When 'Reporting UOM' 
             Then dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)))
--               (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)) / 
--               (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)
            When 'Conversion Factor' 
            Then (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)) * 
              (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)
  End,

"Free Opening Quantity" = 
  Case @UOM When 'Sales UOM' Then (ISNULL(Free_Saleable_Quantity, 0))
            When 'Reporting UOM' 
            Then 
              dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Free_Saleable_Quantity, 0)))
-- 			  (ISNULL(Free_Saleable_Quantity, 0)) / 
--               (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)
            When 'Conversion Factor' 
            Then (ISNULL(Free_Saleable_Quantity, 0)) *
              (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)
End,         
        
"Damage Opening Quantity" = 
  Case @UOM When 'Sales UOM' Then (ISNULL(Damage_Opening_Quantity, 0))
   When 'Reporting UOM' 
            Then 
    dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Damage_Opening_Quantity, 0)))
--               (ISNULL(Damage_Opening_Quantity, 0)) / 
--               (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)
            When 'Conversion Factor'
     Then (ISNULL(Damage_Opening_Quantity, 0)) * 
              (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)
  End,        
        
"Total Opening Quantity" = 
  Case @UOM When 'Sales UOM' Then (ISNULL(Opening_Quantity, 0))
            When 'Reporting UOM' 
            Then 
                 dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))
--               (ISNULL(Opening_Quantity, 0)) / 
--               (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)
            When 'Conversion Factor' 
            Then (ISNULL(Opening_Quantity, 0)) * 
              (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)
  End,        
        
"Opening Value" = ISNULL(Opening_Value, 0) - IsNull(Damage_Opening_Value, 0),        
        
"Damage Opening Value" = IsNull(Damage_Opening_Value, 0), 

"Total Opening Value" = ISNULL(Opening_Value, 0),
        
"Purchase" = 
  Case @UOM When 'Sales UOM' Then (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)         
                      FROM GRNAbstract, GRNDetail         
                      WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
                      AND GRNDetail.Product_Code = Items.Product_Code         
                      AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
                      (GRNAbstract.GRNStatus & 64) = 0 And        
                      (GRNAbstract.GRNStatus & 32) = 0 ), 0))
            When 'Reporting UOM' Then 
--                  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))

                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)
                      FROM GRNAbstract, GRNDetail         
                      WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
                      AND GRNDetail.Product_Code = Items.Product_Code         
                      AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
                      (GRNAbstract.GRNStatus & 64) = 0 And        
                      (GRNAbstract.GRNStatus & 32) = 0 ), 0)))
--                          / 
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)
            When 'Conversion Factor' Then (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)         
                      FROM GRNAbstract, GRNDetail         
                      WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
                      AND GRNDetail.Product_Code = Items.Product_Code         
                      AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
                      (GRNAbstract.GRNStatus & 64) = 0 And        
                      (GRNAbstract.GRNStatus & 32) = 0 ), 0)) * 
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)
  End,        
        
"Free Purchase" = 
  Case @UOM When 'Sales UOM' Then (ISNULL((SELECT SUM(IsNull(FreeQty, 0))         
                                      FROM GRNAbstract, GRNDetail         
                                      WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
                                      AND GRNDetail.Product_Code = Items.Product_Code         
                                      AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
                                   (GRNAbstract.GRNStatus & 64) = 0 And  
                (GRNAbstract.GRNStatus & 32) = 0 ), 0))
    When 'Reporting UOM' Then 
--  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))

                                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT SUM(IsNull(FreeQty, 0))
                                      FROM GRNAbstract, GRNDetail         
                                      WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
                                      AND GRNDetail.Product_Code = Items.Product_Code         
                                      AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
                                      (GRNAbstract.GRNStatus & 64) = 0 And        
                                      (GRNAbstract.GRNStatus & 32) = 0 ), 0)))
--                                         / 
--                                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End) 
                            When 'Conversion Factor' Then (ISNULL((SELECT SUM(IsNull(FreeQty, 0))         
                                      FROM GRNAbstract, GRNDetail         
                                      WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
                                      AND GRNDetail.Product_Code = Items.Product_Code         
                                      AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
                                      (GRNAbstract.GRNStatus & 64) = 0 And        
                                      (GRNAbstract.GRNStatus & 32) = 0 ), 0)) * 
                                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)
                  End,
        
"Sales Return Saleable" = 
  Case @UOM When 'Sales UOM' Then (ISNULL((SELECT SUM(Quantity) FROM 
                                              InvoiceDetail, InvoiceAbstract         
                                              WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                                              AND (InvoiceAbstract.InvoiceType = 4)         
                                              AND (InvoiceAbstract.Status & 128) = 0         
                                              AND InvoiceDetail.Product_Code = Items.Product_Code         
                                              AND (InvoiceAbstract.Status & 32) = 0        
                                              AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) + 
											  ISNULL((SELECT SUM(Quantity) FROM 
                                              InvoiceDetail, InvoiceAbstract         
                                              WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                                              AND (InvoiceAbstract.InvoiceType = 5)         
                                              AND (InvoiceAbstract.Status & 128) = 0         
                                              AND InvoiceDetail.Product_Code = Items.Product_Code         
                                              --AND (InvoiceAbstract.Status & 32) = 0        
                                              AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0))
                                    When 'Reporting UOM' Then 
--                  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))

											  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT SUM(Quantity) FROM 
                                              InvoiceDetail, InvoiceAbstract         
                                              WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
AND (InvoiceAbstract.InvoiceType = 4)         
         AND (InvoiceAbstract.Status & 128) = 0         
 					      AND InvoiceDetail.Product_Code = Items.Product_Code         
                                              AND (InvoiceAbstract.Status & 32) = 0        
                                              AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0))) + 
											  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT SUM(Quantity) FROM 
                                              InvoiceDetail, InvoiceAbstract         
                                              WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                                              AND (InvoiceAbstract.InvoiceType = 5)         
                                              AND (InvoiceAbstract.Status & 128) = 0         
                                              AND InvoiceDetail.Product_Code = Items.Product_Code         
                                              --AND (InvoiceAbstract.Status & 32) = 0        
                                              AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)))
--                                                 / 
--                                                 (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End) 
                                    When 'Conversion Factor' Then (ISNULL((SELECT SUM(Quantity) FROM 
                                              InvoiceDetail, InvoiceAbstract         
                                              WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                                              AND (InvoiceAbstract.InvoiceType = 4)         
                                              AND (InvoiceAbstract.Status & 128) = 0         
                                              AND InvoiceDetail.Product_Code = Items.Product_Code         
                                              AND (InvoiceAbstract.Status & 32) = 0        
                                              AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) + 
                                              ISNULL((SELECT SUM(Quantity) FROM 
                                              InvoiceDetail, InvoiceAbstract         
                                              WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                                              AND (InvoiceAbstract.InvoiceType = 5)         
                                              AND (InvoiceAbstract.Status & 128) = 0         
                                              AND InvoiceDetail.Product_Code = Items.Product_Code         
                                              --AND (InvoiceAbstract.Status & 32) = 0        
                                              AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)) * 
                                              (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)
                          End,  
        
"Sales Return Damages" = 
  Case @UOM When 'Sales UOM' Then (ISNULL((SELECT SUM(Quantity) FROM 
                                             InvoiceDetail, InvoiceAbstract 
                                             WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                                             AND (InvoiceAbstract.InvoiceType = 4)         
                                             AND (InvoiceAbstract.Status & 128) = 0         
                                             AND InvoiceDetail.Product_Code = Items.Product_Code         
                                             AND (InvoiceAbstract.Status & 32) <> 0        
					                         AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) + 
									         ISNULL((SELECT SUM(Quantity) FROM 
                        InvoiceDetail, InvoiceAbstract 
           				     WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                             AND (InvoiceAbstract.InvoiceType = 6)         
                           AND (InvoiceAbstract.Status & 128) = 0         
                                             AND InvoiceDetail.Product_Code = Items.Product_Code         
                                             --AND (InvoiceAbstract.Status & 32) <> 0        
                                             AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0))
                                   When 'Reporting UOM' Then
--                  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))

						                     dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT SUM(Quantity) FROM 
                                             InvoiceDetail, InvoiceAbstract 
                                             WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                                             AND (InvoiceAbstract.InvoiceType = 4)         
                                             AND (InvoiceAbstract.Status & 128) = 0         
                                             AND InvoiceDetail.Product_Code = Items.Product_Code         
                                             AND (InvoiceAbstract.Status & 32) <> 0        
                                             AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0))) + 
											 dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT SUM(Quantity) FROM 
                                             InvoiceDetail, InvoiceAbstract 
                                             WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                                             AND (InvoiceAbstract.InvoiceType = 6)         
                                             AND (InvoiceAbstract.Status & 128) = 0         
                                             AND InvoiceDetail.Product_Code = Items.Product_Code         
                                             --AND (InvoiceAbstract.Status & 32) <> 0        
                                             AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)))
--                                                / 
--                                                (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)  
                                   When 'Conversion Factor' Then (ISNULL((SELECT SUM(Quantity) FROM 
                                             InvoiceDetail, InvoiceAbstract 
                                             WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                                             AND (InvoiceAbstract.InvoiceType = 4)         
                                             AND (InvoiceAbstract.Status & 128) = 0         
                                             AND InvoiceDetail.Product_Code = Items.Product_Code         
                                             AND (InvoiceAbstract.Status & 32) <> 0        
                                             AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) + 
											 ISNULL((SELECT SUM(Quantity) FROM 
                                             InvoiceDetail, InvoiceAbstract 
                                             WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                                             AND (InvoiceAbstract.InvoiceType = 6)         
                                             AND (InvoiceAbstract.Status & 128) = 0         
                                             AND InvoiceDetail.Product_Code = Items.Product_Code         
                                             --AND (InvoiceAbstract.Status & 32) <> 0        
					     AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)) * 
                                    (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)
                         End, 

"Total Issues" = 
  Case @UOM When 'Sales UOM' Then (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract 
                      WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                      AND (InvoiceAbstract.InvoiceType = 2) AND 
                      (InvoiceAbstract.Status & 128) = 0 AND 
                      InvoiceDetail.Product_Code = Items.Product_Code        
                      AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)         

                      + ISNULL((SELECT SUM(Quantity) FROM ServiceInvoiceDetail, ServiceInvoiceAbstract 
                      WHERE ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID         
                      AND (ServiceInvoiceAbstract.ServiceInvoiceType = 1) AND 
                      Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 AND 
                      IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' AND
                      ServiceInvoiceDetail.SpareCode = Items.Product_Code        
                      AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)         

                      + ISNULL((SELECT SUM(Quantity)         
                      FROM DispatchDetail, DispatchAbstract         
                      WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID          
                      AND Isnull(DispatchAbstract.Status, 0) & 64 = 0      
                      AND DispatchDetail.Product_Code = Items.Product_Code         
                      AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0))
            When 'Reporting UOM' Then 
--                  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))

                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract 
                      WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                      AND (InvoiceAbstract.InvoiceType = 2) AND 
                      (InvoiceAbstract.Status & 128) = 0 AND 
                      InvoiceDetail.Product_Code = Items.Product_Code         
                      AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)         

                      + ISNULL((SELECT SUM(Quantity) FROM ServiceInvoiceDetail, ServiceInvoiceAbstract 
                      WHERE ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID         
                      AND (ServiceInvoiceAbstract.ServiceInvoiceType = 1) AND 
                      Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 AND 
                      IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''AND
                      ServiceInvoiceDetail.SpareCode = Items.Product_Code        
                      AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)         

                      + ISNULL((SELECT SUM(Quantity)         
                      FROM DispatchDetail, DispatchAbstract         
                      WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID          
                      AND Isnull(DispatchAbstract.Status, 0) & 64 = 0      
                      AND DispatchDetail.Product_Code = Items.Product_Code         
                      AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0)))
--                       / 
--                       (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)  
            When 'Conversion Factor' Then (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract 
     WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                      AND (InvoiceAbstract.InvoiceType = 2) AND 
                      (InvoiceAbstract.Status & 128) = 0 AND 
                      InvoiceDetail.Product_Code = Items.Product_Code        
                      AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)         

		     + ISNULL((SELECT SUM(Quantity) FROM ServiceInvoiceDetail, ServiceInvoiceAbstract 
                      WHERE ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID         
                      AND (ServiceInvoiceAbstract.ServiceInvoiceType = 1) AND 
                      Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0  
        	      And IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  
		      And ServiceInvoiceDetail.SpareCode = Items.Product_Code   
                      AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)         

                      + ISNULL((SELECT SUM(Quantity)         
                      FROM DispatchDetail, DispatchAbstract         
                      WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID          
                      AND Isnull(DispatchAbstract.Status, 0) & 64 = 0      
                      AND DispatchDetail.Product_Code = Items.Product_Code         
                      AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0)) * 
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)
  End,
    
"Saleable Issues" = 
  Case @UOM When 'Sales UOM' Then (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract
                      WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                      AND (InvoiceAbstract.InvoiceType = 2)         
                      AND (InvoiceAbstract.Status & 128) = 0         
                      AND InvoiceDetail.Product_Code = Items.Product_Code         
                      AND InvoiceDetail.SalePrice > 0     
                      AND (InvoiceAbstract.Status & 32) = 0        
                     AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)    

			+ ISNULL((SELECT SUM(Quantity)                     
			FROM ServiceInvoiceDetail, serviceInvoiceAbstract                     
			WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID
			AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                     
			AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                     
			AND serviceInvoiceDetail.sparecode = items.product_code
			AND Isnull(ServiceInvoiceDetail.Price,0) <> 0    
			AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''
			AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)                     

                      + ISNULL((SELECT SUM(Quantity)         
                      FROM DispatchDetail, DispatchAbstract         
                      WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
                      AND (DispatchAbstract.Status & 64) = 0         
                      AND DispatchDetail.Product_Code = Items.Product_Code         
                      AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE        
                      And DispatchDetail.SalePrice > 0), 0))            
          When 'Reporting UOM' Then 
--                  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))

                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract
                      WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                      AND (InvoiceAbstract.InvoiceType = 2)         
                      AND (InvoiceAbstract.Status & 128) = 0         
          AND InvoiceDetail.Product_Code = Items.Product_Code         
                      AND InvoiceDetail.SalePrice > 0     
                      AND (InvoiceAbstract.Status & 32) = 0        
              AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)    
                      
			 + ISNULL((SELECT SUM(Quantity)                     
			 FROM ServiceInvoiceDetail, serviceInvoiceAbstract                     
			 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID
			 AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                     
			 AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                     
			 AND serviceInvoiceDetail.sparecode = items.product_code
			AND Isnull(ServiceInvoiceDetail.Price,0) <> 0    
			AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''
			AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)                     

                      + ISNULL((SELECT SUM(Quantity)         
                      FROM DispatchDetail, DispatchAbstract         
                      WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
                      AND (DispatchAbstract.Status & 64) = 0         
                      AND DispatchDetail.Product_Code = Items.Product_Code         
                      AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE        
                      And DispatchDetail.SalePrice > 0), 0)))
--                           / 
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End) 
            When 'Conversion Factor' Then (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract
                      WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                      AND (InvoiceAbstract.InvoiceType = 2)         
		     AND (InvoiceAbstract.Status & 128) = 0         
                      AND InvoiceDetail.Product_Code = Items.Product_Code         
                      AND InvoiceDetail.SalePrice > 0     
                      AND (InvoiceAbstract.Status & 32) = 0        
                      AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)    

			+ ISNULL((SELECT SUM(Quantity)                     
			FROM ServiceInvoiceDetail, serviceInvoiceAbstract                     
			WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID
			AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                     
			AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                     
			AND serviceInvoiceDetail.sparecode = items.product_code
			AND Isnull(ServiceInvoiceDetail.Price,0) <> 0    
			AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''
			AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)                     

                      + ISNULL((SELECT SUM(Quantity)         
                      FROM DispatchDetail, DispatchAbstract         
                      WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
                      AND (DispatchAbstract.Status & 64) = 0         
                      AND DispatchDetail.Product_Code = Items.Product_Code         
                      AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE        
                      And DispatchDetail.SalePrice > 0), 0)) * 
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)
  End,
        
"Free Issues" = 
  Case @UOM When 'Sales UOM' Then (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract
                      WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                      AND (InvoiceAbstract.InvoiceType = 2)         
                      AND (InvoiceAbstract.Status & 128) = 0         
AND InvoiceDetail.Product_Code = Items.Product_Code         
                      AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE        
                      And InvoiceDetail.SalePrice = 0), 0)         

			 + ISNULL((SELECT SUM(Quantity)                     
			FROM ServiceInvoiceDetail, serviceInvoiceAbstract               
			WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID
			AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                     
			AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                     
			AND serviceInvoiceDetail.sparecode = items.product_code
			AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''
			AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE
			AND ISNULL(ServiceInvoiceDetail.Price, 0) = 0), 0) 

                      + ISNULL((SELECT SUM(Quantity)         
                      FROM DispatchDetail, DispatchAbstract         
                      WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
                      AND (DispatchAbstract.Status & 64) = 0         
                      AND DispatchDetail.Product_Code = Items.Product_Code         
                   AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE        
                      And DispatchDetail.SalePrice = 0), 0))
            When 'Reporting UOM' Then 
--                  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract
                      WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                      AND (InvoiceAbstract.InvoiceType = 2)         
                      AND (InvoiceAbstract.Status & 128) = 0         
                      AND InvoiceDetail.Product_Code = Items.Product_Code         
                      AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE        
                     And InvoiceDetail.SalePrice = 0), 0)         

			 + ISNULL((SELECT SUM(Quantity)                     
			FROM ServiceInvoiceDetail, serviceInvoiceAbstract                     
			WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID
			AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                     
			AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                     
			AND serviceInvoiceDetail.sparecode = items.product_code
			AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''
			AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE
			AND ISNULL(ServiceInvoiceDetail.Price, 0) = 0), 0) 

                      + ISNULL((SELECT SUM(Quantity)         
                      FROM DispatchDetail, DispatchAbstract         
                      WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
                      AND (DispatchAbstract.Status & 64) = 0         
                      AND DispatchDetail.Product_Code = Items.Product_Code         
                      AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE        
                      And DispatchDetail.SalePrice = 0), 0)))
--                          / 
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End) 
            When 'Conversion Factor' Then (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract
                      WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
                      AND (InvoiceAbstract.InvoiceType = 2)         
                      AND (InvoiceAbstract.Status & 128) = 0         
                      AND InvoiceDetail.Product_Code = Items.Product_Code         
                      AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE        
    			And InvoiceDetail.SalePrice = 0), 0)         
			 + ISNULL((SELECT SUM(Quantity)                     
			FROM ServiceInvoiceDetail, serviceInvoiceAbstract                     
			WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID
			AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                     
			AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0             
			AND serviceInvoiceDetail.sparecode = items.product_code
			AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''
			AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE
			AND ISNULL(ServiceInvoiceDetail.Price, 0) = 0), 0) 

	              + ISNULL((SELECT SUM(Quantity)         
                      FROM DispatchDetail, DispatchAbstract         
                      WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
                      AND (DispatchAbstract.Status & 64) = 0         
                      AND DispatchDetail.Product_Code = Items.Product_Code         
                      AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE        
                      And DispatchDetail.SalePrice = 0), 0)) * 
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)
  End,

"Sales Value (%c)" = ISNULL((SELECT SUM(case invoicetype when 4 then 0 - Amount else Amount end)         
FROM InvoiceDetail, InvoiceAbstract         
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
AND (InvoiceAbstract.Status & 128) = 0         
AND InvoiceDetail.Product_Code = Items.Product_Code         
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)        

+ISNULL((SELECT SUM(Isnull(serviceinvoiceDetail.Netvalue,0))                       
FROM ServiceInvoiceDetail, serviceInvoiceAbstract                       
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                       
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0               
AND serviceInvoiceDetail.sparecode = items.product_code  
AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  
AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE),0) ,          
          
"Purchase Return" =   
  Case @UOM When 'Sales UOM' Then (ISNULL((SELECT SUM(Quantity)           
         FROM AdjustmentReturnDetail, AdjustmentReturnAbstract           
                      WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID  
                      AND AdjustmentReturnDetail.Product_Code = Items.Product_Code           
                      AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE       
                      And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
                      And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0))  
            When 'Reporting UOM' Then   
--                  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))  
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code,(ISNULL((SELECT  SUM(Quantity)  
                      FROM AdjustmentReturnDetail, AdjustmentReturnAbstract           
                      WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID  
                      AND AdjustmentReturnDetail.Product_Code = Items.Product_Code           
                      AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE       
                      And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
                      And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)))  
--                          /   
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then (ISNULL((SELECT SUM(Quantity)           
                  FROM AdjustmentReturnDetail, AdjustmentReturnAbstract           
                      WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID 
                      AND AdjustmentReturnDetail.Product_Code = Items.Product_Code           
           AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE       
                      And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
                      And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)) *   
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)                    
  End,  
          
"Adjustments" =   
  Case @UOM When 'Sales UOM' Then (ISNULL((SELECT SUM(Quantity - OldQty)           
                      FROM StockAdjustment, StockAdjustmentAbstract           
                      WHERE ISNULL(AdjustmentType,0) in (1, 3)           
                      And Product_Code = Items.Product_Code           
                      AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID          
                      AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0))  
            When 'Reporting UOM' Then   
--                  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))  
  
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT  SUM(Quantity - OldQty)  
                      FROM StockAdjustment, StockAdjustmentAbstract           
                      WHERE ISNULL(AdjustmentType,0) in (1, 3)           
                     And Product_Code = Items.Product_Code           
                      AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID          
                      AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)))  
--                          /   
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then (ISNULL((SELECT SUM(Quantity - OldQty)           
                      FROM StockAdjustment, StockAdjustmentAbstract           
                      WHERE ISNULL(AdjustmentType,0) in (1, 3)           
                      And Product_Code = Items.Product_Code           
                      AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID          
  AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)) *   
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)  
  End,  
    
"Stock Transfer Out" =   
  Case @UOM When 'Sales UOM' Then (IsNull((Select Sum(Quantity)           
                      From StockTransferOutAbstract, StockTransferOutDetail          
                      Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial          
                      And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate           
                      And StockTransferOutAbstract.Status & 192 = 0          
                      And StockTransferOutDetail.Product_Code = Items.Product_Code), 0))  
            When 'Reporting UOM' Then   
--                  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))  
  
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT  SUM(Quantity - OldQty)  
                      FROM StockAdjustment, StockAdjustmentAbstract           
                      WHERE ISNULL(AdjustmentType,0) in (1, 3)           
                      And Product_Code = Items.Product_Code           
                      AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID          
                      AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)))  
--      /   
--              (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then (ISNULL((SELECT SUM(Quantity - OldQty)           
                      FROM StockAdjustment, StockAdjustmentAbstract           
                  WHERE ISNULL(AdjustmentType,0) in (1, 3)        
                      And Product_Code = Items.Product_Code           
                      AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID          
                      AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)) *   
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)  
  End,  
          
"Stock Transfer In" =   
  Case @UOM When 'Sales UOM' Then (IsNull((Select Sum(Quantity)           
                      From StockTransferInAbstract, StockTransferInDetail           
                      Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial          
                      And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate           
                      And StockTransferInAbstract.Status & 192 = 0          
                      And StockTransferInDetail.Product_Code = Items.Product_Code), 0))   
            When 'Reporting UOM' Then   
--                  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))  
  
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (IsNull((Select  Sum(Quantity)  
                      From StockTransferInAbstract, StockTransferInDetail           
                      Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial          
                      And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate           
                      And StockTransferInAbstract.Status & 192 = 0          
                      And StockTransferInDetail.Product_Code = Items.Product_Code), 0)))  
--                         /   
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then (IsNull((Select Sum(Quantity)           
                      From StockTransferInAbstract, StockTransferInDetail           
                      Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial          
                      And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate           
                      And StockTransferInAbstract.Status & 192 = 0         
                      And StockTransferInDetail.Product_Code = Items.Product_Code), 0)) *   
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)                          
  End,  
          
"Stock Destruction" =   
  Case @UOM When 'Sales UOM' Then (cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                   
                      From StockDestructionAbstract, StockDestructionDetail,ClaimsNote       
                      Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                  
                      And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID      
                      And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                   
                      And ClaimsNote.Status & 1 <> 0          
                 And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)))  
            When 'Reporting UOM' Then   
--                  dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL(Opening_Quantity, 0)))  
  
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)  
                      From StockDestructionAbstract, StockDestructionDetail,ClaimsNote       
                 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                  
                      And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID      
                      And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                   
                      And ClaimsNote.Status & 1 <> 0          
                    And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))))  
--                         /   
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then (cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                   
                      From StockDestructionAbstract, StockDestructionDetail,ClaimsNote       
                      Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                  
                      And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID      
                      And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                   
                      And ClaimsNote.Status & 1 <> 0          
  And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))) *   
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)  
  End,  
      
"On Hand Qty" = CASE           
when (@TODATE < @NEXT_DATE) THEN           
  Case @UOM When 'Sales UOM' Then (ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)  
                      - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails  
                      WHERE OpeningDetails.Product_Code = Items.Product_Code   
                      AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))   
                       
   
            When 'Reporting UOM' Then   
--dbo.sp_Get_ReportingUOMQty(Items.Product_Code,   
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)  
                      - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails  
                      WHERE OpeningDetails.Product_Code = Items.Product_Code   
                      AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)))  
--                          /   
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then (ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)  
        - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails  
                      WHERE OpeningDetails.Product_Code = Items.Product_Code   
                      AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *   
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)  
  End  
  
ELSE           
  Case @UOM When 'Sales UOM' Then ((ISNULL((SELECT SUM(Quantity)           
                      FROM Batch_Products           
                      WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And   
                      IsNull(Damage, 0) = 0), 0)  
			+Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM    
			Issuedetail,IssueAbstract,JobcardAbstract    
			where IssueAbstract.IssueID =IssueDetail.IssueID And    
			IssueAbstract.JobCardId = JobcardAbstract.JobcardID     
			AND Issuedetail.sparecode = items.product_code  
			AND Isnull(Issuedetail.Purchaseprice,0) <> 0   
			AND Isnull(IssueAbstract.Status,0) & 192  = 0    
			AND Isnull(jobcardAbstract.status,0) & 192 = 0     
			AND Isnull(jobcardAbstract.status,0) & 32 = 0),0)                
                    + (SELECT ISNULL(SUM(Pending), 0)           
                FROM VanStatementDetail, VanStatementAbstract    
                  WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial      
                      AND (VanStatementAbstract.Status & 128) = 0           
                      And VanStatementDetail.Product_Code = Items.Product_Code And   
                      VanStatementDetail.PurchasePrice <> 0)))  
            When 'Reporting UOM' Then   
--dbo.sp_Get_ReportingUOMQty(Items.Product_Code,   
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, ((ISNULL((SELECT SUM(Quantity)           
                      FROM Batch_Products           
                      WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And   
                      IsNull(Damage, 0) = 0), 0)   
  
			+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM    
			Issuedetail,IssueAbstract,JobcardAbstract    
			where IssueAbstract.IssueID =IssueDetail.IssueID And    
			IssueAbstract.JobCardId = JobcardAbstract.JobcardID     
			AND Issuedetail.sparecode = items.product_code  
			AND Isnull(Issuedetail.Purchaseprice,0) <> 0   
			ANd Isnull(IssueAbstract.Status,0) & 192  = 0    
			AND Isnull(jobcardAbstract.status,0) & 192 = 0     
			AND Isnull(jobcardAbstract.status,0) & 32 = 0),0)                
                         
  
                     +(SELECT ISNULL(SUM(Pending), 0)           
                      FROM VanStatementDetail, VanStatementAbstract           
                      WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
                      AND (VanStatementAbstract.Status & 128) = 0           
                      And VanStatementDetail.Product_Code = Items.Product_Code And   
                      VanStatementDetail.PurchasePrice <> 0))))   
--                       /   
--                       (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
           When 'Conversion Factor' Then   
  
                      ((ISNULL((SELECT  SUM(Quantity)  
                      FROM Batch_Products           
                      WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And   
                      IsNull(Damage, 0) = 0), 0)           
			  
			+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM    
			Issuedetail,IssueAbstract,JobcardAbstract    
			where IssueAbstract.IssueID =IssueDetail.IssueID And    
			IssueAbstract.JobCardId = JobcardAbstract.JobcardID     
			AND Issuedetail.sparecode = items.product_code  
			AND Isnull(Issuedetail.Purchaseprice,0) <> 0   
			AND Isnull(IssueAbstract.Status,0) & 192  = 0    
			AND Isnull(jobcardAbstract.status,0) & 192 = 0     
			AND Isnull(jobcardAbstract.status,0) & 32 = 0),0)  
  
                       +(SELECT ISNULL(SUM(Pending), 0)           
                      FROM VanStatementDetail, VanStatementAbstract           
                      WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
                      AND (VanStatementAbstract.Status & 128) = 0           
                      And VanStatementDetail.Product_Code = Items.Product_Code And   
                      VanStatementDetail.PurchasePrice <> 0))) *   
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)  
  End  
End,          
          
"On Hand Free Qty" =   
CASE when (@TODATE < @NEXT_DATE) THEN           
  Case @UOM When 'Sales UOM' Then (ISNULL((Select IsNull(Free_Saleable_Quantity, 0)          
                      FROM OpeningDetails           
                      WHERE OpeningDetails.Product_Code = Items.Product_Code           
                      AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))  
            When 'Reporting UOM' Then   
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((Select IsNull(Free_Saleable_Quantity, 0)          
   FROM OpeningDetails           
                      WHERE OpeningDetails.Product_Code = Items.Product_Code        
                      AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)))  
--                           /   
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then (ISNULL((Select IsNull(Free_Saleable_Quantity, 0)          
    FROM OpeningDetails           
            WHERE OpeningDetails.Product_Code = Items.Product_Code           
                      AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *   
                       (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)  
  End  
ELSE         
  Case @UOM When 'Sales UOM' Then ((ISNULL((SELECT SUM(Quantity)           
                      FROM Batch_Products           
                      WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0)   
			+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM    
			Issuedetail,IssueAbstract,JobcardAbstract    
			where IssueAbstract.IssueID =IssueDetail.IssueID And    
			IssueAbstract.JobCardId = JobcardAbstract.JobcardID     
			AND Issuedetail.sparecode = items.product_code  
			AND Isnull(Issuedetail.Purchaseprice,0) = 0   
			AND Isnull(IssueAbstract.Status,0) & 192  = 0    
			AND Isnull(jobcardAbstract.status,0) & 192 = 0     
			AND Isnull(jobcardAbstract.status,0) & 32 = 0),0)  

                       + (SELECT ISNULL(SUM(Pending), 0)       
                      FROM VanStatementDetail, VanStatementAbstract           
                      WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
                      AND (VanStatementAbstract.Status & 128) = 0           
                      And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice = 0)))  
            When 'Reporting UOM' Then   
                     dbo.sp_Get_ReportingUOMQty(Items.Product_Code, ((ISNULL((SELECT SUM(Quantity)           
                      FROM Batch_Products           
                      WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0)   
			+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM    
			Issuedetail,IssueAbstract,JobcardAbstract    
			where IssueAbstract.IssueID =IssueDetail.IssueID And    
			IssueAbstract.JobCardId = JobcardAbstract.JobcardID     
			AND Issuedetail.sparecode = items.product_code  
			AND Isnull(Issuedetail.Purchaseprice,0) = 0   
			AND Isnull(IssueAbstract.Status,0) & 192  = 0    
			AND Isnull(jobcardAbstract.status,0) & 192 = 0     
			AND Isnull(jobcardAbstract.status,0) & 32 = 0),0)  
			
                      +(SELECT ISNULL(SUM(Pending), 0)           
                      FROM VanStatementDetail, VanStatementAbstract           
                      WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
                      AND (VanStatementAbstract.Status & 128) = 0           
                      And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice = 0))))  
--                          /   
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then ((ISNULL((SELECT SUM(Quantity)           
                      FROM Batch_Products           
                      WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0)   
			+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM    
			Issuedetail,IssueAbstract,JobcardAbstract    
			where IssueAbstract.IssueID =IssueDetail.IssueID And    
			IssueAbstract.JobCardId = JobcardAbstract.JobcardID     
			AND Issuedetail.sparecode = items.product_code  
			AND Isnull(Issuedetail.Purchaseprice,0) = 0   
			AND Isnull(IssueAbstract.Status,0) & 192  = 0    
			AND Isnull(jobcardAbstract.status,0) & 192 = 0     
			AND Isnull(jobcardAbstract.status,0) & 32 = 0),0)  
    
                      +(SELECT ISNULL(SUM(Pending), 0)           
                FROM VanStatementDetail, VanStatementAbstract           
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
                      AND (VanStatementAbstract.Status & 128) = 0           
            And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice = 0))) *   
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)  
  End  
End,          
          
"On Hand Damage Qty" = CASE When (@TODATE < @NEXT_DATE) THEN           
  Case @UOM When 'Sales UOM' Then (ISNULL((Select IsNull(Damage_Opening_Quantity, 0)          
                      FROM OpeningDetails   
                      WHERE OpeningDetails.Product_Code = Items.Product_Code    
                      AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))  
            When 'Reporting UOM' Then   
  
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((Select IsNull(Damage_Opening_Quantity, 0)          
                      FROM OpeningDetails   
                      WHERE OpeningDetails.Product_Code = Items.Product_Code    
                      AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)))  
--                         /   
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then (ISNULL((Select IsNull(Damage_Opening_Quantity, 0)          
                      FROM OpeningDetails   
                      WHERE OpeningDetails.Product_Code = Items.Product_Code    
                      AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *   
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)  
  End  
ELSE           
  Case @UOM When 'Sales UOM' Then (ISNULL((SELECT SUM(Quantity)   
                      FROM Batch_Products           
                      WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0))  
            When 'Reporting UOM' Then   
            dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT SUM(Quantity)   
 FROM Batch_Products           
                      WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)) )  
--                        /   
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then (ISNULL((SELECT SUM(Quantity)   
                      FROM Batch_Products           
         WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)) *   
                        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)  
  End  
End,          
          
"Total On Hand Qty" = CASE When (@TODATE < @NEXT_DATE) THEN           
  Case @UOM When 'Sales UOM' Then (ISNULL((Select Opening_Quantity          
                      FROM OpeningDetails           
                      WHERE OpeningDetails.Product_Code = Items.Product_Code           
                      AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))  
            When 'Reporting UOM' Then   
  
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((Select Opening_Quantity          
                      FROM OpeningDetails           
                      WHERE OpeningDetails.Product_Code = Items.Product_Code           
                      AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)))   
--   /   
--                   (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then (ISNULL((Select Opening_Quantity          
                      FROM OpeningDetails           
                      WHERE OpeningDetails.Product_Code = Items.Product_Code           
                      AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *   
            (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)  
  End  
ELSE           
  Case @UOM When 'Sales UOM' Then (ISNULL((SELECT SUM(Quantity)           
                      FROM Batch_Products           
                      WHERE Product_Code = Items.Product_Code), 0)           
  
		+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM    
		Issuedetail,IssueAbstract,JobcardAbstract    
		where IssueAbstract.IssueID =IssueDetail.IssueID And    
		IssueAbstract.JobCardId = JobcardAbstract.JobcardID     
		AND Issuedetail.sparecode = items.product_code  
		AND Isnull(IssueAbstract.Status,0) & 192  = 0    
		AND Isnull(jobcardAbstract.status,0) & 192 = 0     
		AND Isnull(jobcardAbstract.status,0) & 32 = 0),0)   
                         
		+(SELECT ISNULL(SUM(Pending), 0)           
		FROM VanStatementDetail, VanStatementAbstract           
		WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
		AND (VanStatementAbstract.Status & 128) = 0           
		And VanStatementDetail.Product_Code = Items.Product_Code))  
            When 'Reporting UOM' Then   
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT SUM(Quantity)           
                      FROM Batch_Products           
                      WHERE Product_Code = Items.Product_Code), 0)   
			+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM    
			Issuedetail,IssueAbstract,JobcardAbstract    
			where IssueAbstract.IssueID =IssueDetail.IssueID And    
			IssueAbstract.JobCardId = JobcardAbstract.JobcardID     
			AND Issuedetail.sparecode = items.product_code  
			AND Isnull(IssueAbstract.Status,0) & 192  = 0    
			AND Isnull(jobcardAbstract.status,0) & 192 = 0     
			AND Isnull(jobcardAbstract.status,0) & 32 = 0),0)   
          
                      +(SELECT ISNULL(SUM(Pending), 0)           
                      FROM VanStatementDetail, VanStatementAbstract           
                      WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
                      AND (VanStatementAbstract.Status & 128) = 0           
                      And VanStatementDetail.Product_Code = Items.Product_Code)))  
--                         /   
--                         (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then (ISNULL((SELECT SUM(Quantity)           
                      FROM Batch_Products           
                      WHERE Product_Code = Items.Product_Code), 0)           
			+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM    
			Issuedetail,IssueAbstract,JobcardAbstract    
			where IssueAbstract.IssueID =IssueDetail.IssueID And    
			IssueAbstract.JobCardId = JobcardAbstract.JobcardID     
			AND Issuedetail.sparecode = items.product_code  
			AND Isnull(IssueAbstract.Status,0) & 192  = 0    
			AND Isnull(jobcardAbstract.status,0) & 192 = 0     
			AND Isnull(jobcardAbstract.status,0) & 32 = 0),0)   

                      +(SELECT ISNULL(SUM(Pending), 0)           
                      FROM VanStatementDetail, VanStatementAbstract           
                      WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
                      AND (VanStatementAbstract.Status & 128) = 0           
                      And VanStatementDetail.Product_Code = Items.Product_Code)) *   
        (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)  
  End  
End,          
          
"On Hand Value" = CASE           
when (@TODATE < @NEXT_DATE) THEN           
ISNULL((Select Opening_Value - IsNull(Damage_Opening_Value, 0)          
FROM OpeningDetails           
WHERE OpeningDetails.Product_Code = Items.Product_Code       
AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
ELSE           
((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)           
FROM Batch_Products           
WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0)            
 +
Isnull((SELECT sum((Isnull(IssuedQty,0) - Isnull(ReturnedQty,0)) * Isnull(Issuedetail.Purchaseprice,0)) from   
Issuedetail,IssueAbstract,JobcardAbstract  
where IssueAbstract.IssueID =IssueDetail.IssueID And  
IssueAbstract.JobCardId = JobcardAbstract.JobcardID   
And Issuedetail.Sparecode = items.product_code
AND Isnull(Issuedetail.Saleprice,0) <> 0  
AND Isnull(IssueAbstract.Status,0) & 192  = 0  
AND Isnull(jobcardAbstract.status,0) & 192 = 0   
AND Isnull(jobcardAbstract.status,0) & 32 = 0),0)

 +(SELECT ISNULL(SUM(Pending * PurchasePrice), 0)           
 FROM VanStatementDetail, VanStatementAbstract           
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
 AND (VanStatementAbstract.Status & 128) = 0           
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0))          
end,          
          
"On Hand Damages Value" = CASE           
when (@TODATE < @NEXT_DATE) THEN           
ISNULL((Select IsNull(Damage_Opening_Value, 0)          
FROM OpeningDetails           
WHERE OpeningDetails.Product_Code = Items.Product_Code           
AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
ELSE           
(SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)           
FROM Batch_Products           
WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0)          
end,           
          

"Total On Hand Value" = 
CASE           
when (@TODATE < @NEXT_DATE) THEN           
	ISNULL((Select Opening_Value          
	FROM OpeningDetails           
	WHERE OpeningDetails.Product_Code = Items.Product_Code           
	AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
ELSE           
	((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)           
	FROM Batch_Products           
	WHERE Product_Code = Items.Product_Code)            

+Isnull((SELECT sum((Isnull(IssuedQty,0) - Isnull(ReturnedQty,0)) * Isnull(Issuedetail.Purchaseprice,0)) from 
Issuedetail,IssueAbstract,JobcardAbstract
where IssueAbstract.IssueID =IssueDetail.IssueID And
IssueAbstract.JobCardId = JobcardAbstract.JobcardID 
And Issuedetail.SpareCode = Items.Product_Code 
And Isnull(IssueAbstract.Status,0) & 192  = 0
And Isnull(jobcardAbstract.status,0) & 192 = 0 
AND Isnull(Issuedetail.Saleprice,0) <> 0  
And Isnull(jobcardAbstract.status,0) & 32 = 0),0)

+(SELECT ISNULL(SUM(Pending * PurchasePrice), 0)           
FROM VanStatementDetail, VanStatementAbstract           
WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial    
AND (VanStatementAbstract.Status & 128) = 0           
And VanStatementDetail.Product_Code = Items.Product_Code))          

end,       

"Pending Orders" =   
  Case @UOM When 'Sales UOM' Then (IsNull(dbo.GetPOPending (Items.Product_Code), 0) +       
                      IsNull(dbo.GetSRPending(Items.Product_Code), 0))      
            When 'Reporting UOM' Then   
                      dbo.sp_Get_ReportingUOMQty(Items.Product_Code,   
                      (IsNull(dbo.GetPOPending (Items.Product_Code), 0) +       
                      IsNull(dbo.GetSRPending(Items.Product_Code), 0)))  
--                        /   
--                       (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)   
            When 'Conversion Factor' Then (IsNull(dbo.GetPOPending (Items.Product_Code), 0) +       
                      IsNull(dbo.GetSRPending(Items.Product_Code), 0)) *   
                      (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End)  
  End,  


"Forum Code" = Items.Alias      
          
FROM Items, OpeningDetails, UOM, Manufacturer, Brand, ItemCategories 
WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND        
 OpeningDetails.Opening_Date = @FROMDATE        
 AND Items.UOM *= UOM.UOM And        
 Items.ManufacturerID = Manufacturer.ManufacturerID And        
 Manufacturer.Manufacturer_Name In (Select Manufacturer from #tmpMfr) And      
 Items.BrandID = Brand.BrandID And      
 Brand.BrandName In (Select Division from #tmpDiv) And       
 Items.CategoryID = ItemCategories.CategoryID And  
 Items.Product_Code in (Select product_code from #tmpProd)  
      
Drop table #tmpMfr      
Drop table #tmpDiv      
Drop table #tmpProd
