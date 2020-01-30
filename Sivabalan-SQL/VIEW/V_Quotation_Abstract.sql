Create VIEW  [V_Quotation_Abstract]  
([Quotation_ID],[Customer_ID],[From_Date],[To_Date],[Invoice_Scheme_Allowed])  
AS  
SELECT    QuotationAbstract.QuotationID,QuotationCustomers.CustomerID,QuotationAbstract.ValidFromDate,QuotationAbstract.ValidToDate,   
           QuotationAbstract.AllowInvoiceScheme  
FROM       QuotationAbstract   
	Left Outer Join QuotationCustomers On QuotationCustomers.QuotationID = QuotationAbstract.QuotationID
	join tbl_merp_OLClassMapping OLM on OLM.CustomerID =QuotationCustomers.CustomerID
	join tbl_merp_OLClass OL on  OL.ID = OLM.OLClassID
	join  tbl_mERP_QuotChannelDetail CD on CD.Channel_Type_Code =OL.Channel_Type_Code
	Where QuotationAbstract.Active = 1  
	And OLM.Active =1
	And CD.Active = 1
	AND validtodate > = getdate()
	And QuotationAbstract.QuotationType <> 4
union 
select  cast(SubGrp.GroupID as varchar(5))+cast(SC.SchemeID+10000 as varchar(25)), SC.CustomerCode,SD.ActiveFrom,SD.ActiveTo,1 'Invoice_Scheme_Allowed' 
from dbo.mERP_fn_Get_CSOutletScopeHH_QuotPR() SC
inner join 
 (select distinct TSA.*,TSSD.SlabID as SlabID,TSSD.groupid as Groupid, TSSD.Value from tbl_mERP_SchemeAbstract TSA
 inner join tbl_mERP_SchemeSlabDetail TSSD on TSSD.SchemeID = TSA.SchemeID 
--CC
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = TSSD.GroupID And SubGrp.SchemeID = TSSD.SchemeID
--And TSSD.GroupID In(Select Max(SubGroupID) From tbl_mERP_SchemeSubGroup Where SchemeID = TSSD.SchemeID And GroupID = SubGrp.GroupID)
--CC  	
 where isnull(TSSD.GroupID,0)<>0 and TSA.SchemeType = 5) SD
on SD.Schemeid=SC.schemeid and SD.groupid=SC.groupid 
Inner Join tbl_mERP_SchemeSubGroup SubGrp On SubGrp.SubGroupID = SC.GroupID And SubGrp.SchemeID = SC.SchemeID
where SC.CustomerCode not in 
(
select distinct QuotationCustomers.CustomerID from QuotationCustomers 
Join QuotationAbstract On QuotationCustomers.QuotationID = QuotationAbstract.QuotationID
join tbl_merp_OLClassMapping OLM on OLM.CustomerID =QuotationCustomers.CustomerID
join tbl_merp_OLClass OL on  OL.ID = OLM.OLClassID
join  tbl_mERP_QuotChannelDetail CD on CD.Channel_Type_Code =OL.Channel_Type_Code 
Where OLM.Active =1
And CD.Active = 1
And QuotationAbstract.Active = 1
)
