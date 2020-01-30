IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'StockMovementMonthly')
BEGIN
	DROP TABLE [StockMovementMonthly]
END
GO
CREATE TABLE [dbo].[StockMovementMonthly](
	[Year] [nvarchar](5) NULL,
	[MonthName] [nvarchar](50) NULL,
	[TransactionDate] [datetime] NULL,
	[Product_Code] [nvarchar](255) NULL,
	[ProductName] [nvarchar](255) NULL,
	[CategoryGroup] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[ItemFamily] [nvarchar](255) NULL,
	[ItemSubFamily] [nvarchar](255) NULL,
	[ItemGroup] [nvarchar](255) NULL,
	[Batch_Number] [nvarchar](255) NULL,
	[Expairy] [datetime] NULL,
	[UOMQty] [decimal](18, 6) NULL,
	[IsDamage] [int] NULL,
	[DamagesReason] [nvarchar](255) NULL,
	[ReceivedAgeing] [int] NULL,
	[Opening] [decimal](18, 6) NULL,
	[Opening_Rate] [decimal](18, 6) NULL,
	[Opening_Value] [decimal](18, 6) NULL,
	[Purchase] [decimal](38, 6) NULL,
	[Purchase_Value] [decimal](38, 6) NULL,
	[Purchase_Discount] [decimal](38, 6) NULL,
	[Purchase_InvDiscAmount] [decimal](38, 6) NULL,
	[Purchase_OtherDiscAmount] [decimal](38, 6) NULL,
	[TransferIn_Value] [decimal](38, 6) NULL,
	[SaleReturn] [decimal](38, 6) NULL,
	[SaleReturn_Value] [decimal](38, 6) NULL,
	[Sales] [decimal](38, 6) NULL,
	[Sales_Value] [decimal](38, 6) NULL,
	[PruchaseReturn] [decimal](38, 6) NULL,
	[PruchaseReturn_Value] [decimal](38, 6) NULL,
	[TransferOut] [decimal](38, 6) NULL,
	[TransferOut_Value] [decimal](38, 6) NULL,
	[Damage_Destroy] [decimal](38, 6) NULL,
	[Damage_Destroy_Value] [decimal](38, 6) NULL,
	[Closing] [decimal](18, 6) NULL,
	[Closing_Rate] [decimal](18, 6) NULL,
	[Closing_Value] [decimal](18, 6) NULL
) ON [PRIMARY]
GO


