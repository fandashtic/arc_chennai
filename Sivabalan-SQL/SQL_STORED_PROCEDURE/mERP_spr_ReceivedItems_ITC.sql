CREATE Procedure mERP_spr_ReceivedItems_ITC(@FromDate DateTime, @ToDate DateTime)
As
Select RIA.[ID],"Vendor Code" = RIA.PartyCode,"Vendor Name" = RIA.PartyName,
"Product Code" = RID.Product_Code, "Product Name" = RID.Productname, 
"PTS" = RID.PTS,"PTR" = RID.PTR,"ECP" = RID.ECP,"MRPPerPack" = RID.MRPPerPack,
"Manufacturer" = RID.ManufacturerName, "Brand" = RID.Brandname, 
"UOM" = RID.UOM, "UOM1" = RID.UOM1,"UOM2" = RID.UOM2,
"UOM1 Conversion" = RID.UOM1_Conversion, "UOM2 Conversion" = RID.UOM2_conversion,
"Sales Tax LST" = RID.STLST, "Sales Tax CST" = RID.STCST,
"Tax Suffered LST" = RID.PTLST, "Tax Suffered CST" = RID.PTCST,
"Received Date" = RIA.CreationDate,
"Status" = Case when IsNull(RIA.Flag,0) & 32 = 0 Then 'Open' Else 'Processed' End
From ItemsReceivedAbstract RIA, ItemsReceivedDetail RID
Where RIA.CreationDate Between @FromDate And @ToDate
And RIA.ID = RID.PartyID
Order By RIA.CreationDate
