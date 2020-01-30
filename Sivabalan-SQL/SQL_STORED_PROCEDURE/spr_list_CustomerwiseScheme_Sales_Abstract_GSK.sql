CREATE PROCEDURE spr_list_CustomerwiseScheme_Sales_Abstract_GSK(     
@FromDate Datetime ,                 
@ToDate DateTime,        
@SchemeName NVarchar(2550))  
As                            
Begin                                                  
Declare @Delimeter as Char(1)                                                    
Set @Delimeter=Char(15)                                                   
Declare @tmpSch table(SchemeName NVarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)                  
                                                  
If @SchemeName='%'                                                     
   Insert into @tmpSch select SchemeName from Schemes                                               
Else                                                    
   Insert into @tmpSch select * from dbo.sp_SplitIn2Rows(@SchemeName,@Delimeter)       
    
Declare @TempCustSchemeSales table(    
SchemeID NVarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,     
SchemeName NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,    
StartingDate DateTime,    
EndDate DateTime,    
SchemeValue Decimal(18,6),    
SchemeType NVarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS    
)                  
                                                 
                
--InvoiceBased Free Items For Value/Items Worth X Amount Free                              
Insert Into @TempCustSchemeSales           
Select    
"Scheme Type" = cast(Sch.SchemeType as nvarchar)+'|' +cast(Sch.SchemeID as nvarchar) ,    
"Scheme Name" = sch.schemename,    
"Starting Date"=sch.ValidFrom,    
"Ending Date"=sch.ValidTo,    
"Cost of Scheme" = Sum(SchS.Cost),    
"Scheme Type"=dbo.GetSchemeType(SchemeType)    
From Schemes Sch,SchemeSale SchS,InvoiceAbstract Inv    
Where Sch.SchemeName in (Select SchemeName From @tmpSch)    
And SchS.Type=Sch.schemeID      
And Inv.InvoiceID=SchS.InvoiceID    
And Inv.InvoiceDate BetWeen @FromDate And @ToDate    
And (IsNull(Inv.Status,0) & 192) =0                    
And Sch.SchemeType in(3,4)    
Group By Sch.SchemeType,sch.schemename,sch.ValidFrom,sch.ValidTo,Sch.SchemeID    
           
                                 
--Item Based Same Item Free /Item Based Different Item Free         
Insert Into @TempCustSchemeSales     
Select               
"Scheme ID" = cast(Sch.SchemeType as nvarchar)+'|'+cast(Sch.SchemeID as nvarchar) ,     
"Scheme Name" = sch.schemename,                   
"Starting Date"=sch.ValidFrom,    
"Ending Date"=sch.ValidTo,    
"Scheme Value"=sum(Schs.cost),          
"Scheme Type"=dbo.GetSchemeType(SchemeType)    
From InvoiceAbstract Inv,SchemeSale SchS,Schemes Sch    
Where                     
Sch.SchemeName in (Select SchemeName From @tmpSch)                  
And Inv.InvoiceId=Schs.InvoiceID                                        
And Inv.InvoiceDate BetWeen @FromDate And @ToDate    
And (IsNull(Inv.Status,0) & 192) =0                                      
And Sch.SchemeID= SchS.Type                                        
And Sch.SchemeType in (17,18)          
group by Sch.SchemeType,sch.schemename,sch.ValidFrom,sch.ValidTo,Sch.SchemeID                  
    
    
--ItemBased Amount/Percentage                                  
Insert Into @TempCustSchemeSales     
Select                
"Scheme ID" = cast(Sch.SchemeType as nvarchar)+'|'+cast(Sch.SchemeID as nvarchar),    
"Scheme Name" = sch.schemename,              
"Starting Date"=sch.ValidFrom,    
"Ending Date"=sch.ValidTo,    
"Scheme Value" = (select sum (discountvalue) from invoicedetail where InvoiceId=Inv.InvoiceId ),    
"Scheme Type"=dbo.GetSchemeType(SchemeType)    
from invoicedetail Idet                        
Inner Join InvoiceAbstract Inv On Inv.InvoiceId=Idet.InvoiceId                      
Left Join Schemes Sch On Idet.Schemeid=sch.Schemeid                      
Left Join SchemeSale SchS On  schs.InvoiceId=Inv.InvoiceId 
Where Sch.SchemeName in (Select SchemeName From @tmpSch)              
And SchS.Type=Sch.schemeID              
And Inv.InvoiceID=SchS.InvoiceID   
And Inv.InvoiceDate BetWeen @FromDate And @ToDate    
And (IsNull(Inv.Status,0) & 192) =0              
And SchS.Quantity = 0              
And isnull(Idet.discountvalue,0)>0              
And Sch.SchemeType in (19,81,20,82)    
Group By Inv.InvoiceID, sch.SchemeID,SchemeName,sch.ValidFrom,sch.ValidTo,SchemeType    
    
--InvoiceBased Amount/Percentage    
Insert Into @TempCustSchemeSales     
select     
"Scheme ID" = cast(Sch.SchemeType as nvarchar)+'|'+cast(Sch.SchemeID as nvarchar) ,    
"Scheme Name" = sch.schemename,              
"Starting Date"=sch.ValidFrom,    
"Ending Date"=sch.ValidTo,    
"Scheme Value"=Isnull((select SchemeDiscountAmount from invoiceabstract where   
 Schemeid=Sch.SchemeId And InvoiceId=Inv.InvoiceId),0),    
"Scheme Type"=dbo.GetSchemeType(SchemeType)    
From Schemes Sch,InvoiceAbstract Inv                                    
Where Sch.SchemeName in (Select SchemeName From @tmpSch)                                   
And Sch.schemeID = Inv.SchemeID                                     
And (IsNull(Inv.Status,0) & 192) =0          
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                      
And Sch.SchemeType  in (1,2)  
Group By Inv.InvoiceID, sch.SchemeID,SchemeName,sch.ValidFrom,sch.ValidTo,SchemeType      
                      
    
Select SchemeID,  
"Scheme Name"=SchemeName,  
"Starting Date"=StartingDate,  
"Ending Date"=EndDate,  
"Scheme Value"=Sum(SchemeValue),  
"Scheme Type"=SchemeType   
From @TempCustSchemeSales    
Group By SchemeID,SchemeName,StartingDate,EndDate,SchemeType    
  
End                                  

