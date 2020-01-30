CREATE Proc Sp_RevertSOQty_FromInvoice (@InvNo Int)  
As  
Declare @SONoList nVarchar(2000)                
Select @SONoList = SONumber From InvoiceAbstract Where InvoiceID = @InvNo                
Create Table #TempSO(SONumber Int)                
Insert into #TempSO Select * from Dbo.Sp_SplitIn2Rows(@SONoList,N',')                
DECLARE @SONumber Int                
DECLARE @PROD_CODE nVarchar(30)                 
DECLARE @INV_QTY Numeric(18,6)               
DECLARE @SO_QTY Numeric(18,6)            
DECLARE @PENDING_QTY Numeric(18,6)              
      
DECLARE Cur_UpdateSOQty CURSOR FOR                
Select InvDet.Product_code, InvDet.Quantity, Sum(SODet.SOQty), Sum(SODet.Pending)            
From (Select InvoiceDetail.Product_Code, (Sum(InvoiceDetail.Quantity) - (Select Isnull(Sum(Exs_Qty),0) From InvFromSODetail, #TempSO 
Where InvFromSODetail.SONumber = #TempSO.SoNumber And InvFromSODetail.InvoiceID = @InvNo And InvFromSODetail.Product_Code = InvoiceDetail.Product_Code)) as Quantity              
  From InvoiceDetail Where  InvoiceID = @InvNo And FlagWord = 0             
  Group By Product_Code) as InvDet,             
 (Select SODet.SoNumber, Product_Code, Sum(Quantity) SOQty, Sum(Pending) Pending            
  From SODetail SODet, #TempSO tSO                
  Where SODet.SONumber = tSO.SONumber            
  Group By SODet.SoNumber, Product_Code) SODet            
Where             
 InvDet.Product_Code = SODet.Product_Code          
Group by       
 InvDet.Product_code, InvDet.Quantity          
OPEN Cur_UpdateSOQty              
FETCH NEXT FROM Cur_UpdateSOQty INTO @PROD_CODE, @INV_QTY, @SO_QTY, @PENDING_QTY              
 WHILE @@FETCH_STATUS = 0                
  BEGIN                
  DECLARE @CUR_QTY Numeric(18,6), @CUR_PND Numeric(18,6)      
  DECLARE @TOT_QTY Numeric(18,6), @REM_QTY Numeric(18,6)      
  DECLARE UPDATE_ROW CURSOR FOR      
  SELECT SOD.SoNumber, SOD.Quantity, SOD.Pending  From SODetail SOD, #TempSO tSO Where PRoduct_code = @PROD_CODE And SOD.SoNumber = tSO.SONumber Order by SOD.SoNumber Desc      
  OPEN UPDATE_ROW          
  FETCH NEXT FROM UPDATE_ROW INTO @SONumber, @CUR_QTY, @CUR_PND          
  WHILE @@FETCH_STATUS = 0                
  BEGIN          
    IF @INV_QTY > (@CUR_QTY - @CUR_PND)          
      BEGIN      
      SET @TOT_QTY = @INV_QTY - (@CUR_QTY - @CUR_PND)          
      SET @REM_QTY = @INV_QTY - @TOT_QTY               
        UPDATE SODETAIL SET Pending = Pending + @REM_QTY WHERE SONumber =  @SONumber And  Product_code = @PROD_CODE      
        SET @INV_QTY  = @INV_QTY - @REM_QTY          
      END          
    ELSE          
      BEGIN          
        UPDATE SODETAIL SET Pending = Pending + @INV_QTY WHERE SONumber =  @SONumber And  Product_code = @PROD_CODE And Pending < Quantity  
    SET @INV_QTY = 0      
      END          
    FETCH NEXT FROM UPDATE_ROW INTO @SONumber, @CUR_QTY, @CUR_PND          
  END          
  CLOSE UPDATE_ROW          
  DEALLOCATE UPDATE_ROW          
  FETCH NEXT FROM Cur_UpdateSOQty INTO @PROD_CODE, @INV_QTY, @SO_QTY, @PENDING_QTY              
 END                
CLOSE Cur_UpdateSOQty                   
DEALLOCATE Cur_UpdateSOQty          
              
UPDATE SOABstract Set STATUS = 0 Where SONumber in(              
SELECT SOAbs.SONumber              
FROM SOAbstract SOAbs, SODetail SODet, #TempSO tSO              
WHERE tSO.SONumber = SOAbs.SONumber              
And SOAbs.SONumber = SODet.SONumber              
And (SOAbs.STATUS) <> 192                
GROUP BY SOAbs.STATUS , SOAbs.SONumber              
HAVING Sum(SOdet.Pending) > 0 )  
  
--To Update SV When Quantity = Pending  
UPDATE SV Set SV.Status = 0   
FROM SVAbstract SV, SOAbstract SO   
WHERE SV.SVNumber = SO.SalesVisitNumber  
And (SO.STATUS) <> 192  
And SO.SONumber in (Select SOD.SONumber From SODetail SOD, #TempSO TSO   
 WHERE TSO.SONumber = SOD.SoNumber Group By SOD.SONumber Having Sum(Quantity) = Sum(Pending))  
          
Drop Table #TempSO  



