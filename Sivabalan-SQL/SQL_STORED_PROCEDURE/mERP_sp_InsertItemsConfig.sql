Create Procedure mERP_sp_InsertItemsConfig
	(@MenuName nVarchar(255),
	 @Lock Int,
	 @Category nVarchar(255),
	 @Vendor nVarchar(255),
	 @Branch nVarchar(255),
	 @Mfr nVarchar(255),
	 @Brand nVarchar(255),
	 @SuppressBarCode nVarchar(255),
	 @ItemCode nVarchar(255),
	 @ItemName nVarchar(255),
	 @TrackBatch nVarchar(255),
	 @TrackPkd nVarchar(255),
	 @BaseUOM nVarchar(255),
	 @RUOM nVarchar(255),
	 @ReportingUnit nVarchar(255),
	 @ConvUnit nVarchar(255),
	 @ConvFactor nVarchar(255),
	 @StkNorm nVarchar(255),
	 @LotSize nVarchar(255),
	 @ForumCode nVarchar(255),
     @PTS nVarchar(255),
     @PTR nVarchar(255),	 
     @ECP nVarchar(255),
	 @TaxInclusive nVarchar(255),
	 @MRP nVarchar(255),
	 @SplPrice nVarchar(255),
	 @STax nVarchar(255),
	 @SaleID nVarchar(255),
	 @PTax nVarchar(255),
	 @SoldAd nVarchar(255),
	 @ExciseDuty nVarchar(255),
	 @AdhocAmt nVarchar(255),
	 @Vat nVarchar(255),
	 @CollTaxSuffered nVarchar(255),
	 @Description nVarchar(255),
	 @Property nVarchar(255),
	 @AvailableQty nVarchar(255),
	 @Margin nVarchar(255),
	 @UOM1 nVarchar(255),
	 @UOM2 nVarchar(255),
	 @UOM1Conv nVarchar(255),
	 @UOM2Conv nVarchar(255),
	 @DefaultSUOM nVarchar(255),	
	 @DefaultPUOM nVarchar(255),
	 @PriceAtUOMLvl	nVarchar(255),
         @Active nvarchar(255)=N'',
	 @HealthCareItem Nvarchar(255)=N'',
	 @TOQ_Purchase Nvarchar(255)=N'',
	 @TOQ_Sales Nvarchar(255)=N''
	)
