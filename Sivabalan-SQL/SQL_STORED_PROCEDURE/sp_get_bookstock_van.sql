Create PROCEDURE sp_get_bookstock_van(@PRODUCT_CODE nvarchar(15),        
      @TRACK_BATCH int,        
      @CAPTURE_PRICE int,        
      @CUSTOMERTYPE int = 0,        
      @DOCID int = 0,
	  @CustomerID nvarchar(15) = '')        
AS        

Declare @ChannelTypeCode nvarchar(15)
Declare @RegisterStatus int

Select @RegisterStatus = Case When isnull(IsRegistered,0) = 0 Then 1 Else 2 End From Customer Where CustomerID = @CustomerID

Select Top 1 @ChannelTypeCode = Channel_Type_Code From tbl_mERP_OLClassMapping OLMap 
Inner Join tbl_mERP_OLClass OLClass ON OLMap.OLClassID = OLClass.ID 
Where OLMap.CustomerID = @CustomerID and isnull(OLMap.Active,0) = 1

Select BP.*, Case When isnull(C.ChannelPTR, 0) = 0 Then BP.PTR Else C.ChannelPTR End 'ChannelPTR'
Into #TmpBatchChannelPTR From Batch_Products BP 
Left Join BatchWiseChannelPTR C ON BP.Batch_Code = C.Batch_Code 
	and C.ChannelTypeCode = @ChannelTypeCode and isnull(C.RegisterStatus,0) & @RegisterStatus <> 0
Where BP.Product_Code= @PRODUCT_CODE --AND BP.Quantity > 0 And ISNULL(BP.Damage, 0) = 0 

--Select * from #TmpBatchChannelPTR

 IF @TRACK_BATCH = 1        
 BEGIN        
  Select VanStatementDetail.Batch_Number, Batch_Products.Expiry,         
  SUM(Pending),         
  Case @CUSTOMERTYPE         
   When 1 then        
   IsNull(VanStatementDetail.PTS, 0)        
   When 2 then        
   --IsNull(VanStatementDetail.PTR, 0)        
	IsNull(Batch_Products.ChannelPTR, 0)        
   When 3 then        
   IsNull(VanStatementDetail.SpecialPrice, 0)        
   Else        
   IsNull(VanStatementDetail.SalePrice, 0)        
  End,         
  Batch_Products.PKD, isnull(Batch_Products.Free, 0),        
  IsNull(Batch_Products.TaxSuffered, 0), IsNull(VanStatementDetail.ECP, 0), IsNull(Max(VanStatementDetail.PTS),0) ,IsNull(Max(VanStatementDetail.PTR),0),IsNull(Max(VanStatementDetail.SpecialPrice),0),  
  Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),
  Isnull(VanStatementDetail.MRPPerPack,0), Tax.Tax_Description		          
  From VanStatementDetail Left Join #TmpBatchChannelPTR Batch_Products on VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
  Left Join Tax on Batch_Products.GRNTaxID = Tax.Tax_Code         
  where VanStatementDetail.DocSerial = @DOCID and
	VanStatementDetail.Product_Code= @PRODUCT_CODE AND         
	VanStatementDetail.Pending > 0	      
  Group By VanStatementDetail.Batch_Number, Expiry,         
  VanStatementDetail.SalePrice, Batch_Products.PKD,         
  isnull(Batch_Products.Free, 0), VanStatementDetail.PTS,        
  VanStatementDetail.PTR, VanStatementDetail.SpecialPrice, VanStatementDetail.ECP,  
  IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), Isnull(VanStatementDetail.MRPPerPack,0),
  isnull(Batch_Products.GRNTaxID,0),Tax.Tax_Description, Batch_Products.ChannelPTR
  Order By Isnull(Free, 0), MIN(VanStatementDetail.Batch_Code)        
 END        
 ELSE        
 BEGIN        
  Select N'', '', SUM(VanStatementDetail.Pending),         
  Case @CUSTOMERTYPE        
   When 1 then        
   IsNull(VanStatementDetail.PTS, 0)        
   When 2 then        
   --IsNull(VanStatementDetail.PTR, 0)        
	IsNull(Batch_Products.ChannelPTR, 0)
   When 3 then        
   IsNull(VanStatementDetail.SpecialPrice, 0)        
   Else        
   IsNull(VanStatementDetail.SalePrice, 0)        
  End,         
  Batch_Products.PKD,         
  isnull(Batch_Products.Free, 0),        
  IsNull(Batch_Products.TaxSuffered, 0), IsNull(VanStatementDetail.ECP, 0), IsNull(Max(VanStatementDetail.PTS),0) ,IsNull(Max(VanStatementDetail.PTR),0),IsNull(Max(VanStatementDetail.SpecialPrice),0),  
  Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),
  Isnull(VanStatementDetail.MRPPerPack,0), Tax.Tax_Description	          
  From VanStatementDetail Left Join #TmpBatchChannelPTR Batch_Products on VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
  Left Join Tax on Batch_Products.GRNTaxID = Tax.Tax_Code        
  where VanStatementDetail.DocSerial = @DOCID and           
	VanStatementDetail.Product_Code= @PRODUCT_CODE AND         
	VanStatementDetail.Pending > 0         
  Group By VanStatementDetail.SalePrice, Batch_Products.PKD,         
  isnull(Batch_Products.Free, 0), VanStatementDetail.PTS,        
  VanStatementDetail.PTR, VanStatementDetail.SpecialPrice, VanStatementDetail.ECP,  
  IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), Isnull(VanStatementDetail.MRPPerPack,0),
  isnull(Batch_Products.GRNTaxID,0),Tax.Tax_Description, Batch_Products.ChannelPTR        
  Order By Isnull(Free, 0), MIN(VanStatementDetail.Batch_Code)        
 END

Drop Table #TmpBatchChannelPTR
        
