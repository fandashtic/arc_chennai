CREATE Proc Sp_Get_SCVanStock_ItemDiff (@VanStmtID Int, @SOList nvarchar(2000),@ShowDiffInQty int = 0 )
As
Declare @Delimeter as Char(1)              
Set @Delimeter=Char(44)        
Create table #tmpSO(Product_Code nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, Pending_Qty Numeric(18,6))        
Insert into #tmpSO        
Select SOD.Product_code, Sum(SOD.Pending) as Pending_Qty From SODetail SOD, SOAbstract SOA        
Where SOA.SoNumber = SOD.SoNumber And         
(isNull(SOA.Status,0) &  192) = 0 And        
SOA.SoNumber in (Select * from dbo.Sp_SplitIn2Rows(@SOList, @Delimeter))        
Group By SOD.Product_code        
IF @ShowDiffInQty = 0         
 Select Product_code From #TmpSO Where Product_code not in(        
 Select Product_code From VanstatementDetail Where DocSerial = @VanStmtID -- and (SalePrice + PTS) > 0         
 Group by Product_code)   And Pending_Qty > 0       
ELSE        
 Select t.Product_code         
 From #tmpSo t,(Select Product_code, sum(Pending) as Pending_Qty From VanstatementDetail Where DocSerial = @VanStmtID -- and (SalePrice+PTS) > 0           
 Group by Product_code) VD          
 Where t.Product_code = VD.Product_code          
 And IsNull(VD.Pending_Qty,0) < IsNull(t.Pending_Qty,0)         
        
Drop Table #TmpSO  
  
  
  
  


