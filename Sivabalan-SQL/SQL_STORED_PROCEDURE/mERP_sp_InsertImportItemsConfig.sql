Create Procedure mERP_sp_InsertImportItemsConfig
	(@MenuName nVarchar(255),
	 @Lock Int,
     @ItemCode nVarchar(255),
	 @ItemName nVarchar(255),
     @Description nVarchar(255),   
	 @Category nVarchar(255),
     @Mfr nVarchar(255),
     @Brand nVarchar(255),
     @BaseUOM nVarchar(255),
     @STax nVarchar(255),
     @MRP nVarchar(255),    
	 @Vendor nVarchar(255),
     @StkNorm nVarchar(255),
     @LotSize nVarchar(255),
     @TrackBatch nVarchar(255),
     @ConvFactor nVarchar(255),
     @ConvUnit nVarchar(255),
     @SaleID nVarchar(255),
     @SplPrice nVarchar(255),	       
	 @PTS nVarchar(255),
     @PTR nVarchar(255),
     @ECP nVarchar(255),
     @Purchaseat nvarchar(255),
	 @UOM1 nVarchar(255),
     @UOM1Conv nVarchar(255),
     @UOM2 nVarchar(255), 
     @UOM2Conv nVarchar(255),
     @DefaultPUOM nVarchar(255),
     @DefaultSUOM nVarchar(255),	
     @PriceAtUOMLvl	nVarchar(255),
     @PTax nVarchar(255),
     @SoldAd nVarchar(255),
     @ForumCode nVarchar(255),     	      
     @RUOM nVarchar(255),
     @ReportingUnit nVarchar(255),	 	 	 	 	 
     @TrackPkd nVarchar(255),	 
     @CstSaleTax nVarchar(255),	        
     @CstTaxSuffered nVarchar(255),	        
     @TaxInclusive nVarchar(255),	 	 	 	 	 
     @AdhocAmt nVarchar(255),
     @TaxInclusiveRate nVarchar(255),	 	 	 	 	 
     @Vat nVarchar(255),         
     @CollTaxSuffered nVarchar(255),	 
     @STLSTAppOn nVarchar(255),	 
     @STLSTPartOff nVarchar(255),	 
     @STCSTAppOn nVarchar(255),	 
     @STCSTPartOff nVarchar(255),	 
     @TFLSTAppOn nVarchar(255),	 
     @TFLSTPartOff nVarchar(255),	 
     @TFCSTAppOn nVarchar(255),	 
     @TFCSTPartOff nVarchar(255),	
     @HealthCareItem Nvarchar(255)=N''      
	)
