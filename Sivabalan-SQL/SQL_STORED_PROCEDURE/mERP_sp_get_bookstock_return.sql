Create Procedure mERP_sp_get_bookstock_return(@PRODUCT_CODE nvarchar(15),        
      @TRACK_BATCH int,        
      @CAPTURE_PRICE int,        
      @CUSTOMER_TYPE int,        
      @UNUSED int = 0,
	  @CustomerID nvarchar(15) = '')        
AS        
Begin

Declare @ChannelTypeCode nvarchar(15)
Declare @RegisterStatus int

Select @RegisterStatus = Case When isnull(IsRegistered,0) = 0 Then 1 Else 2 End From Customer Where CustomerID = @CustomerID

Select Top 1 @ChannelTypeCode = Channel_Type_Code From tbl_mERP_OLClassMapping OLMap 
Inner Join tbl_mERP_OLClass OLClass ON OLMap.OLClassID = OLClass.ID 
Where OLMap.CustomerID = @CustomerID and isnull(OLMap.Active,0) = 1

Select BP.*, Case When isnull(C.ChannelPTR, 0) = 0 Then BP.PTR Else C.ChannelPTR End 'ChannelPTR'
Into #TmpBatchChannelPTR From Batch_Products BP 
Left Join BatchWiseChannelPTR C ON BP.Batch_Code = C.Batch_Code and C.ChannelTypeCode = @ChannelTypeCode and isnull(C.RegisterStatus,0) & @RegisterStatus <> 0
	Where BP.Product_Code= @PRODUCT_CODE And ISNULL(BP.Damage, 0) = 0 

--Select * from #TmpBatchChannelPTR

 IF @TRACK_BATCH = 1        
 BEGIN        
 IF @CUSTOMER_TYPE = 1         
 BEGIN        
  Select Top 1 Batch_Number, Expiry, SUM(Quantity), PTS, PKD,         
  isnull(Free, 0), IsNull(TaxSuffered, 0) ,isnull(ecp , 0) , IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),    
  Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK, Tax.Tax_Description       
  From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code        
  where Product_Code= @PRODUCT_CODE And ISNULL(Damage, 0) = 0         
  Group By Batch_Number, Expiry, PTS, PKD, isnull(Free, 0) ,isnull(ecp , 0),    
  IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK,isnull(GRNTaxID,0),Tax.Tax_Description      
  Order By min(Batch_Code) desc
 END        
 ELSE IF @CUSTOMER_TYPE = 2         
 BEGIN   
  Select Top 1 Batch_Number, Expiry, SUM(Quantity), ChannelPTR PTR, PKD,         
  isnull(Free, 0), IsNull(TaxSuffered, 0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),    
  Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK, Tax.Tax_Description              
  From #TmpBatchChannelPTR Batch_Products 
	Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code        
  where Product_Code= @PRODUCT_CODE And ISNULL(Damage, 0) = 0         
  Group By Batch_Number, Expiry, PTR, PKD, isnull(Free, 0)  ,isnull(ecp , 0),  ChannelPTR,  
  IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0) ,MRPPerPACK,isnull(GRNTaxID,0),Tax.Tax_Description      
   Order By min(Batch_Code) desc
 END        
 ELSE IF @CUSTOMER_TYPE = 3         
 BEGIN        
  Select Top 1 Batch_Number, Expiry, SUM(Quantity), Company_Price, PKD,         
  isnull(Free, 0), IsNull(TaxSuffered, 0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),    
  Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK, Tax.Tax_Description               
  From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code        
  where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0         
  Group By Batch_Number, Expiry, Company_Price, PKD, isnull(Free, 0) ,isnull(ecp , 0),    
  IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK,isnull(GRNTaxID,0),Tax.Tax_Description   
   Order By min(Batch_Code) desc     
 END        
 ELSE IF @CUSTOMER_TYPE = 4         
 BEGIN        
  Select Top 1 Batch_Number, Expiry, SUM(Quantity), ECP, PKD,         
  isnull(Free, 0), IsNull(TaxSuffered, 0) ,isnull(ecp , 0) , IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),    
  Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK, Tax.Tax_Description              
  From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code        
  where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0         
  Group By Batch_Number, Expiry, ECP, PKD, isnull(Free, 0),     
  IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK,isnull(GRNTaxID,0),Tax.Tax_Description       
   Order By min(Batch_Code) desc
 END        
END        
ELSE        
BEGIN        
 IF @CUSTOMER_TYPE = 1         
 BEGIN        
  Select Top 1 N'', '', SUM(Quantity), PTS, PKD, isnull(Free, 0),         
  IsNull(TaxSuffered, 0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),    
  Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK, Tax.Tax_Description               
  From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code        
  where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0         
  Group By PTS, PKD, isnull(Free, 0)  ,isnull(ecp , 0),    
  IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK,isnull(GRNTaxID,0),Tax.Tax_Description       
   Order By min(Batch_Code) desc
 END        
 ELSE IF @CUSTOMER_TYPE = 2         
 BEGIN        
  Select Top 1 N'', '', SUM(Quantity), ChannelPTR PTR, PKD, isnull(Free, 0),         
  IsNull(TaxSuffered, 0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),    
  Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK, Tax.Tax_Description               
  From #TmpBatchChannelPTR Batch_Products 
	Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code    
  where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0         
  Group By PTR, PKD, isnull(Free, 0)  ,isnull(ecp , 0), ChannelPTR,   
  IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK,isnull(GRNTaxID,0),Tax.Tax_Description       
   Order By min(Batch_Code) desc
 END        
 ELSE IF @CUSTOMER_TYPE = 3         
 BEGIN        
  Select Top 1 N'', '', SUM(Quantity), Company_Price, PKD, isnull(Free, 0),         
  IsNull(TaxSuffered, 0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),    
  Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK, Tax.Tax_Description            
  From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code        
  where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0         
  Group By Company_Price, PKD, isnull(Free, 0)  ,isnull(ecp , 0),    
  IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0) ,MRPPerPACK,isnull(GRNTaxID,0),Tax.Tax_Description      
   Order By min(Batch_Code) desc
 END        
 ELSE IF @CUSTOMER_TYPE = 4         
 BEGIN        
  Select Top 1 N'', '', SUM(Quantity), ECP, PKD, isnull(Free, 0),         
  IsNull(TaxSuffered, 0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),    
  Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPACK, Tax.Tax_Description               
  From Batch_Products Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code        
  where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0         
  Group By ECP, PKD, isnull(Free, 0),     
  IsNull(TaxSuffered, 0), Isnull(ApplicableOn,0), Isnull(Partofpercentage,0) ,MRPPerPACK,isnull(GRNTaxID,0),Tax.Tax_Description      
   Order By min(Batch_Code) desc
 END       
END

Drop Table #TmpBatchChannelPTR
END
