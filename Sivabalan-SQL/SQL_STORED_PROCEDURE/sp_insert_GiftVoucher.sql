CREATE procedure sp_insert_GiftVoucher(@VoucherName nvarchar(125)=NULL,@VendorID nvarchar(50)=NULL,
		@Prefix nvarchar(50)=NULL,@Suffix nvarchar(50)=NULL,
		@StartNumber nvarchar(50),@EndNumber nvarchar(50),
		@Denomination Decimal(18,6),@ValidityType Integer,@Period nvarchar(1),
		@ValidityDate DateTime=NULL, @ValidityMonths Integer,
		@CreationDate DateTime,@Active Integer)
As
		Insert Into GiftVoucher(VoucherName,VendorID,
								Prefix,Suffix,
								StartNumber,EndNumber,
								Denomination,ValidityType,Period,
								ValidityDate,ValidityMonths,
								CreationDate,Active)
						 Values(@VoucherName,@VendorID,
								@Prefix,@Suffix,
								@StartNumber,@EndNumber,
								@Denomination,@ValidityType,@Period,
								@ValidityDate,@ValidityMonths,
								@CreationDate,@Active)
Select @@IDENTITY


