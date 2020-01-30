Create Procedure mERP_sp_Get_StkTakingDetail(@ReconcileID Int)    
As    
Begin
Declare @STK_STATUS as Int
Select @STK_STATUS = StockStatus From ReconcileAbstract Where ReconcileID = @ReconcileID

If @STK_STATUS = 3 /*Without Stock*/
  Begin
  Select ReconcileDetail.Product_Code, Items.ProductName, N'' as 'PKD', N'' as 'Expiry',
  Items.PTS, Items.PTR, Items.ECP, UOM.Description, Tax.Percentage
  From ReconcileDetail, Items, ReconcileAbstract, UOM, Tax     
  Where ReconcileDetail.ReconcileID = @ReconcileID and 
        ReconcileAbstract.ReconcileID = ReconcileDetail.ReconcileID and 
        ReconcileDetail.Product_Code = Items.Product_Code and  
        UOM.UOM = Case IsNull(ReconcileAbstract.UOM,1) When 1 Then Items.UOM2 When 2 Then Items.UOM1 Else Items.UOM End and 
        Tax.Tax_code = Items.TaxSuffered 
  End
Else
  Begin
  Declare @tmpBatchProducts table (Product_Code nVarchar(30), Batch_Code int)

  Insert into @tmpBatchProducts 
  Select Product_code, Batch_code From ReconcileDetail Where ReconcileID = @ReconcileID and CharIndex(',', Batch_code) = 0 

  Declare @Batch_Code nVarchar(Max) 
  Declare @Product_Code nVarchar(30)
  Declare Cur_Prdt_batch Cursor For
  Select Product_code, Batch_code From ReconcileDetail Where ReconcileID = @ReconcileID and CharIndex(',', Batch_code) > 0 
  Open Cur_Prdt_batch
  Fetch Next From Cur_Prdt_batch into @Product_Code, @Batch_Code
  While @@Fetch_Status = 0 
    Begin
    Insert into @tmpBatchProducts
    Select @Product_Code, * from dbo.fn_SplitIn2Rows_Int(@Batch_Code,',')
    Fetch Next From Cur_Prdt_batch into @Product_Code, @Batch_Code
    End
  Close Cur_Prdt_batch 
  Deallocate Cur_Prdt_batch

  Select tmpBP.Product_Code, Items.ProductName, Convert(varchar(10),BP.PKD,103), Convert(varchar(10),BP.Expiry,103), 
         BP.PTR, BP.PTS, BP.ECP, IsNull(BP.TaxSuffered,0), UOM.Description   
  From ReconcileAbstract RA, Items, Batch_Products BP, @tmpBatchProducts tmpBP, UOM
  Where RA.ReconcileID = @ReconcileID and 
      BP.Product_Code = Items.Product_Code and 
      tmpBP.Batch_Code = BP.Batch_Code and  
      UOM.UOM = Case IsNull(RA.UOM,1) When 1 Then Items.UOM2 When 2 Then Items.UOM1 Else Items.UOM End 
  Group by tmpBP.Product_Code, Items.ProductName, Convert(varchar(10),BP.PKD,103), Convert(varchar(10),BP.Expiry,103), BP.PTR, BP.PTS, BP.ECP, IsNull(BP.TaxSuffered,0), UOM.Description 
  Order by tmpBP.Product_Code, Convert(varchar(10),BP.PKD,103), Convert(varchar(10),BP.Expiry,103)
  End 
End
