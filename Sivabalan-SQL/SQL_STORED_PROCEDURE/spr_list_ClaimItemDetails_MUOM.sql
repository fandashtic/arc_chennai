
CREATE Procedure spr_list_ClaimItemDetails_MUOM (         
 @SchemeId Int,        
 @SalesValue Decimal(18,6),        
 @Customerid nvarchar(30))            
As        
Declare @SchemeType int             
Declare @bHasSlabs int             
Declare @Fromdate Datetime            
Declare @Todate Datetime            
    
Select @SchemeType=SchemeType,@bHasSlabs=HasSlabs,            
@FromDate=ValidFrom,            
@ToDate=ValidTo            
From Schemes Where SchemeID=@SchemeId            
            
-- Const OFFTAKE_ITEMBASED_FREE_SAME_ITEMS = 49            
-- Const OFFTAKE_ITEMBASED_FREE_DIFF_ITEMS = 50            
             
IF(@SchemeType=35)            
  Begin            
   --OffTake InvoiceBased FreeItems For Value            
   Select "ProductCode"=SchemeItems.FreeItem,            
   "Productname"=Items.ProductName,            
   "Quantity"=(SchemeItems.FreeValue * (Case IsNull(SchemeItems.FreeUOM,0) When 0 then 1        
                   When 1 then (Select UOM1_conversion From Items Where Items.Product_code = SchemeItems.FreeItem)         
       When 2 then (Select UOM2_conversion From Items Where Items.Product_code = SchemeItems.FreeItem) End)),            
   "Active"=Items.Active            
   From Items,SchemeItems            
   Where SchemeItems.Schemeid=@SchemeId            
    And SchemeItems.FreeItem=Items.Product_Code            
    And @SalesValue>=SchemeItems.StartValue And @SalesValue<=SchemeItems.EndValue         
  End            
Else if(@SchemeType=49)            
  Begin    
    Create Table #tmpTable(ProductCode nvarchar(30), ProductName nvarchar(150), Quantity Decimal(18,6) Default(0), Active Int)            
    Create Table CusTable(Product_Code nvarchar(30),Qty Decimal(18,6) Default(0))            
    Insert into CusTable(Product_Code,Qty)              
    Select InvdeT.Product_Code,            
    Sum(Case InvAb.InvoiceType When 4 then 0-InvDet.Quantity Else InvDet.Quantity End)              
    From InvoiceAbstract InvAb,Customer CusMas,Schemes,            
    InvoiceDetail InvDet,ItemSchemes            
    Where InvAb.CustomerId=CusMas.CustomerId            
    And InvAb.CustomerID=@CustomerID            
    And InvAb.Invoicedate Between @Fromdate And @ToDate            
    And InvAb.InvoiceId=InvDet.InvoiceId            
    And InvAb.InvoiceType In (1,2,3)            
    And (InvAb.Status & 128)=0              
    And Schemes.SchemeID=@SchemeID            
    And ItemSchemes.SchemeId=Schemes.Schemeid            
    And InvDet.Product_Code=ItemSchemes.Product_Code            
    And InvDet.FlagWord =0            
    Group by InvdET.Product_Code            
       
  --OFFTAKE_ITEMBASED_FREE_SAME_ITEMS            
  IF(@bHasSlabs=1)            
    Begin    
    Insert into #tmpTable             
    Select "ProductCode"=CusTable.Product_Code,            
    "Productname"=Items.ProductName,            
    "Quantity"=(SchemeItems.FreeValue * (Case ISNull(FreeUOM,0) When 0 Then 1         
                When 1 Then (Select UOM1_Conversion From Items where Items.Product_code = CusTable.Product_code)        
                When 2 Then (Select UOM2_Conversion From Items where Items.Product_code = CusTable.Product_code) End)),            
    "Active"=Items.Active            
    From Items,CusTable,SchemeItems            
    Where SchemeItems.Schemeid=@SchemeId            
     And CusTable.Product_Code=Items.Product_Code            
     And Qty>=(SchemeItems.StartValue * (Case ISNull(PrimaryUOM,0) When 0 Then 1         
                When 1 Then (Select UOM1_Conversion From Items where Items.Product_code = CusTable.Product_code)        
                When 2 Then (Select UOM2_Conversion From Items where Items.Product_code = CusTable.Product_code) End))        
     And Qty<=(SchemeItems.EndValue * (Case ISNull(PrimaryUOM,0) When 0 Then 1         
                When 1 Then (Select UOM1_Conversion From Items where Items.Product_code = CusTable.Product_code)        
                When 2 Then (Select UOM2_Conversion From Items where Items.Product_code = CusTable.Product_code) End))           
     And Qty>0    
     Select * from #tmpTable Where Quantity > 0             
    End           
  Else            
    Begin    
    Insert into #tmpTable            
    Select "ProductCode"=CusTable.Product_Code,            
    "Productname"=Items.ProductName,            
    "Quantity"=(SchemeItems.FreeValue * (Case ISNull(FreeUOM,0) When 0 Then 1         
                When 1 Then (Select UOM1_Conversion From Items where Items.Product_code = CusTable.Product_code)        
                When 2 Then (Select UOM2_Conversion From Items where Items.Product_code = CusTable.Product_code) End)) *         
    Cast(Qty/(StartValue * (Case ISNull(PrimaryUOM,0) When 0 Then 1         
                When 1 Then (Select UOM1_Conversion From Items where Items.Product_code = CusTable.Product_code)        
                When 2 Then (Select UOM2_Conversion From Items where Items.Product_code = CusTable.Product_code) End)) as Integer),            
    "Active"=Items.Active            
    From Items,CusTable,SchemeItems            
    Where Qty/(StartValue * (Case ISNull(PrimaryUOM,0) When 0 Then 1         
                When 1 Then (Select UOM1_Conversion From Items where Items.Product_code = CusTable.Product_code)        
                When 2 Then (Select UOM2_Conversion From Items where Items.Product_code = CusTable.Product_code) End)) > 0            
    And SchemeItems.Schemeid=@SchemeId              
    And CusTable.Product_Code=Items.Product_Code            
    And Qty>0            
    Select * from #tmpTable Where Quantity > 0    
    End            
  DROP TABLE CUSTABLE            
  End            
