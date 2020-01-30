CREATE procedure sp_ser_rpt_OpenEstimationdetail (@EstimationID int)              
as              
Declare @ParamSep nVarchar(10)            
Set @ParamSep = Char(2)            
Declare @Itemspec1 nvarchar(50)               
Declare @Itemspec2 nvarchar(50)              
Declare @Itemspec3 nvarchar(50)              
Declare @Itemspec4 nvarchar(50)              
Declare @Itemspec5 nvarchar(50)              
Declare @ItemInfo nvarchar(4000)              
Declare @ItemInfo1 nvarchar(4000)                            

select @Itemspec1 = servicecaption from servicesetting where servicecode = 'Itemspec1'              
select @Itemspec2 = servicecaption from servicesetting where servicecode = 'Itemspec2'              
select @Itemspec3 = servicecaption from servicesetting where servicecode = 'Itemspec3'              
select @Itemspec4 = servicecaption from servicesetting where servicecode = 'Itemspec4'              
select @Itemspec5=  servicecaption from servicesetting where servicecode = 'Itemspec5'   
  
Create table #OpenEstimation_Temp([_EstimationID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[_Date of Sale] datetime null,[_Delivery Date] datetime null)  
  
set @Iteminfo =  'Alter Table #OpenEstimation_Temp Add [_Item Code] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[_Item Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,                
[' + @Itemspec1 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,
[' + @ItemSpec2 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                
[' + @ItemSpec3 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,
[' + @ItemSpec4 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                 
[' + @ItemSpec5 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,
[_Color] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS null,                 
[_Sold By] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS null, 
[_Delivery Time] nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS null'                  
         
Exec sp_executesql @Iteminfo              
              
Insert into #OpenEstimation_Temp  
select 'EID' = cast(EstDet.EstimationID as nvarchar(20)) + @paramsep + EstDet.product_code + @Paramsep + EstDet.product_specification1,               
IIT.DateofSale,EstDet.Deliverydate,
EstDet.product_code,I.productname,              
EstDet.product_specification1,              
IIT.product_specification2,              
IIT.product_specification3,              
IIT.product_specification4,              
IIT.product_specification5,              
GM.[Description],IIT.soldby,      
'DeliveryTime' = isnull(dbo.sp_ser_StripTimeFromDate(EstDet.DeliveryTime),'')               
from EstimationAbstract EstAbs
Inner Join EstimationDetail EstDet on EstAbs.EstimationID = EstDet.EstimationID               
Inner Join Items I on EstDet.Product_Code = I.product_code
Left Outer Join Iteminformation_transactions IIT on IIT.Documentid = EstDet.serialno and IIT.DocumentType = 1
Left Outer Join Generalmaster GM on IIT.Color = GM.Code
where EstAbs.EstimationID = @EstimationID and
		EstDet.serialno in (Select min(m.serialno) from EstimationDetail m 
		Where m.EstimationID = @EstimationID and m.Product_code = EstDet.Product_code and 
		m.product_specification1 = EstDet.product_specification1)               
group by  EstDet.EstimationID,EstDet.product_code,I.productname,          
EstDet.product_specification1 ,          
IIT.product_specification2 ,          
IIT.product_specification3 ,          
IIT.product_specification4 ,          
IIT.product_specification5 ,          
GM.[Description],IIT.DateofSale,IIT.soldby ,EstDet.Deliverydate ,EstDet.DeliveryTime          


Set @ItemInfo1 = 'Select [_EstimationID] as "EstimationID",
[_Item Code] as "Item Code",
[_Item Name] as "Item Name", 
[' + @Itemspec1 + '],[' + @Itemspec2 + '],[' + @Itemspec3 + '],
[' + @Itemspec4 + '],[' + @Itemspec5 + '],
[_Color] as "Color",
[_Date of Sale] as "Date of Sale",
[_Sold By] as "Sold By",
[_Delivery Date] as "Delivery Date",
[_Delivery Time] as "Delivery Time" from #OpenEstimation_Temp'

Exec sp_executesql @Iteminfo1  
Drop Table #OpenEstimation_Temp  
         
