Create VIEW  [dbo].[V_Quotation_Details]
([Quotation_ID],[Product_Code],[PTR_exclusive_of_Tax_On_Base_UOM],[PTR_inclusive_Tax_On_Base_UOM],
[PTR_exclusive_of_Tax_On_UOM1],[PTR_inclusive_Tax_On_UOM1],[PTR_exclusive_of_Tax_On_UOM2],
[PTR_inclusive_Tax_On_UOM2],[Discount],[Special_Tax],[Item_Scheme_Allowed])
AS
SELECT  QuotationAbstract.QuotationId, Quotationitems.Product_Code,
cast(Round(((RateQuoted * 100)/(100+isnull(Tax.Percentage, 0))) ,2) as decimal(18,2)) AS PTR_exclusive_of_Tax_On_Base_UOM ,
cast(Round(RateQuoted,2) as decimal(18,2)) AS PTR_inclusive_Tax_On_Base_UOM,
cast(Round((((RateQuoted * 100)/(100+isnull(Tax.Percentage, 0))) * isnull(UOM1_Conversion, 0)),2) as decimal(18,2)) as PTR_exclusive_of_Tax_On_UOM1,
cast(Round(((RateQuoted * isnull(UOM1_Conversion,0))),2) as decimal(18,2))  as PTR_Inclusive_of_Tax_On_UOM1,
cast(Round((((RateQuoted * 100)/(100+isnull(Tax.Percentage, 0))) * isnull(UOM2_Conversion, 0)),2) as decimal(18,2)) as PTR_exclusive_of_Tax_On_UOM2,
cast(Round(((RateQuoted * isnull(UOM2_Conversion,0))) ,2) as decimal(18,2))  as PTR_Inclusive_of_Tax_On_UOM2,
Quotationitems.Discount, Quotationitems.QuotedTax, Quotationitems.AllowScheme
FROM    Quotationitems
Inner Join Items on Quotationitems.Product_Code=Items.Product_Code
Inner Join QuotationAbstract On Quotationitems.QuotationId = QuotationAbstract.QuotationId
and QuotationAbstract.Active = 1
Left Outer Join Tax on QuotedTax = Tax.Tax_code
Inner Join QuotationCustomers On QuotationCustomers.QuotationID = QuotationAbstract.QuotationID
join tbl_merp_OLClassMapping OLM on OLM.CustomerID =QuotationCustomers.CustomerID
join tbl_merp_OLClass OL on  OL.ID = OLM.OLClassID
join  tbl_mERP_QuotChannelDetail CD on CD.Channel_Type_Code =OL.Channel_Type_Code
where QuotationAbstract.quotationlevel =1 and QuotationAbstract.validtodate > = getdate()
and QuotationAbstract.Active = 1
And OLM.Active =1
And CD.Active = 1
And QuotationAbstract.QuotationType <> 4
union
--Category Level Quotation for Hirarchy Company
select  qmc.QuotationId as QuotationId, itm.product_code,
cast(Round((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End),2)
AS decimal(18,2))as PTR_exclusive_Tax_On_Base_UOM,
cast(Round(((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) +((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End)* isnull(Tax.Percentage,0)/100)),2)AS decimal(18,2))as PTR_inclusive_Tax_On_Base_UOM,

cast(Round(((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) *  isnull(ITM.UOM1_Conversion,0)),2) AS decimal(18,2))  as  PTR_exclusive_of_Tax_On_UOM1,

cast(Round((((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) +((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End)* isnull(Tax.Percentage,0)/100))*  isnull(ITM.UOM1_Conversion,0)),2)  as decimal(18,2)) as  PTR_Inclusive_of_Tax_On_UOM1 ,

cast(Round(((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) *  isnull(ITM.UOM2_Conversion,0)),2) AS decimal(18,2)) as  PTR_exclusive_of_Tax_On_UOM2,

