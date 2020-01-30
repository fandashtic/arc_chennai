CREATE Procedure spr_lists_Categorywise_Purchase
                                               (@CATNAME nvarchar (2550),
                                                @FROMDATE DATETIME,
                                                @TODATE DATETIME)
As      

Declare @Prefix nvarchar(255)

Select @Prefix = Prefix From VoucherPrefix Where TranID = 'BILL'

Create Table #tempCategory (CategoryID Int, Status Int)
Exec GetLeafCategories '%', @CATNAME
Select Distinct CategoryID InTo #temp1 From #tempCategory

Select ba.BillID, 
  "Bill ID" = @Prefix + Cast(ba.DocumentID As nvarchar),
  "Bill Date" = ba.BillDate, 
  "Vendor ID" = ba.VendorID, 
  "Vendor Name" = v.Vendor_Name 
From BillAbstract ba, BillDetail bd, Vendors v, Items i, #temp1
Where ba.VendorID = v.VendorID And
  ba.BillID = bd.BillID And bd.Product_Code = i.Product_Code And 
  ba.BillDate Between @FromDate And @ToDate And
  IsNull(ba.Status, 0) & 192 = 0 And i.CategoryID = #temp1.CategoryID
Group By ba.BillID, ba.DocumentID, ba.BillDate, ba.VendorID, v.Vendor_Name

      
Drop Table #tempCategory
Drop Table #temp1


