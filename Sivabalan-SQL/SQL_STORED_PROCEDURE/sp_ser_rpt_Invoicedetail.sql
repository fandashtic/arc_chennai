CREATE Procedure sp_ser_rpt_Invoicedetail (@ServiceInvoiceID int)                          
as                           
Declare @Prefix nvarchar(15)                  
Declare @ParamSep nVarchar(10)                        
Set @ParamSep = Char(2)                        
Declare @Itemspec1 nvarchar(50)                           
Declare @ItemInfo nvarchar(4000)                          
Declare @ItemCode nvarchar(255)                    
Declare @tempString nVarchar(510)                    
Declare @ParamSepcounter int                    
Declare @Iteminfo1 nvarchar(4000)  
            
select @Itemspec1 = servicecaption from servicesetting where servicecode = 'Itemspec1'                          
select @Prefix = Prefix from VoucherPrefix where TranID = 'SERVICEINVOICE'                                              

Create table #ServiceInvoiceDetail_Temp([_ID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)                      
                          
set @Iteminfo =  'Alter table #ServiceInvoiceDetail_Temp Add
[_Item Code] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,        
[_Item Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,                                              
[' + @Itemspec1 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                                           
[_Color] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS null,        
[_Type] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,        
[_Amount] decimal(18,6) null,        
[_Net Value] decimal(18,6) null'

Exec sp_executesql @Iteminfo      

Insert into #ServiceInvoiceDetail_Temp 

Select [ID], [Item Code],[Item Name],Spec1,Color,Type,       
Sum(Amount) as [Amount], Sum(NetValue) as [Net Value] From   
    
(Select 'ID' =  cast(InvDet.serviceinvoiceID as nvarchar(20)) + @paramsep + InvDet.Product_code        
+ @paramsep + InvDet.product_specification1 + @paramsep +       
cast((case when InvDet.Type = 2 and Isnull(InvDet.sparecode,'') = '' then 2        
 when Isnull(InvDet.sparecode,'') <> '' then 3 end) as nvarchar(15)),            
'Item Code' = InvDet.Product_Code,        
'Item Name' = I.ProductName,        
InvDet.product_specification1  Spec1,        
'Color' = dbo.sp_ser_getitemcolor(@ServiceInvoiceID,InvDet.product_specification1,InvDet.Product_Code),
'Type' = case when InvDet.Type = 2 and Isnull(InvDet.sparecode,'') = '' then 'Task'        
 when Isnull(InvDet.sparecode,'') <> '' then 'Spare' end,            
'Amount' = Sum(IsNull(InvDet.Amount,0)),  
'NetValue' = Sum(IsNull(InvDet.NetValue,0)) 
from serviceinvoicedetail InvDet 
Inner Join Items I on InvDet.Product_Code = I.Product_Code
where InvDet.ServiceInvoiceID = @Serviceinvoiceid      
and Invdet.Type in (2,3)
group by InvDet.ServiceInvoiceID,InvDet.Type,  
InvDet.product_code,InvDet.product_specification1,  
InvDet.SpareCode,InvDet.Type,InvDet.Serialno,  
I.ProductName) S  
Group by [ID], [Item Code], [Item Name], Type, Spec1,Color,Type
      
set @Iteminfo1 = 'Select [_ID] as "ID",[_Item Code] as  "Item Code",
[_Item Name] as "Item Name",[' + @Itemspec1 + '],
[_Color] as "Color",[_Type] as "Type",
[_Amount] as "Amount",[_Net Value] as "Net Value"
From  #ServiceInvoiceDetail_Temp'     

Exec Sp_executesql @Iteminfo1
Drop Table #ServiceInvoiceDetail_Temp  
