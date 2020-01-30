CREATE procedure [dbo].[sp_ser_rpt_IssueSparesListOpen](@Item nvarchar(255))                      
as                      
                      
Declare @ParamSep nVarchar(10)   
Declare @IssueID int                          
Declare @ItemCode nvarchar(255)                      
Declare @Itemspec1 nvarchar(255)                        
              
Declare @tempString nVarchar(510)                      
Declare @ParamSepcounter int                      
                    
Set @tempString = @Item                      
Set @ParamSep = Char(2)                          
                    
/* IssueID */                    
                       
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                          
set @IssueID = substring(@tempString, 1, @ParamSepcounter-1)                       
                    
                    
/* Productcode */                    
                      
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                       
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)                      
set @ItemCode = substring(@tempString, 1, @ParamSepcounter-1)                       
                    
/* ItemSpecification */                      
                    
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                       
set @Itemspec1 =  @tempString                          
Begin                      
	select Issuedetail.SpareCode,  
	'Spare Code'  = Issuedetail.SpareCode,                 
	'Spare Name ' = productname,                  
	'Batch' = Isnull(Batch_Number,''),                  
	'UOM'= UOM.[Description],                     
	'Qty' = isnull(IssuedQty,0) * (Isnull(UomQty, 0) / isnull(IssuedQty,0)),          
	'Returned Qty' = isnull(ReturnedQty,0) * (Isnull(UomQty, 0) / isnull(IssuedQty,0)),          
	'Net Qty' = (isnull(IssuedQty,0) - isnull(ReturnedQty,0)) * (Isnull(UomQty, 0) / isnull(IssuedQty,0)),                    
	'Date of Sale ' = DateofSale,               
	(case Isnull(Warranty,'') when 1 then 'Yes' when 2 then 'No'else '' end) as 'Warranty',                       
	'Warranty No' = Isnull(WarrantyNo,''),                
	'Purchase Price' = Isnull(PurchasePrice,0) / (Isnull(UomQty, 0) / isnull(IssuedQty,0)),
	'Sale Price' = isnull(uomprice,0),              
	'Personnel Name' = Isnull(PersonnelMaster.PersonnelName,''), 'ColumnKey' = 3
	from issuedetail,items,UOM,PersonnelMaster                       
	where issueDetail.SpareCode = items.product_Code                      
	and issueDetail.UOM = UOM.UOM                    
	and IssueID = @IssueID                      
	and issuedetail.product_Code = @Itemcode
	and Product_specification1 = @Itemspec1
	and issuedetail.personnelID *= PersonnelMaster.PersonnelID
	order by serialno                    
End
