
create procedure sp_consolidate_vanstatement_detail (	@DocSerial int,
							@Product_Code nvarchar(20),
							@Batch_Code int,
							@Batch_Number nvarchar(255),
							@Quantity Decimal(18,6),
							@Pending Decimal(18,6),
							@SalePrice Decimal(18,6),
							@Amount Decimal(18,6),
							@PurchasePrice Decimal(18,6),
							@BFQty Decimal(18,6))
as
Insert into VanStatementDetail (DocSerial,
				Product_Code,
				Batch_Code,
				Batch_Number,
				Quantity,
				Pending,
				SalePrice,
				Amount,
				PurchasePrice,
				BFQty)
Values(				@DocSerial,
				@Product_Code,
				@Batch_Code,
				@Batch_Number,
				@Quantity,
				@Pending,
				@SalePrice,
				@Amount,
				@PurchasePrice,
				@BFQty)

