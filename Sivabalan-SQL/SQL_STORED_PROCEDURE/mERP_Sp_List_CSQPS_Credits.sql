CREATE Procedure mERP_Sp_List_CSQPS_Credits(@SchemeID Int, @PayoutID Int)    
as       
Begin      
  /*Count of Customers*/    
  Select Count(Distinct CustomerID) From tbl_mERP_QPSAbsData Where SchemeID = @SchemeID And PayoutID = @PayoutID and (IsNull(SlabID,0) > 0 Or IsNull(RebateValue,0) > 0 )
  /*List of Customers*/    
  Select SchAbs.ActivityCode, CM.CustomerID, CM.Company_Name, Sum(QPSDtl.SalePrice * QPSDtl.Quantity) SaleValue,  
--  Case SchAbs.ApplicableOn When 1 Then 
--    (Case SchSlab.UOM When 4 Then Sum(QPSDtl.Promoted_Val) Else Sum(QPSDtl.Promoted_Qty) End) Else 
--    (Case SchSlab.UOM When 4 Then QPSAbs.PromotedValue Else QPSAbs.PromotedQuantity End) End,
  Case SchAbs.ApplicableON When 2 then  QPSAbs.PromotedValue Else  Sum(QPSDtl.Promoted_Val) End PromotedValue,
  Case SchSlab.SlabType When 1 Then QPSAbs.RebateValue    
       When 2 Then QPSAbs.RebateValue    
       When 3 Then QPSAbs.RebateQuantity End 'FreeValue',       
  Convert(nVarchar(10), PP.PayoutPeriodFrom, 103) + ' - ' + Convert(nVarchar(10), PP.PayoutPeriodTo, 103) PayoutPeriod,      
  QPSAbs.RowID, QPSAbs.SchemeID, QPSAbs.PayoutID      
  from (Select RowId, SchemeId,PayoutId, GroupID, CustomerID, Max(SlabID) SlabID, Sum(SalesValue) SalesValue, Sum(Quantity) Quantity,
        --Sum(PromotedQuantity) PromotedQuantity, 
        Sum(PromotedValue) PromotedValue, Sum(RebateQuantity) RebateQuantity, Sum(RebateValue) RebateValue, Sum(RFAREbateValue) RFAREbateValue
        From tbl_merp_QPSAbsData 
        Where SchemeID = @SchemeID And PayoutID = @PayoutID and (IsNull(SlabID,0) > 0 Or IsNull(RebateValue,0) > 0 )
        Group By RowId, SchemeId,PayoutId, GroupID, CustomerID) QPSAbs
		Inner Join tbl_mERP_SchemeAbstract SchAbs On SchAbs.SchemeID = QPSAbs.SchemeID       
		Inner Join tbl_merp_SchemePayoutPeriod PP On PP.ID = QPSAbs.PayoutID And  SchAbs.SchemeID = PP.SchemeId 
		Inner Join Customer CM On CM.CustomerID = QPSAbs.CustomerID  
		Inner Join tbl_mERP_QPSDtlData QPSDtl On  QPSAbs.SchemeID = QPSDtl.SchemeID And QPSAbs.PayoutID = QPSDtl.PayoutID  And QPSAbs.CustomerID = QPSDtl.CustomerID
		Left Outer Join tbl_mERP_SchemeSlabDetail SchSlab  On QPSAbs.GroupID = SchSlab.GroupID And SchAbs.SchemeID = SchSlab.SchemeID  And IsNull(QPSAbs.SlabID,0) = SchSlab.SlabID 
		Where (IsNull(QPSAbs.SlabID,0) > 0 Or IsNull(QPSAbs.RebateValue,0) > 0 ) And QPSAbs.SchemeID = @SchemeID And QPSAbs.PayoutID = @PayoutID 
		Group By  SchAbs.ActivityCode,  CM.CustomerID, CM.Company_Name, PP.PayoutPeriodFrom, PP.PayoutPeriodTo, 
		QPSAbs.RowID, QPSAbs.SchemeID, QPSAbs.PayoutID, SchSlab.UOM, SchAbs.ApplicableOn, QPSAbs.PromotedValue,
	    Case SchSlab.SlabType When 1 Then QPSAbs.RebateValue    
       When 2 Then QPSAbs.RebateValue    
       When 3 Then QPSAbs.RebateQuantity End
		Order by SchAbs.ActivityCode,  CM.CustomerID, PP.PayoutPeriodFrom, PP.PayoutPeriodTo      
End
