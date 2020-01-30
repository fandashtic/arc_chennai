CREATE Procedure spr_list_CustomerwiseSchemes_Abstract(@CustomerID nvarchar(2550),                              
 @FromDate DateTime,                                      
 @ToDate DateTime,                              
 @SchemeName nvarchar(2550))                                      
As                                      
Begin                  
Declare @CustID as nvarchar(255)                  
Declare @CustName as nvarchar(255)                  
Declare @InvoiceValue Decimal(18,6)                  
Declare @ItemCost Decimal(18,6)                  
Declare @PercDisc Decimal(18,6)                  
Declare @AmountDisc Decimal(18,6)                  
Declare @Schemecost Decimal(18,6)     
Declare @InvNo Int    
                                      
Declare @Delimeter as Char(1)                                                
Set @Delimeter=Char(15)                                               
                                      
Create Table #tmpCust(CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)                                      
If @CustomerID='%'                                      
   Insert into #tmpCust select CustomerID from customer                                      
Else                                      
   Insert into #tmpCust select * from dbo.sp_SplitIn2Rows(@CUSTOMERID,@Delimeter)                                      
                                      
Create table #tmpSch(SchemeName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)                                                
If @SchemeName='%'                                      
   Insert into #tmpSch select SchemeName from Schemes                                      
Else                                      
   Insert into #tmpSch select * from dbo.sp_SplitIn2Rows(@SchemeName,@Delimeter)                  
                  
Create table #tmpCustSch(InvNo Int,CustID nvarchar(255),                  
CustName nvarchar(255),InvoiceValue Decimal(18,6),ItemCost Decimal(18,6),                  
PercDisc Decimal(18,6),AmountDisc Decimal(18,6),SchemeCost Decimal(18,6))                  
                  
--Itembased Same/Diff Prod Free                                        
Declare CustSch Cursor For                                      
Select Inv.InvoiceID,Cust.CustomerID,Cust.Company_Name,Inv.NetValue,                  
SchS.Cost,Inv.DiscountPercentage,Inv.DiscountValue,SchS.Cost                                      
From Schemes Sch, SchemeSale SchS, InvoiceAbstract Inv, Customer Cust                                                
Where Cust.CustomerID In (Select CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCust)                                      
And Inv.CustomerID=Cust.CustomerID                          
And SchS.InvoiceID=Inv.InvoiceID                                  
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                        
And (IsNull(Inv.Status,0) & 192) =0                                  
And Sch.SchemeName In (Select SchemeName COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpSch)                                      
And SchS.Type=Sch.SchemeID                      
And SchS.Quantity > 0                     
      
                  
Open CustSch                  
Fetch Next From CustSch                   
Into @InvNo,@CustID,@CustName,@InvoiceValue,@ItemCost,@PercDisc,@AmountDisc,@Schemecost                  
While @@Fetch_Status = 0                  
Begin                  
 Insert Into #tmpCustSch (InvNo,CustID,CustName,InvoiceValue,ItemCost,PercDisc,                  
 AmountDisc,Schemecost)                  
 Values(@InvNo,@CustID,@CustName,@InvoiceValue,@ItemCost,@PercDisc,                  
 @AmountDisc,@Schemecost)                  
 Fetch Next From CustSch                  
 Into @InvNo,@CustID,@CustName,@InvoiceValue,@ItemCost,@PercDisc,@AmountDisc,@Schemecost                  
End                  
Close CustSch                
Deallocate CustSch                  
                  
--ItemBased Percentage                    
Declare CustSch Cursor For       
Select Inv.InvoiceID,Cust.CustomerID,Cust.Company_Name,Inv.NetValue,                  
SchS.Value,SchS.Cost,((SchS.Value*SchS.Cost)/100),0                                         
From Schemes Sch, SchemeSale SchS, InvoiceAbstract Inv, Customer Cust                                                
Where Cust.CustomerID In (Select CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCust)                                      
And Inv.CustomerID=Cust.CustomerID        
And SchS.InvoiceID=Inv.InvoiceID                                  
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                        
And (IsNull(Inv.Status,0) & 192) =0                                  
And Sch.SchemeName In (Select SchemeName From #tmpSch)                                      
And SchS.Type=Sch.SchemeID                  
And Sch.SchemeType not in (3,4,20,97)                         
And SchS.Quantity = 0                     
                
Open CustSch                  
Fetch Next From CustSch                   
Into @InvNo,@CustID,@CustName,@InvoiceValue,@ItemCost,@PercDisc,@AmountDisc,@Schemecost                  
While @@Fetch_Status = 0                  
Begin                  
 Insert Into #tmpCustSch (InvNo,CustID,CustName,InvoiceValue,ItemCost,PercDisc,                  
 AmountDisc,Schemecost)                  
 Values(@InvNo,@CustID,@CustName,@InvoiceValue,@ItemCost,@PercDisc,                  
 @AmountDisc,@Schemecost)                  
 Fetch Next From CustSch                  
 Into @InvNo,@CustID,@CustName,@InvoiceValue,@ItemCost,@PercDisc,@AmountDisc,@Schemecost                  
