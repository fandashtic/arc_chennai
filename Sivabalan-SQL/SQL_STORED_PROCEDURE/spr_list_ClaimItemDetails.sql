CREATE procedure spr_list_ClaimItemDetails(@SchemeId Int,@SalesValue Decimal(18,6),@Customerid nvarchar(30))  
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
 "Quantity"=SchemeItems.FreeValue,  
 "Active"=Items.Active  
 From Items,SchemeItems  
 Where SchemeItems.Schemeid=@SchemeId  
 And SchemeItems.FreeItem=Items.Product_Code  
 And @SalesValue>=SchemeItems.StartValue  And @SalesValue<=SchemeItems.EndValue  
End  
Else if(@SchemeType=49)  
Begin  
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
  Select "ProductCode"=CusTable.Product_Code,  
  "Productname"=Items.ProductName,  
  "Quantity"=SchemeItems.FreeValue,  
  "Active"=Items.Active  
  From Items,CusTable,SchemeItems  
  Where SchemeItems.Schemeid=@SchemeId  
  And CusTable.Product_Code=Items.Product_Code  
  And Qty>=SchemeItems.StartValue  And Qty<=SchemeItems.EndValue  
  And Qty>0  
 End   
 Else  
 Begin  
  Select "ProductCode"=CusTable.Product_Code,  
  "Productname"=Items.ProductName,  
  "Quantity"=SchemeItems.FreeValue * Cast(Qty/StartValue as Integer),  
  "Active"=Items.Active  
  From Items,CusTable,SchemeItems  
  Where Qty/StartValue > 0  
  And SchemeItems.Schemeid=@SchemeId    
  And CusTable.Product_Code=Items.Product_Code  
  And Qty >0  
 End  
 dROP TABLE CUSTABLE  
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
  "Quantity"=SchemeItems.FreeValue,  
  "Active"=Items.Active  
  From Items,CusTable,SchemeItems  
  Where SchemeItems.Schemeid=@SchemeId    
  And SchemeItems.FreeItem=Items.Product_Code  
  And Qty>=SchemeItems.StartValue  And Qty<=SchemeItems.EndValue  
  And Qty>0  
 End   
 Else  
 Begin  
  Select "ProductCode"=SchemeItems.FreeItem,  
  "Productname"=Items.ProductName,  
  "Quantity"=SchemeItems.FreeValue * Cast(Qty/StartValue as Integer),  
  "Active"=Items.Active  
  From Items,CusTable,SchemeItems  
  Where Qty/StartValue > 0  
  And SchemeItems.Schemeid=@SchemeId   
  And SchemeItems.FreeItem=Items.Product_Code     
  And Qty >0  
 End  
 dROP TABLE CUSTABLE  
End  