cast(Round((((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) +((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End)* isnull(Tax.Percentage,0)/100))*  isnull(ITM.UOM2_Conversion,0)),2)  as decimal(18,2))  PTR_Inclusive_of_Tax_On_UOM2,
Discount, Tax.Percentage as QuotedTax, AllowScheme
from Items itm join Itemcategories Ic5 on itm.categoryid = IC5.categoryid
join Itemcategories Ic4 on Ic5.parentid = IC4.categoryid
join Itemcategories Ic3 on Ic4.parentid = IC3.categoryid
join Itemcategories Ic2 on Ic3.parentid = IC2.categoryid
join quotationmfrcategory qmc on qmc.MfrCategoryID = Ic2.CategoryID
join QuotationAbstract qa on qa.QuotationId = qmc.QuotationId and qa.QuotationType <> 4
Left Outer Join Tax on itm.sale_Tax = Tax.Tax_code
-- where qa.quotationlevel = 2 and qa.active = 1 and itm.active = 1 and qa.validtodate > = Getdate()
Inner Join QuotationCustomers On QuotationCustomers.QuotationID = QA.QuotationID
join tbl_merp_OLClassMapping OLM on OLM.CustomerID =QuotationCustomers.CustomerID
join tbl_merp_OLClass OL on  OL.ID = OLM.OLClassID
join  tbl_mERP_QuotChannelDetail CD on CD.Channel_Type_Code =OL.Channel_Type_Code
where qa.quotationlevel =2 and qa.Active = 1
And OLM.Active =1
And CD.Active = 1
and itm.active = 1 and qa.validtodate > = Getdate()
--Category Level Quotation for Hirarchy Division
union
select  qmc.QuotationId as QuotationId, itm.product_code,
cast(Round((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End),2)
AS decimal(18,2))as PTR_exclusive_Tax_On_Base_UOM,
cast(Round(((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) +((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End)* isnull(Tax.Percentage,0)/100)),2)AS decimal(18,2))as PTR_inclusive_Tax_On_Base_UOM,

cast(Round(((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) *  isnull(ITM.UOM1_Conversion,0)),2) AS decimal(18,2))  as  PTR_exclusive_of_Tax_On_UOM1,

cast(Round((((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) +((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End)* isnull(Tax.Percentage,0)/100))*  isnull(ITM.UOM1_Conversion,0)),2)  as decimal(18,2)) as  PTR_Inclusive_of_Tax_On_UOM1 ,

cast(Round(((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) *  isnull(ITM.UOM2_Conversion,0)),2) AS decimal(18,2)) as  PTR_exclusive_of_Tax_On_UOM2,

cast(Round((((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) +((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End)* isnull(Tax.Percentage,0)/100))*  isnull(ITM.UOM2_Conversion,0)),2)  as decimal(18,2))  PTR_Inclusive_of_Tax_On_UOM2,
Discount, Tax.Percentage as QuotedTax, AllowScheme
from Items itm join Itemcategories Ic4 on itm.categoryid = IC4.categoryid
join Itemcategories Ic3 on Ic4.parentid = IC3.categoryid
join Itemcategories Ic2 on Ic3.parentid = IC2.categoryid
join quotationmfrcategory qmc on qmc.MfrCategoryID = Ic2.CategoryID
join QuotationAbstract qa on qa.QuotationId = qmc.QuotationId and qa.QuotationType <> 4
Left Outer Join Tax on itm.sale_Tax = Tax.Tax_code
-- where qa.quotationlevel = 2 and qa.active = 1 and itm.active = 1 and qa.validtodate > = Getdate()
Inner Join QuotationCustomers On QuotationCustomers.QuotationID = QA.QuotationID
join tbl_merp_OLClassMapping OLM on OLM.CustomerID =QuotationCustomers.CustomerID
join tbl_merp_OLClass OL on  OL.ID = OLM.OLClassID
join  tbl_mERP_QuotChannelDetail CD on CD.Channel_Type_Code =OL.Channel_Type_Code
where qa.quotationlevel =2
and Itm.Active = 1
and qa.Active = 1
And OLM.Active =1
And CD.Active = 1
and itm.active = 1 and qa.validtodate > = Getdate()
union
----Category Level Quotation for Hirarchy Subcategory
select  qmc.QuotationId as QuotationId, itm.product_code,
cast(Round((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End),2)
AS decimal(18,2))as PTR_exclusive_Tax_On_Base_UOM,
cast(Round(((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) +((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End)* isnull(Tax.Percentage,0)/100)),2)AS decimal(18,2))as PTR_inclusive_Tax_On_Base_UOM,