End                  
Close CustSch                  
Deallocate CustSch                  
                  
--ItemBased Amount/InvoiceBased Free Items For Value            
--& InvoiceBased Items Worth X Amount Free                             
Declare CustSch Cursor For                                      
Select Inv.InvoiceID,Cust.CustomerID,Cust.Company_Name,Inv.NetValue,                  
SchS.Value,0,0,SchS.Cost            
From Schemes Sch, SchemeSale SchS, InvoiceAbstract Inv, Customer Cust                                                
Where Cust.CustomerID In (Select CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCust)                                      
And Inv.CustomerID=Cust.CustomerID                          
And SchS.InvoiceID=Inv.InvoiceID                                  
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                        
And (IsNull(Inv.Status,0) & 192) =0                                  
And Sch.SchemeName In (Select SchemeName From #tmpSch)                                      
And SchS.Type=Sch.SchemeID                  
And SchS.Quantity = 0            
And Sch.SchemeType in (3,4,20)                 
                  
Open CustSch                  
Fetch Next From CustSch                   
Into @InvNo,@CustID,@CustName,@InvoiceValue,@ItemCost,@PercDisc,@AmountDisc,@Schemecost                  
While @@Fetch_Status = 0                  
Begin                  
 Insert Into #tmpCustSch (InvNo,CustID,CustName,InvoiceValue,ItemCost,PercDisc,                  
 AmountDisc,Schemecost)                  
 Values(@InvNo,@CustID,@CustName,@InvoiceValue,@ItemCost,@PercDisc,                  
 @AmountDisc,@Schemecost)                  
 Fetch Next From CustSch                  
 Into @InvNo,@CustID,@CustName,@InvoiceValue,@ItemCost,@PercDisc,@AmountDisc,@Schemecost                  
End                  
Close CustSch                  
Deallocate CustSch                  
                   
--InvoiceBased Percentage/Amount                  
Declare CustSch Cursor For                                      
Select Inv.InvoiceID,Cust.CustomerID,Cust.Company_Name,Inv.NetValue, 
Inv.GoodsValue,Inv.SchemeDiscountPercentage,Inv.SchemeDiscountAmount,0                                      
From Schemes Sch,InvoiceAbstract Inv,InvoiceDetail InvDet,Customer Cust                    
Where Cust.CustomerID In (Select CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCust)                                      
And Inv.CustomerID=Cust.CustomerID                                      
And Inv.InvoiceDate BetWeen @FromDate And @Todate                  
And (IsNull(Inv.Status,0) & 192) =0                                      
And Sch.SchemeName In (Select SchemeName From #tmpsch)                                      
And Inv.SchemeID=Sch.SchemeID                                      
And Inv.InvoiceId=InvDet.InvoiceID                  
And Sch.SchemeType not in (3,4,97)                                      
                  
Open CustSch                  
Fetch Next From CustSch                   
Into @InvNo,@CustID,@CustName,@InvoiceValue,@ItemCost,@PercDisc,@AmountDisc,@Schemecost                  
While @@Fetch_Status = 0                  
Begin                  
 Insert Into #tmpCustSch (InvNo,CustID,CustName,InvoiceValue,ItemCost,PercDisc,                 
 AmountDisc,Schemecost)                  
 Values(@InvNo,@CustID,@CustName,@InvoiceValue,@ItemCost,@PercDisc,                  
 @AmountDisc,@Schemecost)                  
 Fetch Next From CustSch                  
 Into @InvNo,@CustID,@CustName,@InvoiceValue,@ItemCost,@PercDisc,@AmountDisc,@Schemecost                  
End                  
Close CustSch                  
Deallocate CustSch                  

Update #tmpCustSch Set InvoiceValue = (Select Sum(NetValue) From InvoiceAbstract
Where InvoiceAbstract.InvoiceID = #tmpCustSch.InvNo And 
InvoiceAbstract.CustomerID = #tmpCustSch.CustID)

         
Select CustID,"Cust Id" = CustID,"Cust Name" =CustName,                         
"Inv Val (%c)" = Sum(InvoiceValue),
"Item Cost (%c)" = Sum(ItemCost),                                      
"% Dis" = Sum(PercDisc),"Amt Dis (%c)" = Sum(AmountDisc),                    
"Sch Cost (%c)" = Sum(SchemeCost)                                      
From #tmpCustSch                  
Group by CustID,CustName
    
                    
Drop Table #tmpSch                
Drop Table #tmpCust                  
Drop Table #tmpCustSch                                      
End                                      
          
        
      
      
    





