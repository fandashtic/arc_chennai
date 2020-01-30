Create Procedure dbo.spr_WDAvailableBookStock_Detail_ITC     
(        
  @ProductCode nvarchar(50),      
  @ShowItems nvarchar(2000),         
  @UOM nvarchar(50),        
  @StockValuation nvarchar(10),       
  @Unused1 nvarchar(1),      
  @Unused2 nvarchar(1),      
  @FromDate datetime      
)              
As           
Begin        
 If IsNull(@UOM,N'') = N'' or @UOM = N'%' or @UOM = N'Base UOM'        
  Set @UOM = N'Sales UOM'          
      
If IsNull(@StockValuation,N'') = N'' or IsNull(@StockValuation,N'') = N'%'       
 Set @StockValuation = N'PTS'          
      
 If (DatePart(dy, @FromDate) < DatePart(dy, GetDate()) And DatePart(yyyy, @FromDate) = DatePart(yyyy, GetDate())) Or  DatePart(yyyy, @FromDate) < DatePart(yyyy, GetDate())                               
   Begin     
   -- Given date is less than current date, so data to be taken from Opening Details           
      If @UOM = N'Sales UOM' or @UOM = N'UOM1' or @UOM = N'UOM2'                            
       Begin      
        Select         
         "Item Code" = N'',       
         "Batch" = N'',      
         "PKD" = N'',      
         "Expiry" = N'',      
         "UOM" = UOM.[Description],      
   "PFM" =  Cast(Case @UOM       
                 When N'Uom1' Then (Case Isnull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End) * (max(Items.PFM))         
                 When N'Uom2' Then (Case Isnull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End) * (max(Items.PFM))    
               When N'Sales UOM' Then max(Items.PFM)            
                 End as Decimal(18,6)),  
         "PTS" =  Cast(Case @UOM       
                 When N'Uom1' Then (Case Isnull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End) * (max(Items.PTS))         
                 When N'Uom2' Then (Case Isnull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End) * (max(Items.PTS))    
               When N'Sales UOM' Then max(Items.PTS)            
                 End as Decimal(18,6)),                    
          "PTR" = Cast(Case @UOM       
                 When N'Uom1' Then (Case Isnull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End) * (max(Items.PTR))         
                 When N'Uom2' Then (Case Isnull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End) * (max(Items.PTR))    
               When N'Sales UOM' Then max(Items.PTR)            
                 End as Decimal(18,6)),                     
          "ECP" = Cast(Case @UOM       
                 When N'Uom1' Then (Case Isnull(Items.UOM1_Conversion,0) When 0 Then 1 Else Items.UOM1_Conversion End) * (max(Items.ECP))         
                 When N'Uom2' Then (Case Isnull(Items.UOM2_Conversion,0) When 0 Then 1 Else Items.UOM2_Conversion End) * (max(Items.ECP))    
            When N'Sales UOM' Then max(Items.ECP)            
                 End as Decimal(18,6)),     
    "MRPPerPack" = max(Isnull(Items.MRPPerPack,0)),     
          "Tax Applicable" = OpeningDetails.TaxSuffered_Value,          
          "Total Quantity" = Case @UOM When N'Sales UOM' Then Sum(Isnull(Opening_Quantity,0)) -   
       (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0))       
          Else dbo.sp_Get_ReportingQty(sum(Isnull(Opening_Quantity,0))- (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0)   
               ),          
             (Case @UOM       
                When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)          
                When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)          
               End)) End,          
        "Saleable " = Case @UOM When N'Sales UOM'   
                     Then sum(Isnull(Opening_Quantity,0) - IsNull(OpeningDetails.Free_Saleable_Quantity,0)   
              - IsNull(OpeningDetails.Damage_Opening_Quantity,0)) -   
           (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1))      
                     Else      
                    dbo.sp_Get_ReportingQty(  
                    sum(Isnull(Opening_Quantity,0)   
            - IsNull(OpeningDetails.Free_Saleable_Quantity,0)   
             - IsNull(OpeningDetails.Damage_Opening_Quantity,0))  
                   - (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)),          
                      (Case @UOM          
                      When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)          
                    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)          
                          End)) End,      
          "Free " = Case @UOM When N'Sales UOM' Then sum(Isnull(OpeningDetails.Free_Saleable_Quantity,0)   
       - dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2))               
               Else      
                dbo.sp_Get_ReportingQty(Sum(IsNull(OpeningDetails.Free_Saleable_Quantity,0)  
       - dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),                 
              (Case @UOM           
                When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)          
                When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)          
                End)) End,        
          "Damages" = Case @UOM When N'Sales UOM' Then sum(Isnull(OpeningDetails.Damage_Opening_Quantity,0))      
               Else       
              dbo.sp_Get_ReportingQty(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity,0)),      
              (Case @UOM           
                When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)          
                When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)          
                End)) End,     
          "Van Saleable Stock " = Case @UOM When N'Sales UOM'   
                   Then sum(  
                   (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1))) Else      
                    dbo.sp_Get_ReportingQty(  
             (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)),          
                     (Case @UOM          
                    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)          
                  When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)          
                     End)) End,  
          "Van Free Stock "= Case @UOM When N'Sales UOM'   
                   Then sum(  
                   (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2))) Else      
                    dbo.sp_Get_ReportingQty(  
             (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),          
                     (Case @UOM          
                    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)          
                  When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)          
                     End)) End,  
          "DC Saleable Stock "= Case @UOM When N'Sales UOM'   
                   Then sum(  
                   (dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1))) Else      
                    dbo.sp_Get_ReportingQty(  
             (dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)),          
                     (Case @UOM          
                    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)          
                  When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)          
                     End)) End,  
          "DC Free Stock "= Case @UOM When N'Sales UOM'   
                   Then sum(  
                   (dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2))) Else      
                    dbo.sp_Get_ReportingQty(  
             (dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),          
                     (Case @UOM          
                    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
                  When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)          
                     End)) End,  
    
          "Saleable Value" =                    
               Cast(Case @StockValuation                            
         When N'PTS' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTS, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTS, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.PTS, 0))  
         - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) * Isnull(Items.PTS,0))                        
        
                When N'PTR' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTR, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTR, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.PTR, 0))  
           - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)   
                   * Isnull(Items.PTR,0))                        
                When N'ECP' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.ECP, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.ECP, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.ECP, 0))  
         - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)   
                  * Isnull(Items.ECP,0))                         
               End as Decimal(18,6)),     
          "Damaged Value" =       
           Cast(Case @StockValuation                          
               When N'PTS' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTS, 0)), 0)      
               When N'PTR' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTR, 0)), 0)                            
               When N'ECP' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.ECP, 0)), 0)       
              End as Decimal(18,6)),         
          "Total Value" =      
            Cast(Case @StockValuation                          
               When N'PTS' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.PTS, 0))  
           -  Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0)   
                  * Isnull(Items.PTS,0))                             
               When N'PTR' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.PTR, 0))  
           -  Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0)   
                  * Isnull(Items.PTR,0))                               
               When N'ECP' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.ECP, 0))  
          -  Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0)   
                 * Isnull(Items.ECP,0))       
              End as Decimal(18,6)),   
  "Tax Type" = N''   
        From           
         Items
		 Left Outer Join  OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code    
		 Inner Join UOM On  Uom.Uom = Case @UOM When N'UOM1' Then Items.Uom1 When N'UOM2' Then Items.UOM2 Else Items.UOM End                                                     
        Where          
          Items.Product_Code = @ProductCode    
          And OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate)                                                   
        Group By          
          Items.Product_Code,OpeningDetails.TaxSuffered_Value, UOM.[Description], Items.UOM1_Conversion,Items.UOM2_Conversion
         End      
      Else If @UOM = N'UOM1 & UOM2'       
       Begin      
        -- Opening Details Bottom Frame      
         Select       
           "Batch" = N'',      
           "Batch" = N'',      
           "PKD" = N'',      
           "Expiry" = N'',   
 "PFM" =max(Items.PFM) * Items.UOM2_Conversion,   
           "PTS as Per PAC" = max(Items.PTS) * Items.UOM2_Conversion,                    
           "PTR as Per PAC" = max(Items.PTR) * Items.UOM2_Conversion,                    
           "ECP as Per PAC" = max(Items.ECP) * Items.UOM2_Conversion,  
           "MRP Per Pack" = max(isnull(items.MRPPerPack,0)),        
           "Tax Applicable" = OpeningDetails.TaxSuffered_Value,      
           "Total CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(Opening_Quantity,0))- (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0)),1),      
           "PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(Opening_Quantity,0)) - (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0)),2),  
           "Saleable CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,Sum(IsNull(OpeningDetails.Opening_Quantity,0) -       
              IsNull(OpeningDetails.Free_Saleable_Quantity,0) -       
              IsNull(OpeningDetails.Damage_Opening_Quantity,0)) - dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),1),      
           "Saleable PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,Sum(IsNull(OpeningDetails.Opening_Quantity,0) -       
              IsNull(OpeningDetails.Free_Saleable_Quantity,0) -       
              IsNull(OpeningDetails.Damage_Opening_Quantity,0)) - dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),2),        
           "Free CFC"=  dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(OpeningDetails.Free_Saleable_Quantity,0)- dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),1),       
           "Free PAC"=  dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(OpeningDetails.Free_Saleable_Quantity,0)- dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),2),        
           "Damaged CFC"= dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(OpeningDetails.Damage_Opening_Quantity,0)),1),      
           "Damaged PAC"= dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(OpeningDetails.Damage_Opening_Quantity,0)),2),                        
           "Van Saleable CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),1),  
           "Van Saleable PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),2),  
           "Van Free CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2),1),  
           "Van Free CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2),2),  
     "DC Saleable CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),1),  
           "DC Saleable PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),2),  
     "DC Free CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2),1),  
           "DC Free PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2),2),  
  
           "Saleable Value" =                    
             Cast(Case @StockValuation                            
               When N'PTS' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTS, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTS, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.PTS, 0))  
       - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)   
                    * Isnull(Items.PTS,0))                 
               When N'PTR' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTR, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTR, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.PTR, 0))  
       - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)   
                   * Isnull(Items.PTR,0))                        
               When N'ECP' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.ECP, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.ECP, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.ECP, 0))  
       - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)   
                   * Isnull(Items.ECP,0))                            
               End as Decimal(18,6)),        
           "Damaged Value" =       
            Cast(Case @StockValuation                          
              When N'PTS' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTS, 0)), 0)                            
   When N'PTR' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTR, 0)), 0)                            
              When N'ECP' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.ECP, 0)), 0)       
            End as Decimal(18,6)) ,         
       "Total Value" =      
            Cast(Case @StockValuation                          
              When N'PTS' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.PTS, 0))  
        -  Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0)   
                  * Isnull(Items.PTS,0))                             
              When N'PTR' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.PTR, 0))  
        -  Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0)   
                  * Isnull(Items.PTR,0))                               
              When N'ECP' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.ECP, 0))  
        -  Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0)   
                   * Isnull(Items.ECP,0))       
           End as Decimal(18,6)),   
    "Tax Type" = N''     
           From           
            Items
			Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code                         
          Where           
           Items.Product_Code = @ProductCode   
           And OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate)                                   
          Group By          
           Items.Product_Code, OpeningDetails.TaxSuffered_Value, Items.UOM1_Conversion,Items.UOM2_Conversion                 
       End       
   End    
   Else --Given Date is Current Date data to be taken from Batch Products    
   Begin              
     If @UOM = N'Sales UOM' or @UOM = N'UOM1' or @UOM = N'UOM2'                            
       Begin      
       Select          
          "Batch" = Batch_Number,      
          "Batch" = Batch_Number,             
          "PKD" = Cast(DatePart(mm, BP.PKD) As NVarChar) + N'/'+ SubString(Cast(DatePart(yyyy, BP.PKD) As NVarChar), 1, 4),            
          "Expiry" = Cast(DatePart(mm, BP.Expiry) As NVarChar) + N'/'+ SubString(Cast(DatePart(yyyy, BP.Expiry) As NVarChar), 1, 4),        
          "UOM" = UOM.[Description],   
          "PFM" = (Case @UOM       
                    When N'Uom1' Then (Case Isnull(I1.UOM1_Conversion,0) When 0 Then 1 Else I1.UOM1_Conversion End)          
                  When N'Uom2' Then (Case Isnull(I1.UOM2_Conversion,0) When 0 Then 1 Else I1.UOM2_Conversion End)     
                When N'Sales UOM' Then 1           
                 End) *      
         (Case max(ItemCategories.Price_Option) When 1 Then max(BP.PFM) Else max(I1.PFM) End),          
          "PTS" = (Case @UOM       
                    When N'Uom1' Then (Case Isnull(I1.UOM1_Conversion,0) When 0 Then 1 Else I1.UOM1_Conversion End)          
                  When N'Uom2' Then (Case Isnull(I1.UOM2_Conversion,0) When 0 Then 1 Else I1.UOM2_Conversion End)     
                When N'Sales UOM' Then 1           
                 End) *      
         (Case max(ItemCategories.Price_Option) When 1 Then max(BP.PTS) Else max(I1.PTS) End),          
          "PTR" = (Case @UOM   
                    When N'Uom1' Then (Case Isnull(I1.UOM1_Conversion,0) When 0 Then 1 Else I1.UOM1_Conversion End)          
                    When N'Uom2' Then (Case Isnull(I1.UOM2_Conversion,0) When 0 Then 1 Else I1.UOM2_Conversion End)     
                  When N'Sales UOM' Then 1           
                 End) *      
         (Case max(ItemCategories.Price_Option) When 1 Then max(BP.PTR) Else max(I1.PTR) End),    
        "ECP" = (Case @UOM       
                    When N'Uom1' Then (Case Isnull(I1.UOM1_Conversion,0) When 0 Then 1 Else I1.UOM1_Conversion End)          
                    When N'Uom2' Then (Case Isnull(I1.UOM2_Conversion,0) When 0 Then 1 Else I1.UOM2_Conversion End)     
                  When N'Sales UOM' Then 1           
                 End) *      
         (Case max(ItemCategories.Price_Option) When 1 Then max(BP.ECP) Else max(I1.ECP) End),    
    "MRP Per Pack" = (Case max(ItemCategories.Price_Option) When 1 Then max(Isnull(BP.MrpPerPack,0)) Else max(Isnull(I1.MrpPerPack,0)) End),    
         "Tax Applicable" = Bp.TaxSuffered,      
        "Total Quantity" = Case @UOM When N'Sales UOM' Then sum(Isnull(Quantity,0))   
                   Else dbo.sp_Get_ReportingQty(sum(Isnull(Quantity,0)),          
          (Case @UOM --When 'Sales UOM' Then 1          
              When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)          
              When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)          
           End)) End,            
       "Saleable" = Sum(     
          Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then     
             Case @UOM When N'Sales UOM' Then Quantity      
             Else dbo.sp_Get_ReportingQty(Quantity,          
             (Case @UOM --When 'Sales UOM' Then 1          
              When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)          
              When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)          
             End))    
         End      
         Else 0 End    
           ),    
       "Free" = Sum(     
           Case When Free <> 0 And IsNull(Damage, 0) = 0  Then     
             Case @UOM When N'Sales UOM' Then Quantity      
             Else dbo.sp_Get_ReportingQty(Quantity,          
             (Case @UOM --When 'Sales UOM' Then 1          
               When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)          
               When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)          
              End))    
         End      
         Else 0 End    
           ),    
       "Damaged" = Sum(     
          Case When IsNull(Damage,0) <> 0 Then     
             Case @UOM When N'Sales UOM' Then Quantity      
             Else dbo.sp_Get_ReportingQty(Quantity,          
             (Case @UOM --When 'Sales UOM' Then 1          
              When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)          
              When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)          
              End))    
         End      
         Else 0 End    
           ),       
  
  
       "Van Saleable Stock" = Sum(     
          Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then     
             Case @UOM When N'Sales UOM' Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,BP.Batch_Code,1),0)  
             Else dbo.sp_Get_ReportingQty(Isnull(dbo.Fn_GetVanQty(I1.Product_Code,BP.Batch_Code,1),0),          
             (Case @UOM --When 'Sales UOM' Then 1          
   When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)          
              When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)          
             End))    
         End      
         Else 0 End    
           ),    
  
  
          "Van Free Stock " = Sum(     
          Case When IsNull(Free,0)<> 0 And IsNull(Damage,0) <> 1 Then     
             Case @UOM When N'Sales UOM' Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,BP.Batch_Code,2),0)  
             Else dbo.sp_Get_ReportingQty(Isnull(dbo.Fn_GetVanQty(I1.Product_Code,BP.Batch_Code,2),0),          
             (Case @UOM --When 'Sales UOM' Then 1          
              When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)          
              When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)          
             End))    
         End      
         Else 0 End    
           ),    
  
          "DC Saleable Stock " = Sum(     
          Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then     
             Case @UOM When N'Sales UOM' Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,BP.Batch_Code,1),0)  
             Else dbo.sp_Get_ReportingQty(Isnull(dbo.Fn_GetDispQty(I1.Product_Code,BP.Batch_Code,1),0),          
             (Case @UOM --When 'Sales UOM' Then 1          
              When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)          
              When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)          
             End))    
         End      
         Else 0 End    
           ),    
          "DC Free Stock " = Sum(     
          Case When IsNull(Free,0) <> 0 And IsNull(Damage,0) <> 1 Then     
             Case @UOM When N'Sales UOM' Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,BP.Batch_Code,2),0)  
             Else dbo.sp_Get_ReportingQty(Isnull(dbo.Fn_GetDispQty(I1.Product_Code,BP.Batch_Code,2),0),          
             (Case @UOM --When 'Sales UOM' Then 1          
      When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)          
              When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)          
             End))    
         End      
         Else 0 End    
           ),    
  
         "Saleable Value " =      
         Case @StockValuation          
              When N'PTS'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(BP.PTS, 0) Else IsNull(I1.PTS, 0) End) *     
                   (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End))        
              When N'PTR'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(BP.PTR, 0) Else IsNull(I1.PTR, 0) End) *     
                   (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End))     
              When N'ECP'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(BP.ECP, 0) Else IsNull(I1.ECP, 0) End) *     
                    (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End))     
                End,       
         "Damaged Value " =      
         Case @StockValuation          
              When N'PTS'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(BP.PTS, 0) Else IsNull(I1.PTS, 0) End) *     
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End))        
              When N'PTR'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(BP.PTR, 0) Else IsNull(I1.PTR, 0) End) *     
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End))     
              When N'ECP'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(BP.ECP, 0) Else IsNull(I1.ECP, 0) End) *     
                    (Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End))     
                End,         
         "Total Value" =                           
          Case @StockValuation          
           When N'PTS' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(BP.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.PTS, 0)) End) End)             
           When N'PTR' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(BP.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.PTR, 0)) End) End)                    
           When N'ECP' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(BP.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.ECP, 0)) End) End)                                       
         End,   
   "Tax Type" = Case IsNull(BP.TaxType, 0) When 1 Then N'LST'  
             When 2 Then N'CST'  
             When 3 Then N'FLST' 
             When 5 then N'GST' End   
        From          
     Items I1
	 Left Outer Join  Batch_Products BP On I1.Product_Code = BP.Product_Code            
	 Inner Join  ItemCategories On I1.CategoryID = ItemCategories.CategoryID        
	 Inner Join Uom On Uom.Uom = Case @UOM When N'UOM1' Then I1.Uom1 When N'UOM2' Then I1.UOM2 Else I1.UOM End                                                          
         Where          
         Isnull(BP.grn_ID,0) not in (select GrnAbstract.GRNid from GrnAbstract where (Isnull(grnabstract.grnstatus,0) & 96) <> 0)                             
         And I1.Product_Code = @ProductCode      
         And ItemCategories.Active = 1            
         And I1.Active = 1                      
         Group BY          
          I1.Product_Code,ItemCategories.CategoryID,BP.PKD, BP.Batch_Number,Bp.TaxSuffered, BP.Expiry,     
      UOM.[Description], I1.UOM1_Conversion,I1.UOM2_Conversion, BP.PTS, BP.PTR, BP.ECP,Isnull(BP.MrpPerPack,0), BP.TaxType   
       End      
      Else If @UOM = N'UOM1 & UOM2'       
       Begin      
       Select       
           "Batch" = Batch_Number,          
           "Batch" = Batch_Number,     
           "PKD" = Cast(DatePart(mm, BP.PKD) As NVarChar) + N'/'+ SubString(Cast(DatePart(yyyy, BP.PKD) As NVarChar), 1, 4),            
           "Expiry" = Cast(DatePart(mm, BP.Expiry) As NVarChar) + N'/'+ SubString(Cast(DatePart(yyyy, BP.Expiry) As NVarChar), 1, 4),             
           "PFM as Per PAC" = Case max(ItemCategories.Price_Option) When 1 Then max(Isnull(BP.PFM,0)) Else max(Isnull(I1.PFM,0)) End * I1.UOM2_Conversion,                    
           "PTS as Per PAC" = Case max(ItemCategories.Price_Option) When 1 Then max(Isnull(BP.PTS,0)) Else max(Isnull(I1.PTS,0)) End * I1.UOM2_Conversion,                    
           "PTR as Per PAC" = Case max(ItemCategories.Price_Option) When 1 Then max(Isnull(BP.PTR,0)) Else max(Isnull(I1.PTR,0)) End * I1.UOM2_Conversion,                    
           "ECP as Per PAC" = Case max(ItemCategories.Price_Option) When 1 Then max(Isnull(BP.ECP,0)) Else max(Isnull(I1.ECP,0)) End * I1.UOM2_Conversion,         
    "MRP Per Pack" = Case max(ItemCategories.Price_Option) When 1 Then max(Isnull(BP.MRPPerPack,0)) Else max(Isnull(I1.MRPPerPack,0)) End ,         
           "Tax Applicable" = Bp.TaxSuffered,      
           "Total CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,sum(Isnull(Quantity,0)),1),       
           "PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,sum(Isnull(Quantity,0)),2),           
           "Saleable CFC " =  dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
                                Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0     
                          Then Isnull(Quantity,0) Else 0 End),1),       
           "Saleable PAC " = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
                             Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0     
                         Then Isnull(Quantity,0) Else 0 End),2),      
          "Free CFC " = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                        
                             Sum(Case When Free <> 0 And IsNull(Damage, 0) = 0     
                          Then Isnull(Quantity,0) Else 0 End),1),     
           "Free PAC " = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
                             Sum(Case When Free <> 0 And IsNull(Damage, 0) = 0  
                         Then Isnull(Quantity,0) Else 0 End),2),     
          "Damaged CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
                             Sum(Case When IsNull(Damage,0) <> 0     
                         Then Isnull(Quantity,0) Else 0 End),1),     
           "Damaged PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
                             Sum(Case When IsNull(Damage,0) <> 0     
                         Then Isnull(Quantity,0) Else 0 End),2),      
  
   "Van Saleable Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
        Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0     
                         Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,BP.Batch_Code,1),0) Else 0 End),1),    
  
  
   "Van Saleable Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
        Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0     
                         Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,BP.Batch_Code,1),0) Else 0 End),2),    
  
   "Van Free Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
                             Sum(Case When Free <> 0 And IsNull(Damage, 0) <> 1     
                         Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,BP.Batch_Code,2),0) Else 0 End),1),    
  
  
   "Van Free Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
                             Sum(Case When Free <> 0 And IsNull(Damage, 0) <> 1     
                         Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,BP.Batch_Code,2),0) Else 0 End),2),    
  
  "DC Saleable Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
        Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0     
                         Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,BP.Batch_Code,1),0) Else 0 End),1),    
  
  
  "DC Saleable Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
        Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0     
                         Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,BP.Batch_Code,1),0) Else 0 End),2),    
  
  "DC Free Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
                             Sum(Case When Free <> 0 And IsNull(Damage, 0) <> 1     
                         Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,BP.Batch_Code,2),0) Else 0 End),1),    
  
  "DC Free Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                        
                             Sum(Case When Free <> 0 And IsNull(Damage, 0) <> 1     
                         Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,BP.Batch_Code,2),0) Else 0 End),2),    
  
  
           "Saleable Value " =      
        Case @StockValuation          
         When N'PTS'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(BP.PTS, 0) Else IsNull(I1.PTS, 0) End) *     
                   (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End))        
                When N'PTR'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(BP.PTR, 0) Else IsNull(I1.PTR, 0) End) *     
                   (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End))     
                When N'ECP'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(BP.ECP, 0) Else IsNull(I1.ECP, 0) End) *     
                    (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End))     
                End,       
           "Damaged Value " =      
              Case @StockValuation          
                 When N'PTS'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(BP.PTS, 0) Else IsNull(I1.PTS, 0) End) *     
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End))        
                 When N'PTR'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(BP.PTR, 0) Else IsNull(I1.PTR, 0) End) *     
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End))     
                 When N'ECP'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(BP.ECP, 0) Else IsNull(I1.ECP, 0) End) *     
                    (Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End))     
                End,        
           "Total Value" =                           
             Case @StockValuation          
                When N'PTS' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(BP.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.PTS, 0)) End) End)             
                When N'PTR' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(BP.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.PTR, 0)) End) End)                    
                When N'ECP' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(BP.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.ECP, 0)) End) End)                                      
             End ,   
   "Tax Type" = Case IsNull(BP.TaxType, 0) When 1 Then N'LST'  
             When 2 Then N'CST'  
             When 3 Then N'FLST'
             When 5 then N'GST' End                             
           From          
            Items I1
			Left Outer Join  Batch_Products Bp On I1.Product_Code = BP.Product_Code      
			Inner Join  ItemCategories On I1.CategoryID = ItemCategories.CategoryID                                                                           
          Where    
         I1.Product_Code = @ProductCode           
            and Isnull(Bp.grn_ID,0) not in (select GrnAbstract.GRNid from GrnAbstract where (Isnull(grnabstract.grnstatus,0) & 96) <> 0)                                
          Group BY          
            I1.Product_Code, I1.UOM2_Conversion, BP.PKD, BP.Batch_Number, BP.Expiry,    
            Bp.TaxSuffered, BP.PTS, BP.PTR, BP.ECP,BP.MRPPerPack, BP.TaxType   
        End       
   End          
End  