As
   declare @nidentity int 
   insert into tbl_mERP_RecConfigAbstract(Menuname,flag,status) values(@MenuName,@Lock,0)             
   select @nidentity= @@IDENTITY    
  
   IF @ItemCode is not null or @ItemCode<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ItemCode,1,charindex('|',@ItemCode,1)-1),substring(@ItemCode ,charindex('|',@ItemCode,1)+1,len(@ItemCode)),0)
   end   
   IF @ItemName is not null or @ItemName<>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ItemName,1,charindex('|',@ItemName,1)-1),substring(@ItemName  ,charindex('|',@ItemName,1)+1,len(@ItemName)),0)
   end       
   IF @Description is not null or @Description<>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Description,1,charindex('|',@Description,1)-1),substring(@Description,charindex('|',@Description,1)+1,len(@Description)),0)
   end 
   IF @Category is not null or @Category<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Category,1,charindex('|',@Category,1)-1),substring(@Category,charindex('|',@Category,1)+1,len(@Category)),0)
   end
   IF @Mfr is not null or @Mfr<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Mfr,1,charindex('|',@Mfr ,1)-1),substring(@Mfr ,charindex('|',@Mfr,1)+1,len(@Mfr)),0)
   end 
   IF @Brand is not null or @Brand<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Brand,1,charindex('|',@Brand,1)-1),substring(@Brand,charindex('|',@Brand ,1)+1,len(@Brand)),0)
   end 
   IF @BaseUOM is not null or @BaseUOM<>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@BaseUOM,1,charindex('|',@BaseUOM,1)-1),substring(@BaseUOM ,charindex('|',@BaseUOM ,1)+1,len(@BaseUOM )),0)
   end
   IF @STax is not null  or @STax<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@STax,1,charindex('|',@STax ,1)-1),substring(@STax ,charindex('|',@STax  ,1)+1,len(@STax)),0)
   end 
   IF @MRP is not null or @MRP<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@MRP,1,charindex('|',@MRP  ,1)-1),substring(@MRP  ,charindex('|',@MRP ,1)+1,len(@MRP)),0)
   end       
   IF @Vendor is not null or @Vendor<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Vendor,1,charindex('|',@Vendor,1)-1),substring(@Vendor,charindex('|',@Vendor,1)+1,len(@Vendor)),0)
   end 
   IF @StkNorm is not null or @StkNorm<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@StkNorm,1,charindex('|',@StkNorm ,1)-1),substring(@StkNorm ,charindex('|',@StkNorm,1)+1,len(@StkNorm)),0)
   end 
   IF @LotSize is not null or @LotSize<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@LotSize,1,charindex('|',@LotSize ,1)-1),substring(@LotSize ,charindex('|',@LotSize,1)+1,len(@LotSize)),0)
   end
   IF @TrackBatch is not null or @TrackBatch<>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TrackBatch,1,charindex('|',@TrackBatch,1)-1),substring(@TrackBatch  ,charindex('|',@TrackBatch,1)+1,len(@TrackBatch)),0)
   end 
   IF @ConvFactor is not null or @ConvFactor<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ConvFactor,1,charindex('|',@ConvFactor,1)-1),substring(@ConvFactor ,charindex('|',@ConvFactor,1)+1,len(@ConvFactor)),0)
   end
   IF @ConvUnit is not null or @ConvUnit<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ConvUnit,1,charindex('|',@ConvUnit,1)-1),substring(@ConvUnit,charindex('|',@ConvUnit,1)+1,len(@ConvUnit)),0)
   end
   IF @SaleID is not null or @SaleID<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@SaleID,1,charindex('|',@SaleID ,1)-1),substring(@SaleID ,charindex('|',@SaleID ,1)+1,len(@SaleID)),0)
   end 
   IF @SplPrice is not null or @SplPrice<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@SplPrice,1,charindex('|',@SplPrice  ,1)-1),substring(@SplPrice  ,charindex('|',@SplPrice ,1)+1,len(@SplPrice)),0)
   end    
   IF @PTS is not null or @PTS<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@PTS,1,charindex('|',@PTS ,1)-1),substring(@PTS ,charindex('|',@PTS,1)+1,len(@PTS )),0)
   end
   IF @PTR is not null or @PTR<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@PTR,1,charindex('|',@PTR  ,1)-1),substring(@PTR  ,charindex('|',@PTR ,1)+1,len(@PTR )),0)   
   end 
   IF @ECP is not null or @ECP<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ECP,1,charindex('|',@ECP ,1)-1),substring(@ECP ,charindex('|',@ECP ,1)+1,len(@ECP)),0)
   end
   IF @Purchaseat is not null or @Purchaseat <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Purchaseat,1,charindex('|',@Purchaseat,1)-1),substring(@Purchaseat ,charindex('|',@Purchaseat,1)+1,len(@Purchaseat)),0)
   end
   if @UOM1 is not null or @UOM1<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@UOM1,1,charindex('|',@UOM1,1)-1),substring(@UOM1,charindex('|',@UOM1,1)+1,len(@UOM1)),0)
   end
   if @UOM1Conv is not null or @UOM1Conv <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@UOM1Conv,1,charindex('|',@UOM1Conv,1)-1),substring(@UOM1Conv,charindex('|',@UOM1Conv,1)+1,len(@UOM1Conv)),0)
   end
   if @UOM2 is not null or @UOM2 <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@UOM2,1,charindex('|',@UOM2,1)-1),substring(@UOM2,charindex('|',@UOM2,1)+1,len(@UOM2)),0)
   end   
   if @UOM2Conv is not null or @UOM2Conv <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@UOM2Conv,1,charindex('|',@UOM2Conv,1)-1),substring(@UOM2Conv,charindex('|',@UOM2Conv,1)+1,len(@UOM2Conv)),0)
   end
   if @DefaultPUOM is not null or @DefaultPUOM <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@DefaultPUOM,1,charindex('|',@DefaultPUOM,1)-1),substring(@DefaultPUOM,charindex('|',@DefaultPUOM,1)+1,len(@DefaultPUOM)),0)
   end  
   if @DefaultSUOM is not null or  @DefaultSUOM <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@DefaultSUOM,1,charindex('|',@DefaultSUOM,1)-1),substring(@DefaultSUOM,charindex('|',@DefaultSUOM,1)+1,len(@DefaultSUOM)),0)
   end
   if @PriceAtUOMLvl is not null or  @PriceAtUOMLvl <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@PriceAtUOMLvl,1,charindex('|',@PriceAtUOMLvl,1)-1),substring(@PriceAtUOMLvl,charindex('|',@PriceAtUOMLvl,1)+1,len(@PriceAtUOMLvl)),0)
   end
   IF @PTax is not null or  @PTax <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@PTax,1,charindex('|',@PTax ,1)-1),substring(@PTax ,charindex('|',@PTax ,1)+1,len(@PTax)),0)
   end 
   IF @SoldAd is not null or  @SoldAd <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@SoldAd,1,charindex('|',@SoldAd  ,1)-1),substring(@SoldAd,charindex('|',@SoldAd,1)+1,len(@SoldAd)),0)
   end
   IF @ForumCode is not null or  @ForumCode <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ForumCode,1,charindex('|',@ForumCode  ,1)-1),substring(@ForumCode  ,charindex('|',@ForumCode ,1)+1,len(@ForumCode)),0)
   end
   IF @RUOM is not null or  @RUOM <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@RUOM,1,charindex('|',@RUOM ,1)-1),substring(@RUOM ,charindex('|',@RUOM ,1)+1,len(@RUOM )),0)
   end 
   IF @ReportingUnit is not null or  @ReportingUnit <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ReportingUnit,1,charindex('|',@ReportingUnit,1)-1),substring(@ReportingUnit  ,charindex('|',@ReportingUnit,1)+1,len(@ReportingUnit)),0)
   end              
   IF @TrackPkd is not null or  @TrackPkd <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TrackPkd,1,charindex('|',@TrackPkd,1)-1),substring(@TrackPkd ,charindex('|',@TrackPkd  ,1)+1,len(@TrackPkd )),0)
   end           
   IF @CstSaleTax  is not null or @CstSaleTax <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@CstSaleTax,1,charindex('|',@CstSaleTax,1)-1),substring(@CstSaleTax ,charindex('|',@CstSaleTax,1)+1,len(@CstSaleTax)),0)
   end        
   IF @CstTaxSuffered  is not null or @CstTaxSuffered <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@CstTaxSuffered,1,charindex('|',@CstTaxSuffered,1)-1),substring(@CstTaxSuffered ,charindex('|',@CstTaxSuffered  ,1)+1,len(@CstTaxSuffered)),0)
   end        
   IF @TaxInclusive is not null or @TaxInclusive <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TaxInclusive,1,charindex('|',@TaxInclusive ,1)-1),substring(@TaxInclusive ,charindex('|',@TaxInclusive ,1)+1,len(@TaxInclusive )),0)
   end
   IF @AdhocAmt is not null or @AdhocAmt <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@AdhocAmt,1,charindex('|',@AdhocAmt ,1)-1),substring(@AdhocAmt ,charindex('|',@AdhocAmt,1)+1,len(@AdhocAmt)),0)
   end 
   IF @TaxInclusiveRate is not null or @TaxInclusiveRate <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TaxInclusiveRate,1,charindex('|',@TaxInclusiveRate ,1)-1),substring(@TaxInclusiveRate ,charindex('|',@TaxInclusiveRate ,1)+1,len(@TaxInclusiveRate )),0)
   end
   IF @Vat is not null or @Vat <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Vat,1,charindex('|',@Vat  ,1)-1),substring(@Vat  ,charindex('|',@Vat,1)+1,len(@Vat)),0)
   end
   IF @CollTaxSuffered is not null  or @CollTaxSuffered<>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@CollTaxSuffered,1,charindex('|',@CollTaxSuffered  ,1)-1),substring(@CollTaxSuffered  ,charindex('|',@CollTaxSuffered,1)+1,len(@CollTaxSuffered)),0)
   end   
   IF @STLSTAppOn is not null or @STLSTAppOn <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@STLSTAppOn,1,charindex('|',@STLSTAppOn  ,1)-1),substring(@STLSTAppOn  ,charindex('|',@STLSTAppOn,1)+1,len(@STLSTAppOn)),0)
   end   
   IF @STLSTPartOff is not null or @STLSTPartOff <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@STLSTPartOff,1,charindex('|',@STLSTPartOff  ,1)-1),substring(@STLSTPartOff  ,charindex('|',@STLSTPartOff,1)+1,len(@STLSTPartOff)),0)
   end   
   IF @STCSTAppOn is not null or @STCSTAppOn <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@STCSTAppOn,1,charindex('|',@STCSTAppOn  ,1)-1),substring(@STCSTAppOn  ,charindex('|',@STCSTAppOn,1)+1,len(@STCSTAppOn)),0)
   end 
   IF @STCSTPartOff is not null or @STCSTPartOff <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@STCSTPartOff,1,charindex('|',@STCSTPartOff  ,1)-1),substring(@STCSTPartOff  ,charindex('|',@STCSTPartOff,1)+1,len(@STCSTPartOff)),0)
   end
   IF @TFLSTAppOn is not null  or @TFLSTAppOn <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TFLSTAppOn,1,charindex('|',@TFLSTAppOn  ,1)-1),substring(@TFLSTAppOn  ,charindex('|',@TFLSTAppOn,1)+1,len(@TFLSTAppOn)),0)
   end
   IF @TFLSTPartOff is not null  or @TFLSTPartOff <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TFLSTPartOff,1,charindex('|',@TFLSTPartOff  ,1)-1),substring(@TFLSTPartOff  ,charindex('|',@TFLSTPartOff,1)+1,len(@TFLSTPartOff)),0)
   end
   IF @TFCSTAppOn is not null or @TFCSTAppOn <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TFCSTAppOn,1,charindex('|',@TFCSTAppOn  ,1)-1),substring(@TFCSTAppOn,charindex('|',@TFCSTAppOn,1)+1,len(@TFCSTAppOn)),0)
   end
   IF @TFCSTPartOff is not null or @TFCSTPartOff <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TFCSTPartOff,1,charindex('|',@TFCSTPartOff  ,1)-1),substring(@TFCSTPartOff,charindex('|',@TFCSTPartOff,1)+1,len(@TFCSTPartOff)),0)
   end               
   IF @HealthCareItem is not null or @HealthCareItem <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@HealthCareItem,1,charindex('|',@HealthCareItem  ,1)-1),substring(@HealthCareItem,charindex('|',@HealthCareItem,1)+1,len(@HealthCareItem)),0)
   end               	
