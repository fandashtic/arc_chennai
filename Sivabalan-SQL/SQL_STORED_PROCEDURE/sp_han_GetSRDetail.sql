CREATE Procedure sp_han_GetSRDetail (@ReturnNumber as nVarchar(50))      
As    
Select SR.[ReturnNumber], SR.[Product_Code] 'ITEMID', SR.[Quantity] 'SRQty'    
,isnull(SR.Price,0) 'SR_Price'    
,isnull(SR.Total_value,0) 'SR_Totalvalue'    
,isnull(SR.ReturnType,0) 'SR_ReturnType'    
,isnull(SR.Reason,0) 'SR_Reason'    
,isnull(SR.CategoryGroupID,0) 'SR_CategoryGroupID'                              
,u.[Description] 'SR_UOM_Desc'                              
,IsNull(u.[UOM], 0) 'UOM_ID'    
,IsNull(u.[Description], '') 'UOM_Desc'                        
,IsNull(i.Product_Code, '') 'Item_Code'                        
,IsNull(i.UOM, 0) 'Item_UOM'                        
,IsNull(i.UOM1, 0) 'Item_UOM1'                        
,IsNull(i.UOM2, 0) 'Item_UOM2'    
From Stock_Return SR                             
Inner Join Items i On i.Product_Code = SR.[Product_Code]                            
Inner Join ItemCategories ic On i.CategoryID = ic.Categoryid           
Left Outer Join UOM u On u.UOM = SR.[UOM]      
Where SR.[ReturnNumber] = @ReturnNumber                          
Order by SR.ReturnNumber, SR.Product_Code, SR.Quantity, SR.UOM 
