--exec sp_get_bookstock '1182',1,1,2,0,'ARC003'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'sp_get_bookstock')
BEGIN
    DROP PROC [sp_get_bookstock]
END
GO
CREATE PROCEDURE [dbo].[sp_get_bookstock](@PRODUCT_CODE nvarchar(15),      
      @TRACK_BATCH int,      
      @CAPTURE_PRICE Int,      
      @CUSTOMER_TYPE int,      
      @UNUSED int = 0, 
	  @CustomerID nvarchar(15) = '')      
AS
BEGIN

	Declare @ChannelTypeCode nvarchar(15)
	Declare @RegisterStatus int

	Select @RegisterStatus = Case When isnull(IsRegistered,0) = 0 Then 1 Else 2 End From Customer WITH (NOLOCK) Where CustomerID = @CustomerID

	Select Top 1 @ChannelTypeCode = Channel_Type_Code From tbl_mERP_OLClassMapping OLMap WITH (NOLOCK)  
	Inner Join tbl_mERP_OLClass OLClass WITH (NOLOCK)  ON OLMap.OLClassID = OLClass.ID 
	Where OLMap.CustomerID = @CustomerID and isnull(OLMap.Active,0) = 1

	Select BP.*, Case When isnull(C.ChannelPTR, 0) = 0 Then BP.PTR Else C.ChannelPTR End 'ChannelPTR'
	Into #TmpBatchChannelPTR From Batch_Products BP WITH (NOLOCK)  
	Left Join BatchWiseChannelPTR C WITH (NOLOCK)  ON BP.Batch_Code = C.Batch_Code and C.ChannelTypeCode = @ChannelTypeCode and isnull(C.RegisterStatus,0) & @RegisterStatus <> 0
	Where BP.Product_Code= @PRODUCT_CODE AND BP.Quantity > 0 And ISNULL(BP.Damage, 0) = 0 

	 IF @TRACK_BATCH = 1      
	 BEGIN      
	  IF @CUSTOMER_TYPE = 1       
	  BEGIN      
	   Select Batch_Number, Expiry, SUM(Quantity), PTS, PKD,       
	   Isnull(Free, 0), IsNull(TaxSuffered, 0), isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
	   Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack, Tax.Tax_Description  
	   From Batch_Products WITH (NOLOCK)  Left Join Tax WITH (NOLOCK)  ON Batch_Products.GRNTaxID = Tax.Tax_Code
		where Product_Code= @PRODUCT_CODE AND       
	   Quantity > 0 And ISNULL(Damage, 0) = 0       
	   Group By Batch_Number, Expiry, PTS, PKD, Isnull(Free, 0)   ,isnull(ecp , 0),  
	   IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack,isnull(GRNTaxID,0),Tax.Tax_Description
	   Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code) 
	  END      
	  ELSE IF @CUSTOMER_TYPE = 2       
	  BEGIN      
	
	   Select Batch_Number, Expiry, SUM(Quantity), ChannelPTR PTR, PKD,       
	   Isnull(Free, 0), IsNull(TaxSuffered,0)  ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
	   Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack, Tax.Tax_Description  
	   From #TmpBatchChannelPTR Batch_Products WITH (NOLOCK)  
		Left Join Tax WITH (NOLOCK)  ON Batch_Products.GRNTaxID = Tax.Tax_Code
		where Product_Code= @PRODUCT_CODE AND Quantity > 0 And ISNULL(Damage, 0) = 0       
	   Group By Batch_Number, Expiry, PTR, PKD, Isnull(Free, 0)   ,isnull(ecp , 0),  ChannelPTR,
	   IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack,isnull(GRNTaxID,0),Tax.Tax_Description    
	   Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code)   
	  END      
	  ELSE IF @CUSTOMER_TYPE = 3       
	  BEGIN      
	   Select Batch_Number, Expiry, SUM(Quantity), Company_Price, PKD,       
	   Isnull(Free, 0), IsNull(TaxSuffered,0)   ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
	   Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack, Tax.Tax_Description  
	   From Batch_Products WITH (NOLOCK)  Left Join Tax WITH (NOLOCK)  ON Batch_Products.GRNTaxID = Tax.Tax_Code
		where Product_Code= @PRODUCT_CODE AND       
	   Quantity > 0 And ISNULL(Damage, 0) = 0       
	   Group By Batch_Number, Expiry, Company_Price, PKD, Isnull(Free, 0)   ,isnull(ecp , 0),  
	   IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0) ,MRPPerPack,isnull(GRNTaxID,0),Tax.Tax_Description   
	   Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code)   
	  END      
	  ELSE IF @CUSTOMER_TYPE = 4       
	  BEGIN      
	   Select Batch_Number, Expiry, SUM(Quantity), ECP, PKD,       
	   Isnull(Free, 0), IsNull(TaxSuffered,0)   ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
	   Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack, Tax.Tax_Description  
	   From Batch_Products WITH (NOLOCK)  Left Join Tax WITH (NOLOCK)  ON Batch_Products.GRNTaxID = Tax.Tax_Code
		where Product_Code= @PRODUCT_CODE AND Quantity > 0 And ISNULL(Damage, 0) = 0       
	   Group By Batch_Number, Expiry, ECP, PKD, Isnull(Free, 0),  
	   IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack,isnull(GRNTaxID,0),Tax.Tax_Description  
	   Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code)   
	  END      
	 END      
	 ELSE      
	 BEGIN      
	  IF @CUSTOMER_TYPE = 1       
	  BEGIN      
	   Select N'', '', SUM(Quantity), PTS, PKD, Isnull(Free, 0),       
	   IsNull(TaxSuffered,0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0) ,  
	   Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack, Tax.Tax_Description  
	   From Batch_Products WITH (NOLOCK)  Left Join Tax WITH (NOLOCK)  ON Batch_Products.GRNTaxID = Tax.Tax_Code      
	   where Product_Code= @PRODUCT_CODE AND Quantity > 0 And ISNULL(Damage, 0) = 0       
	   Group By PTS, PKD, Isnull(Free, 0), isnull(ecp , 0),  
	   IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack,isnull(GRNTaxID,0),Tax.Tax_Description    
	   Order By Isnull(Free, 0), PKD, MIN(Batch_Code)   
	  END      
	  ELSE IF @CUSTOMER_TYPE = 2       
	  BEGIN      
	
	   Select N'', '', SUM(Quantity),  ChannelPTR PTR, PKD, Isnull(Free, 0),       
	   IsNull(TaxSuffered,0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
	   Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack, Tax.Tax_Description    
		From #TmpBatchChannelPTR Batch_Products WITH (NOLOCK)  Left Join Tax WITH (NOLOCK)  ON Batch_Products.GRNTaxID = Tax.Tax_Code
	   where Product_Code= @PRODUCT_CODE AND Quantity > 0 And ISNULL(Damage, 0) = 0       
	   Group By PTR, PKD, Isnull(Free, 0)  ,isnull(ecp , 0),  ChannelPTR,
	   IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0) ,MRPPerPack,isnull(GRNTaxID,0),Tax.Tax_Description     
	   Order By Isnull(Free, 0), PKD, MIN(Batch_Code)   
	  END      
	  ELSE IF @CUSTOMER_TYPE = 3       
	  BEGIN      
	   Select N'', '', SUM(Quantity), Company_Price, PKD, Isnull(Free, 0),       
	   IsNull(TaxSuffered,0)   ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
	   Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack, Tax.Tax_Description       
	   From Batch_Products WITH (NOLOCK)  Left Join Tax WITH (NOLOCK)  ON Batch_Products.GRNTaxID = Tax.Tax_Code
		Where Product_Code= @PRODUCT_CODE AND Quantity > 0 And ISNULL(Damage, 0) = 0       
	   Group By Company_Price, PKD, Isnull(Free, 0) ,isnull(ecp , 0)   ,  
	   IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack,isnull(GRNTaxID,0),Tax.Tax_Description   
	   Order By Isnull(Free, 0), PKD, MIN(Batch_Code)   
	  END      
	  ELSE IF @CUSTOMER_TYPE = 4       
	  BEGIN      
	   Select N'', '', SUM(Quantity), ECP, PKD, Isnull(Free, 0),       
	   IsNull(TaxSuffered,0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),  
	   Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),MRPPerPack, Tax.Tax_Description       
	   From Batch_Products WITH (NOLOCK)  Left Join Tax WITH (NOLOCK)  ON Batch_Products.GRNTaxID = Tax.Tax_Code
		Where Product_Code= @PRODUCT_CODE AND Quantity > 0 And ISNULL(Damage, 0) = 0       
	   Group By ECP, PKD, Isnull(Free, 0),   
	   IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0) ,MRPPerPack,isnull(GRNTaxID,0),Tax.Tax_Description  
	   Order By Isnull(Free, 0), PKD, MIN(Batch_Code)   
	  END      
	 END      

	Drop Table #TmpBatchChannelPTR
END
GO
