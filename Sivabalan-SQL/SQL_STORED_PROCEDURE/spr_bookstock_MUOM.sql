CREATE procedure [dbo].[spr_bookstock_MUOM]
(
 @PRODUCT_CODE NVarChar(15),   
 @UOM NVarChar(50),  
 @ItemCode NVarChar(255),  
 @ItemName NVarChar(255)
)      
As      
Declare @PriceOption Int      
Select @PriceOption = Price_Option From ItemCategOries Where CategOryID = (Select CategOryID From Items Where Product_Code = @PRODUCT_CODE)      
If IsNull(@UOM,N'') = N'' Or @UOM = N'%'  Or   @UOM = N'Base UOM' 
 Set @UOM = N'Sales UOM'        
IF @PriceOption = 1      
	Begin      
		Select
	  Batch_Number, "Batch" = Batch_Number,     
			"PKD" = Cast(DatePart(mm, Batch_Products.PKD) As NVarChar) + N'/'+ SubString(Cast(DatePart(yyyy, Batch_Products.PKD) As NVarChar), 1, 4),    
			"Expiry" = Cast(DatePart(mm, Batch_Products.Expiry) As NVarChar) + N'/'+ SubString(Cast(DatePart(yyyy, Batch_Products.Expiry) As NVarChar), 1, 4),    
		 "Remarks" = 
				Case IsNull(Damage, 0)      
		   When  1 Then N'Stock Adjustment Damages'       
		   When  2 Then N'Sales Return Damages'       
		   Else  Case When IsNull(Free, 0) >= 1 Then N'Free' End      
		  End,    
		 "Available Quantity" =  
				Case @UOM 
					When N'Sales UOM' Then Cast(SUM(Quantity) As NVarChar) 
					Else 
						Cast(dbo.sp_Get_ReportingQty( IsNull(SUM(Quantity), 0),    
				 (Case @UOM 
		 				When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
						 When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
					 End)) As NVarChar) + N' ' +  Cast((
						Case @UOM 
							When N'Sales UOM' Then SalesUOM.Description    
						 When N'Uom1' Then (Select IsNull(Description,N'') From UOM Where UOM = Items.UOM1)    
						 When N'Uom2' Then (Select IsNull(Description,N'') From UOM Where UOM = Items.UOM2)    
						End)As NVarChar) 
				End,      
		 "Conversion Unit" = Cast(Cast(Items.ConversionFactor * IsNull(SUM(Quantity), 0) As Decimal(18,6)) As NVarChar)+ N' '+ Cast(ConversionTable.ConversionUnit As NVarChar),      
		 "Reporting UOM" = Cast(dbo.sp_Get_ReportingQty(SUM(IsNull(QUANTITY, 0)), IsNull((Select ReportingUnit From Items Where Product_Code = @PRODUCT_CODE), 0)) As NVarChar)  + N' ' + Cast((Select Description From UOM Where UOM = Items.ReportingUOM) As NVarChar),     
		 "Purchase Price" = IsNull(Batch_Products.PurchasePrice, 0)*  
		  (Case @UOM When N'Sales UOM' Then 1    
			   When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
			   When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
	   End),      
		 "PTS" = IsNull(Batch_Products.PTS, 0)*  
		  (Case @UOM When N'Sales UOM' Then 1    
			   When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
			   When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
	   End),       
		 "PTR" = IsNull(Batch_Products.PTR, 0)*  
		  (Case @UOM When N'Sales UOM' Then 1    
				  When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
				  When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
	   End),       
		 "ECP" = IsNull(Batch_Products.ECP, 0)*  
		  (Case @UOM When N'Sales UOM' Then 1    
			   When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
			   When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
		   End),       
		 "Special Price" = IsNull(Batch_Products.Company_Price, 0)*  
		  (Case @UOM When N'Sales UOM' Then 1    
				  When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
				  When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
		  End)  
		From 
			Batch_Products, Items, UOM As SalesUOM, ConversionTable      
		Where 
			Batch_Products.Product_Code = @PRODUCT_CODE AND       
			Items.Product_Code = Batch_Products.Product_Code AND      
			Batch_Products.Quantity > 0 AND      
			Items.UOM *= SalesUOM.UOM AND      
			Items.ConversionUnit *= ConversionTable.ConversionID      
		GROUP BY 
			Batch_Products.Batch_Number, Batch_Products.PKD,Batch_Products.Expiry,
		 Batch_Products.ECP, Batch_Products.PTS,Batch_Products.PurchasePrice,
		 Batch_Products.PTR, Batch_Products.Company_Price, IsNull(Free, 0),IsNull(Damage, 0),
		 SalesUOM.Description, Items.ConversionFactor, Items.ConversionUnit,Items.ReportingUnit,
		 Items.ReportingUOM, ConversionTable.ConversionUnit,Items.UOM1_Conversion,
			Items.UOM2_Conversion,Items.UOM1,Items.UOM2    
	End      
