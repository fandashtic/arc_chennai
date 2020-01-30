Create Procedure sp_Upgrade_Database (@DestinationDB NVarchar(30), @YearEnd NVarchar(23))
As
Declare @SQLString as NVarchar(4000)
Declare @SQLString1 as NVarchar(4000)
Declare @Year as nvarchar(23)
Declare @ServiceImpact as NVarchar(1024)
set dateformat dmy
set @year = Convert(datetime,Cast(@yearend as datetime),103)
/*Start of Items Inactive and no entries in Batch_products Need to Delete */
Set @SQLString1 = 'Delete From ' + @DestinationDB + '.dbo.Items Where Product_code Not In'
Set @SQLString1 = @SQLString1 + '(Select Distinct Product_Code from '
Set @SQLString1 = @SQLString1 +  @DestinationDB + '.dbo.Batch_Products ) And Active = 0 '
Execute (@SQLString1)
/*End of Items Inactive and no entries in Batch_products Need to Delete */
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IssueDetail]')
and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin
Set @ServiceImpact = ' UNION select Distinct(IsNull(Batch_Code,0)) from ' + @DestinationDB + '.dbo.IssueDetail '
End
else
Set @ServiceImpact = ''

Set @SQLString = 'DELETE ' + @DestinationDB  + '.dbo.Batch_Products WHERE (IsNull(Quantity, 0) <= 0 And '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.Batch_Products.Batch_Code Not In (Select Distinct(IsNull(Batch_Code, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.VanStatementDetail' + ' UNION Select Distinct(IsNull(Batch_Code, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.StockTransferOutDetail' + ' UNION Select Distinct(IsNull(Batch_Code, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.StockTransferInDetail' + ' UNION Select Distinct(IsNull(BatchCode, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.AdjustmentReturnDetail' + ' UNION Select Distinct(IsNull(Batch_Code, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.InvoiceDetail' + ' UNION Select Distinct(IsNull(BatchCode, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.StockDestructionDetail' + ' UNION Select Distinct(IsNull(Batch_Code, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.DispatchDetail' + ' UNION Select Distinct(IsNull(Batch_Code, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.StockAdjustment' + ' UNION Select Distinct(IsNull(Batch_Code, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.ClaimsDetail' + ' UNION Select Distinct(IsNull(Batch_Code, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.DandDDetail DD Join '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.DandDAbstract DA On DA.ID = DD.ID And IsNull(DA.Status,0) & 192 = 0 '
Set @SQLString = @SQLString                  + ' UNION Select Distinct(IsNull(BatchCode, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.VanTransferDetail' + ' UNION Select Distinct(IsNull(OldBatchCode, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.ConversionDetail' + ' UNION Select Distinct(IsNull(NewBatchCode, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.ConversionDetail' + ' UNION Select Distinct(IsNull(BatchCode, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.PriceChangeDetails' + ' UNION Select Distinct(IsNull(BatchReference, 0)) From '
Set @SQLString = @SQLString + @DestinationDB + '.dbo.Batch_Products '
--Begin: Service Impact
Set @SQLString = @SQLString + @ServiceImpact + '))' + ' and CreationDate < ''' + @year + ''''
--End: Service Impact
Execute(@SQLString)

Set @SQLString=''
set @SQLString='Delete From '
+ @DestinationDB
+'.dbo.BatchWiseChannelPTR Where BatchWiseChannelPTR.Batch_Code Not In (Select Batch_Products.Batch_Code From '
+ @DestinationDB  +'.dbo.Batch_Products)'
Execute(@SQLString)

set @SQLString=''
set @SQLString= 'Update '+@DestinationDB +'..Tbl_Merp_ConfigAbstract set Flag = -1 Where Screencode = ''DATAPURGE'''
Execute(@SQLString)