As
   declare @nidentity int 
   insert into tbl_mERP_RecConfigAbstract(Menuname,flag,status) values(@MenuName,@Lock,0)             
   select @nidentity= @@IDENTITY  

   IF @Category is not null or @Category<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Category,1,charindex('|',@Category,1)-1),substring(@Category,charindex('|',@Category,1)+1,len(@Category)),0)
   end 

   IF @Vendor is not null or @Vendor<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Vendor,1,charindex('|',@Vendor,1)-1),substring(@Vendor,charindex('|',@Vendor,1)+1,len(@Vendor)),0)
   end 
   IF @Branch is not null or  @Branch<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Branch,1,charindex('|',@Branch ,1)-1),substring(@Branch ,charindex('|',@Branch,1)+1,len(@Branch )),0)
   end 
   IF @Mfr is not null or  @Mfr<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Mfr,1,charindex('|',@Mfr ,1)-1),substring(@Mfr ,charindex('|',@Mfr,1)+1,len(@Mfr)),0)
   end 
   IF @Brand is not null or  @Brand<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Brand,1,charindex('|',@Brand,1)-1),substring(@Brand,charindex('|',@Brand ,1)+1,len(@Brand)),0)
   end
   IF @SuppressBarCode is not null  or  @SuppressBarCode<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@SuppressBarCode,1,charindex('|',@SuppressBarCode,1)-1),substring(@SuppressBarCode ,charindex('|',@SuppressBarCode ,1)+1,len(@SuppressBarCode )),0)
   end 
   IF @ItemCode is not null or  @ItemCode<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ItemCode,1,charindex('|',@ItemCode,1)-1),substring(@ItemCode ,charindex('|',@ItemCode ,1)+1,len(@ItemCode )),0)
   end
   IF @ItemName is not null or  @ItemName<>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ItemName,1,charindex('|',@ItemName,1)-1),substring(@ItemName  ,charindex('|',@ItemName ,1)+1,len(@ItemName  )),0)
   end 
   IF @TrackBatch is not null or  @TrackBatch<>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TrackBatch,1,charindex('|',@TrackBatch,1)-1),substring(@TrackBatch  ,charindex('|',@TrackBatch ,1)+1,len(@TrackBatch )),0)
   end 
   IF @TrackPkd is not null or  @TrackPkd<>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TrackPkd,1,charindex('|',@TrackPkd,1)-1),substring(@TrackPkd ,charindex('|',@TrackPkd  ,1)+1,len(@TrackPkd )),0)
   end 
   IF @BaseUOM is not null  or  @BaseUOM<>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@BaseUOM,1,charindex('|',@BaseUOM,1)-1),substring(@BaseUOM ,charindex('|',@BaseUOM ,1)+1,len(@BaseUOM )),0)
   end 
   IF @RUOM is not null or  @RUOM<>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@RUOM,1,charindex('|',@RUOM ,1)-1),substring(@RUOM ,charindex('|',@RUOM ,1)+1,len(@RUOM )),0)
   end 
   IF @ReportingUnit is not null or @ReportingUnit<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ReportingUnit,1,charindex('|',@ReportingUnit,1)-1),substring(@ReportingUnit  ,charindex('|',@ReportingUnit ,1)+1,len(@ReportingUnit)),0)
   end 
   IF @ConvUnit is not null or @ConvUnit <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ConvUnit,1,charindex('|',@ConvUnit,1)-1),substring(@ConvUnit  ,charindex('|',@ConvUnit ,1)+1,len(@ConvUnit)),0)
   end
   IF @ConvFactor is not null or @ConvFactor <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ConvFactor,1,charindex('|',@ConvFactor,1)-1),substring(@ConvFactor ,charindex('|',@ConvFactor  ,1)+1,len(@ConvFactor)),0)
   end
   IF @StkNorm is not null or @StkNorm <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@StkNorm,1,charindex('|',@StkNorm ,1)-1),substring(@StkNorm ,charindex('|',@StkNorm ,1)+1,len(@StkNorm )),0)
   end 
   IF @LotSize is not null or @LotSize <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@LotSize,1,charindex('|',@LotSize ,1)-1),substring(@LotSize ,charindex('|',@LotSize ,1)+1,len(@LotSize)),0)
   end
   IF @ForumCode is not null or @ForumCode<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ForumCode,1,charindex('|',@ForumCode  ,1)-1),substring(@ForumCode  ,charindex('|',@ForumCode ,1)+1,len(@ForumCode)),0)
   end
   IF @PTS is not null or @PTS<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@PTS,1,charindex('|',@PTS ,1)-1),substring(@PTS ,charindex('|',@PTS  ,1)+1,len(@PTS )),0)
   end
   IF @PTR is not null  or @PTR<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@PTR,1,charindex('|',@PTR  ,1)-1),substring(@PTR  ,charindex('|',@PTR ,1)+1,len(@PTR )),0)   
   end 
   IF @ECP is not null or @ECP<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ECP,1,charindex('|',@ECP ,1)-1),substring(@ECP ,charindex('|',@ECP ,1)+1,len(@ECP )),0)
   end
   IF @TaxInclusive is not null or @TaxInclusive<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TaxInclusive,1,charindex('|',@TaxInclusive ,1)-1),substring(@TaxInclusive ,charindex('|',@TaxInclusive ,1)+1,len(@TaxInclusive )),0)
   end
   IF @MRP is not null  or @MRP<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@MRP,1,charindex('|',@MRP  ,1)-1),substring(@MRP  ,charindex('|',@MRP ,1)+1,len(@MRP  )),0)
   end 
   IF @SplPrice is not null  or @SplPrice<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@SplPrice,1,charindex('|',@SplPrice  ,1)-1),substring(@SplPrice  ,charindex('|',@SplPrice ,1)+1,len(@SplPrice)),0)
   end 
   IF @STax is not null  or @STax <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@STax,1,charindex('|',@STax ,1)-1),substring(@STax ,charindex('|',@STax  ,1)+1,len(@STax)),0)
   end 
   IF @SaleID is not null or @SaleID <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@SaleID,1,charindex('|',@SaleID ,1)-1),substring(@SaleID ,charindex('|',@SaleID ,1)+1,len(@SaleID)),0)
   end 
   IF @PTax is not null or @PTax <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@PTax,1,charindex('|',@PTax ,1)-1),substring(@PTax ,charindex('|',@PTax ,1)+1,len(@PTax)),0)
   end 
   IF @SoldAd is not null or @SoldAd <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@SoldAd,1,charindex('|',@SoldAd  ,1)-1),substring(@SoldAd  ,charindex('|',@SoldAd,1)+1,len(@SoldAd)),0)
   end 
   IF @ExciseDuty is not null or @ExciseDuty <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@ExciseDuty,1,charindex('|',@ExciseDuty  ,1)-1),substring(@ExciseDuty  ,charindex('|',@ExciseDuty ,1)+1,len(@ExciseDuty)),0)
   end
   IF @AdhocAmt is not null or @AdhocAmt <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@AdhocAmt,1,charindex('|',@AdhocAmt ,1)-1),substring(@AdhocAmt ,charindex('|',@AdhocAmt,1)+1,len(@AdhocAmt)),0)
   end 
   IF @Vat is not null  or @Vat <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Vat,1,charindex('|',@Vat  ,1)-1),substring(@Vat  ,charindex('|',@Vat,1)+1,len(@Vat)),0)
   end
   IF @CollTaxSuffered is not null or @CollTaxSuffered <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@CollTaxSuffered,1,charindex('|',@CollTaxSuffered  ,1)-1),substring(@CollTaxSuffered  ,charindex('|',@CollTaxSuffered,1)+1,len(@CollTaxSuffered)),0)
   end
   IF @Description is not null  or  @Description <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Description,1,charindex('|',@Description,1)-1),substring(@Description,charindex('|',@Description  ,1)+1,len(@Description)),0)
   end
   IF @Property is not null  or  @Property <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Property,1,charindex('|',@Property,1)-1),substring(@Property,charindex('|',@Property,1)+1,len(@Property)),0)
   end 
   IF @AvailableQty is not null or @AvailableQty  <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@AvailableQty,1,charindex('|',@AvailableQty  ,1)-1),substring(@AvailableQty,charindex('|',@AvailableQty,1)+1,len(@AvailableQty)),0)   
   end 
   IF @Margin is not null or @Margin  <>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Margin,1,charindex('|',@Margin   ,1)-1),substring(@Margin,charindex('|',@Margin,1)+1,len(@Margin)),0)
   end  
   if @UOM1 is not null or @UOM1  <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@UOM1,1,charindex('|',@UOM1,1)-1),substring(@UOM1,charindex('|',@UOM1,1)+1,len(@UOM1)),0)
   end
   if @UOM2 is not null  or @UOM2  <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@UOM2,1,charindex('|',@UOM2,1)-1),substring(@UOM2,charindex('|',@UOM2,1)+1,len(@UOM2)),0)
   end
   if @UOM1Conv is not null  or  @UOM1Conv  <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@UOM1Conv,1,charindex('|',@UOM1Conv,1)-1),substring(@UOM1Conv,charindex('|',@UOM1Conv,1)+1,len(@UOM1Conv)),0)
   end 
   if @UOM2Conv is not null  or  @UOM2Conv  <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@UOM2Conv,1,charindex('|',@UOM2Conv,1)-1),substring(@UOM2Conv,charindex('|',@UOM2Conv,1)+1,len(@UOM2Conv)),0)
   end 
   if @DefaultSUOM is not null or  @DefaultSUOM  <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@DefaultSUOM,1,charindex('|',@DefaultSUOM,1)-1),substring(@DefaultSUOM,charindex('|',@DefaultSUOM,1)+1,len(@DefaultSUOM)),0)
   end
   if @DefaultPUOM is not null or  @DefaultPUOM <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@DefaultPUOM,1,charindex('|',@DefaultPUOM,1)-1),substring(@DefaultPUOM,charindex('|',@DefaultPUOM,1)+1,len(@DefaultPUOM)),0)
   end  
   if @PriceAtUOMLvl is not null  or  @PriceAtUOMLvl  <>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@PriceAtUOMLvl,1,charindex('|',@PriceAtUOMLvl,1)-1),substring(@PriceAtUOMLvl,charindex('|',@PriceAtUOMLvl,1)+1,len(@PriceAtUOMLvl)),0)
   end  
   if @Active is not null or @Active<>' ' 
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Active,1,charindex('|',@Active,1)-1),substring(@Active,charindex('|',@Active,1)+1,len(@Active)),0)
   end 
   if @HealthCareItem is not null Or @HealthCareItem <> ' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@HealthCareItem,1,charindex('|',@HealthCareItem,1)-1),substring(@HealthCareItem,charindex('|',@HealthCareItem,1)+1,len(@HealthCareItem)),0)
   end 	
   if @TOQ_Purchase is not null Or @TOQ_Purchase <> ' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TOQ_Purchase,1,charindex('|',@TOQ_Purchase,1)-1),substring(@TOQ_Purchase,charindex('|',@TOQ_Purchase,1)+1,len(@TOQ_Purchase)),0)
   end 	
   if @TOQ_Sales is not null Or @TOQ_Sales <> ' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TOQ_Sales,1,charindex('|',@TOQ_Sales,1)-1),substring(@TOQ_Sales,charindex('|',@TOQ_Sales,1)+1,len(@TOQ_Sales)),0)
   end 	