Else      
	Begin      
		Select  Batch_Number, "Batch" = Batch_Number,     
		"PKD" = Cast(DatePart(mm, Batch_Products.PKD) As NVarChar) + N'/'+ SubString(Cast(DatePart(yyyy, Batch_Products.PKD) As NVarChar), 1, 4),    
		"Expiry" = Cast(DatePart(mm, Batch_Products.Expiry) As NVarChar) + N'/'+ SubString(Cast(DatePart(yyyy, Batch_Products.Expiry) As NVarChar), 1, 4),       
	 "Remarks" = 
			Case IsNull(Damage, 0)      
		  When  1 Then N'Stock Adjustment Damages'       
		  When  2 Then N'Sales Return Damages'       
		  Else  Case When IsNull(Free, 0) >= 1 Then N'Free' End      
		 End,    
		 "Available Quantity" =  
				Case @UOM 
					When N'Sales UOM' Then Cast(SUM(Quantity) As NVarChar) 
					Else 
						Cast(dbo.sp_Get_ReportingQty( IsNull(SUM(Quantity), 0),    
				 (Case @UOM 
		 				When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
						 When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
					 End)) As NVarChar) + N' ' +  Cast((
						Case @UOM 
							When N'Sales UOM' Then SalesUOM.Description    
						 When N'Uom1' Then (Select IsNull(Description,N'') From UOM Where UOM = Items.UOM1)    
						 When N'Uom2' Then (Select IsNull(Description,N'') From UOM Where UOM = Items.UOM2)    
						End)As NVarChar) 
				End + N' ' +  Cast(    
			 (Case @UOM 
						When N'Sales UOM' Then SalesUOM.Description    
					 When N'Uom1' Then (Select IsNull(Description,N'') From UOM Where UOM = Items.UOM1)    
					 When N'Uom2' Then (Select IsNull(Description,N'') From UOM Where UOM = Items.UOM2)    
			 	End)    
			 As NVarChar),      
		 "Conversion Unit" = Cast(Cast(Items.ConversionFactor * IsNull(SUM(Quantity), 0) As Decimal(18,6)) As NVarChar)+ N' ' + Cast(ConversionTable.ConversionUnit As NVarChar),      
		 "Reporting UOM" = Cast(dbo.sp_Get_ReportingQty(SUM(IsNull(QUANTITY, 0)), IsNull((Select ReportingUnit From Items Where Product_Code = @PRODUCT_CODE), 0)) As NVarChar)  + N' ' + Cast((Select Description From UOM Where UOM = Items.ReportingUOM) As NVarChar),
		 "Purchase Price" = IsNull(Items.Purchase_Price, 0)*  
    (Case @UOM When N'Sales UOM' Then 1    
		    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
		    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
     End),      
		 "PTS" = IsNull(Items.PTS, 0)*  
	  	(Case @UOM When N'Sales UOM' Then 1    
			   When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
			   When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
	  	End),       
		 "PTR" = IsNull(Items.PTR, 0)*  
				(Case @UOM When N'Sales UOM' Then 1    
						When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
						When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
				End),       
		 "ECP" = IsNull(Items.ECP, 0)*  
		  (Case @UOM When N'Sales UOM' Then 1    
			   When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
			   When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
		   End),       
		 "Special Price" = IsNull(Items.Company_Price, 0)*  
		  (Case @UOM When N'Sales UOM' Then 1    
			   When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)    
			   When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)    
		   End)    
		From 
			Batch_Products, Items, UOM As SalesUOM, ConversionTable      
		Where 
			Batch_Products.Product_Code = @PRODUCT_CODE AND       
			Items.Product_Code = Batch_Products.Product_Code AND      
			Batch_Products.Quantity > 0 AND      
			Items.UOM *= SalesUOM.UOM AND      
			Items.ConversionUnit *= ConversionTable.ConversionID      
		GROUP BY 
			Batch_Products.Batch_Number,Batch_Products.PKD,Batch_Products.Expiry,Items.ECP,
		 Items.Purchase_Price,Items.PTS, Items.PTR,Items.Company_Price,IsNull(Free, 0),
		 IsNull(Damage, 0),SalesUOM.Description,Items.ConversionFactor,Items.ConversionUnit,
		 Items.ReportingUnit,Items.ReportingUOM,ConversionTable.ConversionUnit,
			Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2      
	End
