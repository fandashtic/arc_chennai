CREATE Procedure sp_Get_ReconcileDocumentDetail (@ReconcileID Integer)  
As  
Select ReconcileDetail.Product_Code, Items.ProductName From ReconcileDetail, Items  
Where ReconcileID = @ReconcileID  
and ReconcileDetail.Product_Code = Items.Product_Code  
Order by ReconcileDetail.Product_Code

