CREATE Function fn_han_Get_SchemeFreeItem(@SlabID Int)    
Returns nvarchar(50)  
As    
Begin    
Declare @SKUCode nvarchar(50)  
select @SKUCode=Tmp.FreeItem from (SELECT Top 1 TSFS.SKUCode 'FreeItem', SUM(TBP.Quantity) FreeQty             
FROM tbl_mERP_SchemeFreeSKU TSFS 
left join Batch_Products TBP on TSFS.SKUCode=TBP.Product_Code  
where TSFS.SlabId= @SlabID
and ISNULL(TBP.Damage, 0) = 0 
and (TBP.expiry > getdate() or TBP.expiry is null) --IsNull(TBP.Expiry,'9999') > getdate() 
GROUP BY TSFS.SlabId,TSFS.SKUCode  
Order By FreeQty desc)Tmp
return @SKUCode 
End   