cast(Round(((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) *  isnull(ITM.UOM1_Conversion,0)),2) AS decimal(18,2))  as  PTR_exclusive_of_Tax_On_UOM1,

cast(Round((((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) +((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End)* isnull(Tax.Percentage,0)/100))*  isnull(ITM.UOM1_Conversion,0)),2)  as decimal(18,2)) as  PTR_Inclusive_of_Tax_On_UOM1 ,

cast(Round(((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) *  isnull(ITM.UOM2_Conversion,0)),2) AS decimal(18,2)) as  PTR_exclusive_of_Tax_On_UOM2,

cast(Round((((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) +((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End)* isnull(Tax.Percentage,0)/100))*  isnull(ITM.UOM2_Conversion,0)),2)  as decimal(18,2))  PTR_Inclusive_of_Tax_On_UOM2,
Discount, Tax.Percentage as QuotedTax, AllowScheme
from Items itm join Itemcategories Ic4 on itm.categoryid = IC4.categoryid
join Itemcategories Ic3 on Ic4.parentid = IC3.categoryid
join quotationmfrcategory qmc on qmc.MfrCategoryID = Ic3.CategoryID
join QuotationAbstract qa on qa.QuotationId = qmc.QuotationId and qa.QuotationType <> 4
Left Outer Join Tax on itm.sale_Tax = Tax.Tax_code
-- where qa.quotationlevel = 2 and qa.active = 1 and itm.active = 1 and qa.validtodate > = Getdate()
Inner Join QuotationCustomers On QuotationCustomers.QuotationID = QA.QuotationID
join tbl_merp_OLClassMapping OLM on OLM.CustomerID =QuotationCustomers.CustomerID
join tbl_merp_OLClass OL on  OL.ID = OLM.OLClassID
join  tbl_mERP_QuotChannelDetail CD on CD.Channel_Type_Code =OL.Channel_Type_Code
where qa.quotationlevel =2 and qa.Active = 1
And OLM.Active =1
And CD.Active = 1
and itm.active = 1 and qa.validtodate > = Getdate()
union
----Category Level Quotation for Hirarchy Market SKU
select  qmc.QuotationId as QuotationId, itm.product_code,
cast(Round((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End),2)
AS decimal(18,2))as PTR_exclusive_Tax_On_Base_UOM,
cast(Round(((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) +((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End)* isnull(Tax.Percentage,0)/100)),2)AS decimal(18,2))as PTR_inclusive_Tax_On_Base_UOM,

cast(Round(((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) *  isnull(ITM.UOM1_Conversion,0)),2) AS decimal(18,2))  as  PTR_exclusive_of_Tax_On_UOM1,

cast(Round((((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) +((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End)* isnull(Tax.Percentage,0)/100))*  isnull(ITM.UOM1_Conversion,0)),2)  as decimal(18,2)) as  PTR_Inclusive_of_Tax_On_UOM1 ,

cast(Round(((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) *  isnull(ITM.UOM2_Conversion,0)),2) AS decimal(18,2)) as  PTR_exclusive_of_Tax_On_UOM2,

cast(Round((((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End) +((Case Marginon when 2 then ITM.PTS * (1+qmc.marginpercentage/100) Else ITM.ECP * (1-qmc.marginpercentage/100)End)* isnull(Tax.Percentage,0)/100))*  isnull(ITM.UOM2_Conversion,0)),2)  as decimal(18,2))  PTR_Inclusive_of_Tax_On_UOM2,
Discount, Tax.Percentage as QuotedTax, AllowScheme
from Items itm join Itemcategories Ic4 on itm.categoryid = IC4.categoryid
join quotationmfrcategory qmc on qmc.MfrCategoryID = Ic4.CategoryID
join QuotationAbstract qa on qa.QuotationId = qmc.QuotationId and qa.QuotationType <> 4
Left Outer Join Tax on Tax = Tax.Tax_code
-- where qa.quotationlevel = 2 and qa.active = 1 and itm.active = 1 and qa.validtodate > = Getdate()
Inner Join QuotationCustomers On QuotationCustomers.QuotationID = QA.QuotationID
join tbl_merp_OLClassMapping OLM on OLM.CustomerID =QuotationCustomers.CustomerID
join tbl_merp_OLClass OL on  OL.ID = OLM.OLClassID
join  tbl_mERP_QuotChannelDetail CD on CD.Channel_Type_Code =OL.Channel_Type_Code
where qa.quotationlevel =2 and qa.Active = 1
And OLM.Active =1
And CD.Active = 1
and itm.active = 1 and qa.validtodate > = Getdate()
union