Else if(@SchemeType=50)            
  Begin            
  Create Table CusTable(Product_Code nvarchar(30),Qty Decimal(18,6) Default(0),FreeProductCode nvarchar(30))            
  Insert into CusTable(Product_Code,Qty)              
  Select InvdeT.Product_Code,            
  Sum(Case InvAb.InvoiceType When 4 then 0-InvDet.Quantity Else InvDet.Quantity End)              
  From InvoiceAbstract InvAb,Customer CusMas,Schemes,            
  InvoiceDetail InvDet,ItemSchemes            
  Where InvAb.CustomerId=CusMas.CustomerId            
  And InvAb.CustomerID=@CustomerID            
  And InvAb.Invoicedate Between @Fromdate And @ToDate            
  And InvAb.InvoiceId=InvDet.InvoiceId            
  And InvAb.InvoiceType In (1,2,3)            
  And (InvAb.Status & 128)=0              
  And Schemes.SchemeID=@SchemeID            
  And ItemSchemes.SchemeId=Schemes.Schemeid            
  And InvDet.Product_Code=ItemSchemes.Product_Code            
  And InvDet.FlagWord =0            
  Group by InvdET.Product_Code            
            
  --OFFTAKE_ITEMBASED_FREE_SAME_ITEMS            
  IF(@bHasSlabs=1)            
    Begin            
    Select "ProductCode"=SchemeItems.FreeItem,            
    "Productname"=Items.ProductName,            
    "Quantity"=(SchemeItems.FreeValue * (Case IsNull(FreeUOM,0) When 0 Then 1        
                When 1 Then (Select UOM1_Conversion From Items Where Items.Product_Code = SchemeItems.FreeItem)        
                When 2 Then (Select UOM2_Conversion From Items Where Items.Product_Code = SchemeItems.FreeItem) End)),            
    "Active"=Items.Active            
    From Items,CusTable,SchemeItems            
    Where SchemeItems.Schemeid=@SchemeId              
     And SchemeItems.FreeItem=Items.Product_Code            
     And Qty>=(SchemeItems.StartValue  * (Case IsNull(PrimaryUOM,0) When 0 Then 1        
               When 1 Then (Select UOM1_Conversion From Items Where Items.Product_code = CusTable.Product_code)        
               When 2 Then (Select UOM2_Conversion From Items Where Items.Product_code = CusTable.Product_code)End ))        
     And Qty<=(SchemeItems.EndValue * (Case IsNull(PrimaryUOM,0) When 0 Then 1        
               When 1 Then (Select UOM1_Conversion From Items Where Items.Product_code = CusTable.Product_code)        
         When 2 Then (Select UOM2_Conversion From Items Where Items.Product_code = CusTable.Product_code)End ))            
     And Qty>0            
    End             
  Else            
    Begin            
    Select "ProductCode"=SchemeItems.FreeItem,            
    "Productname"=Items.ProductName,            
    "Quantity"=(SchemeItems.FreeValue * (Case FreeUOM When 0 Then 1        
    When 1 Then (Select UOM1_Conversion From Items Where Items.Product_Code = SchemeItems.FreeItem)        
    When 2 Then (Select UOM2_Conversion From Items Where Items.Product_Code = SchemeItems.FreeItem) End))         
              * Cast(Qty/(StartValue * (Case IsNull(PrimaryUOM,0) When 0 Then 1        
                                      When 1 Then (Select UOM1_Conversion From Items Where Items.Product_code = CusTable.Product_code)        
                                      When 2 Then (Select UOM2_Conversion From Items Where Items.Product_code = CusTable.Product_code)End ))as Integer),            
    "Active"=Items.Active            
    From Items,CusTable,SchemeItems            
    Where Qty/(StartValue * (Case IsNull(PrimaryUOM,0) When 0 Then 1        
                              When 1 Then (Select UOM1_Conversion From Items Where Items.Product_code = CusTable.Product_code)        
                              When 2 Then (Select UOM2_Conversion From Items Where Items.Product_code = CusTable.Product_code)End ))> 0            
    And SchemeItems.Schemeid=@SchemeId             
    And SchemeItems.FreeItem=Items.Product_Code               
    And Qty >0            
    End            
  DROP TABLE CUSTABLE        
End            
  
