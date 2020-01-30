Create Procedure spr_han_SalesReturnDetail(@Data nVarchar(3000))        
As 
Declare @ParamSep Char(1)        
Declare @Pos Int        
Declare @tmpStr nVarchar(300)        
Declare @SalesManID   nVarchar(30)        
DEclare @DocumentID  nVarchar(30)        
Declare @CustomerID  nVarchar(30)        
DEclare @BeatID  nVarchar(100)        
Declare @DocumentDate  nVarchar(100)
Declare @ReturnType Int        
    
Set @ParamSep = Char(15)        
Set @tmpStr = @Data     
    
--Customer ID Extraction        
Set @tmpStr = SubString(@tmpstr,1, len(@tmpstr))        
Set @Pos = CHARINDEX(@ParamSep,@tmpStr,1)        
Set @CustomerID = SubString(@tmpStr,1, @Pos - 1)        
--SalesmanID Extraction        
Set @tmpStr = SubString(@tmpStr, @pos + 1, len(@tmpstr))        
Set @Pos = CHARINDEX(@ParamSep,@tmpStr,1)        
Set @SalesmanID = SubString(@tmpStr,1, @Pos - 1)        
--Beat ID Extraction        
Set @tmpStr = SubString(@tmpStr, @pos + 1, len(@tmpstr))        
Set @Pos = CHARINDEX(@ParamSep,@tmpStr,1)        
Set @BeatID = SubString(@tmpStr,1, @Pos - 1)
--Return Type Extraction         
Set @tmpStr = SubString(@tmpStr, @pos + 1, len(@tmpstr))        
Set @Pos = CHARINDEX(@ParamSep,@tmpStr,1)        
Set @ReturnType = SubString(@tmpStr,1, @Pos - 1)
--DocumentDate Extraction    
Set @DocumentDate = SubString(@tmpStr,@Pos + 1, len(@tmpstr)) 
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)  
Exec sp_CatLevelwise_ItemSorting       
Select "ProductCode" = IsNull(StkRet.Product_Code,'')        
,"ItemCode" = IsNull(StkRet.Product_Code,'')     
,"ItemName" = IsNull(I.ProductName,'')
,"Returned UOM" = IsNull(U.Description,0)
,"Returned Qty" = sum(IsNull(StkRet.Quantity,0))
,"Rate" = IsNull(StkRet.Price,0)        
,"Value" = sum(IsNull(StkRet.Total_Value,0))    
From Stock_Return StkRet        
Inner Join Items I ON IsNull(StkRet.Product_Code,'') = IsNull(I.Product_Code,'')         
Inner Join UOM U ON IsNull(StkRet.UOM,0)=IsNull(U.UOM,0)
Inner Join #tempCategory1 ic On I.CategoryID = ic.CategoryID            
Where IsNull(StkRet.SalesManID,0) = @SalesManID        
AND IsNull(StkRet.Outletid,'') = @CustomerID     
AND IsNull(StkRet.BeatID,0) = @BeatID
And IsNull(StkRet.ReturnType,0) = @ReturnType    
AND Cast(StkRet.DocumentDate as varchar)= @DocumentDate    
Group by StkRet.Product_code
,I.ProductName
,U.Description
,StkRet.Quantity
,StkRet.Price
,StkREt.Total_Value
,Ic.IDS
order by Ic.IDS,StkRet.Product_Code        
Drop Table #tempCategory1       
