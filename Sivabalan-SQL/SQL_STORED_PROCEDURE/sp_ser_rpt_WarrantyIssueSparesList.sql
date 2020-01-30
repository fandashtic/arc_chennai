CREATE procedure sp_ser_rpt_WarrantyIssueSparesList(@Item nvarchar(255))                  
as                  
                  
Declare @ParamSep nVarchar(10)                      
Declare @IID int                  
Declare @IssueID int                      
Declare @ItemCode nvarchar(255)                  
Declare @Productcode int                  
Declare @Itemspec1 nvarchar(255)                    
Declare @sparecode nvarchar(255)        
          
Declare @tempString nVarchar(510)                  
Declare @ParamSepcounter int                  
                
Set @tempString = @Item                  
Set @ParamSep = Char(2)                      
                
/* isssueiD */                
                   
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                      
set @IssueID = substring(@tempString, 1, @ParamSepcounter-1)                   
                
                
/* Productcode */                
                  
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                   
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)                  
set @ItemCode = substring(@tempString, 1, @ParamSepcounter-1)                   
                
/* ItemSpecification */                  
        
        
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                   
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)                  
set @Itemspec1 = substring(@tempString, 1, @ParamSepcounter-1)                
        
/* Saprecode */        
                
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                   
set @sparecode =  @tempString           
        
        
Begin                  
 select         
 Batch_Number,              
'Batch' = Batch_Number,              
'UOM'= UOM.[Description],                 
'Qty' = UomQty,                
'Date of Sale ' = DateofSale,           
'Warranty No' = WarrantyNo            
from issuedetail,UOM                   
where IssueID = @IssueID                  
and issueDetail.UOM = UOM.UOM                
and issuedetail.product_Code = @Itemcode                  
and Product_specification1 = @Itemspec1                  
and issuedetail.sparecode = @sparecode        
and warranty = 1                          
order by serialno                
End                  
      
  