select distinct cast(NQC.GroupID as varchar(5))+cast(NQC.SchemeID+10000 as varchar(25)) ,Items.Product_code
,cast(Round(Items.PTR / (1 + isnull(NQC.Value,0)/100),2) as decimal(18,2))  AS PTR_exclusive_of_Tax_On_Base_UOM,
cast(Round(((Items.PTR / (1 + isnull(NQC.Value,0)/100))* isnull(Tax.Percentage, 0)/100)+(Items.PTR / (1 + isnull(NQC.Value,0)/100)),2) as decimal(18,2))  AS PTR_inclusive_Tax_On_Base_UOM ,
cast(Round((Items.PTR / (1 + isnull(NQC.Value,0)/100)) * isnull(Items.UOM1_Conversion, 0),2) as decimal(18,2)) as PTR_exclusive_of_Tax_On_UOM1,
cast(Round((((Items.PTR / (1 + isnull(NQC.Value,0)/100))* isnull(Tax.Percentage, 0)/100)+(Items.PTR / (1 + isnull(NQC.Value,0)/100))) * isnull(Items.UOM1_Conversion,0),2) as decimal(18,2))  as PTR_Inclusive_of_Tax_On_UOM1,
cast(Round((Items.PTR / (1 + isnull(NQC.Value,0)/100)) * isnull(Items.UOM2_Conversion, 0),2) as decimal(18,2)) as PTR_exclusive_of_Tax_On_UOM2,
cast(Round((((Items.PTR / (1 + isnull(NQC.Value,0)/100))* isnull(Tax.Percentage, 0)/100)+(Items.PTR / (1 + isnull(NQC.Value,0)/100))) * isnull(Items.UOM2_Conversion, 0),2) as decimal(18,2))  as PTR_Inclusive_of_Tax_On_UOM2,
0 , 0, 1
from

(select schemeid,product_code  from dbo.fn_han_Get_SchemesItems(1)
union
select schemeid,product_code  from dbo.fn_han_Get_SchemesItems(2)) SI
inner join
items on items.product_code=SI.product_code
inner join
Tax on Tax.Tax_code=Items.Sale_Tax
inner join
(select distinct SD.SchemeID, SD.groupid as Groupid, SD.Value
from dbo.mERP_fn_Get_CSOutletScopeHH_QuotPR() SC
inner join
( select distinct TSSD.SchemeID, SubGrp.groupid as Groupid, TSSD.Value from tbl_mERP_SchemeAbstract TSA
inner join tbl_mERP_SchemeSlabDetail TSSD on TSSD.SchemeID = TSA.SchemeID
--CC
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = TSSD.GroupID And SubGrp.SchemeID = TSSD.SchemeID
And TSSD.GroupID In (Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where SchemeID = TSSD.SchemeID And GroupID = SubGrp.GroupID)
--CC 
where isnull(TSSD.GroupID,0)<>0 and TSA.SchemeType = 5
) SD
on SD.Schemeid=SC.schemeid --and SD.groupid=SC.groupid
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = SC.GroupID And SubGrp.SchemeID = SC.SchemeID 
where SC.CustomerCode not in (
select distinct QuotationCustomers.CustomerID from QuotationCustomers
Join QuotationAbstract On QuotationCustomers.QuotationID= QuotationAbstract.QuotationID
join tbl_merp_OLClassMapping OLM on OLM.CustomerID =QuotationCustomers.CustomerID
join tbl_merp_OLClass OL on  OL.ID = OLM.OLClassID
join  tbl_mERP_QuotChannelDetail CD on CD.Channel_Type_Code =OL.Channel_Type_Code
Where OLM.Active =1
And CD.Active = 1
And QuotationAbstract.Active = 1
And QuotationAbstract.QuotationType <> 4
)
) NQC


on SI.Schemeid=NQC.SchemeID
