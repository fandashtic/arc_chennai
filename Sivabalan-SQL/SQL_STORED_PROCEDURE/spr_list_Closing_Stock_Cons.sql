CREATE Procedure spr_list_Closing_Stock_Cons  
(       
 @BranchName NVarChar(4000),    
 @UOM NVarChar(255),  
 @Given_Date DateTime  
)  
AS    
 Declare @Operating_Period as DateTime      
 Select @Given_Date = dbo.StripDatefromTime(@Given_Date)     
 Select @Operating_Period = dbo.StripDatefromTime (GetDate())     
   
 Declare @Delimeter as Char(1)          
 Set @Delimeter=Char(15)    

 CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)          
 If @BranchName = N'%'              
  Insert InTo #TmpBranch Select Distinct CompanyId From Reports    
 Else              
  Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))    
  
  
 Create table #TmpLocalStk  
 (  
  ItemCode NVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,  
  SaleableStock Decimal(18,6),   
  FreeStock Decimal(18,6),  
  ClosingValue Decimal(18,6),  
  ForumCode NVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS  
  )         
  
 Create table #TmpLocalStkUnion  
 (  
  ItemCode NVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,  
  SaleableStock Decimal(18,6),   
  FreeStock Decimal(18,6),  
  ClosingValue Decimal(18,6),  
  ForumCode NVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS  
  )       
  
 If @Operating_Period <= @Given_Date     
  Insert Into #TmpLocalStk(ItemCode,SaleableStock,FreeStock,ClosingValue,ForumCode)  
  Select   
   "Item Code" = Batch_Products.Product_Code,  
   "Saleable Stock" = Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End),  
   "Free Stock" = Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End),  
   "Closing Value (%c)" = Cast((  
     Case ItemCategories.Price_Option    
      When 0 Then    
        Cast(Sum(  
        Case   
         When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then   
          Cast((Quantity * Items.Purchase_Price) as Decimal(18,6))   
         Else 0 End  
        )as Decimal(18,6))      
      Else    
        Cast(Sum(  
        Case   
         When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then   
          Cast((Quantity * Batch_Products.PurchasePrice) as Decimal(18,6))   
         Else 0 End  
        )as Decimal(18,6))    
     End) as Decimal(18,6)),    
  "Forum Code" = Items.Alias     
  From   
   Batch_Products,Items,UOM,ItemCategories   
  Where   
   Items.UOM = UOM.UOM    
   And Items.CategoryID = ItemCategories.CategoryID    
   And Batch_Products.Product_Code = Items.Product_Code    
  Group By   
   Batch_Products.Product_Code, ItemCategories.Price_Option,Items.Alias,Items.ProductName  
  Order by   
   Batch_Products.Product_Code    
 Else    
  Begin  
  Insert Into #TmpLocalStk(ItemCode,SaleableStock,FreeStock,ClosingValue,ForumCode)  
   Select   
    "Item Code" = OpeningDetails.Product_Code,  
    "Saleable Stock" = Cast(Opening_Quantity - Damage_Opening_Quantity as NVarChar),  
    "Free Stock" = Cast(Free_Opening_Quantity as NVarChar),"Closing Value (%c)" = Opening_Value,  
    "Forum Code" = Items.Alias     
   From   
    OpeningDetails,UOM,Items  
   Where   
    Opening_Date = DateAdd(Day,1,@Given_date)    
    And Items.UOM = UOM.UOM    
    And OpeningDetails.Product_Code = Items.Product_Code    
   Order by   
    OpeningDetails.Product_Code  
  End  
  

  Insert Into #TmpLocalStkUnion(ItemCode,SaleableStock,FreeStock,ClosingValue,ForumCode)  
  Select   
    "Item Code" = ItemCode,"Saleable Stock" = SaleableStock,  
    "Free Stock" = FreeStock,"Closing Value (%c)" = ClosingValue,  
    "Forum Code" = ForumCode  
  From    
   #TmpLocalStk  
  
 Union All  
  
  Select         
   "Item Code" = IsNull(Field1,''),
			"Saleable Stock" = Sum(
			 (Case 
					When Field2='' Then Cast(0 As Decimal(18,6))
					When Field2=NULL Then Cast(0 As Decimal(18,6))   
					Else Cast(Field2 As Decimal(18,6))
				End)),
   "Free Stock" = Sum(
			 (Case 
						When Field3='' Then Cast(0 As Decimal(18,6))
						When Field3=Null Then Cast(0 As Decimal(18,6))
						Else Cast(Field3 As Decimal(18,6))
					End)),
   "Closing Value (%c)" = Sum(Cast(Field4 As Decimal(18,6))),
   "Forum Code" = IsNull(Field5,'')            
  From    
   Reports,ReportAbstractReceived  
  Where    
   Reports.ReportID In (Select Max(ReportID) From Reports Where ReportName = N'Closing Stock'    
   And ParameterID In (Select ParameterID From dbo.GetReportParameters_ClosingStk_DAILY(N'Closing Stock') Where GivenDate = @Given_Date)Group by CompanyId)  
   And ReportAbstractReceived.ReportID = Reports.ReportID  
   And Field1 <> N'Item Code'  And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:'   
   And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)  

  Group by   
   Field1,Field5  
  
  Select   
    ItemCode,"Item Code" = ItemCode,  
    "Saleable Stock" =   
     Case @UOM  
      When 'Sales UOM' Then Sum(IsNull(SaleableStock,0))  
      When 'Conversion Factor'  Then  Sum(IsNull(SaleableStock,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))  
      When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCode,Sum(IsNull(SaleableStock,0)))    
     End,  
    "Free Stock" =   
     Case @UOM  
      When 'Sales UOM' Then Sum(IsNull(FreeStock,0))  
      When 'Conversion Factor'  Then  Sum(IsNull(FreeStock,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))  
      When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCode,Sum(IsNull(FreeStock,0)))    
     End,  
    "Closing Value (%c)" = Sum(ClosingValue),  
    "Forum Code" = ForumCode  
  From    
   #TmpLocalStkUnion,Items  
  Where  
    Items.Product_Code=#TmpLocalStkUnion.ItemCode  
  Group By   
   ItemCode,ForumCode  
  Order By  
   ItemCode  
  
 Drop Table #TmpLocalStk  
 Drop Table #TmpLocalStkUnion 
 Drop Table #TmpBranch 

