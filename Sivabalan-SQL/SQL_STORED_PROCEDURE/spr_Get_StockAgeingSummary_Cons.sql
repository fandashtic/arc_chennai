CREATE procedure spr_Get_StockAgeingSummary_Cons  
(
 @BranchName NVarChar(4000),
	@StockType NVarChar(10),
	@ItemCode NVarChar(2550)
)  
As  
Begin  
	Declare @Delimeter as Char(1)    
	Set @Delimeter=Char(15)    

	Create Table #TmpProd(Product_Code NVarChar(255))  
	If @ItemCode = N'%'  
	 Insert InTo #TmpProd Select Product_Code From Items  
	Else  
	 Insert into #TmpProd Select * From dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)  

 CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)        
 If @BranchName = N'%'            
  Insert InTo #TmpBranch Select Distinct CompanyId From Reports  
 Else            
  Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))  

 CREATE Table #TmpTbl
	(
		ItemH NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
  SKUCode NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		ItmName NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		A030 Decimal(18,6),
		A3160 Decimal(18,6),
		A6190 Decimal(18,6),
		A91120 Decimal(18,6),
		A121150 Decimal(18,6),
		A151180 Decimal(18,6),
		A1811 Decimal(18,6),
		A1Year Decimal(18,6)
	)

 CREATE Table #TmpTblUnion
	(
		ItemH NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
  SKUCode NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		ItmName NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		A030 Decimal(18,6),
		A3160 Decimal(18,6),
		A6190 Decimal(18,6),
		A91120 Decimal(18,6),
		A121150 Decimal(18,6),
		A151180 Decimal(18,6),
		A1811 Decimal(18,6),
		A1Year Decimal(18,6)
	)

	Declare @Query VarChar(8000)  
	Set @Query = ' Insert #TmpTbl
	(
	 ItemH,SKUCode,ItmName,A030,	A3160,	A6190,A91120,A121150,A151180,A1811,A1Year
 )
	Select	Distinct It.Product_Code,"SKU Code" = It.Product_Code, "Item" = It.ProductName,'  
	Set @Query = @Query + '  
	"0-30" = IsNull((  
	   Select 
					Sum(Quantity)   
	   From 
					Batch_Products BP  
	   Where   
	    BP.Product_Code = It.Product_Code   
	    And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) Between 0 And 31  
	   ),0)'  
	 If @StockType <> 'ALL STOCK'  
	 Begin  
	  Set @Query = @Query + ' -   
	  IsNull((  
	   Select 
					Sum(BP.Quantity)   
	   From 
					Batch_Products BP  
	   Where 
					BP.Product_Code = It.Product_Code   
	    And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) Between 0 And 31  
	    And 
					(
						IsNull(BP.Damage,0) <> 0 
						Or DBO.StripDateFromTime(IsNull(BP.Expiry,GetDate()+1)) <= 
						DBO.StripDateFromTime(GetDate())
					)  
	  ),0)'  
	 End  
	  
	Set @Query = @Query + ',   
	"31-60" = IsNull((  
	    Select 
						Sum(Quantity)   
	    From 
						Batch_Products BP  
	    Where   
	     BP.Product_Code = It.Product_Code   
	     And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) Between 31 And 60  
	   ),0)'  
	 If @StockType <> 'ALL STOCK'  
	 Begin  
	  Set @Query = @Query + ' -   
	  IsNull((  
	   Select 
					Sum(BP.Quantity)   
	   From 
					Batch_Products BP  
	   Where 
					BP.Product_Code = It.Product_Code   
	    And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) Between 31 And 60  
					And 
					(
						IsNull(BP.Damage,0) <> 0 
						Or	DBO.StripDateFromTime(IsNull(BP.Expiry,GetDate()+1))<= 
						DBO.StripDateFromTime(GetDate()))  
	  ),0)'  
	 End  
	  
	Set @Query = @Query + ',   
	"61-90" = IsNull((  
	    Select 
						Sum(Quantity)   
	    From 
						Batch_Products BP  
	    Where   
	     BP.Product_Code = It.Product_Code   
	     And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) Between 61 And 90  
	   ),0)'  
	 If @StockType <> 'ALL STOCK'  
	 Begin  
	  Set @Query = @Query + ' -   
	  IsNull((  
	   Select 
					Sum(BP.Quantity)   
	   From 
					Batch_Products BP  
	   Where 
					BP.Product_Code = It.Product_Code   
	    And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) Between 61 And 90  
	    And 
					(  
	      IsNull(BP.Damage,0) <> 0 Or        
	      DBO.StripDateFromTime(IsNull(BP.Expiry,GetDate()+1)) <= 
							DBO.StripDateFromTime(GetDate())  
	     )  
	  ),0)'  
	 End  
	  
	Set @Query = @Query + ',   
	"91-120" = IsNull((  
	    Select 
						Sum(Quantity)   
	    From 
						Batch_Products BP  
	    Where   
	     BP.Product_Code = It.Product_Code   
	     And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) Between 91 And 120  
	   ),0)'  
	 If @StockType <> 'ALL STOCK'  
	 Begin  
	  Set @Query = @Query + ' -   
	  IsNull((  
	   Select 
					Sum(BP.Quantity)   
	   From 
					Batch_Products BP  
	   Where 
					BP.Product_Code = It.Product_Code   
	    And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) Between 91 And 120  
	    And 
					(  
	      IsNull(BP.Damage,0) <> 0 Or        
	      DBO.StripDateFromTime(IsNull(BP.Expiry,GetDate()+1))   
	       <= DBO.StripDateFromTime(GetDate())  
	     )  
	  ),0)'  
	 End  
	  
	Set @Query = @Query + ',   
	"121-150" = IsNull((  
	    Select 
						Sum(Quantity)   
	    From 
						Batch_Products BP  
	    Where   
	     BP.Product_Code = It.Product_Code 
						And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate())Between 121 And 150  
	   ),0)'  
	 If @StockType <> 'ALL STOCK'  
	 Begin  
	  Set @Query = @Query + ' -   
	  IsNull((  
	   Select 
					Sum(BP.Quantity)   
	   From 
					Batch_Products BP  
	   Where 
					BP.Product_Code = It.Product_Code 
					And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate())Between 121 And 150  
	    And 
					(  
	      IsNull(BP.Damage,0) <> 0 Or        
	      DBO.StripDateFromTime(IsNull(BP.Expiry,GetDate()+1))   
	       <= DBO.StripDateFromTime(GetDate())  
	     )  
	  ),0)'  
	 End  
	  
	Set @Query = @Query + ',   
	"151-180" = IsNull((  
	    Select 
						Sum(Quantity)   
	    From 
						Batch_Products BP  
	    Where   
	     BP.Product_Code = It.Product_Code   
	     And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate())  Between 151 And 180  
	   ),0)'  
	 If @StockType <> 'ALL STOCK'  
	 Begin  
	  Set @Query = @Query + ' -   
	  IsNull((  
	   Select 
					Sum(BP.Quantity)   
	   From 
					Batch_Products BP  
	   Where 
					BP.Product_Code = It.Product_Code   
	    And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) Between 151 And 180  
	    And 
					(  
	      IsNull(BP.Damage,0) <> 0 Or        
	      DBO.StripDateFromTime(IsNull(BP.Expiry,GetDate()+1))   
	       <= DBO.StripDateFromTime(GetDate())  
	     )  
	  ),0)'  
	 End  
	  
	Set @Query = @Query + ',   
	"181-1Year" = IsNull((  
	    Select 
						Sum(Quantity)   
	    From 
						Batch_Products BP  
	    Where   
	     BP.Product_Code = It.Product_Code   
	     And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) Between 181 And 365  
	    ),0)'  
	 If @StockType <> 'ALL STOCK'  
	 Begin  
	  Set @Query = @Query + ' -   
	  IsNull((  
	   Select 
					Sum(BP.Quantity)   
	   From 
					Batch_Products BP  
	   Where 
					BP.Product_Code = It.Product_Code   
	   And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) Between 181 And 365  
	   And
			 (  
	      IsNull(BP.Damage,0) <> 0 Or        
	      DBO.StripDateFromTime(IsNull(BP.Expiry,GetDate()+1))   
	       <= DBO.StripDateFromTime(GetDate())  
	   )  
	  ),0)'  
	 End  
	  
	Set @Query = @Query + ',   
	"> 1Year" = IsNull((  
	    Select 
						Sum(Quantity)   
	    From 
						Batch_Products BP  
	    Where   
	     BP.Product_Code = It.Product_Code   
	     And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) > 365  
	   ),0)'  
	 If @StockType <> 'ALL STOCK'  
	 Begin  
	  Set @Query = @Query + ' -   
	  IsNull((  
	   Select Sum(BP.Quantity)   
	   From Batch_Products BP  
	   Where BP.Product_Code = It.Product_Code   
	    And DateDIff(DD, IsNull(BP.Pkd, Bp.CreationDate), GetDate()) > 365  
	    And (  
	      IsNull(BP.Damage,0) <> 0 Or        
	      DBO.StripDateFromTime(IsNull(BP.Expiry,GetDate()+1))   
	       <= DBO.StripDateFromTime(GetDate())  
	     )  
	  ),0)'  
	 End  
	  
	Set @Query = @Query + 'From Items It   
	                       Where It.Product_Code In (Select Product_Code From #TmpProd)  
																		      Group By IT.Product_Code, It.ProductName'  
	Print @Query  

	Exec (@Query)   

Insert #TmpTblUnion
(
 ItemH,SKUCode,ItmName,A030,	A3160,	A6190,A91120,A121150,A151180,A1811,A1Year
)

		Select
			SKUCode,SKUCode,ItmName,A030,A3160,A6190,A91120,A121150,A151180,A1811,A1Year
		From	
			#TmpTbl

	Union All

		Select
			Field1,Field1,Field2,Field3,Field4,Field5,Field6,Field7,Field8,Field9,Field10
		From	
			#TmpTbl,Reports,ReportAbstractReceived
	 Where  
	  Reports.ReportID In (Select ReportID From Reports Where ReportName = N'Stock Ageing Summary')  
	  And Reports.CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)  
	  And Field1 In (Select Product_Code COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpProd)  
	  And ReportAbstractReceived.ReportID = Reports.ReportID  
	  And Field1 <> N'SKU Code' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:' 
			And #TmpTbl.SKUCode=ReportAbstractReceived.Field1

 Select  
  SKUCode,"SKU Code" = SKUCode,"Item" =ItmName,"0-30" =Sum(A030),"31-60" =Sum(A3160),
  "61-90" = Sum(A6190),"91-120" = Sum(A91120),"121-150" = Sum(A121150),"151-180" = Sum(A151180),
  "181-1Year" = sum(A1811),"> 1Year" = Sum(A1Year)
 From   
  #TmpTblUnion
 Group By  
  ItemH,SKUCode,ItmName
End

